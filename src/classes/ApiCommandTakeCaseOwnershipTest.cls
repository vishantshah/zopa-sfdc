@isTest
private class ApiCommandTakeCaseOwnershipTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.TAKE_CASE_OWNERSHIP, setup_data.ClassUnderTest.CommandName, 'CommandName should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            System.assertEquals('', body, 'Request body is not created correctly');
        }
    }

    static testMethod void testGetResponseSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockResponse(true, true);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                Boolean take_ownership_response_succcess = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals(true, take_ownership_response_succcess, 'Got the wrong response from the command');
            System.assertEquals(true, setup_data.ClassUnderTest.CommandSuccessful, 'Command should be successful');
            System.assertEquals(null, setup_data.ClassUnderTest.CommandError, 'Command should not have an error');

        }
    }

    static testMethod void testGetResponseNotSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockResponse(true, false);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                Boolean take_ownership_response_succcess = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals(false, take_ownership_response_succcess, 'Got the wrong response from the command');
            System.assertEquals(true, setup_data.ClassUnderTest.CommandSuccessful, 'Command should be successful');
            System.assertEquals(null, setup_data.ClassUnderTest.CommandError, 'Command should not have an error');

        }
    }

    static testMethod void testGetResponsefailResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockResponse(false, false);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.CommandSuccessful, 'Command should not be successful');
            System.assertEquals('Internal Server Error: Internal Error', setup_data.ClassUnderTest.CommandError, 'Command should not have an error');
        }
    }

    private class SetupDataClass {
        public ApiCommandTakeCaseOwnership ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandTakeCaseOwnershipTest' AND LastName = 'ApiCommandTakeCaseOwnershipTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandTakeCaseOwnership(UUID);
        }

        public void setMockResponse(Boolean is_success, Boolean fail_response) {
            Test.setMock(HttpCalloutMock.class, new ApiTakeCaseOwnershipTestMock(is_success, fail_response));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('ApiCommandTakeCaseOwnershipTest')
                                     .setLastName('ApiCommandTakeCaseOwnershipTest')
                                     .save();
    }
}