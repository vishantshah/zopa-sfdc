@isTest private class CustomSettingInitializationTest {

    static testMethod void testCreateDefaultMUTaskSubjectsNotFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
        setup_data.createMUTasksSubjectsCS();
            Test.startTest();
                CustomSettingInitialization.createDefaultMUTaskSubjects();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(1, setup_data.TestTaskSubjects.size(), 'Should not override cs id exist');
        }
    }

    static testMethod void testCreateDefaultMUTaskSubjectsFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                CustomSettingInitialization.createDefaultMUTaskSubjects();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(CustomSettingInitialization.NEW_TASKS_SUBJECTS.size(), setup_data.TestTaskSubjects.size(), 'Should insert all cs list');
        }
    }

    static testMethod void testCreateDefaultZopaDocumentTypesFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                CustomSettingInitialization.createDefaultZopaDocumentTypes();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(CustomSettingInitialization.DOCUMENT_TYPES.size(), setup_data.TestDocTypes.size(), 'Should insert all cs list');
        }
    }

    static testMethod void testCreateDefaultZopaDocumentTypesNotFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
        setup_data.createDoctypesCS();
            Test.startTest();
                CustomSettingInitialization.createDefaultZopaDocumentTypes();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(1, setup_data.TestDocTypes.size(), 'Should not override cs id exist');
        }
    }

    static testMethod void testCreateCompanyClassOptionsFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                CustomSettingInitialization.createCompanyClassOptions();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(CustomSettingInitialization.NEW_COMPANY_CLASS_OPTIONS.size(), setup_data.TestCompanyClassOptions.size(), 'Should insert all cs list');
        }
    }

    static testMethod void testCreateCompanyClassOptionsNotFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
        setup_data.createCompClassCS();
            Test.startTest();
                CustomSettingInitialization.createCompanyClassOptions();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(1, setup_data.TestCompanyClassOptions.size(), 'Should not override cs id exist');
        }
    }

    static testMethod void testCreateAccountTypeOptionFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        StaticResourceTestData.createTestAccountTypeStaticResource();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                CustomSettingInitialization.createAccountTypeOption();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(10, setup_data.TestAccountTypeOptions.size(), 'Should insert all cs list');
        }
    }

    static testMethod void testCreateAccountTypeOptionNotFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            StaticResourceTestData.createTestAccountTypeStaticResource();
            setup_data.createAccountTypesCS();
            Test.startTest();
                CustomSettingInitialization.createAccountTypeOption();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(10, setup_data.TestAccountTypeOptions.size(), 'Should not override cs id exist');
        }
    }

    static testMethod void testCreateDefaultCRTaskSubjectsNotFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
        setup_data.createCSTasksSubjectsCS();
            Test.startTest();
                CustomSettingInitialization.createDefaultCRTaskSubjects();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(1, setup_data.TestCollectionsTaskSubjects.size(), 'Should not override cs id exist');
        }
    }

    static testMethod void testCreateDefaultCRTaskSubjectsFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                CustomSettingInitialization.createDefaultCRTaskSubjects();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(CustomSettingInitialization.NEW_TASKS_SUBJECTS_COLLECTIONS_CASE.size(), setup_data.TestCollectionsTaskSubjects.size(), 'Should insert all cs list');
        }
    }

    static testMethod void testcreateDefaultCRTaskReasonsNotFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
        setup_data.createCSTasksReasonCS();
            Test.startTest();
                CustomSettingInitialization.createDefaultCRTaskReasons();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(1, setup_data.TestCollectionsTaskReason.size(), 'Should not override cs id exist');
        }
    }

    static testMethod void testcreateDefaultCRTaskReasonsFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                CustomSettingInitialization.createDefaultCRTaskReasons();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(CustomSettingInitialization.NEW_TASKS_REASON_COLLECTIONS_CALL_CASE.size(), setup_data.TestCollectionsTaskReason.size(), 'Should insert all cs list');
        }
    }

    static testMethod void testCreateSettingsForMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            List<Mock_Manager_for_Callout__c> list_cs_before_test = Mock_Manager_for_Callout__c.getall().values();
            Test.startTest();
                CustomSettingInitialization.createSettingsForMock();
            Test.stopTest();
            List<Mock_Manager_for_Callout__c> list_cs_after_test = Mock_Manager_for_Callout__c.getall().values();
            List<Zopa_Api_Command__mdt> list_command_info =[SELECT Name_of_the_mock_class__c FROM Zopa_Api_Command__mdt WHERE Name_of_the_mock_class__c != null];
            Set<String> set_name_command_info = new Set<String>();
            for (Zopa_Api_Command__mdt current_command_info: list_command_info){
                set_name_command_info.add(current_command_info.Name_of_the_mock_class__c);
            }
            System.assertEquals(0, list_cs_before_test.size(), 'Should not exist cs list');
            System.assertEquals(set_name_command_info.size(), list_cs_after_test.size(), 'Should insert all cs list');
        }
    }

    static testMethod void testCreateOtherOptionsForLogACallNotFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
        setup_data.createCSOtherOptions();
            Test.startTest();
                CustomSettingInitialization.createOtherOptionsForLogACall();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(1, setup_data.TestOtherOptionsLogACall.size(), 'Should not override cs id exist');
        }
    }

    static testMethod void testCreateOtherOptionsForLogACallFirstInit() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                CustomSettingInitialization.createOtherOptionsForLogACall();
            Test.stopTest();
            setup_data.getCustomSettings();
            System.assertEquals(CustomSettingInitialization.OTHER_OPTIONS_FOR_LOG_A_CALL.size(), setup_data.TestOtherOptionsLogACall.size(), 'Should insert all cs list');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public List<Available_Document_Types__c> TestDocTypes;
        public List<Manual_Underwriting_Task_Subjects__c> TestTaskSubjects;
        public List<Collections_Recoveries_Task_Subjects__c> TestCollectionsTaskSubjects;
        public List<Collections_Call_Task_Reason__c> TestCollectionsTaskReason;
        public List<Company_Class_Options_MU__c> TestCompanyClassOptions;
        public List<Account_Type_Option_MU__c> TestAccountTypeOptions;
        public List<Log_a_Call_Other_Options__c> TestOtherOptionsLogACall;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        }

        public void createMUTasksSubjectsCS() {
            insert new Manual_Underwriting_Task_Subjects__c(Name = 'Test', Task_Subject__c = 'Test');
        }

        public void createCSTasksSubjectsCS() {
            insert new Collections_Recoveries_Task_Subjects__c(Name = 'Test', Task_Subject__c = 'Test');
        }

        public void createCSTasksReasonCS() {
            insert new Collections_Call_Task_Reason__c(Name = 'Test', Task_Reason__c = 'Test');
        }

        public void createCSOtherOptions() {
            insert new Log_a_Call_Other_Options__c(Name = 'Test', Value__c = 'Test');
        }

        public void createDoctypesCS() {
            insert new Available_Document_Types__c(Name = 'Test');
        }

        public void createCompClassCS() {
            insert new Company_Class_Options_MU__c(Name = 'Test');
        }

        public void createAccountTypesCS() {
            insert new Account_Type_Option_MU__c(Name = 'Test');
        }

        public void getCustomSettings() {
            TestDocTypes = Available_Document_Types__c.getall().values();
            TestTaskSubjects = Manual_Underwriting_Task_Subjects__c.getall().values();
            TestCollectionsTaskSubjects = Collections_Recoveries_Task_Subjects__c.getall().values();
            TestCollectionsTaskReason = Collections_Call_Task_Reason__c.getall().values();
            TestCompanyClassOptions = Company_Class_Options_MU__c.getall().values();
            TestAccountTypeOptions = Account_Type_Option_MU__c.getall().values();
            TestOtherOptionsLogACall = Log_a_Call_Other_Options__c.getall().values();
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('CustomSettingInitializationTest')
                                     .setLastName('CustomSettingInitializationTest')
                                     .save();
    }
}