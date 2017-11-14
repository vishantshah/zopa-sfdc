public class LoanBuilder {

    public class Builder{
        private Loan__c Loan;

        private Builder(Account related_account){
            Loan = new Loan__c();
            Loan.Account__c = related_account.Id;
            Loan.Account__r = related_account;
        }

        private Builder(Loan__c loan_Loan){
            Loan = loan_Loan;
        }

        public Builder setLoanStatus(String loan_status){
            Loan.State__c = loan_status;
            return this;
        }

        public Builder setExternalId(String external_id){
            Loan.Loan_Id__c = external_id;
            return this;
        }

        public Builder setArrearsRatio(Decimal ratio){
            Loan.Arrears_Ratio__c = ratio;
            return this;
        }

        public Builder setMemberID(String member_id){
            Loan.Member_ID__c = member_id;
            return this;
        }

        public Builder setAccountDCAID(String dca_id){
            Loan.AccountDCA__c = dca_id;
            return this;
        }

        public Builder save(){
            upsert Loan;
            return this;
        }

        public Loan__c getRecord(){
            return Loan;
        }

        public List<Loan__c> getRecordList(Integer number_of_loans){
            List<Loan__c> loan_list = new List<Loan__c>();
            for( Integer i = 0; i < number_of_loans ;i++){
                loan_list.add(this.Loan.clone());
            }
            return loan_list;
        }
    }

    public static Builder getBuilder(Account related_account){
        return new Builder(related_account);
    }

    public static Builder getBuilder(Loan__c loan_Loan){
        return new Builder(loan_Loan);
    }
}