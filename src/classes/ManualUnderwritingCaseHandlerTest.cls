@isTest
private class ManualUnderwritingCaseHandlerTest {

    static testMethod void testCreateManualUnderwitingCaseForNewLoanCreatesOpenCaseIfCaseCodesIsNotBlank() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createLoanWithCaseCodes('triggered_code;', 'aborted_code;');
            Test.startTest();
                setup_data.ClassUnderTest.createManualUnderwitingCaseForNewLoan(setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpsert.size(), 'Should create one case');
            System.assertEquals('Open', setup_data.ClassUnderTest.AllCasesToUpsert.get(0).Status, 'Should be open');
            System.assertEquals('Web', setup_data.ClassUnderTest.AllCasesToUpsert.get(0).Origin, 'Should be Web');
            System.assertEquals('triggered_code;', setup_data.ClassUnderTest.AllCasesToUpsert.get(0).Triggered_Referral_Codes__c, 'Should populate field');
            System.assertEquals('aborted_code;', setup_data.ClassUnderTest.AllCasesToUpsert.get(0).Aborted_Referral_Codes__c, 'Should populate field');
            System.assertEquals('triggered_code;aborted_code;', setup_data.ClassUnderTest.AllCasesToUpsert.get(0).All_Referral_Codes__c, 'Should populate field');
            System.assertEquals(setup_data.TestLoanApplication.Id, setup_data.ClassUnderTest.AllCasesToUpsert.get(0).Loan_Application__c, 'Should be linked to correct Loan');
            System.assertEquals(setup_data.TestAccount.Id, setup_data.ClassUnderTest.AllCasesToUpsert.get(0).AccountId, 'Should be linked to correct Account');
            System.assertEquals(RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING), setup_data.ClassUnderTest.AllCasesToUpsert.get(0).RecordTypeId, 'Should be underwriting case');
        }
    }

    static testMethod void testCreatesManualUnderwitingCaseForNewLoanCreatesClosedCaseIfCaseCodesIsBlank() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createLoanWithoutCaseCodes();
            Test.startTest();
                setup_data.ClassUnderTest.createManualUnderwitingCaseForNewLoan(setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpsert.size(), 'Should create one case');
            System.assertEquals('Open', setup_data.ClassUnderTest.AllCasesToUpsert.get(0).Status, 'Should be closed');
            System.assertEquals('Web', setup_data.ClassUnderTest.AllCasesToUpsert.get(0).Origin, 'Should be Web');
            System.assertEquals(setup_data.TestLoanApplication.Id, setup_data.ClassUnderTest.AllCasesToUpsert.get(0).Loan_Application__c, 'Should be linked to correct Loan');
            System.assertEquals(setup_data.TestAccount.Id, setup_data.ClassUnderTest.AllCasesToUpsert.get(0).AccountId, 'Should be linked to correct Account');
            System.assertEquals(RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING), setup_data.ClassUnderTest.AllCasesToUpsert.get(0).RecordTypeId, 'Should be underwriting case');
        }
    }

    static testMethod void testCreateLoanWithAutoRequiresManualUnderwritingStatus() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createLoanWithAutoRequiresManualUnderwritingStatus();
            Test.startTest();
                setup_data.ClassUnderTest.createManualUnderwitingCaseForNewLoan(setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpsert.size(), 'Case should be created');
        }
    }

    static testMethod void testCreateLoanWithNotAutoRequiresManualUnderwritingStatus() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createLoanWithOtherStatus();
            Test.startTest();
                setup_data.ClassUnderTest.createManualUnderwitingCaseForNewLoan(setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpsert.size(), 'Case should not be created');
        }
    }

    static testMethod void testUpsertAllCasesWithOneRecord() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createCase();
            setup_data.ClassUnderTest.AllCasesToUpsert.add(setup_data.TestCase);
            Test.startTest();
                Integer dml_operations = -Limits.getDMLRows();
                setup_data.ClassUnderTest.upsertAllCases();
                dml_operations += Limits.getDMLRows();
            Test.stopTest();
            System.assertEquals(1, dml_operations, 'Should process one dml');
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpsert.size(), 'Should clear List');
        }
    }

    static testMethod void testUpsertAllCasesWithNoRecords() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Integer dml_operations = -Limits.getDMLRows();
                setup_data.ClassUnderTest.upsertAllCases();
                dml_operations += Limits.getDMLRows();
            Test.stopTest();
            System.assertEquals(0, dml_operations, 'Should process one dml');
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpsert.size(), 'Should clear List');
        }
    }

    static testMethod void testCaseIsTakenOutOfTheQueueIfPickedUpInAdminSystem() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createLoanWithAutoRequiresManualUnderwritingStatus();
            Test.startTest();
                setup_data.TestLoanApplication.Picked_Up_In_Underwriting_Web__c = true;
                update setup_data.TestLoanApplication;
            Test.stopTest();

            setup_data.queryCase();
            System.assertEquals(setup_data.TestUser.Id, setup_data.TestCase.OwnerId, 'Case should have been reassigned to the user');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public User TestUser;
        public ManualUnderwritingCaseHandler ClassUnderTest;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'ManualUnderwritingCaseHandlerTest' AND FirstName = 'ManualUnderwritingCaseHandlerTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = ManualUnderwritingCaseHandler.getInstance();
        }

        public void createLoanWithoutCaseCodes() {
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('RequiresManualUnderwriting').save().getRecord();
            queryCase();
        }

        public void createLoanWithAutoRequiresManualUnderwritingStatus(){
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('RequiresManualUnderwriting').save().getRecord();
        }

        public void createLoanWithOtherStatus(){
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('Test').save().getRecord();
        }

        public void createLoanWithCaseCodes(String triggered_code, String aborted_code) {
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('RequiresManualUnderwriting').setTriggeredReferralCodes(triggered_code).setAbortedReferralCodes(aborted_code).save().getRecord();
            queryCase();
        }

        public void createCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).getRecord();
        }

        public void queryCase() {
            TestCase = [SELECT OwnerId,Status FROM Case WHERE Loan_Application__c = :TestLoanApplication.Id AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING) LIMIT 1];
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ManualUnderwritingCaseHandlerTest')
                                     .setLastName('ManualUnderwritingCaseHandlerTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('ManualUnderwritingCaseHandlerTest').save().getRecord();
        }
    }
}