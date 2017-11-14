@isTest
public class TelephoneMatchViewControllerTest {

    static testMethod void testGetTelephoneMatchInformationSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getTelephoneMatchInformation();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'Should not have an error');
            System.assertNotEquals(null, setup_data.ClassUnderTest.TelephoneMatchList, 'Should initialize TelephoneMatchList');
            System.assertEquals(1, setup_data.ClassUnderTest.TelephoneMatchList.size(), 'Should fill TelephoneMatchList');
            System.assertEquals('123 my street, some town, PO5 4CD', setup_data.ClassUnderTest.TelephoneMatchList.get(0).Address, 'Should fill TelephoneMatchList correctly');
            System.assertEquals(true, setup_data.ClassUnderTest.TelephoneMatchList.get(0).getHasTelephoneMatchItems(), 'TelephoneMatch should have items');
            System.assertEquals(1, setup_data.ClassUnderTest.TelephoneMatchList.get(0).getTelephoneMatchItemsNumber(), 'TelephoneMatch should have items');
            System.assertEquals('Nate Denver', setup_data.ClassUnderTest.TelephoneMatchList.get(0).TelephoneMatchItems.get(0).Name, 'Should fill TelephoneMatchList correctly');
            System.assertEquals('880094485', setup_data.ClassUnderTest.TelephoneMatchList.get(0).TelephoneMatchItems.get(0).TelephoneNumber, 'Should fill TelephoneMatchList correctly');
        }
    }

    static testMethod void testGetTelephoneMatchInformationError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getTelephoneMatchInformation();
            Test.stopTest();
            System.assertEquals('Bad request. Internal Error', setup_data.ClassUnderTest.ErrorOnLoad, 'Should have an error');
            System.assertEquals(null, setup_data.ClassUnderTest.TelephoneMatchList, 'Should not fill TelephoneMatchList');
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
        public TelephoneMatchViewController ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'TelephoneMatchTest' AND LastName = 'TelephoneMatchTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new TelephoneMatchViewController();
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
                                     .setFirstName('TelephoneMatchTest')
                                     .setLastName('TelephoneMatchTest')
                                     .save();
    }
}