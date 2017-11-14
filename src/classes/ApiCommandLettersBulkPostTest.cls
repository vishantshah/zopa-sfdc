@IsTest
private class ApiCommandLettersBulkPostTest {

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();

            System.assertEquals(ApiCommandsFactory.BULK_POST_LETTER, setup_data.ClassUnderTest.CommandName, 'Command Name should be set as BULK_POST_LETTER.');
        }
    }

    static testMethod void testAddSendLetterRequest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.ClassUnderTest.addSendLetterRequest('1234-1234-1234-1234', 'TestTemplateName', 'Auto');

            Test.startTest();
                String json_body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();

            Map<String, Object> deserialized_body = (Map<String, Object>) JSON.deserializeUntyped(json_body);
            System.assertEquals(ApiCommandsFactory.BULK_POST_LETTER, setup_data.ClassUnderTest.CommandName, 'Command Name should be set as BULK_POST_LETTER.');
            System.assertEquals(true, deserialized_body.containsKey('generateLetterItems'), 'Body should contains key "generateLetterItems".');
            List<Object> deserialized_requests = (List<Object>) deserialized_body.get('generateLetterItems');
            System.assertEquals(1, deserialized_requests.size(), 'One Letter Request should be created.');
        }
    }

    static testMethod void testApiCommandWithSuccess200Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, 200);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.CommandSuccessful, 'Command should be successful.');
        }
    }

    static testMethod void testApiCommandWithSuccess202Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, 202);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.CommandSuccessful, 'Command should be successful.');
        }
    }

    static testMethod void testApiCommandWithFail500Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false, 500);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.CommandSuccessful, 'Command should fail.');
            System.assertEquals(
                    'Internal Server Error: Internal Error',
                    setup_data.ClassUnderTest.CommandError,
                    'Internal error message should be set.'
            );
        }
    }

    private class SetupDataClass {
        public ApiCommandLettersBulkPost ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'TestFirstName' AND LastName = 'TestLastName' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandLettersBulkPost();
        }

        public void setMockForResponse(Boolean is_success, Integer status_code) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLettersBulkPostMock(is_success, status_code));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setFirstName('TestFirstName')
                .setLastName('TestLastName')
                .save();
    }
}