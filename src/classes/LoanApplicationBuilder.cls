public class LoanApplicationBuilder {

    public class Builder{
        private Loan_Application__c Application;

        private Builder(Account related_account){
            Application = new Loan_Application__c();
            Application.Customer_Account__c = related_account.Id;
            Application.Customer_Account__r = related_account;
        }

        private Builder(Loan_Application__c loan_application){
            Application = loan_application;
        }

        public Builder setApplicationDate(DateTime application_date){
            Application.Loan_Application_Date__c = application_date;
            return this;
        }

        public Builder setApplicationAmount(Decimal application_amount){
            Application.Loan_Application_Amount__c = application_amount;
            return this;
        }

        public Builder setApplicationStatus(String application_status){
            Application.Loan_Application_Status__c = application_status;
            return this;
        }

        public Builder setApplicationName(String loan_name) {
            Application.Name = loan_name;
            return this;
        }

        public Builder setLoanId(String loan_id){
            Application.Loan_ID__c = loan_id;
            return this;
        }

        public Builder setExpiryDate(DateTime expiry_date) {
            Application.Expiry_Date__c = expiry_date;
            return this;
        }

        public Builder setPurpose(String purpose){
            Application.Purpose__c = purpose;
            return this;
        }

        public Builder setRate(Decimal rate){
            Application.Rate__c = rate;
            return this;
        }

        public Builder setFirstPayment(Decimal first_payment){
            Application.First_Payment__c = first_payment;
            return this;
        }

        public Builder setPaymentDay(Integer payment_day){
            Application.Payment_Day__c = payment_day;
            return this;
        }

        public Builder setQuickPay(Boolean quick_pay){
            Application.QuickPay__c = quick_pay;
            return this;
        }

        public Builder setInstitution(String institution){
            Application.Institution__c = institution;
            return this;
        }

        public Builder setTerm(Integer term){
            Application.Term__c = term;
            return this;
        }

        public Builder setAPR(Decimal APR){
            Application.APR__c = APR;
            return this;
        }

        public Builder setFee(Decimal fee){
            Application.Fee__c = fee;
            return this;
        }

        public Builder setBroker(String broker){
            Application.Broker__c = broker;
            return this;
        }

        public Builder setMarket(String market){
            Application.Market__c = market;
            return this;
        }

        public Builder setTriggeredReferralCodes(String referral_codes){
            Application.Triggered_Referral_Codes__c = referral_codes;
            return this;
        }

        public Builder setAbortedReferralCodes(String referral_codes){
            Application.Aborted_Referral_Codes__c = referral_codes;
            return this;
        }

        public Builder setErroredReferralCodes(String referral_codes){
            Application.Errored_Referral_Codes__c = referral_codes;
            return this;
        }

        public Builder setExternalId(String external_id){
            Application.Loan_ID__c = external_id;
            return this;
        }

        public Builder setDocumentsLastUpdatedDate(Datetime last_updated){
            Application.Documents_Last_Updated_Date__c = last_updated;
            return this;
        }

        public Builder save(){
            upsert Application;
            return this;
        }

        public Loan_Application__c getRecord(){
            return Application;
        }

        public List<Loan_Application__c> getRecordList(Integer number_of_loans){
            List<Loan_Application__c> loan_list = new List<Loan_Application__c>();
            for( Integer i = 0; i < number_of_loans ;i++){
                loan_list.add( this.Application.clone());
            }
            return loan_list;
        }
    }

    public static Builder getBuilder(Account related_account){
        return new Builder(related_account);
    }

    public static Builder getBuilder(Loan_Application__c loan_application){
        return new Builder(loan_application);
    }
}