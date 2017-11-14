global class BatchUpdateLoanConsolidationQueue implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    @TestVisible private String ErrorMsgs = '';
    @TestVisible private Id LoanConsolidationQueueId;
    @TestVisible private Id TeamLeaderQueueId;
    private final String CASE_STATUS_ADMIN_APPROVAL = 'Approved - Pending Admin Approval';

    global BatchUpdateLoanConsolidationQueue () {
        LoanConsolidationQueueId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_LOAN_CONSOLIDATION);
        TeamLeaderQueueId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.TEAM_LEADER);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query_string = 'SELECT Id, Loan_Application__r.Loan_ID__c, OwnerId, Status FROM Case WHERE OwnerId = \'' + LoanConsolidationQueueId + '\'';
        return Database.getQueryLocator(query_string);
    }

    global void execute(Database.BatchableContext batchable_context, List<Case> scope) {
        List<Case> cases_to_update = new List<Case>();
        for (Case single_case: scope) {
            if(executeSingleCase(single_case)){
                cases_to_update.add(single_case);
            }
        }
        if(!cases_to_update.isEmpty()){
            handleDatabaseSaveResult(Database.update(cases_to_update,false));
        }
    }

    global void finish(Database.BatchableContext batchable_context) {
        AsyncApexJob apex_job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchable_context.getJobId()];
        if(ErrorMsgs != '') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(apex_job.CreatedBy.Id);
            mail.setSubject('Batch update pending loan consolidation cases ' + apex_job.Status);
            mail.setPlainTextBody
            ('The batch Apex job processed ' + apex_job.TotalJobItems +
            ' batches with '+ apex_job.NumberOfErrors + ' failures.' + '\r\n' + ErrorMsgs + 'test');
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    private Boolean executeSingleCase(Case single_case) {
        String uuid = single_case.Loan_Application__r.Loan_ID__c;
        ApiCommandLoanConsolidationCandidates loan_consolidation_candidates_command = new ApiCommandLoanConsolidationCandidates(uuid);
        ApiCommandsFactory.getInstance().performApiCommandCallout(loan_consolidation_candidates_command);
        if (loan_consolidation_candidates_command.CommandSuccessful){
            if(!loan_consolidation_candidates_command.hasPaymentPending()){
                single_case.OwnerId = TeamLeaderQueueId;
                single_case.Status = CASE_STATUS_ADMIN_APPROVAL;
                return true;
            }
        } else {
            this.errorMsgs += 'Case record:' + single_case.Id + ', ' + 'There has been an error checking if there are loans pending consolidation. Error: ' + loan_consolidation_candidates_command.CommandError + '\r\n';
        }
        return false;
    }

    private void handleDatabaseSaveResult(Database.SaveResult [] update_results) {
        for(Database.SaveResult single_update_results: update_results) {
            if(!single_update_results.isSuccess()) {
                this.errorMsgs += 'Case record:' + single_update_results.getId() + ', ' +  single_update_results.getErrors()[0].getMessage() + '\r\n';
            }
        }
    }
}