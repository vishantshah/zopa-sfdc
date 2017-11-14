@isTest
private class EquifaxDetailsViewControllerTest {

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

    static testMethod void testGetEquifaxDetailsSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getEquifaxDetails();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.LazyLoadFinished, 'LazyLoadFinished is not set correctly');
            System.assertEquals(2, setup_data.ClassUnderTest.Equifax.ApplicantCreditChecks.size(), 'ApplicantCreditChecks is not set correctly');
            System.assertEquals('123 my street, some town, PO5 4CD', setup_data.ClassUnderTest.Equifax.ApplicantCreditChecks.get(0).Address, 'Address is not set correctly');
            System.assertEquals('76 Trombones Road, Bristol, BS94EZ', setup_data.ClassUnderTest.Equifax.ApplicantCreditChecks.get(1).Address, 'Address is not set correctly');
            System.assertEquals(2, setup_data.ClassUnderTest.Equifax.ApplicantCreditChecks.get(0).Insights.size(), 'Insights is not set correctly');
            System.assertEquals('Mr Adam Test', setup_data.ClassUnderTest.Equifax.ApplicantCreditChecks.get(0).Insights.get(0).Name, 'Name is not set correctly');
            System.assertEquals(1, setup_data.ClassUnderTest.Equifax.AssociatedCreditChecks.size(), 'AssociatedCreditChecks is not set correctly');
            System.assertEquals('123 my street, some town, PO5 4CD', setup_data.ClassUnderTest.Equifax.AssociatedCreditChecks.get(0).Address, 'Address is not set correctly');
            System.assertEquals(1, setup_data.ClassUnderTest.Equifax.FamilyCreditChecks.size(), 'FamilyCreditChecks is not set correctly');
            System.assertEquals('123 my street, some town, PO5 4CD', setup_data.ClassUnderTest.Equifax.FamilyCreditChecks.get(0).Address, 'Address is not set correctly');
            System.assertEquals('Fixed Term', setup_data.ClassUnderTest.Equifax.FamilyCreditChecks.get(0).Insights.get(0).AccountType, 'AccountType is not set correctly');
            System.assertEquals('36 over 10M', setup_data.ClassUnderTest.Equifax.FamilyCreditChecks.get(0).Insights.get(0).Terms, 'Terms is not set correctly');
            System.assertEquals(1, setup_data.ClassUnderTest.Equifax.OtherCreditChecks.size(), 'OtherCreditChecks is not set correctly');
            System.assertEquals('76 Trombones Road, Bristol, BS94EZ', setup_data.ClassUnderTest.Equifax.OtherCreditChecks.get(0).Address, 'Address is not set correctly');
            System.assertEquals('2011-11-23T00:00:00', setup_data.ClassUnderTest.Equifax.OtherCreditChecks.get(0).Insights.get(0).DelinquentDate, 'DelinquentDate is not set correctly');
            System.assertEquals('A', setup_data.ClassUnderTest.Equifax.OtherCreditChecks.get(0).Insights.get(0).Flags, 'Flags is not set correctly');
        }
    }

    static testMethod void testGetEquifaxDetailsNotSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getEquifaxDetails();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.LazyLoadFinished, 'LazyLoadFinished is not set correctly');
            System.assert(MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'), 'Expected to have an error message on the page');
        }
    }


    private class SetupDataClass {
        public EquifaxDetailsViewController ClassUnderTest;
        public User TestUser;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'EquifaxDetailsViewControllerTest' AND LastName = 'EquifaxDetailsViewControllerTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id, Loan_ID__c FROM Loan_Application__c LIMIT 1];
            Apexpages.currentpage().getparameters().put('id', TestLoanApplication.Id);
        }

        public void initClassUnderTest() {
            ApexPages.StandardController loan_std_controller = new ApexPages.StandardController(TestLoanApplication);
            ClassUnderTest = new EquifaxDetailsViewController(loan_std_controller);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanEquifaxTestMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                                     .setFirstName('EquifaxDetailsViewControllerTest')
                                     .setLastName('EquifaxDetailsViewControllerTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('EquifaxDetailsViewControllerTest').save().getRecord();
            LoanApplicationBuilder.getBuilder(test_account).setExternalId('TestLoanExtId').save();
        }
    }
}