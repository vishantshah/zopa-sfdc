@isTest
private class ApiCommandLoanCallCreditTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.LOAN_CALLCREDIT, setup_data.ClassUnderTest.CommandName, 'CommandName should be initialized');
        }
    }

    static testMethod void testGetResponseSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandLoanCallCredit.CallCreditDetails call_credit_details = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals(102728, call_credit_details.ApplicantSummary.TotalBalancesActive, 'TotalBalancesActive is not set correctly');
            System.assertEquals(2663, call_credit_details.ApplicantSummary.TotalBalancesLoans, 'TotalBalancesLoans is not set correctly');
            System.assertEquals(100065, call_credit_details.ApplicantSummary.TotalBalancesMortgages, 'TotalBalancesMortgages is not set correctly');
            System.assertEquals(10034, call_credit_details.ApplicantSummary.TotalBalancesRevolve, 'TotalBalancesRevolve is not set correctly');
            System.assertEquals(123, call_credit_details.ApplicantSummary.TotalLimitsRevolve, 'TotalLimitsRevolve is not set correctly');
            System.assertEquals(123, call_credit_details.ApplicantSummary.BalanceLimitRatioRevolve, 'BalanceLimitRatioRevolve is not set correctly');
            System.assertEquals(456, call_credit_details.ApplicantSummary.TotalValueCashAdvances12Months, 'TotalValueCashAdvances12Months is not set correctly');
            System.assertEquals(789, call_credit_details.ApplicantSummary.TotalValueCashAdvances36Months, 'TotalValueCashAdvances36Months is not set correctly');
            System.assertEquals(0, call_credit_details.ApplicantSummary.TotalDelinqs12Months, 'TotalDelinqs12Months is not set correctly');
            System.assertEquals('U', call_credit_details.ApplicantSummary.WorstPayStatus12Months, 'WorstPayStatus12Months is not set correctly');
            System.assertEquals('U', call_credit_details.ApplicantSummary.WorstPayStatus36Months, 'WorstPayStatus36Months is not set correctly');
            System.assertEquals(0, call_credit_details.ApplicantSummary.TotalDefaults12Months, 'TotalDefaults12Months is not set correctly');
            System.assertEquals(0, call_credit_details.ApplicantSummary.TotalDefaults36Months, 'TotalDefaults36Months is not set correctly');
            System.assertEquals(false, call_credit_details.ApplicantSummary.CurrentlyInsolvent, 'CurrentlyInsolvent is not set correctly');
            System.assertEquals(0, call_credit_details.ApplicantSummary.TotalDischargedBAIs, 'TotalDischargedBAIs is not set correctly');
            System.assertEquals(0, call_credit_details.ApplicantSummary.TotalActiveJudgements, 'TotalActiveJudgements is not set correctly');
            System.assertEquals(0, call_credit_details.ApplicantSummary.TotalSatisfiedJudgements, 'TotalSatisfiedJudgements is not set correctly');
            System.assertEquals(0, call_credit_details.ApplicantSummary.TotalHomeCreditSearches3Months, 'TotalHomeCreditSearches3Months is not set correctly');

            System.assertNotEquals(null, call_credit_details.SummaryAddresses, 'SummaryAddresses is not set correctly');
            System.assertEquals(1, call_credit_details.SummaryAddresses.size(), 'SummaryAddresses is not set correctly');
            System.assertEquals(true, call_credit_details.SummaryAddresses.get(0).Current, 'Current is not set correctly');
            System.assertEquals('123 my street, some town, PO5 4CD', call_credit_details.SummaryAddresses.get(0).Address, 'Address is not set correctly');
            System.assertEquals('Individual', call_credit_details.SummaryAddresses.get(0).Level, 'Level is not set correctly');
            System.assertEquals('Electoral Roll', call_credit_details.SummaryAddresses.get(0).Source, 'Source is not set correctly');

            System.assertNotEquals(null, call_credit_details.ApplicantsCurrentAddressElectoralRoll, 'ApplicantsCurrentAddressElectoralRoll is not set correctly');
            System.assertEquals(1, call_credit_details.ApplicantsCurrentAddressElectoralRoll.size(), 'ApplicantsCurrentAddressElectoralRoll is not set correctly');
            System.assertEquals('123 my street, some town, PO5 4CD', call_credit_details.ApplicantsCurrentAddressElectoralRoll.get(0).Address, 'Address is not set correctly');
            System.assertEquals('Mr Adam Test', call_credit_details.ApplicantsCurrentAddressElectoralRoll.get(0).Resident, 'Resident is not set correctly');
            System.assertEquals('12/2015 to date', call_credit_details.ApplicantsCurrentAddressElectoralRoll.get(0).Duration, 'Duration is not set correctly');

            System.assertEquals(true, call_credit_details.IsIndividualReport, 'IsIndividualReport is not set correctly');

            System.assertEquals(null, call_credit_details.UnsettledShareAccounts, 'UnsettledShareAccounts is not set correctly');

            System.assertNotEquals(null, call_credit_details.SettledShareAccounts, 'SettledShareAccounts is not set correctly');
            System.assertEquals(1, call_credit_details.SettledShareAccounts.size(), 'SettledShareAccounts is not set correctly');
            System.assertEquals('Mr Adam Test', call_credit_details.SettledShareAccounts.get(0).AccountHolderName, 'AccountHolderName is not set correctly');
            System.assertEquals('123 my street, some town, PO5 4CD', call_credit_details.SettledShareAccounts.get(0).AccountHolderAddress, 'AccountHolderAddress is not set correctly');
            System.assertEquals('1986-01-26T00:00:00', call_credit_details.SettledShareAccounts.get(0).AccountHolderDob, 'AccountHolderDob is not set correctly');
            System.assertEquals('Normal', call_credit_details.SettledShareAccounts.get(0).AccountState, 'AccountState is not set correctly');
            System.assertEquals('Unsecured Loan', call_credit_details.SettledShareAccounts.get(0).AccountType, 'AccountType is not set correctly');
            System.assertEquals(2124, call_credit_details.SettledShareAccounts.get(0).CurrentBalance, 'CurrentBalance is not set correctly');
            System.assertEquals('2016-01-07T00:00:00', call_credit_details.SettledShareAccounts.get(0).DateUpdated, 'DateUpdated is not set correctly');
            System.assertEquals(123, call_credit_details.SettledShareAccounts.get(0).CreditLimitOverdraft, 'CreditLimitOverdraft is not set correctly');
            System.assertEquals('Finance House', call_credit_details.SettledShareAccounts.get(0).OrganisationType, 'OrganisationType is not set correctly');
            System.assertEquals('2016-02-12T00:00:00', call_credit_details.SettledShareAccounts.get(0).AccountStartDate, 'AccountStartDate is not set correctly');
            System.assertEquals('2016-02-13T00:00:00', call_credit_details.SettledShareAccounts.get(0).AccountEndDate, 'AccountEndDate is not set correctly');
            System.assertEquals(2520, call_credit_details.SettledShareAccounts.get(0).StartingBalance, 'StartingBalance is not set correctly');
            System.assertEquals(1234, call_credit_details.SettledShareAccounts.get(0).StatementBalance, 'StatementBalance is not set correctly');
            System.assertEquals('Monthly', call_credit_details.SettledShareAccounts.get(0).PaymentFrequency, 'PaymentFrequency is not set correctly');
            System.assertEquals(113, call_credit_details.SettledShareAccounts.get(0).RegularPayment, 'RegularPayment is not set correctly');
            System.assertEquals(24, call_credit_details.SettledShareAccounts.get(0).RepaymentPeriodPayment, 'RepaymentPeriodPayment is not set correctly');
            System.assertEquals(true, call_credit_details.SettledShareAccounts.get(0).Defaulted, 'Defaulted is not set correctly');
            System.assertEquals('2016-02-05T00:00:00', call_credit_details.SettledShareAccounts.get(0).DefaultDate, 'DefaultDate is not set correctly');
            System.assertEquals(2100, call_credit_details.SettledShareAccounts.get(0).OriginalDefaultBalance, 'OriginalDefaultBalance is not set correctly');
            System.assertEquals('2016-05-30T00:00:00', call_credit_details.SettledShareAccounts.get(0).DateDefaultSatisfied, 'DateDefaultSatisfied is not set correctly');

            System.assertEquals(6, call_credit_details.SettledShareAccounts.get(0).HistoricPaymentStatus.size(), 'HistoricPaymentStatus is not set correctly');
            System.assertEquals(6, call_credit_details.SettledShareAccounts.get(0).HistoricAccountStatus.size(), 'HistoricAccountStatus is not set correctly');
            System.assertEquals(6, call_credit_details.SettledShareAccounts.get(0).AccountHistory.size(), 'AccountHistory is not set correctly');


            System.assertNotEquals(null, call_credit_details.AddressLinks, 'AddressLinks is not set correctly');
            System.assertEquals(1, call_credit_details.AddressLinks.size(), 'AddressLinks is not set correctly');
            System.assertEquals('76 Trombones Road, Bristol, BS94EZ', call_credit_details.AddressLinks.get(0).Value, 'Value is not set correctly');

            System.assertNotEquals(null, call_credit_details.AssociateLinks, 'AssociateLinks is not set correctly');
            System.assertEquals(1, call_credit_details.AssociateLinks.size(), 'AssociateLinks is not set correctly');
            System.assertEquals('Bank', call_credit_details.AssociateLinks.get(0).SupplierType, 'SupplierType is not set correctly');
            System.assertEquals('2012-10-31T00:00:00', call_credit_details.AssociateLinks.get(0).LastConfirmationDate, 'LastConfirmationDate is not set correctly');
            System.assertEquals('2012-10-31T00:00:00', call_credit_details.AssociateLinks.get(0).EarliestConfirmationDate, 'EarliestConfirmationDate is not set correctly');
        }
    }

    static testMethod void testGetResponseNotSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandLoanCallCredit.CallCreditDetails call_credit_details = setup_data.ClassUnderTest.getResponse();
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
                ApiCommandLoanCallCredit.CallCreditDetails call_credit_details = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals('07/01/2016', call_credit_details.SettledShareAccounts.get(0).getDateUpdatedDisplay(), 'Got the wrong display date value');
            System.assertEquals('12/02/2016', call_credit_details.SettledShareAccounts.get(0).getAccountStartDateDisplay(), 'Got the wrong display date value');
            System.assertEquals('13/02/2016', call_credit_details.SettledShareAccounts.get(0).getAccountEndDateDisplay(), 'Got the wrong display date value');
            System.assertEquals('05/02/2016', call_credit_details.SettledShareAccounts.get(0).getDefaultDateDisplay(), 'Got the wrong display date value');
            System.assertEquals('30/05/2016', call_credit_details.SettledShareAccounts.get(0).getDateDefaultSatisfiedDisplay(), 'Got the wrong display date value');
            System.assertEquals('26/01/1986', call_credit_details.SettledShareAccounts.get(0).getAccountHolderDobDisplay(), 'Got the wrong display date value');

            System.assertEquals('31/10/2012', call_credit_details.AssociateLinks.get(0).getLastConfirmationDateDisplay(), 'Got the wrong display date value');
            System.assertEquals('31/10/2012', call_credit_details.AssociateLinks.get(0).getEarliestConfirmationDateDisplay(), 'Got the wrong display date value');
        }
    }

    private class SetupDataClass {
        public ApiCommandLoanCallCredit ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandLoanCallCreditTest' AND LastName = 'ApiCommandLoanCallCreditTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandLoanCallCredit(UUID);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanCallCreditTestMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('ApiCommandLoanCallCreditTest')
                                     .setLastName('ApiCommandLoanCallCreditTest')
                                     .save();
    }
}