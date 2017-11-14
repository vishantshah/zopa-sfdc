@isTest
private class ApiCommandCancelLoanTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.CANCEL_LOAN_COMMAND, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            System.assertEquals('{"CancellationReason":"OTHER","CancellationExplanation":"Test request"}', body, 'There should be 2 headers');
        }
    }

    static testMethod void testGetCancelLoanReasonOptions() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                List<SelectOption> cancel_loan_reason_options = ApiCommandCancelLoan.getCancelLoanReasonOptions();
            Test.stopTest();
            System.assertEquals(20, cancel_loan_reason_options.size(), 'There should be 20 reasons');
        }
    }

    static testMethod void testGetReversedMapOfCancelLoanReasonOptions(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Map<String, String> cancel_reason_label_to_api_names = ApiCommandCancelLoan.CANCEL_REASONS_LABEL_TO_API_NAMES;
            Map<String, String> cancel_reason_api_names_to_label = ApiCommandCancelLoan.getCancelReasonsApiNamesToLabelMap();

            for(String reason_label : cancel_reason_label_to_api_names.keySet()){
                String reason_api_name = cancel_reason_label_to_api_names.get(reason_label);
                String reason_label_in_reversed_map = cancel_reason_api_names_to_label.get(reason_api_name);

                if(reason_label == 'Reason not given' || reason_label == 'Other'){
                    System.assert(reason_label_in_reversed_map == 'Reason not given' || reason_label_in_reversed_map == 'Other', 'Value of reversed_map ' + reason_label_in_reversed_map + 'does not equal to Other or Reason not given');
                }
                else{
                     System.assertEquals(reason_label, reason_label_in_reversed_map,
                         'reason_label of initial map ' + reason_label +  'does not coincide with reversed map value' + reason_label_in_reversed_map);
                }
            }
        }
    }

    private class SetupDataClass {
        public ApiCommandCancelLoan ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandCancelLoanTest' AND LastName = 'ApiCommandCancelLoanTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandCancelLoan(UUID, 'OTHER');
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandCancelLoanTest')
                                     .setLastName('ApiCommandCancelLoanTest')
                                     .save();
    }
}