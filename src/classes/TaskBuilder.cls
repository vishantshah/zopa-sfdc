public class TaskBuilder{

    public static Builder getBuilder(){
        return new Builder();
    }

    public static Builder getBuilder(Task existing_task){
        return new Builder(existing_task);
    }

    public class Builder{
        private Task TaskRecord;

        private Builder() {
            TaskRecord = new Task();
        }

        private Builder (Task existing_task) {
            TaskRecord = existing_task;
        }

        public Builder save() {
            upsert TaskRecord;
            return this;
        }

        public Builder setRelatedTo(Id object_id) {
            TaskRecord.WhatId = object_id;
            return this;
        }

        public Builder setAssignTo(Id object_id) {
            TaskRecord.WhoId = object_id;
            return this;
        }

        public Builder setSubject(String subject) {
            TaskRecord.Subject = subject;
            return this;
        }

        public Builder setStatus(String status) {
            TaskRecord.Status = status;
            return this;
        }

        public Builder setRCCodeStatus(String status) {
            TaskRecord.RCCodeStatus__c = status;
            return this;
        }

        public Builder setType(String type) {
            TaskRecord.Type = type;
            return this;
        }

        public Builder setTaskDescription(String task_description) {
            TaskRecord.Task_description__c = task_description;
            return this;
        }

        public Builder setDueDate(Date due_date) {
            TaskRecord.ActivityDate = due_date;
            return this;
        }

        public Builder setRecordType(String record_type_name) {
            TaskRecord.RecordTypeId = RecordTypeUtility.getIdByName(record_type_name);
            return this;
        }

        public Builder setPriority(String priority) {
            TaskRecord.Priority = priority;
            return this;
        }

        public Builder setComment(String comment) {
            TaskRecord.Description = comment;
            return this;
        }

        public Builder setTaskFor(String task_for) {
            TaskRecord.Task_For__c = task_for;
            return this;
        }

        public Builder setSubtype(String task_subtype) {
            TaskRecord.TaskSubtype = task_subtype;
            return this;
        }

        public Builder setOwner(Id owner) {
            TaskRecord.OwnerId = owner;
            return this;
        }

        public Builder setCompletedDateTime(Datetime date_time){
            TaskRecord.CompletedDateTime__c = date_time;
            return this;
        }

        public Builder setReviewDueDate(Datetime date_time){
            TaskRecord.Review_Due_Date__c = date_time;
            return this;
        }

        public Builder setCaseConfigurationTask(Id case_configuration_task) {
            TaskRecord.Case_Configuration_Task__c = case_configuration_task;
            return this;
        }

        public Builder setMethod(String method) {
            TaskRecord.Method__c = method;
            return this;
        }

        public Builder setCopyForCase(Boolean is_copy) {
            TaskRecord.Copy_For_Case__c = is_copy;
            return this;
        }

        public Builder cloneTask(){
            TaskRecord = TaskRecord.clone(true, true);
            return this;
        }

        public Task getRecord() {
            return TaskRecord;
        }

        public Id getRecordId() {
            return TaskRecord.Id;
        }

        public Builder setCouldNotContactReason(String reason) {
            TaskRecord.Reason__c = reason;
            return this;
        }

        public Builder setReasonForFailDpa(String reason) {
            TaskRecord.Reason_for_failed_DPA__c = reason;
            return this;
        }

        public List<Task> getRecordList(Integer number_of_tasks) {
            List<Task> tasks_list = new List<Task>();
            for( Integer i = 0; i < number_of_tasks; i++) {
                tasks_list.add( this.TaskRecord.clone());
            }
            return tasks_list;
        }
    }
}