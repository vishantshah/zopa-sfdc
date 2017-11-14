@isTest
private class ApiCommandDeclineLoanTest {
    private static final String UUID = 'sdgfqewtddsdfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.DECLINE_LOAN_COMMAND, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            System.debug(body);
            System.assertEquals('{"DeclineReason":"OTHER"}', body, 'There should be correct body');
        }
    }

    static testMethod void testGetDeclineLoanReasonOptions() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                List<SelectOption> decline_loan_reason_options = ApiCommandDeclineLoan.getDeclineLoanReasonOptions();
            Test.stopTest();
            System.assertEquals(16, decline_loan_reason_options.size(), 'There should be 16 reasons');
        }
    }

    static testMethod void testGetReversedMapOfDeclineLoanReasonOptions(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Map<String, String> decline_reason_label_to_apin_names = ApiCommandDeclineLoan.DECLINE_REASONS_LABEL_TO_API_NAMES;
            Map<String, String> decline_reason_api_names_to_label = ApiCommandDeclineLoan.getDeclineReasonsApiNamesToLabelMap();

            for(String reason_label : decline_reason_label_to_apin_names.keySet()){
                String reason_api_name = decline_reason_label_to_apin_names.get(reason_label);
                String reason_label_in_reversed_map = decline_reason_api_names_to_label.get(reason_api_name);
                System.assertEquals(reason_label, reason_label_in_reversed_map,
                 'reason_label of initial map ' + reason_label +  'does not coincide with reversed map value' + reason_label_in_reversed_map);
            }
        }
    }

    private class SetupDataClass {
        public ApiCommandDeclineLoan ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandDeclineLoanTest' AND LastName = 'ApiCommandDeclineLoanTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandDeclineLoan(UUID, 'OTHER');
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandDeclineLoanTest')
                                     .setLastName('ApiCommandDeclineLoanTest')
                                     .save();
    }
}