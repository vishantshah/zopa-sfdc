@isTest
public class ApiCommandValidateBankDetailsTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.VALIDATE_BANK_DETAILS_COMMAND, setup_data.ClassUnderTest.CommandName, 'CommandName should be initialized');
        }
    }

    static testMethod void testGetResponseSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandValidateBankDetails.ValidateBankDetails val_bank_details_details = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals('PASS', val_bank_details_details.Result, 'ValidateBankDetails Result is not set correctly');
        }
    }

    static testMethod void testGetResponseNotSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertNotEquals(null, setup_data.ClassUnderTest.CommandError, 'Error should be not null');
        }
    }

    private class SetupDataClass {
        public ApiCommandValidateBankDetails ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandValidateDetailTest' AND LastName = 'ApiCommandValidateDetailTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandValidateBankDetails(UUID);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiValidateBankDetailsTestMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('ApiCommandValidateDetailTest')
                                     .setLastName('ApiCommandValidateDetailTest')
                                     .save();
    }
}