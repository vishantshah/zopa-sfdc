global class CaseArrearsDayCountBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable  {

    @TestVisible private String Query;
    @TestVisible private static List<Messaging.SingleEmailMessage> EmailToSend = new List<Messaging.SingleEmailMessage>();

    @TestVisible private String FailedIdsMessage = 'Some Case records was failed to update: \n';
    @TestVisible private String FatalErrorMessage = '';
    @TestVisible private Boolean IsError = false;

    global CaseArrearsDayCountBatch() {
        Query = 'SELECT Id, Process_Day_Counter__c FROM Case WHERE IsClosed = false';
        Query += ' AND RecordTypeId = \''+RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES) + '\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{
            List<Case> cases_to_count_day = (List<Case>) scope;
            for(Case case_to_count : cases_to_count_day){
                if(case_to_count.Process_Day_Counter__c != null){
                    case_to_count.Process_Day_Counter__c += 1;
                }else{
                    case_to_count.Process_Day_Counter__c = 1;
                }
            }
            updateCases(cases_to_count_day);
        }catch(Exception ex){
            FatalErrorMessage += '<br><br> Some unexpected exception: <br>' + ex.getMessage() + '<br><br>';
            IsError = true;
        }
    }

    private void updateCases(List<Case> cases_to_update){
        List<Database.SaveResult> updateResults = Database.update(cases_to_update, false);
        for(Integer i = 0; i < updateResults.size(); ++i){
            if (!updateResults.get(i).isSuccess()){
                Database.Error error = updateResults.get(i).getErrors().get(0);
                String error_message = error.getMessage();
                cases_to_update.get(i);
                FailedIdsMessage += 'Failed ID : '+cases_to_update.get(i).Id + ' With error: ' + error_message + '<br> ';
                FailedIdsMessage += 'Please review this case: : '+ System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + cases_to_update.get(i).Id +  '<br><br>';
                IsError = true;
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        if(IsError){
            sendMessagesForCase();
        }
    }

    private void sendMessagesForCase() {
        Id admin_profile_id = ProfileUtilities.getInstance().getProfileIdForType(ProfileUtilities.ProfileType.SYSADMIN);
        for (User admin : [SELECT Id, FirstName FROM User WHERE ProfileId = :admin_profile_id AND isActive = true]) {
            EmailToSend.add(getMessageForCaseAndAdmin(admin));
        }
        Messaging.sendEmail(EmailToSend, false);
    }

    private Messaging.SingleEmailMessage getMessageForCaseAndAdmin(User admin) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(admin.Id);
        mail.setSubject('Case update to count days in arrears process failed');
        String body = 'Hey ' + admin.FirstName + ', <br><br>';
        body += 'Case update to count days in arrears process has failed with the next error:<br>';
        body += FailedIdsMessage + '<br><br>';
           body += FatalErrorMessage;
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(false);
        return mail;
    }

    global void execute(SchedulableContext ctx) {
        database.executeBatch(this, 30);
    }

}