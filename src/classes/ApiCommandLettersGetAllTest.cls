@IsTest
private class ApiCommandLettersGetAllTest {
    static final String LOAN_ID = '0000-0000-0001';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initClassUnderTest(LOAN_ID);
            Test.stopTest();

            System.assertEquals(LOAN_ID, setup_data.ClassUnderTest.RecordUuid, 'Loan Id should be set with proper value.');
            System.assertEquals(ApiCommandsFactory.GET_ALL_LETTERS, setup_data.ClassUnderTest.CommandName, 'Command Name should be set as GET_ALL_LETTERS.');
        }
    }

    static testMethod void testApiCommandWithSuccess200Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(LOAN_ID);
            setup_data.setMockForResponse(true, 200);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                List<ApiCommandLettersGetAll.Letter> letters = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.CommandSuccessful, 'Command should be successful.');
            System.assertEquals(2, letters.size(), '2 letters should be returned.');
        }
    }

    static testMethod void testApiCommandWithFail404Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(LOAN_ID);
            setup_data.setMockForResponse(false, 404);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.CommandSuccessful, 'Command should fail.');
            System.assertEquals(
                    'Request error: No letters found for this Loan',
                    setup_data.ClassUnderTest.CommandError,
                    'Not Found error message should be set.'
            );
        }
    }

    static testMethod void testApiCommandWithFail500Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(LOAN_ID);
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
        public ApiCommandLettersGetAll ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'TestFirstName' AND LastName = 'TestLastName' LIMIT 1];
        }

        public void initClassUnderTest(String loan_id) {
            ClassUnderTest = new ApiCommandLettersGetAll(loan_id);
        }

        public void setMockForResponse(Boolean is_success, Integer status_code) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLettersGetAllMock(is_success, status_code));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setFirstName('TestFirstName')
                .setLastName('TestLastName')
                .save();
    }
}