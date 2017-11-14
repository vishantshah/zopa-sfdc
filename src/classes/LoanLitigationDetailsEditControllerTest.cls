@isTest
private class LoanLitigationDetailsEditControllerTest {

    static testMethod void testGetEpmtyLitigationDetailsSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true,false);
            Test.startTest();
                setup_data.ClassUnderTest.updateLitigationDetails();
            Test.stopTest();
            System.assertEquals(new ApexPages.Message(ApexPages.Severity.INFO, 'Loan Litigation Details was successfully updated'), ApexPages.getMessages()[1]);
        }
    }

    static testMethod void testGetEpmtyLitigationDetailsFail() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false,true);
            Test.startTest();
                setup_data.ClassUnderTest.updateLitigationDetails();
            Test.stopTest();
            System.assertEquals(new ApexPages.Message(ApexPages.Severity.FATAL, 'Internal Server Error: Internal Error'), ApexPages.getMessages()[1]);
        }
    }

    static testMethod void testMakeEditableFieldsSecondClick() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true,false);
            setup_data.ClassUnderTest.makeEditableFields();
            Test.startTest();
                setup_data.ClassUnderTest.makeEditableFields();
            Test.stopTest();
            System.assertEquals(new ApexPages.Message(ApexPages.Severity.INFO, 'Loan Litigation Details was successfully updated'), ApexPages.getMessages()[1]);
            System.assertEquals(false, setup_data.ClassUnderTest.IsEditeble);
        }
    }

    static testMethod void testMakeEditableFieldsFirstClick() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true,false);
            Test.startTest();
                setup_data.ClassUnderTest.makeEditableFields();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.IsEditeble);
        }
    }

    private class SetupDataClass {
        public LoanLitigationDetailsEditController ClassUnderTest;
        public User TestUser;
        public Loan__c TestLoan;
        public Account TestAccount;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'LoanLitigationDetailsEditControllerTest' AND LastName = 'LoanLitigationDetailsEditControllerTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            createLoan();
            ClassUnderTest = new LoanLitigationDetailsEditController(new ApexPages.StandardController(TestLoan));
            fillingResponce();
        }

        public void createLoan() {
            createDataForLoan();
            TestLoan = LoanBuilder.getBuilder(TestAccount).setExternalId('test_uuid').setLoanStatus('Litigation').save().getRecord();
        }

        private void createDataForLoan() {
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('CaseCollectionsRecoveriesExtension').save().getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void setMockForResponse(Boolean is_success, Boolean fail_response) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanLitigationDetailsEditMock(is_success, fail_response));
        }

        private void fillingResponce(){
            ApiCommandLoanLitigationDetails.LoanLitigationDetails test_responce = (ApiCommandLoanLitigationDetails.LoanLitigationDetails)System.JSON.deserialize(LoanLitigationDetailsMock.getMockResponceBody(), ApiCommandLoanLitigationDetails.LoanLitigationDetails.class);
            ClassUnderTest.CurrentLoanLitigationDetails = new LoanLitigationDetailsController.LoanLitigationDetailsWrapper(test_responce);
            ClassUnderTest.LoanLitigationDetailsEdit = new LoanLitigationDetailsEditController.LoanLitigationDetailsEditWrapper(ClassUnderTest.CurrentLoanLitigationDetails);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('LoanLitigationDetailsEditControllerTest')
                                     .setLastName('LoanLitigationDetailsEditControllerTest')
                                     .save();
    }
}