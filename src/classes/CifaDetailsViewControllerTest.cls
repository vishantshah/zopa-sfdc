@isTest
private class CifaDetailsViewControllerTest {

    static testMethod void testGetCifaInformationSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getCifaInformation();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'Should not have an error');
            System.assertNotEquals(null, setup_data.ClassUnderTest.CifaList, 'Should initialize CifaList');
            System.assertEquals(1, setup_data.ClassUnderTest.CifaList.size(), 'Should fill CifaList');
            System.assertEquals('123 my street, some town, PO5 4CD', setup_data.ClassUnderTest.CifaList.get(0).Address, 'Should fill CifaList correctly');
            System.assertEquals(true, setup_data.ClassUnderTest.CifaList.get(0).getHasCifaItems(), 'Cifa should have items');
            System.assertEquals(1, setup_data.ClassUnderTest.CifaList.get(0).getCifaItemsNumber(), 'Cifa should have items');
            System.assertEquals('John Smith', setup_data.ClassUnderTest.CifaList.get(0).CifaItems.get(0).Name, 'Should fill CifaList correctly');
            System.assertEquals('01/01/1970', setup_data.ClassUnderTest.CifaList.get(0).CifaItems.get(0).DateOfBirth, 'Should fill CifaList correctly');
            System.assertEquals('03/02/2012', setup_data.ClassUnderTest.CifaList.get(0).CifaItems.get(0).FraudDate, 'Should fill CifaList correctly');
        }
    }

    static testMethod void testGetCifaInformationError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getCifaInformation();
            Test.stopTest();
            System.assertEquals('Bad request. Internal Error', setup_data.ClassUnderTest.ErrorOnLoad, 'Should have an error');
            System.assertEquals(null, setup_data.ClassUnderTest.CifaList, 'Should not fill CifaList');
        }
    }

    static testMethod void testGetIsZopa76IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-76');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa76IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa76IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-76');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa76IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be false');
        }
    }

    private class SetupDataClass {
        public CifaDetailsViewController ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'CifaDetailsViewControllerTest' AND LastName = 'CifaDetailsViewControllerTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new CifaDetailsViewController();
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
                                     .setFirstName('CifaDetailsViewControllerTest')
                                     .setLastName('CifaDetailsViewControllerTest')
                                     .save();
    }
}