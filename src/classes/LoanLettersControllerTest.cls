@IsTest
private class LoanLettersControllerTest {

    static testMethod void testGetLettersWhenSuccess200Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setLoanUuid();
            setup_data.setMockForGetAllLetters(true, 200);

            Test.startTest();
                setup_data.ClassUnderTest.getAllLetters();
            Test.stopTest();

            System.assertEquals(2, setup_data.ClassUnderTest.ExistingLetters.size(), 'This list should contains 2 mocked Letters.');
        }
    }

    static testMethod void testGetLettersWhenFail404Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setLoanUuid();
            setup_data.setMockForGetAllLetters(false, 404);

            Test.startTest();
                setup_data.ClassUnderTest.getAllLetters();
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.ExistingLetters.size(), 'This list should contains 0 mocked Letters.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: No letters found for this Loan'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testGetLettersWhenFail500Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setLoanUuid();
            setup_data.setMockForGetAllLetters(false, 500);

            Test.startTest();
                setup_data.ClassUnderTest.getAllLetters();
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.ExistingLetters.size(), 'This list should contains 0 mocked Letters.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testGetLetterWhenSuccess200Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setLoanUuid();
            setup_data.setSelectedLetter();
            setup_data.setMockForGetLetters(true, 200);

            Test.startTest();
                setup_data.ClassUnderTest.getLetter();
            Test.stopTest();

            System.assertEquals(true, String.isNotBlank(setup_data.ClassUnderTest.LetterData), 'Letter should be retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Letter retrieved successfully.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testGetLetterWhenFail404Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setLoanUuid();
            setup_data.setSelectedLetter();
            setup_data.setMockForGetLetters(false, 404);

            Test.startTest();
                setup_data.ClassUnderTest.getLetter();
            Test.stopTest();

            System.assertEquals(false, String.isNotBlank(setup_data.ClassUnderTest.LetterData), 'Letter should not be retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: Letter not found'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testGetLetterWhenFail500Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setLoanUuid();
            setup_data.setSelectedLetter();
            setup_data.setMockForGetLetters(false, 500);

            Test.startTest();
            setup_data.ClassUnderTest.getLetter();
            Test.stopTest();

            System.assertEquals(false, String.isNotBlank(setup_data.ClassUnderTest.LetterData), 'Letter should not be retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public LoanLettersController ClassUnderTest;
        public Account TestAccount;
        public Loan__c TestLoan;
        public Case TestCase;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' AND FirstName = 'TestFirstName' LIMIT 1];
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .save()
                    .getRecord();
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setExternalId('test')
                    .save()
                    .getRecord();
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(TestLoan)
                    .save()
                    .getRecord();
        }

        public void initController() {
            ClassUnderTest = new LoanLettersController();
        }

        public void setLoanUuid() {
            ClassUnderTest.LoanUuid = '1234-1234-1234-1234';
        }

        public void setSelectedLetter() {
            ClassUnderTest.LetterId = 1;
            ClassUnderTest.LetterName = 'TestLetterName';
        }

        public void setMockForGetAllLetters(Boolean is_success, Integer status_code) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLettersGetAllMock(is_success, status_code));
        }

        public void setMockForGetLetters(Boolean is_success, Integer status_code) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLettersGetMock(is_success, status_code));
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('TestLastName')
                .setFirstName('TestFirstName')
                .save();
    }
}