@isTest
private class CaseBuilderTest {

    static testMethod void testEmptyGetBuilderJustInitCase(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Case test_case = CaseBuilder.getBuilder().getRecord();
            Test.stopTest();
            System.assertNotEquals(null, test_case);
        }
    }

    static testMethod void testBuilderSetsDefaultValuesCorrectlyWithLittleLoanAndNoAccount(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            setup_data.createLoanApplication();
            Test.startTest();
               Case test_case = CaseBuilder.getBuilder(setup_data.TestAccount).getRecord();
            Test.stopTest();
            System.assertEquals('Open', test_case.Status);
            System.assertEquals('Phone', test_case.Origin);
            System.assertEquals('Problem', test_case.Type);
            System.assertEquals(setup_data.TestAccount.Id, test_case.AccountId);
        }
    }

    static testMethod void testSaveMethodWorksOnBuilder(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Test.startTest();
                Case test_case = CaseBuilder.getBuilder(setup_data.TestAccount).
                                       setReason('Fraud').
                                       save().
                                       getRecord();
            Test.stopTest();
            Integer quantity_of_saved_cases = [SELECT Count() FROM Case];
            System.assertEquals(1, quantity_of_saved_cases, 'Expected 1 case to have been saved, instead there were ' + quantity_of_saved_cases);
        }
    }

    static testMethod void testgetCaseList(){
        SetupDataClass setup_data = new SetupDataClass();
        Integer no_of_cases =123;
        System.runAs(setup_data.TestUser){
            Test.startTest();
                List<Case> case_list = CaseBuilder.getBuilder().getRecordList(no_of_cases);
            Test.stopTest();
            System.assertEquals(no_of_cases, case_list.size() , 'List of cases has wrong size');
        }
    }

    static testMethod void testSetLoanApplication(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            setup_data.createLoanApplication();
            Test.startTest();
                Case test_case = CaseBuilder.getBuilder().setLoanApplication(setup_data.TestLoanApp).getRecord();
            Test.stopTest();
            System.assertEquals(setup_data.TestLoanApp.Id, test_case.Loan_Application__c, 'Loan Application isn\'t set correctly');
        }
    }

    static testMethod void testSetContact(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Contact test_contact = [SELECT Id FROM Contact];

            Test.startTest();
                Case test_case = CaseBuilder.getBuilder(setup_data.TestAccount).
                                       setContact(test_contact).
                                       setReason('Fraud').
                                       save().
                                       getRecord();
            Test.stopTest();

            Case new_case = [SELECT Id, ContactId FROM Case];
            System.assertEquals(test_contact.Id, new_case.ContactId, 'Contact Id of Case should be the same as Id of Contact assigned to Case.');
        }
    }

    static testMethod void testSetIsSensitive(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();

            Test.startTest();
            Case test_case = CaseBuilder.getBuilder(setup_data.TestAccount).
                    setIsSensitive(true).
                    save().
                    getRecord();
            Test.stopTest();

            Case new_case = [SELECT Id, Is_Sensitive__c FROM Case];
            System.assertEquals(true, new_case.Is_Sensitive__c, 'Case should be set as sensitive.');
        }
    }

    static testMethod void testSetAccountIdSetsIdCorrectly(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Test.startTest();
                Case test_case = CaseBuilder.getBuilder()
                                        .setAccountId(setup_data.TestAccount.Id)
                                        .save()
                                        .getRecord();
            Test.stopTest();
            Case case_created = [SELECT AccountId FROM Case WHERE Id =: test_case.Id];
            System.assertEquals(setup_data.TestAccount.Id, case_created.AccountId, 'Expected case to be linked to test account id');
        }
    }

    static testMethod void testSetInitialUnderwriter(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Test.startTest();
                Case test_case = CaseBuilder.getBuilder()
                                        .setInitialUnderwriter(setup_data.AdminUser.Id)
                                        .save()
                                        .getRecord();
            Test.stopTest();
            Case case_created = [SELECT Initial_Underwriter__c FROM Case WHERE Id =: test_case.Id];
            System.assertEquals(setup_data.AdminUser.Id, case_created.Initial_Underwriter__c, 'Expected case to be linked to test user id');
        }
    }

    static testMethod void testSetSubStatus(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Test.startTest();
                Case test_case = CaseBuilder.getBuilder()
                                        .setSubProcess('DCA')
                                        .save()
                                        .getRecord();
            Test.stopTest();
            Case case_created = [SELECT Sub_Process__c FROM Case WHERE Id =: test_case.Id];
            System.assertEquals('DCA', case_created.Sub_Process__c, 'Sub_Process was setted wrong');
        }
    }

    static testMethod void testSetProcess(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Test.startTest();
                Case test_case = CaseBuilder.getBuilder()
                                        .setProcess('Collections')
                                        .save()
                                        .getRecord();
            Test.stopTest();
            Case case_created = [SELECT Process__c FROM Case WHERE Id =: test_case.Id];
            System.assertEquals('Collections', case_created.Process__c, 'Process was setted wrong');
        }
    }

    static testMethod void testSetProcessDayCounter(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Test.startTest();
                Case test_case = CaseBuilder.getBuilder()
                                        .setProcessDayCounter(5)
                                        .save()
                                        .getRecord();
            Test.stopTest();
            Case case_created = [SELECT Process_Day_Counter__c FROM Case WHERE Id =: test_case.Id];
            System.assertEquals(5, case_created.Process_Day_Counter__c, 'Process_Day_Counter was setted wrong');
        }
    }

    static testMethod void testSetDefaultNoticeSentDate(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Datetime test_date_time = System.now();
            Test.startTest();
                Case test_case = CaseBuilder.getBuilder()
                                        .setDefaultNoticeSentDate(test_date_time)
                                        .save()
                                        .getRecord();
            Test.stopTest();
            Case case_created = [SELECT Default_Notice_Sent_Date__c FROM Case WHERE Id =: test_case.Id];
            System.assertEquals(test_date_time, case_created.Default_Notice_Sent_Date__c, 'Default_Notice_Sent_Date was setted wrong');
        }
    }

    static testMethod void testSetIsLockedFromUpdatesInProcess(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Test.startTest();
            Case test_case = CaseBuilder.getBuilder()
                    .setIsLockedFromUpdatesInProcess(true)
                    .save()
                    .getRecord();
            Test.stopTest();
            Case case_created = [SELECT IsLockedFromUpdatesInProcess__c FROM Case WHERE Id =: test_case.Id];
            System.assertEquals(true, case_created.IsLockedFromUpdatesInProcess__c, 'IsLockedFromUpdatesInProcess__c was setted wrong');
        }
    }

    static testMethod void testSetAccountDCAID(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Test.startTest();
                Case test_case = CaseBuilder.getBuilder()
                                        .setAccountDCAID(setup_data.TestAccount.Id)
                                        .save()
                                        .getRecord();
            Test.stopTest();
            Case case_created = [SELECT AccountDCA__c FROM Case WHERE Id =: test_case.Id];
            System.assertEquals(setup_data.TestAccount.Id, case_created.AccountDCA__c, 'Expected case to be linked to test DCA account');
        }
    }

    static testMethod void testSetNextReviewDate(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createTestAccount();
            Datetime next_review_date = Datetime.now();
            Test.startTest();
                Case test_case = CaseBuilder.getBuilder()
                        .setNextReviewDate(next_review_date)
                        .save()
                        .getRecord();
            Test.stopTest();
            Case case_created = [SELECT Next_Review_Date__c FROM Case WHERE Id =: test_case.Id];
            System.assertEquals(next_review_date, case_created.Next_Review_Date__c, 'Next_Review_Date__c has not been set');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public User AdminUser;
        public Account TestAccount {get; set;}
        public Loan_Application__c TestLoanApp {get; set;}
        public Case TestCase {get; set;}

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE LastName = 'CaseBuilderTestCASE_PREP' LIMIT 1];
            AdminUser = [SELECT Id FROM User WHERE LastName = 'CaseBuilderTestSYSADMIN' LIMIT 1];
        }

        public void createTestAccount(){
            TestAccount = AccountBuilder.getBuilder().setLastName().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).save().getRecord();
        }

        public void createBasicTestCase(){
            TestCase = CaseBuilder.getBuilder(TestAccount).getRecord();
        }

        public void createLoanApplication(){
            TestLoanApp = LoanApplicationBuilder.getBuilder(TestAccount).save().getRecord();
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setLastName('CaseBuilderTestCASE_PREP')
                                     .save();
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('CaseBuilderTestSYSADMIN')
                                     .save();
    }
}