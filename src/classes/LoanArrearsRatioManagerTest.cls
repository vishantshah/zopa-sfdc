@isTest
private class LoanArrearsRatioManagerTest {

    static testMethod void testCheckArrearsRatio() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestLoanNew(4);
            Test.startTest();
                LoanArrearsRatioManager.checkArrearsRatio(setup_data.TestLoan, setup_data.TestLoanNew);
            Test.stopTest();
            System.assertEquals(true, String.isBlank(setup_data.TestLoanNew.AccountDCA__c), 'DCA should be null, if arrears ratio more than 4');
        }
    }

    static testMethod void testCheckArrearsRatioWhenArrearsRatioNotChanged() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestLoanNew(0);
            Test.startTest();
                LoanArrearsRatioManager.checkArrearsRatio(setup_data.TestLoan, setup_data.TestLoanNew);
            Test.stopTest();
            System.assertEquals(false, String.isBlank(setup_data.TestLoanNew.AccountDCA__c), 'DCA should exist, if arrears ratio did not change');
        }
    }

    static testMethod void testCheckArrearsRatioWhenArrearsRatioLessThanFour() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestLoanNew(3);
            Test.startTest();
                LoanArrearsRatioManager.checkArrearsRatio(setup_data.TestLoan, setup_data.TestLoanNew);
            Test.stopTest();
            System.assertEquals(false, String.isBlank(setup_data.TestLoanNew.AccountDCA__c), 'DCA should exist, if arrears ratio less than 4');
        }
    }


    private class SetupDataClass {
        public Loan__c TestLoan;
        public Loan__c TestLoanNew;
        public User TestUser;
        public Account TestAccount;

        public SetupDataClass() {
            TestLoan = [SELECT id, Account__c, Arrears_Ratio__c FROM Loan__c LIMIT 1];
            TestUser = [SELECT Id FROM User WHERE LastName = 'LoanArrearsRatioManagerTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account WHERE Name = 'LoanArrearsRatioManagerTest' LIMIT 1];
        }

        public void createTestLoanNew(Decimal ratio){
            TestLoanNew = LoanBuilder.getBuilder(TestAccount).setArrearsRatio(ratio).setAccountDCAID(TestAccount.Id).save().getRecord();
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('LoanArrearsRatioManagerTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('LoanArrearsRatioManagerTest').save().getRecord();
            LoanBuilder.getBuilder(test_account).save();
        }
    }
}