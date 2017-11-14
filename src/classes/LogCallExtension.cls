public class LogCallExtension{
    public Case CurrentCase {get; set;}
    public Account TheAccount {get; set;}
    public Task NewTask {get; set;}
    public Loan__c TheLoan {get; set;}
    public FollowingOptionsWrapper TheFollowingOptions {get; set;}
    public Loan__c ContainerForFollowUpRequiredDate {get; set;}
    public Loan__c ContainerForPromiseToPayDate {get; set;}
    public Boolean IsFilledRequiredFields {get; private set;}
    public Boolean IsNotApiErrorsOccurred {get; private set;}
    public ApiCommandGetLoanDetails.LoanDetails LoanDetails {get; private set;}
    @TestVisible
    private final Map<String, String> FOLLOWING_OPTIONS = new Map<String, String>{
            'PayNow' => 'Pay Now',
            'PromiseToPay' => 'Promise to Pay',
            'FollowUpRequired' => 'Follow-Up Required',
            'RepaymentArrangement' => 'Repayment Arrangement',
            'Other' => 'Other'
    };
    @TestVisible public String TabToRefreshId {get; private set;}

    public List<SelectOption> getTaskReasons() {
        List<SelectOption> options = new List<SelectOption>();
        for (Collections_Call_Task_Reason__c subject_setting : Collections_Call_Task_Reason__c.getall().values()) {
            options.add(new SelectOption(subject_setting.Task_Reason__c, subject_setting.Task_Reason__c));
        }
        return options;
    }

    public List<SelectOption> getOtherOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (Log_a_Call_Other_Options__c subject_setting : Log_a_Call_Other_Options__c.getAll().values()) {
            options.add(new SelectOption(subject_setting.Value__c, subject_setting.Value__c));
        }
        return options;
    }

    public LogCallExtension(){
        ContainerForFollowUpRequiredDate = new Loan__c(Start_Date__c = System.today().addDays(3));
        ContainerForPromiseToPayDate = new Loan__c();
        String case_id = ApexPages.currentPage().getParameters().get('caseId');
        CurrentCase = [
                SELECT IsClosed, Loan__c, Next_Review_Date__c, Subject, CreatedDate, OwnerId,
                        CaseNumber, Status, AccountId, Loan__r.Loan_Id__c
                FROM Case
                WHERE id = :case_id
        ];
        prepareTabToRefreshId();
        configureInitialValues();
        retrieveOrPrepareNewReviewTask();
    }

    private void prepareTabToRefreshId(){
        TabToRefreshId = ApexPages.currentPage().getParameters().get('tab_to_refresh_id');
    }

    public PageReference setOutboundSubject(){
        NewTask.Subject = 'Outbound Call';
        return stepFirst();
    }

    public PageReference setInboundSubject(){
        NewTask.Subject = 'Inbound Call';
        return stepFirst();
    }

    public PageReference stepStart(){
        clearDpaFields();
        return Page.LogCallFirst;
    }

    public PageReference stepFirst(){
        clearTaskReason();
        clearDpaFields();
        getLoanDetails();
        PageReference page_ref = Page.LogCallSecond;
        addTabToRefreshParam(page_ref);
        return page_ref;
    }

    @TestVisible
    private void addTabToRefreshParam(PageReference page_ref){
        if(String.isNotBlank(TabToRefreshId)) {
            page_ref.getParameters().put('tab_to_refresh_id', TabToRefreshId);
        }
    }

    public PageReference stepSecond(){
        clearTaskReason();
        PageReference page_ref = Page.LogCallThird;
        addTabToRefreshParam(page_ref);
        return page_ref;
    }

    public PageReference stepThird(){
        PageReference page_ref = null;
        IsNotApiErrorsOccurred = true;
        IsFilledRequiredFields = validateVariables();
        if (IsFilledRequiredFields){
            if(TheFollowingOptions.SelectedOptions != 'PromiseToPay'){
                upsertReviewTask();
                page_ref = managementOfSelectedOptions();
            } else if (getIsZcp58IsEnabled() && TheFollowingOptions.SelectedOptions == 'PromiseToPay') {
                updateCaseAsPromiseToPay();
            }
        }
        return page_ref;
    }

    public void saveAndExit(){
        NewTask.Subject = 'Could not Contact. Outbound Call';
        NewTask.Description = NewTask.Reason__c;
        upsertReviewTask();
        updateCaseNextReviewDate(Date.today().addDays(1));
    }

    public void failFlow(){
        if (String.isBlank(NewTask.Reason_for_failed_DPA__c)){
            MessageUtility.addWarningPageMessage('Reason for failed DPA is required, if you click Fail button');
            IsFilledRequiredFields = false;
        } else {
            NewTask.Description = NewTask.Reason_for_failed_DPA__c;
            NewTask.Subject = 'Fail For DPA. ' + NewTask.Subject;
            upsertReviewTask();
            IsFilledRequiredFields = true;
        }
    }

    public void setDPA(){
        String current_dpa = Apexpages.currentPage().getParameters().get('currentDPA');
        NewTask.put(current_dpa,NewTask.get(current_dpa) == true? false : true);
    }

    public PageReference setPassedDpaAndCompleteSecondStep() {
        NewTask.DPA_Passed__c = true;
        return stepSecond();
    }

    private void updateCaseAsPromiseToPay(){
        IsNotApiErrorsOccurred = performCalloutToUpdateStopCommunicationDate();
        if(IsNotApiErrorsOccurred) {
            upsertReviewTask();
            setPromiseToPayFields();
            update CurrentCase;
        } else {
            MessageUtility.addErrorPageMessage('There are some problems with saving your process. Please try again or contact your Support team if this issue persist.');
        }
    }

    @TestVisible
    private Boolean performCalloutToUpdateStopCommunicationDate() {
        if (isLoanWithExternalId()) {
            ApiCommandPutStopCommunicationDate put_stop_communication_date_command = new ApiCommandPutStopCommunicationDate(TheLoan.Loan_Id__c, ContainerForPromiseToPayDate.Start_Date__c);
            HttpResponse http_response = ApiCommandsFactory.getInstance().performApiCommandCallout(put_stop_communication_date_command);
            if (put_stop_communication_date_command.CommandSuccessful) {
                IsNotApiErrorsOccurred = true;
                return true;
            } else {
                MessageUtility.addErrorPageMessage('There are some problems with saving your process. Please try again or contact your Support team if this issue persist.');
                IsNotApiErrorsOccurred = false;
                return false;
            }
        } else {
            return false;
        }
    }

    private Boolean isLoanWithExternalId(){
        return ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(TheLoan.Loan_Id__c);
    }

    private void setPromiseToPayFields() {
        CurrentCase.Status = 'On-Hold';
        setCaseOwnerToOnHold();
        setCaseSubProcessToPromiseToPay();
        Time stop_communication_until_time = Time.newInstance(8, 0, 0, 0);
        Date stop_communication_until_date = ContainerForPromiseToPayDate.Start_Date__c;
        CurrentCase.Stop_Communication_Until__c = DateTime.newInstance(stop_communication_until_date, stop_communication_until_time);
    }

    public Boolean getIsZcp58IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-58').isFeatureEnabled();
    }

    public Boolean getPromiseToPayDateVisible(){
        return TheFollowingOptions.SelectedOptions == 'PromiseToPay';
    }

    public Boolean getIsZcp143IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-143').isFeatureEnabled();
    }

    public Boolean getPayNowExternalSystemLinkVisible(){
        return TheFollowingOptions.SelectedOptions == 'PayNow';
    }

    public Boolean getFollowUpRequiredVisible(){
        return TheFollowingOptions.SelectedOptions == 'FollowUpRequired';
    }

    public Boolean getIsOtherOptionChosen(){
        return TheFollowingOptions.SelectedOptions == 'Other';
    }

    private PageReference managementOfSelectedOptions(){
        if(TheFollowingOptions.SelectedOptions == 'RepaymentArrangement'){
            return goToManagePaymentPlanPage();
        }
        if (getFollowUpRequiredVisible()){
            updateCaseNextReviewDate(ContainerForFollowUpRequiredDate.Start_Date__c);
        }
        return null;
    }

    public PageReference returnToCasePage(){
        PageReference page_ref = Page.CaseCollectionsRecoveries;
        page_ref.getParameters().put('id', CurrentCase.Id);
        page_ref.setRedirect(true);
        return page_ref;
    }

    public PageReference goToManagePaymentPlanPage(){
        PageReference page_ref = Page.ManagePaymentPlan;
        page_ref.getParameters().put('uuid', CurrentCase.Loan__r.Loan_Id__c);
        page_ref.getParameters().put('from_id', CurrentCase.Id);
        page_ref.getParameters().put('case_id', CurrentCase.Id);
        page_ref.getParameters().put('back_page', 'CaseCollectionsRecoveries');
        page_ref.setRedirect(true);
        return page_ref;
    }

    public void clearSecondPage(){
        clearDpaFields();
        clearTaskReason();
    }

    private void getLoanDetails() {
        if(TheLoan != null && ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(TheLoan.Loan_Id__c)){
            ApiCommandGetLoanDetails get_loan_details_command = new ApiCommandGetLoanDetails(TheLoan.Loan_Id__c);
            ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);
            if(get_loan_details_command.CommandSuccessful){
                LoanDetails = get_loan_details_command.getResponse();
            } else {
                MessageUtility.addFatalPageMessage(get_loan_details_command.CommandError);
            }
        }
    }

    private void retrieveOrPrepareNewReviewTask(){
        NewTask = getExistingForReviewTask();
        if(NewTask == null) {
            prepareNewReviewTask();
        }
    }

    private Task getExistingForReviewTask(){
        List<Task> tasks = [
                SELECT Id, Reason__c, Review_Due_Date__c, Subject
                FROM Task
                WHERE WhatId = :CurrentCase.Id
                AND Subject = 'For Review'
                AND IsClosed = false
        ];
        return tasks.isEmpty() ? null : tasks[0];
    }

    @TestVisible
    private void prepareNewReviewTask(){
        NewTask = new Task(
                TaskSubtype = 'Call',
                WhatId = CurrentCase.Id,
                RecordTypeId = RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL),
                WhoId = TheAccount != null ? TheAccount.PersonContactId : null
        );
    }

    @TestVisible
    private void upsertReviewTask(){
        NewTask.Status = 'Completed';
        NewTask.CompletedDateTime__c = System.now();
        if(NewTask.Review_Due_Date__c == null){
            NewTask.Review_Due_Date__c = NewTask.CompletedDateTime__c;
        }
        if (FOLLOWING_OPTIONS.containsKey(TheFollowingOptions.SelectedOptions)){
            NewTask.Status = FOLLOWING_OPTIONS.get(TheFollowingOptions.SelectedOptions);
        }
        upsert NewTask;
    }

    private void updateCaseNextReviewDate(Date next_review_date){
        setCaseOwnerToOnHold();
        Time current_time = Time.newInstance(8, 0, 0, 0);
        CurrentCase.Next_Review_Date__c = DateTime.newInstance(next_review_date,current_time);
        update CurrentCase;
    }

    public void setCaseOwnerToOnHold(){
        Id on_hold_queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD);
        CurrentCase.OwnerId = on_hold_queue_id;
    }

    private void setCaseSubProcessToPromiseToPay(){
        CurrentCase.Sub_Process__c = 'Promise to Pay';
    }

    private void configureInitialValues(){
        TheFollowingOptions = new FollowingOptionsWrapper();
        List<Account> related_accounts = [SELECT id, MemberID__c, Name, PersonEmail, Email__c, Date_Of_Birth__c, HouseNumber__c, Street1__c, Street2__c, Postcode__c, PersonContactId FROM Account WHERE id = :CurrentCase.AccountId LIMIT 1];
        if (related_accounts.size() != 0){
            TheAccount = related_accounts[0];
        }
        List<Loan__c> related_loans = [SELECT id, Loan_id__c FROM Loan__c WHERE id = :CurrentCase.Loan__c];
        if (related_loans.size() != 0){
            TheLoan = related_loans[0];
        }
    }

    @TestVisible
    private Boolean validateVariables(){
        Boolean result = true;
        if (TheFollowingOptions.SelectedOptions == null) {
            result = false;
            MessageUtility.addWarningPageMessage('You need to choose one of the options');
        } else if (TheFollowingOptions.SelectedOptions == 'FollowUpRequired'){
            result = validateDate(ContainerForFollowUpRequiredDate.Start_Date__c, 'Follow-Up');
        } else if (TheFollowingOptions.SelectedOptions == 'PromiseToPay'){
            result = validateDate(ContainerForPromiseToPayDate.Start_Date__c, 'Promise to Pay');
        }
        return result;
    }

    private Boolean validateDate(Date date_to_check, String date_name) {
        Boolean result = true;
        if (date_to_check == null) {
            result = false;
            MessageUtility.addWarningPageMessage(date_name + ' Date is required, if you mark ' + date_name + ' Required');
        }
        else if (date_to_check < Date.today()) {
            result = false;
            MessageUtility.addWarningPageMessage(date_name + ' Date can`t be in the past');
        }
        return result;
    }

    public String getDateOfBirthFormated() {
        return TheAccount.Date_Of_Birth__c == null ? '' : TheAccount.Date_Of_Birth__c.format();
    }

    @TestVisible
    private void clearDpaFields(){
        NewTask.DPA_Full_Name__c = false;
        NewTask.DPA_Email_Address__c = false;
        NewTask.DPA_Date_of_Birth__c = false;
        NewTask.DPA_Postcode__c = false;
        NewTask.DPA_Member_Id__c = false;
        NewTask.DPA_Contractual_Repayment__c = false;
        NewTask.DPA_Repayment_Date__c = false;
    }

    @TestVisible
    private void clearTaskReason(){
        NewTask.Reason_for_failed_DPA__c = '';
        NewTask.Reason__c = '';
    }

    public class FollowingOptionsWrapper{
        public String SelectedOptions {get; set;}
        public SelectOption PayNow {get; set;}
        public SelectOption PromiseToPay {get; set;}
        public SelectOption FollowUpRequired {get; set;}
        public SelectOption RepaymentArrangement {get; set;}
        public SelectOption Other {get; set;}

        public FollowingOptionsWrapper(){
            PayNow = new SelectOption('PayNow','Pay Now');
            PromiseToPay = new SelectOption('PromiseToPay','Promise to Pay');
            FollowUpRequired = new SelectOption('FollowUpRequired','Follow-Up Required');
            RepaymentArrangement = new SelectOption('RepaymentArrangement','Repayment Arrangement');
            Other = new SelectOption('Other','Other');
        }
    }
}