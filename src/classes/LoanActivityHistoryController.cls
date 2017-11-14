public class LoanActivityHistoryController {
    public Id LoanApplicationId {get;
        set{
            if(LoanApplicationId == null && value != null){
                LoanApplicationId = value;
                LoanCases = [SELECT Id FROM Case WHERE Case.Loan_Application__r.Id =:LoanApplicationId];
                AllIdsCasesAndLoan.add(LoanApplicationId);
                AllIdsCasesAndLoan.addAll(new Map<Id,SObject>(LoanCases).keySet());
                queryTasksAndEvents();
            }
        }
    }
    public List<Case> LoanCases {get; set;}
    public List<ActivityWrapper> ClosedTasks {get; set;}
    public Integer ShowElementsInPage {get; set;}
    public Id SelectedTaskId {get; set;}
    private Set<Id> AllIdsCasesAndLoan = new Set<Id>();

    @TestVisible private List<Event> QueryCasesEvents;
    @TestVisible private List<Task> QueryCasesTasks;

    public LoanActivityHistoryController() {
        ShowElementsInPage = 5;
    }

    public void deleteTask(){
        if (SelectedTaskId == null) {
            return;
        }
        Task task_to_delete = null;
        for(ActivityWrapper wrapped_task : ClosedTasks){
            if (wrapped_task.Id == SelectedTaskId) {
                task_to_delete = wrapped_task.TaskRecord;
                break;
            }
        }
        if(task_to_delete != null) {
            delete task_to_delete;
        }
        queryTasksAndEvents();
   }

    public void showMoreElements(){
        ShowElementsInPage += 5;
    }

    public void showAllElements(){
        ShowElementsInPage = ClosedTasks.size();
    }

    public Boolean getHasWorkWithTasksSectionPermissions() {
        return checkPermissionByName('Case_Work_With_Tasks_Section');
    }

    private void queryTasksAndEvents(){
        QueryCasesTasks = [SELECT  id, Subject, Task_Description__c, Owner.Name, OwnerId, RecordTypeId, LastModifiedDate, CompletedDateTime__c, CreatedDate, ActivityDate, Who.Name FROM Task WHERE What.Id IN :AllIdsCasesAndLoan AND  Copy_For_Case__c = false AND isClosed = true ORDER BY LastModifiedDate DESC];
        QueryCasesEvents = [SELECT id, Subject, Owner.Name, OwnerId, Description, LastModifiedDate, StartDateTime, CreatedDate, ActivityDate, Who.Name FROM Event WHERE What.Id IN :AllIdsCasesAndLoan AND StartDateTime < TODAY ORDER BY ActivityDate DESC];
        refreshAllTasks();
    }

    private void refreshAllTasks() {
        ClosedTasks = getActivitiesByQuery(QueryCasesTasks, QueryCasesEvents);
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

    private List<ActivityWrapper> getActivitiesByQuery(List<Task> query_tasks, List<Event> query_events) {
        List<ActivityWrapper> activities = new List<ActivityWrapper>();
        if(query_tasks != null){
            for(Task task_to_wrap : query_tasks){
                activities.add(new ActivityWrapper(task_to_wrap));
            }
        }
        if(query_events != null){
            for(Event event_to_wrap : query_events){
                activities.add(new ActivityWrapper(event_to_wrap));
            }
        }
        return activities;
    }


    private Boolean checkPermissionByName(String name) {
        return CustomPermissions.getInstance().isCustomPermissionAvailable(name);
    }

    public class ActivityWrapper {
        public Boolean IsTask {get; set;}
        public Task TaskRecord {get; set;}
        public Event EventRecord {get; set;}

        public Id Id {get; set;}
        public String Subject {get; set;}
        public String DueDate {get; set;}
        public String LastModified {get; set;}
        public String AgentName {get; set;}
        public String Description {get; set;}
        public Id OwnerId {get; set;}
        public String Name {get; set;}

        public ActivityWrapper(Task task_record) {
            this.TaskRecord = task_record;
            this.IsTask = true;
            this.Id = TaskRecord.Id;
            this.Subject = TaskRecord.Subject;
            this.LastModified = TaskRecord.LastModifiedDate.format('dd/MM/yyyy HH:mm');
            this.AgentName = TaskRecord.Owner.Name;
            this.Description = TaskRecord.Task_Description__c;
            this.OwnerId = task_record.OwnerId;
            if(TaskRecord.Who.Name != null){
                this.Name = TaskRecord.Who.Name;
            }else{
                this.Name = '';
            }
            if(TaskRecord.ActivityDate != null){
                this.DueDate = TaskRecord.ActivityDate.format();
            }else{
                this.DueDate = '';
            }
        }

        public ActivityWrapper(Event event_record) {
            this.EventRecord = event_record;
            this.IsTask = false;
            this.Id = EventRecord.Id;
            this.Subject = EventRecord.Subject;
            this.LastModified = EventRecord.LastModifiedDate.format('dd/MM/yyyy HH:mm');
            this.AgentName = EventRecord.Owner.Name;
            this.Description = EventRecord.Description;
            this.OwnerId = event_record.OwnerId;
            if(EventRecord.Who.Name != null){
                this.Name = EventRecord.Who.Name;
            }else{
                this.Name = '';
            }
            if(EventRecord.ActivityDate != null){
                this.DueDate = EventRecord.ActivityDate.format();
            }else{
                this.DueDate = '';
            }
        }
    }
}