@isTest
private class AddressDetailsViewControllerTest {

    static testMethod void testGetAddressHistoryInformationSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAddressHistoryInformation();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'Should not have an error');
            System.assertNotEquals(null, setup_data.ClassUnderTest.AddressHistoryList, 'Should initialize AddressHistoryList');
            System.assertEquals(2, setup_data.ClassUnderTest.AddressHistoryList.size(), 'Should fill AddressHistoryList');
            System.assertEquals('123 Letsbe Avenue, London, SW84DA', setup_data.ClassUnderTest.AddressHistoryList.get(0).Address, 'Should fill AddressHistoryList correctly');
            System.assertEquals('03/11/2013', setup_data.ClassUnderTest.AddressHistoryList.get(1).ArrivedDate, 'Should fill AddressHistoryList correctly');
            System.assertEquals('2 Years, 4 Months', setup_data.ClassUnderTest.AddressHistoryList.get(1).TimeAtAddress, 'Should fill AddressHistoryList correctly');
        }
    }

    static testMethod void testGetAddressHistoryInformationError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getAddressHistoryInformation();
            Test.stopTest();
            System.assertEquals('Bad request. Internal Error', setup_data.ClassUnderTest.ErrorOnLoad, 'Should have an error');
            System.assertEquals(null, setup_data.ClassUnderTest.AddressHistoryList, 'Should not fill AddressHistoryList');
        }
    }

    static testMethod void testGetIsZopa83IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-83');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa83IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa83IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-83');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa83IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetNoRecordToDisplayReturnFalseWhenThereAreRecords() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getAddressHistoryInformation();
                Boolean no_record_to_display = setup_data.ClassUnderTest.getNoRecordToDisplay();
            Test.stopTest();
            System.assertEquals(false, no_record_to_display, 'Result should have records');
        }
    }

    static testMethod void testGetNoRecordToDisplayReturnFalseWhenThereIsAnError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getAddressHistoryInformation();
                Boolean no_record_to_display = setup_data.ClassUnderTest.getNoRecordToDisplay();
            Test.stopTest();
            System.assertEquals(false, no_record_to_display, 'No records should be false if there\'s an error');
        }
    }

    static testMethod void testGetNoRecordToDisplayReturnTrueWhenThereAreNoRecords() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, true);
            Test.startTest();
                setup_data.ClassUnderTest.getAddressHistoryInformation();
                Boolean no_record_to_display = setup_data.ClassUnderTest.getNoRecordToDisplay();
            Test.stopTest();
            System.assertEquals(true, no_record_to_display, 'There should be no records');
        }
    }

    private class SetupDataClass {
        public AddressDetailsViewController ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'AddressDetailsViewControllerTest' AND LastName = 'AddressDetailsViewControllerTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new AddressDetailsViewController();
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
                                     .setFirstName('AddressDetailsViewControllerTest')
                                     .setLastName('AddressDetailsViewControllerTest')
                                     .save();
    }
}