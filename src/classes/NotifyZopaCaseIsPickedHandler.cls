public with sharing class NotifyZopaCaseIsPickedHandler {

    private static NotifyZopaCaseIsPickedHandler Instance;
    @TestVisible private Set<Id> CaseToBeMarkedAsFirstTimePicked;

    public static NotifyZopaCaseIsPickedHandler getInstance() {
        if(Instance == null){
            Instance = new NotifyZopaCaseIsPickedHandler();
        }
        return Instance;
    }

    private NotifyZopaCaseIsPickedHandler() {
        CaseToBeMarkedAsFirstTimePicked = new Set<Id>();
    }

    public void checkIfCaseIsPickedUpForTheFirstTime(Case new_case) {
        if (needToNotifyZopa(new_case)) {
            CaseToBeMarkedAsFirstTimePicked.add(new_case.Id);
        }
    }

    public void markCasesAsFirstTimePickedAndSendCallouts(){
        if(!CaseToBeMarkedAsFirstTimePicked.isEmpty()){
            List<Case> cases_to_update = [SELECT Id, First_Time_Picked__c FROM Case WHERE Id IN :CaseToBeMarkedAsFirstTimePicked];
            CaseToBeMarkedAsFirstTimePicked.clear();
            for(Case case_to_update : cases_to_update){
                case_to_update.First_Time_Picked__c = true;
            }
            update cases_to_update;
            for(Case updated_case : cases_to_update){
                notifyZopaCaseIsPicked(updated_case.Id);
            }
        }
    }

    private Boolean needToNotifyZopa(Case new_case){
        return isCaseUnderwriting(new_case) && isCaseOwnedByUser(new_case) && !new_case.First_Time_Picked__c && isEnoughFutureCalls() && new_case.Loan_Application__c != null && !System.isFuture() && !System.isBatch() && caseIsNotOwnedByCreator(new_case);
    }

    private Boolean caseIsNotOwnedByCreator(Case new_case){
        return new_case.CreatedById != new_case.OwnerId;
    }

    private Boolean isEnoughFutureCalls(){
        return Limits.getFutureCalls() + CaseToBeMarkedAsFirstTimePicked.size() < Limits.getLimitFutureCalls();
    }

    private Boolean isCaseOwnedByUser(Case new_case){
        String case_id = (String)new_case.OwnerId;
        return case_id.startsWith('005');
    }

    private Boolean isCaseUnderwriting(Case new_case) {
        return new_case.RecordTypeId == RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING);
    }

    @future(callout=true)
    private static void notifyZopaCaseIsPicked(Id case_id){
        if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new ApiTakeCaseOwnershipTestMock(ApiTakeCaseOwnershipTestMock.SetIsSuccess, ApiTakeCaseOwnershipTestMock.SetFailResponse));
        }
        Case case_to_process = [SELECT Id, Loan_Application__r.Loan_ID__c,First_Time_Picked__c FROM Case WHERE Id = :case_id];
        if(!String.isBlank(case_to_process.Loan_Application__r.Loan_ID__c)){
            ApiCommandTakeCaseOwnership notify_zopa_case_is_picked_command = new ApiCommandTakeCaseOwnership(case_to_process.Loan_Application__r.Loan_ID__c);
            ApiCommandsFactory.getInstance().performApiCommandCallout(notify_zopa_case_is_picked_command);
            if(notify_zopa_case_is_picked_command.CommandSuccessful){
                Boolean command_successful = notify_zopa_case_is_picked_command.getResponse();
                if(!command_successful){
                    sendMessagesForCase(case_to_process, 'Railto was unable to process the request');
                }
            } else {
                sendMessagesForCase(case_to_process, notify_zopa_case_is_picked_command.CommandError);
            }
        }
    }

    private static List<Messaging.SingleEmailMessage> sendMessagesForCase(Case case_to_cancel, String error_message) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Id admin_profile_id = ProfileUtilities.getInstance().getProfileIdForType(ProfileUtilities.ProfileType.SYSADMIN);
        for (User admin : [SELECT id, FirstName FROM User WHERE ProfileId = :admin_profile_id AND isActive = true]) {
            messages.add(getMessageForCaseAndAdmin(case_to_cancel, admin, error_message));
        }
        Messaging.sendEmail(messages, false);
        return messages;
    }

    private static Messaging.SingleEmailMessage getMessageForCaseAndAdmin(Case case_to_cancel, User admin, String error_message) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(admin.Id);
        mail.setSubject('Take Case Ownership Failed');
        String body = 'Hey ' + admin.FirstName + ', <br><br>';
        body += 'Take ownership of case has failed with the next error:<br>';
        body += error_message + '<br><br>';
        body += 'Railto is not aware this case has been picked up.<br>';
        body += 'Please review this case: <br>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + case_to_cancel.Id;
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(false);
        return mail;
    }
}