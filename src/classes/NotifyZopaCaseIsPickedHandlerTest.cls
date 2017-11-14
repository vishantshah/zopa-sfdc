@isTest
private class NotifyZopaCaseIsPickedHandlerTest {

    static testMethod void testCheckIfCaseIsPickedUpForTheFirstTimeAddsItemToList() {
        SetupDataClass setup_data = new SetupDataClass();
         setup_data.createTestCase();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                NotifyZopaCaseIsPickedHandler.getInstance().checkIfCaseIsPickedUpForTheFirstTime(setup_data.TestCase);
            Test.stopTest();
            setup_data.requeryCase();

            System.assertEquals(1, NotifyZopaCaseIsPickedHandler.getInstance().CaseToBeMarkedAsFirstTimePicked.size(), 'Case is not added to list');
        }
    }

    static testMethod void testMarkCasesAsFirstTimePickedAndSendCalloutsSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
         setup_data.createTestCase();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            NotifyZopaCaseIsPickedHandler.getInstance().checkIfCaseIsPickedUpForTheFirstTime(setup_data.TestCase);
            Test.startTest();
                NotifyZopaCaseIsPickedHandler.getInstance().markCasesAsFirstTimePickedAndSendCallouts();
            Test.stopTest();
            setup_data.requeryCase();

            System.assertEquals(true, setup_data.TestCase.First_Time_Picked__c, 'Case should have been marked as picked');
            System.assertEquals(1, ApiTakeCaseOwnershipTestMock.CommandsSent, 'Command should have been sent');
            System.assertEquals(0, NotifyZopaCaseIsPickedHandler.getInstance().CaseToBeMarkedAsFirstTimePicked.size(), 'List of ids is not cleared');
        }
    }

    static testMethod void testMarkCasesAsFirstTimePickedAndSendCalloutsErrorResponse() {
        SetupDataClass setup_data = new SetupDataClass();
         setup_data.createTestCase();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(false);
            NotifyZopaCaseIsPickedHandler.getInstance().checkIfCaseIsPickedUpForTheFirstTime(setup_data.TestCase);
            Test.startTest();
                NotifyZopaCaseIsPickedHandler.getInstance().markCasesAsFirstTimePickedAndSendCallouts();
            Test.stopTest();
            setup_data.requeryCase();

            System.assertEquals(true, setup_data.TestCase.First_Time_Picked__c, 'Case should have been marked as picked');
            System.assertEquals(1, ApiTakeCaseOwnershipTestMock.CommandsSent, 'Command should have been sent');
            System.assertEquals(0, NotifyZopaCaseIsPickedHandler.getInstance().CaseToBeMarkedAsFirstTimePicked.size(), 'List of ids is not cleared');
        }
    }

    static testMethod void testCheckIfCaseIsPickedUpForTheFirstTimeDifferentCase() {
        SetupDataClass setup_data = new SetupDataClass();
        Case test_case = CaseBuilder.getBuilder(setup_data.TestAccount).setLoanApplication(setup_data.TestLoanApplication).setRecordType(RecordTypeUtility.CASE_TECH_SUPPORT).save().getRecord();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                NotifyZopaCaseIsPickedHandler.getInstance().checkIfCaseIsPickedUpForTheFirstTime(test_case);
            Test.stopTest();

            System.assertEquals(0, NotifyZopaCaseIsPickedHandler.getInstance().CaseToBeMarkedAsFirstTimePicked.size(), 'Case is added to list');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Loan_Application__c TestLoanApplication;
        public Account TestAccount;
        public User TestUser;

        public SetupDataClass() {
            FeatureSwitch.disable('ZOPA-59');
            TestAccount = AccountBuilder.getBuilder('CaseViewLoanDetailsExtenstion').save().getRecord();
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setExpiryDate(System.now()).setExternalId(Utility.getRandomString(8)).save().getRecord();
            TestUser = [SELECT Id FROM User WHERE FirstName = 'NotifyZopaCaseIsPickedHandlerTest' AND LastName = 'NotifyZopaCaseIsPickedHandlerTest' LIMIT 1];
        }

        public void createTestCase(){
            TestCase = CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void setMockForResponse(Boolean is_success) {
            ApiTakeCaseOwnershipTestMock.SetIsSuccess = is_success;
        }

        public void requeryCase(){
            TestCase = [SELECT First_Time_Picked__c FROM Case WHERE Id = :TestCase.Id];
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('NotifyZopaCaseIsPickedHandlerTest')
                                     .setLastName('NotifyZopaCaseIsPickedHandlerTest')
                                     .save();
    }
}