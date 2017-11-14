@isTest
private class CountyCourtJudgmentViewContTest {

    static testMethod void testGetCountyCourtJudgmentInformationSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getCountyCourtJudgmentInformation();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'Should not have an error');
            System.assertNotEquals(null, setup_data.ClassUnderTest.CountyCourtJudgmentList, 'Should initialize CountyCourtJudgmentList');
            System.assertEquals(1, setup_data.ClassUnderTest.CountyCourtJudgmentList.size(), 'Should fill CountyCourtJudgmentList');
            System.assertEquals('123 my street, some town, PO5 4CD', setup_data.ClassUnderTest.CountyCourtJudgmentList.get(0).Address, 'Should fill CountyCourtJudgmentList correctly');
            System.assertEquals(true, setup_data.ClassUnderTest.CountyCourtJudgmentList.get(0).getHasCountyCourtJudgmentItems(), 'Cifa should have items');
            System.assertEquals(1, setup_data.ClassUnderTest.CountyCourtJudgmentList.get(0).getCountyCourtJudgmentItemsNumber(), 'Cifa should have items');
            System.assertEquals('John Smith', setup_data.ClassUnderTest.CountyCourtJudgmentList.get(0).CountyCourtJudgmentItems.get(0).Name, 'Should fill CountyCourtJudgmentList correctly');
            System.assertEquals('01/01/1970', setup_data.ClassUnderTest.CountyCourtJudgmentList.get(0).CountyCourtJudgmentItems.get(0).DateOfBirth, 'Should fill CountyCourtJudgmentList correctly');
            System.assertEquals(123, setup_data.ClassUnderTest.CountyCourtJudgmentList.get(0).CountyCourtJudgmentItems.get(0).Value, 'Should fill CountyCourtJudgmentList correctly');
        }
    }

    static testMethod void testGetCountyCourtJudgmentInformationError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getCountyCourtJudgmentInformation();
            Test.stopTest();
            System.assertEquals('Bad request. Internal Error', setup_data.ClassUnderTest.ErrorOnLoad, 'Should have an error');
            System.assertEquals(null, setup_data.ClassUnderTest.CountyCourtJudgmentList, 'Should not fill CountyCourtJudgmentList');
        }
    }

    static testMethod void testGetIsZopa77IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-77');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa77IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa77IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-77');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa77IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be false');
        }
    }

    private class SetupDataClass {
        public CountyCourtJudgmentViewCont ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'CountyCourtJudgmentViewContTest' AND LastName = 'CountyCourtJudgmentViewContTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new CountyCourtJudgmentViewCont();
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
                                     .setFirstName('CountyCourtJudgmentViewContTest')
                                     .setLastName('CountyCourtJudgmentViewContTest')
                                     .save();
    }
}