@IsTest
private class SendLettersHandlerTest {
    static final Integer BULK_SIZE = 10;

    static testMethod void testSendLettersWithSuccess200Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForPostLetters(true, 200);
            setup_data.prepareRequests();

            Test.startTest();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.performSendLettersToCustomer();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();

            List<Task> loan_letter_tasks = setup_data.getLoanLetterTasks();
            System.assertEquals(10, loan_letter_tasks.size(), '10 tasks for Loan should be created.');
            System.assertEquals('Letter Sent (Automatically) - Test Template Name', loan_letter_tasks[0].Subject, 'Should set Success Send Subject for Loan task.');
            List<Task> case_letter_tasks = setup_data.getCaseLetterTasks();
            System.assertEquals(10, case_letter_tasks.size(), '1 task per each Case should be created.');
            System.assertEquals('Letter Sent (Automatically) - Test Template Name', case_letter_tasks[0].Subject, 'Should set Success Send Subject for Case task.');
            System.assertEquals(0, email_operations, 'No error emails should be sent.');
        }
    }

    static testMethod void testSendLettersWithSuccess202Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForPostLetters(true, 202);
            setup_data.prepareRequests();

            Test.startTest();
                Integer email_operations = -Limits.getEmailInvocations();
                setup_data.performSendLettersToCustomer();
                email_operations += Limits.getEmailInvocations();
            Test.stopTest();

            List<Task> loan_letter_tasks = setup_data.getLoanLetterTasks();
            System.assertEquals(10, loan_letter_tasks.size(), '10 tasks for Loan should be created.');
            System.assertEquals('Letter Accepted to Send (Automatically) - Test Template Name', loan_letter_tasks[0].Subject, 'Should set Success Accepted Subject for Loan task.');
            List<Task> case_letter_tasks = setup_data.getCaseLetterTasks();
            System.assertEquals(10, case_letter_tasks.size(), '1 task per each Case should be created.');
            System.assertEquals('Letter Accepted to Send (Automatically) - Test Template Name', case_letter_tasks[0].Subject, 'Should set Success Accepted Subject for Case task.');
            System.assertEquals(0, email_operations, 'No error emails should be sent.');
        }
    }

    static testMethod void testSendLettersWithFail500Mock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForPostLetters(false, 500);
            setup_data.prepareRequests();

            Test.startTest();
                setup_data.performSendLettersToCustomer();
            Test.stopTest();

            List<Task> loan_letter_tasks = setup_data.getLoanLetterTasks();
            System.assertEquals(10, loan_letter_tasks.size(), '10 tasks for Loan should be created.');
            System.assertEquals('Failed to Send Letter (Automatically) - Test Template Name', loan_letter_tasks[0].Subject, 'Should set Fail Send Subject for Loan task.');
            List<Task> case_letter_tasks = setup_data.getCaseLetterTasks();
            System.assertEquals(10, case_letter_tasks.size(), '1 task per each Case should be created.');
            System.assertEquals('Failed to Send Letter (Automatically) - Test Template Name', case_letter_tasks[0].Subject, 'Should set Fail Send Subject for Case task.');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Account TestAccount;
        public Loan__c TestLoan;
        public List<Case> TestCases;
        public List<SendLettersHandler.SendLetterRequest> TestRequests;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' AND FirstName = 'TestFirstName' LIMIT 1];
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .save()
                    .getRecord();
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setExternalId('0000-0000-0000-0001')
                    .save()
                    .getRecord();
            TestCases = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(TestLoan)
                    .getRecordList(BULK_SIZE);
            insert TestCases;
        }

        public void prepareRequests() {
            TestRequests = new List<SendLettersHandler.SendLetterRequest>();
            for (Case case_item: TestCases) {
                SendLettersHandler.SendLetterRequest request = new SendLettersHandler.SendLetterRequest();
                request.TemplateName = 'TestTemplateName';
                request.TemplateLabel = 'Test Template Name';
                request.LoanGuid = TestLoan.Loan_Id__c;
                request.CaseRecord = case_item;
                TestRequests.add(request);
            }
        }

        public void performSendLettersToCustomer() {
            SendLettersHandler.sendLettersToCustomers(TestRequests);
        }

        public void setMockForPostLetters(Boolean is_success, Integer status_code) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLettersBulkPostMock(is_success, status_code));
        }

        public List<Task> getLoanLetterTasks() {
            return [SELECT Id, Subject FROM Task WHERE WhatId = :TestLoan.Id AND Type = 'Letter'];
        }

        public List<Task> getCaseLetterTasks() {
            Set<Id> case_ids = new Map<Id, Case>(TestCases).keySet();
            return [SELECT Id, Subject FROM Task WHERE WhatId IN :case_ids AND Type = 'Letter'];
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('TestLastName')
                .setFirstName('TestFirstName')
                .save();
    }
}