@isTest
private class LoanApplicationBuilderTest {

    static testMethod void testGetRecordMethodReturnsALoanApplicationRecord() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Sobject test_loan = setup_data.getBuilder().getRecord();
            Test.stopTest();
            System.assert(test_loan instanceof Loan_Application__c, 'It should return a Loan Application object type');
        }
    }

    static testMethod void testSaveMethodInsertsTheAccount() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                setup_data.getBuilder().save();
                List<Loan_Application__c> result_loans = [SELECT Id FROM Loan_Application__c];
            Test.stopTest();
            System.assertEquals(1, result_loans.size(), 'The method must inserts one new loan application.');
        }
    }

    static testMethod void testSetExpiryDateMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            DateTime expiry_date = System.now();
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setExpiryDate(expiry_date).getRecord();
            Test.stopTest();
            System.assertEquals(expiry_date, test_loan.Expiry_Date__c, 'The Expiry Date should be set to correctly');
        }
    }

    static testMethod void testSetApplicationDateMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            DateTime application_date = System.now();
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setApplicationDate(application_date).getRecord();
            Test.stopTest();
            System.assertEquals(application_date, test_loan.Loan_Application_Date__c, 'The Loan Application Date should be set to correctly');
        }
    }

    static testMethod void testSetApplicationNameMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String application_name = 'Test name';
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setApplicationName(application_name).getRecord();
            Test.stopTest();
            System.assertEquals(application_name, test_loan.Name,
                                'The Loan Application Name should be set to ' + application_name + ', but it is ' + test_loan.Name + ' now.');
        }
    }

    static testMethod void testSetApplicationAmountMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Decimal LoanApplicationAmount = 3549.87;
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setApplicationAmount(LoanApplicationAmount).getRecord();
            Test.stopTest();
            System.assertEquals(LoanApplicationAmount, test_loan.Loan_Application_Amount__c,
                                'The Loan Application Amount should be set to ' + LoanApplicationAmount + ', but it is ' + test_loan.Loan_Application_Amount__c + ' now.');
        }
    }

    static testMethod void testSetApplicationStatusMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String LoanApplicationStatus = 'Sample status';
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setApplicationStatus(LoanApplicationStatus).getRecord();
            Test.stopTest();
            System.assertEquals(LoanApplicationStatus, test_loan.Loan_Application_Status__c,
                                'The Loan Application Status should be set to ' + LoanApplicationStatus + ', but it is ' + test_loan.Loan_Application_Status__c + ' now.');
        }
    }

    static testMethod void testSetPurposeMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String Purpose = 'Sample Purpose';
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setPurpose(Purpose).getRecord();
            Test.stopTest();
            System.assertEquals(Purpose, test_loan.Purpose__c,
                                'The Purpose__c should be set to ' + Purpose + ', but it is ' + test_loan.Purpose__c + ' now.');
        }
    }

    static testMethod void testSetRateMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Decimal Rate = 9.02;
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setRate(Rate).getRecord();
            Test.stopTest();
            System.assertEquals(Rate, test_loan.Rate__c,
                                'The Rate__c should be set to ' + Rate + ', but it is ' + test_loan.Rate__c + ' now.');
        }
    }

    static testMethod void testSetFirstPaymentMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Decimal FirstPayment = 11.92;
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setFirstPayment(FirstPayment).getRecord();
            Test.stopTest();
            System.assertEquals(FirstPayment, test_loan.First_Payment__c,
                                'The First_Payment__c should be set to ' + FirstPayment + ', but it is ' + test_loan.First_Payment__c + ' now.');
        }
    }

    static testMethod void testSetPaymentDayMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Integer PaymentDay = 3;
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setPaymentDay(PaymentDay).getRecord();
            Test.stopTest();
            System.assertEquals(PaymentDay, test_loan.Payment_Day__c,
                                'The Payment_Day__c should be set to ' + PaymentDay + ', but it is ' + test_loan.Payment_Day__c + ' now.');
        }
    }

    static testMethod void testSetQuickPayMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Boolean QuickPay = true;
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setQuickPay(QuickPay).getRecord();
            Test.stopTest();
            System.assertEquals(QuickPay, test_loan.QuickPay__c,
                                'The QuickPay__c should be set to ' + QuickPay + ', but it is ' + test_loan.QuickPay__c + ' now.');
        }
    }

    static testMethod void testSetInstitutionMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String Institution = 'Sample Institution';
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setInstitution(Institution).getRecord();
            Test.stopTest();
            System.assertEquals(Institution, test_loan.Institution__c,
                                'The Institution__c should be set to ' + Institution + ', but it is ' + test_loan.Institution__c + ' now.');
        }
    }

    static testMethod void testSetTermMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Integer Term = 48;
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setTerm(Term).getRecord();
            Test.stopTest();
            System.assertEquals(Term, test_loan.Term__c,
                                'The Term__c should be set to ' + Term + ', but it is ' + test_loan.Term__c + ' now.');
        }
    }

    static testMethod void testSetAPRMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Decimal APR = 7.39;
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setAPR(APR).getRecord();
            Test.stopTest();
            System.assertEquals(APR, test_loan.APR__c,
                                'The APR__c should be set to ' + APR + ', but it is ' + test_loan.APR__c + ' now.');
        }
    }

    static testMethod void testSetFeeMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Decimal Fee = 5.33;
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setFee(Fee).getRecord();
            Test.stopTest();
            System.assertEquals(Fee, test_loan.Fee__c,
                                'The Fee__c should be set to ' + Fee + ', but it is ' + test_loan.Fee__c + ' now.');
        }
    }

    static testMethod void testSetBrokerMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String Broker = 'Sample broker';
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setBroker(Broker).getRecord();
            Test.stopTest();
            System.assertEquals(Broker, test_loan.Broker__c,
                                'The Broker__c should be set to ' + Broker + ', but it is ' + test_loan.Broker__c + ' now.');
        }
    }

    static testMethod void testSetMarketMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String Market = 'Sample market';
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setMarket(Market).getRecord();
            Test.stopTest();
            System.assertEquals(Market, test_loan.Market__c,
                                'The Market__c should be set to ' + Market + ', but it is ' + test_loan.Market__c + ' now.');
        }
    }

    static testMethod void testsetLoanIdMethodSetsCorrectValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            String loan_id = 'test_loan_id';
            Test.startTest();
                Loan_Application__c test_loan = setup_data.getBuilder().setLoanId(loan_id).getRecord();
            Test.stopTest();
            System.assertEquals(loan_id, test_loan.Loan_Id__c, 'The Loan_Id__c should be set to ' + loan_id + ', but it is ' + test_loan.Loan_Id__c + ' now.');
        }
    }

    static testMethod void testGetCaseList(){
        SetupDataClass setup_data = new SetupDataClass();
        Integer number_of_loans = 123;
        System.runAs(setup_data.TestUser){
            Test.startTest();
                List<Loan_Application__c> loan_list = setup_data.getBuilder().getRecordList(number_of_loans);
            Test.stopTest();
            System.assertEquals(number_of_loans, loan_list.size() , 'List of loans has wrong size');
        }
    }

    private class SetupDataClass {
        public User TestUser;

        public SetupDataClass(){
            TestUser = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP).save().getRecord();
        }

        public LoanApplicationBuilder.Builder getBuilder() {
            Account parent_account = AccountBuilder.getBuilder().setLastName().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).save().getRecord();
            return LoanApplicationBuilder.getBuilder(parent_account);
        }
    }
}