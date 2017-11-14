public class AttachmentBuilder {
    public class Builder {
        private Attachment CurrentRecord;

        private Builder(EmailMessage parent_email){
            CurrentRecord = new Attachment();
            CurrentRecord.ParentId = parent_email.Id;
        }

        private Builder(Id parent_id){
            CurrentRecord = new Attachment();
            CurrentRecord.ParentId = parent_id;
        }

        public Builder setName(String name){
            CurrentRecord.Name = name;
            return this;
        }

        public Builder setBody(Blob body){
            CurrentRecord.Body = body;
            return this;
        }

        public Builder setContentType(String content_type){
            CurrentRecord.ContentType = content_type;
            return this;
        }

        public Builder setDescription(String description){
            CurrentRecord.Description = description;
            return this;
        }

        public Builder save(){
            upsert CurrentRecord;
            return this;
        }

        public Attachment getRecord(){
            return CurrentRecord;
        }
    }

    public static Builder getBuilder(EmailMessage message){
        return new Builder(message);
    }

    public static Builder getBuilder(String parent_id){
        return new Builder(parent_id);
    }

    private AttachmentBuilder() {}
}