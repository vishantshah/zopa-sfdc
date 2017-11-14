@isTest
private class BankDetailsSectionControllerTest {

    static testMethod void testGetBankDetailsInformationSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getBankDetailsInformation();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'Should not have an error');
            System.assertNotEquals(null, setup_data.ClassUnderTest.BankDetailsList, 'Should initialize BankDetailsList');
            System.assertEquals(5, setup_data.ClassUnderTest.BankDetailsList.size(), 'Should fill BankDetailsList');

            System.assertEquals('Bank Name', setup_data.ClassUnderTest.BankDetailsList.get(0).DetailLabel, 'DetailLabel is not set correctly');
            System.assertEquals('Account Holder Name', setup_data.ClassUnderTest.BankDetailsList.get(1).DetailLabel, 'DetailLabel is not set correctly');
            System.assertEquals('Sort Code', setup_data.ClassUnderTest.BankDetailsList.get(2).DetailLabel, 'DetailLabel is not set correctly');
            System.assertEquals('Account Number', setup_data.ClassUnderTest.BankDetailsList.get(3).DetailLabel, 'DetailLabel is not set correctly');
            System.assertEquals('Bank Check', setup_data.ClassUnderTest.BankDetailsList.get(4).DetailLabel, 'DetailLabel is not set correctly');

            System.assertEquals('Barclays', setup_data.ClassUnderTest.BankDetailsList.get(0).CustomerDirectDebitMandate, 'CustomerDirectDebitMandate is not set correctly');
            System.assertEquals('John Smith', setup_data.ClassUnderTest.BankDetailsList.get(1).CustomerDirectDebitMandate, 'CustomerDirectDebitMandate is not set correctly');
            System.assertEquals('10-20-30', setup_data.ClassUnderTest.BankDetailsList.get(2).CustomerDirectDebitMandate, 'CustomerDirectDebitMandate is not set correctly');
            System.assertEquals('60555123', setup_data.ClassUnderTest.BankDetailsList.get(3).CustomerDirectDebitMandate, 'CustomerDirectDebitMandate is not set correctly');
            System.assertEquals('Bank Account Valid', setup_data.ClassUnderTest.BankDetailsList.get(4).CustomerDirectDebitMandate, 'CustomerDirectDebitMandate is not set correctly');
        }
    }

    static testMethod void testGetBankDetailsInformationUnsuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getBankDetailsInformation();
            Test.stopTest();
            System.assertEquals('Bad request. Internal Error', setup_data.ClassUnderTest.ErrorOnLoad, 'Should have an error');
            System.assertEquals(null, setup_data.ClassUnderTest.BankDetailsList, 'Should not fill BankDetailsList');
        }
    }

    static testMethod void testGetIsZopa57IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-57');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa57IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa57IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-57');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa57IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be true');
        }
    }

    static testMethod void testGetIsZopa156IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-156');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa156IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa156IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-156');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa156IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be true');
        }
    }

    static testMethod void testValidateBankDetailsSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponseForValidateDetails(true);
            Test.startTest();
                setup_data.ClassUnderTest.validateBankDetails();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'Should not have an error');
            System.assertEquals('PASS', setup_data.ClassUnderTest.ValidateBankDetails.Result, 'Should fill Result in ValidateBankDetails');
        }
    }

    static testMethod void testValidateBankDetailsUnsuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponseForValidateDetails(false);
            Test.startTest();
                setup_data.ClassUnderTest.validateBankDetails();
            Test.stopTest();
            System.assertEquals('Something whent wrong while proccessing the request', setup_data.ClassUnderTest.ErrorOnLoadValidateDetails, 'Should have an error');
            System.assertEquals(null, setup_data.ClassUnderTest.ValidateBankDetails, 'Should not fill ValidateBankDetails');
        }
    }

    static testMethod void testShowValidateBankDetailsPopup() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponseForValidateDetails(true);
            Test.startTest();
                setup_data.ClassUnderTest.showValidateBankDetailsPopup();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsShownValidateBankDetailsPopUp, 'Should show popup');
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'Should not have an error');
            System.assertEquals('PASS', setup_data.ClassUnderTest.ValidateBankDetails.Result, 'Should fill Result in ValidateBankDetails');
        }
    }

    static testMethod void testEndActionValidateBankDetails() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.endActionValidateBankDetails();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.IsShownValidateBankDetailsPopUp, 'Should hide popup');
            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'Should not have an error');
            System.assertNotEquals(null, setup_data.ClassUnderTest.BankDetailsList, 'Should initialize BankDetailsList');
            System.assertEquals(5, setup_data.ClassUnderTest.BankDetailsList.size(), 'Should fill BankDetailsList');
        }
    }

    private class SetupDataClass {
        public BankDetailsSectionController ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'BankDetailsSectionControllerTest' AND LastName = 'BankDetailsSectionControllerTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new BankDetailsSectionController();
            ClassUnderTest.LoanAppId = 'test_id';
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanInfoTestMock(is_success));
        }

        public void setMockForResponseForValidateDetails(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiValidateBankDetailsTestMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('BankDetailsSectionControllerTest')
                                     .setLastName('BankDetailsSectionControllerTest')
                                     .save();
    }
}