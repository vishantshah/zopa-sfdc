public with sharing class DataImportAnonymousApex {

    private static final string FEATURE_SWITCHES_STATIC_RESOURCE_NAME = 'FeatureSwitch';
    private static Map<String,Feature_Switch__c> ExistingFeatureSwitchesMap = new Map<String,Feature_Switch__c>();
    private static Map<String,Map<String,String>> FeatureSwitchesFromStaticResourceMap = new Map<String,Map<String,String>>();

    private static void populateExistingFeatureSwitchesMap(){
        List<Feature_Switch__c> existing_feature_switches = [SELECT Id, Name, readyForRelease__c, Demo_approved_by__c,
                                                                    Release_Notes__c, Training_Notes__c,
                                                                    UAT_Approved_by__c, Description__c
                                                             FROM Feature_Switch__c];
        for(Feature_Switch__c feature_switch : existing_feature_switches){
            if(!ExistingFeatureSwitchesMap.containsKey(feature_switch.Name)){
                ExistingFeatureSwitchesMap.put(feature_switch.Name, feature_switch);
            }
        }
    }

    private static void populateFeatureSwitchesFromStaticResourceMap(){
        List<Map<String,String>> csv_data_from_static_resource = CsvUtility.getDataFromCsvStaticResource(FEATURE_SWITCHES_STATIC_RESOURCE_NAME);
        for(Map<String,String> feature_switch_map : csv_data_from_static_resource){
            FeatureSwitchesFromStaticResourceMap.put(feature_switch_map.get('Name'), feature_switch_map);
        }
    }

    private static Feature_Switch__c getFeatureSwitchFromCsvMap(Map<String,String> feature_switch_data_map){
        Feature_Switch__c feature_switch_record = new Feature_Switch__c();
        feature_switch_record.Name = feature_switch_data_map.get('Name');
        feature_switch_record.Description__c = feature_switch_data_map.get('Description');
        feature_switch_record.JIRATicket__c = feature_switch_data_map.get('JiraTicket__c');
        feature_switch_record.readyForRelease__c = false;
        feature_switch_record.readyForQA__c = true;
        return feature_switch_record;
    }

    public static void importFeatureSwitchesFromResource(){
        populateExistingFeatureSwitchesMap();
        populateFeatureSwitchesFromStaticResourceMap();
        List<Feature_Switch__c> list_of_feature_switches_to_upsert = new List<Feature_Switch__c>();
        for (Map<String,String> feature_switch_data_map : FeatureSwitchesFromStaticResourceMap.values()){
            if (!ExistingFeatureSwitchesMap.keySet().contains(feature_switch_data_map.get('Name'))){
                Feature_Switch__c feature_switch_up_upsert = getFeatureSwitchFromCsvMap(feature_switch_data_map);
                list_of_feature_switches_to_upsert.add(feature_switch_up_upsert);
            }
        }
        upsert list_of_feature_switches_to_upsert;
    }
}