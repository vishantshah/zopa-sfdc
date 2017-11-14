@isTest
private class LoanBuilderTest {
    private static final Integer BULK_SIZE = 100;

    static testMethod void testGetRecordMethodReturnsLoanRecord() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Sobject test_loan = setup_data.getBuilder().getRecord();
            Test.stopTest();
            System.assert(test_loan instanceof Loan__c, 'It should return a Loan object type');
        }
    }

    static testMethod void testSaveMethodInsertsTheAccount() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                setup_data.getBuilder().save();
                List<Loan__c> result_loans = [SELECT Id FROM Loan__c];
            Test.stopTest();
            System.assertEquals(1, result_loans.size(), 'The method must inserts one new loan application.');
        }
    }

    static testMethod void testSetLoanArrearsRatioMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Loan__c test_loan = setup_data.getBuilder().setArrearsRatio(1).getRecord();
            Test.stopTest();
            System.assertEquals(1, test_loan.Arrears_Ratio__c,
                                'The Loan Arrears_Ratio should be set to ' + 1 + ', but it is ' + test_loan.Arrears_Ratio__c + ' now.');
        }
    }

    static testMethod void testSetLoanStatusMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String LoanStatus = 'Sample status';
            Test.startTest();
                Loan__c test_loan = setup_data.getBuilder().setLoanStatus(LoanStatus).getRecord();
            Test.stopTest();
            System.assertEquals(LoanStatus, test_loan.State__c,
                                'The Loan Status should be set to ' + LoanStatus + ', but it is ' + test_loan.State__c + ' now.');
        }
    }

    static testMethod void testSetExternalIdMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String ExternalId = '1234-1234';
            Test.startTest();
                Loan__c test_loan = setup_data.getBuilder().setExternalId(ExternalId).getRecord();
            Test.stopTest();
            System.assertEquals(ExternalId, test_loan.Loan_Id__c,
                                'The Loan Amount should be set to ' + ExternalId + ', but it is ' + test_loan.Loan_Id__c + ' now.');
        }
    }

    static testMethod void testSetLoanMemberID(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String member_id = 'test';
            Test.startTest();
                Loan__c test_loan = setup_data.getBuilder().setMemberID(member_id).getRecord();
            Test.stopTest();
            System.assertEquals(member_id, test_loan.Member_ID__c,
                                'The Loan MemberID should be set to ' + member_id + ', but it is ' + test_loan.Member_ID__c + ' now.');
        }
    }

    static testMethod void testSetAccountDCAID(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Loan__c test_loan = setup_data.getBuilder().setAccountDCAID(setup_data.TestAccount.Id).getRecord();
            Test.stopTest();
            System.assertEquals(setup_data.TestAccount.Id, test_loan.AccountDCA__c,
                                'The Loan Account DCA ID should be set to ' + setup_data.TestAccount.Id + ', but it is ' + test_loan.AccountDCA__c + ' now.');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Account TestAccount;

        public SetupDataClass(){
            TestUser = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN).save().getRecord();
        }

        public LoanBuilder.Builder getBuilder() {
            TestAccount = AccountBuilder.getBuilder().setLastName().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).save().getRecord();
            return LoanBuilder.getBuilder(TestAccount);
        }
    }
}