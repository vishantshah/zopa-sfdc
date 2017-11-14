public class BatchUpdateCaseCounters implements Database.Batchable<sObject>, Schedulable {

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(this, 50);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT Id
                FROM Case
                WHERE RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                AND IsClosed = false
        ]);
    }

    public void execute(Database.BatchableContext batchable_context, List<Case> scope) {
        clearTaskCounters(scope);
        Map<Id, Case> scope_map = new Map<Id, Case>(scope);
        List<Task> tasks_related_to_cases = getTasksRelatedToCases(scope_map.keySet());
        for (Task task_item : tasks_related_to_cases) {
            increaseTaskCounters(scope_map.get(task_item.WhatId), task_item);
        }
        update scope;
    }

    private void clearTaskCounters(List<Case> cases) {
        for (Case case_item : cases) {
            case_item.Task_Counter__c = 0;
            case_item.Outbound_Calls_Counter__c = 0;
            case_item.Contacts_Made_Counter__c = 0;
        }
    }

    private List<Task> getTasksRelatedToCases(Set<Id> case_ids) {
        return [
                SELECT CompletedDateTime__c, RecordTypeId, Review_Due_Date__c, Subject, WhatId
                FROM Task
                WHERE WhatId IN :case_ids
        ];
    }

    private void increaseTaskCounters(Case case_item, Task task_item) {
        case_item.Task_Counter__c++;
        if (isOutboundCallTask(task_item)) {
            case_item.Outbound_Calls_Counter__c++;
        }
        if (isCompletedReviewTask(task_item)) {
            case_item.Contacts_Made_Counter__c++;
        }
    }

    private Boolean isOutboundCallTask(Task task_item) {
        return task_item.Subject.containsIgnoreCase('Outbound Call');
    }

    private Boolean isCompletedReviewTask(Task task_item) {
        return task_item.RecordTypeId == RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL)
                && task_item.Review_Due_Date__c != null
                && task_item.CompletedDateTime__c != null;
    }

    public void finish(Database.BatchableContext batchable_context) {
    }
}