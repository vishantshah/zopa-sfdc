@isTest
public class UnassignDcaHelperTest {

    static testMethod void testChangeCasesAfterUnassignDcaCollectionsProcess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.changeCaseProcess(CaseUtility.CASE_PROCESS_COLLECTIONS);
            Test.startTest();
                UnassignDcaHelper.changeCasesAfterUnassignDca(new List<Id>{setup_data.TestLoan.Id});
            Test.stopTest();
            Integer number_of_correctly_updated_cases_from_process_builder = [SELECT COUNT() FROM Case WHERE id = :setup_data.TestCase.id AND Sub_Process__c = 'Collections' AND Status = 'Open - Need to Contact' AND AccountDCA__c = null];
            System.assertEquals(1, number_of_correctly_updated_cases_from_process_builder);
        }
    }

    static testMethod void testChangeCasesAfterUnassignDcaCollectionsProcessRecoveriesProcess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.changeCaseProcess(CaseUtility.CASE_PROCESS_RECOVERIES);
            Test.startTest();
                UnassignDcaHelper.changeCasesAfterUnassignDca(new List<Id>{setup_data.TestLoan.Id});
            Test.stopTest();
            Integer number_of_correctly_updated_cases_from_process_builder = [SELECT COUNT() FROM Case WHERE id = :setup_data.TestCase.id AND Sub_Process__c = 'Litigation' AND Status = 'Open - Need to Contact' AND AccountDCA__c = null];
            System.assertEquals(1, number_of_correctly_updated_cases_from_process_builder);
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Loan__c TestLoan;
        public Account TestAccount;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'UnassignDcaHelperTest' LIMIT 1];
            TestAccount = [SELECT id, Name, PersonContactId FROM Account WHERE Name = 'UnassignDcaHelperTestAccount' LIMIT 1];
            createLoan();
            createCollectionsRecoveriesCase();
        }

        public void createCollectionsRecoveriesCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setLoan(TestLoan).save().getRecord();
        }

        public void createLoan(){
            TestLoan = LoanBuilder.getBuilder(TestAccount).setExternalId('0000-0000-0000-0001').setArrearsRatio(0).save().getRecord();
        }

        public void changeCaseProcess(String new_process){
            TestCase = CaseBuilder.getBuilder(TestCase).setProcess(new_process).save().getRecord();
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('UnassignDcaHelperTest')
                                     .save()
                                     .getRecord();
        System.runAs(test_user){
            AccountBuilder.getBuilder('UnassignDcaHelperTestAccount').save().getRecord();
        }
    }
}