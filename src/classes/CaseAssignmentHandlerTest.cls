@isTest
public class CaseAssignmentHandlerTest {
    private static final String FRAUD_USER = 'DocumentReceivedFromIntegrationFraud';
    private static final String UNDERWRITER_USER = 'DocumentReceivedFromIntegrationUnderwriting';
    private static final String TEAM_LEADER_USER = 'DocumentReceivedFromIntegrationTeamLeader';

    static testMethod void testInitVariables() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertNotEquals(null, setup_data.ClassUnderTest.AllCasesToUpdate, 'Should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.LoanIdToUnderwritingCaseToUpdate, 'Should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.CasePrepQueueIds, 'Should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.FraudQueueIds, 'Should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.UnderwriterQueueIds, 'Should be initialized');
        }
    }

    static testMethod void testQueryUnderwritingCasesForExistCase() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createCustomerCase();
            Test.startTest();
                setup_data.ClassUnderTest.queryUnderwritingCasesForOldLoan(new Map<Id, sObject>{setup_data.TestLoanApplication.Id => setup_data.TestLoanApplication});
            Test.stopTest();
            System.assertEquals(0, setup_data.ClassUnderTest.LoanIdToUnderwritingCaseToUpdate.size(), 'Should be blank');
        }
    }

    static testMethod void testUpdateManualUnderwitingCaseForLoanOwnedByQueueUnderwriter() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToUnderwriterQueue();
            setup_data.fillUnderwritingCasesForOldLoanMap(setup_data.TestLoanApplication.id, setup_data.TestCase);
            Test.startTest();
                setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should add case to update');
            System.assertNotEquals(null, setup_data.ClassUnderTest.AllCasesToUpdate[0].getOptions(), 'Should use dml option');
            System.assertEquals(CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_UNDERWRITER),
                        setup_data.ClassUnderTest.AllCasesToUpdate[0].getOptions().AssignmentRuleHeader.assignmentRuleId, 'Should use move to case prep rule');
        }
    }

    static testMethod void testUpdateManualUnderwitingCaseForLoanOwnedByQueueFraud() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToFraudQueue();
            setup_data.fillUnderwritingCasesForOldLoanMap(setup_data.TestLoanApplication.id, setup_data.TestCase);
            Test.startTest();
                setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should add case to update');
            System.assertNotEquals(null, setup_data.ClassUnderTest.AllCasesToUpdate[0].getOptions(), 'Should use dml option');
            System.assertEquals(CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_FRAUD),
                        setup_data.ClassUnderTest.AllCasesToUpdate[0].getOptions().AssignmentRuleHeader.assignmentRuleId, 'Should use move to case prep rule');
        }
    }

    static testMethod void testUpdateManualUnderwitingCaseForLoanOwnedByQueueCasePrep() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToCasePrepQueue();
            setup_data.fillUnderwritingCasesForOldLoanMap(setup_data.TestLoanApplication.id, setup_data.TestCase);
            Test.startTest();
                setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should add case to update');
            System.assertNotEquals(null, setup_data.ClassUnderTest.AllCasesToUpdate[0].getOptions(), 'Should use dml option');
            System.assertEquals(CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_CASE_PREP),
                        setup_data.ClassUnderTest.AllCasesToUpdate[0].getOptions().AssignmentRuleHeader.assignmentRuleId, 'Should use move to case prep rule');
        }
    }

    static testMethod void testUpdateManualUnderwitingCaseForLoanOwnedByUser() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToTestUser();
            Test.startTest();
                setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should not be case to update');
        }
    }

    static testMethod void testUpdateAllCases() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToUnderwriterQueue();
            setup_data.fillUnderwritingCasesForOldLoanMap(setup_data.TestLoanApplication.id, setup_data.TestCase);
            setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.startTest();
                Integer dml_operations = -Limits.getDMLRows();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.ClassUnderTest.updateAllCases();
                dml_operations += Limits.getDMLRows();
            Test.stopTest();
            System.assertEquals(2, dml_operations, 'Should 2 dml, to update all cases');
        }
    }


    private class SetupDataClass {
        public Case TestCase;
        public User TestUser;
        public CaseAssignmentHandler ClassUnderTest;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;
        public Loan_Application__c TestOldLoanApplication;

        public SetupDataClass(String last_name) {
            FeatureSwitch.disable('ZOPA-4');
            FeatureSwitch.disable('ZOPA-72');
            FeatureSwitch.disable('ZOPA-130');
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name AND FirstName = 'DocumentReceivedFromIntegrationHandTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id, Documents_Last_Updated_Date__c FROM Loan_Application__c LIMIT 1];
            TestOldLoanApplication = TestLoanApplication;
        }

        public void initClassUnderTest() {
            ClassUnderTest = CaseAssignmentHandler.getInstance();
        }

        public void createManualUnderwritingCaseAssignToUnderwriterQueue() {
            Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.UNDERWRITER_PRIORITY1);
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(queue_id).setStatus('Closed').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createManualUnderwritingCaseAssignToCasePrepQueue() {
            Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.CASE_PREP_PRIORITY1);
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(queue_id).setStatus('Closed').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createManualUnderwritingCaseAssignToFraudQueue() {
            Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.FRAUD_PRIORITY1);
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(queue_id).setStatus('Closed').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createManualUnderwritingCaseAssignToTestUser() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(TestUser.Id).setStatus('Closed').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createCustomerCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(TestUser.Id).setStatus('Closed').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_CUSTOMER).save().getRecord();
        }

        public void fillUnderwritingCasesForOldLoanMap(id loan_id, Case case_to_update) {
            ClassUnderTest.LoanIdToUnderwritingCaseToUpdate = new Map<Id, Case>{loan_id => case_to_update};
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                                     .setFirstName('DocumentReceivedFromIntegrationHandTest')
                                     .setLastName(UNDERWRITER_USER)
                                     .save();
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.FRAUD)
                                     .setFirstName('DocumentReceivedFromIntegrationHandTest')
                                     .setLastName(FRAUD_USER)
                                     .save();
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                                     .setFirstName('DocumentReceivedFromIntegrationHandTest')
                                     .setLastName(TEAM_LEADER_USER)
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('DocumentReceivedFromIntegrationHandTest').save().getRecord();
            LoanApplicationBuilder.getBuilder(test_account).save();
        }
    }
}