@isTest
private class ScheduleBatchUpdateCaseAssignmentsTest {

    @isTest static void testScheduleUpdateUnderwritingAssignments() {
        ScheduleBatchUpdateCaseAssignments.ScheduleUpdateUnderwritingAssignments class_under_test = new ScheduleBatchUpdateCaseAssignments.ScheduleUpdateUnderwritingAssignments();

        Test.startTest();
            class_under_test.execute(null);
        Test.stopTest();

        List<AsyncApexJob> apex_job = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, apex_job.size(), 'Batch job not scheduled ' + apex_job);
    }

    @isTest static void testScheduleUpdateCollectionsAssignments() {
        ScheduleBatchUpdateCaseAssignments.ScheduleUpdateCollectionsAssignments class_under_test = new ScheduleBatchUpdateCaseAssignments.ScheduleUpdateCollectionsAssignments();

        Test.startTest();
            class_under_test.execute(null);
        Test.stopTest();

        List<AsyncApexJob> apex_job = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, apex_job.size(), 'Batch job not scheduled ' + apex_job);
    }
}