@isTest
private class PaymentHistoryViewControllerTest {

    static testMethod void testGetPaymentHistoryInformationSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getPaymentHistoryInformation();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'Should not have an error');
            System.assertNotEquals(null, setup_data.ClassUnderTest.PaymentHistoryList, 'Should initialize PaymentHistoryList');
            System.assertEquals(1, setup_data.ClassUnderTest.PaymentHistoryList.size(), 'Should fill PaymentHistoryList');
            System.assertEquals('04/10/2016', setup_data.ClassUnderTest.PaymentHistoryList.get(0).ZopaLoanRepaymentItems.get(0).RepaymentDate, 'Should fill PaymentHistoryList correctly');
            System.assertEquals('12345-123123-213123-12322', setup_data.ClassUnderTest.PaymentHistoryList.get(0).LoanExternalId, 'Should fill PaymentHistoryList correctly');
            System.assertEquals('Paid', setup_data.ClassUnderTest.PaymentHistoryList.get(0).ZopaLoanRepaymentItems.get(0).Status, 'Should fill PaymentHistoryList correctly');
            System.assertEquals('Regular', setup_data.ClassUnderTest.PaymentHistoryList.get(0).ZopaLoanRepaymentItems.get(0).Type, 'Should fill PaymentHistoryList correctly');
            System.assertEquals(250, setup_data.ClassUnderTest.PaymentHistoryList.get(0).ZopaLoanRepaymentItems.get(0).Amount, 'Should fill PaymentHistoryList correctly');
        }
    }

    static testMethod void testGetLoanIdIsExistIfLoalExist() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            setup_data.createAndInsertLoanWithExternalId();
            Test.startTest();
                setup_data.ClassUnderTest.getPaymentHistoryInformation();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.PaymentHistoryList.get(0).getLoanIdIsExist(), 'Should be true because we add loans');

        }
    }

    static testMethod void testGetLoanIdIsExistIfLoalNotExist() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getPaymentHistoryInformation();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.PaymentHistoryList.get(0).getLoanIdIsExist(), 'Should be false because we did not add loans');

        }
    }

    static testMethod void testGetPaymentHistoryInformationError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getPaymentHistoryInformation();
            Test.stopTest();
            System.assertEquals('Bad request. Internal Error', setup_data.ClassUnderTest.ErrorOnLoad, 'Should have an error');
            System.assertEquals(null, setup_data.ClassUnderTest.PaymentHistoryList, 'Should not fill PaymentHistoryList');
        }
    }

    static testMethod void testGetIsZopa74IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-74');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa74IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa74IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-74');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa74IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetNoRecordToDisplayReturnFalseWhenThereAreRecords() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getPaymentHistoryInformation();
                Boolean no_record_to_display = setup_data.ClassUnderTest.getNoRecordToDisplay();
            Test.stopTest();
            System.assertEquals(false, no_record_to_display, 'Result should have records');
        }
    }

    static testMethod void testGetNoRecordToDisplayReturnFalseWhenThereIsAnError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getPaymentHistoryInformation();
                Boolean no_record_to_display = setup_data.ClassUnderTest.getNoRecordToDisplay();
            Test.stopTest();
            System.assertEquals(false, no_record_to_display, 'No records should be false if there\'s an error');
        }
    }

    static testMethod void testGetNoRecordToDisplayReturnTrueWhenThereAreNoRecords() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, true);
            Test.startTest();
                setup_data.ClassUnderTest.getPaymentHistoryInformation();
                Boolean no_record_to_display = setup_data.ClassUnderTest.getNoRecordToDisplay();
            Test.stopTest();
            System.assertEquals(true, no_record_to_display, 'There should be no records');
        }
    }

    static testMethod void testGetLoanHistoryHasAnyPaymentsWithResults() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, false);
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
            setup_data.setMockForResponse(true, true);
            Test.startTest();
                setup_data.ClassUnderTest.getPaymentHistoryInformation();
                Boolean loan_history_has_any_payments = setup_data.ClassUnderTest.getLoanHistoryHasAnyPayments();
            Test.stopTest();
            System.assertEquals(false, loan_history_has_any_payments, 'There shouldnt be any payments');
        }
    }

    private class SetupDataClass {
        public PaymentHistoryViewController ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'PaymentHistoryViewControllerTest' AND LastName = 'PaymentHistoryViewControllerTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new PaymentHistoryViewController();
            ClassUnderTest.LoanAppId = 'test_id';
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanInfoTestMock(is_success));
        }

        public void setMockForResponse(Boolean is_success, Boolean empty_response) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanInfoTestMock(is_success, empty_response));
        }

        public void createAndInsertLoanWithExternalId(){
            Account test_account = AccountBuilder.getBuilder('AccountForTest').save().getRecord();
            LoanApplicationBuilder.getBuilder(test_account).setExternalId('12345-123123-213123-12322').save();
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('PaymentHistoryViewControllerTest')
                                     .setLastName('PaymentHistoryViewControllerTest')
                                     .save();
    }
}