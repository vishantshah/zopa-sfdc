public class CaseBuilder {

    public class Builder{
        private Case CurrentCase;
        private Account CustomerAccount;

        private Builder(Account customer_account){
            CurrentCase = new Case();
            this.CustomerAccount = customer_account;
            setDefaultCaseValues();
        }

        private Builder(){
            CurrentCase = new Case();
        }

        private Builder(Case existing_case){
            CurrentCase = existing_case;
        }

        private void setDefaultCaseValues(){
            CurrentCase.Status = 'Open';
            CurrentCase.Origin = 'Phone';
            CurrentCase.Type = 'Problem';
            CurrentCase.OwnerId = UserInfo.getUserId();
            if(CustomerAccount != null){
                CurrentCase.AccountId = CustomerAccount.Id;
                CurrentCase.Subject = 'Case Logged for: ' + CustomerAccount.Name;
                if(CustomerAccount.PersonContactId != null){
                    CurrentCase.ContactId = CustomerAccount.PersonContactId;
                }
            }
        }

        public Builder setContact(Contact contact) {
            CurrentCase.ContactId = contact.Id;
            return this;
        }

        public Builder setReason(String reason){
            CurrentCase.Reason = reason;
            return this;
        }

        public Builder setAccountId(Id account_id){
            CurrentCase.AccountId = account_id;
            return this;
        }

        public Builder setStatus(String status){
            CurrentCase.Status = status;
            return this;
        }

        public Builder setOrigin(String origin){
            CurrentCase.Origin = origin;
            return this;
        }

        public Builder setType(String type){
            CurrentCase.Type = type;
            return this;
        }

        public Builder setSubject(String subject){
            CurrentCase.Subject = subject;
            return this;
        }

        public Builder setRecordType(String record_type_name){
            CurrentCase.RecordTypeId = RecordTypeUtility.getIdByName(record_type_name);
            return this;
        }

        public Builder setRecordTypeId(Id record_type_id){
            CurrentCase.RecordTypeId = record_type_id;
            return this;
        }

        public Builder setOwner(String owner_id){
            CurrentCase.OwnerId = owner_id;
            return this;
        }

        public Builder setDescription(String description){
            CurrentCase.Description = description;
            return this;
        }

        public Builder setIsSensitive(Boolean is_sensitive){
            CurrentCase.Is_Sensitive__c = is_sensitive;
            return this;
        }

        public Builder setPriority(String priority){
            CurrentCase.Priority = priority;
            return this;
        }

        public Builder setSubProcess(String sub_process){
            CurrentCase.Sub_Process__c = sub_process;
            return this;
        }

        public Builder setProcess(String process){
            CurrentCase.Process__c = process;
            return this;
        }

        public Builder setProcessDayCounter(Decimal days){
            CurrentCase.Process_Day_Counter__c = days;
            return this;
        }

        public Builder setLoanApplication(Loan_Application__c loan_application){
            CurrentCase.Loan_Application__c = loan_application.Id;
            CurrentCase.Loan_Application__r = loan_application;
            return this;
        }

        public Builder setInitialUnderwriter(Id user_id){
            CurrentCase.Initial_Underwriter__c = user_id;
            return this;
        }

        public Builder setTriggeredReferralCodes(String referral_codes){
            CurrentCase.Triggered_Referral_Codes__c = referral_codes;
            return this;
        }

        public Builder setAbortedReferralCodes(String referral_codes){
            CurrentCase.Aborted_Referral_Codes__c = referral_codes;
            return this;
        }

        public Builder setErroredReferralCodes(String referral_codes){
            CurrentCase.Errored_Referral_Codes__c = referral_codes;
            return this;
        }

        public Builder setLoan(Loan__c loan){
            CurrentCase.Loan__c = loan.Id;
            CurrentCase.loan__r = loan;
            return this;
        }

        public Builder setAllReferralCodes(String referral_codes){
            CurrentCase.All_Referral_Codes__c = referral_codes;
            return this;
        }

        public Builder setAutoCanceledLoan(Boolean auto_canceled_loan){
            CurrentCase.Auto_Canceled_Loan__c = auto_canceled_loan;
            return this;
        }

        public Builder setAccountEmail(String customer_email){
            CurrentCase.Workflow_Emailing_Person_Account__c = customer_email;
            return this;
        }

        public Builder setAccountDCAID(String dca_id){
            CurrentCase.AccountDCA__c = dca_id;
            return this;
        }

        public Builder setDefaultNoticeSentDate(Datetime default_Notice_Sent_Date){
            CurrentCase.Default_Notice_Sent_Date__c = default_Notice_Sent_Date;
            return this;
        }

        public Builder setIsLockedFromUpdatesInProcess(Boolean is_locked){
            CurrentCase.IsLockedFromUpdatesInProcess__c = is_locked;
            return this;
        }

        public Builder setNextReviewDate(Datetime next_review_date){
            CurrentCase.Next_Review_Date__c = next_review_date;
            return this;
        }

        public Builder save(){
            upsert CurrentCase;
            return this;
        }

        public Case getRecord(){
            return this.CurrentCase;
        }

        public List<Case> getRecordList(Integer no_of_cases){
            List<Case> case_list = new List<Case>();
            for( Integer i = 0; i < no_of_cases ;i++){
                case_list.add( this.CurrentCase.clone());
            }
            return case_list;
        }
    }

    public static Builder getBuilder(Account customer_account){
        return new Builder(customer_account);
    }

    public static Builder getBuilder(Case existing_case){
        return new Builder(existing_case);
    }

    public static Builder getBuilder(){
        return new Builder();
    }
}