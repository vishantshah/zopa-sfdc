@isTest
private class ApiCommandApproveLoanAndWaveQuickPayTest {
    private static final String UUID = 'sdgfqewtfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.APPROVE_AND_WAVE_QUICK_PAY_COMMAND, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            String expected_body = '["' + UUID + '"]';
            System.assertEquals(expected_body, body, 'There should be 2 headers');
        }
    }

    private class SetupDataClass {
        public ApiCommandApproveLoanAndWaveQuickPay ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandApproveLoanAndMakeQuickPayTest' AND LastName = 'ApiCommandApproveLoanAndMakeQuickPayTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandApproveLoanAndWaveQuickPay(UUID);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandApproveLoanAndMakeQuickPayTest')
                                     .setLastName('ApiCommandApproveLoanAndMakeQuickPayTest')
                                     .save();
    }
}