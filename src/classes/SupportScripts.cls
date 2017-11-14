public with sharing class SupportScripts {
    public static Id createAccountReturnId(String first_name) {
        Account inserted_account = AccountBuilder.getBuilder()
            .setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT)
            .setFirstName(first_name)
            .setLastName('Smith')
            .setPersonBirthDay()
            .setPersonMobilePhone('07777111111')
            .setPersonHomePhone('07777111111')
            .setPersonEmail('jon.smith@gmail.com')
            .setPhone()
            .setBillingCity('London')
            .setBillingCountry('Canada')
            .setBillingStreet('Top Gear Lane, Result 7')
            .setBillingPostalCode('U786313')
            .save().getRecord();
        return inserted_account.Id;
    }

    public static void createLoanApplicationWithCaseCodes(Account customer_account, String triggered_case_codes, String aborted_case_codes, String errored_case_codes, Boolean quick_pay) {
        LoanApplicationBuilder.getBuilder(customer_account)
            .setApplicationDate(DateTime.now())
            .setApplicationName('1234-1234-1234-1234')
            .setApplicationAmount(11700.00)
            .setApplicationStatus('Approved')
            .setPurpose('Repairs')
            .setRate(9.02)
            .setFirstPayment(389.87)
            .setPaymentDay(4)
            .setQuickPay(quick_pay)
            .setInstitution('N/A')
            .setTerm(36)
            .setAPR(12.93)
            .setFee(620)
            .setBroker('Zopa Car Refi Low')
            .setMarket('A2')
            .setTriggeredReferralCodes(triggered_case_codes)
            .setAbortedReferralCodes(aborted_case_codes)
            .setErroredReferralCodes(errored_case_codes)
            .setExternalId(Utility.getRandomString(8))
            .save();
    }
}