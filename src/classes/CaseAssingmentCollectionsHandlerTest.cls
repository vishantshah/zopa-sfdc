@isTest
public class CaseAssingmentCollectionsHandlerTest {
    static Integer BULK_SIZE = 10;

    static testMethod void testAssignCaseToArrears() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccout();
            setup_data.createTestCases();

            Test.startTest();
                Integer dml_rows = -Limits.getDMLRows();
                CaseAssingmentCollectionsHandler.assignCaseToCollections(setup_data.getCaseIdsAsList());
                dml_rows += Limits.getDMLRows();
            Test.stopTest();

            System.assertEquals(BULK_SIZE, dml_rows, 'Should perform update on all cases.');
        }
    }

    private class SetupDataClass {
        public Map<Id, Case> TestCases;
        public User TestUser;
        public Account TestAccount;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' AND FirstName = 'TestFirstName' LIMIT 1];
        }

        public void createTestAccout() {
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .setRecordType(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT)
                    .save()
                    .getRecord();
        }

        public void createTestCases() {
            List<Case> cases = CaseBuilder.getBuilder(TestAccount)
                    .setOwner(TestUser.Id)
                    .setStatus('Open')
                    .setRecordType(RecordTypeUtility.CASE_CUSTOMER)
                    .getRecordList(BULK_SIZE);
            insert cases;
            TestCases = new Map<Id, Case>(cases);
        }

        public List<Id> getCaseIdsAsList() {
            return new List<Id>(TestCases.keySet());
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.COLLECTIONS)
                .setFirstName('TestFirstName')
                .setLastName('TestLastName')
                .save()
                .getRecord();
    }
}