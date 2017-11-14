@isTest
private class BatchUpdateCaseAssignmentsTest {
    public static final Integer BULK_SIZE = 200;

    static testMethod void testConstructorOfBatchUpdateCaseAssignments() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
            setup_data.initClassUnderTestWithUnderwritingMode();
            Test.stopTest();

            System.assertEquals(
                    CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_CASE_PREP),
                    setup_data.ClassUnderTest.CasePrepDmlOption.AssignmentRuleHeader.assignmentRuleId,
                    'Should fit Case Prep assignment rule.'
            );
            System.assertEquals(
                    CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_FRAUD),
                    setup_data.ClassUnderTest.FraudDmlOption.AssignmentRuleHeader.assignmentRuleId,
                    'Should fit Fraud assignment rule.'
            );
            System.assertEquals(
                    CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_UNDERWRITER),
                    setup_data.ClassUnderTest.UnderwriterDmlOption.AssignmentRuleHeader.assignmentRuleId,
                    'Should fit Underwriter assignment rule.'
            );
            System.assertEquals(
                    CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_COLLECTIONS),
                    setup_data.ClassUnderTest.CollectionsDmlOption.AssignmentRuleHeader.assignmentRuleId,
                    'Should fit Collections assignment rule.'
            );
            System.assertEquals(
                    CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_RECOVERIES),
                    setup_data.ClassUnderTest.RecoveriesDmlOption.AssignmentRuleHeader.assignmentRuleId,
                    'Should fit Recoveries assignment rule.'
            );
            System.assertEquals(
                    CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_SENSITIVE),
                    setup_data.ClassUnderTest.SensitiveDmlOption.AssignmentRuleHeader.assignmentRuleId,
                    'Should fit Sensitive assignment rule.'
            );
            System.assertEquals(BatchUpdateCaseAssignments.JobMode.UNDERWRITING, setup_data.ClassUnderTest.CurrentJobMode, 'Should be set as UNDERWRITING JobMode.');
            System.assertNotEquals(null, setup_data.ClassUnderTest.QueueIds, 'Should init value.');
        }
    }

    static testMethod void testBatchUpdateCaseAssignmentsInUnderwritingModeWithCasePrepQueueOwner() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.initClassUnderTestWithUnderwritingMode();
            setup_data.createManualUnderwritingCases(CaseUtility.QueueName.CASE_PREP_PRIORITY1);

            Test.startTest();
            Database.executeBatch(setup_data.ClassUnderTest);
            Test.stopTest();

            for (Case updated_case : setup_data.reQueryCases()) {
                System.assertNotEquals(setup_data.TestCases.get(updated_case.Id).OwnerId, updated_case.OwnerId, 'Should change owner.');
            }
        }
    }

    static testMethod void testBatchUpdateCaseAssignmentsInUnderwritingModeWithUnderwriterQueueOwner() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.initClassUnderTestWithUnderwritingMode();
            setup_data.createManualUnderwritingCases(CaseUtility.QueueName.UNDERWRITER_PRIORITY1);

            Test.startTest();
            Database.executeBatch(setup_data.ClassUnderTest);
            Test.stopTest();

            for (Case updated_case : setup_data.reQueryCases()) {
                System.assertNotEquals(setup_data.TestCases.get(updated_case.Id).OwnerId, updated_case.OwnerId, 'Should change owner.');
            }
        }
    }

    static testMethod void testBatchUpdateCaseAssignmentsInCollectionsModeWithUnderwriterQueueOwner() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.initClassUnderTestWithCollectionsMode();
            setup_data.createManualUnderwritingCases(CaseUtility.QueueName.UNDERWRITER_PRIORITY1);

            Test.startTest();
            Database.executeBatch(setup_data.ClassUnderTest);
            Test.stopTest();

            for (Case updated_case : setup_data.reQueryCases()) {
                System.assertEquals(setup_data.TestCases.get(updated_case.Id).OwnerId, updated_case.OwnerId, 'Should not change owner.');
            }
        }
    }

    private class SetupDataClass {
        public BatchUpdateCaseAssignments ClassUnderTest;
        public User TestUser;
        public Account TestAccount;
        public Map<Id, Case> TestCases;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' LIMIT 1];
        }

        public void createTestAccount() {
            TestAccount = AccountBuilder.getBuilder('TestAccountName').save().getRecord();
        }

        public void initClassUnderTestWithUnderwritingMode() {
            initClassUnderTest(BatchUpdateCaseAssignments.JobMode.UNDERWRITING);
        }

        public void initClassUnderTestWithCollectionsMode() {
            initClassUnderTest(BatchUpdateCaseAssignments.JobMode.COLLECTIONS);
        }

        private void initClassUnderTest(BatchUpdateCaseAssignments.JobMode job_mode) {
            ClassUnderTest = new BatchUpdateCaseAssignments(job_mode);
        }

        public void createManualUnderwritingCases(CaseUtility.QueueName queue_name) {
            Id queue_id = CaseUtility.getInstance().getQueueIdFromName(queue_name);
            List<Case> cases = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                    .setOwner(queue_id)
                    .setSubject('Manual Underwriting')
                    .getRecordList(BULK_SIZE);
            insert cases;
            TestCases = new Map<Id, Case>(cases);
        }

        private List<Case> reQueryCases() {
            return [SELECT RecordTypeId, Status, OwnerId FROM Case WHERE Id = :TestCases.keySet()];
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('TestLastName')
                .save()
                .getRecord();
    }
}