@isTest
private class EmailMessageHandlerTest {
    private static final String FRAUD_USER = 'CaseViewFraud';
    private static final String UNDERWRITER_USER = 'CaseViewUnderwriting';
    private static final String TEAM_LEADER_USER = 'CaseViewTeamLeader';

    private static final String TEST_EMAIL_ADDRESS = 'test@test.ie';

    static testMethod void testInsertReplyEmailChangeCaseStatusOnReplyForFraudOwner() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseAssignToTestUser();
            Test.startTest();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.createReplyMessage();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();
            setup_data.requeryCase();
            System.assertEquals('In Progress - Document Received', setup_data.TestCase.Status, 'Status should be updated');
            System.assertEquals(1, email_operations, 'Should process one email send for Fraud');
        }
    }

    static testMethod void testInsertReplyEmailChangeCaseStatusOnReplyForFraudOwnerZopa14Disabled() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        FeatureSwitch.disable('ZOPA-14');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseAssignToTestUser();
            Test.startTest();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.createReplyMessage();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();
            setup_data.requeryCase();
            System.assertEquals('Pending', setup_data.TestCase.Status, 'Status should not be updated if Zopa-14 Disabled');
            System.assertEquals(0, email_operations, 'Should not process email send for Fraud if Zopa-14 Disabled');
        }
    }

    static testMethod void testInsertReplyEmailChangeCaseStatusOnReplyForTeamLeadOwner() {
        SetupDataClass setup_data = new SetupDataClass(TEAM_LEADER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseAssignToTestUser();
            Test.startTest();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.createReplyMessage();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();
            setup_data.requeryCase();
            System.assertEquals('In Progress - Document Received', setup_data.TestCase.Status, 'Status should be updated');
            System.assertEquals(1, email_operations, 'Should process one email send for Fraud');
        }
    }

    static testMethod void testInsertReplyEmailChangeCaseStatusOnReplyForUnderwriterOwner() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseAssignToTestUser();
            Test.startTest();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.createReplyMessage();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();
            setup_data.requeryCase();
            System.assertEquals('In Progress - Document Received', setup_data.TestCase.Status, 'Status should be updated');
            System.assertEquals(1, email_operations, 'Should process one email send for Fraud');
        }
    }

    static testMethod void testInsertReplyEmailChangeCaseStatusOnReplyForQueueOwner() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseAssignToQueue();
            Test.startTest();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.createReplyMessage();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();
            setup_data.requeryCase();
            System.assertEquals('In Progress - Document Received', setup_data.TestCase.Status, 'Status should be updated');
            System.assertEquals(0, email_operations, 'Should not process email send for queue owner');
        }
    }

    static testMethod void testInsertReplyEmailNotChangeCaseStatusForAnotherRecordType() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCustomerCase();
            Test.startTest();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.createReplyMessage();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();
            setup_data.requeryCase();
            System.assertNotEquals('In Progress - Document Received', setup_data.TestCase.Status, 'Status should be updated');
            System.assertEquals(0, email_operations, 'Should process one email send for Fraud');
        }
    }

    private class SetupDataClass {
        public EmailMessage FirstMessageFromCustomer;
        public EmailMessage Reply;
        public Case TestCase;
        public User TestUser;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;
        public List<Case> TestCases;
        public Id queueId;
        public String SpamHeader;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name AND FirstName = 'EmailMessageHandlerTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id FROM Loan_Application__c LIMIT 1];
            TestCases = new List<Case>();
        }

        public void createManualUnderwritingCaseAssignToQueue() {
            Id queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_CASE_PREP);
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(queue_id).setStatus('Pending').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createManualUnderwritingCaseAssignToTestUser() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(TestUser.Id).setStatus('Pending').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
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
                                       .save().getRecord();
        }


        public void createOutboundMessage(){
            EmailMessageBuilder.getBuilder(TestCase).setFromAddresses(TEST_EMAIL_ADDRESS).setInComming(false).save();
        }

        public void requeryCase() {
            TestCase = [SELECT Status, OwnerId FROM Case WHERE Id = :TestCase.Id];
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                                     .setFirstName('EmailMessageHandlerTest')
                                     .setLastName(UNDERWRITER_USER)
                                     .save();
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.FRAUD)
                                     .setFirstName('EmailMessageHandlerTest')
                                     .setLastName(FRAUD_USER)
                                     .save();
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                                     .setFirstName('EmailMessageHandlerTest')
                                     .setLastName(TEAM_LEADER_USER)
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('EmailMessageHandlerTest').save().getRecord();
            LoanApplicationBuilder.getBuilder(test_account).setLoanId('1111111111').save();
        }
    }
}