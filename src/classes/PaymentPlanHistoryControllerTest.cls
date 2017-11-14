@IsTest
private class PaymentPlanHistoryControllerTest {

    static testMethod void testGetPaymentPlanHistoryWhenApiCallSuccessful() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setLoanUuid();
            setup_data.setMockForPaymentPlans(true);

            Test.startTest();
                setup_data.ClassUnderTest.getPaymentPlanHistory();
            Test.stopTest();

            System.assertEquals(3, setup_data.ClassUnderTest.ExistingPaymentPlans.size(), 'This list should contains 3 mocked Payment Plans.');
        }
    }

    static testMethod void testGetPaymentPlanHistoryWhenApiCallFailed() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setLoanUuid();
            setup_data.setMockForPaymentPlans(false);

            Test.startTest();
                setup_data.ClassUnderTest.getPaymentPlanHistory();
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.ExistingPaymentPlans.size(), 'Payment Plans should not be retrieved.');
            System.assert(MessageUtility.checkListContents('Internal Server Error', ApexPages.getMessages(), false), 'Proper message should be added.');
        }
    }

    static testMethod void testGetPaymentPlanHistoryWhenLoanUuidIsBlank() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setMockForPaymentPlans(true);

            Test.startTest();
                setup_data.ClassUnderTest.getPaymentPlanHistory();
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.ExistingPaymentPlans.size(), 'Payment Plans should not be retrieved.');
            System.assert(MessageUtility.checkListContents('Callout can\'t be performed', ApexPages.getMessages(), false), 'Proper message should be added.');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public PaymentPlanHistoryController ClassUnderTest;
        public String LoanId;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' LIMIT 1];
        }

        public void initController() {
            ClassUnderTest = new PaymentPlanHistoryController();
        }

        public void setLoanUuid() {
            ClassUnderTest.LoanUuid = '1234-1234-1234-1234';
        }

        public void setMockForPaymentPlans(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLoanPaymentPlansTestMock(is_success));
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('TestLastName')
                .save();
    }
}