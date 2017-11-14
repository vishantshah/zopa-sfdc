@isTest
public class EmailMessageBuilderTest {

    static testMethod void testBuilderSetsTheCorrectCase(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                EmailMessage test_email = EmailMessageBuilder.getBuilder(setup_data.TestCase).getRecord();
            Test.stopTest();
            System.assertEquals(setup_data.TestCase.Id, test_email.ParentId, 'The ParentId should have been set by the Builder constructor');
        }
    }

    static testMethod void testSetHeadersSetsTheCorrectData(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                EmailMessage test_email = EmailMessageBuilder.getBuilder(setup_data.TestCase).setHeaders('Random Headers').getRecord();
            Test.stopTest();
            System.assertEquals('Random Headers', test_email.Headers, 'The Headers should have been set correctly');
        }
    }

    static testMethod void testSetFromAddressesSetsTheCorrectData(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                EmailMessage test_email = EmailMessageBuilder.getBuilder(setup_data.TestCase).setFromAddresses('dipsey.lala@tinkeywinkey.com').getRecord();
            Test.stopTest();
            System.assertEquals('dipsey.lala@tinkeywinkey.com', test_email.FromAddress, 'The From Address should have been set correctly');
        }
    }

    static testMethod void testSetToAddressesSetsTheCorrectData(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                EmailMessage test_email = EmailMessageBuilder.getBuilder(setup_data.TestCase).setToAddresses('dipsey.lala@tinkeywinkey.com').getRecord();
            Test.stopTest();
            System.assertEquals('dipsey.lala@tinkeywinkey.com', test_email.ToAddress, 'The To Address should have been set correctly');
        }
    }

    static testMethod void testSetHtmlBodySetsTheCorrectData(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                EmailMessage test_email = EmailMessageBuilder.getBuilder(setup_data.TestCase).setHtmlBody('<htmsmells></htmsmells>').getRecord();
            Test.stopTest();
            System.assertEquals('<htmsmells></htmsmells>', test_email.HtmlBody, 'The Html Body should have been set correctly');
        }
    }

    static testMethod void testSetTextBodySetsTheCorrectData(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                EmailMessage test_email = EmailMessageBuilder.getBuilder(setup_data.TestCase).setTextBody('No smells here').getRecord();
            Test.stopTest();
            System.assertEquals('No smells here', test_email.TextBody, 'The Text Body should have been set correctly');
        }
    }

    static testMethod void testSetSubjectSetsTheCorrectData(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                EmailMessage test_email = EmailMessageBuilder.getBuilder(setup_data.TestCase).setSubject('Random Subject').getRecord();
            Test.stopTest();
            System.assertEquals('Random Subject', test_email.Subject, 'The Subject should have been set correctly');
        }
    }

    static testMethod void testSetStatusSetsTheCorrectData(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                EmailMessage test_email = EmailMessageBuilder.getBuilder(setup_data.TestCase).setStatus('Sent').getRecord();
            Test.stopTest();
            System.assertEquals('Sent', test_email.Status, 'The Status should have been set correctly');
        }
    }

    static testMethod void testSetMassageDateSetsTheCorrectData(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                EmailMessage test_email = EmailMessageBuilder.getBuilder(setup_data.TestCase).setMessageDate(Datetime.now()).getRecord();
            Test.stopTest();
            System.assertEquals(Datetime.now(), test_email.MessageDate, 'The MessageDate should have been set correctly');
        }
    }

    static testMethod void testIsInCommingSetsTheCorrectData(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                EmailMessage test_email = EmailMessageBuilder.getBuilder(setup_data.TestCase).setInComming(true).getRecord();
            Test.stopTest();
            System.assertEquals(true, test_email.Incoming, 'The email should have been set to incomming');
        }
    }

    static testMethod void testSaveMethodWorksOnBuilder(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                EmailMessage test_email = EmailMessageBuilder.getBuilder(setup_data.TestCase).setInComming(true).save().getRecord();
            Test.stopTest();

            Integer number_of_saved_email_messages = [SELECT Count() FROM EmailMessage];
            System.assertEquals(1, number_of_saved_email_messages, 'Expected 1 Email Message to have been saved, instead there were ' + number_of_saved_email_messages);
        }
    }


    private class SetupDataClass {
        public User TestUser;
        public Case TestCase;

        public SetupDataClass(){
            setRunningUser();
            setTestCase();
        }

        private void setRunningUser() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'EmailMessage' AND LastName = 'BuilderTest' LIMIT 1];
        }

        private void setTestCase() {
            TestCase = [SELECT Id FROM Case LIMIT 1];
        }
    }

    @testSetup
    static void createAndInsertTestData() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('EmailMessage')
                                     .setLastName('BuilderTest')
                                     .save()
                                     .getRecord();

        System.runAs(test_user) {
            TriggerHandler.IsTriggerActive = false;
            createAndInsertCase();
            TriggerHandler.IsTriggerActive = true;
        }

    }

    static void createAndInsertCase() {
        Account test_account = AccountBuilder.getBuilder('CaseViewExtension').save().getRecord();
        Loan_Application__c test_loan = LoanApplicationBuilder.getBuilder(test_account).save().getRecord();
        CaseBuilder.getBuilder(test_account).setLoanApplication(test_loan).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save();
    }
}