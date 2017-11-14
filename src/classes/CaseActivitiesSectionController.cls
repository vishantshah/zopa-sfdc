public class CaseActivitiesSectionController {

    @TestVisible private static final List<String> BUTTONS_TO_UPDATE_STATUS = new List<String> {'Completed', 'Rejected', 'Pending'};
    @TestVisible private static final String TASKS_QUERY_PATTERN = 'SELECT isClosed, id, Subject, CompletedDateTime__c, CreatedDate, Task_Description__c, Status, Task_For__c, Owner.Name, OwnerId, RecordTypeId, ActivityDate, TaskSubtype, Description, Reason__c, Reason_for_failed_DPA__c FROM Task WHERE What.Id = {0} AND isClosed = {1} {2} ORDER BY LastModifiedDate DESC';
    public Case RelatedCase {get;
        set {
            if (RelatedCase == null && value != null) {
                RelatedCase = value;
                String soql_clause = getClauseForCurrentUserPermissions();
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
    public Task NewTask {get; set;}

    @TestVisible private String QueryOpenTasks;
    @TestVisible private String QueryClosedTasks;

    public CaseActivitiesSectionController() {
        MessageHandlerClosedTasks = new MessageUtility();
        MessageHandlerOpenTasks = new MessageUtility();
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
            tasks_to_update.add(wrapped_task.getRecord());
        }
        if(selected_any_task){
            handleUpdateTasks(tasks_to_update);
        } else {
            MessageHandlerOpenTasks.showError('No tasks are selected');
        }
        return null;
    }

    public PageReference newTask() {
        NewTask = new Task();
        return null;
    }

    public List<String> getButtonsUpdatingStatus() {
        return BUTTONS_TO_UPDATE_STATUS;
    }

    public void saveTask() {
        try {
            TaskBuilder.getBuilder(NewTask).setRelatedTo(RelatedCase.Id).setRecordType(RecordTypeUtility.TASK_COLLECTIONS_RECOVERIES).save();
            refreshOpenActivities();
            hideNewTaskPopup();
            MessageHandlerOpenTasks.showConfirm('Task was successfully created');
        } catch (Exception e) {
            MessageHandlerOpenTasks.showError('Unexpected issue has occured, while creating new task. Please contact administrator');
        }
    }

    public void undoneChosenTask() {
        for (ActivityWrapper wrapped_task : ClosedTasks) {
            if (wrapped_task.TaskRecord.id == IdTaskToUndo) {
                handleUpdateTasks(new List<Task> {wrapped_task.setStatus('Open').setOwner(UserInfo.getUserId()).getRecord()});
                return;
            }
        }
    }

    public void hideNewTaskPopup() {
        NewTask = null;
    }

    public List<SelectOption> getTaskSubjects() {
        List<SelectOption> options = new List<SelectOption>();
        for (Collections_Recoveries_Task_Subjects__c subject_setting : Collections_Recoveries_Task_Subjects__c.getall().values()) {
            options.add(new SelectOption(subject_setting.Task_Subject__c, subject_setting.Task_Subject__c));
        }
        return options;
    }

    private String getClauseForCurrentUserPermissions() {
        if (checkPermissionByName('Case_View_All_Tasks')) {
            return '';
        } else {
            return 'AND (RecordTypeId != \'' + RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_RECOVERIES) + '\')';
        }
    }

    @TestVisible
    private List<ActivityWrapper> getActivitiesByQuery(String query_string) {
        List<ActivityWrapper> activities = new List<ActivityWrapper>();
        for (sObject activity_to_wrap : Database.query(query_string)) {
            if (activity_to_wrap instanceof Task) {
                activities.add(new ActivityWrapper((Task)activity_to_wrap));
            }
        }
        return activities;
    }

    private void refreshAllTasks() {
        refreshOpenActivities();
        refreshActivityHistory();
    }

    private void refreshOpenActivities() {
        OpenTasks = getActivitiesByQuery(QueryOpenTasks);
    }

    private void refreshActivityHistory() {
        ClosedTasks = getActivitiesByQuery(QueryClosedTasks);
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
            if(open_task.IsTask && String.isNotEmpty(open_task.Comment)){
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
            if(open_task.IsTask){
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
            if(closed_task.IsTask){
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
            if(closed_task.IsTask){
                return true;
            }
        }
        return false;
    }

    public class ActivityWrapper {
        public Boolean IsSelected {get; set;}
        public Boolean IsTask {get; set;}
        public Task TaskRecord {get; set;}
        public Boolean CanBeUndone {get; set;}

        public Id Id {get; private set;}
        public String Subject {get; set;}
        public String Status {get; set;}
        public String TaskFor {get; set;}
        public String DueDate {get; set;}
        public String AgentName {get; set;}
        public String Description {get; set;}
        public String Comment {get; set;}
        public Boolean ShowComment {get; set;}
        public Id OwnerId {get; private set;}
        public String ReasonFailForDpa {get; set;}
        public String ReasonFailCouldNotContact {get; set;}

        public ActivityWrapper(Task task_record) {
            this.TaskRecord = task_record;
            this.IsSelected = false;
            this.IsTask = true;
            this.Id = TaskRecord.Id;
            this.Subject = TaskRecord.Subject;
            this.Status = TaskRecord.Status;
            this.TaskFor = TaskRecord.Task_For__c;
            this.CanBeUndone = TaskRecord.TaskSubtype != 'Email'
                    && TaskRecord.RecordTypeId != RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL)
                    && TaskRecord.RecordTypeId != RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_LETTER)
                    && TaskRecord.RecordTypeId != RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_SMS);
            if(TaskRecord.CompletedDateTime__c != null){
                this.DueDate = TaskRecord.CompletedDateTime__c.format('dd/MM/yyyy HH:mm');
            }else{
                this.DueDate = TaskRecord.CreatedDate.format('dd/MM/yyyy HH:mm');
            }
            this.AgentName = TaskRecord.Owner.Name;
            this.Description = TaskRecord.Task_Description__c;
            this.Comment = TaskRecord.Description;
            this.ShowComment = true;
            this.OwnerId = task_record.OwnerId;
            this.ReasonFailForDpa = task_record.Reason_for_failed_DPA__c;
            this.ReasonFailCouldNotContact  = task_record.Reason__c;
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

        public Task getRecord() {
            return TaskRecord;
        }
    }
}