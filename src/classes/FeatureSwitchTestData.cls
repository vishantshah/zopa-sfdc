@isTest
public class FeatureSwitchTestData {

    public static Builder getFeatureSwitchForTest(String switch_name){
        return new Builder(switch_name);
    }

    public class Builder{
        private Feature_Switch__c Record;

        private Builder(String switch_name){
            Record = new Feature_Switch__c(
            Name = switch_name,
            readyForRelease__c = false,
            readyForQA__c = false,
            JIRATicket__c = 'https://jira.zopa.com/browse/' + switch_name
            );
        }

        public Builder save(){
            upsert record;
            return this;
        }

        public Builder setReadyForQA(Boolean value){
            Record.readyForQA__c = value;
            return this;
        }

        public Builder setReadyForRelease(Boolean value){
            Record.readyForRelease__c = value;
            return this;
        }

        public Builder setReleaseNotes(String value){
            Record.Release_Notes__c = value;
            return this;
        }

        public Builder setTrainingNotes(String value){
            Record.Training_Notes__c = value;
            return this;
        }

        public Builder setUATApprovedBy(String value){
            Record.UAT_Approved_by__c = value;
            return this;
        }

        public Builder setDemoApprovedBy(String value){
            Record.Demo_approved_by__c = value;
            return this;
        }

        public Feature_Switch__c getRecord(){
            return Record;
        }

        public List<Feature_Switch__c> getListOfRecords(Integer number_of_records){
            List<Feature_Switch__c> feature_switch_list = new List<Feature_Switch__c>();
            for(Integer i = 0; i < number_of_records; i++){
                Feature_Switch__c feature_switch_clone = Record.clone();
                feature_switch_list.add(feature_switch_clone);
            }
            return feature_switch_list;
        }
    }
}