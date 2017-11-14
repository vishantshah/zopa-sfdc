@isTest
private class AnonymousApexTest {

    static testMethod void testExecuteBeforeDeployAnonymousApex(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            StaticResourceTestData.createTestSchedulableJobsStaticResource();
            SchedulerAnonymousApex.RestoreSchedulableJobs();

            Test.startTest();
                AnonymousApex.executeBeforeDeployAnonymousApex();
            Test.stopTest();

            System.assertEquals(0, setup_data.getScheduledJobs().size(), 'Expected 0 jobs to be scheduled');
        }
    }

    static testMethod void testExecuteAfterDeployAnonymousApex(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            AnonymousApex.executeBeforeDeployAnonymousApex();
            StaticResourceTestData.createTestSchedulableJobsStaticResource();
            StaticResourceTestData.createTestFeatureSwitchStaticResource();
            StaticResourceTestData.createTestAccountTypeStaticResource();

            Test.startTest();
                AnonymousApex.executeAfterDeployAnonymousApex();
            Test.stopTest();

            System.assertEquals(6, setup_data.getScheduledJobs().size(), 'Expected 6 jobs to be scheduled');
            Integer feature_count = Database.countQuery('SELECT COUNT() FROM Feature_Switch__c');
            System.assertEquals(3, feature_count,'Didnt create the 3 feature switches like in the static resource');
            Integer account_type_count = Database.countQuery('SELECT COUNT() FROM Account_Type_Option_MU__c');
            System.assertEquals(10, account_type_count,'Didnt create the 10 account type like in the static resource');
        }
    }

    private class SetupDataClass {
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'AnonymousApexTest' AND LastName = 'AnonymousApexTest' LIMIT 1];
        }

        public List<CronTrigger> getScheduledJobs(){
            List<String> job_types_to_exclude = new List<String>{'3', '4', '8'};
            return [SELECT Id FROM CronTrigger WHERE NextFireTime != NULL AND CronJobDetail.JobType NOT IN :job_types_to_exclude];
        }
    }


    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                .setFirstName('AnonymousApexTest')
                .setLastName('AnonymousApexTest')
                .save();
    }
}