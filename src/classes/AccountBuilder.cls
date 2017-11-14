public class AccountBuilder {

    public static Builder getBuilder(String name){
        return new Builder(name);
    }

    public static Builder getBuilder(){
        return new Builder();
    }

    public static Builder getBuilder(Account existing_account){
        return new Builder(existing_account);
    }

    public class Builder{
        private Account NewAccount;

        private Builder(String name){
            NewAccount = new Account(Name = name);
            NewAccount.MemberID__c = 'Test' + Utility.getRandomString(5);
            NewAccount.RecordTypeId = RecordTypeUtility.getIdByName(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT);
        }

        private Builder(){
            NewAccount = new Account();
            NewAccount.MemberID__c = 'Test' + Utility.getRandomString(5);
            NewAccount.RecordTypeId = RecordTypeUtility.getIdByName(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT);
        }

        private Builder(Account existing_account){
            NewAccount = existing_account;
        }

        public Builder setFirstName(String first_name){
            NewAccount.FirstName = first_name;
            return this;
        }

        public Builder setLastName(String last_name){
            NewAccount.LastName = last_name;
            return this;
        }

        public Builder setLastName(){
            NewAccount.LastName = 'Test' + Utility.getRandomInteger();
            return this;
        }

        public Builder setName(String account_name){
            NewAccount.Name = account_name;
            return this;
        }

        public Builder setNumberOfEmployees(){
            NewAccount.NumberOfEmployees = Utility.getRandomInteger();
            return this;
        }

        public Builder setRecordType(String record_type_name){
            NewAccount.RecordTypeId = RecordTypeUtility.getIdByName(record_type_name);
            return this;
        }

        public Builder setBillingCity(String billing_city){
            NewAccount.BillingCity = billing_city;
            return this;
        }

        public Builder setBillingCountry(String billing_country){
            NewAccount.BillingCountry = billing_country;
            return this;
        }

        public Builder setBillingStreet(String billing_street){
            NewAccount.BillingStreet = billing_street;
            return this;
        }

        public Builder setBillingPostalCode(String billing_postal_code){
            NewAccount.BillingPostalCode = billing_postal_code;
            return this;
        }

        public Builder setBillingState(String billing_state){
            NewAccount.BillingState = billing_state;
            return this;
        }

        public Builder setDateOfBirth(Date date_of_birth){
            NewAccount.Date_Of_Birth__c = date_of_birth;
            return this;
        }

        public Builder setMemberId(String member_id){
            NewAccount.MemberID__c = member_id;
            return this;
        }

        public Builder setPersonMailingPostalcode(){
            NewAccount.PersonMailingPostalCode = 'code' + Utility.getRandomInteger();
            return this;
        }

        public Builder setPersonMailingPostalcode(String postal_code){
            NewAccount.PersonMailingPostalCode = postal_code;
            return this;
        }

        public Builder setPersonBirthDay(){
            NewAccount.PersonBirthdate = Date.today().addYears(-Math.round(Math.random() * 40));
            return this;
        }

        public Builder setPersonMobilePhone(){
            NewAccount.PersonMobilePhone = '34' + Utility.getRandomInteger();
            return this;
        }

        public Builder setPersonMobilePhone(String mobile_phone){
            NewAccount.PersonMobilePhone = mobile_phone;
            return this;
        }

        public Builder setPersonHomePhone(){
            NewAccount.PersonHomePhone = '44' + Utility.getRandomInteger();
            return this;
        }

        public Builder setPersonHomePhone(String home_phone){
            NewAccount.PersonHomePhone = home_phone;
            return this;
        }

        public Builder setPersonEmail(){
            NewAccount.PersonEmail = NewAccount.LastName + '@test.com';
            return this;
        }

        public Builder setPersonEmail(String person_email){
            NewAccount.PersonEmail = person_email;
            return this;
        }

        public Builder setPhone(){
            NewAccount.Phone = '34' + Utility.getRandomInteger();
            return this;
        }

        public Builder setParentId(String parent_id){
            NewAccount.ParentId = parent_id;
            return this;
        }

        public Builder setOwnerId(String owner_id){
            NewAccount.OwnerId = owner_id;
            return this;
        }

        public Builder setDcaId(String dca_id){
            NewAccount.DCA_Id__c = dca_id;
            return this;
        }

        public Builder save(){
            upsert NewAccount;
            return this;
        }

        public Account getRecord(){
            return NewAccount;
        }

        public List<Account> getRecordList(Integer number_of_accs){
            List<Account> acc_list = new List<Account>();
            for( Integer i = 0; i < number_of_accs ;i++){
                Account clone = this.NewAccount.clone();
                clone.MemberID__c = NewAccount.MemberID__c + i;
                acc_list.add(clone);
            }
            return acc_list;
        }
    }
}