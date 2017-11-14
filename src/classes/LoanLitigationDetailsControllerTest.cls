@isTest
private class LoanLitigationDetailsControllerTest {

    static testMethod void testGetIsZcp60IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-60');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp60IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be true');
        }
    }

    static testMethod void testGetIsZcp60IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-60');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp60IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetEpmtyLitigationDetails() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false,400);
            Test.startTest();
                setup_data.ClassUnderTest.getLitigationDetails();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentLoanLitigationDetails, 'Result should have records');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: Internal Error'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testGetEpmtyLitigationDetailsError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false,404);
            Test.startTest();
                setup_data.ClassUnderTest.getLitigationDetails();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentLoanLitigationDetails, 'Result should have records');
            System.assertEquals(new ApexPages.Message(ApexPages.Severity.INFO, 'No Litigation details found for this loan'), ApexPages.getMessages()[0]);
        }
    }

    static testMethod void testGetLitigationDetails() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, 200);
            Test.startTest();
                setup_data.ClassUnderTest.getLitigationDetails();
            Test.stopTest();
            System.assertNotEquals(null, setup_data.ClassUnderTest.CurrentLoanLitigationDetails, 'Result should have records');
        }
    }

    static testMethod void testGetIsAccessToLitigationDetailsBlock() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-60');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Recoveries');
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsAccessToLitigationDetailsBlock();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Litigation details block should be available');
        }
    }

    static testMethod void testGetIsAccessToLitigationDetailsBlockIncorrect() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-60');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('test');
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsAccessToLitigationDetailsBlock();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Litigation details block should not be available');
        }
    }

    static testMethod void testGetIsRecoveriesCaseProcess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Recoveries');
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsRecoveriesCaseProcess();
            Test.stopTest();
            System.assertEquals(true, result, 'Case process should be Recoveries');
        }
    }

    static testMethod void testGetIsRecoveriesCaseProcessIncorrect() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('test');
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsRecoveriesCaseProcess();
            Test.stopTest();
            System.assertEquals(false, result, 'Case process should not be Recoveries');
        }
    }

    static testMethod void testGetIsRecoveriesCaseProcessIncorrectWithoutCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsRecoveriesCaseProcess();
            Test.stopTest();
            System.assertEquals(false, result, 'Case process should false, when Loan have not related Case');
        }
    }

    private class SetupDataClass {
        public LoanLitigationDetailsController ClassUnderTest;
        public User TestUser;
        public Case TestCase;
        public Account TestAccount;
        public Loan__c TestLoan;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'LoanLitigationDetailsControllerTest' AND LastName = 'LoanLitigationDetailsControllerTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new LoanLitigationDetailsController();
            if (TestLoan != null) {
                ClassUnderTest.LoanId = TestLoan.Id;
            } else {
                ClassUnderTest.LoanId = 'test_id';
            }
            ClassUnderTest.LoanUuid = 'test_uuid';
        }

        public void setMockForResponse(Boolean is_success, Integer error_code) {
            Test.setMock(HttpCalloutMock.class, new LoanLitigationDetailsMock(is_success, error_code));
        }

        public void createCollectionsRecoveriesCase(String process) {
            createDataForCase();
            createLoan();
            TestCase = CaseBuilder.getBuilder(TestAccount).setProcess(process).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setLoan(TestLoan).save().getRecord();
        }

        private void createDataForCase() {
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('CaseCollectionsRecoveriesExtension').save().getRecord();
            TestLoan = LoanBuilder.getBuilder(TestAccount).setExternalId('test').save().getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void createLoan(){
            TestLoan = LoanBuilder.getBuilder(TestAccount).setExternalId(Utility.getRandomString(8)).save().getRecord();
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('LoanLitigationDetailsControllerTest')
                                     .setLastName('LoanLitigationDetailsControllerTest')
                                     .save();
    }
}