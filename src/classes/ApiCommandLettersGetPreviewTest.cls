@IsTest
private class ApiCommandLettersGetPreviewTest {
    static final String LOAN_ID = '0000-0000-0000-0001';
    static final String TEMPLATE_NAME = 'TestTemplateName';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initClassUnderTest(LOAN_ID, TEMPLATE_NAME);
            Test.stopTest();

            System.assertEquals(LOAN_ID, setup_data.ClassUnderTest.RecordUuid, 'Loan Id should be set with proper value.');
            System.assertEquals(TEMPLATE_NAME, setup_data.ClassUnderTest.TemplateName, 'Template Name should be set with proper value.');
            System.assertEquals(ApiCommandsFactory.GET_LETTER_PREVIEW, setup_data.ClassUnderTest.CommandName, 'Should be set as GET_LETTER_PREVIEW.');
        }
    }

    static testMethod void testApiCommandWithSuccess200Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(LOAN_ID, TEMPLATE_NAME);
            setup_data.setMockForResponse(true, 200);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.CommandSuccessful, 'Command should be successful.');
            System.assert(String.isNotBlank(setup_data.ClassUnderTest.getResponse()), 'Command response should not be blank.');
        }
    }

    static testMethod void testApiCommandWithFail404Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(LOAN_ID, TEMPLATE_NAME);
            setup_data.setMockForResponse(false, 404);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.CommandSuccessful, 'Command should failed.');
            System.assertEquals('Request error: Letter not found', setup_data.ClassUnderTest.CommandError, 'Not Found error message should be set.');
        }
    }

    static testMethod void testApiCommandWithFail500Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(LOAN_ID, TEMPLATE_NAME);
            setup_data.setMockForResponse(false, 500);

            Test.startTest();
            ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.CommandSuccessful, 'Command should failed.');
            System.assertEquals('Internal Server Error: Internal Error', setup_data.ClassUnderTest.CommandError, 'Internal error message should be set.');
        }
    }

    private class SetupDataClass {
        public ApiCommandLettersGetPreview ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'TestFirstName' AND LastName = 'TestLastName' LIMIT 1];
        }

        public void initClassUnderTest(String loan_id, String template_name) {
            ClassUnderTest = new ApiCommandLettersGetPreview(loan_id, template_name);
        }

        public void setMockForResponse(Boolean is_success, Integer status_code) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLettersGetMock(is_success, status_code));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setFirstName('TestFirstName')
                .setLastName('TestLastName')
                .save();
    }
}