@isTest
private class ApiCommandConfirmDefaultTest {
    private static final String UUID = 'sdgfqewtddfafs';
    private static final String REASON = 'reason';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(REASON, setup_data.ClassUnderTest.DefaultReason, 'Reason should be initialized');
            System.assertEquals(ApiCommandsFactory.PUT_CONFIRM_DEFAULT, setup_data.ClassUnderTest.CommandName, 'CommandName should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            System.debug(body);
            System.assertEquals('{"defaultReason":"reason"}', body, 'There should be correct body');
        }
    }

    private class SetupDataClass {
        public ApiCommandConfirmDefault ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandConfirmDefaultTest' AND LastName = 'ApiCommandConfirmDefaultTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandConfirmDefault(UUID,REASON);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('ApiCommandConfirmDefaultTest')
                                     .setLastName('ApiCommandConfirmDefaultTest')
                                     .save();
    }
}