@isTest
public class AttachmentBuilderTest {
    static testMethod void testBuilderSetsTheCorrectEmailMessage(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Attachment document = AttachmentBuilder.getBuilder(setup_data.TestEmail).getRecord();
            Test.stopTest();
            System.assertEquals(setup_data.TestEmail.Id, document.ParentId, 'ParentId should be equal to testemail Id');
        }
    }

    static testMethod void testSetName(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String test_name = 'test name';
            Test.startTest();
                Attachment document = AttachmentBuilder.getBuilder(setup_data.TestEmail).setName(test_name).getRecord();
            Test.stopTest();
            System.assertEquals(test_name, document.Name, 'Names aren`t equal');
        }
    }

    static testMethod void testSetBody(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Blob test_blob = Blob.valueOf('test Blob');
            Test.startTest();
                Attachment document = AttachmentBuilder.getBuilder(setup_data.TestEmail).setBody(test_blob).getRecord();
            Test.stopTest();
            System.assertEquals(test_blob, document.Body, 'blobs are not equal');
        }
    }

    static testMethod void testSetContentType(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String test_content_type = 'test content type';
            Test.startTest();
                Attachment document = AttachmentBuilder.getBuilder(setup_data.TestEmail).setContentType(test_content_type).getRecord();
            Test.stopTest();
            System.assertEquals(test_content_type, document.ContentType, 'content types are not equal');
        }
    }

    static testMethod void testSetDescription(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String test_description = 'test description';
            Test.startTest();
                Attachment document = AttachmentBuilder.getBuilder(setup_data.TestEmail).setDescription(test_description).getRecord();
            Test.stopTest();
            System.assertEquals(test_description, document.Description, 'Descriptions are not equal');
        }
    }

    static testMethod void testSave(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZS-44');
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Attachment document = AttachmentBuilder.getBuilder(setup_data.TestEmail).setName('test').setBody(Blob.valueOf('test blob')).save().getRecord();
            Test.stopTest();
            System.assertEquals(true, document.Id != null, 'Id should not be null');
        }
    }

    private class SetupDataClass{
        public User TestUser;
        public EmailMessage TestEmail;
        public Case TestCase;

        public SetupDataClass(){
            Account test_account = AccountBuilder.getBuilder('CaseViewExtension').save().getRecord();
            Loan_Application__c test_loan = LoanApplicationBuilder.getBuilder(test_account).save().getRecord();
            TestCase = CaseBuilder.getBuilder(test_account).setLoanApplication(test_loan).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
               TestEmail = EmailMessageBuilder.getBuilder(TestCase)
                           .setHeaders('test')
                           .setFromAddresses('abc@pexlify.com')
                           .setToAddresses('Currend@pexlify.com')
                           .setTextBody('TestMessage')
                           .setInComming(false)
                           .save()
                           .getRecord();
            TestUser = [SELECT Id FROM User WHERE FirstName ='EmailMessage' LIMIT 1];
        }

    }

    @testSetup
    static void setupData(){
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('EmailMessage')
                                     .setLastName('BuilderTest')
                                     .save();
    }
}