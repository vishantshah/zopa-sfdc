public with sharing class BulkCaseProcessingController {
    private static final String QUERY_PATTERN = 'SELECT {0} Id, QuickPay__c, CaseNumber, Loan_Application__r.Loan_ID__c, Initial_Underwriter__r.Id, Initial_Underwriter__r.Name, Loan_Application__r.Customer_Account__r.Name FROM Case WHERE isClosed = false AND OwnerId = {1} ORDER BY CreatedDate DESC LIMIT 1000';

    private enum Agent {CASE_PREP,
                       UNDERWRITER,
                       FRAUD}
    @TestVisible private enum Process {BULK_APPROVE_LOAN,
                                       BULK_MOVE_TO_FRAUD,
                                       BULK_MOVE_TO_CASE_PREP,
                                       BULK_MOVE_TO_UNDERWRITERS,
                                       APPROVE_LOAN_AND_WAIVE_QUICK_PAY}
    public Map<Process, String> PopupMessagesMap {get; private set;}
    public Process CurrentProcess {get; set;}
    public List<CaseWrapper> WrappedCases {get; set;}
    public Boolean SelectAll {get; set;}
    @TestVisible private List<Case> SelectedCases;

    public BulkCaseProcessingController() {
        SelectAll = false;
        WrappedCases = new List<CaseWrapper>();
        SelectedCases = new List<Case>();
        queryCases();
        PopupMessagesMap = new Map<Process, String>{Process.BULK_APPROVE_LOAN => 'This action will approve all selected loans',
                                                    Process.BULK_MOVE_TO_FRAUD => 'This action will move selected cases to fraud agents',
                                                    Process.BULK_MOVE_TO_CASE_PREP => 'This action will move selected cases to case-prep agents',
                                                    Process.BULK_MOVE_TO_UNDERWRITERS => 'This action will move selected cases to underwriters',
                                                    Process.APPROVE_LOAN_AND_WAIVE_QUICK_PAY => 'This action will approve loan and make free quick pay'};
    }

    public void selectDeselectAllAction() {
        for (CaseWrapper wrapper : WrappedCases) {
            wrapper.Selected = SelectAll;
        }
    }

    public void showApproveLoanAndWaiveQuickPayPopup() {
        if(selectedAtLeastOneCase() && handleMoreThanOneCaseSelected() && handleCaseIsNotMarkedAsQuickPay()) {
            CurrentProcess = Process.APPROVE_LOAN_AND_WAIVE_QUICK_PAY;
        }
    }

    public void showBulkApprovePopup() {
        if(selectedAtLeastOneCase()) {
            CurrentProcess = Process.BULK_APPROVE_LOAN;
        }
    }

    public void showBulkMoveToFraudPopup() {
        if(selectedAtLeastOneCase()) {
            CurrentProcess = Process.BULK_MOVE_TO_FRAUD;
        }
    }

    public void showBulkMoveToCasePrepPopup() {
        if(selectedAtLeastOneCase()) {
            CurrentProcess = Process.BULK_MOVE_TO_CASE_PREP;
        }
    }

    public void showBulkMoveToUnderwriterPopup() {
        if(selectedAtLeastOneCase()) {
            CurrentProcess = Process.BULK_MOVE_TO_UNDERWRITERS;
        }
    }

    public void confirmAction() {
        if (CurrentProcess == Process.BULK_APPROVE_LOAN) {
            performBulkApproveAction();
        } else if (CurrentProcess == Process.BULK_MOVE_TO_FRAUD) {
            performBulkMoveToAction(Agent.FRAUD);
        } else if (CurrentProcess == Process.BULK_MOVE_TO_CASE_PREP) {
            performBulkMoveToAction(Agent.CASE_PREP);
        } else if (CurrentProcess == Process.BULK_MOVE_TO_UNDERWRITERS) {
            performBulkMoveToAction(Agent.UNDERWRITER);
        } else if (CurrentProcess == Process.APPROVE_LOAN_AND_WAIVE_QUICK_PAY) {
            approveLoanAndWaiveQuickPay();
        }
        hidePopup();
        queryCases();
    }

    public List<Schema.FieldSetMember> getFieldSet() {
        List<Schema.FieldSetMember> fields = Schema.SObjectType.Case.FieldSets.Team_Leader_List_View.getFields();
        for (Integer i = 0; i < fields.size(); i++) {
            if (fields[i].getFieldPath() == 'CaseNumber') {
                fields.remove(i);
                return fields;
            }
        }
        return fields;
    }

    private void approveLoanAndWaiveQuickPay() {
        Case case_to_approve = [SELECT Id, QuickPay__c, CaseNumber, Loan_Application__r.Loan_ID__c, Initial_Underwriter__r.Name, Loan_Application__r.Customer_Account__r.Name FROM Case WHERE Id = :SelectedCases[0].Id FOR UPDATE];
        try {
            ApiCommandapproveLoanAndWaveQuickPay approve_command = new ApiCommandapproveLoanAndWaveQuickPay(case_to_approve.Loan_Application__r.Loan_ID__c);
            ApiCommandsFactory.getInstance().performApiCommandCallout(approve_command);
            if (approve_command.CommandSuccessful) {
                case_to_approve.Status = 'Closed - Approved';
                update case_to_approve;
                AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.APPROVE_LOAN_AND_WAIVE_QUICK_PAY).record(case_to_approve);
                MessageUtility.addConfirmPageMessage('Case was approved successfully');
            } else {
                MessageUtility.addErrorPageMessage(approve_command.CommandError);
            }
        } catch(DMLException e) {
            MessageUtility.addErrorPageMessage('Error has occured on uploading file on server');
        }
    }

    private void queryCases() {
        SelectedCases.clear();
        WrappedCases.clear();
        String query_string = String.format(QUERY_PATTERN, new LIST<String> {getStringFieldsForQuery(), getTeamLeaderQueueId()});
        for (Case case_record : Database.query(query_string)) {
            WrappedCases.add(new CaseWrapper(case_record));
        }
    }

    private String getStringFieldsForQuery() {
        String string_fields = '';
        for(Schema.FieldSetMember field : getFieldSet()) {
            string_fields += field.getFieldPath() + ', ';
        }
        return string_fields;
    }

    private String getTeamLeaderQueueId() {
        return '\'' + CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.TEAM_LEADER) + '\'';
    }

    private List<Case> getAllSelectedCases() {
        List<Case> cases = new List<Case>();
        for (CaseWrapper case_wrap : WrappedCases) {
            if (case_wrap.Selected) {
                cases.add(case_wrap.CaseRecord);
            }
        }
        return cases;
    }

    private Boolean handleCaseIsNotMarkedAsQuickPay() {
        if (!SelectedCases[0].QuickPay__c) {
            MessageUtility.addWarningPageMessage('To Waive Case it should be Quickpay');
        }
        return SelectedCases[0].QuickPay__c;
    }

    private Boolean handleMoreThanOneCaseSelected() {
        if (SelectedCases.size() > 1) {
            MessageUtility.addWarningPageMessage('You can perform this action only for single case');
        }
        return SelectedCases.size() == 1;
    }

    private Boolean selectedAtLeastOneCase() {
        SelectedCases = getAllSelectedCases();
        if (SelectedCases.isEmpty()) {
            MessageUtility.addWarningPageMessage('Please, select at least one case');
        }
        return !SelectedCases.isEmpty();
    }

    private void performBulkMoveToAction(Agent move_to) {
        try {
            bulkMoveToAction(move_to);
            MessageUtility.addConfirmPageMessage('Updated succesfully!');
            recordMoveToAction(move_to);
        } catch(Exception e) {
            MessageUtility.addErrorPageMessage('Something goes wrong: ' + e.getMessage());
        }
    }

    private void recordMoveToAction(Agent move_to) {
        if (move_to == Agent.CASE_PREP) {
            AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.MOVE_TO_CASE_PREP).record(SelectedCases);
        } else if (move_to == Agent.UNDERWRITER) {
            AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.MOVE_TO_UNDERWRITERS).record(SelectedCases);
        } else if (move_to == Agent.FRAUD) {
            AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.MOVE_TO_FRAUD).record(SelectedCases);
        }
    }

    private void bulkMoveToAction(Agent move_to){
        Id assignment_rule_id = getAssignmentRuleIdForToken(move_to);
        if(move_to == Agent.UNDERWRITER){
            bulkMoveToUnderwriters(assignment_rule_id);
            update SelectedCases;
        }
        else{
            updateChildCasesWithAssignmentRule(assignment_rule_id);
        }
    }

    private void bulkMoveToUnderwriters(Id assignment_rule_id){
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.assignmentRuleId = assignment_rule_id;

        for(Case selected_case : SelectedCases){
             if(selected_case.Initial_Underwriter__c != null){
                selected_case.OwnerId = selected_case.Initial_Underwriter__r.Id;
                selected_case.Status = 'In Progress';
             }
             else{
                selected_case.setOptions(dmo);
                selected_case.Status = 'Open';
             }
        }
    }

    private Id getAssignmentRuleIdForToken(Agent move_to) {
        if (move_to == Agent.CASE_PREP) {
            return CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_CASE_PREP);
        } else if (move_to == Agent.UNDERWRITER) {
            return CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_UNDERWRITER);
        } else if (move_to == Agent.FRAUD) {
            return CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_FRAUD);
        } else {
            return null;
        }
    }

    private void updateChildCasesWithAssignmentRule(Id assignment_rule_id) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.assignmentRuleId = assignment_rule_id;
        for (Case selected_case : SelectedCases) {
            selected_case.Status = 'Open';
            selected_case.setOptions(dmo);
        }
        update SelectedCases;
    }

    public void lockCases(){
        Set<Id> case_ids = new Set<Id>();
        for(Case selected_case : SelectedCases){
            case_ids.add(selected_case.Id);
        }
        SelectedCases = [SELECT Id, QuickPay__c, CaseNumber, Loan_Application__r.Loan_ID__c, Initial_Underwriter__r.Name, Loan_Application__r.Customer_Account__r.Name FROM Case WHERE Id IN :case_ids FOR UPDATE];
        for(Case selected_case :SelectedCases){
            selected_case.Is_Case_Currently_Locked__c = true;
        }
        update SelectedCases;
    }

    public void unlockCases(){
        for(Case selected_case :SelectedCases){
            selected_case.Is_Case_Currently_Locked__c = false;
        }
        update SelectedCases;
    }


    private void performBulkApproveAction() {
        Set<Id> case_ids = new Set<Id>();
        for(Case selected_case : SelectedCases){
            case_ids.add(selected_case.Id);
        }
        SelectedCases = [SELECT Id, QuickPay__c, CaseNumber, Loan_Application__r.Loan_ID__c, Initial_Underwriter__r.Name, Loan_Application__r.Customer_Account__r.Name FROM Case WHERE Id IN :case_ids FOR UPDATE];

        Set<String> uuid_set = getLoansUuidsForSelectedCases();
        try {
            ApiCommandBulkApproveLoan approve_command = new ApiCommandBulkApproveLoan(new Set<String>(uuid_set));
            ApiCommandsFactory.getInstance().performApiCommandCallout(approve_command);
            if (approve_command.CommandSuccessful) {
                handleBulkApproveResponse(approve_command);
            } else {
                MessageUtility.addErrorPageMessage(approve_command.CommandError);
            }
        } catch(DMLException e) {
            MessageUtility.addErrorPageMessage('Error has occured on sending request on server');
        }
    }

    private void handleBulkApproveResponse(ApiCommandBulkApproveLoan approve_command){
        ApiCommandBulkApproveLoan.BulkApproveResponse response = approve_command.getResponse();
        if (response != null){
            removeCaseFromFailedLoans(new Set<String>(response.Errored));
            if(SelectedCases.size() > 0){
                updateChildCasesWithStatusClosedApproved();
                MessageUtility.addConfirmPageMessage('Some loan applications were approved succesfully!');
            }
        }
        if(SelectedCases.size() > 0 && response == null){
            updateChildCasesWithStatusClosedApproved();
            MessageUtility.addConfirmPageMessage('Loan applications approved succesfully!');
            AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.BULK_APPROVE).record(SelectedCases);
        }
    }

    private HttpResponse performCallout(ApiCommandsFactory.ApiCommandAbstractBuilder command) {
        return ApiCommandsFactory.getInstance().performApiCommandCallout(command);
    }

    private void removeCaseFromFailedLoans(Set<String> errored){
        Integer i = 0;
        while (i < SelectedCases.size()) {
            if(errored.contains(SelectedCases[i].Loan_Application__r.Loan_ID__c)){
                MessageUtility.addErrorPageMessage('Failed to approve ' + SelectedCases[i].Loan_Application__r.Loan_ID__c);
                SelectedCases.remove(i);
            }else{
                ++i;
            }
        }
    }

    private void updateChildCasesWithStatusClosedApproved() {
        for (Case case_to_update : SelectedCases) {
            case_to_update.Status = 'Closed - Approved';
        }
        update SelectedCases;
    }

    private Set<String> getLoansUuidsForSelectedCases() {
        Set<String> uuid_set = new Set<String>();
        for (Case child_case : SelectedCases) {
            if (child_case.Loan_Application__r.Loan_ID__c != null) {
                uuid_set.add(child_case.Loan_Application__r.Loan_ID__c);
            }
        }
        return uuid_set;
    }

    public void hidePopup() {
        unlockCases();
        CurrentProcess = null;
    }

    public Boolean getIsZopa37IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-37').isFeatureEnabled();
    }

    public Boolean getIsZopa36IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-36').isFeatureEnabled();
    }

    public class CaseWrapper {
        public Boolean Selected {get; set;}
        public Case CaseRecord {get; set;}
        public CaseWrapper(Case case_record) {
            Selected = false;
            CaseRecord = case_record;
        }
    }
}