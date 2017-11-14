@isTest
private class CaseViewLoanDetailsExtenstionTest {

    static testMethod void testConstructorSetsCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'CurrentCase should be set');
            System.assertEquals(false, setup_data.ClassUnderTest.LazyLoadFinished, 'LazyLoadFinished should be false by default');
        }
    }

    static testMethod void testGetLoanDetailsInformationSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanDetailsInformation();
            Test.stopTest();
            System.assertEquals('60555123', setup_data.ClassUnderTest.BankAccountNumber, 'BankAccountNumber is not set correctly');
            System.assertEquals('10-20-30', setup_data.ClassUnderTest.SortCode, 'SortCode is not set correctly');
            System.assertEquals('Barclays', setup_data.ClassUnderTest.BankName, 'BankName is not set correctly');
            System.assertEquals('MegaCorp', setup_data.ClassUnderTest.EmployerName, 'EmployerName is not set correctly');
            System.assertEquals('John Smith', setup_data.ClassUnderTest.AccountHolder, 'AccountHolder is not set correctly');
            System.assertEquals(true, setup_data.ClassUnderTest.LazyLoadFinished, 'LazyLoadFinished should be true');
        }
    }

    static testMethod void testGetLoanDetailsInformationWhenCaseHasNoLoan() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.TestCase = CaseBuilder.getBuilder(setup_data.TestAccount).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
            setup_data.initClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.getLoanDetailsInformation();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.LazyLoadFinished, 'LazyLoadFinished should be true');
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('The case is not linked to a loan application'), 'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
        }
    }

    static testMethod void testGetLoanDetailsInformationError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanDetailsInformation();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.LazyLoadFinished, 'LazyLoadFinished should be true');
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('Can\'t load Bank Account Number, Sort Code, Bank Name and Employer Name. Bad Request. Internal Error'), 'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
        }
    }

    static testMethod void testGetIsZopa73IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-73');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa73IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa73IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-73');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa73IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetFeatureSwitch80EnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-80');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getFeatureSwitch80Enabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetFeatureSwitch80EnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-80');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getFeatureSwitch80Enabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be false');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Loan_Application__c TestLoanApplication;
        public Account TestAccount;
        public CaseViewLoanDetailsExtenstion ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestAccount = AccountBuilder.getBuilder('CaseViewLoanDetailsExtenstion').save().getRecord();
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setExternalId('1234').save().getRecord();
            TestCase = CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
            TestUser = [SELECT Id FROM User WHERE FirstName = 'CaseViewLoanDetailsExtenstionTest' AND LastName = 'CaseViewLoanDetailsExtenstionTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ApexPages.StandardController std_controller = new ApexPages.StandardController(TestCase);
            ClassUnderTest = new CaseViewLoanDetailsExtenstion(std_controller);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanInfoTestMock(is_success));
        }

        public void setMockForResponse(Boolean is_success, Boolean empty_response) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanInfoTestMock(is_success, empty_response));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('CaseViewLoanDetailsExtenstionTest')
                                     .setLastName('CaseViewLoanDetailsExtenstionTest')
                                     .save();
    }
}