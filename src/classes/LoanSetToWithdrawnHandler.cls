public class LoanSetToWithdrawnHandler {

    @InvocableMethod(label='Set Loan to Withdrawn' description='Send ApiCallout to Set Loan to Withdrawn.')
    public static void setLoanTowithdrawnFromFlow(List<Id> loans_ids) {
        if (getIsZcp106IsEnabled()) {
            setLoansToWithdrawnFuture(loans_ids);
        }
    }

    @TestVisible
    private static Boolean getIsZcp106IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-106').isFeatureEnabled();
    }

    @future(callout = true)
    private static void setLoansToWithdrawnFuture(List<Id> loans_ids) {
        List<Loan__c> loans = [SELECT Id, Loan_Id__c FROM Loan__c WHERE Id IN :loans_ids];
        setLoansToWithdrawn(loans);
    }

    private static void setLoansToWithdrawn(List<Loan__c> loans) {
        Set<Id> successful_request_loan_ids = new Set<Id>();
        for (Loan__c loan : loans) {
            if (setLoanToWithdrawn(loan.Loan_Id__c)) {
                successful_request_loan_ids.add(loan.id);
            }
        }
        updateRelatedCasesWithWithdrawnStatus(successful_request_loan_ids);
        createTasksAndChatterPosts(successful_request_loan_ids);
    }

    private static Boolean setLoanToWithdrawn(String uuid) {
        if (ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(uuid)) {
            ApiCommandSetToWithdrawn command = setLoanToWithdrawnCommand(uuid);
            return command.CommandSuccessful;
        }
        return false;
    }

    public static Boolean setLoanToWithdrawnFromPageAction(Loan__c loan) {
        if(ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(loan.Loan_Id__c)) {
            ApiCommandSetToWithdrawn command = setLoanToWithdrawnCommand(loan.Loan_Id__c);
            if(command.CommandSuccessful) {
                MessageUtility.addConfirmPageMessage('Loan State has been successfully set to "Withdrawn"!');
                updateRelatedCaseWithWithdrawnStatus(loan.Id);
            } else {
                MessageUtility.addErrorPageMessage(command.CommandError);
            }
            return command.CommandSuccessful;
        }
        return false;
    }

    private static ApiCommandSetToWithdrawn setLoanToWithdrawnCommand(String uuid) {
        ApiCommandSetToWithdrawn command = new ApiCommandSetToWithdrawn(uuid);
        ApiCommandsFactory.getInstance().performApiCommandCallout(command);
        return command;
    }

    private static void updateRelatedCasesWithWithdrawnStatus(Set<Id> loan_ids) {
        List<Case> cases = [
                SELECT Id, Status
                FROM Case
                WHERE IsClosed = false
                AND Loan__c IN :loan_ids
                AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
        ];
        for (Case case_item : cases) {
            case_item.Status = 'Withdrawn';
        }
        update cases;
    }

    private static void updateRelatedCaseWithWithdrawnStatus(Id loan_id) {
        List<Case> cases = [
                SELECT Id, Status
                FROM Case
                WHERE IsClosed = false
                AND Loan__c = :loan_id
                AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
        ];
        if(!cases.isEmpty()) {
            Case case_to_update = cases[0];
            case_to_update.Status = 'Withdrawn';
            update case_to_update;
        }
    }

    private static void createTasksAndChatterPosts(Set<Id> loan_ids) {
        AgentActionsRecorderForCollections recorder = AgentActionsRecorderForCollections.getInstance(
                AgentActionsRecorderForCollections.Action.SET_WITHDRAWN, '', '(Process Builder)'
        );
        recorder.record(loan_ids);
        recorder.insertNewTasks();
        recorder.insertNewFeedItems();
    }
}