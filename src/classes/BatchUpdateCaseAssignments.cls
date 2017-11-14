global class BatchUpdateCaseAssignments implements Database.Batchable<sObject>, Database.Stateful {
    @TestVisible private String ErrorMsgs = '';
    @TestVisible private Database.DMLOptions FraudDmlOption;
    @TestVisible private Database.DMLOptions CasePrepDmlOption;
    @TestVisible private Database.DMLOptions UnderwriterDmlOption;
    @TestVisible private Database.DMLOptions CollectionsDmlOption;
    @TestVisible private Database.DMLOptions RecoveriesDmlOption;
    @TestVisible private Database.DMLOptions SensitiveDmlOption;
    @TestVisible private Set<Id> QueueIds;
    global enum JobMode {
        UNDERWRITING,
        COLLECTIONS
    }
    @TestVisible private JobMode CurrentJobMode;

    global BatchUpdateCaseAssignments (JobMode job_mode) {
        CurrentJobMode = job_mode;
        initQueueIds();
        initDmlOptions();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(CurrentJobMode == JobMode.UNDERWRITING) {
            return Database.getQueryLocator([SELECT Id, Owner.Name, OwnerId FROM CASE WHERE OwnerId IN :QueueIds AND RecordType.Name = 'Manual Underwriting']);
        } else if (CurrentJobMode == JobMode.COLLECTIONS) {
            return Database.getQueryLocator([SELECT Id, Process__c FROM Case WHERE OwnerId IN :QueueIds AND RecordType.Name = 'Collections & Recoveries']);
        }
        return null;
    }

    global void execute(Database.BatchableContext batchable_context, List<Case> scope) {
        for (Case single_case: scope) {
            executeSingleCase(single_case);
        }
        handleDatabaseSaveResult(Database.update(scope,false));
    }

    global void finish(Database.BatchableContext batchable_context) {
        AsyncApexJob apex_job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchable_context.getJobId()];
        if(ErrorMsgs != '') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(apex_job.CreatedBy.Id);
            mail.setSubject('Batch Run Case (' + CurrentJobMode.name() + ')Assignments ' + apex_job.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + apex_job.TotalJobItems + ' batches with '+ apex_job.NumberOfErrors + ' failures.' + '\r\n' + ErrorMsgs + 'test');
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    private void initQueueIds(){
        if(CurrentJobMode == JobMode.UNDERWRITING) {
            QueueIds = new Map<Id, Group>([
                    SELECT Id
                    FROM Group
                    WHERE Type = 'Queue'
                    AND (
                            DeveloperName LIKE 'Case_Prep_Priority_%'
                            OR DeveloperName LIKE 'Fraud_Priority_%'
                            OR DeveloperName LIKE 'Underwriters_Priority_%'
                    )
            ]).keySet();
        } else if (CurrentJobMode == JobMode.COLLECTIONS) {
            QueueIds = new Map<Id, Group>([
                    SELECT Id
                    FROM Group
                    WHERE Type = 'Queue'
                    AND (
                            DeveloperName LIKE 'Collections_Priority_%'
                            OR DeveloperName LIKE 'Recoveries_Priority_%'
                            OR DeveloperName LIKE 'Sensitive_Priority_%'
                    )
            ]).keySet();
        }
    }

    private void initDmlOptions(){
        FraudDmlOption = new Database.DMLOptions();
        FraudDmlOption.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_FRAUD);
        CasePrepDmlOption = new Database.DMLOptions();
        CasePrepDmlOption.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_CASE_PREP);
        UnderwriterDmlOption = new Database.DMLOptions();
        UnderwriterDmlOption.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_UNDERWRITER);
        CollectionsDmlOption = new Database.DMLOptions();
        CollectionsDmlOption.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_COLLECTIONS);
        RecoveriesDmlOption = new Database.DMLOptions();
        RecoveriesDmlOption.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_RECOVERIES);
        SensitiveDmlOption = new Database.DMLOptions();
        SensitiveDmlOption.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_SENSITIVE);
    }

    private void executeSingleCase (Case single_case) {
        if(CurrentJobMode == JobMode.UNDERWRITING) {
            String owner_queue_name = CaseUtility.getInstance().getQueueNameFromId(single_case.OwnerId);
            if (owner_queue_name != null && owner_queue_name.contains('Fraud')) {
                single_case.setOptions(FraudDmlOption);
            } else if (owner_queue_name != null && owner_queue_name.contains('Case_Prep')) {
                single_case.setOptions(CasePrepDmlOption);
            } else if (owner_queue_name != null && owner_queue_name.contains('Underwriters')) {
                single_case.setOptions(UnderwriterDmlOption);
            }
        } else if (CurrentJobMode == JobMode.COLLECTIONS) {
            if(single_case.Process__c == CaseUtility.CASE_PROCESS_COLLECTIONS) {
                single_case.setOptions(CollectionsDmlOption);
            } else if (single_case.Process__c == CaseUtility.CASE_PROCESS_RECOVERIES) {
                single_case.setOptions(RecoveriesDmlOption);
            } else if (single_case.Process__c == CaseUtility.CASE_PROCESS_SENSITIVE_CUSTOMERS) {
                single_case.setOptions(SensitiveDmlOption);
            }
        }
    }

    private void handleDatabaseSaveResult (Database.SaveResult [] update_results) {
        for(Database.SaveResult single_update_results: update_results) {
            if(!single_update_results.isSuccess()) {
                this.errorMsgs += 'Case record:' + single_update_results.getId() + ', ' +  single_update_results.getErrors()[0].getMessage() + '\r\n';
            }
        }
    }
}