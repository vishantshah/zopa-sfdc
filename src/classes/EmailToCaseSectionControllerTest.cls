@isTest
public class EmailToCaseSectionControllerTest {

    static testMethod void testQueryTasksAndEmailQueriesCorrectData(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.initClassUnderTest();
            setup_data.createEmailMessageAndTaskRecords();
            Test.startTest();
                setup_data.ClassUnderTest.queryTasksAndEmails();
            Test.stopTest();
            System.assertEquals(
                    true,
                    setup_data.ClassUnderTest.CasesEmailMessages.size() >= 20,
                    'Should be created 20 or more records of EmailMessageWrapper - depends on state of feature creating new tasks on EmailMessage insert'
            );
        }
    }

    static testMethod void testQueryTasksAndEmailsWithoutTaskAndEmail(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.initClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.queryTasksAndEmails();
            Test.stopTest();
            System.assertEquals(0, setup_data.ClassUnderTest.CasesEmailMessages.size(), 'There should be no records');
        }
    }

    static testMethod void testGetEmailAddressFromTaskDescriptionIfDescriptionToAddress(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.initClassUnderTest();
            setup_data.createEmailMessageAndTaskRecords();
            Test.startTest();
                setup_data.ClassUnderTest.queryTasksAndEmails();
            Test.stopTest();
            for(EmailToCaseSectionController.EmailMessageWrapper email_message : setup_data.ClassUnderTest.CasesEmailMessages){
                System.assertEquals('some_mail@test.com', email_message.ToAddress, 'EmailMessage to address should be some_mail@test.com');
            }
        }
    }

    static testMethod void testGetEmailAddressFromTaskDescriptionWithoutToAddresses(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.initClassUnderTest();
            setup_data.createTaskForCaseNoToAddresses();
            Test.startTest();
                setup_data.ClassUnderTest.queryTasksAndEmails();
            Test.stopTest();
            for(EmailToCaseSectionController.EmailMessageWrapper email_message : setup_data.ClassUnderTest.CasesEmailMessages){
                System.assertEquals('', email_message.ToAddress, 'EmailMessage to address should be empty');
            }
        }
    }

    static testMethod void testCompareToEmailMessagesDateForCompare(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.initClassUnderTest();
            setup_data.createEmailMessageWithDifferentMessageDate();
            Test.startTest();
                setup_data.ClassUnderTest.queryTasksAndEmails();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.CasesEmailMessages[0].DateForCompare > setup_data.ClassUnderTest.CasesEmailMessages[1].DateForCompare,
             'The first date in the list should be greater');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Case TestCase;
        public EmailToCaseSectionController ClassUnderTest;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE LastName = 'EmailToCaseSectionControllerTest' LIMIT 1];
            TestCase = [SELECT Id FROM Case LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new EmailToCaseSectionController();
            ClassUnderTest.CurrentCaseId = TestCase.Id;
        }

        public void createEmailMessageAndTaskRecords(){
            List<EmailMessage> email_messages_to_insert = new List<EmailMessage>();
            List<Task> tasks_to_insert = new List<Task>();
            for(Integer i = 0; i < 10; i++){
                email_messages_to_insert.add(
                        EmailMessageBuilder.getBuilder(TestCase)
                                .setToAddresses('some_mail@test.com')
                                .getRecord()
                );
                tasks_to_insert.add(
                        TaskBuilder.getBuilder()
                                .setRelatedTo(TestCase.Id)
                                .setSubject('Email')
                                .setComment('Additional To: some_mail@test.com')
                                .getRecord()
                );
            }
            insert email_messages_to_insert;
            insert tasks_to_insert;
        }

        public void createTaskForCaseNoToAddresses(){
            TaskBuilder.getBuilder()
                    .setRelatedTo(TestCase.Id)
                    .setSubject('Email')
                    .save();
        }

        public void createEmailMessageWithDifferentMessageDate(){
            EmailMessageBuilder.getBuilder(TestCase)
                    .setMessageDate(Datetime.now().addDays(2))
                    .setToAddresses('some_mail@test.com')
                    .save();
            EmailMessageBuilder.getBuilder(TestCase)
                    .setToAddresses('some_mail@test.com')
                    .save();
        }

    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('EmailToCaseSectionControllerTest')
                .save();
    }

    @testSetup
    static void setupTestCase() {
        CaseBuilder.getBuilder()
                .setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                .save();
    }
}