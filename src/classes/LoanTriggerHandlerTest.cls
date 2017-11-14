@isTest
private class LoanTriggerHandlerTest {
    private static final Integer BULK_SIZE = 50;

    static testMethod void testInsertLoanWithoutLoanEvent() {
        SetupDataClass setup_data = new SetupDataClass();
        List<Loan__c> loan_list = setup_data.getListLoan(setup_data.testLoan);
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                insert loan_list;
            Test.stopTest();
            System.assertEquals(0, [SELECT COUNT() FROM Case WHERE RecordType.Name = :CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE], 'Cases not to be created');
        }
    }

    static testMethod void testInsertLoanWithCorrectLoanEvent() {
        SetupDataClass setup_data = new SetupDataClass();
        setup_data.TestLoan.Arrears_Ratio__c = 0.5;
        List<Loan__c> loan_list = setup_data.getListLoan(setup_data.TestLoan);
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                insert loan_list;
            Test.stopTest();
            System.assertEquals(BULK_SIZE, [SELECT COUNT() FROM Case WHERE RecordType.Name = :CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE], 'Should create ' + BULK_SIZE + ' cases with Record Type ' + CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE);
        }
    }

    static testMethod void testUpdateLoanWithPositiveRatio() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-76');
        List<Loan__c> loan_list = setup_data.getListLoan(setup_data.TestLoan);
        insert loan_list;
        for (Loan__c the_loan: loan_list){
            the_loan.Arrears_Ratio__c = 0.5;
        }
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                update loan_list;
            Test.stopTest();
            System.assertEquals(BULK_SIZE, [SELECT COUNT() FROM Case WHERE RecordType.Name = :CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE], 'Should create ' + BULK_SIZE + ' cases with Record Type ' + CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE);
        }
    }

    static testMethod void testUpdateLoanWithPositiveRatioFeatureSwitch104Disabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-76');
        FeatureSwitch.disable('ZCP-104');
        List<Loan__c> loan_list = setup_data.getListLoan(setup_data.TestLoan);
        insert loan_list;
        for (Loan__c the_loan: loan_list){
            the_loan.Arrears_Ratio__c = 0.5;
        }
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                update loan_list;
            Test.stopTest();
            System.assertEquals(0, [SELECT COUNT() FROM Case WHERE RecordType.Name = :CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE], 'Should create ' + BULK_SIZE + ' cases with Record Type ' + CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE);
        }
    }

    static testMethod void testUpdateLoanWithZeroRatio() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-76');
        FeatureSwitch.disable('ZCP-106');
        List<Loan__c> loan_list = setup_data.getListLoan(setup_data.TestLoan);
        insert loan_list;
        setup_data.createCases(loan_list.get(0));
        for (Loan__c the_loan: loan_list){
            the_loan.Arrears_Ratio__c = 0;
        }
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                update loan_list;
            Test.stopTest();
            System.assertEquals(BULK_SIZE, [SELECT COUNT() FROM Case WHERE IsClosed = true], 'Should close cases related to Loan');
        }
    }

    static testMethod void testUpdateLoanWithZeroRatioFeatureSwitch104Disabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-76');
        FeatureSwitch.disable('ZCP-104');
        FeatureSwitch.disable('ZCP-106');
        List<Loan__c> loan_list = setup_data.getListLoan(setup_data.TestLoan);
        insert loan_list;
        setup_data.createCases(loan_list.get(0));
        for (Loan__c the_loan: loan_list){
            the_loan.Arrears_Ratio__c = 0;
        }
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                update loan_list;
            Test.stopTest();
            System.assertEquals(0, [SELECT COUNT() FROM Case WHERE IsClosed = true], 'Should have not close cases related to Loan');
        }
    }

    static testMethod void testCreateLoansLinkedToAccounts() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-128');
        System.runAs(setup_data.TestUser) {
            setup_data.createAccountsWithMemberId();
            setup_data.createLoansWithoutAccount();

            Test.startTest();
                insert setup_data.TestLoans;
            Test.stopTest();

            setup_data.requeryTestLoans();
            for(Loan__c loan : setup_data.TestLoans){
                System.assertEquals(setup_data.TestAccountsByMemberId.get(loan.Member_ID__c).Id, loan.Account__c, 'Loan was linked to the incorrect account');
            }
        }
    }

    static testMethod void testUpdateLoanWithRatioEqualsFour() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-157');
        FeatureSwitch.enable('ZCP-104');
        List<Loan__c> loan_list = setup_data.getListLoanWithPositiveRatio(setup_data.TestLoan);
        insert loan_list;
        for (Loan__c the_loan: loan_list){
            the_loan.Arrears_Ratio__c = 4;
        }
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                update loan_list;
            Test.stopTest();
            System.assertEquals(BULK_SIZE, [SELECT COUNT() FROM Case WHERE Sub_Process__c = 'Pre-Default' AND Status = 'Pending'], 'Should set cases related to Loan as Pre-Default');
        }
    }

    static testMethod void testUpdateLoanWithPositiveRatioTwice() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-76');
        List<Loan__c> loan_list = setup_data.getListLoan(setup_data.TestLoan);
        insert loan_list;
        setup_data.updateLoanArrearsRatio(loan_list, 0.5);
        update loan_list;
        setup_data.updateLoanArrearsRatio(loan_list, 2);
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                update loan_list;
            Test.stopTest();
            System.assertEquals(BULK_SIZE, [SELECT COUNT() FROM Case WHERE RecordType.Name = :CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE], 'Should create only' + BULK_SIZE + ' cases and not duplicate it');
        }
    }

    static testMethod void testUpdatingCaseOnMissedPlanPayment() {
        SetupDataClass setup_data = new SetupDataClass();
        List<Loan__c> loan_list = setup_data.getListLoanWithPositiveRatio(setup_data.TestLoan);
        insert loan_list;
        setup_data.updateLoanDateOfLastMissedPlanPayment(loan_list);
        setup_data.addPreviousSubProcess('Arrangement Default', 'DCA');
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                update loan_list;
            Test.stopTest();

            List<Case> updated_cases = [SELECT Id, OwnerId, Sub_Process__c, Previous_Sub_Process__c FROM Case];
            for(Case updated_case : updated_cases){
                System.assertEquals('Broken Repayment Arrangement', updated_case.Sub_Process__c , 'Sub_Process was setted incorrect');
                System.assertEquals('Arrangement Default', updated_case.Previous_Sub_Process__c , 'Previous_Sub_Process was setted incorrect');
                System.assertEquals(CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD), updated_case.OwnerId , 'Case owner was setted incorrect');
            }

        }
    }

    static testMethod void testUpdatingLoanDCALinks() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-135');
        List<Loan__c> loan_list = setup_data.getListLoanWithPositiveRatio(setup_data.TestLoan);
        insert loan_list;

        System.runAs(setup_data.TestUser) {
            setup_data.setDCAAccountsToLoans(loan_list);
            DcaAccountLinkingHandler.getInstance().IsAlreadyUpdatedRecordsInTransaction = false;

            Test.startTest();
                update loan_list;
            Test.stopTest();

            List<Case> updated_cases = [SELECT Id, AccountDCA__c FROM Case];
            for(Case updated_case : updated_cases){
                System.assertEquals(setup_data.AccountDca.Id, updated_case.AccountDCA__c , 'Case was not linked to the DCA correctly');
            }
        }
    }


    private class SetupDataClass {
        public Loan__c TestLoan;
        public User TestUser;
        public Account TestAccount;
        public Map<String, Account> TestAccountsByMemberId;
        public List<Loan__c> TestLoans;
        public Account AccountDca;

        public SetupDataClass() {
            TestLoan = [SELECT id, Account__c, Arrears_Ratio__c, Loan_Id__c FROM Loan__c LIMIT 1];
            TestUser = [SELECT Id FROM User WHERE LastName = 'CreateCollectionsRecoveriesCaseTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account WHERE Name = 'CreateCollectionsRecoveriesCaseTest' LIMIT 1];
            AccountDca = [SELECT Id, Name, PersonContactId FROM Account WHERE Name = 'DcaAccount' LIMIT 1];
        }

        public List<Loan__c> getListLoan(Loan__c the_loan){
            List<Loan__c> loan_list = new List<Loan__c>();
            for(Integer i = 0; i < BULK_SIZE ; i++){
                Loan__c new_loan = the_loan.clone();
                new_loan.Loan_Id__c += i;
                loan_list.add(new_loan);
            }
            return loan_list;
        }

        public void createCases(Loan__c the_loan){
            insert CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setLoan(the_loan).getRecordList(BULK_SIZE);
        }

        public void createAccountsWithMemberId(){
           TestAccountsByMemberId = new Map<String, Account>();
            for( Integer i = 0; i < BULK_SIZE ;i++){
                TestAccountsByMemberId.put('test'+i, AccountBuilder.getBuilder('CreateCollectionsRecoveriesCaseTest').setMemberId('test'+i).getRecord());
            }
            insert TestAccountsByMemberId.values();
        }

        public void updateLoanArrearsRatio(List<Loan__c> loan_list, Decimal ratio){
            for (Loan__c the_loan: loan_list){
                the_loan.Arrears_Ratio__c = ratio;
            }
        }

        public void updateLoanDateOfLastMissedPlanPayment(List<Loan__c> loan_list){
            for (Loan__c the_loan : loan_list){
                the_loan.Date_Of_Last_Missed_Plan_Payment__c = Datetime.now().addDays(2);
            }
        }

        public List<Loan__c> getListLoanWithPositiveRatio(Loan__c the_loan){
            List<Loan__c> loan_list = new List<Loan__c>();
            the_loan.Arrears_Ratio__c = 1;
            for( Integer i = 0; i < BULK_SIZE ;i++){
                Loan__c new_loan = the_loan.clone();
                new_loan.Loan_Id__c += i;
                loan_list.add(new_loan);
            }
            return loan_list;
        }

        public void addPreviousSubProcess(String sub_process, String previous_sub_process){
            List<Case> cases_to_update = [SELECT Id, Sub_Process__c, Previous_Sub_Process__c FROM Case];
            for(Case case_to_update : cases_to_update){
                case_to_update.Sub_Process__c = previous_sub_process;
            }
            update cases_to_update;
            for(Case case_to_update : cases_to_update){
                case_to_update.Sub_Process__c = sub_process;
            }
            update cases_to_update;
        }

        public void createLoansWithoutAccount(){
            delete [SELECT Id FROM Loan__c];
            TestLoans = new List<Loan__c>();
            for( Integer i = 0; i < BULK_SIZE; i++){
                Loan__c new_loan = new Loan__c();
                new_loan.Member_ID__c = 'test'+i;
                TestLoans.add(new_loan);
            }
        }

        public void requeryTestLoans(){
            TestLoans = [SELECT id, Account__c, Member_ID__c FROM Loan__c];
        }

        public void setDCAAccountsToLoans(List<Loan__c> loan_list){
            for(Loan__c loan : loan_list){
                loan.AccountDCA__c = AccountDca.Id;
            }
        }

    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('CreateCollectionsRecoveriesCaseTest')
                .save()
                .getRecord();
        System.runAs(test_user) {
            FeatureSwitch.disable('ZCP-128');
            Account test_account = AccountBuilder.getBuilder('CreateCollectionsRecoveriesCaseTest').save().getRecord();
            Account dca = AccountBuilder.getBuilder('DcaAccount').save().getRecord();
            LoanBuilder.getBuilder(test_account).setExternalId('0000-0000-0000-0001').save();
        }
    }
}