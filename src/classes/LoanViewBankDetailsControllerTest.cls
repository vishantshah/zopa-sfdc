@IsTest
private class LoanViewBankDetailsControllerTest {

    @IsTest
    static void testInitClass() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.LazyLoadFinished, 'Lazy load was not started');
        }
    }

    @IsTest
    static void testSettingLoanDetails() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.CurrentLoanId = setup_data.TestLoan.Id;
            Test.stopTest();
            System.assertEquals(setup_data.TestLoan.Loan_Id__c, setup_data.ClassUnderTest.CurrentLoan.Loan_Id__c, 'Loan was queried incorrect');
            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentLoanId, 'LoanId was not setted');
        }
    }

    @IsTest
    static void testGetIsZCP56IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-56');
        System.runAs(setup_data.TestUser) {
        setup_data.initClassUnderTest();
        Test.startTest();
            Boolean is_enabled = setup_data.ClassUnderTest.getIsZCP56IsEnabled();
        Test.stopTest();
        System.assertEquals(true, is_enabled, 'ZCP-56 should be disabled');
        }
    }

    @IsTest
    static void testGetIsZCP56IsDisabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-56');
        System.runAs(setup_data.TestUser) {
        setup_data.initClassUnderTest();
        Test.startTest();
            Boolean is_enabled = setup_data.ClassUnderTest.getIsZCP56IsEnabled();
        Test.stopTest();
        System.assertEquals(false, is_enabled, 'ZCP-56 should be disabled');
        }
    }

    @IsTest
    static void testGetLoanDetailsInformation() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-56');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.ClassUnderTest.CurrentLoanId = setup_data.TestLoan.Id;
            setup_data.setMockForResponse(true, 200);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanBankDetailsInformation();
            Test.stopTest();
            System.assertEquals('test', setup_data.ClassUnderTest.BankDetails.AccountNumber, 'AccountNumber was setted incorrect.');
            System.assertEquals('test', setup_data.ClassUnderTest.BankDetails.SortCode, 'SortCode was setted incorrect.');
            System.assertEquals('test', setup_data.ClassUnderTest.BankDetails.AccountHolderName, 'AccountHolderName was setted incorrect.');
            System.assertEquals('test', setup_data.ClassUnderTest.BankDetails.Reference, 'Reference was setted incorrect.');
            System.assertEquals('test', setup_data.ClassUnderTest.BankDetails.BankName, 'BankName was setted incorrect.');
            System.assertEquals('test', setup_data.ClassUnderTest.BankDetails.DirectDebitStatus, 'DirectDebitStatus was setted incorrect.');
        }
    }


    private class SetupDataClass {
        public LoanViewBankDetailsController ClassUnderTest;
        public User TestUser;
        public Account TestAccount;
        public Loan__c TestLoan;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'LoanBankDetailTest' AND LastName = 'LoanBankDetailTest' LIMIT 1];
            TestAccount = AccountBuilder.getBuilder('TestUser').save().getRecord();
            createLoan();
        }

        public void initClassUnderTest() {
            ClassUnderTest = new LoanViewBankDetailsController();
        }

        public void setMockForResponse(Boolean is_success, Integer code) {
            Test.setMock(HttpCalloutMock.class, new LoanBankDetailsViewMock(is_success, code));
        }

        public void createLoan(){
            TestLoan = LoanBuilder.getBuilder(TestAccount).setExternalId(Utility.getRandomString(8)).save().getRecord();
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.COLLECTIONS)
                                     .setFirstName('LoanBankDetailTest')
                                     .setLastName('LoanBankDetailTest')
                                     .save();
    }
}