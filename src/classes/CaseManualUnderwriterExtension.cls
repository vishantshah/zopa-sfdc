public with sharing class CaseManualUnderwriterExtension {
    public static final List<String> ADDITIONAL_FIELDS_TO_QUERY = new List<string>{
            'Loan_Application__c','First_Time_Picked__c','IsClosed', 'Loan_Application__r.Broker__c', 'Loan_Application__r.Loan_ID__c', 'Subject',
            'CreatedDate', 'OwnerId', 'Initial_Underwriter__r.Email', 'Initial_Underwriter__r.FirstName', 'CaseNumber', 'Owner.Profile.Name'
    };
    @TestVisible public Case CurrentCase {get; private set;}
    public Map<Process, String> PopupMessagesMap {get; private set;}
    public Process CurrentProcess {get; set;}
    public Boolean NeedToCloseTab {get; set;}
    public String CancellationReason {get; set;}
    public String DeclineReason {get; set;}
    public final String CASE_STATUS_ADMIN_APPROVAL = 'Approved - Pending Admin Approval';
    public final String CASE_STATUS_PENDING_LOAN_CONSOLIDATION = 'Pending Loan Consolidation';

    public enum Process {
        DECLINE_LOAN,
        CANCEL_LOAN,
        MAKE_QUICK_PAY,
        MOVE_TO_FRAUD,
        MOVE_TO_CASE_PREP,
        MOVE_TO_UNDERWRITERS_FROM_CASE_PREP,
        MOVE_TO_UNDERWRITERS_FROM_TEAM_LEADER,
        PENDING,
        APPROVE_LOAN,
        PENDING_LOAN_CONSOLIDATION
    }

    public CaseManualUnderwriterExtension(ApexPages.StandardController controller){
        if (!Test.isRunningTest()) {
            controller.addFields(ADDITIONAL_FIELDS_TO_QUERY);
        }
        CurrentCase = (Case)controller.getRecord();
        PopupMessagesMap = new Map<Process, String>{
                Process.DECLINE_LOAN => 'This action will decline loan',
                Process.CANCEL_LOAN => 'This action will cancel loan',
                Process.MAKE_QUICK_PAY => 'This action will make a quick pay',
                Process.MOVE_TO_UNDERWRITERS_FROM_CASE_PREP => 'This case will be moved to Underwriters',
                Process.MOVE_TO_UNDERWRITERS_FROM_TEAM_LEADER => 'This case will be moved to Underwriters',
                Process.PENDING => 'This case will be moved to Case-Prep queue',
                Process.APPROVE_LOAN => 'This case will be moved to Team Leaders queue',
                Process.PENDING_LOAN_CONSOLIDATION => 'This case will be moved to the Pending Loan Consolidation queue as one of the loans for consolidation has a pending payment',
                Process.MOVE_TO_CASE_PREP => 'This case will be moved to Case-Preps',
                Process.MOVE_TO_FRAUD => 'This case will be moved to Fraud'};
        NeedToCloseTab = true;
    }

    private Boolean isCaseHasPendingTasks() {
        return isCaseHasTasksWithTheStatus('Pending');
    }

    private Boolean isCaseHasRejectedTasks() {
        return isCaseHasTasksWithTheStatus('Rejected');
    }

    private Boolean isCaseHasTasksWithTheStatus(String status) {
        if ([SELECT count() FROM Task WHERE WhatId =: CurrentCase.Id AND Status = :status] > 0) {
            return true;
        } else {
            MessageUtility.addWarningPageMessage('The case should have at least one task of status ' + status + ' to perform this action');
            return false;
        }
    }

    public void fixOmniChannelConflict() {
        Id owner_profile_id;
        List<User> owner = [SELECT ProfileId FROM User WHERE Id = :CurrentCase.OwnerId];
        if(!owner.isEmpty()){
            owner_profile_id = owner.get(0).ProfileId;
        }
        Boolean populate_initial_underwriter = OmniChannelHandler.populateInitialUnderwriter(CurrentCase, owner_profile_id);
        Boolean change_status_to_in_progress = OmniChannelHandler.changeStatusToInProgress(CurrentCase, owner_profile_id);
        if (populate_initial_underwriter || change_status_to_in_progress || !CurrentCase.First_Time_Picked__c) {
            updateCase();
        }
    }

    public Boolean getIsCaseNotClosed() {
        return !CaseUtility.isManualUnderwritingCaseClosed(CurrentCase);
    }

    public void showDeclineLoanPopup() {
        if(UserInfo.getUserId() != CurrentCase.OwnerId ){
            MessageUtility.addErrorPageMessage('Only the owner of the case can decline the loan');
        }
        else if(isCaseHasRejectedTasks()){
            CurrentProcess = Process.DECLINE_LOAN;
        }
    }

    public void showCancelLoanPopup() {
        CurrentProcess = Process.CANCEL_LOAN;
    }

    public void showMakeQuickPayPopup() {
        CurrentProcess = Process.MAKE_QUICK_PAY;
    }

    public void showPendingActionPopupForCasePrepElseUpdateStatus() {
        NeedToCloseTab = false;
        if (isCaseHasPendingTasks()) {
            if(checkPermissionByName('Profile_Token_Case_Prep')) {
                CurrentProcess = Process.PENDING;
            } else if (CurrentCase.Status != 'Pending') {
                AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.PENDING).record(CurrentCase);
                CurrentCase.Status = 'Pending';
                updateCase();
                MessageUtility.addConfirmPageMessage('The case was marked as Pending');
                NeedToCloseTab = true;
            }
        }
    }

    public void showApproveLoanPopup() {
        if (checkIsCaseHasNoOpenTasks()){
            if(getIsZopa81IsEnabled()){
                String uuid = CurrentCase.Loan_Application__r.Loan_ID__c;
                ApiCommandLoanConsolidationCandidates loan_consolidation_candidates_command = new ApiCommandLoanConsolidationCandidates(uuid);
                ApiCommandsFactory.getInstance().performApiCommandCallout(loan_consolidation_candidates_command);
                if (loan_consolidation_candidates_command.CommandSuccessful){
                    if(loan_consolidation_candidates_command.hasPaymentPending()){
                        CurrentProcess = Process.PENDING_LOAN_CONSOLIDATION;
                    } else {
                        CurrentProcess = Process.APPROVE_LOAN;
                    }
                    updateCaseUnderwriterApproveDate();
                } else {
                    MessageUtility.addErrorPageMessage('There has been an error checking if there are loans pending consolidation. Error: ' + loan_consolidation_candidates_command.CommandError);
                }
            } else {
                CurrentProcess = Process.APPROVE_LOAN;
                updateCaseUnderwriterApproveDate();
            }
        }
    }

    private void updateCaseUnderwriterApproveDate(){
        CurrentCase = [SELECT OwnerId, Status, First_Time_Picked__c, Loan_Application__r.Loan_ID__c, Initial_Underwriter__c, Initial_Underwriter__r.FirstName, CaseNumber, Underwriter_Approve_Date__c FROM Case WHERE Id = :CurrentCase.Id FOR UPDATE];
        CurrentCase.Underwriter_Approve_Date__c = Datetime.now();
        update CurrentCase;
    }

    public void showMoveToCasePrepPopup() {
        CurrentProcess = Process.MOVE_TO_CASE_PREP;
    }

    public void showMoveToFraudPopup() {
        CurrentProcess = Process.MOVE_TO_FRAUD;
    }

    public void showMoveToUnderwritersPopupFromCasePrep() {
        if (checkIsCaseHasNoOpenTasks()) {
            CurrentProcess = Process.MOVE_TO_UNDERWRITERS_FROM_CASE_PREP;
        }
    }

    public void showMoveToUnderwritersPopupFromTeamLeader() {
        CurrentProcess = Process.MOVE_TO_UNDERWRITERS_FROM_TEAM_LEADER;
    }

    public Boolean getIsCancelLoanProcess() {
        return CurrentProcess == Process.CANCEL_LOAN;
    }

    public Boolean getIsDeclineLoanProcess() {
        return CurrentProcess == Process.DECLINE_LOAN;
    }

    public List<SelectOption> getCancelLoanReasonOptions() {
        return ApiCommandCancelLoan.getCancelLoanReasonOptions();
    }

    public List<SelectOption> getDeclineLoanReasonOptions() {
        return ApiCommandDeclineLoan.getDeclineLoanReasonOptions();
    }

    private void setDefaultValueForNeedToCloseTab() {
        NeedToCloseTab = true;
    }

    private Boolean checkIsCaseHasNoOpenTasks() {
        if (!getIsZopa15IsEnabled()) {
            return true;
        }
        if (!checkPermissionByName('Case_Move_Case_With_Open_Tasks') && hasOpenTasks()) {
            MessageUtility.addWarningPageMessage('You cannot approve this loan application. The manual underwriting case still has open tasks. If you cannot see the open tasks please contact your team lead');
            return false;
        }
        return true;
    }

    public Boolean getisInitialUnderwriterReasonRequiredToDisplay(){
        return (CurrentCase.Status.Contains('Cancel') || CurrentCase.Status.Contains('Decline')) && !CurrentCase.Status.Contains('Auto');
    }

    public void confirmAction() {
        CurrentCase = [SELECT OwnerId, Status, Loan_Application__r.Loan_ID__c, Initial_Underwriter__c, Initial_Underwriter__r.FirstName, CaseNumber, Underwriter_Approve_Date__c FROM Case WHERE Id = :CurrentCase.Id FOR UPDATE];
        setDefaultValueForNeedToCloseTab();
        if (CurrentProcess == Process.MOVE_TO_UNDERWRITERS_FROM_CASE_PREP) {
            moveToUnderwriters();
        } else if (CurrentProcess == Process.MOVE_TO_UNDERWRITERS_FROM_TEAM_LEADER) {
            moveToUnderwriters();
        } else if (CurrentProcess == Process.APPROVE_LOAN) {
            moveToTeamLeaderQueue();
        } else if (CurrentProcess == Process.PENDING) {
            pendingActionForCasePrep();
        } else if (CurrentProcess == Process.MOVE_TO_CASE_PREP) {
            moveToCasePrep();
        } else if (CurrentProcess == Process.MOVE_TO_FRAUD) {
            moveToFraud();
        } else if (CurrentProcess == Process.PENDING_LOAN_CONSOLIDATION) {
            moveToPendingLoanConsolidation();
        } else if (CurrentProcess == Process.MAKE_QUICK_PAY) {
            NeedToCloseTab = false;
            makeQuickPay();
        } else if (CurrentProcess == Process.CANCEL_LOAN) {
            cancelLoanAction();
        } else if (CurrentProcess == Process.DECLINE_LOAN) {
            declineLoanAction();
        }
        hidePopup();
    }

    private void makeQuickPay() {
        String uuid = CurrentCase.Loan_Application__r.Loan_ID__c;
        if (isExternalIdOfLoanCorrect(uuid)) {
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(new ApiCommandMakeQuickPay(uuid));

            if(handleCommandResponseSuccess(response)) {
                AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.MAKE_QUICK_PAY).record(CurrentCase);
                MessageUtility.addConfirmPageMessage('The loan application was made quick pay successfully');
            }
        }
    }

    public void lockCase(){
        if(CurrentProcess == Process.CANCEL_LOAN || CurrentProcess == Process.DECLINE_LOAN){
            CurrentCase = [SELECT OwnerId, Status, First_Time_Picked__c, Loan_Application__r.Loan_ID__c, Initial_Underwriter__c, Initial_Underwriter__r.FirstName, CaseNumber, Underwriter_Approve_Date__c FROM Case WHERE Id = :CurrentCase.Id FOR UPDATE];
            CurrentCase.Is_Case_Currently_Locked__c = true;
            update CurrentCase;
        }
    }

    public void unlockCase(){
        CurrentCase.Is_Case_Currently_Locked__c = false;
        update CurrentCase;
    }

     private void cancelLoanAction() {
        String uuid = CurrentCase.Loan_Application__r.Loan_ID__c;
        if (isExternalIdOfLoanCorrect(uuid)) {
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(
                        new ApiCommandCancelLoan(uuid, CancellationReason));
            if (handleCommandResponseSuccess(response)) {
                AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.CANCEL_LOAN).record(CurrentCase);
                CurrentCase.Status = 'Closed - Cancelled';
                updateLoanApplicationCancelDeclineReason();
            }
        }
    }

    private void declineLoanAction() {
        String uuid = CurrentCase.Loan_Application__r.Loan_ID__c;
        if (isExternalIdOfLoanCorrect(uuid)) {
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(new ApiCommandDeclineLoan(uuid, DeclineReason));
            if (handleCommandResponseSuccess(response)) {
                AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.DECLINE_LOAN).record(CurrentCase);
                CurrentCase.Status = 'Closed - Declined';
                updateLoanApplicationCancelDeclineReason();
            }
        }
    }

    private Boolean isExternalIdOfLoanCorrect(String loan_external_id) {
        if (loan_external_id == null) {
            MessageUtility.addFatalPageMessage('Loan of this case doesn\'t have external Id. Callout can\'t be performed');
            NeedToCloseTab = false;
            return false;
        } else {
            return true;
        }
    }

    private Boolean handleCommandResponseSuccess(HttpResponse response) {
        try{
            if (response.getStatusCode() == 200 && response.getStatus() == 'OK') {
                NeedToCloseTab = true;
                return true;
            } else if (response.getStatusCode() == 403){
                MessageUtility.addFatalPageMessage('Access Denied. Please ask administrator to check credentials');
                NeedToCloseTab = false;
                return false;
            } else if(response.getStatusCode() == 500){
                String error_message = (String)((Map<String, Object>)JSON.deserializeUntyped(response.getBody())).get('message');
                MessageUtility.addFatalPageMessage('Internal Server Error: '+ error_message);
                NeedToCloseTab = false;
                return false;
            }else{
                String error_message = (String)((Map<String, Object>)JSON.deserializeUntyped(response.getBody())).get('message');
                MessageUtility.addFatalPageMessage('Bad request. ' + error_message);
                NeedToCloseTab = false;
                return false;
            }
        } catch (Exception e) {
            MessageUtility.addFatalPageMessage('Error on parsing response: ' + response.getBody());
            System.debug('Error on parsing response: ' + e.getMessage());
            NeedToCloseTab = false;
            return false;
        }
    }

    private void pendingActionForCasePrep() {
        Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_CASE_PREP);
        CaseBuilder.getBuilder(CurrentCase).setStatus('Pending').setOwner(queue_id).save();
        AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.PENDING).record(CurrentCase);
    }

    private void moveToUnderwriters() {
        if (CurrentCase.Initial_Underwriter__c != null) {
            CurrentCase.OwnerId = CurrentCase.Initial_Underwriter__c;
            sendEmailNotificationToUnderwriter();
            updateCase();
        } else {
            updateCaseWithAssignmentRule(CaseUtility.AssignmentRuleName.MOVE_TO_UNDERWRITER);
        }
        CaseBuilder.getBuilder(CurrentCase).setStatus('Open').save();
        AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.MOVE_TO_UNDERWRITERS).record(CurrentCase);
    }

    private void moveToCasePrep() {
        updateCaseWithAssignmentRule(CaseUtility.AssignmentRuleName.MOVE_TO_CASE_PREP);
        CaseBuilder.getBuilder(CurrentCase).setStatus('Open').save();
        AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.MOVE_TO_CASE_PREP).record(CurrentCase);
    }

    private void moveToFraud() {
        updateCaseWithAssignmentRule(CaseUtility.AssignmentRuleName.MOVE_TO_FRAUD);
        CaseBuilder.getBuilder(CurrentCase).setStatus('Open').save();
        AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.MOVE_TO_FRAUD).record(CurrentCase);
    }

    private void moveToTeamLeaderQueue() {
        Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.TEAM_LEADER);
        CaseBuilder.getBuilder(CurrentCase).setOwner(queue_id).setStatus(CASE_STATUS_ADMIN_APPROVAL).save();
        AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.TEAM_LEADER).record(CurrentCase);
    }

    private void moveToPendingLoanConsolidation(){
        Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_LOAN_CONSOLIDATION);
        CaseBuilder.getBuilder(CurrentCase).setOwner(queue_id).setStatus(CASE_STATUS_PENDING_LOAN_CONSOLIDATION).save();
        AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.PENDING_LOAN_CONSOLIDATION).record(CurrentCase);
    }

    public void hidePopup() {
        unlockCase();
        CurrentProcess = null;
    }

    public String getDocumentReminderTemplate() {
        return returnTemplateIdUrlParameter('DocReqRem');
    }

    public String getBlankEmailTemplate() {
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

    public void assignToMe() {
        CurrentCase.OwnerId = UserInfo.getUserId();
        updateCase();
        MessageUtility.addConfirmPageMessage('The case was assigned to you');
    }

    public Boolean getShowSmartActivitySection() {
        return FeatureSwitch.getSwitch('ZOPA-9').isFeatureEnabled();
    }

    public Boolean getIsZopa19IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-19').isFeatureEnabled();
    }

    private Boolean getIsZopa81IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-81').isFeatureEnabled();
    }

    public Boolean getIsZopa20IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-20').isFeatureEnabled();
    }

    public Boolean getIsZopa21IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-21').isFeatureEnabled();
    }

    public Boolean getIsZopa22IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-22').isFeatureEnabled();
    }

    public Boolean getIsZopa15IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-15').isFeatureEnabled();
    }

    public Boolean getIsZopa11IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-11').isFeatureEnabled();
    }

    public Boolean getIsZopa10IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-10').isFeatureEnabled();
    }

    public Boolean getIsZopa7IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-7').isFeatureEnabled();
    }

    public Boolean getIsZopa35IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-35').isFeatureEnabled();
    }

    public Boolean getIsZopa34IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-34').isFeatureEnabled();
    }

    public Boolean getIsZopa29IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-29').isFeatureEnabled();
    }

    public Boolean getIsSendTextButtonAvailable() {
        return !CurrentCase.IsClosed
                && checkPermissionByName('Send_Twilio_Text_button');
    }

    private Boolean checkPermissionByName(String name) {
        return CustomPermissions.getInstance().isCustomPermissionAvailable(name);
    }

    private void updateCase() {
        try {
            update CurrentCase;
        } catch (Exception e) {
            MessageUtility.addFatalPageMessage('System error. Can\'t update Case');
        }
    }

    private void updateLoanApplicationCancelDeclineReason(){
        Loan_Application__c loan_application_of_current_case = [SELECT Cancel_Decline_Reason__c FROM Loan_Application__c WHERE Id =:CurrentCase.Loan_Application__r.Id];
        if(CurrentProcess == Process.DECLINE_LOAN){
            loan_application_of_current_case.Cancel_Decline_Reason__c = ApiCommandDeclineLoan.getDeclineReasonsApiNamesToLabelMap().get(DeclineReason);
        }
        else {
            loan_application_of_current_case.Cancel_Decline_Reason__c = ApiCommandCancelLoan.getCancelReasonsApiNamesToLabelMap().get(CancellationReason);
        }
        updateLoanApplication(loan_application_of_current_case);
    }

    private void updateLoanApplication(Loan_Application__c loan_to_update){
        try{
            update loan_to_update;
        }
        catch(Exception e){
            MessageUtility.addFatalPageMessage('System error. Can\'t update Loan');
        }
    }

    private void updateCaseWithAssignmentRule(CaseUtility.AssignmentRuleName rule_name) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        try {
            dmo.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(rule_name);
        } catch (Exception e) {
            MessageUtility.addFatalPageMessage('No such specified Assignment Rule');
            return;
        }
        CurrentCase = [SELECT Id FROM Case WHERE Id =:CurrentCase.Id];
        CurrentCase.setOptions(dmo);
        updateCase();
    }

    private void sendEmailNotificationToUnderwriter() {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(CurrentCase.Initial_Underwriter__c);
        mail.setSubject('Case returned');
        String body = 'Hey ' + CurrentCase.Initial_Underwriter__r.FirstName + ', <br><br>';
        body += UserInfo.getFirstName() + ' moved case ' + CurrentCase.CaseNumber + ' back to you.<br><br>';
        body += 'Please review this case: <br>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + CurrentCase.Id;
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail}, false);
    }

    private Boolean hasOpenTasks() {
        String tasks_count_query = 'SELECT count() FROM Task WHERE What.Id = \'' + CurrentCase.Id + '\' AND Status = \'Open\'';
        tasks_count_query += getClauseForCurrentUser();
        return 0 != Database.countQuery(tasks_count_query);
    }

    private String getClauseForCurrentUser() {
        if (checkPermissionByName('Profile_Token_Underwriter')) {
            return 'AND (Task_For__c = \'Case-Prep\' OR Task_For__c = \'Underwriter\' OR Task_For__c = \'Fraud\' OR Task_For__c = null)';
        } else if (checkPermissionByName('Profile_Token_Case_Prep')) {
            return 'AND (Task_For__c = \'Case-Prep\' OR Task_For__c = null)';
        } else {
            return '';
        }
    }
}