@IsTest
private class ApiCommandLettersGetTest {
    static final String LOAN_ID = '0000-0000-0001';
    static final String LETTER_ID = '123456789';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initClassUnderTest(LOAN_ID, LETTER_ID);
            Test.stopTest();

            System.assertEquals(LOAN_ID, setup_data.ClassUnderTest.RecordUuid, 'Loan Id should be set with proper value.');
            System.assertEquals(LETTER_ID, setup_data.ClassUnderTest.LetterId, 'Letter Id should be set with proper value.');
            System.assertEquals(ApiCommandsFactory.GET_LETTER, setup_data.ClassUnderTest.CommandName, 'Command Name should be set as GET_LETTER.');
        }
    }

    static testMethod void testApiCommandWithSuccess200Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(LOAN_ID, LETTER_ID);
            setup_data.setMockForResponse(true, 200);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                String letter_data = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.CommandSuccessful, 'Command should be successful.');
            System.assertEquals(true, String.isNotBlank(letter_data), 'Not blank letter file should be retrieved.');
        }
    }

    static testMethod void testApiCommandWithFail404Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(LOAN_ID, LETTER_ID);
            setup_data.setMockForResponse(false, 404);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.CommandSuccessful, 'Command should failed.');
            System.assertEquals('Request error: Letter not found', setup_data.ClassUnderTest.CommandError, 'Not Found error should be set.');
        }
    }

    static testMethod void testApiCommandWithFail500Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(LOAN_ID, LETTER_ID);
            setup_data.setMockForResponse(false, 500);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.CommandSuccessful, 'Command should failed.');
            System.assertEquals('Internal Server Error: Internal Error', setup_data.ClassUnderTest.CommandError, 'Internal error should be set.');
        }
    }

    private class SetupDataClass {
        public ApiCommandLettersGet ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'TestFirstName' AND LastName = 'TestLastName' LIMIT 1];
        }

        public void initClassUnderTest(String loan_id, String letter_id) {
            ClassUnderTest = new ApiCommandLettersGet(loan_id, letter_id);
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