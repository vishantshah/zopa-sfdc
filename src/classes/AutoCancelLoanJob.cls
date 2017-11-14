public class AutoCancelLoanJob {

    public static void checkLoanForAutoCancelCriteria(Case old_case, Case new_case) {
        if(!old_case.Auto_Canceled_Loan__c && new_case.Auto_Canceled_Loan__c && isManualUnderwritingCase(new_case) && !new_case.IsClosed && !System.isFuture() && !System.isBatch()) {
            performCancelCalloutAndUpdateCase(new_case.Id);
        }
    }

    private static Boolean isManualUnderwritingCase(Case new_case) {
        return RecordTypeUtility.getKeyById(new_case.RecordTypeId) == RecordTypeUtility.CASE_MANUAL_UNDERWRITING;
    }

    @future (callout=true)
    public static void performCancelCalloutAndUpdateCase(id case_id) {
        if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(ApiCommandTestMock.SetIsSuccess));
        }
        Case case_to_cancel = [SELECT Auto_Canceled_Loan__c, Status, Loan_Application__r.Loan_ID__c
                               FROM Case
                               WHERE Id = :case_id FOR UPDATE];
        HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(
                            new ApiCommandCancelLoan(case_to_cancel.Loan_Application__r.Loan_ID__c, 'NO_CONTACT'));
        String error_message = getErrorFromResponse(response);
        if (error_message == null) {
            case_to_cancel.Status = 'Closed - Auto Cancelled';
            if(Limits.getLimitDMLStatements() - Limits.getDmlStatements() > 4) {
                AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.AUTO_CANCEL).record(case_to_cancel);
            }
        } else {
            sendMessagesForCase(case_to_cancel, error_message);
        }
        case_to_cancel.Auto_Canceled_Loan__c = false;
        try {
            update case_to_cancel;
        } catch (DmlException e) {
            sendMessagesForCase(case_to_cancel, 'Job failed on update: ' + e.getMessage() + '.<br>You should manually cancel the case');
        }

    }

    private static String getErrorFromResponse(HttpResponse response) {
        if (response.getStatusCode() == 200 && response.getStatus() == 'OK') {
            return null;
        } else {
            try {
                return (String)((Map<String, Object>)JSON.deserializeUntyped(response.getBody())).get('message');
            } catch (Exception e) {
                return 'Couldn\'t parse response: ' + e.getMessage();
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
        mail.setSubject('Auto Cancel Loan Failed');
        String body = 'Hey ' + admin.FirstName + ', <br><br>';
        body += 'Automatic Cancel Loan job was failed with the next error:<br>';
        body += error_message + '<br><br>';
        body += 'Please review this case: <br>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + case_to_cancel.Id;
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(false);
        return mail;
    }
}