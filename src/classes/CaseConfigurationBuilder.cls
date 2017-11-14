public class CaseConfigurationBuilder{

    public class Builder{
        private Case_Configuration__c NewCaseConfiguration;

        private Builder()
        {
            NewCaseConfiguration = new Case_Configuration__c();
        }

        public Builder setName(String case_configuration_name){
            NewCaseConfiguration.Name = case_configuration_name;
            return this;
        }

        public Builder setCodeDescription(String code_description){
            NewCaseConfiguration.Code_Description__c = code_description;
            return this;
        }

        public Builder save(){
            upsert NewCaseConfiguration;
            return this;
        }

        public Case_Configuration__c getRecord(){
            return NewCaseConfiguration;
        }

        public List<Case_Configuration__c> getRecordList(Integer number_of_case_configuration_records){
            List<Case_Configuration__c> case_configuration_list = new List<Case_Configuration__c>();
            for(Integer i=0;i<number_of_case_configuration_records;i++){
                case_configuration_list.add(this.NewCaseConfiguration.clone());
            }
            return case_configuration_list;
        }
    }

    public static Builder getBuilder(){
        return new Builder();
    }
}