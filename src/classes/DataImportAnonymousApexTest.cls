@isTest
private class DataImportAnonymousApexTest {
    static testMethod void testImportFeatureSwitchesFromResource(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            StaticResourceTestData.createTestFeatureSwitchStaticResource();
            Test.startTest();
                DataImportAnonymousApex.ImportFeatureSwitchesFromResource();
            Test.stopTest();
            Integer feature_count = Database.countQuery('SELECT COUNT() FROM Feature_Switch__c');
            System.assertEquals(3,feature_count,'Didnt create the 3 feature switches like in the static resource');
        }
    }

    static testMethod void testImportFeatureSwitchesFromResourceCreatesTheFeatureSwitchesWithTheCorrectValues(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            StaticResourceTestData.createTestFeatureSwitchStaticResource();
            Test.startTest();
                DataImportAnonymousApex.ImportFeatureSwitchesFromResource();
            Test.stopTest();
            List<Feature_Switch__c> feature_switch_for_cp_7 = [SELECT Id FROM Feature_Switch__c WHERE Name = 'ZOPA-7' AND readyForRelease__c = false AND readyForQA__c = true];
            System.assertEquals(1, feature_switch_for_cp_7.size(), 'Feature switch ZOPA-130 expected to be created with ready for QA and not ready for release');
            List<Feature_Switch__c> feature_switch_for_cp_4 = [SELECT Id FROM Feature_Switch__c WHERE Name = 'ZOPA-4' AND readyForRelease__c = false AND readyForQA__c = true];
            System.assertEquals(1, feature_switch_for_cp_4.size(), 'Feature switch ZOPA-4 expected to be created with ready for QA and ready for release');
        }
    }

    static testMethod void testConcreteImportFeatureSwitchFromResource(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            StaticResourceTestData.createTestFeatureSwitchStaticResource();
            Test.startTest();
                List<Map<String, String>> resources = CsvUtility.getDataFromCsvStaticResource('FeatureSwitch');
            Test.stopTest();
            String name_of_feature_switch = resources[0].get('Name');
            System.assertEquals('ZOPA-4', name_of_feature_switch,'Got the wrong feature switch record from the static resource');
        }
    }

    static testMethod void testExistingFeatureSwitchHasNotChanged(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            StaticResourceTestData.createTestFeatureSwitchStaticResource();
            setup_data.insertFeatureSwitch('ZOPA-4', true, true);
            setup_data.insertFeatureSwitch('ZOPA-7', true, true);

            Test.startTest();
                DataImportAnonymousApex.ImportFeatureSwitchesFromResource();
            Test.stopTest();

            Feature_Switch__c feature_switch = [SELECT Id, Name, readyForRelease__c, readyForQA__c, Already_deleted_from_code__c FROM Feature_Switch__c WHERE Name = 'ZOPA-4'];
            Feature_Switch__c feature_switch_2 = [SELECT Id, Name, readyForRelease__c, readyForQA__c, Already_deleted_from_code__c FROM Feature_Switch__c WHERE Name = 'ZOPA-7'];
            System.assertEquals(true, feature_switch.readyForQA__c);
            System.assertEquals(true, feature_switch.readyForRelease__c);
            System.assertEquals(true, feature_switch_2.readyForQA__c);
            System.assertEquals(true, feature_switch_2.readyForRelease__c);
        }
    }

    public class SetupDataClass{
        public User TestUser {get; private set;}

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'DataImportAnonymousApexTest' AND LastName = 'DataImportAnonymousApexTest' LIMIT 1];
        }

        public void insertFeatureSwitch(String name_of_feature_switch, Boolean ready_for_QA, Boolean ready_for_release){
            Feature_Switch__c feature = generateFeatureSwitch(name_of_feature_switch, ready_for_QA, ready_for_release);
            insert feature;
        }

        public Feature_Switch__c generateFeatureSwitch(String name, Boolean ready_for_QA, Boolean ready_for_release){
            Feature_Switch__c feature = new Feature_Switch__c();
            feature.Name = name;
            feature.JIRATicket__c = 'https://jira.wonga.com/browse/' + name;
            feature.ReadyForQA__c = ready_for_QA;
            feature.ReadyForRelease__c  = ready_for_release;
            return feature;
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('DataImportAnonymousApexTest')
                                     .setLastName('DataImportAnonymousApexTest')
                                     .save();
    }
}