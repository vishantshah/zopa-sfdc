public with sharing class CaseConfigurationTaskBuilder{

    public class Builder{
        private Case_Configuration_Task__c NewCaseConfigurationTask;
        private Case_Configuration__c ParentCaseConfiguration;

        private Builder(Case_Configuration__c parent_case_configuration)
        {
            NewCaseConfigurationTask = new Case_Configuration_Task__c();
            this.ParentCaseConfiguration = parent_case_configuration;
            setDefaultCaseConfigurationTaskValues();
        }

        private Builder()
        {
            NewCaseConfigurationTask = new Case_Configuration_Task__c();
        }

        private void setDefaultCaseConfigurationTaskValues()
        {
            if(ParentCaseConfiguration != null){
                NewCaseConfigurationTask.Case_Configuration__c = ParentCaseConfiguration.Id;
            }
        }

        public Builder setTaskSubject(String task_subject){
            NewCaseConfigurationTask.Task_Subject__c = task_subject;
            return this;
        }

        public Builder setTaskDescription(String task_description){
            NewCaseConfigurationTask.Task_Description__c = task_description;
            return this;
        }

        public Builder setTaskFor(String task_for){
            NewCaseConfigurationTask.Task_For__c = task_for;
            return this;
        }

        public Builder setStatuses(String statuses) {
            NewCaseConfigurationTask.Statuses__c = statuses;
            return this;
        }

        public Builder save(){
            upsert NewCaseConfigurationTask;
            return this;
        }

        public Case_Configuration_Task__c getRecord(){
            return this.NewCaseConfigurationTask;
        }

        public List<Case_Configuration_Task__c> getRecordList(Integer no_of_case_configuration_tasks){
            List<Case_Configuration_Task__c> case_configuration_task_list = new List<Case_Configuration_Task__c>();
            for( Integer i = 0; i < no_of_case_configuration_tasks ;i++){
                case_configuration_task_list.add( this.NewCaseConfigurationTask.clone());
            }
            return case_configuration_task_list;
        }
    }

    public static Builder getBuilder(){
        return new Builder();
    }

    public static Builder getBuilder(Case_Configuration__c parent_case_configuration){
        return new Builder(parent_case_configuration);
    }
}