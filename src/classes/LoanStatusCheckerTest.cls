@isTest
private class LoanStatusCheckerTest {
    static testMethod void testIsValidStatus() {
        SetupDataClass setup_data = new SetupDataClass();
        String closed_status = 'Settled';
        String invalid_status = 'invalid_status';
        System.runAs(setup_data.TestUser) {
            Test.startTest();
               Boolean result_with_closed_status = LoanStatusChecker.isClosedStatus(closed_status);
               Boolean result_with_invalid_status = LoanStatusChecker.isClosedStatus(invalid_status);
            Test.stopTest();
            System.assertEquals(true, result_with_closed_status);
            System.assertEquals(false, result_with_invalid_status);
        }
    }
    private class SetupDataClass {
        public User TestUser;
        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'CreateCollectionsRecoveriesCaseTest' LIMIT 1];
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('CreateCollectionsRecoveriesCaseTest')
                                     .save().getRecord();
    }
}