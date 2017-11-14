@isTest
private class CsvUtilityTest {

    static testMethod void testGetDataFromCsvStaticResource() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            StaticResourceTestData.createTestSchedulableJobsStaticResource();
            Test.startTest();
                List<Map<String,String>> csv_map = CsvUtility.getDataFromCsvStaticResource('SchedulableJobs');
            Test.stopTest();
            System.assertEquals(6, csv_map.size(), 'Got the wrong map ' + csv_map);
            for (Integer i = 0; i < 6; i++) {
                System.assertEquals(3, csv_map.get(i).size(), 'Got the wrong map ' + csv_map.get(i));
                System.assert(csv_map.get(i).containsKey('Name'), 'Got the wrong map ' + csv_map.get(i));
                System.assert(csv_map.get(i).containsKey('Cron Expression'), 'Got the wrong map ' + csv_map.get(i));
                System.assert(csv_map.get(i).containsKey('Class Name'), 'Got the wrong map ' + csv_map.get(i));
            }
            System.assertEquals('Reevaluate underwriting assignment rules hourly',csv_map.get(0).get('Name'), 'Got the wrong map ' + csv_map.get(0));
            System.assertEquals('0 0 * * * ?',csv_map.get(0).get('Cron Expression'), 'Got the wrong map ' + csv_map.get(0));
            System.assertEquals('ScheduleRunUnderwritingAssignments',csv_map.get(0).get('Class Name'), 'Got the wrong map ' + csv_map.get(0));
            System.assertEquals('Reevaluate collections assignment rules hourly',csv_map.get(1).get('Name'), 'Got the wrong map ' + csv_map.get(1));
            System.assertEquals('0 0 * * * ?',csv_map.get(1).get('Cron Expression'), 'Got the wrong map ' + csv_map.get(1));
            System.assertEquals('ScheduleRunCollectionsAssignments',csv_map.get(1).get('Class Name'), 'Got the wrong map ' + csv_map.get(1));
            System.assertEquals('Reevaluate loan pending consolidation queue',csv_map.get(2).get('Name'), 'Got the wrong map ' + csv_map.get(2));
            System.assertEquals('0 0 1 * * ?',csv_map.get(2).get('Cron Expression'), 'Got the wrong map ' + csv_map.get(2));
            System.assertEquals('ScheduleUpdateLoanConsolidationQueue',csv_map.get(2).get('Class Name'), 'Got the wrong map ' + csv_map.get(2));
            System.assertEquals('Update OAuth Token every 30 mins 1',csv_map.get(3).get('Name'), 'Got the wrong map ' + csv_map.get(3));
            System.assertEquals('0 0 * * * ?',csv_map.get(3).get('Cron Expression'), 'Got the wrong map ' + csv_map.get(3));
            System.assertEquals('ScheduleUpdateZopaOAuth',csv_map.get(3).get('Class Name'), 'Got the wrong map ' + csv_map.get(3));
            System.assertEquals('Update OAuth Token every 30 mins 2',csv_map.get(4).get('Name'), 'Got the wrong map ' + csv_map.get(4));
            System.assertEquals('0 30 * * * ?',csv_map.get(4).get('Cron Expression'), 'Got the wrong map ' + csv_map.get(4));
            System.assertEquals('ScheduleUpdateZopaOAuth',csv_map.get(4).get('Class Name'), 'Got the wrong map ' + csv_map.get(4));
            System.assertEquals('Update Case Counters',csv_map.get(5).get('Name'), 'Got the wrong map ' + csv_map.get(4));
            System.assertEquals('0 0 6 * * ?',csv_map.get(5).get('Cron Expression'), 'Got the wrong map ' + csv_map.get(4));
            System.assertEquals('BatchUpdateCaseCounters',csv_map.get(5).get('Class Name'), 'Got the wrong map ' + csv_map.get(4));
        }
    }

    private class SetupDataClass {
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'CsvUtilityTest' AND LastName = 'CsvUtilityTest' LIMIT 1];
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('CsvUtilityTest')
                                     .setLastName('CsvUtilityTest')
                                     .save();
    }
}