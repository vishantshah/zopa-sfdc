@isTest
private class CallCreditDetailsViewControllerTest {

    static testMethod void testStandardConstructorSetsLoanId() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(setup_data.TestLoanApplication.Id, setup_data.ClassUnderTest.LoanRecordId, 'LoanRecordId is not set correctly');
            System.assertEquals('TestLoanExtId', setup_data.ClassUnderTest.LoanAppId, 'Loan Id is not set correctly');
            System.assertEquals(false, setup_data.ClassUnderTest.LazyLoadFinished, 'LazyLoadFinished is not set correctly');
        }
    }

    static testMethod void testGoToLoanApplication() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                PageReference actual_page = setup_data.ClassUnderTest.goToLoanApplication();
            Test.stopTest();
            ApexPages.StandardController loan_std_controller = new ApexPages.StandardController(setup_data.TestLoanApplication);
            PageReference expected_page = loan_std_controller.view();
            System.assertEquals(expected_page.getUrl(), actual_page.getUrl(), 'Got the wrong redirect URL');
        }
    }

    static testMethod void testGetCallCreditDetailsSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getCallCreditDetails();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.LazyLoadFinished, 'LazyLoadFinished is not set correctly');
            System.assertEquals(102728, setup_data.ClassUnderTest.CallCredit.ApplicantSummary.TotalBalancesActive, 'TotalBalancesActive is not set correctly');
            System.assertEquals(2663, setup_data.ClassUnderTest.CallCredit.ApplicantSummary.TotalBalancesLoans, 'TotalBalancesLoans is not set correctly');
            System.assertEquals(100065, setup_data.ClassUnderTest.CallCredit.ApplicantSummary.TotalBalancesMortgages, 'TotalBalancesMortgages is not set correctly');
            System.assertEquals(10034, setup_data.ClassUnderTest.CallCredit.ApplicantSummary.TotalBalancesRevolve, 'TotalBalancesRevolve is not set correctly');
            System.assertEquals(123, setup_data.ClassUnderTest.CallCredit.ApplicantSummary.TotalLimitsRevolve, 'TotalLimitsRevolve is not set correctly');
            System.assertEquals(123, setup_data.ClassUnderTest.CallCredit.ApplicantSummary.BalanceLimitRatioRevolve, 'BalanceLimitRatioRevolve is not set correctly');
            System.assertEquals(1, setup_data.ClassUnderTest.CallCredit.SummaryAddresses.size(), 'SummaryAddresses is not set correctly');
            System.assertEquals(true, setup_data.ClassUnderTest.CallCredit.SummaryAddresses.get(0).Current, 'Current is not set correctly');
            System.assertEquals('123 my street, some town, PO5 4CD', setup_data.ClassUnderTest.CallCredit.SummaryAddresses.get(0).Address, 'Address is not set correctly');
            System.assertEquals('Individual', setup_data.ClassUnderTest.CallCredit.SummaryAddresses.get(0).Level, 'Level is not set correctly');
            System.assertEquals('Electoral Roll', setup_data.ClassUnderTest.CallCredit.SummaryAddresses.get(0).Source, 'Source is not set correctly');
            System.assertEquals('12/2015 to date', setup_data.ClassUnderTest.CallCredit.ApplicantsCurrentAddressElectoralRoll.get(0).Duration, 'Duration is not set correctly');
            System.assertEquals(true, setup_data.ClassUnderTest.CallCredit.IsIndividualReport, 'IsIndividualReport is not set correctly');
            System.assertEquals(null, setup_data.ClassUnderTest.CallCredit.UnsettledShareAccounts, 'UnsettledShareAccounts is not set correctly');
            System.assertEquals('Bank', setup_data.ClassUnderTest.CallCredit.AssociateLinks.get(0).SupplierType, 'SupplierType is not set correctly');
            System.assertEquals('2012-10-31T00:00:00', setup_data.ClassUnderTest.CallCredit.AssociateLinks.get(0).LastConfirmationDate, 'LastConfirmationDate is not set correctly');
            System.assertEquals('2012-10-31T00:00:00', setup_data.ClassUnderTest.CallCredit.AssociateLinks.get(0).EarliestConfirmationDate, 'EarliestConfirmationDate is not set correctly');
        }
    }

    static testMethod void testGetCallCreditDetailsNotSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getCallCreditDetails();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.LazyLoadFinished, 'LazyLoadFinished is not set correctly');
            System.assert(MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'), 'Expected to have an error message on the page');
        }
    }


    private class SetupDataClass {
        public CallCreditDetailsViewController ClassUnderTest;
        public User TestUser;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'CallCreditDetailsViewControllerTest' AND LastName = 'CallCreditDetailsViewControllerTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id, Loan_ID__c FROM Loan_Application__c LIMIT 1];
            Apexpages.currentpage().getparameters().put('id', TestLoanApplication.Id);
        }

        public void initClassUnderTest() {
            ApexPages.StandardController loan_std_controller = new ApexPages.StandardController(TestLoanApplication);
            ClassUnderTest = new CallCreditDetailsViewController(loan_std_controller);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanCallCreditTestMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                                     .setFirstName('CallCreditDetailsViewControllerTest')
                                     .setLastName('CallCreditDetailsViewControllerTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('CallCreditDetailsViewControllerTest').save().getRecord();
            LoanApplicationBuilder.getBuilder(test_account).setExternalId('TestLoanExtId').save();
        }
    }
}