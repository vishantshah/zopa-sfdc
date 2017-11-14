public class LoanViewExtension {
    public Boolean IsCustomerInArrears {get; set;}
    public Process CurrentProcess {get; set;}
    public Loan__c CurrentLoan {get;set;}
    public Case RelatedCase {get; set;}
    public Account RelatedDCA {get; set;}
    public Account RelatedDMC {get; set;}
    public Boolean IsCollectionsNotesInEditMode {get; private set;}
    public String AccountDcaId {get; set;}
    public String AccountDmcId {get; set;}
    public String SelectedReason {get; set;}
    public ApiCommandGetLoanDetails.LoanDetails LoanDetails {get; set;}
    public enum Process {
        CONFIRM_DECEASED,
        SET_WITHDRAWN,
        SETTLE_CASE,
        CONFIRM_COLLECTIONS,
        CONFIRM_DEFAULT,
        ASSIGN_DCA,
        RECALL_FROM_DCA,
        ASSIGN_DMC,
        RECALL_FROM_DMC,
        CREATE_COLLECTIONS_AND_RECOVERIES_CASE
    }
    public static final Map<Process, String> POPUP_MESSAGES_MAP {get;set;}
    private final List<String> LOAN_FIELDS_FOR_RETRIEVE = new List<String>{
            'Account__c', 'AccountDCA__c', 'AccountDMC__c', 'Arrears_Ratio__c', 'Collections_Notes__c', 'Default_Reason__c',
            'Loan_id__c', 'Name', 'State__c'
    };
    static{
        POPUP_MESSAGES_MAP = new Map<Process, String> {
                Process.CONFIRM_DECEASED => 'This action will update Loan status to Rialto',
                Process.SETTLE_CASE => 'This action will settle a case',
                Process.CONFIRM_COLLECTIONS => 'This action will update Loan status to Collections',
                Process.SET_WITHDRAWN => 'This action will set Loan to Withdrawn',
                Process.CONFIRM_DEFAULT => 'This action will set Loan to Default',
                Process.ASSIGN_DCA => 'This action will assign Loan to DCA',
                Process.RECALL_FROM_DCA => 'This action will unassign Loan and DCA',
                Process.ASSIGN_DMC => 'This action will assign Loan to DMC',
                Process.RECALL_FROM_DMC => 'This action will unassign Loan from DMC',
                Process.CREATE_COLLECTIONS_AND_RECOVERIES_CASE => 'This action will Create Collections & Recoveries Case'
        };
    }
    private Boolean IsLoanStateListenerEnabled = false;
    public Boolean IsPageReadyToRefresh {get; private set;}

    public LoanViewExtension(ApexPages.StandardController controller) {
        if(!Test.isRunningTest()){
            controller.addFields(LOAN_FIELDS_FOR_RETRIEVE);
        }
        CurrentLoan = (Loan__c)controller.getRecord();
        setIsCustomerInArrears(CurrentLoan.Arrears_Ratio__c);
        IsCollectionsNotesInEditMode = false;
        IsPageReadyToRefresh = false;
        getLoanDetails();
        getRelatedCase();
    }

    public void getLoanDetails() {
        String loan_uuid = CurrentLoan.Loan_Id__c;
        if(ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(loan_uuid)){
            ApiCommandGetLoanDetails get_loan_details_command = new ApiCommandGetLoanDetails(loan_uuid);
            ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);
            if(get_loan_details_command.CommandSuccessful){
                LoanDetails = get_loan_details_command.getResponse();
            }
        }
    }

    public List<SelectOption> getAccountsDca() {
        List<Account> dca_accounts = getAccountsByRecordType(RecordTypeUtility.ACCOUNT_DCA_ACCOUNT);
        return getAccountsSelectOptions(dca_accounts);
    }

    public List<SelectOption> getAccountsDmc() {
        List<Account> dmc_accounts = getAccountsByRecordType(RecordTypeUtility.ACCOUNT_DMC_ACCOUNT);
        return getAccountsSelectOptions(dmc_accounts);
    }

    private List<Account> getAccountsByRecordType(String record_type_name) {
        return [SELECT Id, Name FROM Account WHERE RecordTypeId = :RecordTypeUtility.getIdByName(record_type_name)];
    }

    private List<SelectOption> getAccountsSelectOptions(List<Account> accounts) {
        List<SelectOption> options = new List<SelectOption>();
        for (Account current_account : accounts) {
            options.add(new SelectOption(current_account.Id, current_account.Name));
        }
        return options;
    }

    public Boolean getIsTheConfirmCollectionsButtonAvailable(){
        return getIsZcp107IsEnabled() && !checkCaseProcess(CaseUtility.CASE_PROCESS_RECOVERIES);
    }

    public Boolean getIsAssignToDcaButtonAvailable(){
        return getIsZcp123IsEnabled() && !isDcaForLoan();
    }

    public Boolean getIsUnassignToDcaButtonAvailable(){
        return getIsZcp123IsEnabled() && isDcaForLoan();
    }

    public Boolean getIsPicklistDcaAccountsVisible(){
        return getIsAssignToDcaButtonAvailable() && CurrentProcess == Process.ASSIGN_DCA;
    }

    private void setIsCustomerInArrears(Decimal arears_ratio){
        IsCustomerInArrears = arears_ratio > 0;
    }

    public void showMakeDefaultPopup() {
        CurrentProcess = Process.CONFIRM_DEFAULT;
    }

    public void showConfirmDeceasedPopup() {
        CurrentProcess = Process.CONFIRM_DECEASED;
    }

    public void showConfirmCollectionsPopup() {
        CurrentProcess = Process.CONFIRM_COLLECTIONS;
    }

    public void showSetWithdrawnPopup() {
        CurrentProcess = Process.SET_WITHDRAWN;
    }

    public void showRecallDcaPopup() {
        CurrentProcess = Process.RECALL_FROM_DCA;
    }

    public void showAssignDcaPopup() {
        if(isRelatedLoanStateProperToAssignLoanToDca()) {
            CurrentProcess = Process.ASSIGN_DCA;
        } else {
            MessageUtility.addErrorPageMessage('You can not assign Loan to DCA when current Loan Status equals: Arrangement, Closed, Deceased or Settled. Current Loan Status: ' + CurrentLoan.State__c + '.');
        }
    }

    private Boolean isRelatedLoanStateProperToAssignLoanToDca() {
        return CurrentLoan.State__c != 'Arrangement' && CurrentLoan.State__c != 'Closed' && CurrentLoan.State__c != 'Deceased' && CurrentLoan.State__c != 'Settled';
    }

    public void showAssignDmcPopup() {
        CurrentProcess = Process.ASSIGN_DMC;
    }

    public void showRecallDmcPopup() {
        CurrentProcess = Process.RECALL_FROM_DMC;
    }

    public void showCreateCollectionsAndRecoveriesCasePopup() {
        CurrentProcess = Process.CREATE_COLLECTIONS_AND_RECOVERIES_CASE;
    }

    public void enableEditModeForCollectionsNotes() {
        IsCollectionsNotesInEditMode = true;
    }

    public void saveCollectionsNotes() {
        IsCollectionsNotesInEditMode = false;
        updateLoan();
    }

    public Boolean checkCaseProcess(String process){
        getRelatedCase();
        return RelatedCase != null && RelatedCase.Process__c == process;
    }

    public void hidePopup() {
        CurrentProcess = null;
    }

    public Boolean getIsZcp106IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-106').isFeatureEnabled();
    }

    public Boolean getIsZcp105IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-105').isFeatureEnabled();
    }

    public Boolean getIsZcp107IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-107').isFeatureEnabled();
    }

    public Boolean getIsZcp98IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-98').isFeatureEnabled();
    }

    public Boolean getIsZcp24IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-24').isFeatureEnabled();
    }

    public Boolean getIsZcp76IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-76').isFeatureEnabled();
    }

    public Boolean getIsZcp123IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-123').isFeatureEnabled();
    }

    public Boolean getShownManualSetWithdrawn(){
        getRelatedCase();
        return getIsZcp106IsEnabled() && checkCaseProcess(CaseUtility.CASE_PROCESS_COLLECTIONS);
    }

    public Boolean getIsDefaultAction(){
        return CurrentProcess == Process.CONFIRM_DEFAULT;
    }

    public Boolean getIsRelatedCaseExist(){
        getRelatedCase();
        return RelatedCase != null;
    }

    public Boolean getIsManagePaymentPlanVisible(){
        return getIsZcp24IsEnabled();
    }

    public Boolean getIsMakeDefaultButtonAvailable(){
        return CustomPermissions.getInstance().isCustomPermissionAvailable('Make_Default_on_Collections_Case')
                && getIsZcp76IsEnabled()
                && (LoanDetails != null)
                && LoanDetails.State != 'Default';
    }

    public Boolean getIsPicklistDmcAccountsVisible(){
        return getIsAssignToDmcButtonAvailable() && CurrentProcess == Process.ASSIGN_DMC;
    }

    public Boolean getIsAssignToDmcButtonAvailable(){
        return Case.AccountDMC__c.getDescribe().isUpdateable()
                && Loan__c.AccountDMC__c.getDescribe().isUpdateable()
                && String.isBlank(CurrentLoan.AccountDMC__c);
    }

    public Boolean getIsRecallFromDmcButtonAvailable(){
        return Case.AccountDMC__c.getDescribe().isUpdateable()
                && Loan__c.AccountDMC__c.getDescribe().isUpdateable()
                && String.isNotBlank(CurrentLoan.AccountDMC__c);
    }

    public Boolean getIsCreateCollectionsAndRecoveriesCaseButtonAvailable(){
        return RelatedCase == null
                && CustomPermissions.getInstance().isCustomPermissionAvailable('Create_Collections_Recoveries_Case_Button');
    }

    public void confirmAction() {
        getRelatedCase();
        AgentActionsRecorderForCollections.Action current_action;
        String description = '';
        String action_target = '';
        if(CurrentProcess == Process.CONFIRM_DECEASED){
            if(LoanStateDeceasedHelper.changeLoanStatusToRialtoToDeceased(CurrentLoan.Loan_Id__c)){
                current_action = AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED;
                createTaskAndChatterPost(current_action, description, action_target);
            }
        } else if(CurrentProcess == Process.SET_WITHDRAWN){
            if(LoanSetToWithdrawnHandler.setLoanToWithdrawnFromPageAction(CurrentLoan)) {
                current_action = AgentActionsRecorderForCollections.Action.SET_WITHDRAWN;
                createTaskAndChatterPost(current_action, description, action_target);
            }
        } else if(CurrentProcess == Process.CONFIRM_COLLECTIONS){
            if (LoanStateCollectionsHelper.changeLoanStatusToRialtoToCollections(CurrentLoan.Loan_Id__c)){
                current_action = AgentActionsRecorderForCollections.Action.CONFIRM_COLLECTIONS;
                createTaskAndChatterPost(current_action, description, action_target);
            }
        } else if(CurrentProcess == Process.CONFIRM_DEFAULT){
            if (LoanStateDefaultHelper.changeLoanStatusToRialtoToDefault(CurrentLoan.Loan_Id__c, CurrentLoan.Default_Reason__c)){
                update CurrentLoan;
                IsLoanStateListenerEnabled = true;
            }
        } else if(CurrentProcess == Process.ASSIGN_DCA){
            getDCA(AccountDcaId);
            if(ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(CurrentLoan.Loan_Id__c)) {
                ApiCommandPostCollectionAgency command = CollectionAgencyCommandHelper.sendPostCollectionsAgencyToZopaAndReturnCommand(CurrentLoan.Loan_Id__c, RelatedDCA.DCA_Id__c, getDefaultDateForCollectionAgency());
                if (command.CommandSuccessful) {
                    MessageUtility.addConfirmPageMessage('Loan assigned to DCA successfully. Response: ' + command.getResponseBody());
                    current_action = AgentActionsRecorderForCollections.Action.ASSIGN_DCA;
                    changeCaseAfterAssignToDCA();
                    createTaskAndChatterPost(current_action, description, action_target);
                } else {
                    MessageUtility.addErrorPageMessage(command.CommandError);
                }
            }
        } else if(CurrentProcess == Process.RECALL_FROM_DCA){
            getDCA(CurrentLoan.AccountDCA__c);
            changeDcaOnLoanAndCase(null);
            MessageUtility.addConfirmPageMessage('DCA was unassigned with Loan successfully');
            current_action = AgentActionsRecorderForCollections.Action.RECALL_FROM_DCA;
            action_target = '(' + RelatedDCA.Name + ')';
            createTaskAndChatterPost(current_action, description, action_target);
        } else if(CurrentProcess == Process.ASSIGN_DMC){
            getDMC(AccountDmcId);
            changeCaseAndLoanAfterAssignToDMC();
            MessageUtility.addConfirmPageMessage('Loan assigned to DMC successfully.');
            current_action = AgentActionsRecorderForCollections.Action.ASSIGN_DMC;
            action_target = '(' + RelatedDMC.Name + ')';
            createTaskAndChatterPost(current_action, description, action_target);
        } else if(CurrentProcess == Process.RECALL_FROM_DMC){
            getDMC(CurrentLoan.AccountDMC__c);
            changeCaseAndLoanAfterRecallFromDMC();
            MessageUtility.addConfirmPageMessage('Loan has been successfully unassigned from DMC.');
            current_action = AgentActionsRecorderForCollections.Action.RECALL_FROM_DMC;
            action_target = '(' + RelatedDMC.Name + ')';
            createTaskAndChatterPost(current_action, description, action_target);
        } else if(CurrentProcess == Process.CREATE_COLLECTIONS_AND_RECOVERIES_CASE){
            getRelatedCase();
            if(RelatedCase == null){
                createCollectionsRecoveriesCase();
                MessageUtility.addConfirmPageMessage('New Collections & Recoveries Case created successfully - ' + RelatedCase.Id);
                current_action = AgentActionsRecorderForCollections.Action.CREATE_COLLECTIONS_AND_RECOVERIES_CASE;
                createTaskAndChatterPost(current_action, description, action_target);
            } else{
                MessageUtility.addErrorPageMessage('There is an existing open Collections & Recoveries Case - ' + RelatedCase.Id);
            }
        }
        hidePopup();
    }

    private void changeCaseAfterSettingStateToWithdrawn(){
        if(RelatedCase != null) {
            RelatedCase.Status = 'Withdrawn';
            updateCase();
        }
    }

    private void changeCaseAfterAssignToDCA(){
        RelatedCase.Sub_Process__c = 'DCA';
        RelatedCase.OwnerId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD);
        RelatedCase.IsLockedFromUpdatesInProcess__c = true;
        changeDcaOnLoanAndCase(RelatedDCA.Id);
    }

    private void changeCaseAndLoanAfterAssignToDMC(){
        if(RelatedCase != null) {
            RelatedCase.Sub_Process__c = 'With DMC';
            RelatedCase.OwnerId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD);
            RelatedCase.IsLockedFromUpdatesInProcess__c = true;
        }
        changeDmcOnLoanAndCase(RelatedDMC.Id);
    }

    private void changeCaseAndLoanAfterRecallFromDMC(){
        if(RelatedCase != null) {
            RelatedCase.IsLockedFromUpdatesInProcess__c = false;
        }
        changeDmcOnLoanAndCase(null);
    }

    private void createTaskAndChatterPost(AgentActionsRecorderForCollections.Action current_action, String description, String action_target){
        if (current_action != null){
            AgentActionsRecorderForCollections recorder = AgentActionsRecorderForCollections.getInstance(current_action, description, action_target);
            recorder.record(CurrentLoan.Id);
            recorder.insertNewTasks();
            recorder.insertNewFeedItems();
        }
    }

    private void getRelatedCase(){
        if (RelatedCase == null){
            List<Case> list_case = [
                    SELECT Id, Process__c, Default_Notice_Sent_Date__c, CreatedDate, IsLockedFromUpdatesInProcess__c, AccountDCA__c, AccountDMC__c
                    FROM Case
                    WHERE Loan__c = :CurrentLoan.Id
                    AND IsClosed = false
                    AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
            ];
            if (list_case.size() != 0){
                RelatedCase = list_case[0];
            }
        }
    }

    private void getDCA(Id account_dca_id){
        if (RelatedDCA == null){
            List<Account> list_accounts = [SELECT id, Name, DCA_Id__c FROM Account WHERE id = :account_dca_id];
            if (list_accounts.size() != 0){
                RelatedDCA = list_accounts[0];
            }
        }
    }

    private void getDMC(Id account_dmc_id){
        if (RelatedDMC == null){
            List<Account> list_accounts = [SELECT Id, Name, DMC_Id__c FROM Account WHERE id = :account_dmc_id];
            if (list_accounts.size() != 0){
                RelatedDMC = list_accounts[0];
            }
        }
    }

    private Datetime getDefaultDateForCollectionAgency(){
        if(CurrentLoan.State__c == 'Default'){
            return RelatedCase.Default_Notice_Sent_Date__c;
        } else {
            return RelatedCase.CreatedDate;
        }
    }

    private void changeDcaOnLoanAndCase(Id dca_account_id){
        RelatedCase.AccountDCA__c = dca_account_id;
        updateCase();
        CurrentLoan.AccountDCA__c = dca_account_id;
        updateLoan();
    }

    private void changeDmcOnLoanAndCase(Id dmc_account_id){
        if(RelatedCase != null) {
            RelatedCase.AccountDMC__c = dmc_account_id;
            updateCase();
        }
        CurrentLoan.AccountDMC__c = dmc_account_id;
        updateLoan();
    }

    private void createCollectionsRecoveriesCase(){
        Case new_case = new Case();
        new_case.RecordTypeId = RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES);
        new_case.Loan__c = CurrentLoan.Id;
        new_case.Status = 'New';
        new_case.Process__c = 'Collections';
        new_case.Sub_Process__c = 'Early Arrears';
        new_case.Subject = 'Collections & Recoveries';
        new_case.AccountId = CurrentLoan.Account__c;
        insert new_case;
        getRelatedCase();
    }

    private void updateCase() {
        try {
            update RelatedCase;
        } catch (Exception e) {
            MessageUtility.addFatalPageMessage('System error. Can\'t update Case');
        }
    }

    private void updateLoan() {
        try {
            update CurrentLoan;
        } catch (Exception e) {
            MessageUtility.addFatalPageMessage('System error. Can\'t update Loan');
        }
    }

    public Boolean getIsLoanStateListenerEnabled() {
        return IsLoanStateListenerEnabled;
    }

    public void checkIfLoanStateChanged() {
        Loan__c retrieved_loan = [SELECT State__c FROM Loan__c WHERE Id = :CurrentLoan.Id];
        if(CurrentLoan.State__c != retrieved_loan.State__c) {
            IsPageReadyToRefresh = true;
        }
    }

    @TestVisible
    private Boolean isDcaForLoan(){
        return !String.isBlank(CurrentLoan.AccountDCA__c);
    }

    public Boolean getIsLoanDefault(){
        return String.isNotBlank(CurrentLoan.Default_Reason__c);
    }

    public List<System.SelectOption> getDefaultReasons() {
        return null;
    }
}