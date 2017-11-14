@isTest
public class CaseOwnerChangeHandlerTest{
    static testMethod void testUpdateStatusIfOwnerChangedPositive(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.CurrentUser){
            Test.startTest();
                setup_data.createCaseWithStatusOpenDocumentReceived();
                setup_data.NewTestCase.OwnerId = setup_data.CurrentUser.Id;
                CaseOwnerChangeHandler.getInstance(setup_data.OldTestCase, setup_data.NewTestCase).updateStatusIfOwnerChanged();
            Test.stopTest();
            System.assertEquals(setup_data.NewTestCase.Status, 'In Progress - Documents Received', 'Status should equal to In Progress - Documents Received');
        }
    }

    static testMethod void testUpdateStatusIfOwnerChangedNegative(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.CurrentUser){
            Test.startTest();
                setup_data.createCaseWithStatusOpen();
                setup_data.NewTestCase.OwnerId = setup_data.CurrentUser.Id;
                CaseOwnerChangeHandler.getInstance(setup_data.OldTestCase, setup_data.NewTestCase).updateStatusIfOwnerChanged();
            Test.stopTest();
            System.assertEquals(setup_data.OldTestCase.Status, setup_data.NewTestCase.Status, 'Status of old and new cases shouldn`t be different!!!');
        }
    }

    private class SetupDataClass{
        public User PreviousOwner { get; private set; }
        public User CurrentUser { get; private set; }
        public Account TestAccount { get; private set; }
        public Case OldTestCase { get; private set; }
        public Case NewTestCase { get; private set; }
        public CaseOwnerChangeHandler ClassUnderTest { get; private set; }

        public SetupDataClass(){
            PreviousOwner = [SELECT Name, Id FROM User WHERE Name = 'First Owner' LIMIT 1];
            CurrentUser = [SELECT Name, Id FROM User WHERE Name = 'Second Owner' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
        }

        public void createCaseWithStatusOpenDocumentReceived(){
            OldTestCAse = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).setStatus('Open - Document Received').setOwner(PreviousOwner.Id).save().getRecord();
            NewTestCase  = OldTestCAse.clone();
        }

        public void createCaseWithStatusOpen(){
            OldTestCAse = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).setStatus('Open').setOwner(PreviousOwner.Id).save().getRecord();
            NewTestCase  = OldTestCAse.clone();
        }
    }

    @testSetup
    static void createAccountAndUsers(){
        User sys_admin = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('AccountTriggerHandlerTest')
                                     .save().getRecord();
        System.runAs(sys_admin){
            UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                                         .setLastName('First Owner')
                                         .save().getRecord();
            UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                                         .setLastName('Second Owner')
                                         .save().getRecord();
            AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT).setName('AccountTriggerHandlerTest').save().getRecord();
        }
    }
}