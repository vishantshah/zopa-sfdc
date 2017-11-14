@IsTest
private class ScheduleRunCollectionsAssignmentsTest {

    static testmethod void testScheduleRunCollectionsAssignments() {
        ScheduleRunCollectionsAssignments class_under_test = new ScheduleRunCollectionsAssignments();

        Test.startTest();
            class_under_test.execute(null);
        Test.stopTest();

        List<AsyncApexJob> apex_job = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'BatchUpdateCaseAssignments'];
        System.assertEquals(1, apex_job.size(), 'Batch job not scheduled ' + apex_job);
    }
}