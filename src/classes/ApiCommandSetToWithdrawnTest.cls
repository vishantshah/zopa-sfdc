@isTest
public class ApiCommandSetToWithdrawnTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void apiCommandSetToWithdrawnTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.LOAN_SET_TO_WITHDRAWN, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }


    private class SetupDataClass {
        public ApiCommandSetToWithdrawn ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandSetToWithdrawn' AND LastName = 'ApiCommandSetToWithdrawn' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandSetToWithdrawn(UUID);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandSetToWithdrawn')
                                     .setLastName('ApiCommandSetToWithdrawn')
                                     .save();
    }
}