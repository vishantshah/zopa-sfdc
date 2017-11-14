@isTest
public class ApiCommandSettlementCaseTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.CASE_SETTLEMENT_COLLECTIONS, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }


    private class SetupDataClass {
        public ApiCommandSettlementCase ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandSettlementCase' AND LastName = 'ApiCommandSettlementCase' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandSettlementCase(UUID);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandSettlementCase')
                                     .setLastName('ApiCommandSettlementCase')
                                     .save();
    }
}