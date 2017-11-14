@isTest
private class ApiCommandBulkApproveLoanTest {
    private static final Set<String> UUID_LIST = new Set<String> {'1sdgfqeasdwtfafs', '2swfewefdsf','3dgfqeasdwtfafs'};

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID_LIST, setup_data.ClassUnderTest.LoanUuidSet, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.BULK_APPROVE_LOAN_COMMAND, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            String expected_body = '[';
            for (String uuid : UUID_LIST) {
                expected_body += '"' + uuid + '",';
            }
            expected_body = expected_body.removeEnd(',') + ']';
            System.assertEquals(expected_body, body, 'There should be correct body');
        }
    }

    private class SetupDataClass {
        public ApiCommandBulkApproveLoan ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandBulkApproveLoanTest' AND LastName = 'ApiCommandBulkApproveLoanTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandBulkApproveLoan(UUID_LIST);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandBulkApproveLoanTest')
                                     .setLastName('ApiCommandBulkApproveLoanTest')
                                     .save();
    }
}