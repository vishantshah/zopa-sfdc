public without sharing class EmailAttachmentHandler{
    static EmailAttachmentHandler Instance;
    @TestVisible Set<Attachment> EmailAttachments = new Set<Attachment>();
    @TestVisible Map<Id,EmailMessage> ParentEmailsOfAttachments = new Map<Id,EmailMessage>();
    @TestVisible Map<Id,Case> ParentCasesOfEmail;

    private EmailAttachmentHandler(){
    }

    public static EmailAttachmentHandler getInstance(){
        if(Instance == null) {
            Instance = new EmailAttachmentHandler();
        }
        return Instance;
    }

    public void checkIfItIsEmailAttachment(Attachment document){
        if(isDocumentAttachedToIncomingEmail(document)){
            EmailAttachments.add(document);
        }
    }

    @TestVisible private Boolean isDocumentAttachedToIncomingEmail(Attachment document){
        Schema.DescribeSObjectResult[] email_message_description = Schema.describeSObjects(new String[]{'EmailMessage'});
        if(!String.valueOf(document.ParentId).startsWith(email_message_description.get(0).getKeyPrefix())){
            return false;
        }
        return true;
    }

    public void sendToBackend(){
        getEmailMessagesOfAttachments();
        removeOutboundEmailsAndItsAttachments();
        getEmailParentCases();
        sendDocumentsToBackend();
    }

    @TestVisible private void getEmailMessagesOfAttachments(){
        List<Id> emails_to_retrieve_ids = new List<Id>();
        for(Attachment attachment_item : EmailAttachments){
            emails_to_retrieve_ids.add(attachment_item.ParentId);
        }
        ParentEmailsOfAttachments = new Map<Id, EmailMessage>([SELECT Id, ParentId, Incoming FROM EmailMessage WHERE Id IN :emails_to_retrieve_ids]);
    }

    @TestVisible private void removeOutboundEmailsAndItsAttachments(){
        List<Attachment> attachments_to_remove = new List<Attachment>();
        Set<Id> emails_to_remove_ids = new Set<Id>();
        for(Attachment attachment_item : EmailAttachments){
            if(isParentEmailOutbound(attachment_item)) {
                attachments_to_remove.add(attachment_item);
                emails_to_remove_ids.add(attachment_item.ParentId);
            }
        }
        removeAttachments(attachments_to_remove);
        removeEmails(emails_to_remove_ids);
    }

    private Boolean isParentEmailOutbound(Attachment attachment_record) {
        EmailMessage parent_email = ParentEmailsOfAttachments.get(attachment_record.ParentId);
        return !parent_email.Incoming;
    }

    private void removeAttachments(List<Attachment> attachments_to_remove) {
        EmailAttachments.removeAll(attachments_to_remove);
    }

    private void removeEmails(Set<Id> emails_to_remove_ids) {
        for(Id email_id : emails_to_remove_ids) {
            ParentEmailsOfAttachments.remove(email_id);
        }
    }

    @TestVisible private void getEmailParentCases(){
        List<Id> parent_cases_ids = new List<Id>();
        for(EmailMessage email_item : ParentEmailsOfAttachments.values()){
            parent_cases_ids.add(email_item.ParentId);
        }
        ParentCasesOfEmail = new Map<Id, Case>([SELECT Loan_Application__r.Loan_ID__c FROM Case WHERE Id IN :parent_cases_ids]);
    }

    @TestVisible private void sendDocumentsToBackend(){
        for(Attachment attachment_item : EmailAttachments){
            EmailMessage email_of_attachment = ParentEmailsOfAttachments.get(attachment_item.ParentId);
            if(isNumberOfFutureCallNotExceedLimit()){
                Case email_parent_case = ParentCasesOfEmail.get(email_of_attachment.ParentId);
                sendDocument(email_parent_case.Loan_Application__r.Loan_ID__c, attachment_item.Body, attachment_item.Name, attachment_item.ContentType);
            }
        }
    }

    @TestVisible private Boolean isNumberOfFutureCallNotExceedLimit(){
        return (Limits.getLimitFutureCalls() - Limits.getFutureCalls()) > 0;
    }


    @future(callout=true)
    private static void sendDocument(String loan_id, Blob body, String name, String content_type){
        ApiCommandUploadDocument upload_command = new ApiCommandUploadDocument(loan_id, body, 'unknown', name, content_type);
        ApiCommandsFactory.getInstance().performApiCommandCallout(upload_command);
    }
}