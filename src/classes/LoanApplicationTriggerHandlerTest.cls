@isTest
private class LoanApplicationTriggerHandlerTest {
    private static final Integer BULK_SIZE = 40;

    private static final String CASE_CONFIGURATION_CODE_NAME = 'RC_01';
    private static final String CASE_CONFIGURATION_STATUS = 'Triggered';
    private static final String CASE_CONFIGURATION_DESCRIPTION = 'Description';
    private static final String CASE_CONFIGURATION_TASK_SUBJECT = 'Task Subject';
    private static final String CASE_CONFIGURATION_TASK_DESCRIPTION = 'Task Description';
    private static final String CASE_CONFIGURATION_TASK_TASK_FOR = 'Underwriter';

    static testMethod void testCreatesOpenUnderwritingCaseForLoanWithCaseBulk() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-4');
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanListWithCase(BULK_SIZE);
            Test.startTest();
                insert setup_data.TestLoanApplicationBulk;
            Test.stopTest();
            setup_data.queryCases();
            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case new_case : setup_data.TestCases) {
                System.assertEquals('Open', new_case.Status, 'Should be open');
                System.assertEquals('Web', new_case.Origin, 'Should be Web');
            }
        }
    }

    static testMethod void testCreatesOpenUnderwritingCaseForLoanWithCaseCodes() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-4');
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.createLoanWithStatus('RequiresManualUnderwriting');
            Test.stopTest();
            System.assertEquals('Open', setup_data.TestCases.get(0).Status, 'Should be open');
            System.assertEquals('Web', setup_data.TestCases.get(0).Origin, 'Should be Web');
        }
    }

    static testMethod void testOpeningClosedUnderwritingCaseForLoanWithLoanInStatusRequiresManualUnderwriting() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-4');
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithStatus('RequiresManualUnderwriting');
            Test.startTest();
                setup_data.TestLoanApplication.Triggered_Referral_Codes__c = 'RC_01';
                update setup_data.TestLoanApplication;
            Test.stopTest();
            setup_data.queryCase();
            System.assertEquals('Open', setup_data.TestCases.get(0).Status, 'Should be open');
        }
    }

    static testMethod void testClosingOpenUnderwritingCaseForLoanWhenClearsCaseCodes() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-4');
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithStatus('RequiresManualUnderwriting');
            Test.startTest();
                setup_data.TestLoanApplication.Loan_Application_Status__c = 'AutoApproved';
                update setup_data.TestLoanApplication;
            Test.stopTest();
            setup_data.queryCase();
            System.assertEquals('Closed - Auto Approved', setup_data.TestCases.get(0).Status, 'Should be closed');
        }
    }

    static testMethod void testCreatesClosedUnderwritingCaseForLoanWithoutCaseCodesDisabledZopa4() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-4');
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.createLoanWithStatus('AutoClosed');
            Test.stopTest();
            System.assertEquals(0, setup_data.TestCases.size(), 'Should be closed');
        }
    }

    static testMethod void testOpeningClosedUnderwritingCaseForLoanWithFilledCaseCodesEnabledZopa18() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-4');
        FeatureSwitch.enable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            setup_data.createLoanWithStatus('RequiresManualUnderwriting');
            Test.startTest();
                setup_data.TestLoanApplication.Triggered_Referral_Codes__c = 'RC_01';
                update setup_data.TestLoanApplication;
            Test.stopTest();
            setup_data.queryCase();
            System.assertEquals('Open', setup_data.TestCases.get(0).Status, 'Should be open');
            for (Task new_task : setup_data.TestCases.get(0).Tasks) {
                if(!new_task.Subject.contains('case owner')){
                    System.assertEquals('Open', new_task.Status, 'Should be open');
                    System.assertEquals(CASE_CONFIGURATION_TASK_SUBJECT, new_task.Subject, 'Should be populated from configuration');
                    System.assertEquals(CASE_CONFIGURATION_TASK_TASK_FOR, new_task.Task_For__c, 'Should be populated from configuration');
                }
            }
        }
    }

    static testMethod void testCreatingUnderwritingCaseForLoanWithFilledCaseCodesEnabledZopa18() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-4');
        FeatureSwitch.enable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            Test.startTest();
                setup_data.createLoanWithReferralCode('RC_01');
            Test.stopTest();
            setup_data.queryCase();
            System.assertEquals('Open', setup_data.TestCases.get(0).Status, 'Should be open');
            for (Task new_task : setup_data.TestCases.get(0).Tasks) {
                if(!new_task.Subject.contains('case owner')){
                    System.assertEquals('Open', new_task.Status, 'Should be open');
                    System.assertEquals(CASE_CONFIGURATION_TASK_SUBJECT, new_task.Subject, 'Should be populated from configuration');
                    System.assertEquals(CASE_CONFIGURATION_TASK_TASK_FOR, new_task.Task_For__c, 'Should be populated from configuration');
                }
            }
        }
    }

    static testMethod void testClosingUnderwritingCaseForLoanWithFilledCaseCodesEnabledZopa18() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-4');
        FeatureSwitch.enable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            setup_data.createLoanWithReferralCode('RC_01');
            Test.startTest();
                setup_data.TestLoanApplication.Triggered_Referral_Codes__c = null;
                update setup_data.TestLoanApplication;
            Test.stopTest();
            setup_data.queryCase();
            System.assertEquals('Open', setup_data.TestCases.get(0).Status, 'Should be closed');
        }
    }

    static testMethod void testUpdatingCaseOnDocumentsLastUpdatedDateChanged() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-4');
        FeatureSwitch.enable('ZOPA-18');
        FeatureSwitch.enable('ZOPA-72');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanListWithCase(BULK_SIZE);
            insert setup_data.TestLoanApplicationBulk;
            Test.startTest();
                setup_data.updateLoansWithDocumentsLastUpdatedDate();
            Test.stopTest();
            setup_data.queryCases();
            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case new_case : setup_data.TestCases) {
                System.assertEquals('Open - Document Received', new_case.Status, 'Should be correct status');
            }
        }
    }

    static testMethod void testUpdatingCaseOnDocumentsLastUpdatedDateChangedDisabledZOPA72() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-4');
        FeatureSwitch.enable('ZOPA-18');
        FeatureSwitch.disable('ZOPA-72');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanListWithCase(BULK_SIZE);
            insert setup_data.TestLoanApplicationBulk;
            Test.startTest();
                setup_data.updateLoansWithDocumentsLastUpdatedDate();
            Test.stopTest();
            setup_data.queryCases();
            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case new_case : setup_data.TestCases) {
                System.assertNotEquals('Open - Document Received', new_case.Status, 'Should not change status');
            }
        }
    }

    static testMethod void testClosingCaseLoanStatusUpdateFromRequiresManualUnderwritingAutoDeclined() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable(new Set<String> {'ZOPA-4', 'ZOPA-82'});
        FeatureSwitch.disable('ZOPA-72');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanListWithStatusRequiresManualUnderwriting();
            insert setup_data.TestLoanApplicationBulk;

            Test.startTest();
                setup_data.updateLoansWithNewStatus('AutoDeclined');
            Test.stopTest();

            setup_data.queryCases();
            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case new_case : setup_data.TestCases) {
                System.assertEquals('Closed - Auto Declined', new_case.Status, 'Should be correct status');
            }
        }
    }

    static testMethod void testClosingCaseLoanStatusUpdateFromRequiresManualUnderwritingAutoApproved() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable(new Set<String> {'ZOPA-4', 'ZOPA-82'});
        FeatureSwitch.disable('ZOPA-72');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanListWithStatusRequiresManualUnderwriting();
            insert setup_data.TestLoanApplicationBulk;

            Test.startTest();
                setup_data.updateLoansWithNewStatus('AutoApproved');
            Test.stopTest();

            setup_data.queryCases();
            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case new_case : setup_data.TestCases) {
                System.assertEquals('Closed - Auto Approved', new_case.Status, 'Should be correct status');
            }
        }
    }

    static testMethod void testClosingCaseLoanStatusUpdateFromRequiresManualUnderwritingDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-4');
        FeatureSwitch.disable(new Set<String> {'ZOPA-72', 'ZOPA-82'});
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanListWithStatusRequiresManualUnderwriting();
            insert setup_data.TestLoanApplicationBulk;

            Test.startTest();
                setup_data.updateLoansWithNewStatus('AutoApproved');
            Test.stopTest();

            setup_data.queryCases();
            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case new_case : setup_data.TestCases) {
                System.assertEquals('Open', new_case.Status, 'Should be correct status');
            }
        }
    }

    static testMethod void testClosingCaseLoanStatusUpdateFromRequiresManualUnderwritingToTheSameStatus() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable(new Set<String>{'ZOPA-4', 'ZOPA-82'});
        FeatureSwitch.disable('ZOPA-72');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanListWithStatusRequiresManualUnderwriting();
            insert setup_data.TestLoanApplicationBulk;

            Test.startTest();
                setup_data.updateLoansWithNewStatus('RequiresManualUnderwriting');
            Test.stopTest();

            setup_data.queryCases();
            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case new_case : setup_data.TestCases) {
                System.assertEquals('Open', new_case.Status, 'Should be correct status');
            }
        }
    }


    private class SetupDataClass {
        public List<Case> TestCases;
        public User TestUser;
        public User DataImporter;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;
        public List<Loan_Application__c> TestLoanApplicationBulk;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'LoanApplicationTriggerHandlerTest' AND FirstName = 'LoanApplicationTriggerHandlerTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            DataImporter = [SELECT Id FROM USER WHERE Alias ='Importer' AND LastName='Importer' AND FirstName ='Data'];
        }

        public void createLoanWithStatus(String status) {
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus(status).save().getRecord();
            queryCase();
        }

        public void createLoanWithReferralCode(String referral_codes) {
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('RequiresManualUnderwriting').setTriggeredReferralCodes(referral_codes).save().getRecord();
            queryCase();
        }

        public void createLoanListWithCase(Integer size) {
            TestLoanApplicationBulk = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('RequiresManualUnderwriting').getRecordList(size);
        }

        public void createLoanListWithStatusRequiresManualUnderwriting() {
            TestLoanApplicationBulk = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('RequiresManualUnderwriting').getRecordList(BULK_SIZE);
        }

        public void createRCCodesWithTasks() {
            Case_Configuration__c rc_code = CaseConfigurationBuilder.getBuilder().setName(CASE_CONFIGURATION_CODE_NAME).setCodeDescription(CASE_CONFIGURATION_DESCRIPTION).save().getRecord();
            CaseConfigurationTaskBuilder.getBuilder(rc_code).setStatuses(CASE_CONFIGURATION_STATUS).setTaskSubject(CASE_CONFIGURATION_TASK_SUBJECT).setTaskDescription(CASE_CONFIGURATION_TASK_DESCRIPTION).setTaskFor(CASE_CONFIGURATION_TASK_TASK_FOR).save();
        }

        public void updateLoansWithDocumentsLastUpdatedDate() {
            Datetime now = System.now();
            for (Loan_Application__c loan : TestLoanApplicationBulk) {
                loan.Documents_Last_Updated_Date__c = now;
            }
            update TestLoanApplicationBulk;
        }

        public void updateLoansWithNewStatus(String status) {
            for (Loan_Application__c loan : TestLoanApplicationBulk) {
                loan.Loan_Application_Status__c = status;
            }
            update TestLoanApplicationBulk;
        }

        public void queryCase() {
            TestCases = [SELECT Status, Origin, (SELECT Status, Subject, Description, Task_For__c, Case_Configuration_Task__r.Id FROM Tasks) FROM Case WHERE Loan_Application__c = :TestLoanApplication.Id AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)];
        }

        public void queryCases() {
            TestCases = [SELECT Status, Origin FROM Case WHERE Loan_Application__c in :new Map<Id, Loan_Application__c>(TestLoanApplicationBulk).keyset() AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)];
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('LoanApplicationTriggerHandlerTest')
                                     .setLastName('LoanApplicationTriggerHandlerTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('LoanApplicationTriggerHandlerTest').save().getRecord();
        }
    }
}