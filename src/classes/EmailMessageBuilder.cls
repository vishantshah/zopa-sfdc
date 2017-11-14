public class EmailMessageBuilder {

    public class Builder{
        private EmailMessage CurrentRecord;

        private Builder(Case email_case) {
            CurrentRecord = new EmailMessage();
            CurrentRecord.ParentId = email_case.Id;
        }

        private Builder(String email_case_id) {
            CurrentRecord = new EmailMessage();
            CurrentRecord.ParentId = email_case_id;
        }

        public Builder setHeaders(String header_string){
            CurrentRecord.Headers = header_string;
            return this;
        }

        public Builder setFromAddresses(String from_address){
            CurrentRecord.FromAddress = from_address;
            return this;
        }

        public Builder setToAddresses(String to_address){
            CurrentRecord.ToAddress = to_address;
            return this;
        }

        public Builder setHtmlBody(String html_body){
            CurrentRecord.HtmlBody = html_body;
            return this;
        }

        public Builder setTextBody(String text_body){
            CurrentRecord.TextBody = text_body;
            return this;
        }

        public Builder setSubject(String subject){
            CurrentRecord.Subject = subject;
            return this;
        }

        public Builder setInComming(Boolean incomming_status){
            CurrentRecord.Incoming = incomming_status;
            return this;
        }

        public Builder setStatus(String status){
            CurrentRecord.Status = status;
            return this;
        }

        public Builder setMessageDate(Datetime message_date){
            CurrentRecord.MessageDate = message_date;
            return this;
        }

        public EmailMessage getRecord(){
            return CurrentRecord;
        }

        public Builder save(){
            Upsert CurrentRecord;
            return this;
        }
    }

    public static Builder getBuilder(Case email_case){
        return new Builder(email_case);
    }

    public static Builder getBuilder(String email_case_id){
        return new Builder(email_case_id);
    }

    private EmailMessageBuilder() {}
}