@isTest
private class CasePopulateEmailFieldFromAccountTest {
    private static final String NEW_ACCOUNT_EMAIL = 'new@email.test';

    static testMethod void testInitVariables() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertNotEquals(null, setup_data.ClassUnderTest.AllCasesToUpdate, 'Should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.AccountIdToUnderwritingCasesToUpdate, 'Should be initialized');
        }
    }

    static testMethod void testqueryAllCasesForAccountInContextNoCases() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.removeTestCases();
            Test.startTest();
                setup_data.ClassUnderTest.queryAllCasesForAccountInContext(new Map<Id, sObject>{setup_data.TestAccount.Id => setup_data.TestAccount});
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AccountIdToUnderwritingCasesToUpdate.size(), 'Should get only one Account ');
            System.assertEquals(0, setup_data.ClassUnderTest.AccountIdToUnderwritingCasesToUpdate.get(setup_data.TestAccount.Id).size(), 'Should get no Cases ');
        }
    }

    static testMethod void testqueryAllCasesForAccountInContextQueryOneCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.queryAllCasesForAccountInContext(new Map<Id, sObject>{setup_data.TestAccount.Id => setup_data.TestAccount});
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AccountIdToUnderwritingCasesToUpdate.size(), 'Should get only one Account ');
            System.assertEquals(1, setup_data.ClassUnderTest.AccountIdToUnderwritingCasesToUpdate.get(setup_data.TestAccount.Id).size(), 'Should get only one Case ');
        }
    }

    static testMethod void testPopulateEmailFieldOnManualUnderwitingCaseNoCases() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.removeTestCases();
            setup_data.fillUnderwritingCasesForAccountMap();
            setup_data.updateAccountEmail();
            Test.startTest();
                setup_data.ClassUnderTest.populateEmailFieldOnManualUnderwitingCase(setup_data.TestOldAccount, setup_data.TestAccount);
            Test.stopTest();
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should not add case to update');
        }
    }

    static testMethod void testPopulateEmailFieldOnManualUnderwitingCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.fillUnderwritingCasesForAccountMap();
            setup_data.updateAccountEmail();
            Test.startTest();
                setup_data.ClassUnderTest.populateEmailFieldOnManualUnderwitingCase(setup_data.TestOldAccount, setup_data.TestAccount);
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should add case to update');
            System.assertEquals(NEW_ACCOUNT_EMAIL, setup_data.ClassUnderTest.AllCasesToUpdate[0].Workflow_Emailing_Person_Account__c, 'Should update email');
        }
    }

    static testMethod void testUpdateAllCasesNoRecords() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Integer dml_operations = -Limits.getDMLRows();
                setup_data.ClassUnderTest.updateAllCases();
                dml_operations += Limits.getDMLRows();
            Test.stopTest();
            System.assertEquals(0, dml_operations, 'Should not process any dml, when there is no records');
        }
    }

    static testMethod void testUpdateAllCases() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-59');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.fillUnderwritingCasesForAccountMap();
            setup_data.updateAccountEmail();
            setup_data.ClassUnderTest.populateEmailFieldOnManualUnderwitingCase(setup_data.TestOldAccount, setup_data.TestAccount);
            Test.startTest();
                Integer dml_operations = -Limits.getDMLRows();
                setup_data.ClassUnderTest.updateAllCases();
                dml_operations += Limits.getDMLRows();
                Test.stopTest();
            System.assertEquals(1, dml_operations, 'Should process one dml');
            System.assertEquals(0, setup_data.ClassUnderTest.AllCasesToUpdate.size(), 'Should clear list');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public CasePopulateEmailFieldFromAccount ClassUnderTest;
        public Account TestAccount;
        public Account TestOldAccount;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'CasePopulateEmailFieldFromAccountTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = CasePopulateEmailFieldFromAccount.getInstance();
        }

        public void updateAccountEmail() {
            TestOldAccount = TestAccount.clone(true, true);
            TestAccount.PersonEmail = NEW_ACCOUNT_EMAIL;
        }

        public void fillUnderwritingCasesForAccountMap() {
            ClassUnderTest.queryAllCasesForAccountInContext(new Map<Id, sObject>{TestAccount.Id => TestAccount});
        }

        public void removeTestCases() {
            delete [SELECT id FROM Case];
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('CasePopulateEmailFieldFromAccountTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('CasePopulateEmailFieldFromAccountTest').save().getRecord();
            FeatureSwitch.enable('ZOPA-4');
            LoanApplicationBuilder.getBuilder(test_account).setApplicationStatus('RequiresManualUnderwriting').save();
        }
    }
}