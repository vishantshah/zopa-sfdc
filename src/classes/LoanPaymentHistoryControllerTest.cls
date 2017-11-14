@isTest
private class LoanPaymentHistoryControllerTest {

    static testMethod void testGetPaymentHistoryInformationError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false,400);
            Test.startTest();
                setup_data.ClassUnderTest.getPaymentHistoryInformation();
            Test.stopTest();
            System.assertEquals('Bad request. Internal Error', setup_data.ClassUnderTest.ErrorOnLoad, 'Should have an error');
            System.assertEquals(0, setup_data.ClassUnderTest.PaymentHistoryList.size(), 'Should not fill PaymentHistoryList');
        }
    }

    static testMethod void testInitController() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                List<LoanPaymentHistoryController.ZopaLoanRepaymentItemWrapper> list_of_payments = setup_data.ClassUnderTest.PaymentHistoryList;
            Test.stopTest();
            System.assertEquals(true, list_of_payments.isEmpty(), 'Should be true because it is initialized with empty list in constructor');
            System.assertEquals(null, setup_data.ClassUnderTest.LoanDetails, 'Should be null because it is not being retrieved in constructor.');
        }
    }

    static testMethod void testGetIsNoPaymentsMessageVisibleIfEnabledFSAndEmptyPaymentListAndNoError() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-160');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true,200);
            Test.startTest();
                setup_data.ClassUnderTest.getPaymentHistoryInformation();
                setup_data.ClassUnderTest.PaymentHistoryList.clear();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsNoPaymentsMessageVisible();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be true if FS160 is enabled, payment list is empty and no errors');
        }
    }

    static testMethod void testGetIsNoPaymentsMessageVisibleIfEnabledFSAndNotEmptyPaymentList() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-160');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true,200);
            setup_data.ClassUnderTest.getPaymentHistoryInformation();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsNoPaymentsMessageVisible();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false if payment list is not empty');
        }
    }

    static testMethod void testGetIsNoPaymentsMessageVisibleIfDisabledFS() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-160');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true,200);
            setup_data.ClassUnderTest.getPaymentHistoryInformation();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsNoPaymentsMessageVisible();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false if FS160 is disabled');
        }
    }

    static testMethod void testGetIsZcp20IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-20');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp20IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false if FS20 is disabled');
        }
    }

    static testMethod void testGetIsZcp20IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-20');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp20IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be true if FS20 is enabled');
        }
    }

    static testMethod void testGetNoRecordToDisplayReturnFalseWhenThereAreRecords() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false,403);
            setup_data.ClassUnderTest.getPaymentHistoryInformation();
            Test.startTest();
                Boolean no_record_to_display = setup_data.ClassUnderTest.isNoRecordToDisplay();
            Test.stopTest();
            System.assertEquals(false, no_record_to_display, 'Result should have records');
        }
    }

    static testMethod void testGetNoRecordToDisplayReturnFalseWhenThereIsAnError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false,400);
            setup_data.ClassUnderTest.getPaymentHistoryInformation();
            Test.startTest();
                Boolean no_record_to_display = setup_data.ClassUnderTest.isNoRecordToDisplay();
            Test.stopTest();
            System.assertEquals(false, no_record_to_display, 'No records should be false if there\'s an error');
        }
    }

    static testMethod void testGetLoanHistoryHasAnyPaymentsWithResults() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, 200);
            Test.startTest();
                setup_data.ClassUnderTest.getPaymentHistoryInformation();
                Boolean loan_history_has_any_payments = setup_data.ClassUnderTest.getLoanHistoryHasAnyPayments();
            Test.stopTest();
            System.assertEquals(true, loan_history_has_any_payments, 'There should be payments');
        }
    }

    static testMethod void testGetLoanHistoryHasAnyPaymentsWithoutResults() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false, 400);
            setup_data.ClassUnderTest.getPaymentHistoryInformation();
            Test.startTest();
                Boolean loan_history_has_any_payments = setup_data.ClassUnderTest.getLoanHistoryHasAnyPayments();
            Test.stopTest();
            System.assertEquals(false, loan_history_has_any_payments, 'There shouldnt be any payments');
        }
    }

    static testMethod void testGetLoanDetailsWithSuccess200Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForLoanDetails(true, 200);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanDetails();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.getIsLoanDetailsRetrieved(), 'Loan Details should be retrieved and set successfully.');
        }
    }

    static testMethod void testGetLoanDetailsWithFail500Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForLoanDetails(false, 500);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanDetails();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.getIsLoanDetailsRetrieved(), 'Loan Details should not be retrieved and set.');
        }
    }

    private class SetupDataClass {
        public LoanPaymentHistoryController ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'LoanPaymentHistoryControllerTest' AND LastName = 'LoanPaymentHistoryControllerTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new LoanPaymentHistoryController();
            ClassUnderTest.LoanId = 'test_id';
        }

        public void setMockForResponse(Boolean is_success, Integer error_code) {
            Test.setMock(HttpCalloutMock.class, new LoanRepaymentMock(is_success, error_code));
        }

        public void setMockForLoanDetails(Boolean is_success, Integer error_code) {
            Test.setMock(HttpCalloutMock.class, new LoanDetailsViewMock(is_success, error_code));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('LoanPaymentHistoryControllerTest')
                                     .setLastName('LoanPaymentHistoryControllerTest')
                                     .save();
    }
}