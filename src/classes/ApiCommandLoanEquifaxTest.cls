@isTest
private class ApiCommandLoanEquifaxTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.LOAN_EQUIFAX, setup_data.ClassUnderTest.CommandName, 'CommandName should be initialized');
        }
    }

    static testMethod void testGetResponseSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandLoanEquifax.EquifaxDetails equifax_details = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertNotEquals(null, equifax_details.ApplicantCreditChecks, 'ApplicantCreditChecks is not set correctly');
            System.assertEquals(2, equifax_details.ApplicantCreditChecks.size(), 'ApplicantCreditChecks is not set correctly');
            System.assertEquals('123 my street, some town, PO5 4CD', equifax_details.ApplicantCreditChecks.get(0).Address, 'Address is not set correctly');
            System.assertEquals('76 Trombones Road, Bristol, BS94EZ', equifax_details.ApplicantCreditChecks.get(1).Address, 'Address is not set correctly');
            System.assertEquals(2, equifax_details.ApplicantCreditChecks.get(0).Insights.size(), 'Insights is not set correctly');
            System.assertEquals('Mr Adam Test', equifax_details.ApplicantCreditChecks.get(0).Insights.get(0).Name, 'Name is not set correctly');
            System.assertEquals('1991-10-28T00:00:00', equifax_details.ApplicantCreditChecks.get(0).Insights.get(0).DateOfBirth, 'DateOfBirth is not set correctly');
            System.assertEquals('2015-10-25T00:00:00', equifax_details.ApplicantCreditChecks.get(0).Insights.get(1).StartDate, 'StartDate is not set correctly');
            System.assertEquals('2015-10-26T00:00:00', equifax_details.ApplicantCreditChecks.get(0).Insights.get(1).EndDate, 'EndDate is not set correctly');

            System.assertNotEquals(null, equifax_details.AssociatedCreditChecks, 'AssociatedCreditChecks is not set correctly');
            System.assertEquals(1, equifax_details.AssociatedCreditChecks.size(), 'AssociatedCreditChecks is not set correctly');
            System.assertEquals('123 my street, some town, PO5 4CD', equifax_details.AssociatedCreditChecks.get(0).Address, 'Address is not set correctly');
            System.assertEquals(0, equifax_details.AssociatedCreditChecks.get(0).Insights.get(0).Balance, 'Balance is not set correctly');
            System.assertEquals(0, equifax_details.AssociatedCreditChecks.get(0).Insights.get(0).CreditLimit, 'CreditLimit is not set correctly');
            System.assertEquals('00000000000000000000000000000000', equifax_details.AssociatedCreditChecks.get(0).Insights.get(0).PaymentHistory, 'PaymentHistory is not set correctly');
            System.assertEquals('Comms Supplier', equifax_details.AssociatedCreditChecks.get(0).Insights.get(0).CompanyClass, 'CompanyClass is not set correctly');

            System.assertNotEquals(null, equifax_details.FamilyCreditChecks, 'FamilyCreditChecks is not set correctly');
            System.assertEquals(1, equifax_details.FamilyCreditChecks.size(), 'FamilyCreditChecks is not set correctly');
            System.assertEquals('123 my street, some town, PO5 4CD', equifax_details.FamilyCreditChecks.get(0).Address, 'Address is not set correctly');
            System.assertEquals('Fixed Term', equifax_details.FamilyCreditChecks.get(0).Insights.get(0).AccountType, 'AccountType is not set correctly');
            System.assertEquals('36 over 10M', equifax_details.FamilyCreditChecks.get(0).Insights.get(0).Terms, 'Terms is not set correctly');
            System.assertEquals('2016-07-21T00:00:00', equifax_details.FamilyCreditChecks.get(0).Insights.get(0).UpdateDate, 'UpdateDate is not set correctly');
            System.assertEquals(0, equifax_details.FamilyCreditChecks.get(0).Insights.get(0).DefaultBalance, 'DefaultBalance is not set correctly');

            System.assertNotEquals(null, equifax_details.OtherCreditChecks, 'OtherCreditChecks is not set correctly');
            System.assertEquals(1, equifax_details.OtherCreditChecks.size(), 'OtherCreditChecks is not set correctly');
            System.assertEquals('76 Trombones Road, Bristol, BS94EZ', equifax_details.OtherCreditChecks.get(0).Address, 'Address is not set correctly');
            System.assertEquals('2011-11-23T00:00:00', equifax_details.OtherCreditChecks.get(0).Insights.get(0).DelinquentDate, 'DelinquentDate is not set correctly');
            System.assertEquals('A', equifax_details.OtherCreditChecks.get(0).Insights.get(0).Flags, 'Flags is not set correctly');

        }
    }

    static testMethod void testGetResponseNotSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandLoanEquifax.EquifaxDetails equifax_details = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.CommandSuccessful, 'Command should have not been successful');
            System.assertEquals('Internal Server Error: Internal Error', setup_data.ClassUnderTest.CommandError, 'Got the wrong error');
        }
    }

    static testMethod void testGetDateDisplayField() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandLoanEquifax.EquifaxDetails equifax_details = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals('28/10/1991', equifax_details.ApplicantCreditChecks.get(0).Insights.get(0).getDateOfBirthDisplay(), 'Got the wrong display date value');
            System.assertEquals('12/02/2016', equifax_details.ApplicantCreditChecks.get(0).Insights.get(0).getStartDateDisplay(), 'Got the wrong display date value');
            System.assertEquals('', equifax_details.ApplicantCreditChecks.get(0).Insights.get(0).getEndDateDisplay(), 'Got the wrong display date value');
            System.assertEquals('07/08/2016', equifax_details.ApplicantCreditChecks.get(0).Insights.get(0).getUpdateDateDisplay(), 'Got the wrong display date value');
            System.assertEquals('', equifax_details.ApplicantCreditChecks.get(0).Insights.get(0).getDelinquentDateDisplay(), 'Got the wrong display date value');
        }
    }

    private class SetupDataClass {
        public ApiCommandLoanEquifax ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandLoanEquifaxTest' AND LastName = 'ApiCommandLoanEquifaxTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandLoanEquifax(UUID);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanEquifaxTestMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('ApiCommandLoanEquifaxTest')
                                     .setLastName('ApiCommandLoanEquifaxTest')
                                     .save();
    }
}