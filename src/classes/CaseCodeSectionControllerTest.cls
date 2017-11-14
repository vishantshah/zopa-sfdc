@isTest
public class CaseCodeSectionControllerTest{

    private static final String LOAN_RC_CODES = 'RC_02;RC_03';
    private static final String CASE_CONFIGURATION_CODE_NAME = 'RC_02';
    private static final String CASE_CONFIGURATION_REASON = 'Triggered';
    private static final String CASE_CONFIGURATION_DESCRIPTION = 'Test Description';
    private static final String CASE_CONFIGURATION_TASK_SUBJECT = 'Task Subject';
    private static final String CASE_CONFIGURATION_TASK_DESCRIPTION = 'Task Description';
    private static final String CASE_CONFIGURATION_TASK_TASK_FOR = 'Underwriter';

    static testMethod void testCaseCodeSectionInitComponentAttributeAsCasePrepUser(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser)
        {
            setup_data.createReferralCodes();
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assert(setup_data.ClassUnderTest.CaseCodesWithCaseConfigurationDescription.size()==0, 'List should be initialized with no elements');
        }
    }

    static testMethod void testCaseCodeSectionInitComponentAttributeCasePrepUserCanSeeRelatedCaseConfigurations(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser)
        {
            setup_data.createReferralCodes();
            setup_data.createLoanApplicationWithCaseCodes();
            setup_data.createCaseConfigurationWithCaseConfigurationTask();
            setup_data.createCaseWithParentLoanApplication();
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assert(setup_data.ClassUnderTest.CaseCodesWithCaseConfigurationDescription.size()==1, 'List should have a Case Configuration');
            for(CaseCodeSectionController.CaseCodeWrapper singleWrapper : setup_data.ClassUnderTest.CaseCodesWithCaseConfigurationDescription)
            {
                System.assertEquals(CASE_CONFIGURATION_CODE_NAME, singleWrapper.CodeName, 'RC Code not set correctly');
                System.assertEquals(CASE_CONFIGURATION_REASON, singleWrapper.CodeReason, 'RC Code reason not set correctly');
                System.assertEquals(CASE_CONFIGURATION_DESCRIPTION, singleWrapper.CodeDescription, 'RC Code Description not set correctly');
            }
        }
    }

    private class SetupDataClass{
        public CaseCodeSectionController ClassUnderTest;
        public User TestUser;
        public String ReferralCodes;
        public Account LoanApplicationAccount;
        public Loan_Application__c LoanApplication;
        public Case_Configuration__c CaseConfiguration;
        public Case_Configuration_Task__c CaseConfigurationTask;
        public Case CaseWithParentLoanApplication;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'CaseCodeSectionController' LIMIT 1];
        }

        public void initComponent() {
            ClassUnderTest = new CaseCodeSectionController();
            ClassUnderTest.IncomingTriggeredReferralCodes = ReferralCodes;
        }

        public void createReferralCodes(){
            ReferralCodes = LOAN_RC_CODES;
        }

        public void createLoanApplicationWithCaseCodes(){
            LoanApplicationAccount = AccountBuilder.getBuilder('loan application account')
                                                    .save()
                                                    .getRecord();
            LoanApplication = LoanApplicationBuilder.getBuilder(LoanApplicationAccount)
                                                    .setApplicationName('test loan application')
                                                    .setTriggeredReferralCodes(ReferralCodes)
                                                    .save()
                                                    .getRecord();
        }

        public void createCaseConfigurationWithCaseConfigurationTask(){
            CaseConfiguration = CaseConfigurationBuilder.getBuilder()
                                                    .setName(CASE_CONFIGURATION_CODE_NAME)
                                                    .setCodeDescription(CASE_CONFIGURATION_DESCRIPTION)
                                                    .save()
                                                    .getRecord();
            CaseConfigurationTask = CaseConfigurationTaskBuilder.getBuilder(CaseConfiguration)
                                                    .setTaskSubject(CASE_CONFIGURATION_TASK_SUBJECT)
                                                    .setTaskDescription(CASE_CONFIGURATION_TASK_DESCRIPTION)
                                                    .setTaskFor(CASE_CONFIGURATION_TASK_TASK_FOR)
                                                    .save()
                                                    .getRecord();
        }

        public void createCaseWithParentLoanApplication(){
            CaseWithParentLoanApplication = CaseBuilder.getBuilder(LoanApplicationAccount).save().getRecord();
        }
    }

    @testSetup
    static void setupTestUser(){
    UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                 .setFirstName('CaseCodeSectionController'+Utility.getRandomInteger())
                                 .setLastName('CaseCodeSectionController')
                                 .save();
    }
}