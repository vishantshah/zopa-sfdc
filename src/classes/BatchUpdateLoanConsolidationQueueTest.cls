@isTest
private class BatchUpdateLoanConsolidationQueueTest {
    public static final Integer BULK_SIZE = 10;

    static testMethod void testBatchUpdateLoanConsolidationQueueInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();

            Id expected_loan_consolidation_queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_LOAN_CONSOLIDATION);
            Id expected_team_leader_queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.TEAM_LEADER);
            System.assertEquals(expected_loan_consolidation_queue_id, setup_data.ClassUnderTest.LoanConsolidationQueueId, 'Got the wrong queue Id');
            System.assertEquals(expected_team_leader_queue_id, setup_data.ClassUnderTest.TeamLeaderQueueId, 'Got the wrong queue Id');
        }
    }

    static testMethod void testBatchUpdateLoanConsolidationQueueDoesntUpdateQueueOwner() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_LOAN_CONSOLIDATION);
            setup_data.createManualUnderwritingCases(queue_id);
            setup_data.setMockForResponse(true, false);
            Test.startTest();
                Database.executeBatch(setup_data.ClassUnderTest, 10);
            Test.stopTest();
            setup_data.queryCase();
            for (Case case_to_assert : setup_data.TestCases) {
                System.assertEquals(queue_id, case_to_assert.OwnerId, 'Should stay in pending loan consolidation queue');
                System.assertEquals('Pending Loan Consolidation', case_to_assert.Status, 'Status should stay pending loan consloidation');
            }
        }
    }

    static testMethod void testBatchUpdateLoanConsolidationQueueUpdateQueueOwner() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_LOAN_CONSOLIDATION);
            setup_data.createManualUnderwritingCases(queue_id);
            setup_data.setMockForResponse(true, true);
            Test.startTest();
                Database.executeBatch(setup_data.ClassUnderTest, 10);
            Test.stopTest();
            setup_data.queryCase();
            Id team_leader_queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.TEAM_LEADER);
            for (Case case_to_assert : setup_data.TestCases) {
                System.assertEquals(team_leader_queue_id, case_to_assert.OwnerId, 'Should move to team leader queue');
                System.assertEquals('Approved - Pending Admin Approval', case_to_assert.Status, 'Status should change');
            }
        }
    }

    static testMethod void testBatchUpdateLoanConsolidationCalloutError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_LOAN_CONSOLIDATION);
            setup_data.createManualUnderwritingCases(queue_id);
            setup_data.setMockForResponse(false, true);
            Test.startTest();
                Database.executeBatch(setup_data.ClassUnderTest, 10);
            Test.stopTest();
            setup_data.queryCase();
            for (Case case_to_assert : setup_data.TestCases) {
                System.assertEquals(queue_id, case_to_assert.OwnerId, 'Should stay in pending loan consolidation queue');
                System.assertEquals('Pending Loan Consolidation', case_to_assert.Status, 'Status should stay pending loan consloidation');
            }
            System.assertEquals('', setup_data.ClassUnderTest.ErrorMsgs, 'Generated the wrong ErrorMsgs');
        }
    }

    private class SetupDataClass {
        public List<Case> TestCases;
        public User TestUser;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;
        public BatchUpdateLoanConsolidationQueue ClassUnderTest;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'BatchUpdateLoanConsolidationQueueTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id, Loan_ID__c FROM Loan_Application__c LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new BatchUpdateLoanConsolidationQueue();
        }

        public void createManualUnderwritingCases(Id owner_id) {
            TestCases = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).setLoanApplication(TestLoanApplication).setStatus('Pending Loan Consolidation').setOwner(owner_id).getRecordList(BULK_SIZE);
            insert TestCases;
        }

        public void setMockForResponse(Boolean is_success, Boolean is_empty) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanConsolidationCandidatesTestMock(is_success, is_empty));
        }

        private void queryCase() {
            Set<Id> case_ids = new Map<Id, Case>(TestCases).keySet();
            TestCases = [SELECT RecordTypeId, Status, OwnerId FROM Case WHERE Id = :case_ids];
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('BatchUpdateLoanConsolidationQueueTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('BatchUpdateLoanConsolidationQueueTest').save().getRecord();
            LoanApplicationBuilder.getBuilder(test_account).setExpiryDate(System.now()).setExternalId(Utility.getRandomString(8)).save();
        }
    }
}