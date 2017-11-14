@isTest public class LoanAppViewExtensionTest {
    private static final String CASE_PREP_USER = 'CaseViewCasePrep';

    static testMethod void testGetIsZopa80IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-80');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getFeatureSwitch80Enabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa80IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-80');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getFeatureSwitch80Enabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be true');
        }
    }

    static testMethod void testGetShowCancelDeclineReasonFieldWhenReasonAndStatusIsBlank(){
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createDataForCase();
            setup_data.initController();
            setup_data.TestLoanApplication.Cancel_Decline_Reason__c = '';
            Test.startTest();
                Boolean is_true = setup_data.ClassUnderTest.getShowCancelDeclineReasonField();
            Test.stopTest();
            System.assertEquals(false, is_true, 'Result should be false if CancelDeclineReason is empty');
        }
    }

    static testMethod void testGetShowCancelDeclineReasonFieldWhenReasonFilledAndStatusIsDeclined(){
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createDataForCase();
            setup_data.initController();
            setup_data.TestLoanApplication.Cancel_Decline_Reason__c = 'test reason';
            setup_data.TestLoanApplication.Loan_Application_Status__c = 'Declined';
            Test.startTest();
                Boolean is_true = setup_data.ClassUnderTest.getShowCancelDeclineReasonField();
            Test.stopTest();
            System.assertEquals(true, is_true, 'Result should be true if CancelDeclineReason is filled and Status is declined');
        }
    }

    static testMethod void testGetShowCancelDeclineReasonFieldWhenReasonFilledAndStatusIsCancelled(){
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createDataForCase();
            setup_data.initController();
            setup_data.TestLoanApplication.Cancel_Decline_Reason__c = 'test reason';
            setup_data.TestLoanApplication.Loan_Application_Status__c = 'Cancelled';
            Test.startTest();
                Boolean is_true = setup_data.ClassUnderTest.getShowCancelDeclineReasonField();
            Test.stopTest();
            System.assertEquals(true, is_true, 'Result should be true if CancelDeclineReason is filled and Status is cancelled');
        }
    }

    static testMethod void testGetShowCancelDeclineReasonFieldWhenReasonAndStatusIsBlankAndStatusIsDeclined(){
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createDataForCase();
            setup_data.initController();
            setup_data.TestLoanApplication.Cancel_Decline_Reason__c = '';
            setup_data.TestLoanApplication.Loan_Application_Status__c = 'Declined';
            Test.startTest();
                Boolean is_true = setup_data.ClassUnderTest.getShowCancelDeclineReasonField();
            Test.stopTest();
            System.assertEquals(false, is_true, 'Result should be false if CancelDeclineReason is empty');
        }
    }

    static testMethod void testGetIdLoanApplicationCaseFSEnable(){
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZCP-212');
        System.runAs(setup_data.TestUser){
            setup_data.createDataForCase();
            setup_data.initController();
            Test.startTest();
                Id id_of_loan_app_case = setup_data.ClassUnderTest.getIdLoanApplicationCase();
            Test.stopTest();
            System.assertEquals(setup_data.TestCase.Id, id_of_loan_app_case, 'Return Id should be equal TestCase.Id');
        }
    }

    static testMethod void testGetIdLoanApplicationCaseFSDisable(){
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZCP-212');
        System.runAs(setup_data.TestUser){
            setup_data.createDataForCase();
            setup_data.initController();
            Test.startTest();
                Id id_of_loan_app_case = setup_data.ClassUnderTest.getIdLoanApplicationCase();
            Test.stopTest();
            System.assertEquals(setup_data.TestCase.Id, id_of_loan_app_case, 'Return Id should be equal TestCase.Id');
        }
    }

    static testMethod void testGetIdLoanApplicationCaseWithoutCasesFSEnable(){
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZCP-212');
        System.runAs(setup_data.TestUser){
            setup_data.createLoanApplication();
            setup_data.initController();
            Test.startTest();
                Id id_of_loan_app_case = setup_data.ClassUnderTest.getIdLoanApplicationCase();
            Test.stopTest();
            System.assertEquals(null, id_of_loan_app_case, 'Should returned null. Erorrs should not arise.');
        }
    }

    static testMethod void testGetIdLoanApplicationCaseWithoutCasesFSDisable(){
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZCP-212');
        System.runAs(setup_data.TestUser){
            setup_data.createLoanApplication();
            setup_data.initController();
            Boolean is_error = false;
            Test.startTest();
                try {
                    Id id_of_loan_app_case = setup_data.ClassUnderTest.getIdLoanApplicationCase();
                } catch (Exception e){
                    is_error = true;
                }
            Test.stopTest();
            System.assertEquals(true, is_error, 'Should got an error when FS is disable');
        }
    }

    private class SetupDataClass {
        public Loan_Application__c TestLoanApplication;
        public Account TestAccount;
        public Case TestCase;
        public User TestUser;
        public User AssignedToUser;
        public LoanAppViewExtension ClassUnderTest;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        private void createDataForCase() {
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('CaseManualUnderwriterExtension').save().getRecord();

            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount)
                .setExpiryDate(System.now()).setExternalId(Utility.getRandomString(8)).save().getRecord();

            TestCase = CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication)
                .setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).setStatus('Open').setOrigin('Web').save().getRecord();

            TriggerHandler.IsTriggerActive = true;
        }

        public void createLoanApplication(){
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('CaseManualUnderwriterExtension').save().getRecord();
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount)
                .setExpiryDate(System.now()).setExternalId(Utility.getRandomString(8)).save().getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void initController() {
            ClassUnderTest = new LoanAppViewExtension(new ApexPages.StandardController(TestLoanApplication));
        }

        public String getExpectedUrlForCustomerAccount() {
            return new PageReference('/'+TestAccount.id).getUrl();
        }

        public String getExpectedUrlForLoanApplication() {
            return new PageReference('/apex/LoanApplicationView?id=' + TestLoanApplication.id).getUrl();
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setLastName(CASE_PREP_USER)
                                     .save();
    }
}