@IsTest
public class CaseOnChangeStopCommunicationHandlerTest {
    private static final String COLLECTIONS_USER = 'TestUserLastName';

    static testMethod void testChangeNextReviewDateOnUpdateCaseIfStopCommunicationChanged() {
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createAccount();
            setup_data.createLoanForAccount(0);
            setup_data.setMockForPutStopCommunicationResponse(true);

            Case old_case_with_change = setup_data.createCollectionsRecoveriesCase();
            Case new_case_with_change = old_case_with_change.clone();
            DateTime test_time = Datetime.now();
            new_case_with_change.Stop_Communication_Until__c = test_time;

            Case old_case_without_change = setup_data.createCollectionsRecoveriesCase();
            Case new_case_without_change = old_case_without_change.clone();

            List<Case> old_list = new List<Case> {old_case_with_change, old_case_without_change};
            List<Case> new_list = new List<Case> {new_case_with_change, new_case_without_change};

            Test.startTest();
                CaseOnChangeStopCommunicationHandler.changeNextReviewDateIfStopCommunicationUntilChanged(old_list, new_list);
            Test.stopTest();

            System.assertEquals(test_time, new_case_with_change.Next_Review_Date__c, 'Next Review Date is populated because Stop Communication Until has changed.');
            System.assertEquals(null, new_case_without_change.Next_Review_Date__c, 'Next Review Date is not populated because Stop Communication Until has not changed.');
        }
    }

    static testMethod void testChangeNextReviewDateOnUpdateCaseIfStopCommunicationNotChanged() {
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createAccount();
            setup_data.createLoanForAccount(0);
            setup_data.setMockForPutStopCommunicationResponse(true);
            Case old_case = setup_data.createCollectionsRecoveriesCase();
            Case new_case = old_case.clone(true, true);
            List<Case> old_list = new List<Case> {old_case};
            List<Case> new_list = new List<Case> {new_case};

            Test.startTest();
                CaseOnChangeStopCommunicationHandler.changeNextReviewDateIfStopCommunicationUntilChanged(old_list, new_list);
            Test.stopTest();

            System.assertEquals(null, new_case.Next_Review_Date__c, 'Next Review Date should not be changed if Stop Communication Until has not changed.');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Account TestAccount;
        public Loan__c TestLoan;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        public void createAccount(){
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('TestAccountName').save().getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        private void createLoanForAccount(Decimal arrears_ratio){
            TriggerHandler.IsTriggerActive = false;
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                .setArrearsRatio(arrears_ratio)
                .setExternalId(Utility.getRandomString(8))
                .save()
                .getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public Case createCollectionsRecoveriesCase() {
            TriggerHandler.IsTriggerActive = false;
            Case test_case = CaseBuilder.getBuilder(TestAccount)
                .setOwner(TestUser.Id)
                .setLoan(TestLoan)
                .setStatus('Open')
                .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                .save()
                .getRecord();
            TriggerHandler.IsTriggerActive = true;
            return test_case;
        }

        public void setMockForPutStopCommunicationResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandPutStopCommunicationDateMock(is_success));
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest()
            .setProfile(ProfileUtilities.ProfileType.COLLECTIONS)
            .setFirstName('TestUserFirstName')
            .setLastName(COLLECTIONS_USER)
            .save()
            .getRecord();
    }
}