public class ReferralCodeUtility {
    public Enum Status {TRIGGERED, ABORTED, ERRORED}
    private static ReferralCodeUtility Instance;

    @testVisible private Map<String, CaseConfigurationWrapper> CaseCodesNameToRecordMap;

    public static ReferralCodeUtility getInstance() {
        if(Instance == null){
            Instance = new ReferralCodeUtility();
        }
        return Instance;
    }

    private ReferralCodeUtility() {
        CaseCodesNameToRecordMap = new Map<String, CaseConfigurationWrapper>();
        for (Case_Configuration__c configuration_with_children:
                        [SELECT Id, Name, Code_Description__c,
                        (SELECT Task_Subject__c, Task_Description__c, Task_for__c, Statuses__c, Case_Configuration__c  FROM Case_Configuration_Tasks__r)
                        FROM Case_Configuration__c ]) {
            CaseCodesNameToRecordMap.put(configuration_with_children.Name, new CaseConfigurationWrapper(configuration_with_children));
        }
    }

    public List<Case_Configuration_Task__c> getConfigurationTasksForCodeWithSpecificStatus(String code_name, Status code_status) {
        if (CaseCodesNameToRecordMap.containsKey(code_name)) {
            return CaseCodesNameToRecordMap.get(code_name).getTasksForStatus(code_status);
        } else {
            return new List<Case_Configuration_Task__c>();
        }
    }

    private class CaseConfigurationWrapper {
        private String CodeName;
        private String StatusName;
        private Case_Configuration__c CaseConfigurationRecord;
        private List<Case_Configuration_Task__c> TriggeredCaseConfigurationTasks;
        private List<Case_Configuration_Task__c> AbortedCaseConfigurationTasks;
        private List<Case_Configuration_Task__c> ErroredCaseConfigurationTasks;

        public CaseConfigurationWrapper(Case_Configuration__c configuration_record) {
            CodeName = configuration_record.Name;
            CaseConfigurationRecord = configuration_record;
            fillConfigurationTaskLists();
        }

        private void fillConfigurationTaskLists() {
            TriggeredCaseConfigurationTasks = new List<Case_Configuration_Task__c>();
            AbortedCaseConfigurationTasks = new List<Case_Configuration_Task__c>();
            ErroredCaseConfigurationTasks = new List<Case_Configuration_Task__c>();
            for (Case_Configuration_Task__c configuration_task: CaseConfigurationRecord.Case_Configuration_Tasks__r) {
                if (configuration_task.Statuses__c.contains('Triggered')) {
                    TriggeredCaseConfigurationTasks.add(configuration_task);
                }
                if (configuration_task.Statuses__c.contains('Aborted')) {
                    AbortedCaseConfigurationTasks.add(configuration_task);
                }
                if (configuration_task.Statuses__c.contains('Errored')) {
                    ErroredCaseConfigurationTasks.add(configuration_task);
                }
            }
        }

        public List<Case_Configuration_Task__c> getTasksForStatus(Status code_status) {
            if (code_status == Status.TRIGGERED) {
                return TriggeredCaseConfigurationTasks;
            } else if (code_status == Status.ABORTED) {
                return AbortedCaseConfigurationTasks;
            } else {
                return ErroredCaseConfigurationTasks;
            }
        }
    }
}