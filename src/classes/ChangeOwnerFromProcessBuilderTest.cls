@isTest
public class ChangeOwnerFromProcessBuilderTest {

    static testMethod void testChangeOwnerId() {
            SetupDataClass setup_data = new SetupDataClass();
            System.runAs(setup_data.TestUser) {
                setup_data.createTestListRequest();
                Test.startTest();
                    ChangeOwnerFromProcessBuilder.changeOwnerIdOnCase(setup_data.TestListRequests);
                Test.stopTest();
                Integer number_of_correctly_updated_cases_from_process_builder = [SELECT COUNT() FROM Case WHERE id = :setup_data.TestCase.id];
                System.assertEquals(1, number_of_correctly_updated_cases_from_process_builder);
            }
        }

    private class SetupDataClass {
        public Case TestCase;
        public Loan__c TestLoan;
        public Account TestAccount;
        public User TestUser;
        public Group TestQueue;
        public List<ChangeOwnerFromProcessBuilder.ConvertCaseActionRequest> TestListRequests;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'ChangeOwnerFromProcessBuilderTest' LIMIT 1];
            TestQueue = [SELECT Id, Name FROM Group WHERE Name = 'ChangeOwnerFromProcessBuilderTest' LIMIT 1];
            TestAccount = [SELECT id, Name, PersonContactId FROM Account WHERE Name = 'ChangeOwnerFromProcessBuilderTestAccount' LIMIT 1];
            createLoan();
            createCollectionsRecoveriesCase();
        }

        public void createCollectionsRecoveriesCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setLoan(TestLoan).save().getRecord();
        }

        public void createLoan(){
            TestLoan = LoanBuilder.getBuilder(TestAccount).setArrearsRatio(1).save().getRecord();
        }

        public void createTestListRequest(){
            ChangeOwnerFromProcessBuilder.ConvertCaseActionRequest the_request = new ChangeOwnerFromProcessBuilder.ConvertCaseActionRequest();
            the_request.TheCase = TestCase;
            the_request.OwnerName = TestQueue.Name;
            TestListRequests = new List<ChangeOwnerFromProcessBuilder.ConvertCaseActionRequest>{the_request};
        }

        public void changeLoanState(String state){
            LoanBuilder.getBuilder(TestLoan).setLoanStatus(state).save().getRecord();
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('ChangeOwnerFromProcessBuilderTest')
                                     .save().getRecord();
        Group test_group = new Group(Name='ChangeOwnerFromProcessBuilderTest', Type='Queue');
        insert test_group;
        System.runAs(test_user) {
            QueuesObject test_queue = new QueueSObject(QueueID = test_group.id, SObjectType = 'Case');
            insert test_queue;
            AccountBuilder.getBuilder('ChangeOwnerFromProcessBuilderTestAccount').save().getRecord();
        }
    }
}