@isTest
public class LoanSetToWithdrawnHandlerTest {

    static testMethod void testSetLoanToWithdrawnWithSuccessMock() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable(new Set<String> {'ZCP-104', 'ZCP-106', 'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.setMockForResponse(true);

            Test.startTest();
                LoanSetToWithdrawnHandler.setLoanTowithdrawnFromFlow(new List<Id>{setup_data.TestLoan.Id});
            Test.stopTest();

            setup_data.reQueryTestCase();
            System.assertEquals('Withdrawn', setup_data.TestCase.Status, 'Related Case Status should be set to "Withdrawn".');
            System.assertEquals(
                    2,
                    [SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestLoan.Id OR WhatId = :setup_data.TestCase.Id],
                    '2 Tasks should be created. For Loan and for Case.'
            );
            System.assertEquals(
                    2,
                    [SELECT COUNT() FROM FeedItem WHERE ParentId = :setup_data.TestLoan.Id OR ParentId = :setup_data.TestCase.Id],
                    '2 ChatterPosts should be created. For Loan and for Case.'
            );
        }
    }

    static testMethod void testSetLoanToWithdrawnWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable(new Set<String>{'ZCP-106', 'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.setMockForResponse(false);

            Test.startTest();
                LoanSetToWithdrawnHandler.setLoanTowithdrawnFromFlow(new List<Id>{setup_data.TestLoan.Id});
            Test.stopTest();

            setup_data.reQueryTestCase();
            System.assertNotEquals('Withdrawn', setup_data.TestCase.Status, 'Related Case Status should not be set to "Withdrawn".');
        }
    }

    static testMethod void testSetLoanToWithdrawnFromPageActionWithSuccessMock() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable(new Set<String> {'ZCP-104', 'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.setMockForResponse(true);

            Test.startTest();
            LoanSetToWithdrawnHandler.setLoanToWithdrawnFromPageAction(setup_data.TestLoan);
            Test.stopTest();

            setup_data.reQueryTestCase();
            System.assertEquals('Withdrawn', setup_data.TestCase.Status, 'Related Case Status should be set to "Withdrawn".');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Loan State has been successfully set to "Withdrawn"!'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testSetLoanToWithdrawnFromPageActionWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable(new Set<String> {'ZCP-104', 'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.setMockForResponse(false);

            Test.startTest();
                LoanSetToWithdrawnHandler.setLoanToWithdrawnFromPageAction(setup_data.TestLoan);
            Test.stopTest();

            setup_data.reQueryTestCase();
            System.assertNotEquals('Withdrawn', setup_data.TestCase.Status, 'Related Case Status should not be set to "Withdrawn".');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: Internal issues.'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testGetIsZCP106IsEnabledWhenEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-106');
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                Boolean result = LoanSetToWithdrawnHandler.getIsZCP106IsEnabled();
            Test.stopTest();

            System.assertEquals(true, result, 'ZCP-106 should be enabled');
        }
    }

    static testMethod void testGetIsZCP106IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-106');
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                Boolean result = LoanSetToWithdrawnHandler.getIsZCP106IsEnabled();
            Test.stopTest();

            System.assertEquals(false, result, 'ZCP-106 should be disabled');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Account TestAccount;
        public Loan__c TestLoan;
        public Case TestCase;

        public SetupDataClass() {
            FeatureSwitch.disable('ZCP-128');
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' LIMIT 1];
        }

        private void createDataForTest() {
            TriggerHandler.IsTriggerActive = false;
            createTestAccount();
            createTestLoan();
            createTestCase();
            TriggerHandler.IsTriggerActive = true;
        }

        public void createTestAccount() {
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .save()
                    .getRecord();
        }

        public void createTestLoan() {
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setExternalId(Utility.getRandomString(8))
                    .save()
                    .getRecord();
        }

        public void createTestCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(TestLoan)
                    .save()
                    .getRecord();
        }

        public void reQueryTestCase() {
            TestCase = [SELECT Id, Status FROM Case WHERE Id = : TestCase.Id];
        }

        public void reQueryTestLoan() {
            TestLoan = [SELECT Id, State__c FROM Loan__c WHERE Id = : TestLoan.Id];
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('TestLastName')
                .save();
    }
}