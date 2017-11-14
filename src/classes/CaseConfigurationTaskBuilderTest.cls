@isTest
public class CaseConfigurationTaskBuilderTest{

    static testMethod void testEmptyGetBuilderJustInitCaseConfigurationTask(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Case_Configuration_Task__c test_case_configuration_task = CaseConfigurationTaskBuilder.getBuilder().getRecord();
            Test.stopTest();
            System.assertNotEquals(null, test_case_configuration_task);
        }
    }

    static testMethod void testSetParentCaseConfiguration(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestCaseConfiguration();
            Test.startTest();
                Case_Configuration_Task__c test_case_configuration_task = CaseConfigurationTaskBuilder.getBuilder(setup_data.TestCaseConfiguration)
                                                                            .getRecord();
            Test.stopTest();
            System.assertNotEquals(null, test_case_configuration_task.Case_Configuration__c,'Case Configuration was not set correctly');
        }
    }

    static testMethod void testSetSubject(){
        SetupDataClass setup_data = new SetupDataClass();
        String subject = 'test subject';
        System.runAs(setup_data.TestUser){
            setup_data.createTestCaseConfiguration();
            Test.startTest();
                Case_Configuration_Task__c test_case_configuration_task = CaseConfigurationTaskBuilder.getBuilder(setup_data.TestCaseConfiguration)
                                                                            .setTaskSubject(subject)
                                                                            .getRecord();
            Test.stopTest();
            System.assertEquals(subject, test_case_configuration_task.Task_Subject__c,'Task subject was not set correctly');
        }
    }

    static testMethod void testSetDescription(){
        SetupDataClass setup_data = new SetupDataClass();
        String description = 'test description';
        System.runAs(setup_data.TestUser){
            setup_data.createTestCaseConfiguration();
            Test.startTest();
                Case_Configuration_Task__c test_case_configuration_task = CaseConfigurationTaskBuilder.getBuilder(setup_data.TestCaseConfiguration)
                                                                            .setTaskDescription(description)
                                                                            .getRecord();
            Test.stopTest();
            System.assertEquals(description, test_case_configuration_task.Task_Description__c,'Task Description was not set correctly');
        }
    }

    static testMethod void testSetTaskFor(){
        SetupDataClass setup_data = new SetupDataClass();
        String task_for = 'Underwriter';
        System.runAs(setup_data.TestUser){
            setup_data.createTestCaseConfiguration();
            Test.startTest();
                Case_Configuration_Task__c test_case_configuration_task = CaseConfigurationTaskBuilder.getBuilder(setup_data.TestCaseConfiguration)
                                                                            .setTaskFor(task_for)
                                                                            .getRecord();
            Test.stopTest();
            System.assertEquals(task_for, test_case_configuration_task.Task_For__c,'Task For was not set correctly');
        }
    }

    static testMethod void testSaveMethodWorksOnBuilder(){
        SetupDataClass setup_data = new SetupDataClass();
        String task_for = 'Underwriter';
        System.runAs(setup_data.TestUser){
            setup_data.createTestCaseConfiguration();
            Test.startTest();
                Case_Configuration_Task__c test_case_configuration_task = CaseConfigurationTaskBuilder.getBuilder(setup_data.TestCaseConfiguration)
                                                                            .setTaskFor(task_for)
                                                                            .save()
                                                                            .getRecord();
            Test.stopTest();
            System.assertNotEquals(null, test_case_configuration_task.Id,'Case configuration task was not saved');
        }
    }

    static testMethod void testgetCaseConfigurationTaskList(){
        SetupDataClass setup_data = new SetupDataClass();
        Integer number_of_case_configuration_tasks = 100;
        System.runAs(setup_data.TestUser){
            Test.startTest();
                List<Case_Configuration_Task__c> case_configuration_task_list = CaseConfigurationTaskBuilder.getBuilder(setup_data.TestCaseConfiguration)
                                                                                    .getRecordList(number_of_case_configuration_tasks);
            Test.stopTest();
            System.assertEquals(number_of_case_configuration_tasks, case_configuration_task_list.size() , 'List of case configuration tasks has wrong size');
        }
    }

    private class SetupDataClass{
        public User TestUser;
        public Case_Configuration__c TestCaseConfiguration;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE LastName = 'CaseBuilderTestCASE_PREP' LIMIT 1];
        }

        public void createTestCaseConfiguration(){
            TestCaseConfiguration = CaseConfigurationBuilder.getBuilder().setName('RC_05').save().getRecord();
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setLastName('CaseBuilderTestCASE_PREP')
                                     .save();
    }
}