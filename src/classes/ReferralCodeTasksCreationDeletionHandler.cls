public class ReferralCodeTasksCreationDeletionHandler {
    private static ReferralCodeTasksCreationDeletionHandler Instance;
    @TestVisible private List<Task> AllTaskToUpsert;
    @TestVisible private Set<Id> CasesIdsToSaveTasks;
    @TestVisible public static Map<UniqueTaskKey, Task> UniqueTaskKeyToExistingTask;

    public static ReferralCodeTasksCreationDeletionHandler getInstance() {
        if(Instance == null){
            Instance = new ReferralCodeTasksCreationDeletionHandler();
        }
        return Instance;
    }

    private ReferralCodeTasksCreationDeletionHandler() {
        AllTaskToUpsert = new List<Task>();
        UniqueTaskKeyToExistingTask = new Map<UniqueTaskKey, Task>();
        CasesIdsToSaveTasks = new Set<Id>();
    }

    public void queryExistingRCTasks(Map<Id, Case> old_cases) {
        for (Task old_task : [SELECT Case_Configuration_Task__r.Id, WhatId, Status, RCCodeStatus__c FROM Task
                                     WHERE WhatId IN :old_cases.keySet()
                                     AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_REFERRAL_CODE)
                                     AND Case_Configuration_Task__c != null
                                     AND RCCodeStatus__c != null]) {
            UniqueTaskKeyToExistingTask.put(new UniqueTaskKey(old_task.Case_Configuration_Task__r.Id, old_task.WhatId, old_task.RCCodeStatus__c), old_task);
        }
    }

    public void createTasksIfNecessary(Case new_case) {
        if (isCaseUnderwriting(new_case) && new_case.Status == 'Open') {
            AllTaskToUpsert.addAll(new CaseCodesConfigurations(new_case, true).getTasksForThisConfigurations());
        }
    }

    public void createUpdateDeleteTasksIfNecessary(Case old_case, Case new_case) {
        if (isCaseUnderwriting(new_case) && isReferralCodesUpdated(old_case, new_case)) {
            AllTaskToUpsert.addAll(new CaseCodesConfigurations(new_case, false).getTasksForThisConfigurations());
        } else {
            CasesIdsToSaveTasks.add(new_case.Id);
        }
    }

    public void upsertAndDeleteReferralTasks() {
        if (AllTaskToUpsert.size() > 0) {
            upsert AllTaskToUpsert;
            AllTaskToUpsert.clear();
        }
        List<Task> task_to_delete = getOnlyOpenTasksForCorrectCases(UniqueTaskKeyToExistingTask.values());
        if (task_to_delete.size() > 0) {
            delete task_to_delete;
            UniqueTaskKeyToExistingTask.clear();
        }
    }

    private List<Task> getOnlyOpenTasksForCorrectCases(List<Task> all_tasks) {
        List<Task> open_tasks_to_delete = new List<Task>();
        for (Task tasks_to_check : all_tasks) {
            if (tasks_to_check.Status == 'Open' && !CasesIdsToSaveTasks.contains(tasks_to_check.WhatId)) {
                open_tasks_to_delete.add(tasks_to_check);
            }
        }
        return open_tasks_to_delete;
    }

    private Boolean isCaseUnderwriting(Case new_case) {
        return new_case.RecordTypeId == RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING);
    }

    private Boolean isReferralCodesUpdated(Case old_case, Case new_case) {
        return old_case.Triggered_Referral_Codes__c != new_case.Triggered_Referral_Codes__c
            || old_case.Aborted_Referral_Codes__c != new_case.Aborted_Referral_Codes__c
            || old_case.Errored_Referral_Codes__c != new_case.Errored_Referral_Codes__c;
    }

    public static List<String> splitStringToList(String string_code) {
        if (string_code != null) {
            return string_code.split(';');
        } else {
            return new List<String>();
        }
    }

    private class UniqueTaskKey {
        Id CaseId;
        Id ConfigId;
        String RCCodeStatus;

        public UniqueTaskKey(Id confif_id, Id case_id, String rc_code_status) {
            CaseId = confif_id;
            ConfigId = case_id;
            RCCodeStatus = rc_code_status;
        }

        public Boolean equals(Object obj) {
            if (obj instanceof UniqueTaskKey) {
                UniqueTaskKey anothey_key = (UniqueTaskKey)obj;
                return anothey_key.CaseId == CaseId && anothey_key.ConfigId == ConfigId && anothey_key.RCCodeStatus == RCCodeStatus;
            }
            return false;
        }

        public Integer hashCode() {
            return ((String)CaseId).hashCode() + ((String)ConfigId).hashCode() + RCCodeStatus.hashCode();
        }
    }

    private class CaseCodesConfigurations {
        private Id CaseId;
        private Boolean ForNewCase;
        private List<String> TriggeredCaseConfigurationCodes;
        private List<String> AbortedCaseConfigurationCodes;
        private List<String> ErroredCaseConfigurationCodes;

        public CaseCodesConfigurations(Case case_record, Boolean for_new_case) {
            TriggeredCaseConfigurationCodes = splitStringToList(case_record.Triggered_Referral_Codes__c);
            AbortedCaseConfigurationCodes = splitStringToList(case_record.Aborted_Referral_Codes__c);
            ErroredCaseConfigurationCodes = splitStringToList(case_record.Errored_Referral_Codes__c);
            CaseId = case_record.Id;
            ForNewCase = for_new_case;
        }

        public List<Task> getTasksForThisConfigurations() {
            List<Task> tasks_to_create = getTasksForCodesAndStatus(TriggeredCaseConfigurationCodes, ReferralCodeUtility.Status.TRIGGERED);
            tasks_to_create.addAll(getTasksForCodesAndStatus(AbortedCaseConfigurationCodes, ReferralCodeUtility.Status.ABORTED));
            tasks_to_create.addAll(getTasksForCodesAndStatus(ErroredCaseConfigurationCodes, ReferralCodeUtility.Status.ERRORED));
            return tasks_to_create;
        }

        private List<Task> getTasksForCodesAndStatus(List<String> code_list, ReferralCodeUtility.Status code_status) {
            List<Task> tasks_to_create = new List<Task>();
            for (String code_name : code_list) {
                for (Case_Configuration_Task__c configuration_task : ReferralCodeUtility.getInstance().getConfigurationTasksForCodeWithSpecificStatus(code_name, code_status)) {
                    if (ForNewCase || taskDoesNotExist(configuration_task, code_status.name())) {
                        tasks_to_create.add(createNewTaskFromConfiguration(configuration_task, code_status.name()));
                    } else {
                        UniqueTaskKey key_task_to_update = new UniqueTaskKey(configuration_task.Id, CaseId, code_status.name());
                        tasks_to_create.add(updateTaskFromConfiguration(configuration_task, UniqueTaskKeyToExistingTask.get(key_task_to_update)));
                        UniqueTaskKeyToExistingTask.remove(key_task_to_update);
                    }
                }
            }
            return tasks_to_create;
        }

        private Boolean taskDoesNotExist(Case_Configuration_Task__c configuration_task, String code_status) {
            return !UniqueTaskKeyToExistingTask.containsKey(new UniqueTaskKey(configuration_task.Id, CaseId, code_status));
        }

        private Task updateTaskFromConfiguration(Case_Configuration_Task__c configuration_task, Task existing_task) {
            return TaskBuilder.getBuilder(existing_task)
                        .setTaskFor(configuration_task.Task_for__c)
                        .setSubject(configuration_task.Task_Subject__c)
                        .setCompletedDateTime(Datetime.now())
                        .setTaskDescription(configuration_task.Task_Description__c)
                        .getRecord();
        }

        private Task createNewTaskFromConfiguration(Case_Configuration_Task__c configuration_task, String code_status) {
            return TaskBuilder.getBuilder()
                        .setTaskFor(configuration_task.Task_for__c)
                        .setSubject(configuration_task.Task_Subject__c)
                        .setTaskDescription(configuration_task.Task_Description__c)
                        .setCompletedDateTime(Datetime.now())
                        .setCaseConfigurationTask(configuration_task.Id)
                        .setRCCodeStatus(code_status)
                        .setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                        .setRelatedTo(CaseId)
                        .getRecord();
        }
    }
}