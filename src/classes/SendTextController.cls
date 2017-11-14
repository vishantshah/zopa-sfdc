public class SendTextController {

    public String CurrentId { get; private set; }
    public Case CurrentCase { get; private set; }
    public Account CurrentAccount { get; private set; }
    public Boolean IsPageError { get; private set; }
    public String ToPhoneNumber { get; set; }
    public String TextContent { get; set; }
    public String TabToRefreshId { get; private set; }
    public Boolean IsSendActionSuccess { get; private set; }

    public SendTextController() {
        IsPageError = false;
        TextContent = '';
        CurrentId = ApexPages.currentPage().getParameters().get('id');
        prepareRecordData();
        prepareTabToRefreshId();
    }

    private void prepareRecordData() {
        if (String.isBlank(CurrentId)) {
            IsPageError = true;
            MessageUtility.addErrorPageMessage('Redirection to this page has been performed without required parameter!');
        } else if (isCaseId()) {
            getCaseData(CurrentId);
            getAccountData();
        } else {
            IsPageError = true;
            MessageUtility.addErrorPageMessage('Redirection to this page has been performed with incorrect parameter!');
        }
    }

    private Boolean isCaseId() {
        String case_key_prefix = Case.getSObjectType().getDescribe().getKeyPrefix();
        return CurrentId.substring(0, 3) == case_key_prefix;
    }

    private void getCaseData(String case_id) {
        CurrentCase = [
                SELECT Id, AccountId, Loan__c, RecordTypeId
                FROM Case
                WHERE Id = :case_id
                LIMIT 1
        ];
    }

    private void getAccountData() {
        List<Account> accounts = [
                SELECT Id, Name, PersonContactId, MobilePhone__c, PersonMobilePhone, Phone
                FROM Account
                WHERE Id = :CurrentCase.AccountId
                LIMIT 1
        ];
        if (!accounts.isEmpty()) {
            CurrentAccount = accounts[0];
            setToPhoneNumberFromAccount();
        } else {
            MessageUtility.addWarningPageMessage('Record is not directly related to Account!');
        }
    }

    @TestVisible
    private void setToPhoneNumberFromAccount() {
        if (String.isNotBlank(CurrentAccount.PersonMobilePhone)) {
            ToPhoneNumber = CurrentAccount.PersonMobilePhone;
        } else if (isPhoneNumberValid(CurrentAccount.Phone)) {
            ToPhoneNumber = CurrentAccount.Phone;
        } else if (isPhoneNumberValid(CurrentAccount.MobilePhone__c)) {
            ToPhoneNumber = CurrentAccount.MobilePhone__c;
        } else {
            MessageUtility.addWarningPageMessage('Valid Phone Number has not been found in related Account!');
        }
    }

    private Boolean isPhoneNumberValid(String phone_number) {
        return String.isNotBlank(phone_number) && (phone_number.startsWith('07') || phone_number.startsWith('+447'));
    }

    private void prepareTabToRefreshId() {
        TabToRefreshId = ApexPages.currentPage().getParameters().get('tab_to_refresh_id');
    }

    public void send() {
        IsSendActionSuccess = true;
        if (validateForm()) {
            TwilioConfig__c twilio_config = getTwilioConfig('ZOPA');
            if (twilio_config != null) {
                TwilioRestClient client = getTwilioClient(twilio_config);
                Map<String, String> text_properties = getTextProperties(twilio_config);
                try {
                    TwilioMessage message = sendText(client, text_properties);
                    MessageUtility.addConfirmPageMessage('Text sent successfully!');
                    createTasksAndChatterPosts(message);
                } catch (TwilioRestException e) {
                    IsSendActionSuccess = false;
                    MessageUtility.addErrorPageMessage(e.getMessage());
                }
            } else {
                IsSendActionSuccess = false;
                MessageUtility.addErrorPageMessage('Twilio configuration for "ZOPA" has not been found! Please ask your Salesforce Administrator about this.');
            }
        } else {
            IsSendActionSuccess = false;
        }
    }

    @TestVisible
    private Boolean validateForm() {
        Boolean valid = true;
        if (String.isBlank(ToPhoneNumber)) {
            valid = false;
            MessageUtility.addErrorPageMessage('Phone Number can not be empty!');
        }
        if (String.isBlank(TextContent)) {
            valid = false;
            MessageUtility.addErrorPageMessage('Text Content can not be empty!');
        } else if (TextContent.length() > 160) {
            valid = false;
            MessageUtility.addErrorPageMessage('Text Content can not be longer than 160 characters!');
        }
        return valid;
    }

    private TwilioConfig__c getTwilioConfig(String twilio_config_name) {
        return TwilioConfig__c.getValues(twilio_config_name);
    }

    private TwilioRestClient getTwilioClient(TwilioConfig__c twilio_config) {
        return new TwilioRestClient(
                twilio_config.AccountSid__c,
                twilio_config.AuthToken__c
        );
    }

    private Map<String, String> getTextProperties(TwilioConfig__c twilio_config) {
        return new Map<String, String>{
                'To' => ToPhoneNumber,
                'From' => twilio_config.Phone__c,
                'Body' => TextContent
        };
    }

    private TwilioMessage sendText(TwilioRestClient client, Map<String, String> text_properties) {
        return client.getAccount().getMessages().create(text_properties);
    }

    private void createTasksAndChatterPosts(TwilioMessage message) {
        createTasks(message);
        createChatterPosts(message);
    }

    private void createTasks(TwilioMessage message) {
        List<Task> tasks = new List<Task>();
        tasks.add(prepareTask(message, CurrentCase.Id));
        if (getIsCurrentCaseCollectionsAndRecoveries()) {
            tasks.add(prepareTask(message, CurrentCase.Loan__c));
        }
        insert tasks;
    }

    private Task prepareTask(TwilioMessage message, String related_to_id) {
        TaskBuilder.Builder builder = TaskBuilder.getBuilder()
                .setSubject('SMS Sent (Manually) - Free text')
                .setStatus('Completed')
                .setType('SMS')
                .setComment('"' + message.getBody() + '" sent to "' + ToPhoneNumber + '"')
                .setRelatedTo(related_to_id)
                .setMethod('Manual')
                .setRecordType(RecordTypeUtility.TASK_SMS)
                .setCompletedDateTime(Datetime.now())
                .setOwner(UserInfo.getUserId());
        if (CurrentAccount != null && String.isNotBlank(CurrentAccount.PersonContactId)) {
            builder.setAssignTo(CurrentAccount.PersonContactId);
        }
        return builder.getRecord();
    }

    private void createChatterPosts(TwilioMessage message) {
        List<FeedItem> posts = new List<FeedItem>();
        posts.add(preparePost(message, CurrentCase.Id));
        if (getIsCurrentCaseCollectionsAndRecoveries()) {
            posts.add(preparePost(message, CurrentCase.Loan__c));
        }
        insert posts;
    }

    private FeedItem preparePost(TwilioMessage message, String related_to_id) {
        FeedItem post = new FeedItem();
        post.ParentId = related_to_id;
        post.Body = ' sent SMS (Manually) - Free text';
        return post;
    }

    public Boolean getIsCurrentCaseCollectionsAndRecoveries() {
        return CurrentCase.RecordTypeId == RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES);
    }
}