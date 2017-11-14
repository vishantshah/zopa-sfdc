@IsTest
private class LoanDetailsViewControllerTest {

    @IsTest
    static void testInitClass() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanApplication();
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
            setup_data.createLoanApplication();
            setup_data.initClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.CurrentLoanId = setup_data.TestLoan.Id;
            Test.stopTest();
            System.assertEquals(setup_data.TestLoan.Loan_Id__c, setup_data.ClassUnderTest.CurrentLoan.Loan_Id__c, 'Loan was queried incorrect');
            System.assertEquals(setup_data.TestLoanApplication.Id, setup_data.ClassUnderTest.CurrentLoanApplication.Id, 'LoanApplication was setted incorrect');
            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentLoanId, 'LoanId was not setted');
        }
    }

    @IsTest
    static void testSettingLoanDetailsWithoutLoanApp() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.CurrentLoanId = setup_data.TestLoan.Id;
            Test.stopTest();
            System.assertEquals(setup_data.TestLoan.Loan_Id__c, setup_data.ClassUnderTest.CurrentLoan.Loan_Id__c, 'Loan was queried incorrect');
        }
    }

    @IsTest
    static void testGetIsZCP55IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-55');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanApplication();
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZCP55IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-55 should be disabled');
        }
    }

    @IsTest
    static void testGetIsZCP55IsDisabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-55');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanApplication();
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZCP55IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-55 should be disabled');
        }
    }

    @IsTest
    static void testGetIsZCP169IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-169');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanApplication();
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZCP169IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-169 should be disabled');
        }
    }

    @IsTest
    static void testGetIsZCP169IsEnabledWhenEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-169');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanApplication();
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZCP169IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-169 should be enabled');
        }
    }

    @IsTest
    static void testGetIsZCP104IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-104');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanApplication();
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZCP104IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-104 should be disabled');
        }
    }

    @IsTest
    static void testGetIsZCP104IsDisabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-104');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanApplication();
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZCP104IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-104 should be disabled');
        }
    }

    @IsTest
    static void testGetLoanDetailsInformation() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-55');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanApplication();
            setup_data.initClassUnderTest();
            setup_data.ClassUnderTest.CurrentLoanId = setup_data.TestLoan.Id;
            setup_data.setMockForResponse(true, 200);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanDetailsInformation();
            Test.stopTest();
            System.assertEquals(0.0, setup_data.ClassUnderTest.LoanDetails.ArrearsBalance , 'ArrearsBalance was setted incorrect.');
            System.assertEquals(0.0, setup_data.ClassUnderTest.LoanDetails.ArrearsRatio , 'ArrearsRatio was setted incorrect.');
            System.assertEquals(12345.0, setup_data.ClassUnderTest.LoanDetails.EarlyRepaymentAmount , 'EarlyRepaymentAmount was setted incorrect.');
            System.assertEquals(0.0, setup_data.ClassUnderTest.LoanDetails.HoldingAccountBalance , 'HoldingAccountBalance was setted incorrect.');
            System.assertEquals(166.64750352, setup_data.ClassUnderTest.LoanDetails.MonthlyRepaymentAmount , 'MonthlyRepaymentAmount was setted incorrect.');
            System.assertEquals(0.0, setup_data.ClassUnderTest.LoanDetails.NextRepaymentAdjustment , 'NextRepaymentAdjustment was setted incorrect.');
            System.assertEquals(7665.78516896, setup_data.ClassUnderTest.LoanDetails.RemainingBalance , 'RemainingBalance was setted incorrect.');
            System.assertEquals(0.0, setup_data.ClassUnderTest.LoanDetails.ReplacementAmount , 'ReplacementAmount was setted incorrect.');
            System.assertEquals('Withdrawn', setup_data.ClassUnderTest.LoanDetails.State , 'State was setted incorrect.');
            System.assertEquals(7999.08016896, setup_data.ClassUnderTest.LoanDetails.TotalActualRepayableAmount , 'TotalActualRepayableAmount was setted incorrect.');
            System.assertEquals('22/02/2021', setup_data.ClassUnderTest.LoanDetails.LastRepaymentDate , 'LoanStartDate was setted incorrect.');
            System.assertEquals(22, setup_data.ClassUnderTest.LoanDetails.RepaymentDayofMonth , 'RepaymentDayofMonth was setted incorrect.');
            System.assertEquals(166.64750352, setup_data.ClassUnderTest.LoanDetails.FirstMonthRepaymentAmount , 'FirstMonthRepaymentAmount was setted incorrect.');
            System.assertEquals(0, setup_data.ClassUnderTest.LoanDetails.FirstMonthExtraDays , 'FirstMonthExtraDays was setted incorrect.');

        }
    }

    @IsTest
    static void testGetIsZCP71IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-71');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanApplication();
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZCP71IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-71 should be enabled');
        }
    }

    @IsTest
    static void testGetIsZCP71IsDisabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-71');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanApplication();
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZCP71IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-71 should be disabled');
        }
    }

    static testMethod void testGetIsDefaultReasonWhenLoanIsNull() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();

            Test.startTest();
                Boolean is_default_reason = setup_data.ClassUnderTest.getIsDefaultReason();
            Test.stopTest();

            System.assertEquals(false, is_default_reason,' Should return false because Loan is null.');
        }
    }

    static testMethod void testGetIsDefaultReasonWhenDefaultReasonFieldIsNull() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setTestLoanAsCurrentLoan();

            Test.startTest();
                Boolean is_default_reason = setup_data.ClassUnderTest.getIsDefaultReason();
            Test.stopTest();

            System.assertEquals(false, is_default_reason, 'Should return false because Default Reason field is blank.');
        }
    }

    static testMethod void testGetIsDefaultReasonWhenDefaultReasonFieldIsNotNull() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setDefaultReasonForTestLoan('Bankruptcy');
            setup_data.setTestLoanAsCurrentLoan();

            Test.startTest();
            Boolean is_default_reason = setup_data.ClassUnderTest.getIsDefaultReason();
            Test.stopTest();

            System.assertEquals(true, is_default_reason, 'Should return true because Default Reason field is not blank.');
        }
    }

    private class SetupDataClass {
        public LoanDetailsViewController ClassUnderTest;
        public User TestUser;
        public Account TestAccount;
        public Loan__c TestLoan;
        public Loan_Application__c TestLoanApplication;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'LoanDetailTest' AND LastName = 'LoanDetailTest' LIMIT 1];
            TestAccount = AccountBuilder.getBuilder('TestUser22').save().getRecord();
            createLoan();
        }

        public void initClassUnderTest() {
            ClassUnderTest = new LoanDetailsViewController();
        }

        public void setMockForResponse(Boolean is_success, Integer code) {
            Test.setMock(HttpCalloutMock.class, new LoanDetailsViewMock(is_success, code));
        }

        public void createLoan(){
            TestLoan = LoanBuilder.getBuilder(TestAccount).setExternalId(Utility.getRandomString(8)).save().getRecord();
        }

        public void setTestLoanAsCurrentLoan() {
            ClassUnderTest.CurrentLoanId = TestLoan.Id;
        }

        public void createLoanApplication(){
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('RequiresManualUnderwriting').setExpiryDate(System.now()).setExternalId(Utility.getRandomString(8)).save().getRecord();
        }

        public void setDefaultReasonForTestLoan(String default_reason){
            TestLoan.Default_Reason__c = default_reason;
            update TestLoan;
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.COLLECTIONS)
                                     .setFirstName('LoanDetailTest')
                                     .setLastName('LoanDetailTest')
                                     .save();
    }
}