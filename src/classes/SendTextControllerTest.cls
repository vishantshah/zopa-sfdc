@IsTest
private class SendTextControllerTest {

    static testMethod void testInitControllerWithCollectionsAndRecoveriesCaseIdParameter() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsPageError, 'There should not be Page Errors.');
            System.assertEquals('', setup_data.ClassUnderTest.TextContent, 'TextContent should be set as an empty String.');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentId, 'Current Id should be set as Case Id.');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'Proper Case should be retrieved.');
            System.assertEquals(setup_data.TestAccount.Id, setup_data.ClassUnderTest.CurrentAccount.Id, 'Proper Account should be retrieved.');
            System.assertEquals(setup_data.TestAccount.PersonMobilePhone, setup_data.ClassUnderTest.ToPhoneNumber, 'ToPhoneNumber should be set as Account PersonMobilePhone.');
        }
    }

    static testMethod void testInitControllerWithManualUnderwritingCaseIdParameter() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoanApplication();
            setup_data.createManualUnderwritingCase();
            setup_data.setPageIdParameterAsCaseId();

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsPageError, 'There should not be Page Errors.');
            System.assertEquals('', setup_data.ClassUnderTest.TextContent, 'TextContent should be set as an empty String.');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentId, 'Current Id should be set as Case Id.');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'Proper Case should be retrieved.');
            System.assertEquals(setup_data.TestAccount.Id, setup_data.ClassUnderTest.CurrentAccount.Id, 'Proper Account should be retrieved.');
            System.assertEquals(setup_data.TestAccount.PersonMobilePhone, setup_data.ClassUnderTest.ToPhoneNumber, 'ToPhoneNumber should be set as Account PersonMobilePhone.');
        }
    }

    static testMethod void testInitControllerWithInvalidIdParameter() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoanApplication();
            setup_data.createManualUnderwritingCase();
            setup_data.setPageIdParameterAsUserId();

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsPageError, 'There should be a Page Error.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Redirection to this page has been performed with incorrect parameter!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals('', setup_data.ClassUnderTest.TextContent, 'TextContent should be set as an empty String.');
            System.assertEquals(setup_data.TestUser.Id, setup_data.ClassUnderTest.CurrentId, 'Current Id should bet set as User Id.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentCase, 'Case should not be retrieved.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentAccount, 'Account should not be retrieved.');
            System.assertEquals(null, setup_data.ClassUnderTest.ToPhoneNumber, 'ToPhoneNumber should be set as an empty String.');
        }
    }

    static testMethod void testInitControllerWithoutIdParameter() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoanApplication();
            setup_data.createManualUnderwritingCase();

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsPageError, 'There should be a Page Error.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Redirection to this page has been performed without required parameter!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals('', setup_data.ClassUnderTest.TextContent, 'TextContent should be set as an empty String.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentId, 'Current Id should bet set as a null.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentCase, 'Case should not be retrieved.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentAccount, 'Account should not be retrieved.');
            System.assertEquals(null, setup_data.ClassUnderTest.ToPhoneNumber, 'ToPhoneNumber should be set as an empty String.');
        }
    }

    static testMethod void testInitControllerWithCollectionsAndRecoveriesCaseIdNotRelatedToAccountParameter() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCaseNotRelatedToAccount();
            setup_data.setPageIdParameterAsCaseId();

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsPageError, 'There should be a Page Error.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Record is not directly related to Account!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals('', setup_data.ClassUnderTest.TextContent, 'TextContent should be set as an empty String.');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentId, 'Current Id should bet set as Case Id.');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'Proper Case should be retrieved.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentAccount, 'Account should not be retrieved.');
            System.assertEquals(null, setup_data.ClassUnderTest.ToPhoneNumber, 'ToPhoneNumber should be set as an empty String.');
        }
    }

    static testMethod void testSetToPhoneNumberFromAccountWhenPersonMobilePhoneIsNotBlank() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.updatePersonAccountPhones('+48555555555', null, null);
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.setToPhoneNumberFromAccount();
            Test.stopTest();

            System.assertEquals('+48555555555', setup_data.ClassUnderTest.ToPhoneNumber, 'ToPhoneNumber should be set as Account.PersonMobilePhone.');
        }
    }

    static testMethod void testSetToPhoneNumberFromAccountWhenMobilePhoneIsNotBlankAndItIsValid() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.updatePersonAccountPhones(null, '07555555555', null);
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.setToPhoneNumberFromAccount();
            Test.stopTest();

            System.assertEquals('07555555555', setup_data.ClassUnderTest.ToPhoneNumber, 'ToPhoneNumber should be set as Account.MobilePhone__c.');
        }
    }

    static testMethod void testSetToPhoneNumberFromAccountWhenMobilePhoneIsNotBlankAndItIsNotValid() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.updatePersonAccountPhones(null, '555555555', null);
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.setToPhoneNumberFromAccount();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.ToPhoneNumber, 'ToPhoneNumber should not be set.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Valid Phone Number has not been found in related Account!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testSetToPhoneNumberFromAccountWhenPhoneIsNotBlankAndItIsValid() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.updatePersonAccountPhones(null, null, '+447555555555');
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.setToPhoneNumberFromAccount();
            Test.stopTest();

            System.assertEquals('+447555555555', setup_data.ClassUnderTest.ToPhoneNumber, 'ToPhoneNumber should be set as Account.Phone.');
        }
    }

    static testMethod void testSetToPhoneNumberFromAccountWhenPhoneIsNotBlankAndItIsNotValid() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.updatePersonAccountPhones(null, null, '555555555');
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.setToPhoneNumberFromAccount();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.ToPhoneNumber, 'ToPhoneNumber should not be set.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Valid Phone Number has not been found in related Account!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testSetToPhoneNumberFromAccountWhenAllPhonesAreBlank() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.updatePersonAccountPhones(null, null, null);
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.setToPhoneNumberFromAccount();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.ToPhoneNumber, 'ToPhoneNumber should not be set.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Valid Phone Number has not been found in related Account!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testValidateFormWhenToPhoneNumberIsBlank() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();
            setup_data.ClassUnderTest.ToPhoneNumber = '';
            setup_data.ClassUnderTest.TextContent = 'Some text content.';

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateForm();
            Test.stopTest();

            System.assertEquals(false, result, 'Validation result should be equal false.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Phone Number can not be empty!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testValidateFormWhenTextContentIsBlank() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();
            setup_data.ClassUnderTest.ToPhoneNumber = '+48555666777';
            setup_data.ClassUnderTest.TextContent = '';

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateForm();
            Test.stopTest();

            System.assertEquals(false, result, 'Validation result should be equal false.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Text Content can not be empty!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testValidateFormWhenTextContentIsLongerThan160Characters() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();
            setup_data.ClassUnderTest.ToPhoneNumber = '+48555666777';
            setup_data.ClassUnderTest.TextContent = 'I am too long. I am too long. I am too long. I am too long. I am too long. I am too long.'
                    + ' I am too long. I am too long. I am too long. I am too long. I am too long. I am too long. I am too long. I am too long.'
                    + ' I am too long. I am too long. I am too long. I am too long. I am too long. I am too long. I am too long. I am too long.'
                    + ' I am too long. I am too long. I am too long. I am too long. I am too long. I am too long. I am too long. I am too long.'
                    + ' I am too long. I am too long. I am too long. I am too long. I am too long. I am too long. I am too long. I am too long.'
                    + ' I am too long. I am too long. I am too long. I am too long. I am too long. I am too long. I am too long. I am too long.';

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.validateForm();
            Test.stopTest();

            System.assertEquals(false, result, 'Validation result should be equal false.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Text Content can not be longer than 160 characters!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testValidateFormWhenToPhoneNumberAndTextContentAreBlank() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();
            setup_data.ClassUnderTest.ToPhoneNumber = '';
            setup_data.ClassUnderTest.TextContent = '';

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateForm();
            Test.stopTest();

            System.assertEquals(false, result, 'Validation result should be equal false.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Phone Number can not be empty!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Text Content can not be empty!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testValidateFormWhenToPhoneNumberAndTextContentAreNotBlank() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();
            setup_data.ClassUnderTest.ToPhoneNumber = '+48555666777';
            setup_data.ClassUnderTest.TextContent = 'Some text content.';

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateForm();
            Test.stopTest();

            System.assertEquals(true, result, 'Validation result should be equal true.');
        }
    }

    static testMethod void testSendWhenFormIsNotValid() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.send();
            Test.stopTest();

            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Text Content can not be empty!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(false, setup_data.ClassUnderTest.IsSendActionSuccess, 'IsSendActionSuccess should be set as false.');
        }
    }

    static testMethod void testSendWhenTwilioConfigIsNull() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.initController();
            setup_data.ClassUnderTest.ToPhoneNumber = '+48555666777';
            setup_data.ClassUnderTest.TextContent = 'Some text content.';

            Test.startTest();
                setup_data.ClassUnderTest.send();
            Test.stopTest();

            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Twilio configuration for "ZOPA" has not been found! Please ask your Salesforce Administrator about this.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(false, setup_data.ClassUnderTest.IsSendActionSuccess, 'IsSendActionSuccess should be set as false.');
        }
    }

    static testMethod void testSendWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.createTwilioConfig();
            setup_data.initController();
            setup_data.ClassUnderTest.ToPhoneNumber = '+48555666777';
            setup_data.ClassUnderTest.TextContent = 'Some text content.';
            setup_data.setMockForResponse(false);

            Test.startTest();
                setup_data.ClassUnderTest.send();
            Test.stopTest();

            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Twilio Error'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(false, setup_data.ClassUnderTest.IsSendActionSuccess, 'IsSendActionSuccess should be set as false.');
        }
    }

    static testMethod void testSendWithSuccessMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createPersonAccount();
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setPageIdParameterAsCaseId();
            setup_data.createTwilioConfig();
            setup_data.initController();
            setup_data.ClassUnderTest.ToPhoneNumber = '+48555666777';
            setup_data.ClassUnderTest.TextContent = 'Some text content.';
            setup_data.setMockForResponse(true);

            Test.startTest();
                setup_data.ClassUnderTest.send();
            Test.stopTest();

            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Text sent successfully!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(true, setup_data.ClassUnderTest.IsSendActionSuccess, 'IsSendActionSuccess should be set as true.');
            List<Task> tasks = [
                    SELECT Id
                    FROM Task
                    WHERE Status = 'Completed'
                    AND Type = 'SMS'
                    AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_SMS)
                    AND Subject = 'SMS Sent (Manually) - Free text'
                    AND Method__c = 'Manual'
                    AND (
                            WhatId = :setup_data.TestCase.Id
                            OR WhatId = :setup_data.TestLoan.Id
                    )
            ];
            System.assertEquals(2, tasks.size(), '2 Tasks should be created.');
        }
        List<FeedItem> posts = [
                SELECT Id
                FROM FeedItem
                WHERE ParentId = :setup_data.TestCase.Id
                OR ParentId = :setup_data.TestLoan.Id
        ];
        System.assertEquals(2, posts.size(), 'Should create 2 chatter posts. For Case and Loan');
    }


    private class SetupDataClass {
        public User TestUser;
        public SendTextController ClassUnderTest;
        public Account TestAccount;
        public Loan__c TestLoan;
        public Loan_Application__c TestLoanApplication;
        public Case TestCase;

        public SetupDataClass() {
            TestUser = [
                    SELECT Id
                    FROM User
                    WHERE LastName = 'TestLastName'
                    AND FirstName = 'TestFirstName'
                    LIMIT 1
            ];
        }

        public void createPersonAccount() {
            TestAccount = AccountBuilder.getBuilder()
                    .setFirstName('TestAccountFirstName')
                    .setLastName('TestAccountLastName')
                    .setPersonMobilePhone('+48555666777')
                    .setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT)
                    .save()
                    .getRecord();
        }

        public void createLoan() {
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setExternalId('0000-0000-0000-0001')
                    .save()
                    .getRecord();
        }

        public void createLoanApplication() {
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount)
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

        public void createCollectionsRecoveriesCaseNotRelatedToAccount() {
            TestCase = CaseBuilder.getBuilder()
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(TestLoan)
                    .save()
                    .getRecord();
        }

        public void createManualUnderwritingCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                    .setLoanApplication(TestLoanApplication)
                    .setAccountId(TestAccount.Id)
                    .save()
                    .getRecord();
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
            ClassUnderTest = new SendTextController();
        }

        public void createTwilioConfig() {
            insert new TwilioConfig__c(
                    Name = 'ZOPA',
                    AccountSid__c = 'AC00000000000000000000000000000000',
                    AuthToken__c = 'AT000000000000000000000000000000',
                    Phone__c = '+48111222333'
            );
        }

        public void setMockForResponse(Boolean is_success) {
            String resourceLocation = 'https://api.twilio.com/2010-04-01/Accounts/AC00000000000000000000000000000000/Messages.json';
            String jsonResponse = '{"message": "Twilio Error", "more_info": "More Twilio Error"}';

            if(is_success) {
                Twilio_TestHTTPMock.getInstance().putResponse(
                        'POST',
                        resourceLocation,
                        new Twilio_TestHTTPMock.Response(jsonResponse, 200)
                );
            } else {
                Twilio_TestHTTPMock.getInstance().putResponse(
                        'POST',
                        resourceLocation,
                        new Twilio_TestHTTPMock.Response(jsonResponse, 400)
                );
            }
        }

        public void updatePersonAccountPhones(String person_mobile_phone, String mobile_phone, String phone) {
            TestAccount.PersonMobilePhone = person_mobile_phone;
            TestAccount.MobilePhone__c = mobile_phone;
            TestAccount.Phone = phone;
            update TestAccount;
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