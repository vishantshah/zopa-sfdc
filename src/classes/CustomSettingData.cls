@isTest
public class CustomSettingData {

    public static void createFeatureSwitchOn(String FeatureName){
        createFeatureSwitch(FeatureName, true);
    }

    public static void createFeatureSwitchOff(String FeatureName){
        createFeatureSwitch(FeatureName, false);
    }

    public static void createFeatureSwitch(String feature_name, Boolean turn_feature_switch_on){
        Feature_Switch__c new_feature_switch = createFeatureSwitchTestRecord(feature_name, turn_feature_switch_on);
        insert new_feature_switch;
    }

    public static void createDeliveredFeatureSwitch(String feature_name, Boolean turn_feature_switch_on){
        Feature_Switch__c new_feature_switch = createFeatureSwitchTestRecord(feature_name, turn_feature_switch_on);
        new_feature_switch.Delivered__c = true;
        insert new_feature_switch;
    }

    private static Feature_Switch__c createFeatureSwitchTestRecord(String feature_name, Boolean turn_feature_switch_on){
        Feature_Switch__c new_feature_switch = FeatureSwitchTestData.getFeatureSwitchForTest(feature_name)
                                                                    .setReadyForRelease(turn_feature_switch_on)
                                                                    .setReadyForQA(turn_feature_switch_on)
                                                                    .setReleaseNotes('Release notes')
                                                                    .setTrainingNotes('Training notes')
                                                                    .setUATApprovedBy('UAT approver')
                                                                    .setDemoApprovedBy('Demo approver')
                                                                    .getRecord();
        return new_feature_switch;
    }
}