public with sharing class DocumentsManagementExtension {
    public static final List<String> ADDITIONAL_FIELDS_TO_QUERY = new List<String>{ 'Customer_Account__c'};
    public Loan_Application__c CurrentLoan {get; private set;}
    public String DocumentType {get; set;}
    public String ContentType {get; set;}
    public Document DocumentToUpload {get; set;}

    public DocumentsManagementExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(ADDITIONAL_FIELDS_TO_QUERY);
        }
        CurrentLoan = (Loan_Application__c)controller.getRecord();
        DocumentToUpload = new Document();
    }

    public List<SelectOption> getAvailableDocumentTypes() {
        List<SelectOption> options = new List<SelectOption>();
        for (Available_Document_Types__c doc_type : Available_Document_Types__c.getall().values()) {
            options.add(new SelectOption(doc_type.Zopa_Value__c, doc_type.Name));
        }
        return options;
    }

    public PageReference uploadDocument() {
        if (DocumentToUpload.Body == null) {
            MessageUtility.addErrorPageMessage('Please select file');
            return ApexPages.currentPage();
        }
        try {
            ApiCommandUploadDocument upload_command = new ApiCommandUploadDocument(CurrentLoan.Loan_ID__c, DocumentToUpload.body, DocumentType, DocumentToUpload.name, ContentType);
            ApiCommandsFactory.getInstance().performApiCommandCallout(upload_command);
            if (upload_command.CommandSuccessful) {
                MessageUtility.addConfirmPageMessage('Document uploaded successfully');
            } else {
                MessageUtility.addErrorPageMessage(upload_command.CommandError);
            }
        } catch(DMLException e) {
            MessageUtility.addErrorPageMessage('Error has occured on uploading file on server');
        }
        DocumentToUpload = new Document();
        return ApexPages.currentPage();
    }

    public Boolean getIsZopa55IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-55').isFeatureEnabled();
    }
}