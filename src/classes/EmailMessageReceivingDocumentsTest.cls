@isTest
private class EmailMessageReceivingDocumentsTest {
    private static final String FRAUD_USER = 'CaseViewFraud';
    private static final String UNDERWRITER_USER = 'CaseViewUnderwriting';
    private static final String TEAM_LEADER_USER = 'CaseViewTeamLeader';

    private static final String TEST_EMAIL_ADDRESS = 'test@test.ie';

    static testMethod void testInitVariables() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertNotEquals(null, setup_data.ClassUnderTest.AllCasesToUpdate, 'Should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.AllMessagesToSend, 'Should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.CasePrepPendingQueueId, 'Should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.UnderwritingRecordtypeId, 'Should be initialized');
        }
    }

    static testMethod void testCheckIfEmailMeetTheConditionReplyMeassageQueueOwner() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToQueue('Pending');
            setup_data.createOutboundMessage();
            setup_data.createReplyMessage();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfEmailMeetTheCondition(setup_data.Reply);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should update case on reply message');
            System.assertEquals('In Progress - Document Received', setup_data.ClassUnderTest.AllCasesToUpdate[0].Status, 'Status should be updated');
            System.assertEquals(0, setup_data.ClassUnderTest.AllMessagesToSend.size(), 'Should not send email for Case Prep Queue');
        }
    }

    static testMethod void testCheckIfEmailMeetTheConditionReplyMeassageCaseOpenStatus() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToQueue('Open');
            setup_data.createOutboundMessage();
            setup_data.createReplyMessage();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfEmailMeetTheCondition(setup_data.Reply);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should update case on reply message');
            System.assertEquals('Open - Document Received', setup_data.ClassUnderTest.AllCasesToUpdate[0].Status, 'Status should be updated');
        }
    }

    static testMethod void testCheckIfEmailMeetTheConditionReplyMeassageQueueOwnerClosedCase() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToQueue('Closed');
            setup_data.createOutboundMessage();
            setup_data.createReplyMessage();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfEmailMeetTheCondition(setup_data.Reply);
            Test.stopTest();
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should not update closed case');
        }
    }

    static testMethod void testCheckIfEmailMeetTheConditionReplyMeassageUserOwnerClosedCase() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToTestUser('Closed');
            setup_data.createOutboundMessage();
            setup_data.createReplyMessage();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfEmailMeetTheCondition(setup_data.Reply);
            Test.stopTest();
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should not update closed case');
            System.assertEquals(1, setup_data.ClassUnderTest.AllMessagesToSend.size(), 'Should send email for Closed case');
        }
    }

    static testMethod void testCheckIfEmailMeetTheConditionReplyMeassageTeamLeader() {
        SetupDataClass setup_data = new SetupDataClass(TEAM_LEADER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToTestUser('Pending');
            setup_data.createOutboundMessage();
            setup_data.createReplyMessage();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfEmailMeetTheCondition(setup_data.Reply);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should update case on reply message');
            System.assertEquals('In Progress - Document Received', setup_data.ClassUnderTest.AllCasesToUpdate[0].Status, 'Status should be updated');
            System.assertEquals(1, setup_data.ClassUnderTest.AllMessagesToSend.size(), 'Should send email for Team Leader owner');
        }
    }

    static testMethod void testCheckIfEmailMeetTheConditionReplyMeassageUnderwriter() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToTestUser('Pending');
            setup_data.createOutboundMessage();
            setup_data.createReplyMessage();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfEmailMeetTheCondition(setup_data.Reply);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should update case on reply message');
            System.assertEquals('In Progress - Document Received', setup_data.ClassUnderTest.AllCasesToUpdate[0].Status, 'Status should be updated');
            System.assertEquals(1, setup_data.ClassUnderTest.AllMessagesToSend.size(), 'Should send email for Underwriter owner');
        }
    }

    static testMethod void testCheckIfEmailMeetTheConditionReplyMeassageFraud() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToTestUser('Pending');
            setup_data.createOutboundMessage();
            setup_data.createReplyMessage();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfEmailMeetTheCondition(setup_data.Reply);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should update case on reply message');
            System.assertEquals('In Progress - Document Received', setup_data.ClassUnderTest.AllCasesToUpdate[0].Status, 'Status should be updated');
            System.assertEquals(1, setup_data.ClassUnderTest.AllMessagesToSend.size(), 'Should send email for Fraud owner');
        }
    }

    static testMethod void testCheckIfEmailMeetTheConditionAnotherCaseRecordType() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createCustomerCase();
            setup_data.createOutboundMessage();
            setup_data.createReplyMessage();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfEmailMeetTheCondition(setup_data.Reply);
            Test.stopTest();
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should not update case for another recordtype');
            System.assertEquals(0, setup_data.ClassUnderTest.AllMessagesToSend.size(), 'Should not send email for another recordtype');
        }
    }

    static testMethod void testUpdateAllCasesWithRecordsInBothLists() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCaseAssignToTestUser('Pending');
            setup_data.createOutboundMessage();
            setup_data.createReplyMessage();
            setup_data.ClassUnderTest.checkIfEmailMeetTheCondition(setup_data.Reply);
            Test.startTest();
                Integer dml_operations = -Limits.getDMLRows();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.ClassUnderTest.updateAllCases();
                dml_operations += Limits.getDMLRows();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();
            System.assertEquals(2, dml_operations, 'Should process any dml, when there is a record in case list');
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
            Test.startTest();
                Integer dml_operations = -Limits.getDMLRows();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.ClassUnderTest.updateAllCases();
                dml_operations += Limits.getDMLRows();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();
            System.assertEquals(0, dml_operations, 'Should not process any dml, when there is no records');
            System.assertEquals(0, email_operations, 'Should not process any email sends, when there is no emails in list');
        }
    }

    private class SetupDataClass {
        public EmailMessage FirstMessageFromCustomer;
        public EmailMessage Reply;
        public Case TestCase;
        public User TestUser;
        public EmailMessageReceivingDocuments ClassUnderTest;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name AND FirstName = 'EmailMessageReceivingDocumentsTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id FROM Loan_Application__c LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = EmailMessageReceivingDocuments.getInstance();
        }

        public void createManualUnderwritingCaseAssignToQueue(String status) {
            Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_CASE_PREP);
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(queue_id).setStatus(status).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createManualUnderwritingCaseAssignToTestUser(String status) {
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(TestUser.Id).setStatus(status).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createCustomerCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(TestUser.Id).setStatus('Pending').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_CUSTOMER).save().getRecord();
        }

        public void createFirstMessageFromCustomer() {
            FirstMessageFromCustomer = EmailMessageBuilder.getBuilder(TestCase)
                                                          .setFromAddresses(TEST_EMAIL_ADDRESS)
                                                          .setInComming(true)
                                                          .save().getRecord();
        }

        public void createReplyMessage(){
            Reply = EmailMessageBuilder.getBuilder(TestCase)
                                       .setFromAddresses(TEST_EMAIL_ADDRESS)
                                       .setInComming(true)
                                       .getRecord();
        }

        public void createOutboundMessage(){
            EmailMessageBuilder.getBuilder(TestCase).setFromAddresses(TEST_EMAIL_ADDRESS).setInComming(false).save();
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                                     .setFirstName('EmailMessageReceivingDocumentsTest')
                                     .setLastName(UNDERWRITER_USER)
                                     .save();
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.FRAUD)
                                     .setFirstName('EmailMessageReceivingDocumentsTest')
                                     .setLastName(FRAUD_USER)
                                     .save();
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                                     .setFirstName('EmailMessageReceivingDocumentsTest')
                                     .setLastName(TEAM_LEADER_USER)
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('EmailMessageReceivingDocumentsTest').save().getRecord();
            LoanApplicationBuilder.getBuilder(test_account).save();
        }
    }
}