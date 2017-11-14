public with sharing class EmailToCaseSectionController {
    public List<EmailMessageWrapper> CasesEmailMessages {get; set;}
    public String CurrentCaseId {get;
        set{
            if (CurrentCaseId == null) {
                CurrentCaseId = value;
                queryTasksAndEmails();
            }
        }
    }

    private List<Task> ListTasksForCurrentCaseWithEmailSubject;
    private List<EmailMessage> ListEmailMessagesForCurrentCase;

    @TestVisible
    private void queryTasksAndEmails(){
        ListTasksForCurrentCaseWithEmailSubject = [SELECT What.Name, Id, Subject, ActivityDate, TaskSubtype, CreatedDate, Description FROM Task WHERE What.Id = :CurrentCaseId AND Subject LIKE 'Email%' AND WhoId = null ORDER BY LastModifiedDate DESC];
        ListEmailMessagesForCurrentCase = [SELECT Id, Status, Incoming, MessageDate, Subject, FromName, FromAddress, ToAddress, HasAttachment FROM EmailMessage WHERE ParentId = :CurrentCaseId ORDER BY MessageDate DESC];
        refreshAllTasks();
    }

    private void refreshAllTasks() {
        CasesEmailMessages = getEmailMessageWrapper();
        CasesEmailMessages.sort();
    }

    private List<EmailMessageWrapper> getEmailMessageWrapper() {
        List<EmailMessageWrapper> email_messages_wrapper = new List<EmailMessageWrapper>();
        if(ListTasksForCurrentCaseWithEmailSubject != null){
            for(Task task_to_wrap : ListTasksForCurrentCaseWithEmailSubject){
                email_messages_wrapper.add(new EmailMessageWrapper(task_to_wrap));
            }
        }
        if(ListEmailMessagesForCurrentCase != null){
            for(EmailMessage massege_to_wrap : ListEmailMessagesForCurrentCase){
                email_messages_wrapper.add(new EmailMessageWrapper(massege_to_wrap));
            }
        }
        return email_messages_wrapper;
    }

    public class EmailMessageWrapper implements Comparable{
        public Map<String, String> StatusPicklistValuesMap = getValueStatusPicklist();
        public Boolean IsTask {get; set;}
        public Task TaskRecord {get; set;}
        public EmailMessage EmailMessageRecord {get; set;}
        public Id Id {get; set;}
        public String Status {get; set;}
        public Boolean Incoming {get; set;}
        public String Subject {get; set;}
        public String ToAddress {get; set;}
        public String MessageDate {get; set;}
        public Boolean HasAttachment {get; set;}
        public DateTime DateForCompare {get; set;}

        public EmailMessageWrapper(Task task_record) {
            this.TaskRecord = task_record;
            this.IsTask = true;
            this.Id = TaskRecord.Id;
            this.Status = 'Sent';
            this.Incoming = false;
            this.Subject = TaskRecord.Subject;
            this.ToAddress = getEmailAddressFromTaskDescription(task_record);
            this.HasAttachment = false;
            this.DateForCompare = TaskRecord.CreatedDate;
            this.MessageDate = TaskRecord.CreatedDate.format('dd/MM/yyyy HH:mm');
        }

        public EmailMessageWrapper(EmailMessage email_message_record) {
            this.EmailMessageRecord = email_message_record;
            this.IsTask = false;
            this.Id = EmailMessageRecord.Id;
            this.Status = StatusPicklistValuesMap.get(EmailMessageRecord.Status);
            this.Incoming = EmailMessageRecord.Incoming;
            this.Subject = EmailMessageRecord.Subject;
            this.ToAddress = EmailMessageRecord.ToAddress;
            this.HasAttachment = EmailMessageRecord.HasAttachment;
            this.DateForCompare = EmailMessageRecord.MessageDate;
            if(EmailMessageRecord.MessageDate != null){
                this.MessageDate = EmailMessageRecord.MessageDate.format();
            }else{
                this.MessageDate = '';
            }
        }

        private Map<String, String> getValueStatusPicklist(){
            Map<String, String> map_picklist_values_to_return = new Map<String, String>();
            Schema.DescribeFieldResult status_picklist_values = EmailMessage.Status.getDescribe();
            List<Schema.PicklistEntry> starus_picklist_entry_list = status_picklist_values.getPicklistValues();
            for(Schema.PicklistEntry starus_picklist_entry : starus_picklist_entry_list){
                 map_picklist_values_to_return.put(starus_picklist_entry.getValue(), starus_picklist_entry.getLabel());
            }
            return map_picklist_values_to_return;
        }

        private String getEmailAddressFromTaskDescription(Task task_record){
            String task_record_email = '';
            if(task_record.Description == null){
                return task_record_email;
            }

            List<String> first_row_comments = task_record.Description.split('\n')[0].split(':');

            if(first_row_comments.size() > 1){
                task_record_email = first_row_comments[1];
            }
            return task_record_email.trim();
        }

        public Integer compareTo(Object compare_to) {
            EmailMessageWrapper compare_to_oppy = (EmailMessageWrapper)compare_to;
            Integer return_value = 0;
            if (DateForCompare < compare_to_oppy.DateForCompare) {
                return_value = 1;
            } else if (DateForCompare > compare_to_oppy.DateForCompare) {
                return_value = -1;
            }
            return return_value;
        }
    }
}