@IsTest
private class ScheduleRunUnderwritingAssignmentsTest {

    static testmethod void testScheduleRunUnderwritingAssignments() {
        ScheduleRunUnderwritingAssignments class_under_test = new ScheduleRunUnderwritingAssignments();

        Test.startTest();
            class_under_test.execute(null);
        Test.stopTest();

        List<AsyncApexJob> apex_job = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'BatchUpdateCaseAssignments'];
        System.assertEquals(1, apex_job.size(), 'Batch job not scheduled ' + apex_job);
    }
}