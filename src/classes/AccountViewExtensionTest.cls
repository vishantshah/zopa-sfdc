@isTest public class AccountViewExtensionTest {
    private static final String TEST_USER = 'CaseViewCasePrep';

    static testMethod void testSetIsCustomerInArrearsEmpty() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            Test.startTest();
                setup_data.initController();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.IsCustomerInArrears, 'Should be false');
        }
    }

    static testMethod void testSetIsCustomerInArrearsNotEmpty() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(1);
            Test.startTest();
                setup_data.initController();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.IsCustomerInArrears, 'Should be true');
        }
    }

    static testMethod void testShowMakeSensitivePopUp() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showMakeSensitivePopUp();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.IsShownPopUp, 'Should be true');
        }
    }

    static testMethod void testHidePopup() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.hidePopup();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.IsShownPopUp, 'Should be false');
        }
    }

    static testMethod void testGetReloadPageRefferenceWhenLoanExistsWithoutCases() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();
            setup_data.ClassUnderTest.CurrentAccount.Is_Sensitive__c = true;
            setup_data.ClassUnderTest.CurrentAccount.Comment_to_Sensitive_Account__c = 'test message';
            setup_data.setPageRefference();

            Test.startTest();
                setup_data.ClassUnderTest.onClickSave();
            Test.stopTest();

            List<Case> inserted_cases = [SELECT Id, Description, OwnerId, Sub_Process__c FROM Case];
            System.assertEquals(1, inserted_cases.size(), 'Should be created only 1 case');
            System.assertEquals('Sensitive Case', inserted_cases[0].Sub_Process__c, 'Sub Process should be Sensitive Case');
            System.assert(inserted_cases[0].Description.contains('test message') , 'Description was not set correct in new case');
            System.assertEquals(CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.SENSITIVE), inserted_cases[0].OwnerId, 'Case was not moved to Sensitive Queue');
            List<FeedItem> created_feed_items = [SELECT Body FROM FeedItem];
            System.assertEquals(2, created_feed_items.size(), 'Was not created 2 chatter posts');
            for(Integer i = 0; i < created_feed_items.size(); ++i){
                System.assert(created_feed_items[i].Body.contains('test message') , 'Message was not set correct in chatter post');
            }
        }
    }

    static testMethod void testGetReloadPageRefferenceWhenLoanExistsWithCase() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.createCasesForAccount();
            setup_data.initController();
            setup_data.ClassUnderTest.CurrentAccount.Is_Sensitive__c = true;
            setup_data.ClassUnderTest.CurrentAccount.Comment_to_Sensitive_Account__c = 'test message';
            setup_data.setPageRefference();

            Test.startTest();
                setup_data.ClassUnderTest.onClickSave();
            Test.stopTest();

            List<Case> inserted_cases = [SELECT Id, Description, OwnerId, Sub_Process__c, IsLockedFromUpdatesInProcess__c FROM Case];
            System.assertEquals(2, inserted_cases.size(), 'Should be only 2 case');
            System.assertEquals('Sensitive Case', inserted_cases[0].Sub_Process__c, 'Sub Process should be Sensitive Case');
            System.assertEquals(true, inserted_cases[0].IsLockedFromUpdatesInProcess__c, 'Should be removed from process');
            System.assert(inserted_cases[0].Description.contains('test message') , 'Description was not set correct in new case');
            System.assertEquals(CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.SENSITIVE), inserted_cases[0].OwnerId, 'Case was not moved to Sensitive Queue');
            List<FeedItem> created_feed_items = [SELECT Body FROM FeedItem];
            System.assertEquals(2, created_feed_items.size(), '2 chatter posts should be created: One for Account and one for Case Collections & Recoveries Case.');
            for(Integer i = 0; i < created_feed_items.size(); ++i){
                System.assert(created_feed_items[i].Body.contains('test message') , 'Message was not set correct in chatter post');
            }
        }
    }

    static testMethod void testGetReloadPageRefferenceWhenLoanNotExists() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.initController();
            setup_data.ClassUnderTest.CurrentAccount.Is_Sensitive__c = true;
            setup_data.ClassUnderTest.CurrentAccount.Comment_to_Sensitive_Account__c = 'Test Message';
            setup_data.setPageRefference();

            Test.startTest();
                setup_data.ClassUnderTest.onClickSave();
            Test.stopTest();

            List<Case> inserted_cases = [SELECT Id, Description, OwnerId, Sub_Process__c, IsLockedFromUpdatesInProcess__c FROM Case];
            System.assertEquals(0, inserted_cases.size(), 'New cases should not be created.');
            List<FeedItem> created_feed_items = [SELECT Body FROM FeedItem];
            System.assertEquals(1, created_feed_items.size(), '1 chatter post for Account should be created.');
            System.debug('feed item body - ' + created_feed_items[0].Body);
            System.assert(created_feed_items[0].Body.contains('Test Message') , 'Message was not set correct in chatter post');
        }
    }

    static testMethod void testGetReloadPageRefferenceIfRequiredFieldsAreNotFilling() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();
            setup_data.setPageRefference();
            Test.startTest();
                setup_data.ClassUnderTest.onClickSave();
            Test.stopTest();
            List<Case> inserted_cases = [SELECT Id, Description, OwnerId FROM Case];
            System.assertEquals(0, inserted_cases.size(), 'Should be created only 1 case');
            List<FeedItem> created_feed_items = [SELECT Body FROM FeedItem];
            System.assertEquals(0, created_feed_items.size(), 'Chatter post should not created');
            System.assertEquals(true, setup_data.ClassUnderTest.RenderedErrorMessage, 'Should rendered error message on the page');
        }
    }

    static testMethod void testGetSensitiveType(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();

            Test.startTest();
                 List<SelectOption> select_option_list = setup_data.ClassUnderTest.getSensitiveType();
            Test.stopTest();

            System.assert(!select_option_list.isEmpty(), 'Should be picklist value');
        }
    }

    static testMethod void testIsZcp78IsEnabledWhenEnabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-78');
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.initController();

            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.isZcp78IsEnabled();
            Test.stopTest();

            System.assertEquals(true, is_enabled, 'ZCP-78 should be enabled.');
        }
    }

    static testMethod void testIsZcp78IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-78');
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.initController();

            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.isZcp78IsEnabled();
            Test.stopTest();

            System.assertEquals(false, is_enabled, 'ZCP-78 should be disabled.');
        }
    }

    static testMethod void testNotOverridePageIfZcp78IsDisabled(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-78');
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();
            setup_data.setPageRefference();

            Test.startTest();
                PageReference result_page_ref = setup_data.ClassUnderTest.onPageLoad();
            Test.stopTest();

            System.assertEquals('/' + setup_data.TestAccount.Id + '?nooverride=1', result_page_ref.getUrl(), 'Should redirect to page with no override.');
        }
    }

    static testMethod void testNotOverridePageIfZcp78IsEnabledAndAccountIsNotPersonAccount(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-78');
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();
            setup_data.setPageRefference();
            setup_data.setAccountRecordType('Account.Business_Account');

            Test.startTest();
                PageReference result_page_ref = setup_data.ClassUnderTest.onPageLoad();
            Test.stopTest();

            System.assertEquals('/' + setup_data.TestAccount.Id + '?nooverride=1', result_page_ref.getUrl(), 'Should redirect to page with no override.');
        }
    }

    static testMethod void testOverridePageIfZcp78IsEnabledAndAccountIsPersonAccount(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-78');
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();
            setup_data.setPageRefference();
            setup_data.setAccountRecordType('Account.PersonAccount');

            Test.startTest();
                PageReference result_page_ref = setup_data.ClassUnderTest.onPageLoad();
            Test.stopTest();

            System.assertEquals(null, result_page_ref, 'Should stay on current page with override.');
        }
    }

    static testMethod void testGetHoldingAccountBalanceWhenFoundLastLoan(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();
            setup_data.setPageRefference();
            setup_data.setAccountRecordType('Account.PersonAccount');
            setup_data.setMockForLoanDetailsResponse(true, 200);

            Test.startTest();
                Decimal holding_account_balance = setup_data.ClassUnderTest.getHoldingAccountBalance();
            Test.stopTest();

            System.assertEquals(0.0, holding_account_balance, 'Should return Holding Account Balance of last found loan - value from Collections API mock.');
        }
    }

    static testMethod void testGetHoldingAccountBalanceWhenNotFoundLastLoan(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.initController();
            setup_data.setPageRefference();
            setup_data.setAccountRecordType('Account.PersonAccount');
            setup_data.setMockForLoanDetailsResponse(true, 200);

            Test.startTest();
                Decimal holding_account_balance = setup_data.ClassUnderTest.getHoldingAccountBalance();
            Test.stopTest();

            System.assertEquals(0, holding_account_balance, 'Should return 0 if last loan not found.');
        }
    }

        static testMethod void testGetHoldingAccountBalanceWhenLastLoanHasNotSetExternalId(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.initController();
            setup_data.setPageRefference();
            setup_data.setAccountRecordType('Account.PersonAccount');
            setup_data.setMockForLoanDetailsResponse(true, 200);

            Test.startTest();
                Decimal holding_account_balance = setup_data.ClassUnderTest.getHoldingAccountBalance();
            Test.stopTest();

            System.assertEquals(0, holding_account_balance, 'Should return 0 if last loan has not set UUID.');
        }
    }

    static testMethod void testGetHoldingAccountBalanceWhenGetLoanDetailsCommandFail(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();
            setup_data.setPageRefference();
            setup_data.setAccountRecordType('Account.PersonAccount');
            setup_data.setMockForLoanDetailsResponse(false, 500);

            Test.startTest();
                Decimal holding_account_balance = setup_data.ClassUnderTest.getHoldingAccountBalance();
            Test.stopTest();

            System.assertEquals(0, holding_account_balance, 'Should return 0 if get loan details command fail.');
        }
    }

    static testMethod void testGetLoanDetails(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();
            setup_data.setPageRefference();
            setup_data.setAccountRecordType('Account.PersonAccount');
            setup_data.setMockForLoanDetailsResponse(true, 200);

            Test.startTest();
                ApiCommandGetLoanDetails.LoanDetails loan_details = setup_data.ClassUnderTest.getLoanDetails(setup_data.TestLoan);
            Test.stopTest();

            System.assertEquals(0.0, loan_details.HoldingAccountBalance, 'Should return loan details with HoldingAccountBalance equal 0.0.');
        }
    }

    static testMethod void testGetLoanDetailsWhenCommandFail(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.createLoanForAccount(0);
            setup_data.initController();
            setup_data.setPageRefference();
            setup_data.setAccountRecordType('Account.PersonAccount');
            setup_data.setMockForLoanDetailsResponse(false, 500);

            Test.startTest();
                ApiCommandGetLoanDetails.LoanDetails loan_details = setup_data.ClassUnderTest.getLoanDetails(setup_data.TestLoan);
            Test.stopTest();

            System.assertEquals(null, loan_details, 'Should return null when can not get loan details.');
        }
    }

    static testMethod void testGetLoanDetailsWhenLoanHasNotSetExternalId(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser){
            setup_data.createDataForTest();
            setup_data.createLoanWithoutExternalIdForAccount(0);
            setup_data.initController();
            setup_data.setPageRefference();
            setup_data.setAccountRecordType('Account.PersonAccount');
            setup_data.setMockForLoanDetailsResponse(true, 200);

            Test.startTest();
                ApiCommandGetLoanDetails.LoanDetails loan_details = setup_data.ClassUnderTest.getLoanDetails(setup_data.TestLoan);
            Test.stopTest();

            System.assertEquals(null, loan_details, 'Should return null when can not get loan details.');
        }
    }

    private class SetupDataClass{
        public Loan__c TestLoan;
        public Account TestAccount;
        public User TestUser;
        public User AssignedToUser;
        public AccountViewExtension ClassUnderTest;

        public SetupDataClass(String last_name){
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        public void setPageRefference(){
            Test.setCurrentPageReference(new PageReference(Page.AccountViewPage.getUrl()));
            System.currentPageReference().getParameters().put('id', TestAccount.Id);
        }

        private void createDataForTest(){
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('CaseManualUnderwriterExtension').save().getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void setAccountRecordType(String record_type_name){
            TestAccount.RecordTypeId = RecordTypeUtility.getIdByName(record_type_name);
        }

        public void initController(){
            ClassUnderTest = new AccountViewExtension(new ApexPages.StandardController(TestAccount));
        }

        public void createCasesForAccount(){
            List<Case> new_case = new List<Case>();
            new_case.add(CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).save().getRecord());
            new_case.add(CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord());
        }

        public void createLoanForAccount(Decimal arrears_ratio){
            createLoanForAccount(arrears_ratio, true);
        }

        public void createLoanWithoutExternalIdForAccount(Decimal arrears_ratio){
            createLoanForAccount(arrears_ratio, false);
        }

        private void createLoanForAccount(Decimal arrears_ratio, Boolean with_external_id){
            TriggerHandler.IsTriggerActive = false;
            LoanBuilder.Builder loan_builder = LoanBuilder.getBuilder(TestAccount).setArrearsRatio(arrears_ratio);
            if(with_external_id) {
                loan_builder.setExternalId(Utility.getRandomString(8));
            }
            TestLoan = loan_builder.save().getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void setMockForLoanDetailsResponse(Boolean is_success, Integer code) {
            Test.setMock(HttpCalloutMock.class, new LoanDetailsViewMock(is_success, code));
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName(TEST_USER)
                                     .save();
    }
}