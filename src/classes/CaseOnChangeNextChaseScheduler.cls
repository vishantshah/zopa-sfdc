global class CaseOnChangeNextChaseScheduler {

    static final String FOR_REVIEW_TASK_SUBJECT = 'For Review';

    public static void handleCasesWithChangedNextReviewDate(List<Case> old_cases, List<Case> new_cases){
        for(Integer i = 0; i < new_cases.size(); ++i){
            if(shouldHandleCase(old_cases[i], new_cases[i])){
                changeCollectCaseScheduleChaseFlagToTrue(new_cases[i]);
                changeLockFromUpdatesInProcessFlagToTrue(new_cases[i]);
                setCaseOwnerToOnHold(new_cases[i]);
                if(isOwnerChanged(old_cases[i], new_cases[i])){
                    increaseReviewCounter(new_cases[i]);
                }
            }
        }
    }

    public static void handleCasesWithNextReviewDateAfterInsert(List<Case> new_cases){
        List<Case> handled_cases = new List<Case>();
        for(Integer i = 0; i < new_cases.size(); ++i){
            if(shouldHandleCase(new_cases[i])){
                handled_cases.add(new_cases[i]);
            }
        }
        createOrUpdateForReviewTasksForHandledCases(handled_cases);
    }

    public static void handleCasesWithChangedNextReviewDateAfterUpdate(List<Case> old_cases, List<Case> new_cases){
        List<Case> handled_cases = new List<Case>();
        for(Integer i = 0; i < new_cases.size(); ++i){
            if(shouldHandleCase(old_cases[i], new_cases[i])){
                handled_cases.add(new_cases[i]);
            }
        }
        createOrUpdateForReviewTasksForHandledCases(handled_cases);
    }

    private static Boolean shouldHandleCase(Case case_item){
        return isCaseCollectionsRecoveriesRecordType(case_item)
                && isNextReviewDateNotNull(case_item);
    }

    private static Boolean shouldHandleCase(Case old_case, Case new_case){
        return isCaseCollectionsRecoveriesRecordType(new_case)
                && isChangedNextReviewDate(old_case, new_case)
                && isNextReviewDateNotNull(new_case);
    }

    private static Boolean isCaseCollectionsRecoveriesRecordType(Case new_case){
        return new_case.RecordTypeId == RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES);
    }

    private static Boolean isChangedNextReviewDate(Case old_case, Case new_case){
        return old_case.Next_Review_Date__c != new_case.Next_Review_Date__c;
    }

    private static Boolean isNextReviewDateNotNull(Case case_item){
        return case_item.Next_Review_Date__c != null;
    }

    private static void changeCollectCaseScheduleChaseFlagToTrue(Case case_item){
        case_item.CollectCaseScheduleChaseFlag__c = true;
    }

    private static void changeLockFromUpdatesInProcessFlagToTrue(Case case_item){
        case_item.IsLockedFromUpdatesInProcess__c = true;
    }

    private static void setCaseOwnerToOnHold(Case case_item){
        case_item.OwnerId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD);
    }

    private static Boolean isOwnerChanged(Case old_case, Case new_case){
        return old_case.OwnerId != new_case.OwnerId;
    }

    @TestVisible
    private static void increaseReviewCounter(Case case_item){
        if(case_item.Review_Counter__c == null){
            case_item.Review_Counter__c = 1;
        }else{
            case_item.Review_Counter__c++;
        }
    }

    private static void createOrUpdateForReviewTasksForHandledCases(List<Case> cases){
        Map<Id, Task> case_id_to_existing_task = prepareCaseIdToExistingTaskMap(
                getExistingForReviewTasks(new Map<Id, Case>(cases).keySet())
        );
        for(Case case_item : cases){
            if(case_id_to_existing_task.containsKey(case_item.Id)){
                updateExistingForReviewTask(case_id_to_existing_task.get(case_item.Id), case_item);
            }else{
                case_id_to_existing_task.put(case_item.Id, createNewForReviewTask(case_item));
            }
        }
        if(!case_id_to_existing_task.isEmpty()){
            upsert case_id_to_existing_task.values();
        }
    }

    private static List<Task> getExistingForReviewTasks(Set<Id> case_ids){
        return [
                SELECT Id, Review_Due_Date__c, WhatId
                FROM Task
                WHERE Subject = :FOR_REVIEW_TASK_SUBJECT
                AND WhatId IN :case_ids
                AND Review_Due_Date__c != null
                AND IsClosed = false
                AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL)
        ];
    }

    private static Map<Id, Task> prepareCaseIdToExistingTaskMap(List<Task> tasks){
        Map<Id, Task> case_id_to_existing_task = new Map<Id, Task>();
        for(Task task_item : tasks) {
            case_id_to_existing_task.put(task_item.WhatId, task_item);
        }
        return case_id_to_existing_task;
    }

    private static void updateExistingForReviewTask(Task task_item, Case case_item){
        TaskBuilder.getBuilder(task_item)
                .setReviewDueDate(case_item.Next_Review_Date__c);
    }

    private static Task createNewForReviewTask(Case case_item){
        return TaskBuilder.getBuilder()
                .setRecordType(RecordTypeUtility.TASK_COLLECTIONS_CALL)
                .setOwner(UserInfo.getUserId())
                .setRelatedTo(case_item.Id)
                .setReviewDueDate(case_item.Next_Review_Date__c)
                .setSubject(FOR_REVIEW_TASK_SUBJECT)
                .setStatus('Open')
                .setSubType('Call')
                .getRecord();
    }
}