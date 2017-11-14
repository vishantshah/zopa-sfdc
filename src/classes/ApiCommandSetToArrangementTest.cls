@isTest
public class ApiCommandSetToArrangementTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void apiCommandSetToArrangementTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.LOAN_SET_TO_ARRANGEMENT, setup_data.ClassUnderTest.CommandName, 'Class under test must have another command name in it');
        }
    }


    private class SetupDataClass {
        public ApiCommandSetToArrangement ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandSetToArrangement' AND LastName = 'ApiCommandSetToArrangement' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandSetToArrangement(UUID);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandSetToArrangement')
                                     .setLastName('ApiCommandSetToArrangement')
                                     .save();
    }
}