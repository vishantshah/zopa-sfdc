@isTest
public class AttachmentTriggerHandlerTest {
    private static final Integer BULK_SIZE = 10;

    static testMethod void testSendInboundEmailAttachmentsToBackendWithParentInboundMessages(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZS-44');
        System.runAs(setup_data.TestUser){
            Test.startTest();
                setup_data.createAttachmentsOfEmailsMessages(true);
                Integer number_of_future_calls = Limits.getFutureCalls();
            Test.stopTest();
            System.assertEquals(BULK_SIZE, number_of_future_calls, 'number_of_future_calls should be equal to the number of attachments');
        }
    }

    static testMethod void testSendInboundEmailAttachmentsToBackendWithParentInboundMessagesZS44Off(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZS-44');
        System.runAs(setup_data.TestUser){
            Test.startTest();
                setup_data.createAttachmentsOfEmailsMessages(true);
                Integer number_of_future_calls = Limits.getFutureCalls();
            Test.stopTest();
            System.assertEquals(0, number_of_future_calls, 'number_of_future_calls should be zero as FS-44 is disabled');
        }
    }

    static testMethod void testSendInboundEmailAttachmentsToBackendWithParentOutboundMessages(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZS-44');
        System.runAs(setup_data.TestUser){
            Test.startTest();
                setup_data.createAttachmentsOfEmailsMessages(false);
                Integer number_of_future_calls = Limits.getFutureCalls();
            Test.stopTest();
            System.assertEquals(0, number_of_future_calls, 'number_of_future_calls should be zero to as parent emails outbound');
        }
    }

    private class SetupDataClass{
        public List<Attachment> TestAttachments;
        public List<Case> TestCases;
        public List<EmailMessage> TestEmails;
        public User TestUser;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;


        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestAdministrator' LIMIT 1];

            TestAccount = AccountBuilder.getBuilder().setLastName('Test')
                                .setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT)
                                .save()
                                .getRecord();

            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount)
                                                        .setApplicationName('testLoanApp')
                                                        .setLoanId('1111111111111111')
                                                        .save()
                                                        .getRecord();
        }

        public void createAttachmentsOfEmailsMessages(Boolean is_incoming){
            createTestCases();
            createEmailMessages(is_incoming);
            TestAttachments = new List<Attachment>();

            for(EmailMessage inbound_message : TestEmails){
                TestAttachments.add(createAttachments(inbound_message.Id));
            }

            insert TestAttachments;
        }

        private void createTestCases(){
            Case test_case = CaseBuilder.getBuilder()
                                          .setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                                          .setLoanApplication(TestLoanApplication)
                                          .setStatus('Open')
                                          .setOrigin('Web')
                                          .getRecord();
            TestCases = CaseBuilder.getBuilder(test_case).getRecordList(BULK_SIZE);
            insert TestCases;
        }

        private void createEmailMessages(Boolean is_incoming){
            TestEmails = new List<EmailMessage>();
            for(Case test_case : TestCases){
                EmailMessage email = EmailMessageBuilder.getBuilder(test_case)
                           .setHeaders('test')
                           .setFromAddresses('abc@pexlify.com')
                           .setToAddresses('Currend@pexlify.com')
                           .setTextBody('TestMessage')
                           .setIncomming(is_incoming)
                           .getRecord();
                TestEmails.add(email);
            }

            insert TestEmails;
        }

        private Attachment createAttachments(Id parent_id){
            return AttachmentBuilder.getBuilder(parent_id)
                                    .setBody(Blob.valueOf('SomeBlob'))
                                    .setContentType('text')
                                    .setName('Test')
                                    .setDescription('Test')
                                    .getRecord();
        }
    }

    @testSetup
    static void setupData(){
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('TestAdministrator')
                                     .setIsActive(true)
                                     .save();
    }
}