public class BulkCaseChangeExtension {
    public static final List<String> ADDITIONAL_FIELDS_TO_QUERY = new List<string>{'CreatedDate', 'Default_Notice_Sent_Date__c', 'Loan__c'};
    public List<Case> SelectedCases { get; private set; }
    public Case CaseBulkChange { get; set; }
    public List<SelectOption> StatusOptions { get; private set; }
    public String StatusJsonMap { get; set; }
    public Boolean AllRecordsHasCollectionsAndRecoveriesRecordType { get; private set; }
    public enum Action {
        ASSIGN_TO_DCA
    }
    @TestVisible public Action CurrentAction { get; private set; }
    @TestVisible static Map<Action, String> ACTION_POPUP_MESSAGES_MAP = new Map<Action, String>{
            Action.ASSIGN_TO_DCA => 'Bulk assignment to DCA'
    };
    public Map<Action, String> ActionPopupMessages {
        get {
            return ACTION_POPUP_MESSAGES_MAP;
        }
        private set;
    }
    public String DcaAccountId {get; set;}
    private Account DcaAccount;

    public BulkCaseChangeExtension(ApexPages.StandardSetController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(ADDITIONAL_FIELDS_TO_QUERY);
        }
        SelectedCases = (List<Case>) controller.getSelected();
        CaseBulkChange = new Case(RecordTypeId = RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES));
        checkRecordType();
    }

    private void checkRecordType() {
        Boolean result = true;
        for (Case case_item : SelectedCases) {
            if (!isCollectionsAndRecoveriesRecordType(case_item)) {
                result = false;
                break;
            }
        }
        AllRecordsHasCollectionsAndRecoveriesRecordType = result;
    }

    private Boolean isCollectionsAndRecoveriesRecordType(Case case_item) {
        Id collections_and_recoveries_record_type_id = RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES);
        return case_item.RecordTypeId == collections_and_recoveries_record_type_id;
    }

    public void setStatusOptions() {
        if (String.isNotBlank(StatusJsonMap)) {
            Map<String, String> status_options_map = (Map<String, String>) JSON.deserialize(StatusJsonMap, Map<String, String>.class);
            StatusOptions = new List<SelectOption>();
            StatusOptions.add(new SelectOption('', '--None--'));
            for (String option_label : status_options_map.keySet()) {
                StatusOptions.add(new SelectOption(status_options_map.get(option_label), option_label));
            }
        }
    }

    public void save() {
        if (isAnyChanges()) {
            setChangedValues();
            try {
                update SelectedCases;
                MessageUtility.addConfirmPageMessage('Cases has been updated successfully!');
                CaseBulkChange = new Case();
            } catch (DmlException ex) {
                MessageUtility.addErrorPageMessage('Bulk Case change failed!');
            }
        } else {
            MessageUtility.addWarningPageMessage('You need to add some changes!');
        }
    }

    @TestVisible
    private Boolean isAnyChanges() {
        return isProcessChanged()
                || isSubProcessChanged()
                || isStatusChanged()
                || isOwnerChanged();
    }

    private Boolean isProcessChanged() {
        return String.isNotBlank(CaseBulkChange.Process__c);
    }

    private Boolean isSubProcessChanged() {
        return String.isNotBlank(CaseBulkChange.Sub_Process__c);
    }

    private Boolean isStatusChanged() {
        return String.isNotBlank(CaseBulkChange.Status);
    }

    private Boolean isOwnerChanged() {
        return String.isNotBlank(CaseBulkChange.OwnerId);
    }

    private void setChangedValues() {
        for (Case case_item : SelectedCases) {
            if (isProcessChanged()) {
                case_item.Process__c = CaseBulkChange.Process__c;
            }
            if (isSubProcessChanged()) {
                case_item.Sub_Process__c = CaseBulkChange.Sub_Process__c;
            }
            if (isStatusChanged()) {
                case_item.Status = CaseBulkChange.Status;
            }
            if (isOwnerChanged()) {
                case_item.OwnerId = CaseBulkChange.OwnerId;
            }
        }
    }

    public Boolean getIsBulkChangePermissionAvailable() {
        return CustomPermissions.getInstance().isCustomPermissionAvailable('Collections_Recoveries_Bulk_Change');
    }

    public Boolean getIsAnyRecordsSelected() {
        return SelectedCases.size() > 0;
    }

    public void showAssignToDcaPopup() {
        if(isCasesRelatedToLoans() && isRelatedLoansStateProperToAssignLoanToDca()) {
            CurrentAction = Action.ASSIGN_TO_DCA;
        }
    }

    @TestVisible
    private Boolean isCasesRelatedToLoans() {
        List<String> cases_not_related_to_loans = new List<String>();
        for(Case case_item : SelectedCases) {
            if(String.isBlank(case_item.Loan__c)) {
                cases_not_related_to_loans.add(case_item.Id);
            }
        }
        if(cases_not_related_to_loans.isEmpty()) {
            return true;
        } else {
            String cases_not_related_to_loans_string = String.join(cases_not_related_to_loans, ', ');
            MessageUtility.addErrorPageMessage('Some of the selected Cases are not assigned to Loans. Please check the following Cases: ' + cases_not_related_to_loans_string);
            return false;
        }
    }

    @TestVisible
    private Boolean isRelatedLoansStateProperToAssignLoanToDca() {
        Set<Id> related_loan_ids = getRelatedLoanIds();
        List<Loan__c> related_loans = [SELECT Id, State__c FROM Loan__c WHERE Id IN :related_loan_ids];
        List<Id> loans_with_improper_state = new List<Id>();
        for(Loan__c loan : related_loans) {
            if(loan.State__c == 'Arrangement' || loan.State__c == 'Closed' || loan.State__c == 'Deceased' || loan.State__c == 'Settled') {
                loans_with_improper_state.add(loan.Id);
            }
        }
        if(loans_with_improper_state.isEmpty()) {
            return true;
        } else {
            String loans_with_improper_state_string = String.join(loans_with_improper_state, ', ');
            MessageUtility.addErrorPageMessage('You can not assign Loan to DCA when current Loan Status equals: Arrangement, Closed, Deceased or Settled. Please check the following related Loans: ' + loans_with_improper_state_string);
            return false;
        }
    }

    private Set<Id> getRelatedLoanIds() {
        Set<Id> related_loan_ids = new Set<Id>();
        for(Case case_item : SelectedCases) {
            related_loan_ids.add(case_item.Loan__c);
        }
        return related_loan_ids;
    }

    public Boolean getIsCurrentActionAssignToDca() {
        return CurrentAction == Action.ASSIGN_TO_DCA;
    }

    public List<SelectOption> getDcaAccounts() {
        List<SelectOption> options = new List<SelectOption>();
        for (Account current_account : [
                SELECT Id, Name
                FROM Account
                WHERE RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.ACCOUNT_DCA_ACCOUNT)
        ]) {
            options.add(new SelectOption(current_account.Id, current_account.Name));
        }
        return options;
    }

    public void confirmAction() {
        if (CurrentAction == Action.ASSIGN_TO_DCA) {
            onAssignToDcaAction();
        }
        hidePopup();
    }

    private void onAssignToDcaAction() {
        getDcaAccount(DcaAccountId);
        Set<Id> related_loan_ids = getRelatedLoanIds();
        List<Loan__c> related_loans = [SELECT Id, Loan_Id__c, State__c FROM Loan__c WHERE Id IN :related_loan_ids];
        Map<Id, Loan__c> loans_with_success = new Map<Id, Loan__c>();
        Map<Id, Case> cases_with_success = new Map<Id, Case>();
        Map<Id, String> case_id_to_error = new Map<Id, String>();

        for(Loan__c loan : related_loans) {
            Case related_case = getRelatedCaseByLoanId(loan.Id);
            Datetime default_date_for_collection_agency = getDefaultDateForCollectionAgency(loan, related_case);
            ApiCommandPostCollectionAgency command = CollectionAgencyCommandHelper.sendPostCollectionsAgencyToZopaAndReturnCommand(loan.Loan_Id__c, DcaAccount.DCA_Id__c, default_date_for_collection_agency);
            if (command.CommandSuccessful) {
                loans_with_success.put(loan.Id, loan);
                cases_with_success.put(related_case.Id, related_case);
                prepareLoanAndCaseToUpdateAfterAssignToDCA(loan, related_case);
            } else {
                case_id_to_error.put(related_case.Id, command.CommandError);
            }
        }

        updateLoans(loans_with_success.values());
        updateCases(cases_with_success.values());
        if(!cases_with_success.isEmpty()) {
            MessageUtility.addConfirmPageMessage('Cases successfully assigned to DCA: ' + String.join(new List<Id>(cases_with_success.keySet()), ', '));
            createTasksAndChatterPosts(AgentActionsRecorderForCollections.Action.ASSIGN_DCA, '', '(' + DcaAccount.Name + ')', cases_with_success.values());
        }
        if(!case_id_to_error.isEmpty()) {
            String error_message = 'Cases not assigned to DCA:';
            for(String case_id : case_id_to_error.keySet()) {
                error_message += '<br/>' + case_id + ' - ' + case_id_to_error.get(case_id);
            }
            MessageUtility.addErrorPageMessage(error_message);
        }
    }

    private void getDcaAccount(Id dca_account_id){
        List<Account> accounts = [SELECT Id, Name, DCA_Id__c FROM Account WHERE id = :dca_account_id];
        if (accounts.size() != 0){
            DcaAccount = accounts[0];
        }
    }

    private Case getRelatedCaseByLoanId(Id loan_id) {
        for(Case case_item : SelectedCases) {
            if(case_item.Loan__c == loan_id) {
                return case_item;
            }
        }
        return null;
    }

    private Datetime getDefaultDateForCollectionAgency(Loan__c loan, Case case_item){
        if(loan.State__c == 'Default'){
            return case_item.Default_Notice_Sent_Date__c;
        } else {
            return case_item.CreatedDate;
        }
    }

    private void prepareLoanAndCaseToUpdateAfterAssignToDCA(Loan__c loan, Case case_item){
        loan.AccountDCA__c = DcaAccountId;
        case_item.Sub_Process__c = 'DCA';
        case_item.OwnerId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD);
        case_item.IsLockedFromUpdatesInProcess__c = true;
        case_item.AccountDCA__c = DcaAccountId;
    }

    private void updateLoans(List<Loan__c> loans) {
        if(!loans.isEmpty()) {
            update loans;
        }
    }

    private void updateCases(List<Case> cases) {
        if(!cases.isEmpty()) {
            update cases;
        }
    }

    private void createTasksAndChatterPosts(AgentActionsRecorderForCollections.Action current_action, String description, String action_target, List<Case> cases){
        if (current_action != null){
            AgentActionsRecorderForCollections recorder = AgentActionsRecorderForCollections.getInstance(current_action, description, action_target);
            for(Case case_item : cases) {
                recorder.record(case_item);
            }
            recorder.insertNewTasks();
            recorder.insertNewFeedItems();
        }
    }

    public void hidePopup() {
        CurrentAction = null;
    }
}