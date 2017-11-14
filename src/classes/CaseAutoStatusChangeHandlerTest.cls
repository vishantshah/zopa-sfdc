@IsTest
public class CaseAutoStatusChangeHandlerTest{

    static String UNDERWRITER_USER = 'TestUnderwriterUser';
    static String COLLECTIONS_USER = 'TestCollectionsUser';

    static testMethod void testAssignDataImporterOwnerIfStatusSetToAutoDeclinedForManualUnderwritingCase(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed - Auto Declined';

            Test.startTest();
                setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToAutoApprovedForManualUnderwritingCase(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed - Auto Approved';

            Test.startTest();
                setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToCancelledForManualUnderwritingCase(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed - Cancelled';

            Test.startTest();
                setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToApprovedForManualUnderwritingCase(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed - Approved';

            Test.startTest();
                setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToDeclinedForManualUnderwritingCase(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed - Declined';

            Test.startTest();
                setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToClosedForManualUnderwritingCase(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed';

            Test.startTest();
                setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToInProgressForManualUnderwritingCase(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'In Progress';
            Id current_case_owner_id = setup_data.OldTestCase.OwnerId;

            Test.startTest();
                setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(current_case_owner_id, setup_data.NewTestCase.OwnerId, 'Owner should not change');
        }
    }


    static testMethod void testAssignDataImporterOwnerIfStatusSetToAutoDeclinedForCollectionsRecoveriesCase(){
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed - Auto Declined';

            Test.startTest();
            setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToAutoApprovedForCollectionsRecoveriesCase(){
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed - Auto Approved';

            Test.startTest();
            setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToCancelledForCollectionsRecoveriesCase(){
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed - Cancelled';

            Test.startTest();
            setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToApprovedForCollectionsRecoveriesCase(){
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed - Approved';

            Test.startTest();
            setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToDeclinedForCollectionsRecoveriesCase(){
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed - Declined';

            Test.startTest();
            setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToClosedForCollectionsRecoveriesCase(){
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed';

            Test.startTest();
            setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, setup_data.NewTestCase.OwnerId, 'Owner should be Data Importer');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToInProgressForCollectionsRecoveriesCase(){
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createManualUnderwritingCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'In Progress';
            Id current_case_owner_id = setup_data.OldTestCase.OwnerId;

            Test.startTest();
            setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(current_case_owner_id, setup_data.NewTestCase.OwnerId, 'Owner should not change');
        }
    }

    static testMethod void testAssignDataImporterOwnerIfStatusSetToClosedForCustomerCase(){
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createCustomerCaseWithInProgressStatus();
            setup_data.NewTestCase.Status = 'Closed';
            Id current_case_owner_id = setup_data.OldTestCase.OwnerId;

            Test.startTest();
            setup_data.ClassUnderTest.assignDataImporterOwnerIfStatusChanged(setup_data.OldTestCase, setup_data.NewTestCase);
            Test.stopTest();

            System.assertEquals(current_case_owner_id, setup_data.NewTestCase.OwnerId, 'Owner should not change because Customer Cases should not be handled');
        }
    }

    private class SetupDataClass{
        public Case OldTestCase;
        public Case NewTestCase;
        public Account TestAccount;
        public User TestUser;
        public User DataImporter;
        public CaseAutoStatusChangeHandler ClassUnderTest;

        public SetupDataClass(String last_name){
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
            TestAccount = AccountBuilder.getBuilder()
                    .setRecordType(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT)
                    .setName('TestAccountName')
                    .save()
                    .getRecord();
            DataImporter = [SELECT Id, Alias FROM User WHERE Alias = 'Importer' LIMIT 1];
            ClassUnderTest = CaseAutoStatusChangeHandler.getInstance();
        }

        public void createManualUnderwritingCaseWithInProgressStatus(){
            OldTestCase = createTestCase(RecordTypeUtility.CASE_MANUAL_UNDERWRITING, 'In Progress');
            NewTestCase = OldTestCase.clone();
        }

        public void createCollectionsRecoveriesCaseWithInProgressStatus(){
            OldTestCase = createTestCase(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES, 'In Progress');
            NewTestCase = OldTestCase.clone();
        }

        public void createCustomerCaseWithInProgressStatus(){
            OldTestCase = createTestCase(RecordTypeUtility.CASE_CUSTOMER, 'In Progress');
            NewTestCase = OldTestCase.clone();
        }

        public Case createTestCase(String record_type, String status){
            return CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(record_type)
                    .setStatus(status)
                    .setOwner(TestUser.Id)
                    .save()
                    .getRecord();
        }
    }

    @TestSetup
    static void setupData(){
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                .setLastName(UNDERWRITER_USER)
                .setAlias('Tuu')
                .save();

        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.COLLECTIONS)
                .setLastName(COLLECTIONS_USER)
                .setAlias('Tcu')
                .save();
    }
}