@isTest
public class LogCallExtensionTest {
    private static final String SYSADMIN = 'CaseViewSysAdmin';

    static testMethod void testLogCallExtensionInitialization() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'Should be initialized by appropriate case');
            System.assertEquals(5, setup_data.ClassUnderTest.FOLLOWING_OPTIONS.keySet().size(), 'Should have the same number of keys as number of selectoptions in FollowingOptionsWrapper');
            System.assertEquals('Pay Now', setup_data.ClassUnderTest.FOLLOWING_OPTIONS.get('PayNow'), 'Proper value for this key');
            System.assertEquals('Promise to Pay', setup_data.ClassUnderTest.FOLLOWING_OPTIONS.get('PromiseToPay'), 'Proper value for this key');
            System.assertEquals('Follow-Up Required', setup_data.ClassUnderTest.FOLLOWING_OPTIONS.get('FollowUpRequired'), 'Proper value for this key');
            System.assertEquals('Repayment Arrangement', setup_data.ClassUnderTest.FOLLOWING_OPTIONS.get('RepaymentArrangement'), 'Proper value for this key');
            System.assertEquals('Other', setup_data.ClassUnderTest.FOLLOWING_OPTIONS.get('Other'), 'Proper value for this key');
            System.assertEquals('test@test.com', setup_data.ClassUnderTest.TheAccount.PersonEmail, 'Should be equals');
        }
    }

    static testMethod void testAddTabToRefreshParamWhenItIsNull() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            PageReference page_ref = Page.LogCallSecond;

            Test.startTest();
                setup_data.ClassUnderTest.addTabToRefreshParam(page_ref);
            Test.stopTest();

            System.assertEquals(false, page_ref.getParameters().containsKey('tab_to_refresh_id'), 'Parameter should not be added to Page Reference.');
        }
    }

    static testMethod void testAddTabToRefreshParamWhenItIsNotNull() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setTabToRefreshId('MyValue');
            PageReference page_ref = Page.LogCallSecond;

            Test.startTest();
                setup_data.ClassUnderTest.addTabToRefreshParam(page_ref);
            Test.stopTest();

            System.assertEquals(true, page_ref.getParameters().containsKey('tab_to_refresh_id'), 'Parameter should be added to Page Reference.');
            System.assertEquals('MyValue', page_ref.getParameters().get('tab_to_refresh_id'), 'Parameter should be added with proper value.');
        }
    }

    static testMethod void testStepStart() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                PageReference actual_result = setup_data.ClassUnderTest.stepStart();
            Test.stopTest();

            System.assertEquals('/apex/logcallfirst', actual_result.getUrl(), 'Should be have the same url');
        }
    }

    static testMethod void testStepFirst() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                PageReference actual_result = setup_data.ClassUnderTest.stepFirst();
            Test.stopTest();

            System.assertEquals('/apex/logcallsecond', actual_result.getUrl(), 'Should be have the same url');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: Internal issues.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testStepSecond() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                PageReference actual_result = setup_data.ClassUnderTest.stepSecond();
            Test.stopTest();

            System.assertEquals('/apex/logcallthird', actual_result.getUrl(), 'Should be have the same url');
        }
    }

    static testMethod void testSetPassedDpaAndCompleteSecondStep() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                PageReference actual_result = setup_data.ClassUnderTest.setPassedDpaAndCompleteSecondStep();
            Test.stopTest();

            System.assertEquals('/apex/logcallthird', actual_result.getUrl(), 'Should be have the same url');
            System.assertEquals(true, setup_data.ClassUnderTest.NewTask.DPA_Passed__c, 'Should be set as true.');
        }
    }

    static testMethod void testStepThirdNotAllFieldsAreFilled() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'PromiseToPay';

            Test.startTest();
                setup_data.ClassUnderTest.stepThird();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsFilledRequiredFields, 'Should be false. All required fields was not populated');
        }
    }

    static testMethod void testStepThirdBackToCase() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'test';

            Test.startTest();
                setup_data.ClassUnderTest.stepThird();
            Test.stopTest();

            PageReference expected_page_ref = Page.CaseCollectionsRecoveries;
            expected_page_ref.getParameters().put('id', setup_data.ClassUnderTest.CurrentCase.Id);
            expected_page_ref.setRedirect(true);
            System.assertEquals(true, setup_data.ClassUnderTest.IsFilledRequiredFields, 'Should be true. All required fields was populated');
            System.assertEquals(1,[SELECT COUNT() FROM Task WHERE Status = 'Completed'
                                                            AND TaskSubtype = 'Call'
                                                            AND WhatId = :setup_data.TestCase.Id]);
        }
    }

    static testMethod void testStepThirdToManagePaymentPlanPage() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'RepaymentArrangement';

            Test.startTest();
                setup_data.ClassUnderTest.stepThird();
            Test.stopTest();

            PageReference expected_page_ref = Page.ManagePaymentPlan;
            expected_page_ref.getParameters().put('uuid', setup_data.ClassUnderTest.CurrentCase.Loan__r.Loan_Id__c);
            expected_page_ref.getParameters().put('from_id', setup_data.ClassUnderTest.CurrentCase.Id);
            expected_page_ref.getParameters().put('back_page', 'CaseCollectionsRecoveries');
            expected_page_ref.setRedirect(true);
            System.assertEquals(true, setup_data.ClassUnderTest.IsFilledRequiredFields, 'Should be true. All required fields was populated');
            System.assertEquals(1,[SELECT COUNT() FROM Task WHERE Status = 'Repayment Arrangement'
                                                            AND TaskSubtype = 'Call'
                                                            AND WhatId = :setup_data.TestCase.Id]);
        }
    }

    static testMethod void testSetOutboundSubject() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                PageReference actual_result = setup_data.ClassUnderTest.setOutboundSubject();
            Test.stopTest();

            System.assertEquals('/apex/logcallsecond', actual_result.getUrl(), 'Should be have the same url');
            System.assertEquals('Outbound Call', setup_data.ClassUnderTest.NewTask.Subject, 'Should be have the same Subject');
        }
    }

    static testMethod void testSetInboundSubject() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                PageReference actual_result = setup_data.ClassUnderTest.setInboundSubject();
            Test.stopTest();

            System.assertEquals('/apex/logcallsecond', actual_result.getUrl(), 'Should be have the same url');
            System.assertEquals('Inbound Call', setup_data.ClassUnderTest.NewTask.Subject, 'Should be have the same Subject');
        }
    }

    static testMethod void testSaveAndExit() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.NewTask.Reason__c = 'test reason';

            Test.startTest();
                setup_data.ClassUnderTest.saveAndExit();
            Test.stopTest();

            Task task_after_save = [SELECT Description, Reason__c FROM Task WHERE id = :setup_data.ClassUnderTest.NewTask.id];
            System.assertEquals('test reason', task_after_save.Description, 'Should be changed after save');
            System.assertEquals('test reason', task_after_save.Reason__c, 'Should be changed after save');
            System.assertEquals('Could not Contact. Outbound Call', setup_data.ClassUnderTest.NewTask.Subject, 'Should be have the same Subject');
        }
    }

    static testMethod void testFailFlow() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.NewTask.Reason_for_failed_DPA__c = 'test';

            Test.startTest();
                setup_data.ClassUnderTest.failFlow();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsFilledRequiredFields, 'Should be true. All required fields was populated');
            Task task_after_save = [SELECT Description, Reason_for_failed_DPA__c FROM Task WHERE id = :setup_data.ClassUnderTest.NewTask.id];
            System.assertEquals('test', task_after_save.Description, 'Should be changed after save');
            System.assertEquals('test', task_after_save.Reason_for_failed_DPA__c, 'Should be changed after save');
            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE Subject LIKE 'Fail For DPA. %'], 'Should be created 1 Fail For DPA Task');
        }
    }

    static testMethod void testFailFlowWithoutReason() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.failFlow();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsFilledRequiredFields, 'Should be false. All required fields was not populated');
            System.assertEquals(new ApexPages.Message(ApexPages.Severity.WARNING, 'Reason for failed DPA is required, if you click Fail button'), ApexPages.getMessages()[0]);
        }
    }

    static testMethod void testGetPayNowLinkVisible() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'PayNow';

            Test.startTest();
                Boolean actual_result = setup_data.ClassUnderTest.getPayNowExternalSystemLinkVisible();
            Test.stopTest();

            System.assertEquals(true, actual_result, 'Should be equals');
        }
    }

    static testMethod void testGetPayNowLinkVisibleNegative() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'PromiseToPay';

            Test.startTest();
                Boolean actual_result = setup_data.ClassUnderTest.getPayNowExternalSystemLinkVisible();
            Test.stopTest();

            System.assertEquals(false, actual_result, 'Should be equals');
        }
    }

    static testMethod void testGetPromiseToPayDateVisible() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'PromiseToPay';

            Test.startTest();
                Boolean actual_result = setup_data.ClassUnderTest.getPromiseToPayDateVisible();
            Test.stopTest();

            System.assertEquals(true, actual_result, 'Should be equals');
        }
    }

    static testMethod void testGetIsZcp143IsEnabledForEnabled() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-143');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp143IsEnabled();
            Test.stopTest();

            System.assertEquals(true, is_enabled, 'ZCP-143 should be enabled');
        }
    }

    static testMethod void testGetIsZcp143IsEnabledForDisabled() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.disable('ZCP-143');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp143IsEnabled();
            Test.stopTest();

            System.assertEquals(false, is_enabled, 'ZCP-143 should be disabled');
        }
    }

    static testMethod void testGetFollowUpRequiredVisible() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'FollowUpRequired';

            Test.startTest();
                Boolean actual_result = setup_data.ClassUnderTest.getFollowUpRequiredVisible();
            Test.stopTest();

            System.assertEquals(true, actual_result, 'Should be equals');
        }
    }

    static testMethod void testGetIsOtherOptionChosen() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'Other';

            Test.startTest();
                Boolean actual_result = setup_data.ClassUnderTest.getIsOtherOptionChosen();
            Test.stopTest();

            System.assertEquals(true, actual_result, 'Should be equals');
        }
    }

    static testMethod void testStepThirdUpdateCase() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'FollowUpRequired';
            DateTime test_date_time = DateTime.newInstanceGmt(Date.today().year(), Date.today().month(), Date.today().day(), 1, 1, 1);
            setup_data.ClassUnderTest.ContainerForFollowUpRequiredDate.Start_Date__c = test_date_time.date();

            Test.startTest();
                setup_data.ClassUnderTest.stepThird();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsFilledRequiredFields, 'Should be true. All required fields was populated');
            System.assertEquals(1,[SELECT COUNT() FROM Task WHERE Status = 'Follow-Up Required'
                                                            AND TaskSubtype = 'Call'
                                                            AND WhatId = :setup_data.TestCase.Id]);
            Case actual_case = [SELECT Next_Review_Date__c FROM Case WHERE id = :setup_data.TestCase.Id];
            System.assertEquals(test_date_time.month(), actual_case.Next_Review_Date__c.month());
            System.assertEquals(8, actual_case.Next_Review_Date__c.hour(),'Next Chase Call Hour should be 8');
            System.assertEquals(0, actual_case.Next_Review_Date__c.second(),'Next Chase Call second should be 0');
            System.assertEquals(0, actual_case.Next_Review_Date__c.minute(),'Next Chase Call minute should be 0');
        }
    }

    static testMethod void testClearDpaFields() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.NewTask.DPA_Full_Name__c = true;

            Test.startTest();
                setup_data.ClassUnderTest.clearDpaFields();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.NewTask.DPA_Full_Name__c, 'Should be false. Each DPA field was cleared');
        }
    }

    static testMethod void testClearTaskReason() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.NewTask.Reason_for_failed_DPA__c = 'test';

            Test.startTest();
                setup_data.ClassUnderTest.clearTaskReason();
            Test.stopTest();

            System.assert(String.isBlank(setup_data.ClassUnderTest.NewTask.Reason_for_failed_DPA__c), 'Should be blank. Reason DPA field was cleared');
            System.assert(String.isBlank(setup_data.ClassUnderTest.NewTask.Reason__c), 'Should be blank. Could not Contact Reason field was cleared');
        }
    }

    static testMethod void testClearSecondPage() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.NewTask.DPA_Full_Name__c = true;
            setup_data.ClassUnderTest.NewTask.Reason_for_failed_DPA__c = 'test';

            Test.startTest();
                setup_data.ClassUnderTest.clearSecondPage();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.NewTask.DPA_Full_Name__c, 'Should be false. Each DPA field was cleared');
            System.assert(String.isBlank(setup_data.ClassUnderTest.NewTask.Reason_for_failed_DPA__c), 'Should be blank. Reason DPA field was cleared');
        }
    }

    static testMethod void testValidateVariablesIfNoOptionIsSelected() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.LogCallThird);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateVariables();
            Test.stopTest();

            String expected_message_value = 'You need to choose one of the options';
            Boolean is_right_message = MessageUtility.checkCurrentPageContainsExact(expected_message_value);
            System.assertEquals(true, is_right_message, 'The message summary doesn\'t match');
            System.assertEquals(false, result, 'Should be false if no option is selected');
        }
    }

    static testMethod void testValidateVariablesIfFollowUpRequiredOptionIsSelectedAndNoDate() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.LogCallThird);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            LogCallExtension.FollowingOptionsWrapper test_selected_option = new LogCallExtension.FollowingOptionsWrapper();
            test_selected_option.SelectedOptions = 'FollowUpRequired';
            setup_data.ClassUnderTest.TheFollowingOptions = test_selected_option;
            setup_data.ClassUnderTest.ContainerForFollowUpRequiredDate.Start_Date__c = null;

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateVariables();
            Test.stopTest();

            String expected_message_value = 'Follow-Up Date is required, if you mark Follow-Up Required';
            Boolean is_right_message = MessageUtility.checkCurrentPageContainsExact(expected_message_value);
            System.assertEquals(true, is_right_message, 'The message summary doesn\'t match');
            System.assertEquals(false, result, 'Should be false if FollowUpRequired option is selected and no date picked');
        }
    }

    static testMethod void testValidateVariablesIfPromiseToPayOptionIsSelectedAndNoDate() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.LogCallThird);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            LogCallExtension.FollowingOptionsWrapper test_selected_option = new LogCallExtension.FollowingOptionsWrapper();
            test_selected_option.SelectedOptions = 'PromiseToPay';
            setup_data.ClassUnderTest.TheFollowingOptions = test_selected_option;

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateVariables();
            Test.stopTest();

            String expected_message_value = 'Promise To Pay Date is required, if you mark Promise To Pay Required';
            Boolean is_right_message = MessageUtility.checkCurrentPageContainsExact(expected_message_value);
            System.assertEquals(true, is_right_message, 'The message summary doesn\'t match');
            System.assertEquals(false, result, 'Should be false if PromiseToPay option is selected and no date picked');
        }
    }

    static testMethod void testValidateVariablesIfFollowUpRequiredOptionIsSelectedAndDateIsInThePast() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.LogCallThird);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            LogCallExtension.FollowingOptionsWrapper test_selected_option = new LogCallExtension.FollowingOptionsWrapper();
            test_selected_option.SelectedOptions = 'FollowUpRequired';
            setup_data.ClassUnderTest.TheFollowingOptions = test_selected_option;
            setup_data.ClassUnderTest.ContainerForFollowUpRequiredDate.Start_Date__c = Date.today().addDays(-1);

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateVariables();
            Test.stopTest();

            String expected_message_value = 'Follow-Up Date can`t be in the past';
            Boolean is_right_message = MessageUtility.checkCurrentPageContainsExact(expected_message_value);
            System.assertEquals(true, is_right_message, 'The message summary doesn\'t match');
            System.assertEquals(false, result, 'Should be false if FollowUpRequired option is selected and date is in the past');
        }
    }

    static testMethod void testValidateVariablesIfPromiseToPayOptionIsSelectedAndDateIsInThePast() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.LogCallThird);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            LogCallExtension.FollowingOptionsWrapper test_selected_option = new LogCallExtension.FollowingOptionsWrapper();
            test_selected_option.SelectedOptions = 'PromiseToPay';
            setup_data.ClassUnderTest.TheFollowingOptions = test_selected_option;
            setup_data.ClassUnderTest.ContainerForPromiseToPayDate.Start_Date__c = Date.today().addDays(-1);

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateVariables();
            Test.stopTest();

            String expected_message_value = 'Promise To Pay Date can`t be in the past';
            Boolean is_right_message = MessageUtility.checkCurrentPageContainsExact(expected_message_value);
            System.assertEquals(true, is_right_message, 'The message summary doesn\'t match');
            System.assertEquals(false, result, 'Should be false if PromiseToPay option is selected and date is in the past');
        }
    }

    static testMethod void testValidateVariablesIfFollowUpRequiredOptionIsSelectedAndDateIsToday() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.LogCallThird);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            LogCallExtension.FollowingOptionsWrapper test_selected_option = new LogCallExtension.FollowingOptionsWrapper();
            test_selected_option.SelectedOptions = 'FollowUpRequired';
            setup_data.ClassUnderTest.TheFollowingOptions = test_selected_option;
            setup_data.ClassUnderTest.ContainerForFollowUpRequiredDate.Start_Date__c = Date.today();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateVariables();
            Test.stopTest();

            System.assertEquals(true, result, 'Should be true if FollowUpRequired option is selected and date is today');
            System.assertEquals(0, ApexPages.getMessages().size(), 'There should have been 0 Page Message');
        }
    }

    static testMethod void testValidateVariablesIfPromiseToPayOptionIsSelectedAndDateIsInTheFuture() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        System.runAs(setup_data.TestUser) {
            Test.setCurrentPage(Page.LogCallThird);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            LogCallExtension.FollowingOptionsWrapper test_selected_option = new LogCallExtension.FollowingOptionsWrapper();
            test_selected_option.SelectedOptions = 'PromiseToPay';
            setup_data.ClassUnderTest.TheFollowingOptions = test_selected_option;
            setup_data.ClassUnderTest.ContainerForPromiseToPayDate.Start_Date__c = Date.today().addDays(1);

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.validateVariables();
            Test.stopTest();

            System.assertEquals(true, result, 'Should be true if PromiseToPay option is selected and date is in the future');
            System.assertEquals(0, ApexPages.getMessages().size(), 'There should have been 0 Page Message');
        }
    }

    static testMethod void testInsertTaskWithRightFollowingOption() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            LogCallExtension.FollowingOptionsWrapper test_selected_option = new LogCallExtension.FollowingOptionsWrapper();
            test_selected_option.SelectedOptions = 'PayNow';
            setup_data.ClassUnderTest.TheFollowingOptions = test_selected_option;

            Test.startTest();
                setup_data.ClassUnderTest.stepThird();
            Test.stopTest();

            Task task_after_save = [SELECT Status FROM Task WHERE id = :setup_data.ClassUnderTest.NewTask.id];
            System.assertEquals('Pay Now', task_after_save.Status, 'Should be changed after save');
        }
    }

    static testMethod void testInsertTaskWithWrongFollowingOption() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            LogCallExtension.FollowingOptionsWrapper test_selected_option = new LogCallExtension.FollowingOptionsWrapper();
            test_selected_option.SelectedOptions = 'wrong option';
            setup_data.ClassUnderTest.TheFollowingOptions = test_selected_option;

            Test.startTest();
                setup_data.ClassUnderTest.stepThird();
            Test.stopTest();

            Task task_after_save = [SELECT Status FROM Task WHERE id = :setup_data.ClassUnderTest.NewTask.id];
            System.assertEquals('Completed', task_after_save.Status, 'Should be changed after save');
        }
    }

    static testMethod void testGetDateOfBirthFormatedIfValueNotExists() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                String result = setup_data.ClassUnderTest.getDateOfBirthFormated();
            Test.stopTest();

            System.assertEquals(true, String.isBlank(result), 'Should be empty string, because there is no value');
        }
    }

    static testMethod void testGetDateOfBirthFormatedIfValueExists() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.addDateOfBirthValueToAccount();
            setup_data.initController();

            Test.startTest();
                String result = setup_data.ClassUnderTest.getDateOfBirthFormated();
            Test.stopTest();

            System.assertEquals(setup_data.Today.format(), result, 'Should be formated, because there is value');
        }
    }

    static testMethod void testStepThirdUpdateCaseWithPromiseToPaySuccess() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable(new Set<String>{'ZCP-58', 'ZCP-189'});
        setup_data.setMockForResponse(true);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'PromiseToPay';
            Date test_date = Date.today().addDays(1);
            Time expected_time = Time.newInstance(8, 0, 0, 0);
            Datetime expected_datetime = Datetime.newInstance(test_date, expected_time);
            setup_data.ClassUnderTest.ContainerForPromiseToPayDate.Start_Date__c = test_date;

            Test.startTest();
                setup_data.ClassUnderTest.stepThird();
            Test.stopTest();

            Case actual_case = [SELECT Next_Review_Date__c, Stop_Communication_Until__c, Sub_Process__c, Status FROM Case WHERE id = :setup_data.TestCase.Id];
            System.assertEquals(expected_datetime, actual_case.Stop_Communication_Until__c, 'Stop_Communication_Until__c was updated');
            System.assertEquals(expected_datetime, actual_case.Next_Review_Date__c, 'Next_Review_Date__c was updated');
            System.assertEquals('Promise to Pay', actual_case.Sub_Process__c, 'Sub_Process was updated');
            System.assertEquals('On-Hold', actual_case.Status, 'Status was updated');
        }
    }

    static testMethod void testStepThirdUpdateCaseWithPromiseToPayNotSuccess() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable(new Set<String>{'ZCP-58', 'ZCP-189'});
        setup_data.setMockForResponse(false);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'PromiseToPay';
            Date test_date = Date.today().addDays(1);
            Time expected_time = Time.newInstance(8, 0, 0, 0);
            Datetime expected_datetime = Datetime.newInstance(test_date, expected_time);
            setup_data.ClassUnderTest.ContainerForPromiseToPayDate.Start_Date__c = test_date;

            Test.startTest();
                setup_data.ClassUnderTest.stepThird();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsFilledRequiredFields, 'Should be true. All required fields was populated');
            Case actual_case = [SELECT Next_Review_Date__c, Stop_Communication_Until__c, Sub_Process__c, Status FROM Case WHERE id = :setup_data.TestCase.Id];
            System.assertNotEquals(expected_datetime, actual_case.Stop_Communication_Until__c,'Stop_Communication_Until__c was not updated');
            System.assertNotEquals(expected_datetime, actual_case.Next_Review_Date__c,'Next_Review_Date__c was not updated');
            System.assertNotEquals('On-Hold', actual_case.Status,'Status was not updated');
            System.assertNotEquals('Promise to Pay', actual_case.Sub_Process__c,'Sub_Process was not updated');
        }
    }

    static testMethod void testStepThirdUpdateCaseWithPromiseToPayWhenZcp189IsDisabled() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        FeatureSwitch.disable('ZCP-189');
        setup_data.setMockForResponse(true);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'PromiseToPay';
            Date test_date = Date.today().addDays(1);
            Time expected_time = Time.newInstance(8, 0, 0, 0);
            Datetime expected_datetime = Datetime.newInstance(test_date, expected_time);
            setup_data.ClassUnderTest.ContainerForPromiseToPayDate.Start_Date__c = test_date;

            Test.startTest();
                setup_data.ClassUnderTest.stepThird();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsFilledRequiredFields, 'Should be true. All required fields was populated');
            Case actual_case = [SELECT Next_Review_Date__c, Stop_Communication_Until__c, Sub_Process__c, Status FROM Case WHERE id = :setup_data.TestCase.Id];
            System.assertEquals(expected_datetime, actual_case.Stop_Communication_Until__c,'Stop_Communication_Until__c was updated.');
            System.assertNotEquals(expected_datetime, actual_case.Next_Review_Date__c,'Next_Review_Date__c was not updated because of disabled FS ZCP-189.');
            System.assertEquals('On-Hold', actual_case.Status,'Status was updated.');
            System.assertEquals('Promise to Pay', actual_case.Sub_Process__c,'Sub_Process was updated.');
        }
    }

    static testMethod void testPerformCalloutToUpdateStopCommunicationUntilSuccess() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        setup_data.setMockForResponse(true);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Date test_date = Date.today().addDays(1);
            setup_data.ClassUnderTest.ContainerForPromiseToPayDate.Start_Date__c = test_date;

            Test.startTest();
                Boolean callout_successfull = setup_data.ClassUnderTest.performCalloutToUpdateStopCommunicationDate();
            Test.stopTest();

            System.assertEquals(true, callout_successfull, 'Stop Communication Until send to backend successfully.');
        }
    }

    static testMethod void testPerformCalloutToUpdateStopCommunicationUntilNotSuccess() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        setup_data.setMockForResponse(false);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Date test_date = Date.today().addDays(1);
            setup_data.ClassUnderTest.ContainerForPromiseToPayDate.Start_Date__c = test_date;

            Test.startTest();
                Boolean callout_successfull = setup_data.ClassUnderTest.performCalloutToUpdateStopCommunicationDate();
            Test.stopTest();

            System.assertEquals(false, callout_successfull, 'Stop Communication Until send failed.');
        }
    }

    static testMethod void testStepThirdRepaymentArrangementRedirect() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable('ZCP-58');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.TheFollowingOptions.SelectedOptions = 'RepaymentArrangement';

            Test.startTest();
                PageReference result_page_ref = setup_data.ClassUnderTest.stepThird();
            Test.stopTest();

            PageReference expected_page_ref = Page.ManagePaymentPlan;
            expected_page_ref.getParameters().put('uuid', setup_data.TestCase.Loan__r.Loan_Id__c);
            expected_page_ref.getParameters().put('from_id', setup_data.TestCase.Id);
            expected_page_ref.getParameters().put('case_id', setup_data.TestCase.Id);
            expected_page_ref.getParameters().put('back_page', 'CaseCollectionsRecoveries');
            expected_page_ref.setRedirect(true);
            System.assertEquals(expected_page_ref.getUrl(), result_page_ref.getUrl(), 'Wrong redirect PageReference on RepaymentArrangement process');
        }
    }

    static testMethod void testPrepareNewReviewTask() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.prepareNewReviewTask();
            Test.stopTest();

            System.assertEquals('Call', setup_data.ClassUnderTest.NewTask.TaskSubtype, 'NewTask.TaskSubtype should be set as "Call".');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.NewTask.WhatId, 'NewTask.WhatId should be set as Current Case Id.');
            System.assertEquals(
                    RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL),
                    setup_data.ClassUnderTest.NewTask.RecordTypeId,
                    'NewTask.RecordTypeId should be set as "Collections Call" record type Id.'
            );
        }
    }

    static testMethod void testUpsertReviewTaskWhenItHasBeenCreatedDuringLogACall() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.prepareNewReviewTask();

            Test.startTest();
                setup_data.ClassUnderTest.upsertReviewTask();
            Test.stopTest();

            System.assertEquals('Call', setup_data.ClassUnderTest.NewTask.TaskSubtype, 'NewTask.TaskSubtype should be set as "Call".');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.NewTask.WhatId, 'NewTask.WhatId should be set as Current Case Id.');
            System.assertEquals(
                    RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL),
                    setup_data.ClassUnderTest.NewTask.RecordTypeId,
                    'NewTask.RecordTypeId should be set as "Collections Call" record type Id.'
            );
            System.assertEquals('Completed', setup_data.ClassUnderTest.NewTask.Status, 'NewTask.Status should be set as "Completed".');
            System.assertNotEquals(null, setup_data.ClassUnderTest.NewTask.CompletedDateTime__c, 'NewTask.CompletedDateTime__c should be not null.');
            System.assertEquals(
                    setup_data.ClassUnderTest.NewTask.CompletedDateTime__c,
                    setup_data.ClassUnderTest.NewTask.Review_Due_Date__c,
                    'NewTask.Review_Due_Date__c should be set as NewTask.CompletedDateTime__c.'
            );
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Account TestAccount;
        public Loan__c TestLoan;
        public LogCallExtension ClassUnderTest;
        public User TestUser;
        public Date Today;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        public void createCollectionsRecoveriesCase() {
            createDataForCase();
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(TestLoan)
                    .save()
                    .getRecord();
        }

        private void addDateOfBirthValueToAccount() {
            Today = Date.today();
            AccountBuilder.getBuilder(TestAccount)
                    .setDateOfBirth(Today)
                    .save();
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandPutStopCommunicationDateMock(is_success));
        }

        private void createDataForCase() {
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder()
                    .setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT)
                    .setLastName('test')
                    .setPersonEmail()
                    .save()
                    .getRecord();
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setArrearsRatio(1)
                    .setExternalId(Utility.getRandomString(8))
                    .save()
                    .getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void initController() {
            ApexPages.currentPage()
                    .getParameters()
                    .put('caseId', TestCase.Id);
            ClassUnderTest = new LogCallExtension();
        }

        public void createCollectionsRecoveriesCaseWithOwner() {
            createDataForCase();
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setOwner(TestUser.Id)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .save()
                    .getRecord();
        }

        public void setTabToRefreshId(String value) {
            ClassUnderTest.TabToRefreshId = value;
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName(SYSADMIN)
                .save();
    }
}