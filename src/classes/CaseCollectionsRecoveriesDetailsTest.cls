@isTest
public class CaseCollectionsRecoveriesDetailsTest{

    static testMethod void testConstructorSetsCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'CurrentCase should be set');
            System.assertEquals(false, setup_data.ClassUnderTest.LazyLoadFinished, 'LazyLoadFinished should be false by default');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Account TestAccount;
        public CaseCollectionsRecoveriesDetails ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestAccount = AccountBuilder.getBuilder('CaseCollectionsRecoveriesDetailsTest').save().getRecord();
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).save().getRecord();
            TestUser = [SELECT Id FROM User WHERE FirstName = 'CaseCollectionsRecoveriesDetailsTest' AND LastName = 'CaseCollectionsRecoveriesDetailsTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ApexPages.StandardController std_controller = new ApexPages.StandardController(TestCase);
            ClassUnderTest = new CaseCollectionsRecoveriesDetails(std_controller);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('CaseCollectionsRecoveriesDetailsTest')
                                     .setLastName('CaseCollectionsRecoveriesDetailsTest')
                                     .save();
    }
}