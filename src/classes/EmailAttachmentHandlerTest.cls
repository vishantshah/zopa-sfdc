@IsTest
public class EmailAttachmentHandlerTest{
    private static final Integer BULK_SIZE = 10;

    static testMethod void testCheckIfItIsEmailAttachmentPositive(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAttachmentWithEmailParent();

            Test.startTest();
                setup_data.ClassUnderTest.checkIfItIsEmailAttachment(setup_data.TestDocument);
            Test.stopTest();

            System.assertEquals(1, setup_data.ClassUnderTest.EmailAttachments.size(), 'Attachment recognized as an email attachment.');
            System.assert(setup_data.ClassUnderTest.EmailAttachments.contains(setup_data.TestDocument), 'Should handle given attachment.');
        }
    }

    static testMethod void testCheckIfItIsEmailAttachmentNegative(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAttachmentWithAccountParent();

            Test.startTest();
                setup_data.ClassUnderTest.checkIfItIsEmailAttachment(setup_data.TestDocument);
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.EmailAttachments.size(), 'Attachment recognized as not email attachment.');
        }
    }

    static testMethod void testIsDocumentAttachedToIncomingEmailPositive(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAttachmentWithEmailParent();

            Test.startTest();
                Boolean is_true = setup_data.ClassUnderTest.isDocumentAttachedToIncomingEmail(setup_data.TestDocument);
            Test.stopTest();

            System.assertEquals(true, is_true, 'Result should be true as parent of attachment is email.');
        }
    }

    static testMethod void testIsDocumentAttachedToIncomingEmailNegative(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAttachmentWithAccountParent();

            Test.startTest();
                Boolean is_true = setup_data.ClassUnderTest.isDocumentAttachedToIncomingEmail(setup_data.TestDocument);
            Test.stopTest();

            System.assertEquals(false, is_true, 'Result should be false as parent of attachment is not email.');
        }
    }

    static testMethod void testGetEmailMessagesOfAttachmentsPositive(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createBulkAttachmentsWithEmailParents(true);
            setup_data.bulkCheckIfItIsEmailAttachment();

            Test.startTest();
                setup_data.ClassUnderTest.getEmailMessagesOfAttachments();
            Test.stopTest();

            System.assertEquals(BULK_SIZE, setup_data.ClassUnderTest.ParentEmailsOfAttachments.size(), 'Should get all emails for handled attachments.');
            for(EmailMessage test_message : setup_data.TestEmails){
                System.assertNotEquals(null, setup_data.ClassUnderTest.ParentEmailsOfAttachments.get(test_message.Id));
            }
        }
    }

    static testMethod void testGetEmailMessagesOfAttachmentsNegative(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createBulkAttachmentsWithAccountParents();
            setup_data.bulkCheckIfItIsEmailAttachment();

            Test.startTest();
                setup_data.ClassUnderTest.getEmailMessagesOfAttachments();
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.EmailAttachments.size(), 'There are no handled attachments.');
            System.assertEquals(0, setup_data.ClassUnderTest.ParentEmailsOfAttachments.size(), 'There are no returned eamils because there are no handled attachments.');
        }
    }

    static testMethod void testRemoveOutboundEmailsAndItsAttachmentsWithOutboundEmails(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createBulkAttachmentsWithEmailParents(false);
            setup_data.bulkCheckIfItIsEmailAttachment();
            setup_data.ClassUnderTest.getEmailMessagesOfAttachments();

            Test.startTest();
                setup_data.ClassUnderTest.removeOutboundEmailsAndItsAttachments();
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.EmailAttachments.size(), 'All attachment should be removed because all are attached to outbound emails.');
            System.assertEquals(0, setup_data.ClassUnderTest.ParentEmailsOfAttachments.size(), 'All emails should be removed because all are outbound.');
        }
    }

    static testMethod void testRemoveOutboundEmailsAndItsAttachmentsWithInboundEmails(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createBulkAttachmentsWithEmailParents(true);
            setup_data.bulkCheckIfItIsEmailAttachment();
            setup_data.ClassUnderTest.getEmailMessagesOfAttachments();

            Test.startTest();
                setup_data.ClassUnderTest.removeOutboundEmailsAndItsAttachments();
            Test.stopTest();

            System.assertEquals(BULK_SIZE, setup_data.ClassUnderTest.EmailAttachments.size(), 'None of attachments should be removed because all are attached to inbound emails.');
            System.assertEquals(BULK_SIZE, setup_data.ClassUnderTest.ParentEmailsOfAttachments.size(), 'None of emails should be removed because all are inbound.');
        }
    }

    static testMethod void testRemoveOutboundEmailsWhenThereAreBothOutboundAndInboundEmailsWithAttachments(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            EmailMessage test_inbound_email = setup_data.createBulkAttachmentsWithSingleEmailParent(true);
            setup_data.createBulkAttachmentsWithSingleEmailParent(false);
            setup_data.bulkCheckIfItIsEmailAttachment();
            setup_data.ClassUnderTest.getEmailMessagesOfAttachments();

            Test.startTest();
                setup_data.ClassUnderTest.removeOutboundEmailsAndItsAttachments();
            Test.stopTest();

            System.assertEquals(BULK_SIZE, setup_data.ClassUnderTest.EmailAttachments.size(), 'There should be handled 10 attachments attached to one inbound email.');
            System.assertEquals(1, setup_data.ClassUnderTest.ParentEmailsOfAttachments.size(), 'One email should be removed beacuse was outbound.');
            for(Attachment attachment_item : setup_data.ClassUnderTest.EmailAttachments) {
                System.assertEquals(test_inbound_email.Id, attachment_item.ParentId, 'Handled attachments are attached to inbound email.');
            }
        }
    }

    static testMethod void testGetEmailParentCases(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAttachmentWithEmailParent();
            setup_data.ClassUnderTest.checkIfItIsEmailAttachment(setup_data.TestDocument);
            setup_data.ClassUnderTest.getEmailMessagesOfAttachments();

            Test.startTest();
                setup_data.ClassUnderTest.getEmailParentCases();
            Test.stopTest();

            System.assertEquals(1, setup_data.ClassUnderTest.ParentCasesOfEmail.size(), 'Found 1 parent case for inbound email.');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.ParentCasesOfEmail.values().get(0).Id, 'Found case is a parent of inbound email.');
        }
    }

    static testMethod void testSendDocumentsToBackend(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createBulkAttachmentsWithEmailParents(true);
            setup_data.bulkCheckIfItIsEmailAttachment();

            Test.startTest();
                setup_data.ClassUnderTest.sendToBackend();
                Integer number_of_future_calls = Limits.getFutureCalls();
            Test.stopTest();

            System.assertEquals(BULK_SIZE, number_of_future_calls, 'Number of future calls should be equal to number of attachments.');
        }
    }

    private class SetupDataClass{
        public Attachment TestDocument;
        public User TestUser;
        public EmailMessage TestEmail;
        public Case TestCase;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;
        public List<EmailMessage> TestEmails = new List<EmailMessage>();
        public List<Attachment> TestDocuments = new List<Attachment>();
        public EmailAttachmentHandler ClassUnderTest;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestAdministrator' LIMIT 1];

            TestAccount = AccountBuilder.getBuilder().setLastName('Test')
                                .setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT)
                                .save().getRecord();

            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount)
                                                        .setApplicationName('testLoanApp')
                                                        .setLoanId('1111111111111111')
                                                        .save()
                                                        .getRecord();

            TestCase = CaseBuilder.getBuilder()
                  .setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                  .setLoanApplication(TestLoanApplication)
                  .setStatus('Open')
                  .setOrigin('Web')
                  .save()
                  .getRecord();

            ClassUnderTest = EmailAttachmentHandler.getInstance();
        }

        public void createAttachmentWithEmailParent(){
            FeatureSwitch.disable('ZOPA-14');
            TestEmail = createEmail(true);
            insert TestEmail;

            FeatureSwitch.disable('ZS-44');
            TestDocument = createAttachment(TestEmail.Id);
            insert TestDocument;
        }

        public void createAttachmentWithAccountParent(){
            TestDocument = createAttachment(TestAccount.Id);
            insert TestDocument;
        }

        public EmailMessage createBulkAttachmentsWithSingleEmailParent(Boolean is_incoming){
            FeatureSwitch.disable('ZOPA-14');
            EmailMessage test_email = createEmail(is_incoming);
            insert test_email;
            TestEmails.add(test_email);

            FeatureSwitch.disable('ZS-44');
            List<Attachment> test_attachments = new List<Attachment>();
            for(Integer i = 0; i < BULK_SIZE; i++){
                test_attachments.add(createAttachment(test_email.Id));
            }
            insert test_attachments;
            TestDocuments.addAll(test_attachments);

            return test_email;
        }

        public void createBulkAttachmentsWithSingleAccountParent(){
            FeatureSwitch.disable('ZS-44');
            List<Attachment> test_attachments = new List<Attachment>();
            for(Integer i = 0; i < BULK_SIZE; i++){
                test_attachments.add(createAttachment(TestAccount.Id));
            }
            insert test_attachments;
            TestDocuments.addAll(test_attachments);
        }

        public void createBulkAttachmentsWithEmailParents(Boolean is_incoming){
            FeatureSwitch.disable('ZOPA-14');
            List<EmailMessage> test_emails = new List<EmailMessage>();
            for(Integer i = 0; i < BULK_SIZE; ++i){
                test_emails.add(createEmail(is_incoming));
            }
            insert test_emails;
            TestEmails.addAll(test_emails);

            List<Attachment> test_attachments = new List<Attachment>();
            for(EmailMessage test_email : TestEmails){
                test_attachments.add(createAttachment(test_email.Id));
            }
            FeatureSwitch.disable('ZS-44');
            insert test_attachments;
            TestDocuments.addAll(test_attachments);
        }

        public void createBulkAttachmentsWithAccountParents(){
            for(Integer i = 0; i < BULK_SIZE; ++i){
                TestDocuments.add(createAttachment(TestAccount.Id));
            }
        }

        private EmailMessage createEmail(Boolean is_incoming){
            return EmailMessageBuilder.getBuilder(TestCase)
                           .setHeaders('test')
                           .setFromAddresses('abc@pexlify.com')
                           .setToAddresses('Currend@pexlify.com')
                           .setTextBody('TestMessage')
                           .setIncomming(is_incoming)
                           .getRecord();
        }

        public Attachment createAttachment(Id parent_id){
            return AttachmentBuilder.getBuilder(parent_id)
                                            .setBody(Blob.valueOf('SomeBlob'))
                                            .setContentType('text')
                                            .setName('Test')
                                            .setDescription('Test')
                                            .getRecord();
        }

        public void bulkCheckIfItIsEmailAttachment(){
            for(Attachment document : TestDocuments){
                ClassUnderTest.checkIfItIsEmailAttachment(document);
            }
        }

        public void setMockForResponse(Boolean is_success, Integer response_code) {
           Test.setMock(HttpCalloutMock.class, new ApiUploadDocumentTestMock(is_success, response_code));
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