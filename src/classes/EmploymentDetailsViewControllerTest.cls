@isTest
private class EmploymentDetailsViewControllerTest {

    static testMethod void testGetEmploymentDetailsInformationSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getEmploymentDetailsInformation();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'Should not have an error');
            System.assertEquals('Programmer', setup_data.ClassUnderTest.CurrentEmployer.JobTitle, 'JobTitle is not set correctly');
            System.assertEquals('MegaCorp', setup_data.ClassUnderTest.CurrentEmployer.Name, 'Name is not set correctly');
            System.assertEquals('Mega Plaze, London', setup_data.ClassUnderTest.CurrentEmployer.Address, 'Address is not set correctly');
            System.assertEquals('EC1A 1AA', setup_data.ClassUnderTest.CurrentEmployer.PostCode, 'PostCode is not set correctly');
            System.assertEquals('020 77554654', setup_data.ClassUnderTest.CurrentEmployer.Telephone, 'Telephone is not set correctly');
            System.assertEquals('5 Months', setup_data.ClassUnderTest.CurrentEmployer.TimeAtEmployer, 'TimeAtEmployer is not set correctly');
            System.assertEquals('Some Manager', setup_data.ClassUnderTest.CurrentEmployer.ContactInfo, 'ContactInfo is not set correctly');

            System.assertEquals('Programmer', setup_data.ClassUnderTest.PreviousEmployer.JobTitle, 'JobTitle is not set correctly');
            System.assertEquals('SmallerCorp', setup_data.ClassUnderTest.PreviousEmployer.Name, 'Name is not set correctly');
            System.assertEquals('Hoxton Square, London', setup_data.ClassUnderTest.PreviousEmployer.Address, 'Address is not set correctly');
            System.assertEquals('N1 6NU', setup_data.ClassUnderTest.PreviousEmployer.PostCode, 'PostCode is not set correctly');
            System.assertEquals('020 7222222', setup_data.ClassUnderTest.PreviousEmployer.Telephone, 'Telephone is not set correctly');
            System.assertEquals('1 Year, 8 Months', setup_data.ClassUnderTest.PreviousEmployer.TimeAtEmployer, 'TimeAtEmployer is not set correctly');
            System.assertEquals('Some Manager', setup_data.ClassUnderTest.PreviousEmployer.ContactInfo, 'ContactInfo is not set correctly');
        }
    }

    static testMethod void testGetEmploymentDetailsInformationError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getEmploymentDetailsInformation();
            Test.stopTest();
            System.assertEquals('Bad request. Internal Error', setup_data.ClassUnderTest.ErrorOnLoad, 'Should have an error');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentEmployer, 'CurrentEmployer should be null');
            System.assertEquals(null, setup_data.ClassUnderTest.PreviousEmployer, 'PreviousEmployer should be null');
        }
    }

    static testMethod void testGetIsZopa73IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-73');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa73IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa73IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-73');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa73IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be false');
        }
    }

    private class SetupDataClass {
        public EmploymentDetailsViewController ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'EmploymentDetailsViewControllerTest' AND LastName = 'EmploymentDetailsViewControllerTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new EmploymentDetailsViewController();
            ClassUnderTest.LoanAppId = 'test_id';
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanInfoTestMock(is_success));
        }

        public void setMockForResponse(Boolean is_success, Boolean empty_response) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanInfoTestMock(is_success, empty_response));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('EmploymentDetailsViewControllerTest')
                                     .setLastName('EmploymentDetailsViewControllerTest')
                                     .save();
    }
}