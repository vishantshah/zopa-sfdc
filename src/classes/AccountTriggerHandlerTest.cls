@isTest
private class AccountTriggerHandlerTest {
    private static final Integer BULK_SIZE = 100;
    private static final String NEW_ACCOUNT_EMAIL = 'new@email.test';

    static testMethod void testBulkUpdateAccountEmailField() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.updateAccountsWithNewEmail();
            Test.stopTest();
            for (Case case_to_check : setup_data.TestCases) {
                System.assertEquals(NEW_ACCOUNT_EMAIL, case_to_check.Workflow_Emailing_Person_Account__c, 'Should be populated');
            }
        }
    }

    private class SetupDataClass {
        public List<Case> TestCases;
        public User TestUser;
        public List<Account> TestAccountBulk;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'AccountTriggerHandlerTest' LIMIT 1];
            TestAccountBulk = [SELECT Id FROM Account];
        }

        public void updateAccountsWithNewEmail() {
            for (Account customer_account : TestAccountBulk) {
                customer_account.PersonEmail = NEW_ACCOUNT_EMAIL;
            }
            update TestAccountBulk;
            queryCases();
        }

        public void queryCases() {
            TestCases = [SELECT Workflow_Emailing_Person_Account__c FROM Case WHERE MemberID__c in :new Map<Id, Account>(TestAccountBulk).keyset() AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)];
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('AccountTriggerHandlerTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            List<Account> test_accounts = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setLastName('AccountTriggerHandlerTest').getRecordList(BULK_SIZE);
            System.debug(test_accounts);
            insert test_accounts;
            FeatureSwitch.enable('ZOPA-4');
            List<Loan_Application__c> loans = new List<Loan_Application__c>();
            for (Account customer_account : test_accounts) {
                loans.add(LoanApplicationBuilder.getBuilder(customer_account).getRecord());
            }
            insert loans;
        }
    }
}