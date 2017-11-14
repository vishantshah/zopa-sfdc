@isTest
private class CaseArrearsDayCountBatchTest {
    public static final Integer BULK_SIZE = 30;

    static testMethod void testCaseArrearsDayCountBatchInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();

            setup_data.assertQuery(setup_data.ClassUnderTest.Query);
        }
    }

    static testMethod void testExecuteBatchFromStartCountInProcessStart() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCases(setup_data.TestUser.Id);

            Test.startTest();
                database.executeBatch(setup_data.ClassUnderTest, 30);
            Test.stopTest();

            List<Case> updated_cases = [SELECT Id, Process_Day_Counter__c FROM Case];
            for(Case updated_case : updated_cases){
                System.assertEquals(1, updated_case.Process_Day_Counter__c, 'Process_Day_Counter was counted wrong');
            }
        }
    }

    static testMethod void testExecuteBatchFromStartCountMiddleOfProcess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCasesFiveDays(setup_data.TestUser.Id);

            Test.startTest();
                database.executeBatch(setup_data.ClassUnderTest, 30);
            Test.stopTest();

            List<Case> updated_cases = [SELECT Id, Process_Day_Counter__c FROM Case];
            for(Case updated_case : updated_cases){
                System.assertEquals(6, updated_case.Process_Day_Counter__c, 'Process_Day_Counter was counted wrong');
            }
        }
    }

    static testMethod void testSendEmailsWhenErrorOccurred() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createManualUnderwritingCasesFiveDays(setup_data.TestUser.Id);
            setup_data.ClassUnderTest.IsError = true;

            Test.startTest();
                Integer email_limit_before = Limits.getEmailInvocations();
                database.executeBatch(setup_data.ClassUnderTest, 30);
                Integer email_limit_after = Limits.getEmailInvocations();
            Test.stopTest();

            System.assertEquals(setup_data.getAdminUserNumber(), CaseArrearsDayCountBatch.EmailToSend.size(), 'Not proper number of Emails prepared.');
        }
    }

    private class SetupDataClass {
        public List<Case> TestCases;
        public User TestUser;
        public Account TestAccount;
        public CaseArrearsDayCountBatch ClassUnderTest;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'BatchUpdateCaseAssignmentsTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new CaseArrearsDayCountBatch();
        }

        public void createManualUnderwritingCases(Id owner_id) {
            TestCases = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setSubProcess('DCA')
                    .getRecordList(BULK_SIZE);
            insert TestCases;
        }

        public void createManualUnderwritingCasesFiveDays(Id owner_id) {
            TestCases = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setSubProcess('DCA')
                    .setProcessDayCounter(5)
                    .getRecordList(BULK_SIZE);
            insert TestCases;
        }

        private void queryCase() {
            Set<Id> case_ids = new Map<Id, Case>(TestCases).keySet();
            TestCases = [SELECT RecordTypeId, Status, OwnerId FROM Case WHERE Id = :case_ids];
        }

        public void assertQuery(String result_query){
            String expected_query = 'SELECT Id, Process_Day_Counter__c FROM Case WHERE IsClosed = false'
                    +' AND RecordTypeId = \''+RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES) + '\'';
               System.assertEquals(expected_query, result_query, 'Query was created wrong');
        }

        public Integer getAdminUserNumber(){
            return [
                    SELECT Id, FirstName
                    FROM User
                    WHERE ProfileId = :ProfileUtilities.getInstance().getProfileIdForType(ProfileUtilities.ProfileType.SYSADMIN)
                    AND isActive = true
            ].size();
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('BatchUpdateCaseAssignmentsTest')
                .save()
                .getRecord();
        System.runAs(test_user) {
            AccountBuilder.getBuilder('BatchUpdateCaseAssignmentsTest').save();
        }
    }
}