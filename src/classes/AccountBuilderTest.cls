@isTest
private class AccountBuilderTest {

    static testMethod void testGetBuilderWithExistingAccountReturnsABuilderWithExistingAccount() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                AccountBuilder.Builder test_builder = AccountBuilder.getBuilder(setup_data.TestAccount);
            Test.stopTest();
            System.assertEquals(test_builder.getRecord(), setup_data.TestAccount, 'Builder must return record of account which it get in constructor.');
        }
    }

    static testMethod void testGetRecordReturnsAnAccountRecordWithDefaulRecordType() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder('Test').getRecord();
            Test.stopTest();
            System.assertEquals(RecordTypeUtility.getIdByName(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT), test_account.RecordTypeId, 'RecordTypeId was set incorrect by default');
        }
    }

    static testMethod void testGetRecordReturnsAnAccountRecord() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Sobject test_account = AccountBuilder.getBuilder('Test').setRecordType(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT).getRecord();
            Test.stopTest();
            System.assert(test_account instanceof Account, 'It should return an Account object type.');
        }
    }

    static testMethod void testSaveInsertsTheAccount() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder('Test2').setRecordType(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT).save().getRecord();
            Test.stopTest();
            System.assertNotEquals(null, test_account.Id, 'The Account has not been inserted');
        }
    }

    static testMethod void testSetRecordTypeSetsTheRecordType() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).getRecord();
            Test.stopTest();
            System.assertEquals(RecordTypeUtility.getIdByName(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT), test_account.RecordTypeId, 'The Record Type is different from the expected one');
        }
    }

    static testMethod void testSetLastNameSetsSomeRamdomValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setLastName().getRecord();
            Test.stopTest();
            System.assertNotEquals(null, test_account.LastName, 'The Last Name is not set');
        }
    }

    static testMethod void testSetSetBillingCitySetsValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setBillingCity('City').getRecord();
            Test.stopTest();
            System.assertEquals('City', test_account.BillingCity, 'The BillingCity is not set');
        }
    }

    static testMethod void testSetSetBillingStreetSetsValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setBillingStreet('Street').getRecord();
            Test.stopTest();
            System.assertEquals('Street', test_account.BillingStreet, 'The BillingStreet is not set');
        }
    }

    static testMethod void testSetSetBillingPostalCodeSetsValue(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setBillingPostalCode('Code').getRecord();
            Test.stopTest();
            System.assertEquals('Code', test_account.BillingPostalCode, 'The BillingPostalCode is not set');
        }
    }

    static testMethod void testSetPersonEmail() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setLastName().setPersonEmail().getRecord();
            Test.stopTest();
            System.assertEquals(test_account.LastName + '@test.com', test_account.PersonEmail, 'Email is not set as last name at test.com');
        }
    }

    static testMethod void testSetNumberOfEmployees() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder('Test').setRecordType(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT).setNumberOfEmployees().getRecord();
            Test.stopTest();
            System.assertEquals(false, test_account.NumberOfEmployees == null, 'The Number Of Employees should not be null.');
        }
    }

    static testMethod void testListBuilderGetRecords() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                List<Account> accounts = AccountBuilder.getBuilder('Test').setRecordType(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT).getRecordList(10);
            Test.stopTest();
            System.assertEquals(10,accounts.size(), 'It should return 10 accounts');
        }
    }

    static testMethod void testSetBillingCountryMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setBillingCountry('Test').getRecord();
            Test.stopTest();
            System.assertEquals('Test', test_account.BillingCountry, 'The BillingCountry value is not set as expected.');
        }
    }

    static testMethod void testSetBillingStateMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setBillingState('Test').getRecord();
            Test.stopTest();
            System.assertEquals('Test', test_account.BillingState, 'The BillingState value is not set as expected.');
        }
    }

    static testMethod void testSetPersonMobilePhoneMethodSetsValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setPersonMobilePhone().getRecord();
            Test.stopTest();
            System.assertEquals(true, String.isNotBlank(String.valueOf(test_account.PersonMobilePhone)), 'The PersonMobilePhone value is not set as expected.');
        }
    }

    static testMethod void testSetFirstNameMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setFirstName('test').getRecord();
            Test.stopTest();
            System.assertEquals('test', test_account.FirstName, 'The FirstName value is not set as expected.');
        }
    }

    static testMethod void testSetLastNameMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setLastName('test').getRecord();
            Test.stopTest();
            System.assertEquals('test', test_account.LastName, 'The LastName value is not set as expected.');
        }
    }

    static testMethod void testSetNameMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder('Ttest').setRecordType(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT).setName('test').getRecord();
            Test.stopTest();
            System.assertEquals('test', test_account.Name, 'The Name value is not set as expected.');
        }
    }

    static testMethod void testSetPhoneMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setPhone().getRecord();
            Test.stopTest();
            System.assertEquals(true, String.isNotBlank(String.valueOf(test_account.Phone)), 'The Phone value is not set as expected.');
        }
    }

    static testMethod void testSetPersonMailingPostalcodeMethodSetsValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setPersonMailingPostalcode().getRecord();
            Test.stopTest();
            System.assertEquals(true, String.isNotBlank(String.valueOf(test_account.PersonMailingPostalCode)), 'The PersonMailingPostalCode value is not set as expected.');
        }
    }

    static testMethod void testSetPersonMailingPostalcodeMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setPersonMailingPostalcode('Sample postal code').getRecord();
            Test.stopTest();
            System.assertEquals('Sample postal code',test_account.PersonMailingPostalCode, 'The PersonMailingPostalCode value is not set as expected.');
        }
    }

    static testMethod void testSetPersonBirthDayMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setPersonBirthDay().getRecord();
            Test.stopTest();
            System.assertEquals(true, String.isNotBlank(String.valueOf(test_account.PersonBirthdate)), 'The PersonBirthdate value is not set as expected.');
        }
    }

    static testMethod void testSetPersonMobilePhoneMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setPersonMobilePhone('07700770').getRecord();
            Test.stopTest();
            System.assertEquals('07700770', test_account.PersonMobilePhone, 'The PersonMobilePhone value is not set as expected.');
        }
    }

    static testMethod void testSetPersonHomePhoneMethodSetsValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setPersonHomePhone().getRecord();
            Test.stopTest();
            System.assertEquals(true, String.isNotBlank(String.valueOf(test_account.PersonHomePhone)), 'The PersonHomePhone value is not set as expected.');
        }
    }

    static testMethod void testSetPersonHomePhoneMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setPersonHomePhone('0777000777').getRecord();
            Test.stopTest();
            System.assertEquals('0777000777', test_account.PersonHomePhone, 'The PersonHomePhone value is not set as expected.');
        }
    }

    static testMethod void testSetPersonEmailMethodSetsValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setPersonEmail().getRecord();
            Test.stopTest();
            System.assertEquals(true, String.isNotBlank(String.valueOf(test_account.PersonEmail)), 'The PersonEmail value is not set as expected.');
        }
    }

    static testMethod void testSetPersonEmailMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setPersonEmail('sample@email.com').getRecord();
            Test.stopTest();
            System.assertEquals('sample@email.com', test_account.PersonEmail, 'The PersonEmail value is not set as expected.');
        }
    }

    static testMethod void testSetParentIdMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setParentId(setup_data.TestAccount.Id).getRecord();
            Test.stopTest();
            System.assertEquals(setup_data.TestAccount.Id, test_account.ParentId, 'The ParentId value is not set as expected.');
        }
    }

    static testMethod void testSetOwnerIdMethodSetsCorrectValue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setOwnerId(setup_data.TestUser.Id).getRecord();
            Test.stopTest();
            System.assertEquals(setup_data.TestUser.Id, test_account.OwnerId, 'The OwnerId value is not set as expected.');
        }
    }

    static testMethod void testSetMemberID() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setLastName().setMemberId('test').getRecord();
            Test.stopTest();
            System.assertEquals('test', test_account.MemberID__c, 'MemberID is not set as test');
        }
    }

    static testMethod void testSetDateOfBirth() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Date today = Date.today();
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_PERSON_ACCOUNT).setLastName().setDateOfBirth(today).getRecord();
            Test.stopTest();
            System.assertEquals(today, test_account.Date_Of_Birth__c, 'Date_Of_Birth__c is not set as test');
        }
    }

    static testMethod void testSetDcaId() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Account test_account = AccountBuilder.getBuilder().setRecordType(RecordTypeUtility.ACCOUNT_DCA_ACCOUNT).setLastName().setDcaId('test').getRecord();
            Test.stopTest();
            System.assertEquals('test', test_account.DCA_Id__c, 'DCA uuid is not set as test');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Account TestAccount;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE LastName = 'AccountBuilderTest' LIMIT 1];
            TestAccount = [SELECT Id FROM Account LIMIT 1];
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('AccountBuilderTest')
                                     .save();
    }

    @testSetup
    static void setupTestAccount() {
        AccountBuilder.getBuilder('Test').save();
    }
}