@isTest
private class LoanToAccountLinkerTest {
    private static final String MEMBER_ID = '001100';

    static testMethod void testGettingAllAccountIdsByMemberIds() {
        SetupDataClass setup_data = new SetupDataClass();

        System.runAs(setup_data.TestUser) {
            Test.startTest();
                LoanToAccountLinker.getInstance().getAllAccountIdsByMemberIds(new List<Loan__c>{setup_data.TestLoan});
            Test.stopTest();
            System.assertEquals(setup_data.TestAccount.Id, LoanToAccountLinker.getInstance().MemberIdToAccountIdMap.get(MEMBER_ID), 'Map of Member Ids to account Ids was setted incorrect');
        }
    }

    static testMethod void testSettingAccountIdForLoan() {
        SetupDataClass setup_data = new SetupDataClass();
        LoanToAccountLinker.getInstance().getAllAccountIdsByMemberIds(new List<Loan__c>{setup_data.TestLoan});

        System.runAs(setup_data.TestUser) {
            Test.startTest();
                LoanToAccountLinker.getInstance().setAccountIdForLoan(setup_data.TestLoan);
            Test.stopTest();
            System.assertEquals(setup_data.TestAccount.Id, setup_data.TestLoan.Account__c, 'AccountId was setted incorrect to Loan');
        }
    }

    private class SetupDataClass {
        public Loan__c TestLoan;
        public User TestUser;
        public Account TestAccount;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'LoanToAccountLinkerTest' LIMIT 1];
            createTestAccount();
            createTestLoan();
        }

        public void createTestAccount(){
            TestAccount = AccountBuilder.getBuilder('LoanToAccountLinkerTest').setMemberId(MEMBER_ID).save().getRecord();
        }

        public void createTestLoan(){
            TestLoan = LoanBuilder.getBuilder(new Loan__c()).setMemberID(MEMBER_ID).getRecord();
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('LoanToAccountLinkerTest')
                                     .save().getRecord();
    }
}