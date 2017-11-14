@isTest
private class LoanNotesControllerTest {

    static testMethod void testInitControllerWithLoanId() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initController(true);
            Test.stopTest();
            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentLoanId, 'Should be equals LoanId');
            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentLoan.Id, 'Should be equals LoanId');
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'ErrorOnLoad should not be set');
        }
    }

    static testMethod void testInitControllerWithoutLoanId() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initController(false);
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentLoanId, 'CurrentLoanId should not be set');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentLoan, 'CurrentLoan should not be set');
            System.assertEquals('Loan Id is blank. Can\'t retrieve information.', setup_data.ClassUnderTest.ErrorOnLoad, 'ErrorOnLoad should be set with proper message');
        }
    }

    static testMethod void testGetIsZcp122IsEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-122');
        System.runAs(setup_data.TestUser) {
            setup_data.initController(true);
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp122IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-122 should be enabled');
        }
    }

    static testMethod void testGetIsZcp122IsDisable() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-122');
        System.runAs(setup_data.TestUser) {
            setup_data.initController(true);
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp122IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-122 should be disabled');
        }
    }

    static testMethod void testGetLoanNotes() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController(true);
            setup_data.setMockForResponse(true, 200, 12);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanNotes();
            Test.stopTest();
            System.assertEquals(12, setup_data.ClassUnderTest.ListNotes.size(), 'Should fill List Notes');
            System.assertEquals(LoanNotesController.QUANTUTY_RECORDS_FOR_DISPAY, setup_data.ClassUnderTest.ListLimitNotes.size(), 'Should fill List Limit Notes');
            System.assertEquals('05/05/2015 01:00', setup_data.ClassUnderTest.ListNotes.get(0).CreatedDate, 'Should fill ListNotes correctly');
            System.assertEquals('Daffy Duck', setup_data.ClassUnderTest.ListNotes.get(0).CreatedBy, 'Should fill ListNotes correctly');
            System.assertEquals('You\'re dethpicable.', setup_data.ClassUnderTest.ListNotes.get(0).Text, 'Should fill ListNotes correctly');
        }
    }

    static testMethod void testGetLoanNotesIncorrect() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController(true);
            setup_data.setMockForResponse(false, 500, 0);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanNotes();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.ListNotes.isEmpty(), 'Should not fill List Notes');
            System.assertEquals(true, setup_data.ClassUnderTest.ListLimitNotes.isEmpty(), 'Should not fill List Limit Notes');
        }
    }

    static testMethod void testGetIsNoNotesMessageVisible() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-122');
        System.runAs(setup_data.TestUser) {
            setup_data.initController(true);
            setup_data.setMockForResponse(true, 200, 4);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanNotes();
                Boolean result = setup_data.ClassUnderTest.getIsNoNotesMessageVisible();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be not visiable Loan Notes Block');
        }
    }

    static testMethod void testGetIsNoNotesMessageVisibleWithoutNotes() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-122');
        System.runAs(setup_data.TestUser) {
            setup_data.initController(true);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsNoNotesMessageVisible();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be visiable Loan Notes Block');
        }
    }

    static testMethod void testGetIsNoNotesMessageVisibleWithoutFeatureSwitch() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-122');
        System.runAs(setup_data.TestUser) {
            setup_data.initController(true);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsNoNotesMessageVisible();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be not visiable Loan Notes Block, when ZCP-122 disabled');
        }
    }

    static testMethod void testGetIsShowMoreVisible() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController(true);
            setup_data.setMockForResponse(true, 200, LoanNotesController.QUANTUTY_RECORDS_FOR_DISPAY + 1);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanNotes();
                Boolean result = setup_data.ClassUnderTest.getIsShowMoreVisible();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be visiable show more link');
        }
    }

    static testMethod void testGetIsShowMoreVisibleWithoutShowMoreLink() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController(true);
            setup_data.setMockForResponse(true, 200, LoanNotesController.QUANTUTY_RECORDS_FOR_DISPAY);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanNotes();
                Boolean result = setup_data.ClassUnderTest.getIsShowMoreVisible();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be not visiable show more link');
        }
    }

    static testMethod void testGetIsShowMoreVisibleWithoutrecords() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController(true);
            setup_data.setMockForResponse(true, 200, 0);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanNotes();
                Boolean result = setup_data.ClassUnderTest.getIsShowMoreVisible();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be not visiable show more link');
        }
    }

    private class SetupDataClass {
        public Account TestAccount;
        public User TestUser;
        public Loan__c TestLoan;
        public LoanNotesController ClassUnderTest;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'LoanNotesControllerTest' AND LastName = 'LoanNotesControllerTest' LIMIT 1];
        }

        public void initController(Boolean with_current_loan_id) {
            ClassUnderTest = new LoanNotesController();
            if(with_current_loan_id) {
                createLoan();
                ClassUnderTest.CurrentLoanId = TestLoan.Id;
            } else {
                ClassUnderTest.CurrentLoanId = null;
            }
        }

        public void setMockForResponse(Boolean is_success, Integer error_code, Integer counter_records) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandGetLoanNotesMock(is_success, error_code, counter_records));
        }

        private void createLoan(){
            createAccount();
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setLoanStatus('withdrawn')
                    .setArrearsRatio(2)
                    .setExternalId(Utility.getRandomString(8))
                    .save()
                    .getRecord();
        }

        private void createAccount() {
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('LoanNotesController')
                    .save()
                    .getRecord();
            TriggerHandler.IsTriggerActive = true;
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setFirstName('LoanNotesControllerTest')
                .setLastName('LoanNotesControllerTest')
                .save();
    }
}