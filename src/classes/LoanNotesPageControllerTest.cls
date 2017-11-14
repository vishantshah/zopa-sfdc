@isTest
private class LoanNotesPageControllerTest {

    static testMethod void testChangeLoanStatusToRialtoToCollectionsSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initController();
            Test.stopTest();
            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentLoan.Id, 'Should be equals Loan');
        }
    }

    static testMethod void testGetLoanNotes() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setMockForResponse(true, 200, 12);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanNotes();
            Test.stopTest();
            System.assertEquals(12, setup_data.ClassUnderTest.ListNotes.size(), 'Should fill List Notes');
            System.assertEquals('05/05/2015 01:00', setup_data.ClassUnderTest.ListNotes.get(0).CreatedDate, 'Should fill ListNotes correctly');
            System.assertEquals('Daffy Duck', setup_data.ClassUnderTest.ListNotes.get(0).CreatedBy, 'Should fill ListNotes correctly');
            System.assertEquals('You\'re dethpicable.', setup_data.ClassUnderTest.ListNotes.get(0).Text, 'Should fill ListNotes correctly');
        }
    }

    static testMethod void testGetLoanNotesIncorrect() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setMockForResponse(false, 500, 0);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanNotes();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.ListNotes.isEmpty(), 'Should not fill List Notes');
        }
    }

    private class SetupDataClass {
        public Account TestAccount;
        public User TestUser;
        public Loan__c TestLoan;
        public LoanNotesPageController ClassUnderTest;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'LoanNotesPageControllerTest' AND LastName = 'LoanNotesPageControllerTest' LIMIT 1];
        }

        public void initController() {
            createLoan();
            ClassUnderTest = new LoanNotesPageController(new ApexPages.StandardController(TestLoan));
        }

        public void setMockForResponse(Boolean is_success, Integer error_code, Integer counter_records) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandGetLoanNotesMock(is_success, error_code, counter_records));
        }

        private void createLoan(){
            createAccount();
            TestLoan = LoanBuilder.getBuilder(TestAccount).setLoanStatus('withdrawn').setArrearsRatio(2).setExternalId(Utility.getRandomString(8)).save().getRecord();
        }

        private void createAccount() {
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('LoanNotesPageController').save().getRecord();
            TriggerHandler.IsTriggerActive = true;
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('LoanNotesPageControllerTest')
                                     .setLastName('LoanNotesPageControllerTest')
                                     .save();
    }
}