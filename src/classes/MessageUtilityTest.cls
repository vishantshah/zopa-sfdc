@isTest
private class MessageUtilityTest {

    static testMethod void testGetCommaSepperatedListOfAllPageMessagesDetail(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.CaseView);
            Test.startTest();
                MessageUtility.addErrorPageMessage('Russell');
                MessageUtility.addFatalPageMessage('Keenan');
                String all_page_messages = MessageUtility.getAllPageMessagesDetailForCurrentPage();
            Test.stopTest();
            System.assert(all_page_messages.contains('Russell'), 'The method should have contained "Russell" as it was included in a Page Message');
            System.assert(all_page_messages.contains('Keenan'), 'The method should have contained "Keenan" as it was included in a Page Message');
        }
    }

    static testMethod void testCheckListContentsTrue(){
        setupErrors setupErrors = new setupErrors();
        test.startTest();
            Boolean isMessageFound = MessageUtility.checkListContents('test fatal error', setupErrors.Messages, true);
        test.stopTest();
        System.assertEquals(true, isMessageFound);
    }

    static testMethod void testCheckListContentsFalse(){
        setupErrors setupErrors = new setupErrors();
        test.startTest();
            Boolean isMessageFound = MessageUtility.checkListContents('asd', setupErrors.Messages, true);
        test.stopTest();
        System.assertEquals(false, isMessageFound);
    }

    static testMethod void testAddErrorPageMessage(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.CaseView);
            test.startTest();
                MessageUtility.addErrorPageMessage('Test error');
            test.stopTest();
            System.assert(ApexPages.hasMessages());
            System.assert(MessageUtility.CheckListContents('Test error', ApexPages.getMessages(), true));
            system.assertEquals(ApexPages.Severity.ERROR,ApexPages.getMessages().get(0).getSeverity());
        }
    }

    static testMethod void testAddFatalPageMessage(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.CaseView);
            test.startTest();
                MessageUtility.addFatalPageMessage('Test fatal');
            test.stopTest();
            System.assert(ApexPages.hasMessages());
            System.assert(MessageUtility.CheckListContents('Test fatal', ApexPages.getMessages(), true));
            system.assertEquals(ApexPages.Severity.FATAL,ApexPages.getMessages().get(0).getSeverity());
        }
    }

    static testMethod void testAddWarningPageMessage(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.CaseView);
            test.startTest();
                MessageUtility.addWarningPageMessage('Test warning');
            test.stopTest();
            System.assert(ApexPages.hasMessages());
            System.assert(MessageUtility.CheckListContents('Test warning', ApexPages.getMessages(), true));
            system.assertEquals(ApexPages.Severity.WARNING,ApexPages.getMessages().get(0).getSeverity());
        }
    }

    static testMethod void testAddInfoPageMessage(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.CaseView);
            test.startTest();
                MessageUtility.addInfoPageMessage('Test info');
            test.stopTest();
            System.assert(ApexPages.hasMessages());
            System.assert(MessageUtility.CheckListContents('Test info', ApexPages.getMessages(), true));
            system.assertEquals(ApexPages.Severity.INFO,ApexPages.getMessages().get(0).getSeverity());
        }
    }

    static testMethod void testAddConfirmPageMessage(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.CaseView);
            test.startTest();
                MessageUtility.addConfirmPageMessage('Test info');
            test.stopTest();
            System.assert(ApexPages.hasMessages());
            System.assert(MessageUtility.CheckListContents('Test info', ApexPages.getMessages(), true));
            system.assertEquals(ApexPages.Severity.CONFIRM,ApexPages.getMessages().get(0).getSeverity());
        }
    }

    static testMethod void testAddErrorPopulatesTheMessagesList(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            MessageUtility page_messages = new MessageUtility();
            test.startTest();
                page_messages.addError('Test error');
            test.stopTest();
            System.assertEquals(1, page_messages.Messages.size());
            System.assertEquals('Test error', page_messages.Messages.get(0).Summary);
        }
    }

    static testMethod void testAddInfoPopulatesTheMessagesList(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            MessageUtility page_messages = new MessageUtility();
            test.startTest();
                page_messages.addInfo('Test info');
            test.stopTest();
            System.assertEquals(1, page_messages.Messages.size());
            System.assertEquals('Test info', page_messages.Messages.get(0).Summary);
        }
    }

    static testMethod void testAddConfirmPopulatesTheMessagesList(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            MessageUtility page_messages = new MessageUtility();
            test.startTest();
                page_messages.addConfirm('Test confirm');
            test.stopTest();
            System.assertEquals(1, page_messages.Messages.size());
            System.assertEquals('Test confirm', page_messages.Messages.get(0).Summary);
        }
    }

    static testMethod void testARemoveErrorsClearsTheMessagesList(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            MessageUtility page_messages = new MessageUtility();
            page_messages.addInfo('Test info');
            test.startTest();
                page_messages.removeMessages();
            test.stopTest();
            System.assertEquals(0, page_messages.Messages.size());
        }
    }

    static testMethod void testAddingMultipleMessagesPopulatesTheMessagesListCorrectly(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            MessageUtility page_messages = new MessageUtility();
            test.startTest();
                page_messages.addInfo('Test info');
                page_messages.addError('Test error');
                page_messages.addInfo('Test info');
                page_messages.addError('Test error');
            test.stopTest();
            System.assertEquals(4, page_messages.Messages.size());
            System.assertEquals('Test info', page_messages.Messages.get(0).Summary);
            System.assertEquals('Test error', page_messages.Messages.get(1).Summary);
            System.assertEquals('Test info', page_messages.Messages.get(2).Summary);
            System.assertEquals('Test error', page_messages.Messages.get(3).Summary);
        }
    }

    static testMethod void testRemoveInfoMessagesOnlyRemovedInfoMessagesFromTheMessagesList(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            MessageUtility page_messages = new MessageUtility();
            page_messages.addInfo('Test info');
            page_messages.addError('Test error');
            page_messages.addConfirm('Test confirm');
            test.startTest();
                page_messages.removeInfoMessages();
            test.stopTest();
            System.assertEquals(2, page_messages.Messages.size());
            System.assertEquals('Test error', page_messages.Messages.get(0).Summary);
            System.assertEquals('Test confirm', page_messages.Messages.get(1).Summary);
        }
    }

     static testMethod void testAddErrorPageMessageDetail() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.CaseView);
            String message_summary = 'Test error summary';
            String message_detail = 'Test error detail';
            Test.startTest();
                MessageUtility.addErrorPageMessage(message_summary, message_detail);
            Test.stopTest();
            System.assertEquals(1, ApexPages.getMessages().size(), 'There should have been 1 Page Message');
            System.assertEquals(message_summary, ApexPages.getMessages().get(0).getSummary() , 'The message summary doesn\'t match');
            System.assertEquals(message_detail, ApexPages.getMessages().get(0).getDetail() , 'The message detail doesn\'t match');
            System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages().get(0).getSeverity(), 'The severity of the message is incorrect');
        }
    }

    static testMethod void testAddFatalPageMessageDetail() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.CaseView);
            String message_summary = 'Test fatal summary';
            String message_detail = 'Test fatal detail';
            Test.startTest();
                MessageUtility.addFatalPageMessage(message_summary, message_detail);
            Test.stopTest();
            System.assertEquals(1, ApexPages.getMessages().size(), 'There should have been 1 Page Message');
            System.assertEquals(message_summary, ApexPages.getMessages().get(0).getSummary() , 'The message summary doesn\'t match');
            System.assertEquals(message_detail, ApexPages.getMessages().get(0).getDetail() , 'The message detail doesn\'t match');
            System.assertEquals(ApexPages.Severity.FATAL, ApexPages.getMessages().get(0).getSeverity(), 'The severity of the message is incorrect');
        }
    }

    static testMethod void testAddWarningPageMessageDetail() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.CaseView);
            String message_summary = 'Test warning summary';
            String message_detail = 'Test warning detail';
            Test.startTest();
                MessageUtility.addWarningPageMessage(message_summary, message_detail);
            Test.stopTest();
            System.assertEquals(1, ApexPages.getMessages().size(), 'There should have been 1 Page Message');
            System.assertEquals(message_summary, ApexPages.getMessages().get(0).getSummary() , 'The message summary doesn\'t match');
            System.assertEquals(message_detail, ApexPages.getMessages().get(0).getDetail() , 'The message detail doesn\'t match');
            System.assertEquals(ApexPages.Severity.WARNING, ApexPages.getMessages().get(0).getSeverity(), 'The severity of the message is incorrect');
        }
    }

    static testMethod void testAddInfoPageMessageDetail() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.CaseView);
            String message_summary = 'Test info summary';
            String message_detail = 'Test info detail';
            Test.startTest();
                MessageUtility.addInfoPageMessage(message_summary, message_detail);
            Test.stopTest();
            System.assertEquals(1, ApexPages.getMessages().size(), 'There should have been 1 Page Message');
            System.assertEquals(message_summary, ApexPages.getMessages().get(0).getSummary() , 'The message summary doesn\'t match');
            System.assertEquals(message_detail, ApexPages.getMessages().get(0).getDetail() , 'The message detail doesn\'t match');
            System.assertEquals(ApexPages.Severity.INFO, ApexPages.getMessages().get(0).getSeverity(), 'The severity of the message is incorrect');
        }
    }

    static testMethod void testAddConfirmPageMessageDetail() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.CaseView);
            String message_summary = 'Test confirm summary';
            String message_detail = 'Test confirm detail';
            Test.startTest();
                MessageUtility.addConfirmPageMessage(message_summary, message_detail);
            Test.stopTest();
            System.assertEquals(1, ApexPages.getMessages().size(), 'There should have been 1 Page Message');
            System.assertEquals(message_summary, ApexPages.getMessages().get(0).getSummary() , 'The message summary doesn\'t match');
            System.assertEquals(message_detail, ApexPages.getMessages().get(0).getDetail() , 'The message detail doesn\'t match');
            System.assertEquals(ApexPages.Severity.CONFIRM, ApexPages.getMessages().get(0).getSeverity(), 'The severity of the message is incorrect');
        }
    }
    private class SetupDataClass {
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE LastName = 'MessageUtilityTest' LIMIT 1];
        }
    }

    private class setupErrors{
        public List<ApexPages.Message> Messages = new List<ApexPages.Message>();

        setupErrors(){
            AddError('test fatal error', ApexPages.Severity.FATAL);
            AddError('test info message', ApexPages.Severity.INFO);
            AddError('test confirm message', ApexPages.Severity.CONFIRM);
            AddError('test error error', ApexPages.Severity.ERROR);
        }

        private void addError(String ErrorText, ApexPages.Severity Severity){
            ApexPages.Message error = new ApexPages.Message(Severity, ErrorText);
            Messages.add(error);
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setLastName('MessageUtilityTest')
                                     .save();
    }
}