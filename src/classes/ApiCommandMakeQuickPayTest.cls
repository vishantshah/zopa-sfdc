@isTest
private class ApiCommandMakeQuickPayTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.MAKE_QUICK_PAY_COMMAND, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            System.assertEquals('{}', body, 'There should be 2 headers');
        }
    }

    private class SetupDataClass {
        public ApiCommandMakeQuickPay ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandMakeQuickPayTest' AND LastName = 'ApiCommandMakeQuickPayTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandMakeQuickPay(UUID);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandMakeQuickPayTest')
                                     .setLastName('ApiCommandMakeQuickPayTest')
                                     .save();
    }
}