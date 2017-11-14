@isTest
public class ThirtySecondDayOfTheCycleTest {

    static testMethod void testChangeCasesAfterThirtyDayOfTheCycle() {
            SetupDataClass setup_data = new SetupDataClass();
            FeatureSwitch.disable('ZCP-104');
            System.runAs(setup_data.TestUser) {
                setup_data.createTestListRequest();
                Test.startTest();
                    ThirtySecondDayOfTheCycle.changeCasesAfterThirtyDayOfTheCycle(setup_data.TestListRequests);
                Test.stopTest();
                Integer number_of_correctly_updated_cases_from_process_builder = [SELECT COUNT() FROM Case WHERE id = :setup_data.TestCase.id AND AccountDCA__c = :setup_data.TestAccount.Id];
                Integer number_of_correctly_updated_loans_from_process_builder = [SELECT COUNT() FROM Loan__c WHERE id = :setup_data.TestLoan.id AND AccountDCA__c = :setup_data.TestAccount.Id];
                System.assertEquals(1, number_of_correctly_updated_loans_from_process_builder);
                System.assertEquals(1, number_of_correctly_updated_cases_from_process_builder);
            }
        }

    static testMethod void testSetCaseOwnerId(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                ThirtySecondDayOfTheCycle.setCaseOwnerId(setup_data.TestQueue.Name);
            Test.stopTest();
            System.assertEquals(setup_data.TestQueue.Id, ThirtySecondDayOfTheCycle.CaseOwnerId, 'Ids should be identic');
        }
    }

    static testMethod void testSetDcaAccountId(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                ThirtySecondDayOfTheCycle.setDcaAccountId(setup_data.TestAccount.Name);
            Test.stopTest();
            System.assertEquals(setup_data.TestAccount.Id, ThirtySecondDayOfTheCycle.DcaAccountId, 'Ids should be identic');
        }
    }

    static testMethod void testChangeDcaLoans(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            ThirtySecondDayOfTheCycle.CaseOwnerId = setup_data.TestQueue.Id;
            ThirtySecondDayOfTheCycle.DcaAccountId = setup_data.TestAccount.Id;
            Test.startTest();
                ThirtySecondDayOfTheCycle.changeDcaLoans(new List<Loan__c>{setup_data.TestLoan});
            Test.stopTest();
            Integer number_of_correctly_updated_loans = [SELECT COUNT() FROM Loan__c WHERE id = :setup_data.TestLoan.id AND AccountDCA__c = :setup_data.TestAccount.Id];
            System.assertEquals(1, number_of_correctly_updated_loans);
        }
    }

    static testMethod void testChangeOwnerAndDcaCases(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            ThirtySecondDayOfTheCycle.CaseOwnerId = setup_data.TestQueue.Id;
            ThirtySecondDayOfTheCycle.DcaAccountId = setup_data.TestAccount.Id;
            Test.startTest();
                ThirtySecondDayOfTheCycle.changeOwnerAndDcaCases(new List<Case>{setup_data.TestCase});
            Test.stopTest();
            Integer number_of_correctly_updated_cases = [SELECT COUNT() FROM Case WHERE id = :setup_data.TestCase.id AND AccountDCA__c = :setup_data.TestAccount.Id];
            System.assertEquals(1, number_of_correctly_updated_cases);
        }
    }

    static testMethod void testCreateMapLoanUuidToDefaultDateWithoutDefaultLoan(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                Map<String, Datetime> actual_map = ThirtySecondDayOfTheCycle.createMapLoanUuidToDefaultDate(new List<Loan__c>{setup_data.TestLoan}, new List<Case>{setup_data.TestCase});
            Test.stopTest();
            Boolean result = setup_data.TestTimeForDefault == actual_map.get(setup_data.TestLoan.Loan_id__c);
            System.assertEquals(false, result, 'In map should be save Created Date.');
        }
    }

    static testMethod void testCreateMapLoanUuidToDefaultDate(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.changeLoanState('Default');
            Test.startTest();
                Map<String, Datetime> actual_map = ThirtySecondDayOfTheCycle.createMapLoanUuidToDefaultDate(new List<Loan__c>{setup_data.TestLoan}, new List<Case>{setup_data.TestCase});
            Test.stopTest();
            Boolean result = setup_data.TestTimeForDefault == actual_map.get(setup_data.TestLoan.Loan_id__c);
            System.assertEquals(true, result, 'In map should be save Default Date.');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Loan__c TestLoan;
        public Account TestAccount;
        public User TestUser;
        public Group TestQueue;
        public List<ThirtySecondDayOfTheCycle.ConvertCaseActionRequest> TestListRequests;
        public Datetime TestTimeForDefault;

        public SetupDataClass() {
            TestTimeForDefault = System.now().addDays(1);
            TestUser = [SELECT Id FROM User WHERE LastName = 'ThirtySecondDayOfTheCycleTest' LIMIT 1];
            TestQueue = [SELECT Id, Name FROM Group WHERE Name = 'ThirtySecondDayOfTheCycleTest' LIMIT 1];
            TestAccount = [SELECT id, Name, PersonContactId FROM Account WHERE Name = 'ThirtySecondDayOfTheCycleTestAccount' LIMIT 1];
            createLoan();
            createCollectionsRecoveriesCase();
        }

        public void createCollectionsRecoveriesCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setLoan(TestLoan).setDefaultNoticeSentDate(TestTimeForDefault).save().getRecord();
        }

        public void createLoan(){
            TestLoan = LoanBuilder.getBuilder(TestAccount).setArrearsRatio(1).setExternalId('0000-0000-0000-0001').save().getRecord();
        }

        public void createTestListRequest(){
            ThirtySecondDayOfTheCycle.ConvertCaseActionRequest the_request = new ThirtySecondDayOfTheCycle.ConvertCaseActionRequest();
            the_request.TheCase = TestCase;
            the_request.OwnerName = TestQueue.Name;
            the_request.NameDCA = TestAccount.Name;
            TestListRequests = new List<ThirtySecondDayOfTheCycle.ConvertCaseActionRequest>{the_request};
        }

        public void changeLoanState(String state){
            LoanBuilder.getBuilder(TestLoan).setLoanStatus(state).save().getRecord();
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('ThirtySecondDayOfTheCycleTest')
                                     .save().getRecord();
        Group test_group = new Group(Name='ThirtySecondDayOfTheCycleTest', Type='Queue');
        insert test_group;
        System.runAs(test_user)
        {
            QueuesObject test_queue = new QueueSObject(QueueID = test_group.id, SObjectType = 'Case');
            insert test_queue;
            AccountBuilder.getBuilder('ThirtySecondDayOfTheCycleTestAccount').save().getRecord();
        }
    }
}