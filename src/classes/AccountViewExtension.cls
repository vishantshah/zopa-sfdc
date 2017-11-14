public class AccountViewExtension {
    public static final List<String> ADDITIONAL_FIELDS_TO_QUERY = new List<String>{
            'Confirm_sensitive_with_customer__c', 'PersonEmail', 'Is_Sensitive__c', 'SensitiveType__c', 'Comment_to_Sensitive_Account__c', 'Email__c', 'OwnerId'
    };

    public Account CurrentAccount { get; set; }
    public Boolean IsCustomerInArrears { get; set; }
    public Boolean IsSensitive { get; set; }
    public Boolean IsShownPopUp { get; set; }
    public Boolean RenderedErrorMessage { get; set; }
    public Decimal HoldingAccountBalance { get; set; }
    public ApexPages.StandardController StandardController;

    public AccountViewExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(ADDITIONAL_FIELDS_TO_QUERY);
        }
        CurrentAccount = (Account) controller.getRecord();
        IsSensitive = CurrentAccount.Is_Sensitive__c;
        IsCustomerInArrears = false;
        RenderedErrorMessage = false;
        Account curent_account = (Account) controller.getRecord();
        setIsCustomerInArrears(curent_account.Id);
        StandardController = controller;
    }

    public PageReference onPageLoad() {
        if (shouldOverridePage()) {
            HoldingAccountBalance = getHoldingAccountBalance();
            return null;
        } else {
            return redirectToNoOverride();
        }
    }

    private Boolean shouldOverridePage() {
        return isZcp78IsEnabled() && isCurrentPersonAccount();
    }

    @TestVisible
    private Boolean isZcp78IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-78').isFeatureEnabled();
    }

    private Boolean isCurrentPersonAccount() {
        return RecordTypeUtility.getKeyById(CurrentAccount.RecordTypeId) == 'Account.PersonAccount';
    }

    private PageReference redirectToNoOverride() {
        String current_id = ApexPages.currentPage().getParameters().get('id');
        PageReference page_ref = new PageReference('/' + current_id + '?nooverride=1');
        page_ref.setRedirect(true);
        return page_ref;
    }

    public Decimal getHoldingAccountBalance() {
        Loan__c last_loan = getLastLoan();
        if (last_loan != null) {
            ApiCommandGetLoanDetails.LoanDetails last_loan_details = getLoanDetails(last_loan);
            if (last_loan_details != null) {
                return last_loan_details.HoldingAccountBalance;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }

    private Loan__c getLastLoan() {
        List<Loan__c> current_account_loans = [SELECT Loan_Id__c FROM Loan__c WHERE Account__c = :CurrentAccount.Id ORDER BY CreatedDate DESC LIMIT 1];
        if (current_account_loans.size() > 0) {
            return current_account_loans[0];
        } else {
            return null;
        }
    }

    @TestVisible
    private ApiCommandGetLoanDetails.LoanDetails getLoanDetails(Loan__c loan) {
        if (loan.Loan_Id__c == null) {
            MessageUtility.addErrorPageMessage('Loan has not UUID. Cannot perform api call.');
            return null;
        } else {
            ApiCommandGetLoanDetails get_loan_details_command = new ApiCommandGetLoanDetails(loan.Loan_Id__c);
            ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);
            if (get_loan_details_command.CommandSuccessful) {
                return get_loan_details_command.getResponse();
            } else {
                MessageUtility.addErrorPageMessage(get_loan_details_command.CommandError);
                return null;
            }
        }
    }

    public List<SelectOption> getSensitiveType() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult field_result = Account.SensitiveType__c.getDescribe();
        List<Schema.PicklistEntry> picklist = field_result.getPicklistValues();
        for (Schema.PicklistEntry picklist_item : picklist) {
           options.add(new SelectOption(picklist_item.getLabel(), picklist_item.getValue()));
        }
        return options;
    }

    private void setIsCustomerInArrears(Id current_account_id) {
        Integer number_of_loans_in_arrears = [SELECT count() FROM Loan__c WHERE Account__c = :current_account_id AND (Arrears_Ratio__c != null AND Arrears_Ratio__c != 0)];
        if (number_of_loans_in_arrears > 0) {
            IsCustomerInArrears = true;
        }
    }

    public void showMakeSensitivePopUp() {
        IsShownPopUp = true;
    }

    public void hidePopup() {
        IsShownPopUp = false;
    }

    private PageReference getReloadPageRefference() {
        String ret_URL = ApexPages.currentPage().getParameters().get('retURL');
        String current_id = ApexPages.currentPage().getParameters().get('id');
        PageReference page_ref;
        if (ret_URL != null) {
            page_ref = new PageReference('/' + ret_URL);
        } else if (current_id != null) {
            page_ref = new PageReference('/' + current_id);
        }
        page_ref.setRedirect(true);
        return page_ref;
    }

    public PageReference onClickSave() {
        if (validateMarkSensitive()) {
            CurrentAccount.Is_Sensitive__c = true;
            update CurrentAccount;
            if (CurrentAccount.Is_Sensitive__c) {
                List<Case> currently_opened_cases = getOpenCases();
                createNewCaseIfNotExist(currently_opened_cases);
                updateCasesAsSensitive(currently_opened_cases);
                createChatterPosts(currently_opened_cases);
            }
            return getReloadPageRefference();
        }
        return null;
    }

    private Boolean validateMarkSensitive() {
        if (!String.isBlank(CurrentAccount.Comment_to_Sensitive_Account__c)) {
            RenderedErrorMessage = false;
            hidePopup();
            return true;
        } else {
            RenderedErrorMessage = true;
            return false;
        }
    }

    private void createNewCaseIfNotExist(List<Case> currently_opened_cases) {
        if (currently_opened_cases.isEmpty()) {
            List<Loan__c> loans = [SELECT Id FROM Loan__c WHERE Account__c = :CurrentAccount.Id];
            for(Loan__c loan : loans) {
                currently_opened_cases.add(createNewCase(loan));
            }
        }
    }

    private void updateCasesAsSensitive(List<Case> currently_opened_cases) {
        Id sensitive_queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.SENSITIVE);
        Database.DMLOptions sensitive_dml_options = new Database.DMLOptions();
        sensitive_dml_options.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance()
                .getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_SENSITIVE);
        for (Case opened_case : currently_opened_cases) {
            opened_case.Is_Sensitive__c = true;
            opened_case.Description = addCommentToCaseDescription(opened_case.Description);
            opened_case.Process__c = CaseUtility.CASE_PROCESS_SENSITIVE_CUSTOMERS;
            opened_case.Sub_Process__c = 'Sensitive Case';
            opened_case.IsLockedFromUpdatesInProcess__c = true;
            opened_case.OwnerId = sensitive_queue_id;
            opened_case.setOptions(sensitive_dml_options);
        }
        if(!currently_opened_cases.isEmpty()) {
            upsert currently_opened_cases;
        }
    }

    private void createChatterPosts(List<Case> currently_opened_cases) {
        Set<Id> ids_objects_to_add_post = new Set<Id>();
        ids_objects_to_add_post.addAll(new Map<Id, Case>(currently_opened_cases).keySet());
        ids_objects_to_add_post.add(CurrentAccount.Id);
        String comment = CurrentAccount.Comment_to_Sensitive_Account__c;
        if (comment == null) {
            comment = '';
        }
        AgentActionsRecorder.makeChatterPosts(ids_objects_to_add_post,  'Customer Case marked as Sensitive \n ' + comment);
    }

    private String addCommentToCaseDescription(String description) {
        if (String.isEmpty(description)) {
            return CurrentAccount.Comment_to_Sensitive_Account__c;
        }
        return description + ' \n ' + CurrentAccount.Comment_to_Sensitive_Account__c;
    }

    private Case createNewCase(Loan__c loan) {
        Case new_case = CaseBuilder.getBuilder()
                .setAccountId(CurrentAccount.Id)
                .setLoan(loan)
                .setAccountEmail(CurrentAccount.Email__c)
                .setSubject('Collections Case - Sensitive')
                .setStatus('Open')
                .setSubProcess('Sensitive Case')
                .setOrigin('Web')
                .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                .getRecord();
        return new_case;
    }

    private List<Case> getOpenCases(){
        return [
                SELECT Id, OwnerId, Description, Sub_Process__c
                FROM Case
                WHERE IsClosed = false
                AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                AND AccountId =: CurrentAccount.Id
        ];
    }
}