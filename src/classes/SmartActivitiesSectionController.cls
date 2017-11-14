public class SmartActivitiesSectionController {
    @TestVisible private static final List<String> BUTTONS_TO_UPDATE_STATUS = new List<String> {'Completed', 'Rejected', 'Pending'};
    @TestVisible private static final String EVENTS_QUERY_PATTERN = 'SELECT id, Subject, Task_For__c, Owner.Name, OwnerId, StartDateTime, Description FROM Event WHERE What.Id = {0} AND StartDateTime {1} TODAY ORDER BY ActivityDate DESC';
    @TestVisible private static final String TASKS_QUERY_PATTERN = 'SELECT CreatedDate, isClosed, id, Subject, CompletedDateTime__c, Task_Description__c, Status, Task_For__c, Owner.Name, OwnerId, RecordTypeId, ActivityDate, TaskSubtype, Type, Description FROM Task WHERE What.Id = {0} AND isClosed = {1} {2} ORDER BY LastModifiedDate DESC';
    public Case RelatedCase {get;
        set {
            if (RelatedCase == null && value != null) {
                RelatedCase = value;
                String soql_clause = getClauseForCurrentUserPermissions();
                QueryFututeEvents = String.format(EVENTS_QUERY_PATTERN, new String[] {'\'' + RelatedCase.Id + '\'', '>='});
                QueryPastEvents = String.format(EVENTS_QUERY_PATTERN, new String[] {'\'' + RelatedCase.Id + '\'', '<'});
                QueryOpenTasks = String.format(TASKS_QUERY_PATTERN, new String[] {'\'' + RelatedCase.Id + '\'', 'false', soql_clause});
                QueryClosedTasks = String.format(TASKS_QUERY_PATTERN, new String[] {'\'' + RelatedCase.Id + '\'', 'true', soql_clause});
                refreshAllTasks();
            }
        }
    }
    public List<ActivityWrapper> OpenTasks {get; set;}
    public List<ActivityWrapper> ClosedTasks {get; set;}
    public String MassEditStatus {get; set;}
    public MessageUtility MessageHandlerClosedTasks {get; set;}
    public MessageUtility MessageHandlerOpenTasks {get; set;}
    public String IdTaskToUndo {get; set;}
    public Task NewMUTask {get; set;}

    @TestVisible private String QueryFututeEvents;
    @TestVisible private String QueryPastEvents;
    @TestVisible private String QueryOpenTasks;
    @TestVisible private String QueryClosedTasks;

    public SmartActivitiesSectionController() {
        MessageHandlerClosedTasks = new MessageUtility();
        MessageHandlerOpenTasks = new MessageUtility();
    }

    public Boolean getIsCaseNotClosed() {
        return !CaseUtility.isManualUnderwritingCaseClosed(RelatedCase);
    }

    public List<String> getButtonsUpdatingStatus() {
        return BUTTONS_TO_UPDATE_STATUS;
    }

    public PageReference updateSelectedTasksWithSpecificStatus() {
        List<Task> tasks_to_update = new List<Task>();
        Boolean selected_any_task = false;
        for (ActivityWrapper wrapped_task : OpenTasks) {
            if (wrapped_task.IsSelected == true) {
                selected_any_task = true;
                wrapped_task.setStatus(MassEditStatus).setOwner(UserInfo.getUserId());
                if(MassEditStatus == 'Completed' || MassEditStatus == 'Rejected'){
                    wrapped_task.setDueDateAsNow();
                }
            }
            if(wrapped_task.isTask){
                tasks_to_update.add(wrapped_task.getRecord());
            }
        }
        if(selected_any_task){
            handleUpdateTasks(tasks_to_update);
        } else {
            MessageHandlerOpenTasks.showError('No tasks are selected');
        }
        return null;
    }

    public void undoneChosenTask() {
        for (ActivityWrapper wrapped_task : ClosedTasks) {
            if (wrapped_task.TaskRecord.id == IdTaskToUndo) {
                handleUpdateTasks(new List<Task> {wrapped_task.setStatus('Open').setOwner(UserInfo.getUserId()).getRecord()});
                return;
            }
        }
    }

    public Boolean getHasWorkWithTasksSectionPermissions() {
        return checkPermissionByName('Case_Work_With_Tasks_Section');
    }

    public PageReference newTask() {
        NewMUTask = new Task();
        return null;
    }

    public void saveMUTask() {
        try {
            TaskBuilder.getBuilder(NewMUTask).setRelatedTo(RelatedCase.Id).setRecordType(RecordTypeUtility.TASK_MANUAL_UNDERWRITER).save();
            refreshOpenActivities();
            hideNewTaskPopup();
            MessageHandlerOpenTasks.showConfirm('Task was successfully created');
        } catch (Exception e) {
            MessageHandlerOpenTasks.showError('Unexpected issue has occured, while creating new task. Please contact administrator');
        }
    }

    public void hideNewTaskPopup() {
        NewMUTask = null;
    }

    public List<SelectOption> getMUTaskSubjects() {
        List<SelectOption> options = new List<SelectOption>();
        for (Manual_Underwriting_Task_Subjects__c subject_setting : Manual_Underwriting_Task_Subjects__c.getall().values()) {
            options.add(new SelectOption(subject_setting.Task_Subject__c, subject_setting.Task_Subject__c));
        }
        return options;
    }

    private String getClauseForCurrentUserPermissions() {
        if (checkPermissionByName('Case_View_All_Tasks')) {
            return '';
        } else if (checkPermissionByName('Case_View_Underwriter_Tasks')) {
            return 'AND (Task_For__c = \'Case-Prep\' OR Task_For__c = \'Underwriter\' OR Task_For__c = null)';
        } else if (checkPermissionByName('Case_View_Case_Prep_Tasks')) {
            return 'AND (Task_For__c = \'Case-Prep\' OR Task_For__c = null)';
        } else {
            return 'AND (RecordTypeId != \'' + RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_REFERRAL_CODE) + '\')';
        }
    }

    private List<ActivityWrapper> getActivitiesByQuery(String query_string) {
        List<ActivityWrapper> activities = new List<ActivityWrapper>();
        for (sObject activity_to_wrap : Database.query(query_string)) {
            if (activity_to_wrap instanceof Task) {
                activities.add(new ActivityWrapper((Task)activity_to_wrap));
            } else {
                activities.add(new ActivityWrapper((Event)activity_to_wrap));
            }
        }
        return activities;
    }

    private void refreshAllTasks() {
        refreshOpenActivities();
        refreshActivityHistory();
    }

    private void refreshOpenActivities() {
        OpenTasks = getActivitiesByQuery(QueryFututeEvents);
        OpenTasks.addAll(getActivitiesByQuery(QueryOpenTasks));
    }

    private void refreshActivityHistory() {
        ClosedTasks = getActivitiesByQuery(QueryClosedTasks);
        ClosedTasks.addAll(getActivitiesByQuery(QueryPastEvents));
        refreshEmailCompletedDate();
    }

    private void refreshEmailCompletedDate(){
        if(ClosedTasks != null) {
            for (ActivityWrapper wrapped_task : ClosedTasks) {
                if (wrapped_task.TaskRecord != null && wrapped_task.TaskRecord.Subject != null && wrapped_task.TaskRecord.Subject.contains('Email') && String.isEmpty(wrapped_task.DueDate)) {
                    wrapped_task.DueDate = wrapped_task.TaskRecord.CreatedDate.format('dd/MM/yyyy HH:mm');
                }
            }
        }
    }

    private void handleUpdateTasks(List<Task> tasks_to_update) {
        tasks_to_update = updateSelectedTasksComments(tasks_to_update);
        try {
            update tasks_to_update;
            MessageHandlerOpenTasks.showConfirm('Tasks were successfully updated');
            refreshAllTasks();
        } catch (Exception e) {
            MessageHandlerOpenTasks.showError('Something goes wrong: ' + e.getMessage());
        }
    }

    private void addMessage(ApexPages.severity severity, String message) {
        ApexPages.addmessage(new ApexPages.message(severity, message));
    }

    private Boolean checkPermissionByName(String name) {
        return CustomPermissions.getInstance().isCustomPermissionAvailable(name);
    }

    public List<Task> updateSelectedTasksComments(List<Task> tasks_to_update_list){
        Map<Id, Task> tasks_to_update = new Map<Id, Task>(tasks_to_update_list);
        for(ActivityWrapper open_task : OpenTasks){
            if(open_task.IsTask && open_task.ShowComment && open_task.CanBeUndone){
                if(tasks_to_update.containsKey(open_task.TaskRecord.Id)){
                    Task task_to_update = tasks_to_update.get(open_task.TaskRecord.Id);
                    task_to_update.Description = open_task.Comment;
                    tasks_to_update.put(task_to_update.Id, task_to_update);
                }else{
                    open_task.TaskRecord.Description = open_task.Comment;
                    tasks_to_update.put(open_task.TaskRecord.Id, open_task.TaskRecord);
                }
            }
        }
        return tasks_to_update.values();
    }

    public PageReference saveCommentsOpenTasks(){
        List<Task> tasks_to_update = new List<Task>();
        for(ActivityWrapper open_task : OpenTasks){
            if(open_task.IsTask && open_task.ShowComment && open_task.CanBeUndone){
                open_task.TaskRecord.Description = open_task.Comment;
                tasks_to_update.add(open_task.TaskRecord);
            }
        }
        if(tasks_to_update.size() > 0){
            try{
                update tasks_to_update;
                MessageHandlerOpenTasks.showConfirm('Tasks were successfully updated');
            }catch(Exception e){
                MessageHandlerOpenTasks.showError('Something goes wrong: ' + e.getMessage());
            }
        }
        return null;
    }

    public PageReference saveCommentsClosedTasks(){
        List<Task> tasks_to_update = new List<Task>();
        for(ActivityWrapper closed_task : ClosedTasks){
            if(closed_task.IsTask && closed_task.ShowComment && closed_task.CanBeUndone){
                closed_task.TaskRecord.Description = closed_task.Comment;
                tasks_to_update.add(closed_task.TaskRecord);
            }
        }
        if(tasks_to_update.size() > 0){
            try{
                update tasks_to_update;
                MessageHandlerClosedTasks.showConfirm('Tasks were successfully updated');
            }catch(Exception e){
                MessageHandlerClosedTasks.showError('Something goes wrong: ' + e.getMessage());
            }
        }
        return null;
    }

    public Boolean getIsClosedTasksWithActiveComments(){
        for(ActivityWrapper closed_task : ClosedTasks){
            if(closed_task.IsTask && closed_task.ShowComment && closed_task.CanBeUndone){
                return true;
            }
        }
        return false;
    }

    public class ActivityWrapper {
        public Boolean IsSelected {get; set;}
        public Boolean IsTask {get; set;}
        public Boolean CanBeUndone {get; set;}
        public Task TaskRecord {get; set;}
        public Event EventRecord {get; set;}

        public Id Id {get; set;}
        public String Subject {get; set;}
        public String Status {get; set;}
        public String TaskFor {get; set;}
        public String DueDate {get; set;}
        public String AgentName {get; set;}
        public String Description {get; set;}
        public Boolean ShowComment {get; set;}
        public String Comment {get; set;}
        public Id OwnerId {get; set;}

        public ActivityWrapper(Task task_record) {
            this.TaskRecord = task_record;
            this.IsSelected = false;
            this.IsTask = true;
            this.CanBeUndone = TaskRecord.TaskSubtype != 'Email'
                    && TaskRecord.RecordTypeId != RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_SMS);
            this.Id = TaskRecord.Id;
            this.Subject = TaskRecord.Subject;
            this.Status = TaskRecord.Status;
            this.TaskFor = TaskRecord.Task_For__c;
            if(TaskRecord.CompletedDateTime__c != null){
                this.DueDate = TaskRecord.CompletedDateTime__c.format('dd/MM/yyyy HH:mm');
            }else{
                this.DueDate = '';
            }
            this.AgentName = TaskRecord.Owner.Name;
            this.Description = TaskRecord.Task_Description__c;
            this.Comment = TaskRecord.Description;
            this.ShowComment = (isTaskManualUnderwriterOrReferralRecordType(task_record) && CanBeUndone)
                    || TaskRecord.RecordTypeId == RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_SMS);
            this.OwnerId = task_record.OwnerId;
        }

        public ActivityWrapper(Event event_record) {
            this.EventRecord = event_record;
            this.IsTask = false;
            this.CanBeUndone = false;
            this.Id = EventRecord.Id;
            this.Subject = EventRecord.Subject;
            this.Status = '';
            this.TaskFor = EventRecord.Task_For__c;
            if(EventRecord.StartDateTime != null){
                this.DueDate = EventRecord.StartDateTime.format('dd/MM/yyyy HH:mm');
            }else{
                this.DueDate = '';
            }
            this.AgentName = EventRecord.Owner.Name;
            this.Description = EventRecord.Description;
            this.ShowComment = false;
            this.OwnerId = event_record.OwnerId;
        }

        public ActivityWrapper setStatus(String status) {
            TaskRecord.Status = status;
            return this;
        }

        public ActivityWrapper setOwner(Id owner_id) {
            TaskRecord.OwnerId = owner_id;
            return this;
        }

        public ActivityWrapper setDueDateAsNow() {
            TaskRecord.CompletedDateTime__c = DateTime.now();
            return this;
        }

        public Boolean isTaskManualUnderwriterOrReferralRecordType(Task task_record){
            Id task_record_type_id = task_record.RecordTypeId;
            Id underwriter_rt_id = RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_MANUAL_UNDERWRITER);
            Id referal_code_rt_id = RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_REFERRAL_CODE);
            return (task_record_type_id == referal_code_rt_id) || (task_record_type_id == underwriter_rt_id);
        }

        public Task getRecord() {
            return TaskRecord;
        }
    }
}