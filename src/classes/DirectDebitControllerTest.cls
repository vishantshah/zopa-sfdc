@isTest
private class DirectDebitControllerTest {

    static testMethod void testNotValidateInput() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.ClassUnderTest.TheDirectDebit.AccountHolderName = '';
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateInput();
            Test.stopTest();

            System.assertEquals(false,result, 'Must be not valid data');
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter valid Account Number. Account Number should have 8 digits'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter valid Sort Code. Sort Code should have 6 digits'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter a Account Holder Name'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
        }
    }

    static testMethod void testValidateInput() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.ClassUnderTest.TheDirectDebit.SortCode = '123456';
            setup_data.ClassUnderTest.TheDirectDebit.AccountNumber = '12345678';
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateInput();
            Test.stopTest();

            System.assertEquals(true,result, 'Must be valid data');
        }
    }

    static testMethod void testCreateNewDirectDebitNotSuccessResponseValidInput() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.ClassUnderTest.TheDirectDebit.SortCode = '123456';
            setup_data.ClassUnderTest.TheDirectDebit.AccountNumber = '12345678';
            Test.startTest();
                setup_data.apiCommandNewDirectDebitTestMockForResponse(false, true);
                setup_data.ClassUnderTest.createNewDirectDebit();
            Test.stopTest();
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
        }
    }

    static testMethod void testCreateNewDirectDebitSuccessResponseValidInput() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable(new Set<String>{'ZCP-62', 'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createCase();
            setup_data.ClassUnderTest.TheDirectDebit.SortCode = '123456';
            setup_data.ClassUnderTest.TheDirectDebit.AccountNumber = '12345678';
            setup_data.apiCommandNewDirectDebitTestMockForResponse(true, true);
            Test.startTest();
                setup_data.ClassUnderTest.createNewDirectDebit();
            Test.stopTest();
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('Direct Debit created successfully'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
        }
    }

    static testMethod void testCreateNewDirectDebitSuccessResponseValidInputInvalidBankAccount() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable(new Set<String>{'ZCP-62'});
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createCase();
            setup_data.ClassUnderTest.TheDirectDebit.SortCode = '123456';
            setup_data.ClassUnderTest.TheDirectDebit.AccountNumber = '12345678';
            setup_data.apiCommandNewDirectDebitTestMockForResponse(true, false);
            Test.startTest();
                setup_data.ClassUnderTest.createNewDirectDebit();
            Test.stopTest();
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact(ApiCommandValidateBankAccountMock.getMockResponceBody(false)),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
        }
    }

    static testMethod void testRedirectToLoanPage() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                PageReference actual_result = setup_data.ClassUnderTest.redirectToLoanPage();
            Test.stopTest();
            System.assertEquals('/apex/loanview?id='+setup_data.TestLoan.Id, actual_result.getUrl(), 'Should be have the same url');
        }
    }

    private class SetupDataClass {
        public DirectDebitController ClassUnderTest;
        public User TestUser;
        public Account TestAccount;
        public Loan__c TestLoan;
        public Case TestCase;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'DirectDebitControllerTest' AND LastName = 'DirectDebitControllerTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoan = [SELECT Id, Loan_id__c FROM Loan__c LIMIT 1];
        }

        public void initClassUnderTest() {
            ApexPages.currentPage().getParameters().put('loanId', TestLoan.Id);
            ClassUnderTest = new DirectDebitController();
            ClassUnderTest.TheDirectDebit = new DirectDebitController.DirectDebitWrapper('Test');
        }

        public void createCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setLoan(TestLoan).save().getRecord();
            TestCase = [SELECT Id, Loan__c FROM Case LIMIT 1];
        }

        public void apiCommandNewDirectDebitTestMockForResponse(Boolean is_success, Boolean is_valid_data) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandNewDirectDebitMock(is_success, is_valid_data));
        }
    }

    @testSetup static void createAndInsertTestData() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('DirectDebitControllerTest')
                                     .setLastName('DirectDebitControllerTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            FeatureSwitch.disable('ZOPA-4');
            Account test_account = AccountBuilder.getBuilder('DirectDebitControllerTest').save().getRecord();
            LoanBuilder.getBuilder(test_account).setExternalId('TestLoanExtId').save();
        }
    }
}