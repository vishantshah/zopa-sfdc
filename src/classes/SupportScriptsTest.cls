@isTest
public class SupportScriptsTest {

    static testMethod void testCreateAccountReturnIdMethodReturnsIdOfNewAccount() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Id account_id = SupportScripts.createAccountReturnId('John');
            Test.stopTest();
            System.assertEquals(1, [SELECT Id FROM Account WHERE Id = :account_id].size(), 'Method must create one new account.');
        }
    }

    static testMethod void testCreateLoanApplicationWithCaseCodes() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Test.startTest();
                SupportScripts.createLoanApplicationWithCaseCodes(setup_data.TestAccount, 'Sample case codes' , 'Sample case codes', 'Sample case codes', true);
            Test.stopTest();
            setup_data.queryLoan();
            System.assertEquals('Sample case codes', setup_data.TestLoan.Triggered_Referral_Codes__c, 'Method must create new loan application with Referral_Codes__c.');
            System.assertEquals('Sample case codes', setup_data.TestLoan.Aborted_Referral_Codes__c, 'Method must create new loan application with Referral_Codes__c.');
            System.assertEquals('Sample case codes', setup_data.TestLoan.Errored_Referral_Codes__c, 'Method must create new loan application with Referral_Codes__c.');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Account TestAccount;
        public Loan_Application__c TestLoan;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE LastName = 'SupportScriptsTest' LIMIT 1];
        }

        public void createTestAccount() {
            TestAccount = AccountBuilder.getBuilder('Test').save().getRecord();
        }

        public void queryLoan() {
            TestLoan = [SELECT Triggered_Referral_Codes__c, Aborted_Referral_Codes__c, Errored_Referral_Codes__c FROM Loan_Application__c WHERE Customer_Account__c = :TestAccount.Id];
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('SupportScriptsTest')
                                     .save();
    }
}