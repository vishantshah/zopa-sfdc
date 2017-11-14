@isTest
private class AffordabilityDetailsControllerTest {

    static testMethod void testGetAffordabilityDetailsInformationSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
            Test.stopTest();

            assertAffordabilityDetailsFromQuery(setup_data);
        }
    }

    static testMethod void testGetAffordabilityDetailsInformationNotSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
            Test.stopTest();

            System.assertEquals('Bad request. Internal Error', setup_data.ClassUnderTest.ErrorOnLoad, 'ErrorOnLoad should be null');
        }
    }

    static testMethod void testAddMonthlyPaymentsRow() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
                setup_data.ClassUnderTest.addRollingCreditLinesRow();
            Test.stopTest();

            System.assertEquals(3, setup_data.ClassUnderTest.RollingCreditLines.size(), 'RollingCreditLines not set correctly');
            System.assertEquals('Unknown', setup_data.ClassUnderTest.RollingCreditLines.get(2).CompanyClass, 'RollingCreditLines not set correctly');
            System.assertEquals('Unknown', setup_data.ClassUnderTest.RollingCreditLines.get(2).AccountType, 'RollingCreditLines not set correctly');
            System.assertEquals('Underwriter', setup_data.ClassUnderTest.RollingCreditLines.get(2).Source, 'RollingCreditLines not set correctly');
            System.assertEquals(null, setup_data.ClassUnderTest.RollingCreditLines.get(2).Total, 'RollingCreditLines not set correctly');
            System.assertEquals(2, setup_data.ClassUnderTest.RollingCreditLines.get(2).Index, 'RollingCreditLines not set correctly');
        }
    }

    static testMethod void testAddUnsecuredDebtsRow() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
                setup_data.ClassUnderTest.addUnsecuredDebtsRow();
            Test.stopTest();

            System.assertEquals(3, setup_data.ClassUnderTest.UnsecuredDebts.size(), 'UnsecuredDebts not set correctly');
            System.assertEquals('Unknown', setup_data.ClassUnderTest.UnsecuredDebts.get(2).CompanyClass, 'UnsecuredDebts not set correctly');
            System.assertEquals('Unknown', setup_data.ClassUnderTest.UnsecuredDebts.get(2).AccountType, 'UnsecuredDebts not set correctly');
            System.assertEquals('Underwriter', setup_data.ClassUnderTest.UnsecuredDebts.get(2).Source, 'UnsecuredDebts not set correctly');
            System.assertEquals(null, setup_data.ClassUnderTest.UnsecuredDebts.get(2).Total, 'UnsecuredDebts not set correctly');
            System.assertEquals(null, setup_data.ClassUnderTest.UnsecuredDebts.get(2).Monthly, 'UnsecuredDebts not set correctly');
            System.assertEquals(2, setup_data.ClassUnderTest.UnsecuredDebts.get(2).Index, 'UnsecuredDebts not set correctly');
        }
    }

    static testMethod void testRemoveMonthlyPaymentsRow() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
                setup_data.ClassUnderTest.RowIndexToRemove = '0';
                setup_data.ClassUnderTest.removeRollingCreditLinesRow();
            Test.stopTest();

            System.assertEquals(1, setup_data.ClassUnderTest.RollingCreditLines.size(), 'RollingCreditLines not set correctly');
            System.assertEquals(0, setup_data.ClassUnderTest.RollingCreditLines.get(0).Index, 'RollingCreditLines not set correctly');
        }
    }

    static testMethod void testRemoveUnsecuredDebtsRow() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
                setup_data.ClassUnderTest.RowIndexToRemove = '0';
                setup_data.ClassUnderTest.removeUnsecuredDebtsRow();
            Test.stopTest();

            System.assertEquals(1, setup_data.ClassUnderTest.UnsecuredDebts.size(), 'UnsecuredDebts not set correctly');
            System.assertEquals(0, setup_data.ClassUnderTest.UnsecuredDebts.get(0).Index, 'UnsecuredDebts not set correctly');
        }
    }

    static testMethod void testGetIsZopa78And79IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable(new Set<String>{'ZOPA-78', 'ZOPA-79'});
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled_78 = setup_data.ClassUnderTest.getIsZopa78IsEnabled();
                Boolean is_enabled_79 = setup_data.ClassUnderTest.getIsZopa79IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled_78, 'Should be false');
            System.assertEquals(false, is_enabled_79, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa78And79sEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable(new Set<String>{'ZOPA-78', 'ZOPA-79'});
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled_78 = setup_data.ClassUnderTest.getIsZopa78IsEnabled();
                Boolean is_enabled_79 = setup_data.ClassUnderTest.getIsZopa79IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled_78, 'Should be true');
            System.assertEquals(true, is_enabled_79, 'Should be true');
        }
    }

    static testMethod void testCalculateAffordabilityDetailsSuccessResponseValidInput() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
                setup_data.setCalculateAffordabilityMockForResponse(true);
                setup_data.ClassUnderTest.calculateAffordabilityDetails();
            Test.stopTest();

            System.assertEquals(100, setup_data.ClassUnderTest.LowDebtToIncome, 'Got the wrong LowDebtToIncome');
            System.assertEquals(111, setup_data.ClassUnderTest.DebtToIncome, 'Got the wrong DeclaredAnnualIncome');
            System.assertEquals(122, setup_data.ClassUnderTest.DisposableIncome, 'Got the wrong ConfirmedAnnualIncome');
        }
    }

    static testMethod void testSetCalculateResponseNoWarnings() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            ApiCommandCalculateAffordability.AffordabilityCalculationResponse affordability_response_test = new ApiCommandCalculateAffordability.AffordabilityCalculationResponse();
            affordability_response_test.LDTI = 59;
            affordability_response_test.DTI = 99;
            affordability_response_test.DI = 451;

            Test.startTest();
                setup_data.ClassUnderTest.setCalculateResponse(affordability_response_test);
            Test.stopTest();

            System.assertEquals(59, setup_data.ClassUnderTest.LowDebtToIncome, 'Got the wrong LowDebtToIncome');
            System.assertEquals(99, setup_data.ClassUnderTest.DebtToIncome, 'Got the wrong DebtToIncome');
            System.assertEquals(451, setup_data.ClassUnderTest.DisposableIncome, 'Got the wrong DisposableIncome');
            System.assertEquals(false, setup_data.ClassUnderTest.IsWarningLDTI, 'Got the wrong Warning check');
            System.assertEquals(false, setup_data.ClassUnderTest.IsWarningDTI, 'Got the wrong Warning check');
            System.assertEquals(false, setup_data.ClassUnderTest.IsWarningDI, 'Got the wrong Warning check');
        }
    }

    static testMethod void testSetCalculateResponseWitnWarnings() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            ApiCommandCalculateAffordability.AffordabilityCalculationResponse affordability_response_test = new ApiCommandCalculateAffordability.AffordabilityCalculationResponse();
            affordability_response_test.LDTI = 61;
            affordability_response_test.DTI = 101;
            affordability_response_test.DI = 449;

            Test.startTest();
                setup_data.ClassUnderTest.setCalculateResponse(affordability_response_test);
            Test.stopTest();

            System.assertEquals(61, setup_data.ClassUnderTest.LowDebtToIncome, 'Got the wrong LowDebtToIncome');
            System.assertEquals(101, setup_data.ClassUnderTest.DebtToIncome, 'Got the wrong DebtToIncome');
            System.assertEquals(449, setup_data.ClassUnderTest.DisposableIncome, 'Got the wrong DisposableIncome');
            System.assertEquals(true, setup_data.ClassUnderTest.IsWarningLDTI, 'Got the wrong Warning check');
            System.assertEquals(true, setup_data.ClassUnderTest.IsWarningDTI, 'Got the wrong Warning check');
            System.assertEquals(true, setup_data.ClassUnderTest.IsWarningDI, 'Got the wrong Warning check');
        }
    }

    static testMethod void testCalculateAffordabilityDetailsNotSuccessResponseValidInput() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
                setup_data.setCalculateAffordabilityMockForResponse(false);
                setup_data.ClassUnderTest.calculateAffordabilityDetails();
            Test.stopTest();

            assertAffordabilityDetailsFromQuery(setup_data);
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
        }
    }

    static testMethod void testUpdateAffordabilityDetailsZopa89Enable() {
         SetupDataClass setup_data = new SetupDataClass();
         FeatureSwitch.enable('ZOPA-89');
         System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTestWithStandardController();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
                setup_data.setUpdateAffordabilityMockForResponse(true);
                setup_data.ClassUnderTest.updateAffordabilityDetails();
            Test.stopTest();

            System.assertEquals(1, setup_data.getAllTasksForLoanApplication().size(), 'Should have 1 task');
        }
    }

    static testMethod void testUpdateAffordabilityDetailsSuccessResponseValidInput() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
                setup_data.setUpdateAffordabilityMockForResponse(true);
                setup_data.ClassUnderTest.updateAffordabilityDetails();
            Test.stopTest();

            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('Affordability details updated successfully'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
        }
    }

    static testMethod void testUpdateAffordabilityDetailsNotSuccessResponseValidInput() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
                setup_data.setUpdateAffordabilityMockForResponse(false);
                setup_data.ClassUnderTest.updateAffordabilityDetails();
            Test.stopTest();

            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: Internal issues.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testSettinScaleForDecimalNull() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();

                Decimal result = setup_data.ClassUnderTest.setScaleForDecimal(null);

            Test.stopTest();

            System.assertEquals(null, result ,'Value should be null, exeption wasn\'t fired');
        }
    }

    static testMethod void testUpdateAffordabilityDetailsNotValidInput() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
                setup_data.ClassUnderTest.addRollingCreditLinesRow();
                setup_data.ClassUnderTest.addUnsecuredDebtsRow();
                setup_data.ClassUnderTest.ConfirmedAnnualIncome = null;
                setup_data.ClassUnderTest.MonthlyNetIncome = null;
                setup_data.ClassUnderTest.updateAffordabilityDetails();
            Test.stopTest();

            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter Verified Gross Annual Income'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter Monthly Net Income'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter Total value for Rolling Credit Line in row 3'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter a Monthly value for Unsecured Debt in row 3'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter Total for Unsecured Debt in row 3'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
        }
    }

    static testMethod void testCalculateAffordabilityDetailsNotValidInput() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setLoanInfoMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAffordabilityDetailsInformation();
                setup_data.ClassUnderTest.addRollingCreditLinesRow();
                setup_data.ClassUnderTest.addUnsecuredDebtsRow();
                setup_data.ClassUnderTest.ConfirmedAnnualIncome = null;
                setup_data.ClassUnderTest.MonthlyNetIncome = null;
                setup_data.ClassUnderTest.calculateAffordabilityDetails();
            Test.stopTest();

            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter Verified Gross Annual Income'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter Monthly Net Income'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter Total value for Rolling Credit Line in row 3'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter a Monthly value for Unsecured Debt in row 3'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('You must enter Total for Unsecured Debt in row 3'),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
        }
    }

    public static void assertAffordabilityDetailsFromQuery(SetupDataClass setup_data){
        System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'ErrorOnLoad should be null');
        System.assertEquals(35000, setup_data.ClassUnderTest.DeclaredAnnualIncome, 'Got the wrong DeclaredAnnualIncome');
        System.assertEquals(30000, setup_data.ClassUnderTest.ConfirmedAnnualIncome, 'Got the wrong ConfirmedAnnualIncome');
        System.assertEquals('PASS', setup_data.ClassUnderTest.IncomeCheckResult, 'Got the wrong IncomeCheckResult');
        System.assertEquals(560, setup_data.ClassUnderTest.AdditionalIncome, 'Got the wrong AdditionalIncome');
        System.assertEquals(2000, setup_data.ClassUnderTest.MonthlyNetIncome, 'Got the wrong MonthlyNetIncome');
        System.assertEquals(670, setup_data.ClassUnderTest.RentMortgage, 'Got the wrong RentMortgage');
        System.assertEquals(270, setup_data.ClassUnderTest.ConfirmedRentMortgage, 'Got the wrong ConfirmedRentMortgage');
        System.assertEquals(40, setup_data.ClassUnderTest.TotalMonthlyRepaymentAmount, 'Got the wrong TotalMonthlyRepaymentAmount');
        System.assertEquals(700, setup_data.ClassUnderTest.TotalUnsecuredDebtAmount, 'Got the wrong TotalUnsecuredDebtAmount');
        System.assertEquals(122, setup_data.ClassUnderTest.DisposableIncome, 'Got the wrong DisposableIncome');
        System.assertEquals(111, setup_data.ClassUnderTest.DebtToIncome, 'Got the wrong DebtToIncome');
        System.assertEquals(100, setup_data.ClassUnderTest.LowDebtToIncome, 'Got the wrong LowDebtToIncome');
        System.assertEquals(1670, setup_data.ClassUnderTest.BureauMortgage, 'Got the wrong BureauMortgage');

        System.assertNotEquals(null, setup_data.ClassUnderTest.RollingCreditLines, 'RollingCreditLines not set correctly');
        System.assertEquals(2, setup_data.ClassUnderTest.RollingCreditLines.size(), 'RollingCreditLines not set correctly');
        System.assertEquals('CommunicationSupplier', setup_data.ClassUnderTest.RollingCreditLines.get(1).CompanyClass, 'RollingCreditLines not set correctly');
        System.assertEquals('CommunicationsSupplier', setup_data.ClassUnderTest.RollingCreditLines.get(0).AccountType, 'RollingCreditLines not set correctly');
        System.assertEquals('Equifax', setup_data.ClassUnderTest.RollingCreditLines.get(0).Source, 'RollingCreditLines not set correctly');
        System.assertEquals(530.5, setup_data.ClassUnderTest.RollingCreditLines.get(1).Total, 'RollingCreditLines not set correctly');
        System.assertEquals(1, setup_data.ClassUnderTest.RollingCreditLines.get(1).Index, 'RollingCreditLines not set correctly');

        System.assertNotEquals(null, setup_data.ClassUnderTest.UnsecuredDebts, 'UnsecuredDebts not set correctly');
        System.assertEquals(2, setup_data.ClassUnderTest.UnsecuredDebts.size(), 'UnsecuredDebts not set correctly');
        System.assertEquals('CommunicationSupplier', setup_data.ClassUnderTest.UnsecuredDebts.get(1).CompanyClass, 'UnsecuredDebts not set correctly');
        System.assertEquals('CommunicationsSupplier', setup_data.ClassUnderTest.UnsecuredDebts.get(0).AccountType, 'UnsecuredDebts not set correctly');
        System.assertEquals('Underwriter', setup_data.ClassUnderTest.UnsecuredDebts.get(0).Source, 'UnsecuredDebts not set correctly');
        System.assertEquals(230.5, setup_data.ClassUnderTest.UnsecuredDebts.get(1).Total, 'UnsecuredDebts not set correctly');
        System.assertEquals(70.1, setup_data.ClassUnderTest.UnsecuredDebts.get(0).Monthly, 'UnsecuredDebts not set correctly');
        System.assertEquals(0, setup_data.ClassUnderTest.UnsecuredDebts.get(0).Index, 'UnsecuredDebts not set correctly');
    }

    static testMethod void testSettingCompanyClassOptions() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            CustomSettingInitialization.createCompanyClassOptions();
            Test.startTest();
                setup_data.ClassUnderTest.setCompanyClassOptions();
            Test.stopTest();

            System.assertEquals(CustomSettingInitialization.NEW_COMPANY_CLASS_OPTIONS.size(), setup_data.ClassUnderTest.CompanyClassOptions.size(), 'Was created wrong number of options');
        }
    }

    static testMethod void testSettingAccountTypeOption() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            StaticResourceTestData.createTestAccountTypeStaticResource();
            CustomSettingInitialization.createAccountTypeOption();
            Test.startTest();
                setup_data.ClassUnderTest.setAccountTypeOption();
            Test.stopTest();

            System.assertEquals(6, setup_data.ClassUnderTest.AccountTypeOptionUnsecuredDebts.size(), 'Was created wrong number of options');
            System.assertEquals('Bank Default', setup_data.ClassUnderTest.AccountTypeOptionUnsecuredDebts.get(0).getLabel(), 'Order is not correct');
            System.assertEquals('Fixed Term', setup_data.ClassUnderTest.AccountTypeOptionUnsecuredDebts.get(1).getLabel(), 'Order is not correct');
            System.assertEquals(5, setup_data.ClassUnderTest.AccountTypeOptionRollingCredit.size(), 'Was created wrong number of options');
            System.assertEquals('Budget Card', setup_data.ClassUnderTest.AccountTypeOptionRollingCredit.get(0).getLabel(), 'Order is not correct');
            System.assertEquals('Charge Card', setup_data.ClassUnderTest.AccountTypeOptionRollingCredit.get(1).getLabel(), 'Order is not correct');
        }
    }

    private class SetupDataClass {
        public AffordabilityDetailsController ClassUnderTest;
        public User TestUser;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'AffordabilityDetailsControllerTest' AND LastName = 'AffordabilityDetailsControllerTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id, Loan_ID__c FROM Loan_Application__c LIMIT 1];
            CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save();
            Apexpages.currentpage().getparameters().put('id', TestLoanApplication.Id);
        }

        public void initClassUnderTest() {
            ClassUnderTest = new AffordabilityDetailsController();
            ClassUnderTest.LoanAppId = 'TestLoanExtId';
        }

        public void initClassUnderTestWithStandardController() {
            ApexPages.StandardController loan_std_controller = new ApexPages.StandardController(TestLoanApplication);
            ClassUnderTest = new AffordabilityDetailsController(loan_std_controller);
        }

        public void setLoanInfoMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanInfoTestMock(is_success));
        }

        public void setCalculateAffordabilityMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCalculateAffordabilityTestMock(is_success));
        }

        public void setUpdateAffordabilityMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public List<Task> getAllTasksForLoanApplication(){
            return [SELECT Id FROM Task WHERE What.Id = :TestLoanApplication.Id];
        }
    }

    @testSetup static void createAndInsertTestData() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                                     .setFirstName('AffordabilityDetailsControllerTest')
                                     .setLastName('AffordabilityDetailsControllerTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            FeatureSwitch.disable('ZOPA-4');
            Account test_account = AccountBuilder.getBuilder('AffordabilityDetailsControllerTest').save().getRecord();
            LoanApplicationBuilder.getBuilder(test_account).setExternalId('TestLoanExtId').save();
        }
    }
}