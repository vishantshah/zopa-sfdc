@isTest
private class ScheduleUpdateLoanConsolidationQueuTest {
    @isTest static void testScheduleWorksCorrectly() {
        ScheduleUpdateLoanConsolidationQueue class_under_test = new ScheduleUpdateLoanConsolidationQueue();
        Test.startTest();
            class_under_test.execute(null);
        Test.stopTest();

        List<AsyncApexJob> apex_job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, apex_job.size(), 'Batch job not scheduled ' + apex_job);
    }
}