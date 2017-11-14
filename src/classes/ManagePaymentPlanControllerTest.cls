@isTest
public class ManagePaymentPlanControllerTest {

    static testMethod void testInitManagePaymentPlanController() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(setup_data.LoanId, setup_data.ClassUnderTest.LoanId, 'LoanId should be set from page parameter.');
            System.assertEquals(setup_data.CaseId, setup_data.ClassUnderTest.CaseId, 'CaseId should be set from page parameter.');
            System.assertEquals(setup_data.FromId, setup_data.ClassUnderTest.FromId, 'FromId should be set from page parameter.');
            System.assertEquals(setup_data.PreviousPageName, setup_data.ClassUnderTest.PreviousPageName, 'PreviousPageName should be set from page parameter.');
            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentLoan.Id, 'Proper Loan should be retrieved.');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'Proper Loan should be retrieved.');
            System.assertEquals(2, setup_data.ClassUnderTest.ArrangementSelectOptions.size(), 'Arrangement list should has 2 options.');
            System.assertEquals(4, setup_data.ClassUnderTest.DurationSelectOptions.size(), 'Duration list should has 4 options.');
            System.assertEquals(1, setup_data.ClassUnderTest.FrequencySelectOptions.size(), 'Frequency list should has 1 option.');
            System.assertEquals(3, setup_data.ClassUnderTest.MethodSelectOptions.size(), 'Method list should has 3 options.');
            System.assertEquals(5, setup_data.ClassUnderTest.ArrearsReasonSelectOptions.size(), 'ArrearsReason list should has 5 options.');
            System.assertEquals(4, setup_data.ClassUnderTest.StateSelectOptions.size(), 'State list should has 4 options.');
            System.assertEquals(28, setup_data.ClassUnderTest.PaymentDaySelectOptions.size(), 'PaymentDay list should has 28 options.');
            System.assertEquals(28, setup_data.ClassUnderTest.PaymentDaySelectOptions.size(), 'PaymentDay list should has 28 options.');
            System.assertNotEquals(null, setup_data.ClassUnderTest.CaseHelper, 'CaseHelper should be initialized.');
        }
    }

    static testMethod void testGetExistingPaymentPlansWithSuccessMockAndWithActivePaymentPlan() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPaymentPlans(true, false);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.getExistingPaymentPlans();
            Test.stopTest();

            System.assertEquals(3, setup_data.ClassUnderTest.ExistingPaymentPlans.size(), '3 Payment Plans should be retrieved.');
            System.assertEquals(true, setup_data.ClassUnderTest.ThereIsActivePaymentPlan, 'ThereIsActivePaymentPlan should be set to true.');
            System.assertNotEquals(null, setup_data.ClassUnderTest.ActivePaymentPlan, 'ActivePaymentPlan should not be equal null.');
            System.assertEquals('Active', setup_data.ClassUnderTest.ActivePaymentPlan.State, 'ActivePaymentPlan should has State equal "Active".');
            System.assertNotEquals(null, setup_data.ClassUnderTest.InitActivePaymentPlan, 'InitActivePaymentPlan should not be equal null.');
            System.assertEquals(
                    true,
                    setup_data.ClassUnderTest.ActivePaymentPlan.equal(
                            setup_data.ClassUnderTest.InitActivePaymentPlan
                    ),
                    'InitActivePaymentPlan should be equal ActivePaymentPlan.'
            );
            System.assertEquals(
                    setup_data.ClassUnderTest.ActivePaymentPlan.CreatedDate,
                    setup_data.ClassUnderTest.CaseHelper.Payment_Plan_Start_Date__c,
                    'PaymentPlanStartDate of CaseHelper should be set as CreatedDate of ActivePaymentPlan.'
            );
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Payment Plans have been successfully retrieved.'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testGetExistingPaymentPlansWithSuccessMockAndWithoutActivePaymentPlan() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPaymentPlans(true, true);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.getExistingPaymentPlans();
            Test.stopTest();

            System.assertEquals(3, setup_data.ClassUnderTest.ExistingPaymentPlans.size(), '3 Payment Plans should be retrieved.');
            System.assertEquals(false, setup_data.ClassUnderTest.ThereIsActivePaymentPlan, 'ThereIsActivePaymentPlan should be set to false.');
            System.assertNotEquals(null, setup_data.ClassUnderTest.ActivePaymentPlan, 'ActivePaymentPlan should not be equal null.');
            System.assertEquals(null, setup_data.ClassUnderTest.ActivePaymentPlan.State, 'ActivePaymentPlan should has State equal null.');
            System.assertEquals(null, setup_data.ClassUnderTest.InitActivePaymentPlan, 'InitActivePaymentPlan should be equal null.');
            System.assertNotEquals(
                    null,
                    setup_data.ClassUnderTest.CaseHelper.Payment_Plan_Start_Date__c,
                    'PaymentPlanStartDate of CaseHelper should not be equal null (as CreatedDate of ActivePaymentPlan).'
            );
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Payment Plans have been successfully retrieved.'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testGetExistingPaymentPlansWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPaymentPlans(false, true);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.getExistingPaymentPlans();
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.ExistingPaymentPlans.size(), '0 Payment Plans should be retrieved.');
            System.assertEquals(false, setup_data.ClassUnderTest.ThereIsActivePaymentPlan, 'ThereIsActivePaymentPlan should be set to false.');
            System.assertNotEquals(null, setup_data.ClassUnderTest.ActivePaymentPlan, 'ActivePaymentPlan should not be equal null.');
            System.assertEquals(null, setup_data.ClassUnderTest.ActivePaymentPlan.State, 'ActivePaymentPlan should has State equal null.');
            System.assertEquals(null, setup_data.ClassUnderTest.InitActivePaymentPlan, 'InitActivePaymentPlan should be equal null.');
            System.assertNotEquals(
                    null,
                    setup_data.ClassUnderTest.CaseHelper.Payment_Plan_Start_Date__c,
                    'PaymentPlanStartDate of CaseHelper should not be equal null (as CreatedDate of ActivePaymentPlan).'
            );
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Cannot retrieve Payment Plans. Internal Server Error: Internal Error'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testRedirectToPreviousPage() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.initController();

            Test.startTest();
                PageReference result = setup_data.ClassUnderTest.redirectToPreviousPage();
            Test.stopTest();

            System.assertEquals(true, result.getRedirect(), 'Should return page reference with redirect set to true.');
            System.assertEquals(
                    '/apex/' + setup_data.PreviousPageName + '?id=' + setup_data.FromId,
                    result.getUrl(),
                    'Should return page reference with proper url.'
            );
            System.assertEquals(
                    setup_data.FromId,
                    result.getParameters().get('id'),
                    'Should return page reference with id parameter set to "' + setup_data.FromId + '".'
            );
        }
    }

    static testMethod void testCreateNewPaymentPlanAndSetLoanToArrangementsStateWithSuccessMocks() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPaymentPlans(true, true);
            setup_data.setMultiMockForSettingLoanToArrangements(true);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.getExistingPaymentPlans();
                setup_data.prepareNewPaymentPlan();
                setup_data.ClassUnderTest.save();
            Test.stopTest();

            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('New Payment Plan has been successfully created!'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Loan State has been successfully changed to "Arrangements"!'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Case has been successfully updated after creating new Payment Plan!'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            setup_data.reQueryTestCase();
            System.assertEquals(true, setup_data.TestCase.IsLockedFromUpdatesInProcess__c, 'IsLockedFromUpdatesInProcess should be set to true.');
            System.assertEquals('Arrangements', setup_data.TestCase.Sub_Process__c, 'Case Sub-Process should be set to "Arrangements".');
            System.assertEquals(
                    setup_data.ClassUnderTest.ActivePaymentPlan.CreatedDate.date(),
                    setup_data.TestCase.Payment_Plan_Start_Date__c.date(),
                    'PaymentPlanStartDate should be set to new PaymentPlan CreatedDate.'
            );
            System.assertEquals(
                    setup_data.ClassUnderTest.ActivePaymentPlan.CreatedDate.addMonths(3).date(),
                    setup_data.TestCase.Payment_Plan_End_Date__c.date(),
                    'PaymentPlanEndDate should be set to new PaymentPlan PaymentPlanStartDate + Duration time.'
            );
            System.assertEquals('Zopa', setup_data.TestCase.Payment_Plan_With__c, 'PaymentPlanWith should be set to "Zopa".');
            System.assertEquals(
                    2,
                    [SELECT Count() FROM Task WHERE WhatId = :setup_data.TestLoan.Id OR WhatId = :setup_data.TestCase.Id],
                    '2 Tasks should be created. For Case and Loan.'
            );
            System.assertEquals(
                    2,
                    [SELECT Count() FROM FeedItem WHERE ParentId = :setup_data.TestLoan.Id OR ParentId = :setup_data.TestCase.Id],
                    '2 ChatterPosts should be created. For Case and Loan.'
            );
        }
    }

    static testMethod void testCreateNewPaymentPlanWithSuccessMockAndSetLoanToArrangementsStateWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPaymentPlans(true, true);
            setup_data.setMultiMockForSettingLoanToArrangements(false);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.getExistingPaymentPlans();
                setup_data.prepareNewPaymentPlan();
                setup_data.ClassUnderTest.save();
            Test.stopTest();

            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('New Payment Plan has been successfully created!'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Cannot set Loan State to "Arrangements". Request error: Internal issues.'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testUpdatePaymentPlanWithSuccessMock() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCaseWithExistingPaymentPlan();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPaymentPlans(true, false);
            setup_data.setMultiMockForPaymentPlanPut(true);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.getExistingPaymentPlans();
                setup_data.prepareUpdateOfPaymentPlan();
                setup_data.ClassUnderTest.save();
            Test.stopTest();

            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Active Payment Plan has been successfully updated!'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Case has been successfully updated after update of Payment Plan!'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            setup_data.reQueryTestCase();
            System.assertEquals(
                    setup_data.ClassUnderTest.ActivePaymentPlan.CreatedDate.addMonths(6).date(),
                    setup_data.TestCase.Payment_Plan_End_Date__c.date(),
                    'PaymentPlanEndDate should be set to new PaymentPlan PaymentPlanStartDate + Duration time.'
            );
            System.assertEquals('DMA', setup_data.TestCase.Payment_Plan_With__c, 'PaymentPlanWith should be set to "DMA".');
            System.assertEquals(
                    2,
                    [SELECT Count() FROM Task WHERE WhatId = :setup_data.TestLoan.Id OR WhatId = :setup_data.TestCase.Id],
                    '2 Tasks should be created. For Case and Loan.'
            );
            System.assertEquals(
                    2,
                    [SELECT Count() FROM FeedItem WHERE ParentId = :setup_data.TestLoan.Id OR ParentId = :setup_data.TestCase.Id],
                    '2 ChatterPosts should be created. For Case and Loan.'
            );
        }
    }

    static testMethod void testUpdatePaymentPlanWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCaseWithExistingPaymentPlan();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPaymentPlans(true, false);
            setup_data.setMultiMockForPaymentPlanPut(false);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.getExistingPaymentPlans();
                setup_data.prepareUpdateOfPaymentPlan();
                setup_data.ClassUnderTest.save();
            Test.stopTest();

            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Cannot update Payment Plan. Internal Server Error: Internal Error'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testUpdatePaymentPlanWithoutChanges() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCaseWithExistingPaymentPlan();
            setup_data.setMultiMock();
            setup_data.setMultiMockForPaymentPlans(true, false);
            setup_data.initController();

            Test.startTest();
            setup_data.ClassUnderTest.getExistingPaymentPlans();
            setup_data.ClassUnderTest.save();
            Test.stopTest();

            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Please, change any field\'s value to update Active Payment Plan.'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testIsCreatedDateValidWhenItIsLaterThanToday() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.initController();
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan();
            payment_plan.CreatedDate = System.now().addDays(3);

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.isCreatedDateValid(payment_plan);
            Test.stopTest();

            System.assertEquals(true, result, 'Validation result should be equal true.');
        }
    }

    static testMethod void testIsCreatedDateValidWhenItIsNull() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.initController();
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan();
            payment_plan.CreatedDate = null;

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.isCreatedDateValid(payment_plan);
            Test.stopTest();

            System.assertEquals(false, result, 'Validation result should be equal false.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Incorrect value of Created Date field!'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testIsCreatedDateValidWhenItIsEarlierThanToday() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.initController();
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan();
            payment_plan.CreatedDate = System.now().addDays(-3);

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.isCreatedDateValid(payment_plan);
            Test.stopTest();

            System.assertEquals(false, result, 'Validation result should be equal false.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Incorrect value of Created Date field!'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testIsAmountValidWhenItIsGreaterThanZero() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.initController();
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan();
            payment_plan.Amount = 100.00;

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.isAmountValid(payment_plan);
            Test.stopTest();

            System.assertEquals(true, result, 'Validation result should be equal true.');
        }
    }

    static testMethod void testIsAmountValidWhenItIsNull() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.initController();
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan();
            payment_plan.Amount = null;

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.isAmountValid(payment_plan);
            Test.stopTest();

            System.assertEquals(false, result, 'Validation result should be equal false.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Incorrect value of Amount field!'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testIsAmountValidWhenItIsEqualZero() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.initController();
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan();
            payment_plan.Amount = 0;

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.isAmountValid(payment_plan);
            Test.stopTest();

            System.assertEquals(false, result, 'Validation result should be equal false.');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Incorrect value of Amount field!'),
                    'Did not find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testGetActivePaymentPlanDurationInMonthsWhenItIsEqualThreeMonths() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.initController();
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan();
            payment_plan.Duration = 'ThreeMonths';

            Test.startTest();
                Integer result = setup_data.ClassUnderTest.getPaymentPlanDurationInMonths(payment_plan);
            Test.stopTest();

            System.assertEquals(3, result, 'Result should be equal "3".');
        }
    }

    static testMethod void testGetActivePaymentPlanDurationInMonthsWhenItIsEqualSixMonths() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.initController();
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan();
            payment_plan.Duration = 'SixMonths';

            Test.startTest();
                Integer result = setup_data.ClassUnderTest.getPaymentPlanDurationInMonths(payment_plan);
            Test.stopTest();

            System.assertEquals(6, result, 'Result should be equal "6".');
        }
    }

    static testMethod void testGetActivePaymentPlanDurationInMonthsWhenItIsEqualLongTerm() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.initController();
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan();
            payment_plan.Duration = 'LongTerm';

            Test.startTest();
                Integer result = setup_data.ClassUnderTest.getPaymentPlanDurationInMonths(payment_plan);
            Test.stopTest();

            System.assertEquals(6, result, 'Result should be equal "6".');
        }
    }

    static testMethod void testGetActivePaymentPlanDurationInMonthsWhenItIsEqualOther() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createTestLoan();
            setup_data.createTestCase();
            setup_data.initController();
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan();
            payment_plan.Duration = 'Other';

            Test.startTest();
                Integer result = setup_data.ClassUnderTest.getPaymentPlanDurationInMonths(payment_plan);
            Test.stopTest();

            System.assertEquals(6, result, 'Result should be equal "6".');
        }
    }

    private class SetupDataClass {
        public ManagePaymentPlanController ClassUnderTest;
        public User TestUser;
        public Account TestAccount;
        public Loan__c TestLoan;
        public Case TestCase;
        public String FromId;
        public String LoanId;
        public String CaseId;
        public String PreviousPageName;
        public MultiHttpCalloutMock MultiMock;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' LIMIT 1];
        }

        public void initController() {
            LoanId = TestLoan.Id;
            CaseId = TestCase.Id;
            FromId = TestLoan.Id;
            PreviousPageName = 'LoanView';
            ApexPages.currentPage().getParameters().put('loan_id', LoanId);
            ApexPages.currentPage().getParameters().put('case_id', CaseId);
            ApexPages.currentPage().getParameters().put('from_id', FromId);
            ApexPages.currentPage().getParameters().put('back_page', PreviousPageName);
            ClassUnderTest = new ManagePaymentPlanController();
        }

        public void createTestAccount() {
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .save()
                    .getRecord();
        }

        public void createTestLoan() {
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setExternalId('test')
                    .save()
                    .getRecord();
        }

        public void createTestLoanWithoutExternalId() {
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .save()
                    .getRecord();
        }

        public void createTestCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(TestLoan)
                    .setProcess('Collections')
                    .setSubProcess('On-Hold')
                    .save()
                    .getRecord();
        }

        public void createTestCaseWithExistingPaymentPlan() {
            createTestCase();
            TestCase.Payment_Plan_With__c = 'Zopa';
            TestCase.Payment_Plan_Start_Date__c = Datetime.newInstance(2017, 01, 01, 12, 00, 00);
            TestCase.Payment_Plan_End_Date__c = Datetime.newInstance(2017, 04, 01, 12, 00, 00);
            update TestCase;
        }

        public void prepareNewPaymentPlan() {
            ClassUnderTest.ActivePaymentPlan.Duration = 'ThreeMonths';
            ClassUnderTest.ActivePaymentPlan.Arrangement = 'Zopa';
            ClassUnderTest.ActivePaymentPlan.Amount = 1234567.89;
            ClassUnderTest.ActivePaymentPlan.Frequency = 'Monthly';
            ClassUnderTest.ActivePaymentPlan.PaymentDay = '13';
            ClassUnderTest.ActivePaymentPlan.Method = 'BACS';
            ClassUnderTest.ActivePaymentPlan.ArrearsReason = 'Mismanagement';
            ClassUnderTest.ActivePaymentPlan.State = 'Active';
        }

        public void prepareUpdateOfPaymentPlan() {
            ClassUnderTest.ActivePaymentPlan.Duration = 'SixMonths';
            ClassUnderTest.ActivePaymentPlan.Arrangement = 'DMA';
            ClassUnderTest.ActivePaymentPlan.Amount = 1000000.00;
            ClassUnderTest.ActivePaymentPlan.Frequency = 'Monthly';
            ClassUnderTest.ActivePaymentPlan.PaymentDay = '17';
            ClassUnderTest.ActivePaymentPlan.Method = 'DebitCard';
            ClassUnderTest.ActivePaymentPlan.ArrearsReason = 'Sickness';
        }

        public void setMultiMock() {
            MultiMock = new MultiHttpCalloutMock();
            Test.setMock(HttpCalloutMock.class, MultiMock);
        }

        public void setMultiMockForPaymentPlans(Boolean is_success, Boolean no_active_plan) {
            MultiMock.addMock(
                    'callout:Zopa_API_Collections_Endpoint/loans/test/payment-plans',
                    new ApiCommandLoanPaymentPlansTestMock(is_success, no_active_plan)
            );
        }

        public void setMultiMockForPaymentPlanPut(Boolean is_success) {
            MultiMock.addMock(
                    'callout:Zopa_API_Collections_Endpoint/loans/test/payment-plans/2a961acf-fe97-479d-8ed9-ab8d04966736',
                    new ApiCommandLoanPaymentPlansTestMock(is_success, true)
            );
        }
        public void setMultiMockForSettingLoanToArrangements(Boolean is_success) {
            MultiMock.addMock(
                    'callout:Zopa_API_Collections_Endpoint/loans/test/state/arrangement',
                    new ApiCommandTestMock(is_success)
            );
        }

        public void reQueryTestCase() {
            TestCase = [
                    SELECT Id, IsLockedFromUpdatesInProcess__c, OwnerId, Payment_Plan_End_Date__c,
                            Payment_Plan_Start_Date__c, Payment_Plan_With__c, Process__c, Sub_Process__c
                    FROM Case
                    WHERE Id = :TestCase.Id
            ];
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
                .save();
    }
}