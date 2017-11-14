public with sharing class LoanStateCollectionsHelper {

    @InvocableMethod(label='Change the status to Collections in ZOPA' description='Generate a request to ZOPA for change the status.')
    public static void determinateAndUpdateLoansState(List<Id> cases) {
        Map<String, String> map_loan_uuid_for_update = getListLoanUuidForUpdateState(cases);
        for (String current_uuid: map_loan_uuid_for_update.keySet()){
            changeLoanStatusToRialtoToCollectionsAuto(current_uuid,map_loan_uuid_for_update.get(current_uuid));
        }
    }

    public static Boolean changeLoanStatusToRialtoToCollections(String uuid){
        if (ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(uuid)) {
            ApiCommandConfirmCollections command = new ApiCommandConfirmCollections(uuid);
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(command);
            if (command.CommandSuccessful) {
                MessageUtility.addInfoPageMessage('Loan State was updated successfully');
                return true;
            } else {
                MessageUtility.addFatalPageMessage(command.CommandError);
            }
        }
        return false;
    }

    @future(callout=true)
    public static void changeLoanStatusToRialtoToCollectionsAuto(String uuid, String loan_id){
        if (ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(uuid)) {
            ApiCommandConfirmCollections command = new ApiCommandConfirmCollections(uuid);
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(command);
            if (command.CommandSuccessful) {
                AgentActionsRecorderForCollections recorder = AgentActionsRecorderForCollections.getInstance(AgentActionsRecorderForCollections.Action.CONFIRM_COLLECTIONS);
                recorder.record(loan_id);
                recorder.insertNewTasks();
                recorder.insertNewFeedItems();
            }
        }
    }

    @TestVisible private static Map<String, String> getListLoanUuidForUpdateState(List<Id> cases){
        Map<String, String> map_loan_uuid_for_update_state = new Map<String, String> ();
        for (Loan__c current_loan :[SELECT Loan_id__c, State__c, Arrears_Ratio__c FROM Loan__c WHERE id IN (SELECT Loan__c FROM Case WHERE id IN :cases)]){
            if (current_loan.State__c == 'withdrawn' && current_loan.Arrears_Ratio__c > 0){
                map_loan_uuid_for_update_state.put(current_loan.Loan_id__c, current_loan.id);
            }
        }
        return map_loan_uuid_for_update_state;
    }
}