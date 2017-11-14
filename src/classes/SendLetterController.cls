public with sharing class SendLetterController {
    public String CurrentId { get; private set; }
    public Loan__c CurrentLoan { get; private set; }
    public Case CurrentCase { get; private set; }
    public Account CurrentAccount { get; private set; }
    public Boolean LazyLoadFinishedPickTemplate { get; private set; }
    public List<SelectOption> AllTemplatesOptions { get; private set; }
    public String SelectedTemplateName { get; set; }
    public String SelectedTemplateLabel { get; set; }
    public Boolean IsPageError { get; private set; }
    public transient String LetterData { get; private set; }

    public SendLetterController() {
        IsPageError = false;
        LazyLoadFinishedPickTemplate = false;
        AllTemplatesOptions = new List<SelectOption>();
        CurrentId = ApexPages.currentPage().getParameters().get('id');
        prepareRecordData();
        getAllLetterTemplates();
    }

    private void prepareRecordData() {
        if (String.isBlank(CurrentId)) {
            IsPageError = true;
            MessageUtility.addErrorPageMessage('Redirection to this page has been performed without required parameter!');
        } else if (isLoanId()) {
            getLoanData(CurrentId);
            getRelatedCollectionsRecoveriesCaseData(CurrentId);
            getAccountData();
        } else if (isCaseId()) {
            getCaseData(CurrentId);
            getLoanData(CurrentCase.Loan__c);
            getAccountData();
        } else {
            IsPageError = true;
            MessageUtility.addErrorPageMessage('Redirection to this page has been performed with incorrect parameter!');
        }
    }

    private Boolean isLoanId() {
        String loan_key_prefix = Loan__c.getSObjectType().getDescribe().getKeyPrefix();
        return CurrentId.substring(0, 3) == loan_key_prefix;
    }

    private Boolean isCaseId() {
        String case_key_prefix = Case.getSObjectType().getDescribe().getKeyPrefix();
        return CurrentId.substring(0, 3) == case_key_prefix;
    }

    private void getLoanData(String loan_id) {
        CurrentLoan = [SELECT Loan_Id__c, Account__c FROM Loan__c WHERE Id = :loan_id LIMIT 1];
    }

    private void getRelatedCollectionsRecoveriesCaseData(String loan_id) {
        List<Case> related_cases = [
                SELECT Id
                FROM Case
                WHERE Loan__c = :loan_id
                AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                AND IsClosed = false
        ];
        if(!related_cases.isEmpty()) {
            CurrentCase = related_cases[0];
        }
    }

    private void getCaseData(String case_id) {
        CurrentCase = [SELECT Id, Loan__c FROM Case WHERE Id = :case_id LIMIT 1];
    }

    private void getAccountData() {
        CurrentAccount = [SELECT Id, Name FROM Account WHERE Id = :CurrentLoan.Account__c LIMIT 1];
    }

    public Boolean getHasLoanExternalId(){
        return String.isNotBlank(CurrentLoan.Loan_Id__c);
    }

    @TestVisible
    private void getAllLetterTemplates() {
        ApiCommandLetterTemplatesGetAll get_all_templates_command = new ApiCommandLetterTemplatesGetAll();
        ApiCommandsFactory.getInstance().performApiCommandCallout(get_all_templates_command);
        if (get_all_templates_command.CommandSuccessful) {
            List<ApiCommandLetterTemplatesGet.LetterTemplate> all_templates = get_all_templates_command.getResponse();
            setTemplatesOptions(all_templates);
        } else {
            MessageUtility.addErrorPageMessage(get_all_templates_command.CommandError);
        }
        LazyLoadFinishedPickTemplate = true;
    }

    private void setTemplatesOptions(List<ApiCommandLetterTemplatesGet.LetterTemplate> templates) {
        AllTemplatesOptions = new List<SelectOption>();
        for (ApiCommandLetterTemplatesGet.LetterTemplate template : templates) {
            AllTemplatesOptions.add(new SelectOption(template.Name, template.FriendlyName));
        }
    }

    public void sendLetter() {
        if(validateSelectedTemplateName()) {
            clearOldLetter();
            ApiCommandLettersPost letters_post_command = ApiCommandLettersPost.getApiCommandLoanPostLettersAuto(CurrentLoan.Loan_Id__c, SelectedTemplateName);
            ApiCommandsFactory.getInstance().performApiCommandCallout(letters_post_command);
            if (letters_post_command.CommandSuccessful) {
                MessageUtility.addConfirmPageMessage('Letter generated and sent successfully (' + SelectedTemplateLabel + ').');
                ApiCommandLettersGetAll.Letter letter = (ApiCommandLettersGetAll.Letter) letters_post_command.getResponse();
                retrieveLetter(letter);
                addLetterTasks('Letter Sent (Manually) - ' + SelectedTemplateLabel);
            } else {
                MessageUtility.addErrorPageMessage(letters_post_command.CommandError);
            }
        }
    }

    public void generateLetter() {
        if(validateSelectedTemplateName()) {
            clearOldLetter();
            ApiCommandLettersPost letters_post_command = ApiCommandLettersPost.getApiCommandLoanPostLettersManual(CurrentLoan.Loan_Id__c, SelectedTemplateName);
            ApiCommandsFactory.getInstance().performApiCommandCallout(letters_post_command);
            if (letters_post_command.CommandSuccessful) {
                MessageUtility.addConfirmPageMessage('Letter generated successfully (' + SelectedTemplateLabel + ').');
                ApiCommandLettersGetAll.Letter letter = (ApiCommandLettersGetAll.Letter) letters_post_command.getResponse();
                retrieveLetter(letter);
                addLetterTasks('Letter Generated (Manually) - ' + SelectedTemplateLabel);
            } else {
                MessageUtility.addErrorPageMessage(letters_post_command.CommandError);
            }
        }
    }

    public void previewLetter() {
        if(validateSelectedTemplateName()) {
            clearOldLetter();
            ApiCommandLettersGetPreview letters_get_preview_command = new ApiCommandLettersGetPreview(CurrentLoan.Loan_Id__c, SelectedTemplateName);
            HttpResponse api_command_response = ApiCommandsFactory.getInstance().performApiCommandCallout(letters_get_preview_command);
            if (letters_get_preview_command.CommandSuccessful) {
                MessageUtility.addConfirmPageMessage('Letter preview retrieved successfully (' + SelectedTemplateLabel + ').');
                LetterData = EncodingUtil.base64Encode(api_command_response.getBodyAsBlob());
            } else {
                MessageUtility.addErrorPageMessage(letters_get_preview_command.CommandError);
            }
        }
    }

    private Boolean validateSelectedTemplateName() {
        if(String.isBlank(SelectedTemplateName)) {
            MessageUtility.addErrorPageMessage('You need to choose Letter Template!');
            return false;
        }
        return true;
    }

    private void clearOldLetter() {
        LetterData = null;
        prepareSelectedTemplateLabel();
    }

    private void prepareSelectedTemplateLabel() {
        SelectedTemplateLabel = '';
        for (SelectOption template_option : AllTemplatesOptions) {
            if (template_option.getValue() == SelectedTemplateName) {
                SelectedTemplateLabel = template_option.getLabel();
                break;
            }
        }
    }

    @TestVisible
    private void retrieveLetter(ApiCommandLettersGetAll.Letter letter) {
        ApiCommandLettersGet get_letters_command = new ApiCommandLettersGet(letter.LoanId, String.valueOf(letter.Id));
        HttpResponse api_command_response = ApiCommandsFactory.getInstance().performApiCommandCallout(get_letters_command);
        if (get_letters_command.CommandSuccessful) {
            MessageUtility.addConfirmPageMessage('Letter retrieved successfully.');
            LetterData = EncodingUtil.base64Encode(api_command_response.getBodyAsBlob());
        } else {
            MessageUtility.addErrorPageMessage(get_letters_command.CommandError);
        }
    }

    public Boolean getIsLetterData() {
        return String.isNotBlank(LetterData);
    }

    @TestVisible
    private void addLetterTasks(String subject) {
        createLetterTask(CurrentLoan.Id, subject);
        if (CurrentCase != null) {
            createLetterTask(CurrentCase.Id, subject);
        }
    }

    private void createLetterTask(String related_to_id, String subject) {
        TaskBuilder.getBuilder()
                .setSubject(subject)
                .setStatus('Completed')
                .setType('Letter')
                .setRelatedTo(related_to_id)
                .setRecordType(RecordTypeUtility.TASK_COLLECTIONS_LETTER)
                .setCompletedDateTime(Datetime.now())
                .save();
    }
}