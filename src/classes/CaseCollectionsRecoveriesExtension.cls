public class CaseCollectionsRecoveriesExtension {
    public static final List<String> ADDITIONAL_FIELDS_TO_QUERY = new List<string>{
            'IsClosed', 'AccountId','Subject', 'Status','CreatedDate', 'OwnerId', 'CaseNumber', 'Owner.Profile.Name', 'Loan__c', 'Process__c',
            'Sub_Process__c','Is_Sensitive__c', 'Loan__r.Loan_Id__c', 'Default_Notice_Sent_Date__c', 'CreatedDate', 'AccountDCA__c', 'AccountDMC__c',
            'IsLockedFromUpdatesInProcess__c', 'Review_Counter__c', 'Task_Counter__c', 'Outbound_Calls_Counter__c', 'Contacts_Made_Counter__c'
    };
    public Case CurrentCase {get; set;}
    public Account RelatedDCA {get; set;}
    public Account RelatedDMC {get; set;}
    public Process CurrentProcess {get; set;}
    public String AccountDcaId {get; set;}
    public String AccountDmcId {get; set;}
    public enum Process {
        CONFIRM_DECEASED,
        SET_WITHDRAWN,
        SETTLE_CASE,
        CONFIRM_COLLECTIONS,
        CONFIRM_DEFAULT,
        ASSIGN_DCA,
        RECALL_FROM_DCA,
        ASSIGN_DMC,
        RECALL_FROM_DMC
    }
    public Loan__c RelatedLoan {get;set;}
    public Map<Process, String> POPUP_MESSAGES {
        get { return POPUP_MESSAGES_MAP; }
        set;
    }
    public String SelectedReason {get; set;}
    public Boolean IsInlineFormValid {get; private set;}
    public Boolean IsNotApiErrorsOccurred {get; private set;}
    private Datetime InitialNextReviewDate;
    private Datetime InitialStopCommunicationUntil;
    public ApiCommandGetLoanDetails.LoanDetails RelatedLoanDetails {get; set;}
    public Boolean LazyLoadFinished {get; private set;}
    static Map<Process, String> POPUP_MESSAGES_MAP = new Map<Process, String> {
            Process.CONFIRM_DECEASED => 'This action will update Loan status to Rialto',
            Process.SETTLE_CASE => 'This action will settle a case',
            Process.CONFIRM_COLLECTIONS => 'This action will update Loan status to Collections',
            Process.SET_WITHDRAWN => 'This action will set Loan to Withdrawn',
            Process.CONFIRM_DEFAULT => 'This action will set Loan to Default',
            Process.ASSIGN_DCA => 'This action will assign Loan to DCA',
            Process.RECALL_FROM_DCA => 'This action will unassign Loan and DCA',
            Process.ASSIGN_DMC => 'This action will assign Loan to DMC',
            Process.RECALL_FROM_DMC => 'This action will unassign Loan from DMC'
    };
    private Boolean IsLoanStateListenerEnabled = false;
    public Boolean IsPageReadyToRefresh {get; private set;}

    public CaseCollectionsRecoveriesExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(ADDITIONAL_FIELDS_TO_QUERY);
        }
        CurrentCase = (Case)controller.getRecord();
        InitialNextReviewDate = CurrentCase.Next_Review_Date__c;
        InitialStopCommunicationUntil = CurrentCase.Stop_Communication_Until__c;
        LazyLoadFinished = false;
        IsPageReadyToRefresh = false;
        getRelatedLoan();
    }

    public PageReference initActions() {
        getRelatedLoanDetails();
        return null;
    }

    public PageReference initActionsWithOmniFix() {
        initActions();
        return fixOmniChannelConflict();
    }

    public void getRelatedLoanDetails() {
        if(RelatedLoan != null && RelatedLoan.Loan_Id__c != null){
            ApiCommandGetLoanDetails get_loan_details_command = new ApiCommandGetLoanDetails(RelatedLoan.Loan_Id__c);
            ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);
            if(get_loan_details_command.CommandSuccessful){
                RelatedLoanDetails = get_loan_details_command.getResponse();
            } else {
                MessageUtility.addErrorPageMessage(get_loan_details_command.CommandError);
            }
        }else if(RelatedLoan == null) {
            MessageUtility.addErrorPageMessage('This Case is not related to Loan!');
        }else{
            MessageUtility.addErrorPageMessage('Related Loan has no UUID. Cannot perform api call.');
        }
        LazyLoadFinished = true;
    }

    public PageReference fixOmniChannelConflict() {
        Id owner_profile_id;
        List<User> owner = [SELECT ProfileId FROM User WHERE Id = :CurrentCase.OwnerId];
        if(!owner.isEmpty()){
            owner_profile_id = owner.get(0).ProfileId;
        }
        Boolean change_status_to_in_progress = OmniChannelHandler.changeStatusToInProgress(CurrentCase, owner_profile_id);
        if (change_status_to_in_progress) {
            updateCase();
        }
        return null;
    }

    public void assignToMe() {
        CurrentCase.OwnerId = UserInfo.getUserId();
        updateCase();
        MessageUtility.addConfirmPageMessage('The case was assigned to you');
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

    public void hidePopup() {
        CurrentProcess = null;
    }

    public PageReference openLogCall(){
        PageReference log_a_call_page = new PageReference('/apex/LogCallFirst?id=' + CurrentCase.Id).setRedirect(true);
        return log_a_call_page;
    }

    private void updateCase() {
        try {
            update CurrentCase;
        } catch (Exception e) {
            MessageUtility.addFatalPageMessage('System error. Can\'t update Case');
        }
    }

    private void updateLoan() {
        try {
            update RelatedLoan;
        } catch (Exception e) {
            MessageUtility.addFatalPageMessage('System error. Can\'t update Loan');
        }
    }

    public PageReference save() {
        IsNotApiErrorsOccurred = true;
        IsInlineFormValid = validateInlineForm();
        if(IsInlineFormValid) {
            if (isStopCommunicationUntilChanged()) {
                IsNotApiErrorsOccurred = performCalloutToUpdateStopCommunicationDate();
                if (IsNotApiErrorsOccurred) {
                    updateCase();
                } else {
                    MessageUtility.addErrorPageMessage('There are some problems with saving your process. Please try again or contact your Support team if this issue persist.');
                }
            } else {
                updateCase();
            }
        }
        return null;
    }

    @TestVisible
    private Boolean validateInlineForm(){
        Boolean result = true;
        if(isNextReviewDateChanged()) {
            result &= validateDate(CurrentCase.Next_Review_Date__c, 'Next Review Date');
        }
        if(isStopCommunicationUntilChanged()) {
            result &= validateDate(CurrentCase.Stop_Communication_Until__c, 'Stop Communication Until');
        }
        return result;
    }

    private Boolean validateDate(Datetime date_to_check, String date_name) {
        Boolean result = true;
        if (date_to_check < Datetime.now()) {
            result = false;
            MessageUtility.addWarningPageMessage(date_name + ' - Date can`t be in the past.');
        }
        return result;
    }

    private Boolean isNextReviewDateChanged(){
        return CurrentCase.Next_Review_Date__c != InitialNextReviewDate;
    }

    private Boolean isStopCommunicationUntilChanged(){
        return CurrentCase.Stop_Communication_Until__c != InitialStopCommunicationUntil;
    }

    @TestVisible
    private Boolean performCalloutToUpdateStopCommunicationDate(){
        ApiCommandPutStopCommunicationDate put_stop_communication_date_command = new ApiCommandPutStopCommunicationDate(RelatedLoan.Loan_Id__c, CurrentCase.Stop_Communication_Until__c);
        HttpResponse http_response = ApiCommandsFactory.getInstance().performApiCommandCallout(put_stop_communication_date_command);
        if(put_stop_communication_date_command.CommandSuccessful){
            return true;
        }else{
            MessageUtility.addErrorPageMessage('There are some problems with saving your process. Please try again or contact your Support team if this issue persist.');
            return false;
        }
    }

    public Boolean getIsDefaultAction(){
        return CurrentProcess == Process.CONFIRM_DEFAULT;
    }

    public Boolean getIsTheConfirmCollectionsButtonAvailable(){
        return getIsZcp107IsEnabled() && !getIsRecoveriesCaseProcess();
    }

    public Boolean getIsZcp76IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-76').isFeatureEnabled();
    }

    public Boolean getIsSensitiveCase() {
        return CurrentCase.Is_Sensitive__c;
    }

    public Boolean getIsCaseNotClosed(){
        return !CurrentCase.IsClosed;
    }

    public Boolean getIsLoanStateDefault() {
        return RelatedLoanDetails.State == 'Default';
    }

    public Boolean getIsZcp94IsEnabled(){
        return FeatureSwitch.getSwitch('ZCP-94').isFeatureEnabled();
    }

    public Boolean getIsAccessToLitigationUpdate(){
        return getIsZcp61IsEnabled() && getIsRecoveriesCaseProcess();
    }

    public Boolean getIsLitigationProcess(){
        return CurrentCase.Sub_Process__c == 'Pre-Litigation' || CurrentCase.Sub_Process__c == 'Litigation';
    }

    public Boolean getIsZcp105IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-105').isFeatureEnabled();
    }

    public Boolean getIsZcp106IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-106').isFeatureEnabled();
    }

    public Boolean getIsZcp107IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-107').isFeatureEnabled();
    }

    public Boolean getIsZcp61IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-61').isFeatureEnabled();
    }

    public Boolean getIsZcp24IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-24').isFeatureEnabled();
    }

    public Boolean getIsZcp123IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-123').isFeatureEnabled();
    }

    public Boolean getIsZcp169IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-169').isFeatureEnabled();
    }

    public Boolean getIsZcp189IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-189').isFeatureEnabled();
    }

    public Boolean getIsRecoveriesCaseProcess(){
        return CurrentCase.Process__c == CaseUtility.CASE_PROCESS_RECOVERIES;
    }

    public Boolean getShownManualSetWithdrawn(){
        getRelatedLoan();
        return getIsZcp106IsEnabled() && checkProcess(CaseUtility.CASE_PROCESS_COLLECTIONS);
    }

    public Boolean checkProcess(String process){
        return CurrentCase.Process__c != null && CurrentCase.Process__c == process;
    }    

    public Boolean getIsSendTextButtonAvailable() {
        return !CurrentCase.IsClosed
                && CustomPermissions.getInstance().isCustomPermissionAvailable('Send_Twilio_Text_button');
    }

    public Boolean getIsAssignToDcaButtonAvailable(){
        return getIsZcp123IsEnabled() && !isDcaForCase();
    }

    public Boolean getIsPicklistDcaAccountsVisible(){
        return getIsAssignToDcaButtonAvailable() && CurrentProcess == Process.ASSIGN_DCA;
    }

    public Boolean getIsPicklistDmcAccountsVisible(){
        return getIsAssignToDmcButtonAvailable() && CurrentProcess == Process.ASSIGN_DMC;
    }

    public Boolean getIsAssignToDmcButtonAvailable(){
        return Case.AccountDMC__c.getDescribe().isUpdateable()
                && Loan__c.AccountDMC__c.getDescribe().isUpdateable()
                && String.isBlank(RelatedLoan.AccountDMC__c);
    }

    public Boolean getIsRecallFromDmcButtonAvailable(){
        return Case.AccountDMC__c.getDescribe().isUpdateable()
                && Loan__c.AccountDMC__c.getDescribe().isUpdateable()
                && String.isNotBlank(RelatedLoan.AccountDMC__c);
    }

    public Boolean getIsUnassignToDcaButtonAvailable(){
        return getIsZcp123IsEnabled() && isDcaForCase();
    }

    public Boolean getIsMakeDefaultButtonAvailable(){
        return CustomPermissions.getInstance().isCustomPermissionAvailable('Make_Default_on_Collections_Case')
                && getIsZcp76IsEnabled()
                && RelatedLoanDetails != null
                && !getIsLoanStateDefault();
    }

    public Boolean getIsSettleCaseButtonAvailable(){
        return CustomPermissions.getInstance().isCustomPermissionAvailable('Case_Settlement_Close')
                && getIsCaseNotClosed()
                && getIsZcp94IsEnabled()
                && RelatedLoanDetails != null
                && getIsLoanStateDefault();
    }

    private void getRelatedLoan(){
        if (RelatedLoan == null) {
            if(String.isBlank(CurrentCase.Loan__c)) {
                MessageUtility.addErrorPageMessage('This Case is not related to Loan!');
            } else {
                List<Loan__c> list_loan = [
                        SELECT id, Loan_id__c, State__c, ArrearsStartDate__c, Default_Reason__c, Name, AccountDCA__c, AccountDMC__c
                        FROM Loan__c
                        WHERE id = :CurrentCase.Loan__c
                ];
                if (list_loan.size() != 0) {
                    RelatedLoan = list_loan[0];
                }
            }
        }
    }

    public void showMakeDefaultPopup() {
        CurrentProcess = Process.CONFIRM_DEFAULT;
    }

    public void showSettleCasePopup() {
        CurrentProcess = Process.SETTLE_CASE;
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
            MessageUtility.addErrorPageMessage('You can not assign Loan to DCA when current Loan Status equals: Arrangement, Closed, Deceased or Settled. Current Loan Status: ' + RelatedLoan.State__c + '.');
        }
    }

    private Boolean isRelatedLoanStateProperToAssignLoanToDca() {
        return RelatedLoan.State__c != 'Arrangement' && RelatedLoan.State__c != 'Closed' && RelatedLoan.State__c != 'Deceased' && RelatedLoan.State__c != 'Settled';
    }

    public void showAssignDmcPopup() {
        CurrentProcess = Process.ASSIGN_DMC;
    }

    public void showRecallDmcPopup() {
        CurrentProcess = Process.RECALL_FROM_DMC;
    }

    public void confirmAction() {
        getRelatedLoan();
        AgentActionsRecorderForCollections.Action current_action;
        String description = '';
        String action_target = '';
        CurrentCase = [
                SELECT IsClosed, AccountId, Default_Notice_Sent_Date__c, Subject, Status, CreatedDate, OwnerId, CaseNumber, Owner.Profile.Name,
                        Loan__c, Loan__r.Loan_Id__c, Process__c, Sub_Process__c, Is_Sensitive__c, RecordTypeId, AccountDCA__c, AccountDMC__c,
                        Review_Counter__c, Task_Counter__c, Outbound_Calls_Counter__c, Contacts_Made_Counter__c
                FROM Case
                WHERE Id = :CurrentCase.Id FOR UPDATE
        ];
        if (CurrentProcess == Process.SETTLE_CASE) {
            settleCaseAction();
            createTaskAndChatterPost(current_action, description, action_target);
        } else if (CurrentProcess == Process.CONFIRM_DECEASED){
            if (LoanStateDeceasedHelper.changeLoanStatusToRialtoToDeceased(RelatedLoan.Loan_Id__c)){
                current_action = AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED;
                createTaskAndChatterPost(current_action, description, action_target);
            }
        } else if (CurrentProcess == Process.CONFIRM_COLLECTIONS){
            if (LoanStateCollectionsHelper.changeLoanStatusToRialtoToCollections(RelatedLoan.Loan_Id__c)){
                current_action = AgentActionsRecorderForCollections.Action.CONFIRM_COLLECTIONS;
                createTaskAndChatterPost(current_action, description, action_target);
            }
        } else if(CurrentProcess == Process.SET_WITHDRAWN){
            if (LoanSetToWithdrawnHandler.setLoanToWithdrawnFromPageAction(RelatedLoan)){
                current_action = AgentActionsRecorderForCollections.Action.SET_WITHDRAWN;
                createTaskAndChatterPost(current_action, description, action_target);
            }
        } else if(CurrentProcess == Process.CONFIRM_DEFAULT){
            if (LoanStateDefaultHelper.changeLoanStatusToRialtoToDefault(RelatedLoan.Loan_Id__c, RelatedLoan.Default_Reason__c)){
                update RelatedLoan;
                IsLoanStateListenerEnabled = true;
            }
        } else if(CurrentProcess == Process.ASSIGN_DCA){
            getDCA(AccountDcaId);
            if(ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(RelatedLoan.Loan_Id__c)) {
                ApiCommandPostCollectionAgency command = CollectionAgencyCommandHelper.sendPostCollectionsAgencyToZopaAndReturnCommand(RelatedLoan.Loan_Id__c, RelatedDCA.DCA_Id__c, getDefaultDateForCollectionAgency());
                if (command.CommandSuccessful) {
                    MessageUtility.addConfirmPageMessage('Loan assigned to DCA successfully. Response: ' + command.getResponseBody());
                    current_action = AgentActionsRecorderForCollections.Action.ASSIGN_DCA;
                    action_target = '(' + RelatedDCA.Name + ')';
                    changeCaseAfterAssignToDCA();
                    createTaskAndChatterPost(current_action, description, action_target);
                } else {
                    MessageUtility.addErrorPageMessage(command.CommandError);
                }
            }
        } else if(CurrentProcess == Process.RECALL_FROM_DCA){
            getDCA(CurrentCase.AccountDCA__c);
            changeDcaOnLoanAndCase(null);
            MessageUtility.addConfirmPageMessage('DCA was unassigned with Loan successfully');
            current_action = AgentActionsRecorderForCollections.Action.RECALL_FROM_DCA;
            action_target = '(' + RelatedDCA.Name + ')';
            createTaskAndChatterPost(current_action, description, action_target);
        } else if(CurrentProcess == Process.ASSIGN_DMC){
            getDMC(AccountDmcId);
            MessageUtility.addConfirmPageMessage('Loan assigned to DMC successfully.');
            current_action = AgentActionsRecorderForCollections.Action.ASSIGN_DMC;
            action_target = '(' + RelatedDMC.Name + ')';
            changeCaseAndLoanAfterAssignToDMC();
            createTaskAndChatterPost(current_action, description, action_target);
        } else if(CurrentProcess == Process.RECALL_FROM_DMC){
            getDMC(RelatedLoan.AccountDMC__c);
            changeCaseAndLoanAfterRecallFromDMC();
            MessageUtility.addConfirmPageMessage('Loan has been successfully unassigned from DMC.');
            current_action = AgentActionsRecorderForCollections.Action.RECALL_FROM_DMC;
            action_target = '(' + RelatedDMC.Name + ')';
            createTaskAndChatterPost(current_action, description, action_target);
        }
        hidePopup();
    }

    private void changeCaseAfterAssignToDCA(){
        CurrentCase.Sub_Process__c = 'DCA';
        CurrentCase.OwnerId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD);
        CurrentCase.IsLockedFromUpdatesInProcess__c = true;
        changeDcaOnLoanAndCase(RelatedDCA.Id);
    }

    private void changeCaseAndLoanAfterAssignToDMC(){
        CurrentCase.Sub_Process__c = 'With DMC';
        CurrentCase.OwnerId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD);
        CurrentCase.IsLockedFromUpdatesInProcess__c = true;
        changeDmcOnLoanAndCase(RelatedDMC.Id);
    }

    private void changeCaseAndLoanAfterRecallFromDMC(){
        CurrentCase.IsLockedFromUpdatesInProcess__c = false;
        changeDmcOnLoanAndCase(null);
    }

    private void createTaskAndChatterPost(AgentActionsRecorderForCollections.Action current_action, String description, String action_target){
        if (current_action != null){
            AgentActionsRecorderForCollections recorder = AgentActionsRecorderForCollections.getInstance(current_action, description, action_target);
            recorder.record(CurrentCase);
            recorder.insertNewTasks();
            recorder.insertNewFeedItems();
        }
    }

    private void changeDcaOnLoanAndCase(Id dca_account_id){
        CurrentCase.AccountDCA__c = dca_account_id;
        updateCase();
        RelatedLoan.AccountDCA__c = dca_account_id;
        updateLoan();
    }

    private void changeDmcOnLoanAndCase(Id dmc_account_id){
        CurrentCase.AccountDMC__c = dmc_account_id;
        updateCase();
        RelatedLoan.AccountDMC__c = dmc_account_id;
        updateLoan();
    }

    private void settleCaseAction(){
        String uuid = CurrentCase.Loan__r.Loan_Id__c;
        if (ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(uuid)) {
            ApiCommandSettlementCase command = new ApiCommandSettlementCase(uuid);
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(command);
            if (command.CommandSuccessful) {
                CurrentCase.Status = 'Closed - Settled';
                updateCase();
            } else {
                MessageUtility.addFatalPageMessage(command.CommandError);
            }
        }
    }

    private Datetime getDefaultDateForCollectionAgency(){
        if(RelatedLoan.State__c == 'Default'){
            return CurrentCase.Default_Notice_Sent_Date__c;
        } else {
            return CurrentCase.CreatedDate;
        }
    }

    public Boolean getIsLoanStateListenerEnabled() {
        return IsLoanStateListenerEnabled;
    }

    public void checkIfLoanStateChanged() {
        Loan__c retrieved_loan = [SELECT State__c FROM Loan__c WHERE Id = :RelatedLoan.Id];
        if(RelatedLoan.State__c != retrieved_loan.State__c) {
            IsPageReadyToRefresh = true;
        }
    }

    private void getDCA(Id account_dca_id){
        if (RelatedDCA == null){
            List<Account> list_accounts = [SELECT Id, Name, DCA_Id__c FROM Account WHERE id = :account_dca_id];
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

    @TestVisible
    public Boolean getIsLoanDefault(){
        return RelatedLoan != null && String.isNotBlank(RelatedLoan.Default_Reason__c);
    }

    @TestVisible
    private Boolean isDcaForCase(){
        return !String.isBlank(CurrentCase.AccountDCA__c);
    }

    public String getBlankEmailTemplate(){
        return returnTemplateIdUrlParameter('Blank_Template');
    }

    private String returnTemplateIdUrlParameter(String template_name){
        List<EmailTemplate> template = [SELECT id FROM EmailTemplate WHERE DeveloperName = :template_name];
        if(template.size() != 0) {
            return '&template_id='+template.get(0).Id;
        } else {
            return '';
        }
    }

    public List<System.SelectOption> getDefaultReasons() {
        return null;
    }
}