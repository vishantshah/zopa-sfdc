@isTest
private class DocumentReceivedFromIntegrationHandTest {
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
            System.assertNotEquals(null, setup_data.ClassUnderTest.AllMessagesToSend, 'Should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.LoanIdToUnderwritingCaseToUpdate, 'Should be initialized');
        }
    }

    static testMethod void testQueryUnderwritingCasesForOldLoanNoMUCaseNoProcessing() {
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

    static testMethod void testQueryUnderwritingCasesForOldLoanQueryOneCase() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToQueue();
            setup_data.createManualUnderwritingCaseAssignToTestUser();
            Test.startTest();
                setup_data.ClassUnderTest.queryUnderwritingCasesForOldLoan(new Map<Id, sObject>{setup_data.TestLoanApplication.Id => setup_data.TestLoanApplication});
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.LoanIdToUnderwritingCaseToUpdate.size(), 'Should get only one case for loan');
        }
    }

    static testMethod void testUpdateManualUnderwitingCaseForOldLoanNoCases() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.fillUnderwritingCasesForOldLoanMap();
            setup_data.updateLoanDocumentsLastUpdatedDate();
            Test.startTest();
                setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(0, setup_data.ClassUnderTest.AllMessagesToSend.size(), 'Should not add email');
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should add case to update');
        }
    }

    static testMethod void testUpdateManualUnderwitingCaseForOldLoanClosedCasesNoUpdates() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingClosedCaseAssignToTestUser();
            setup_data.fillUnderwritingCasesForOldLoanMap();
            setup_data.updateLoanDocumentsLastUpdatedDate();
            Test.startTest();
                setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllMessagesToSend.size(), 'Should add email');
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should add case to update');
        }
    }

    static testMethod void testUpdateManualUnderwitingCaseForOldLoanOwnedByFraud() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToTestUser();
            setup_data.fillUnderwritingCasesForOldLoanMap();
            setup_data.updateLoanDocumentsLastUpdatedDate();
            Test.startTest();
                setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllMessagesToSend.size(), 'Should add email');
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should add case to update');
            System.assertEquals('In Progress - Document Received', setup_data.ClassUnderTest.AllCasesToUpdate[0].Status, 'Should update status');
            System.assertEquals(null, setup_data.ClassUnderTest.AllCasesToUpdate[0].getOptions(), 'Should not use dml option');
        }
    }

    static testMethod void testUpdateManualUnderwitingCaseForOldLoanOwnedByQueue() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToQueue();
            setup_data.fillUnderwritingCasesForOldLoanMap();
            setup_data.updateLoanDocumentsLastUpdatedDate();
            Test.startTest();
                setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(0, setup_data.ClassUnderTest.AllMessagesToSend.size(), 'Should not add email');
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should add case to update');
            System.assertEquals('In Progress - Document Received', setup_data.ClassUnderTest.AllCasesToUpdate[0].Status, 'Should update status');
            System.assertNotEquals(null, setup_data.ClassUnderTest.AllCasesToUpdate[0].getOptions(), 'Should use dml option');
            System.assertEquals(CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_CASE_PREP),
                        setup_data.ClassUnderTest.AllCasesToUpdate[0].getOptions().AssignmentRuleHeader.assignmentRuleId, 'Should use move to case prep rule');
        }
    }

    static testMethod void testUpdateManualUnderwitingCaseForOldLoanOpenCaseStatus() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingOpenCase();
            setup_data.fillUnderwritingCasesForOldLoanMap();
            setup_data.updateLoanDocumentsLastUpdatedDate();
            Test.startTest();
                setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should add case to update');
            System.assertEquals('Open - Document Received', setup_data.ClassUnderTest.AllCasesToUpdate[0].Status, 'Should update status');
        }
    }

    static testMethod void testUpdateStatusToDocumentRecievedAndAddToTheAllCasesWithStatusOpen(){
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
           setup_data.initClassUnderTest();
           setup_data.createManualUnderwritingOpenCase();
           Test.startTest();
                setup_data.ClassUnderTest.updateStatusToDocumentRecievedAndAddToTheAllCases(setup_data.TestCase);
           Test.stopTest();
           System.assertEquals('Open - Document Received',setup_data.ClassUnderTest.AllCasesToUpdate[0].Status, 'Status should Open - Document Received but it ' + setup_data.ClassUnderTest.AllCasesToUpdate[0].Status);
        }
    }

    static testMethod void testUpdateStatusToDocumentRecievedAndAddToTheAllCasesWithOpenDocumentReceivedStatus(){
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
           setup_data.initClassUnderTest();
           setup_data.createManualUnderwritingOpenDocumentReceivedCase();
           Test.startTest();
                setup_data.ClassUnderTest.updateStatusToDocumentRecievedAndAddToTheAllCases(setup_data.TestCase);
           Test.stopTest();
           System.assertEquals('Open - Document Received',setup_data.ClassUnderTest.AllCasesToUpdate[0].Status, 'Status should Open - Document Received but it ' + setup_data.ClassUnderTest.AllCasesToUpdate[0].Status);
        }
    }

    static testMethod void testUpdateStatusToDocumentRecievedAndAddToTheAllCasesWithOpenDocumentPendingStatus(){
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
           setup_data.initClassUnderTest();
           setup_data.createManualUnderwritingPendingCase();
           Test.startTest();
                setup_data.ClassUnderTest.updateStatusToDocumentRecievedAndAddToTheAllCases(setup_data.TestCase);
           Test.stopTest();
           System.assertEquals('In Progress - Document Received',setup_data.ClassUnderTest.AllCasesToUpdate[0].Status, 'Status should In Progress - Document Received but it ' + setup_data.ClassUnderTest.AllCasesToUpdate[0].Status);
        }
    }

    static testMethod void testUpdateAllCasesWithRecordsInBothLists() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToTestUser();
            setup_data.fillUnderwritingCasesForOldLoanMap();
            setup_data.updateLoanDocumentsLastUpdatedDate();
            setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.startTest();
                Integer dml_operations = -Limits.getDMLRows();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.ClassUnderTest.updateAllCasesAndSendEmails();
                dml_operations += Limits.getDMLRows();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();
           // System.assertEquals(2, dml_operations, 'Should process any dml, when there is a record in case list other than the case update and 2 task DMLs');
            System.assertEquals(1, email_operations, 'Should process any email sends, when there is an email in list');
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should clear records after update');
            System.assertEquals(0, setup_data.ClassUnderTest.AllMessagesToSend.size(), 'Should clear emails after send');
        }
    }

    static testMethod void testUpdateAllCasesNoRecords() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createCustomerCase();
            setup_data.fillUnderwritingCasesForOldLoanMap();
            setup_data.updateLoanDocumentsLastUpdatedDate();
            setup_data.ClassUnderTest.updateManualUnderwitingCaseForOldLoan(setup_data.TestOldLoanApplication, setup_data.TestLoanApplication);
            Test.startTest();
                Integer dml_operations = -Limits.getDMLRows();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.ClassUnderTest.updateAllCasesAndSendEmails();
                dml_operations += Limits.getDMLRows();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();
            System.assertEquals(0, dml_operations, 'Should not process any dml, when there is no records');
            System.assertEquals(0, email_operations, 'Should not process any email sends, when there is no emails in list');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public User TestUser;
        public DocumentReceivedFromIntegrationHandler ClassUnderTest;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;
        public Loan_Application__c TestOldLoanApplication;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name AND FirstName = 'DocumentReceivedFromIntegrationHandTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id, Documents_Last_Updated_Date__c FROM Loan_Application__c LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = DocumentReceivedFromIntegrationHandler.getInstance();
        }

        public void createManualUnderwritingOpenCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setStatus('Open').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createManualUnderwritingCaseAssignToQueue() {
            Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_CASE_PREP);
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(queue_id).setStatus('Pending').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createManualUnderwritingCaseAssignToTestUser() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(TestUser.Id).setStatus('Pending').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createManualUnderwritingClosedCaseAssignToTestUser() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(TestUser.Id).setStatus('Closed').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createManualUnderwritingPendingCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setStatus('Pending').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createManualUnderwritingOpenDocumentReceivedCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setStatus('Open - Document Received').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createCustomerCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(TestUser.Id).setStatus('Pending').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_CUSTOMER).save().getRecord();
        }

        public void updateLoanDocumentsLastUpdatedDate() {
            TestOldLoanApplication = TestLoanApplication.clone(true, true);
            LoanApplicationBuilder.getBuilder(TestLoanApplication).setDocumentsLastUpdatedDate(System.now());
        }

        public void fillUnderwritingCasesForOldLoanMap() {
            ClassUnderTest.queryUnderwritingCasesForOldLoan(new Map<Id, sObject>{TestLoanApplication.Id => TestLoanApplication});
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
            FeatureSwitch.disable('ZOPA-4');
            LoanApplicationBuilder.getBuilder(test_account).save();
        }
    }
}