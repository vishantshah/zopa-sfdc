@isTest
public class ElectoralRollAddressesViewControllerTest {

    static testMethod void testGetElectoralRollInformationSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getElectoralRollAddressInformation();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'Should not have an error');
            System.assertNotEquals(null, setup_data.ClassUnderTest.ElectoralRollAddressList, 'Should initialize ElectoralRollAddressList');
            System.assertEquals(1, setup_data.ClassUnderTest.ElectoralRollAddressList.size(), 'Should fill ElectoralRollAddressList');
            System.assertEquals('123 my street, some town, PO5 4CD', setup_data.ClassUnderTest.ElectoralRollAddressList.get(0).Address, 'Should fill ElectoralRollAddressList correctly');
            System.assertEquals(true, setup_data.ClassUnderTest.ElectoralRollAddressList.get(0).getHasElectoralRollAddressItems(), 'ElectoralRoll should have items');
            System.assertEquals(1, setup_data.ClassUnderTest.ElectoralRollAddressList.get(0).getElectoralRollAddressItemsNumber(), 'ElectoralRoll should have items');
            System.assertEquals('John Doe', setup_data.ClassUnderTest.ElectoralRollAddressList.get(0).ElectoralRollAddressItems.get(0).VotersName, 'Should fill ElectoralRollAddressList correctly');
            System.assertEquals('71-10', setup_data.ClassUnderTest.ElectoralRollAddressList.get(0).ElectoralRollAddressItems.get(0).Period, 'Should fill ElectoralRollAddressList correctly');
            System.assertEquals(true, setup_data.ClassUnderTest.ElectoralRollAddressList.get(0).ElectoralRollAddressItems.get(0).IsApplicant, 'Should fill ElectoralRollAddressList correctly');
        }
    }

    static testMethod void testGetElectoralRollInformationError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getElectoralRollAddressInformation();
            Test.stopTest();
            System.assertEquals('Bad request. Internal Error', setup_data.ClassUnderTest.ErrorOnLoad, 'Should have an error');
            System.assertEquals(null, setup_data.ClassUnderTest.ElectoralRollAddressList, 'Should not fill ElectoralRollAddressList');
        }
    }

    static testMethod void testGetIsZopa147IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-147');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa147IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa147IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-147');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa147IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be false');
        }
    }

    private class SetupDataClass {
        public ElectoralRollAddressesViewController ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ElectoralRollAddressesViewControllerTest' AND LastName = 'ElectoralRollAddressesViewControllerTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ElectoralRollAddressesViewController();
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
                                     .setFirstName('ElectoralRollAddressesViewControllerTest')
                                     .setLastName('ElectoralRollAddressesViewControllerTest')
                                     .save();
    }
}