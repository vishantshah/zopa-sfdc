@isTest
private class ApiCommandCalculateAffordabilityTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.CALCULATE_AFFORDABILITY_COMMAND, setup_data.ClassUnderTest.CommandName, 'CommandName should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            String expected_body = '{"UnsecuredDebts":[{"Total":123.45,"Source":"source","Monthly":67.89,"Index":null,"CompanyClass":"company_class","AccountType":"account_type"}],"RollingCreditLines":[{"Total":123.45,"Source":"source","Monthly":6.17,"Index":null,"CompanyClass":"company_class","AccountType":"account_type"}],"MonthlyNetIncome":67.89,"ConfirmedRentMortgage":12.34,"ConfirmedAnnualIncome":123.45}';
            System.assertEquals(expected_body, body, 'Request body is not created correctly');
        }
    }

    static testMethod void testGetResponseSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setCalculateAffordabilityMockForResponse(true);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandCalculateAffordability.AffordabilityCalculationResponse affordability_response_loan_info = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals(100, affordability_response_loan_info.LDTI, 'Got the wrong DeclaredAnnualIncome');
            System.assertEquals(111, affordability_response_loan_info.DTI, 'Got the wrong DeclaredAnnualIncome');
            System.assertEquals(122, affordability_response_loan_info.DI, 'Got the wrong ConfirmedAnnualIncome');
        }
    }

    static testMethod void testGetResponseNotSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setCalculateAffordabilityMockForResponse(false);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.CommandSuccessful, 'Command should have not been successful');
            System.assertEquals('Internal Server Error: Internal Error', setup_data.ClassUnderTest.CommandError, 'Got the wrong error');
        }
    }

    private class SetupDataClass {
        public ApiCommandCalculateAffordability ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandCalculateAffordabilityTest' AND LastName = 'ApiCommandCalculateAffordabilityTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            List<AffordabilityDetailsController.RollingCreditLine> monthly_payments = new List<AffordabilityDetailsController.RollingCreditLine>();
            AffordabilityDetailsController.RollingCreditLine monthly_payment = new AffordabilityDetailsController.RollingCreditLine('company_class', 'account_type', 'source', 123.45, 67.89);
            monthly_payments.add(monthly_payment);
            List<AffordabilityDetailsController.UnsecuredDebt> unsecured_debts = new List<AffordabilityDetailsController.UnsecuredDebt>();
            AffordabilityDetailsController.UnsecuredDebt unsecured_debt = new AffordabilityDetailsController.UnsecuredDebt(67.89, 'company_class', 'account_type', 'source', 123.45);
            unsecured_debts.add(unsecured_debt);
            ClassUnderTest = new ApiCommandCalculateAffordability(UUID, 123.45, 67.89, 12.34, monthly_payments, unsecured_debts);
        }

        public void setCalculateAffordabilityMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCalculateAffordabilityTestMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('ApiCommandCalculateAffordabilityTest')
                                     .setLastName('ApiCommandCalculateAffordabilityTest')
                                     .save();
    }
}