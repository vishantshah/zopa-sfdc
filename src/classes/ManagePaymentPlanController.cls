public class ManagePaymentPlanController {

    public String LoanId { get; set; }
    public String FromId { get; set; }
    public String CaseId { get; set; }
    public Loan__c CurrentLoan { get; private set; }
    public Case CurrentCase { get; private set; }
    public String PreviousPageName { get; set; }
    public Boolean ThereIsActivePaymentPlan { get; set; }
    public ApiCommandLoanGetPaymentPlans.PaymentPlan ActivePaymentPlan { get; set; }
    public ApiCommandLoanGetPaymentPlans.PaymentPlan InitActivePaymentPlan { get; set; }
    public List<ApiCommandLoanGetPaymentPlans.PaymentPlan> ExistingPaymentPlans { get; set; }
    public List<SelectOption> ArrangementSelectOptions { get; private set; }
    public List<SelectOption> DurationSelectOptions { get; private set; }
    public List<SelectOption> FrequencySelectOptions { get; private set; }
    public List<SelectOption> MethodSelectOptions { get; private set; }
    public List<SelectOption> ArrearsReasonSelectOptions { get; private set; }
    public List<SelectOption> StateSelectOptions { get; private set; }
    public List<SelectOption> PaymentDaySelectOptions { get; private set; }
    public Case CaseHelper { get; set; }

    public ManagePaymentPlanController() {
        getPageParams();
        getRelatedLoan();
        getRelatedCase();
        initSelectOptions();
        CaseHelper = new Case(
                Payment_Plan_Start_Date__c = Datetime.now()
        );
    }

    private void getPageParams() {
        LoanId = ApexPages.currentPage().getParameters().get('loan_id');
        CaseId = ApexPages.currentPage().getParameters().get('case_id');
        FromId = ApexPages.currentPage().getParameters().get('from_id');
        PreviousPageName = ApexPages.currentPage().getParameters().get('back_page');
    }

    private void getRelatedLoan() {
        CurrentLoan = [SELECT Id, Loan_Id__c FROM Loan__c WHERE Id = :LoanId];
    }

    private void getRelatedCase() {
        if (String.isNotBlank(CaseId)) {
            CurrentCase = [
                    SELECT Id, IsLockedFromUpdatesInProcess__c, Loan__c, OwnerId, Payment_Plan_Start_Date__c, RecordTypeId, Sub_Process__c
                    FROM Case
                    WHERE Id = :CaseId
            ];
        }
    }

    private void initSelectOptions() {
        StateSelectOptions = new List<SelectOption>{
                new SelectOption('Active', 'Active'),
                new SelectOption('Completed', 'Completed'),
                new SelectOption('Failed', 'Failed'),
                new SelectOption('Revised', 'Revised')
        };
        ArrangementSelectOptions = new List<SelectOption>();
        List<Schema.PicklistEntry> payment_plan_with_picklist_entries = Case.Payment_Plan_With__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry picklist_entry : payment_plan_with_picklist_entries) {
            ArrangementSelectOptions.add(new SelectOption(picklist_entry.getLabel(), picklist_entry.getValue()));
        }
        DurationSelectOptions = new List<SelectOption>{
                new SelectOption('ThreeMonths', 'Three Months'),
                new SelectOption('SixMonths', 'Six Months'),
                new SelectOption('LongTerm', 'Long Term'),
                new SelectOption('Other', 'Other')
        };
        FrequencySelectOptions = new List<SelectOption>{
                new SelectOption('Monthly', 'Monthly')
        };
        MethodSelectOptions = new List<SelectOption>{
                new SelectOption('BACS', 'Bacs'),
                new SelectOption('DebitCard', 'Debit Card'),
                new SelectOption('Cheque', 'Cheque')
        };
        ArrearsReasonSelectOptions = new List<SelectOption>{
                new SelectOption('Sickness', 'Sickness'),
                new SelectOption('Unemployed', 'Unemployment'),
                new SelectOption('Overcommitted', 'Overcommitted'),
                new SelectOption('Mismanagement', 'Mismanagement'),
                new SelectOption('Unknown', 'Other')
        };
        PaymentDaySelectOptions = getPaymentDaySelectOptions();
    }

    private List<SelectOption> getPaymentDaySelectOptions() {
        List<SelectOption> select_options = new List<SelectOption>();
        for (Integer i = 1; i <= 28; i++) {
            select_options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return select_options;
    }

    public void getExistingPaymentPlans() {
        ActivePaymentPlan = new ApiCommandLoanGetPaymentPlans.PaymentPlan();
        InitActivePaymentPlan = null;
        ExistingPaymentPlans = new List<ApiCommandLoanGetPaymentPlans.PaymentPlan>();
        ThereIsActivePaymentPlan = false;
        if (ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(CurrentLoan.Loan_Id__c)) {
            ApiCommandLoanGetPaymentPlans get_payment_plans_command = new ApiCommandLoanGetPaymentPlans(CurrentLoan.Loan_Id__c);
            HttpResponse http_response = ApiCommandsFactory.getInstance().performApiCommandCallout(get_payment_plans_command);
            if (get_payment_plans_command.CommandSuccessful) {
                MessageUtility.addConfirmPageMessage('Payment Plans have been successfully retrieved.');
                ExistingPaymentPlans = get_payment_plans_command.getResponse(http_response.getBody());
                if (!ExistingPaymentPlans.isEmpty()) {
                    getActivePaymentPlan();
                }
            } else {
                if (http_response.getStatusCode() == 404) {
                    MessageUtility.addInfoPageMessage('There are no existing Payment Plans for this loan.');
                } else {
                    MessageUtility.addErrorPageMessage('Cannot retrieve Payment Plans. ' + get_payment_plans_command.CommandError);
                }
            }
        }
    }

    private void getActivePaymentPlan() {
        for (ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan : ExistingPaymentPlans) {
            if (payment_plan.State == 'Active') {
                ActivePaymentPlan = payment_plan;
                InitActivePaymentPlan = payment_plan.clone();
                ThereIsActivePaymentPlan = true;
                CaseHelper.Payment_Plan_Start_Date__c = ActivePaymentPlan.CreatedDate;
                break;
            }
        }
    }

    public PageReference redirectToPreviousPage() {
        PageReference page_ref = new PageReference('/apex/' + PreviousPageName);
        page_ref.getParameters().put('id', FromId);
        page_ref.setRedirect(true);
        return page_ref;
    }

    public void save() {
        if (!ThereIsActivePaymentPlan) {
            createNewPaymentPlan();
        } else {
            editActivePaymentPlan();
        }
    }

    private void createNewPaymentPlan() {
        if (ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(CurrentLoan.Loan_Id__c)) {
            setCreatedDateOfPaymentPlan();
            if (validatePaymentPlan(ActivePaymentPlan)) {
                postPaymentPlan();
            }
        }
    }

    private void editActivePaymentPlan() {
        if (isActivePlanChanged()) {
            if (validatePaymentPlan(ActivePaymentPlan)) {
                putPaymentPlan();
            }
        } else {
            MessageUtility.addErrorPageMessage('Please, change any field\'s value to update Active Payment Plan.');
        }
    }

    private void setCreatedDateOfPaymentPlan() {
        ActivePaymentPlan.CreatedDate = CaseHelper.Payment_Plan_Start_Date__c;
    }

    private Boolean validatePaymentPlan(ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan) {
        Boolean result = true;
        result &= isAmountValid(payment_plan);
        if(!ThereIsActivePaymentPlan) {
            result &= isCreatedDateValid(payment_plan);
        }
        return result;
    }

    @TestVisible
    private Boolean isCreatedDateValid(ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan) {
        if (payment_plan.CreatedDate != null
                && payment_plan.CreatedDate.date() >= System.today()) {
            return true;
        } else {
            MessageUtility.addErrorPageMessage('Incorrect value of Created Date field!');
            return false;
        }
    }

    @TestVisible
    private Boolean isAmountValid(ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan) {
        if (payment_plan.Amount != null && payment_plan.Amount > 0) {
            return true;
        } else {
            MessageUtility.addErrorPageMessage('Incorrect value of Amount field!');
            return false;
        }
    }

    private Boolean isActivePlanChanged() {
        return !InitActivePaymentPlan.equal(ActivePaymentPlan);
    }

    private void postPaymentPlan() {
        ApiCommandLoanPostPaymentPlans command = new ApiCommandLoanPostPaymentPlans(CurrentLoan.Loan_Id__c, ActivePaymentPlan);
        HttpResponse http_response = ApiCommandsFactory.getInstance().performApiCommandCallout(command);
        if (command.CommandSuccessful) {
            MessageUtility.addConfirmPageMessage('New Payment Plan has been successfully created!');
            setLoanToArrangementsState();
        } else {
            MessageUtility.addErrorPageMessage('Cannot create Payment Plan. ' + command.CommandError);
        }
    }

    private void putPaymentPlan() {
        ApiCommandLoanPutPaymentPlans command = new ApiCommandLoanPutPaymentPlans(CurrentLoan.Loan_Id__c, ActivePaymentPlan);
        ApiCommandsFactory.getInstance().performApiCommandCallout(command);
        if (command.CommandSuccessful) {
            MessageUtility.addConfirmPageMessage('Active Payment Plan has been successfully updated!');
            if (CurrentCase != null) {
                updateRelatedCaseAfterUpdateOfPaymentPlan();
            }
            createTasksAndFeedItems(
                    AgentActionsRecorderForCollections.Action.UPDATED_REPAYMENT_ARRANGEMENT,
                    createTaskComment()
            );
        } else {
            MessageUtility.addErrorPageMessage('Cannot update Payment Plan. ' + command.CommandError);
        }
    }

    private void setLoanToArrangementsState() {
        ApiCommandSetToArrangement command = new ApiCommandSetToArrangement(CurrentLoan.Loan_Id__c);
        ApiCommandsFactory.getInstance().performApiCommandCallout(command);
        if (command.CommandSuccessful) {
            MessageUtility.addConfirmPageMessage('Loan State has been successfully changed to "Arrangements"!');
            if (CurrentCase != null) {
                updateRelatedCaseWithArrangementsSubProcess();
                createTasksAndFeedItems(
                        AgentActionsRecorderForCollections.Action.CREATED_REPAYMENT_ARRANGEMENT,
                        createTaskComment()
                );
            }
        } else {
            MessageUtility.addErrorPageMessage('Cannot set Loan State to "Arrangements". ' + command.CommandError);
        }
    }

    private void updateRelatedCaseWithArrangementsSubProcess() {
        CurrentCase.OwnerId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD);
        CurrentCase.IsLockedFromUpdatesInProcess__c = true;
        CurrentCase.Sub_Process__c = 'Arrangements';
        CurrentCase.Payment_Plan_Start_Date__c = Datetime.now();
        CurrentCase.Payment_Plan_End_Date__c = CurrentCase.Payment_Plan_Start_Date__c.addMonths(getPaymentPlanDurationInMonths(ActivePaymentPlan));
        CurrentCase.Payment_Plan_With__c = ActivePaymentPlan.Arrangement;
        update CurrentCase;
        MessageUtility.addConfirmPageMessage('Case has been successfully updated after creating new Payment Plan!');
    }

    private void updateRelatedCaseAfterUpdateOfPaymentPlan() {
        if(CurrentCase.Payment_Plan_Start_Date__c == null) {
            CurrentCase.Payment_Plan_Start_Date__c = ActivePaymentPlan.CreatedDate;
        }
        CurrentCase.Payment_Plan_End_Date__c = CurrentCase.Payment_Plan_Start_Date__c.addMonths(getPaymentPlanDurationInMonths(ActivePaymentPlan));
        CurrentCase.Payment_Plan_With__c = ActivePaymentPlan.Arrangement;
        update CurrentCase;
        MessageUtility.addConfirmPageMessage('Case has been successfully updated after update of Payment Plan!');
    }

    @TestVisible
    private Integer getPaymentPlanDurationInMonths(ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan) {
        if (payment_plan.Duration == 'ThreeMonths') {
            return 3;
        } else if (payment_plan.Duration == 'SixMonths') {
            return 6;
        } else {
            return 6;
        }
    }

    private void createTasksAndFeedItems(AgentActionsRecorderForCollections.Action action, String comment) {
        AgentActionsRecorderForCollections recorder = AgentActionsRecorderForCollections.getInstance(
                action,
                comment
        );
        recorder.record(CurrentLoan.Id);
        recorder.insertNewTasks();
        recorder.insertNewFeedItems();
    }

    private String createTaskComment() {
        String task_comment = 'Active Payment Plan: ' + '\n'
                + 'Arrangement - ' + ActivePaymentPlan.Arrangement + ';\n'
                + 'Amount - ' + ActivePaymentPlan.Amount + ';\n'
                + 'Duration - ' + ActivePaymentPlan.Duration + ';\n'
                + 'Payment Day - ' + ActivePaymentPlan.PaymentDay + ';\n'
                + 'Frequency - ' + ActivePaymentPlan.Frequency + ';\n'
                + 'Method - ' + ActivePaymentPlan.Method + ';\n'
                + 'Arrears Reason - ' + ActivePaymentPlan.ArrearsReason + ';';
        return task_comment;
    }
}