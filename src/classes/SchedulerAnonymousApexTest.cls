@isTest
private class SchedulerAnonymousApexTest {

    static testMethod void testAbortAllSchedulableJobs(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            StaticResourceTestData.createTestSchedulableJobsStaticResource();
            SchedulerAnonymousApex.RestoreSchedulableJobs();

            Test.startTest();
                SchedulerAnonymousApex.abortAllSchedulableJobs();
            Test.stopTest();

            System.assertEquals(0, setup_data.getScheduledJobs().size(), 'Expected 0 jobs to be scheduled');
        }
    }

    static testMethod void testRestoreSchedulableJobs(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            SchedulerAnonymousApex.abortAllSchedulableJobs();
            StaticResourceTestData.createTestSchedulableJobsStaticResource();

            Test.startTest();
                SchedulerAnonymousApex.restoreSchedulableJobs();
            Test.stopTest();

            System.assertEquals(6, setup_data.getScheduledJobs().size(), 'Expected 6 jobs to be scheduled');
        }
    }

    private class SetupDataClass {
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'SchedulerAnonymousApexTest' AND LastName = 'SchedulerAnonymousApexTest' LIMIT 1];
        }

        public List<CronTrigger> getScheduledJobs(){
            List<String> job_types_to_exclude = new List<String>{'3', '4', '8'};
            return [SELECT Id FROM CronTrigger WHERE NextFireTime != NULL AND CronJobDetail.JobType NOT IN :job_types_to_exclude];
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                .setFirstName('SchedulerAnonymousApexTest')
                .setLastName('SchedulerAnonymousApexTest')
                .save();
    }
}