@IsTest
private class SendLetterControllerTest {

    static testMethod void testInitControllerWithLoanIdParameterWhenThereIsAnOpenCollectionsAndRecoveriesCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMockForGetAllLetterTemplates(true);

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsPageError, 'There should not be Page Errors.');
            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentId, 'Current Id should be set as Loan Id.');
            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentLoan.Id, 'Proper Loan should be retrieved.');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'Related Case should be retrieved.');
            System.assertEquals(12, setup_data.ClassUnderTest.AllTemplatesOptions.size(), '12 Templates Options should be prepared.');
        }
    }

    static testMethod void testInitControllerWithLoanIdParameterWhenThereAreNotOpenCollectionsAndRecoveriesCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMockForGetAllLetterTemplates(true);

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsPageError, 'There should not be Page Errors.');
            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentId, 'Current Id should be set as Loan Id.');
            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentLoan.Id, 'Proper Loan should be retrieved.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentCase, 'Case should not be retrieved.');
            System.assertEquals(12, setup_data.ClassUnderTest.AllTemplatesOptions.size(), '12 Templates Options should be prepared.');
        }
    }

    static testMethod void testInitControllerWithCaseIdParameter() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.setMockForGetAllLetterTemplates(true);

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsPageError, 'There should not be Page Errors.');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentId, 'Current Id should be set as Case Id.');
            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentLoan.Id, 'Proper Loan should be retrieved.');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'Proper Case should be retrieved.');
            System.assertEquals(12, setup_data.ClassUnderTest.AllTemplatesOptions.size(), '12 Templates Options should be prepared.');
        }
    }

    static testMethod void testInitControllerWithoutIdParameter() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForGetAllLetterTemplates(true);

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsPageError, 'There should not be Page Errors.');
            System.assertEquals(true, String.isBlank(setup_data.ClassUnderTest.CurrentId), 'Current Id should be blank.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentLoan, 'Loan should not be retrieved.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentCase, 'Case should not be retrieved.');
            System.assertEquals(12, setup_data.ClassUnderTest.AllTemplatesOptions.size(), '12 Templates Options should be prepared.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Redirection to this page has been performed without required parameter!'),
                    'Missing Parameter message should be added.'
            );
        }
    }

    static testMethod void testInitControllerWithIncorrectIdParameter() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsUserId();
            setup_data.setMockForGetAllLetterTemplates(true);

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsPageError, 'There should not be Page Errors.');
            System.assertEquals(setup_data.TestUser.Id, setup_data.ClassUnderTest.CurrentId, 'Current Id should be set as User Id.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentLoan, 'Loan should not be retrieved.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentCase, 'Case should not be retrieved.');
            System.assertEquals(12, setup_data.ClassUnderTest.AllTemplatesOptions.size(), '12 Templates Options should be prepared.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Redirection to this page has been performed with incorrect parameter!'),
                    'Incorrect Parameter message should be added.'
            );
        }
    }

    static testMethod void testGetHasLoanExternalIdWhenItHasExternalId() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMockForGetAllLetterTemplates(true);
            setup_data.initController();

            Test.startTest();
                Boolean has_loan_external_id = setup_data.ClassUnderTest.getHasLoanExternalId();
            Test.stopTest();

            System.assertEquals(true, has_loan_external_id, 'Should return true because Loan has External Id.');
        }
    }

    static testMethod void testGetHasLoanExternalIdWhenItHasNotExternalId() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMockForGetAllLetterTemplates(true);
            setup_data.initController();
            setup_data.clearLoanExternalId();

            Test.startTest();
                Boolean has_loan_external_id = setup_data.ClassUnderTest.getHasLoanExternalId();
            Test.stopTest();

            System.assertEquals(false, has_loan_external_id, 'Should return false because Loan has not External Id.');
        }
    }

    static testMethod void testGetAllLetterTemplatesWithSuccessMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMockForGetAllLetterTemplates(true);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.getAllLetterTemplates();
            Test.stopTest();

            System.assertEquals(12, setup_data.ClassUnderTest.AllTemplatesOptions.size(), '12 Templates Options should be prepared.');
        }
    }

    static testMethod void testGetAllLetterTemplatesWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMockForGetAllLetterTemplates(false);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.getAllLetterTemplates();
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.AllTemplatesOptions.size(), 'No Templates Options should be prepared.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'),
                    'Internal Error message should be added.'
            );
        }
    }

    static testMethod void testSendLetterWithoutSelectedTemplate() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.sendLetter();
            Test.stopTest();

            System.assertEquals(true, String.isBlank(setup_data.ClassUnderTest.LetterData), 'Letter PDF file should not be retrieved.');
            System.assertEquals(false, setup_data.ClassUnderTest.getIsLetterData(), 'Should return true when letter has been retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('You need to choose Letter Template!'),
                    'Error message should be added.'
            );
        }
    }

    static testMethod void testSendLetterWithSuccessMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPostLettersAuto(true);
            setup_data.setMultiMockForGetLetters(true, 200);
            setup_data.initController();
            setup_data.setSelectedTemplate();

            Test.startTest();
                setup_data.ClassUnderTest.sendLetter();
            Test.stopTest();

            System.assertEquals(true, String.isNotBlank(setup_data.ClassUnderTest.LetterData), 'Letter PDF file should be retrieved.');
            System.assertEquals(true, setup_data.ClassUnderTest.getIsLetterData(), 'Should return true when letter has been retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Letter generated and sent successfully (Collections 1).'),
                    'Success Generate and Send Letter message should be added.'
            );
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Letter retrieved successfully.'),
                    'Success Retrieve Letter message should be added.'
            );
            List<Task> letter_tasks = [SELECT Subject FROM Task WHERE Type = 'Letter'];
            System.assertEquals(1, letter_tasks.size(), 'One Letter task should be created.');
            System.assertEquals('Letter Sent (Manually) - Collections 1', letter_tasks[0].Subject, 'Proper task subject should be set.');
        }
    }

    static testMethod void testSendLetterWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPostLettersAuto(false);
            setup_data.setMultiMockForGetLetters(true, 200);
            setup_data.initController();
            setup_data.setSelectedTemplate();

            Test.startTest();
                setup_data.ClassUnderTest.sendLetter();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.LetterData, 'Letter PDF file should not be retrieved.');
            System.assertEquals(false, setup_data.ClassUnderTest.getIsLetterData(), 'Should return false when letter has not been retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'),
                    'Internal Error message should be added.'
            );
            List<Task> letter_tasks = [SELECT Subject FROM Task WHERE Type = 'Letter'];
            System.assertEquals(0, letter_tasks.size(), 'No Letter tasks should be created.');
        }
    }

    static testMethod void testGenerateLetterWithSuccessMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPostLettersManual(true);
            setup_data.setMultiMockForGetLetters(true, 200);
            setup_data.initController();
            setup_data.setSelectedTemplate();

            Test.startTest();
                setup_data.ClassUnderTest.generateLetter();
            Test.stopTest();

            System.assertNotEquals(null, setup_data.ClassUnderTest.LetterData, 'Letter PDF file should be retrieved.');
            System.assertEquals(true, setup_data.ClassUnderTest.getIsLetterData(), 'Should return true when letter has been retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Letter generated successfully (Collections 1).'),
                    'Success Generate Letter message should be added.'
            );
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Letter retrieved successfully.'),
                    'Success Retrieve Letter message should be added.'
            );
            List<Task> letter_tasks = [SELECT Subject FROM Task WHERE Type = 'Letter'];
            System.assertEquals(1, letter_tasks.size(), 'One Letter tasks should be created.');
            System.assertEquals('Letter Generated (Manually) - Collections 1', letter_tasks[0].Subject, 'Proper task subject should be set.');
        }
    }

    static testMethod void testGenerateLetterWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPostLettersManual(false);
            setup_data.setMultiMockForGetLetters(true, 200);
            setup_data.initController();
            setup_data.setSelectedTemplate();

            Test.startTest();
                setup_data.ClassUnderTest.generateLetter();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.LetterData, 'Letter PDF file should not be retrieved.');
            System.assertEquals(false, setup_data.ClassUnderTest.getIsLetterData(), 'Should return false when letter has not been retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'),
                    'Internal Error message should be added.'
            );
        }
    }

    static testMethod void testPreviewLetterWithSuccessMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMockForPostLetters(true);
            setup_data.initController();
            setup_data.setSelectedTemplate();

            Test.startTest();
                setup_data.ClassUnderTest.previewLetter();
            Test.stopTest();

            System.assertNotEquals(null, setup_data.ClassUnderTest.LetterData, 'Letter PDF file should be retrieved.');
            System.assertEquals(true, setup_data.ClassUnderTest.getIsLetterData(), 'Should return true when letter has been retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Letter preview retrieved successfully (Collections 1).'),
                    'Success Preview Letter message should be added.'
            );
        }
    }

    static testMethod void testPreviewLetterWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMockForPostLetters(false);
            setup_data.initController();
            setup_data.setSelectedTemplate();

            Test.startTest();
                setup_data.ClassUnderTest.previewLetter();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.LetterData, 'Letter PDF file should not be retrieved.');
            System.assertEquals(false, setup_data.ClassUnderTest.getIsLetterData(), 'Should return true when letter has not been retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'),
                    'Internal Error message should be added.'
            );
        }
    }

    static testMethod void testRetrieveLetterWithSuccessMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMockForGetLetters(true, 200);
            setup_data.initController();
            setup_data.prepareLetterToRetrieve();

            Test.startTest();
                setup_data.ClassUnderTest.retrieveLetter(setup_data.TestLetter);
            Test.stopTest();

            System.assertNotEquals(null, setup_data.ClassUnderTest.LetterData, 'Letter PDF file should be retrieved.');
            System.assertEquals(true, setup_data.ClassUnderTest.getIsLetterData(), 'Should return true when letter has been retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Letter retrieved successfully.'),
                    'Success Retrieve Letter message should be added.'
            );
        }
    }

    static testMethod void testRetrieveLetterWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.setMockForGetLetters(false, 500);
            setup_data.initController();
            setup_data.prepareLetterToRetrieve();

            Test.startTest();
                setup_data.ClassUnderTest.retrieveLetter(setup_data.TestLetter);
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.LetterData, 'Letter PDF file should not be retrieved.');
            System.assertEquals(false, setup_data.ClassUnderTest.getIsLetterData(), 'Should return false when letter has not been retrieved.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'),
                    'Internal Error message should be added.'
            );
        }
    }

    static testMethod void testAddLetterTasksWithLoanIdParameterWhenThereIsAnOpenCollectionsAndRecoveriesCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsLoanId();
            setup_data.initController();
            setup_data.setSelectedTemplate();

            Test.startTest();
                setup_data.ClassUnderTest.addLetterTasks('Letter Sent (Manually) - Collections 1');
            Test.stopTest();

            List<Task> loan_letter_tasks = setup_data.getLoanLetterTasks();
            System.assertEquals(1, loan_letter_tasks.size(), 'One task for Loan should be created.');
            System.assertEquals('Letter Sent (Manually) - Collections 1', loan_letter_tasks[0].Subject, 'Should set success Subject for Loan task.');
            List<Task> case_letter_tasks = setup_data.getCaseLetterTasks();
            System.assertEquals(1, case_letter_tasks.size(), 'One task for Case should be created.');
            System.assertEquals('Letter Sent (Manually) - Collections 1', case_letter_tasks[0].Subject, 'Should set success Subject for Case task.');
        }
    }

    static testMethod void testAddLetterTasksWithLoanIdParameterWhenThereAreNotOpenCollectionsAndRecoveriesCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setPageIdParameterAsLoanId();
            setup_data.initController();
            setup_data.setSelectedTemplate();

            Test.startTest();
            setup_data.ClassUnderTest.addLetterTasks('Letter Sent (Manually) - Collections 1');
            Test.stopTest();

            List<Task> loan_letter_tasks = setup_data.getLoanLetterTasks();
            System.assertEquals(1, loan_letter_tasks.size(), 'One task for Loan should be created.');
            System.assertEquals('Letter Sent (Manually) - Collections 1', loan_letter_tasks[0].Subject, 'Should set success Subject for Loan task.');
        }
    }

    static testMethod void testAddLetterTasksWithCaseIdParameter() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();
            setup_data.setSelectedTemplate();

            Test.startTest();
                setup_data.ClassUnderTest.addLetterTasks('Letter Sent (Manually) - Collections 1');
            Test.stopTest();

            List<Task> loan_letter_tasks = setup_data.getLoanLetterTasks();
            System.assertEquals(1, loan_letter_tasks.size(), 'One task for Loan should be created.');
            System.assertEquals('Letter Sent (Manually) - Collections 1', loan_letter_tasks[0].Subject, 'Should set success Subject for Loan task.');
            List<Task> case_letter_tasks = setup_data.getCaseLetterTasks();
            System.assertEquals(1, case_letter_tasks.size(), 'One task for Case should be created.');
            System.assertEquals('Letter Sent (Manually) - Collections 1', case_letter_tasks[0].Subject, 'Should set success Subject for Case task.');
        }
    }


    private class SetupDataClass {
        public User TestUser;
        public SendLetterController ClassUnderTest;
        public Account TestAccount;
        public Loan__c TestLoan;
        public Case TestCase;
        public MultiHttpCalloutMock MultiMock;
        public ApiCommandLettersGetAll.Letter TestLetter;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' AND FirstName = 'TestFirstName' LIMIT 1];
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .save()
                    .getRecord();
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setExternalId('0000-0000-0000-0001')
                    .save()
                    .getRecord();
        }

        public void createCollectionsRecoveriesCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(TestLoan)
                    .save()
                    .getRecord();
        }

        public void setPageIdParameterAsLoanId() {
            setPageIdParameter(TestLoan.Id);
        }

        public void setPageIdParameterAsCaseId() {
            setPageIdParameter(TestCase.Id);
        }

        public void setPageIdParameterAsUserId() {
            setPageIdParameter(TestUser.Id);
        }

        private void setPageIdParameter(String id_parameter) {
            ApexPages.currentPage().getParameters().put('Id', id_parameter);
        }

        public void initController() {
            ClassUnderTest = new SendLetterController();
        }

        public void clearLoanExternalId() {
            ClassUnderTest.CurrentLoan.Loan_Id__c = null;
        }

        public void prepareLetterToRetrieve() {
            ApiCommandLettersGetAll.Letter letter = new ApiCommandLettersGetAll.Letter();
            letter.Id = 1;
            letter.LoanId = '0000-0000-0000-0001';
            letter.Name = 'TestLetterName1';
            letter.CreatedBy = 'TestAuthorName1';
            letter.CreatedDate = '2017-05-15T09:00:00.000Z';
            TestLetter = letter;
        }

        public void setMockForGetAllLetterTemplates(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLetterTemplatesTestMock(is_success, ApiCommandLetterTemplatesTestMock.CommandsName.GET_ALL_LETTER_TEMPLATES));
        }

        public void setMockForPostLetters(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLettersPostMock(is_success));
        }

        public void setMockForGetLetters(Boolean is_success, Integer status_code) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLettersGetMock(is_success, status_code));
        }

        public void setMultiMock() {
            MultiMock = new MultiHttpCalloutMock();
            Test.setMock(HttpCalloutMock.class, MultiMock);
        }

        public void setMultiMockForPostLettersAuto(Boolean is_success) {
            MultiMock.addMock(
                    'callout:Zopa_API_Collections_Endpoint/loans/0000-0000-0000-0001/letters/Collections1/generate/auto',
                    new ApiCommandLettersPostMock(is_success)
            );
        }

        public void setMultiMockForPostLettersManual(Boolean is_success) {
            MultiMock.addMock(
                    'callout:Zopa_API_Collections_Endpoint/loans/0000-0000-0000-0001/letters/Collections1/generate/manual',
                    new ApiCommandLettersPostMock(is_success)
            );
        }

        public void setMultiMockForGetLetters(Boolean is_success, Integer status_code) {
            MultiMock.addMock(
                    'callout:Zopa_API_Collections_Endpoint/loans/0000-0000-0000-0001/letters/1',
                    new ApiCommandLettersGetMock(is_success, status_code)
            );
        }

        public void setSelectedTemplate() {
            ClassUnderTest.AllTemplatesOptions.add(
                    new SelectOption('Collections1', 'Collections 1')
            );
            ClassUnderTest.SelectedTemplateName = 'Collections1';
            ClassUnderTest.SelectedTemplateLabel = 'Collections 1';
        }

        public List<Task> getLoanLetterTasks() {
            return [SELECT Id, Subject FROM Task WHERE WhatId = :TestLoan.Id AND Type = 'Letter'];
        }

        public List<Task> getCaseLetterTasks() {
            return [SELECT Id, Subject FROM Task WHERE WhatId = :TestCase.Id AND Type = 'Letter'];
        }
    }

    private class MultiHttpCalloutMock implements HttpCalloutMock {
        Map<String, HttpCalloutMock> EndpointToMock = new Map<String, HttpCalloutMock>();

        public void addMock(String endpoint, HttpCalloutMock mock) {
            EndpointToMock.put(endpoint, mock);
        }

        public HTTPResponse respond(HTTPRequest request) {
            HttpCalloutMock mock = EndpointToMock.get(request.getEndpoint());
            return mock.respond(request);
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