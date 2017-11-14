@isTest
public without sharing class CaseConfigurationBuilderTest{

    static testMethod void testEmptyGetBuilderJustInitCaseConfiguration(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Case_Configuration__c test_case_configuration = CaseConfigurationBuilder.getBuilder().getRecord();
            Test.stopTest();
            System.assertNotEquals(null, test_case_configuration);
        }
    }

    static testMethod void testSetNameCorrectly(){
        SetupDataClass setup_data = new SetupDataClass();
        String case_configuration_name = 'RC_05';
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Case_Configuration__c test_case_configuration = CaseConfigurationBuilder.getBuilder()
                                                                .setName(case_configuration_name)
                                                                .getRecord();
            Test.stopTest();
            System.assertEquals(case_configuration_name, test_case_configuration.Name, 'Case Configuration name not set correctly');
        }
    }

    static testMethod void testSetCodeDescriptionCorrectly(){
        SetupDataClass setup_data = new SetupDataClass();
        String case_configuration_name = 'RC_05';
        String case_configuration_description = 'This is a test decription';
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Case_Configuration__c test_case_configuration = CaseConfigurationBuilder.getBuilder()
                                                                .setName(case_configuration_name)
                                                                .setCodeDescription(case_configuration_description)
                                                                .getRecord();
            Test.stopTest();
            System.assertEquals(case_configuration_description, test_case_configuration.Code_Description__c, 'Case Configuration description not set correctly');
        }
    }

    static testMethod void testSaveMethodWorksOnBuilder(){
        SetupDataClass setup_data = new SetupDataClass();
        String case_configuration_name = 'RC_05';
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Case_Configuration__c test_case_configuration = CaseConfigurationBuilder.getBuilder()
                                                                .setName(case_configuration_name)
                                                                .save()
                                                                .getRecord();
            Test.stopTest();
            System.assertNotEquals(null, test_case_configuration.Id, 'Case Configuration record was not saved');
        }
    }

    static testMethod void testGetCaseConfigurationList(){
        SetupDataClass setup_data = new SetupDataClass();
        String case_configuration_name = 'RC_05';
        Integer number_of_case_configurations = 105;
        System.runAs(setup_data.TestUser){
            Test.startTest();
                List<Case_Configuration__c> case_configuration_list = CaseConfigurationBuilder.getBuilder().getRecordList(number_of_case_configurations);
            Test.stopTest();
            System.assertEquals(number_of_case_configurations, case_configuration_list.size(), 'List of Case Configuration records is the wrong size');
        }
    }

    private class SetupDataClass{
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE LastName = 'CaseBuilderTestCASE_PREP' LIMIT 1];
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setLastName('CaseBuilderTestCASE_PREP')
                                     .save();
                UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('TestAdministrator')
                                     .setIsActive(true)
                                     .save();
    }
}