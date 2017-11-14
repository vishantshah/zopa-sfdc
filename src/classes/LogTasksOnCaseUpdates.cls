public with sharing class LogTasksOnCaseUpdates {

    private static LogTasksOnCaseUpdates Instance;
    @TestVisible private Set<Case> ChangedOwnerCase;
    @TestVisible private Set<Case> ChangedStatusCase;
    private static Integer counter = 0;

    public static LogTasksOnCaseUpdates getInstance() {
        if(Instance == null){
            Instance = new LogTasksOnCaseUpdates();
        }
        return Instance;
    }

    private LogTasksOnCaseUpdates() {
        ChangedOwnerCase = new Set<Case>();
        ChangedStatusCase = new Set<Case>();
    }

    public void checkIfNeedToCreateTasks(Case old_case, Case new_case) {
        if (new_case.RecordTypeId == RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)) {
            if (caseOwnerChanged(new_case, old_case)) {
                ChangedOwnerCase.add(new_case);
            }
            if (caseStatusChanged(new_case, old_case) && counter == 0) {
                ChangedStatusCase.add(new_case);
            }
        }
    }

    private Boolean caseOwnerChanged(Case new_case, Case old_case){
        return (new_case.OwnerId != old_case.OwnerId);
    }

    private Boolean caseStatusChanged(Case new_case, Case old_case){
        return (new_case.Status != old_case.Status);
    }

    public void insertNewCaseUpdateTasks(Map<Id, SObject> old_map) {
        if(!ChangedOwnerCase.isEmpty()){
            insertOwnerChangedTasks(old_map);
        }
        if(!ChangedStatusCase.isEmpty()){
            counter++;
            insertStatusChangedTasks(old_map);
        }
    }

    private void insertOwnerChangedTasks(Map<Id, SObject> old_map){
        Map<Id,User> user_names = getUserName(old_map);
        Map<Id,Group> queue_names = getQueueName(old_map);
        List<Task> tasks_to_insert = new List<Task>();
        for(Case updated_case : ChangedOwnerCase){
            String old_owner_name;
            String new_owner_name;
            Id new_owner_id = updated_case.OwnerId;
            Id old_owner_id = ((Case)old_map.get(updated_case.Id)).OwnerId;
            if(new_owner_id != old_owner_id){
                if(String.valueOf(new_owner_id).startsWith('005')){
                    new_owner_name = user_names.get(new_owner_id).Name;
                } else {
                    new_owner_name = queue_names.get(new_owner_id).Name;
                }
                if(String.valueOf(old_owner_id).startsWith('005')){
                    old_owner_name = user_names.get(old_owner_id).Name;
                } else {
                    old_owner_name = queue_names.get(old_owner_id).Name;
                }
                String task_subject = UserInfo.getName() + ' changed the case owner from ' + old_owner_name + ' to ' + new_owner_name;
                Task changed_owner_task = TaskBuilder.getBuilder().setOwner(UserInfo.getUserId())
                                               .setStatus('Completed')
                                               .setSubType('Email')
                                               .setCompletedDateTime(Datetime.now())
                                               .setSubject(task_subject)
                                               .setRelatedTo(updated_case.Id)
                                               .getRecord();
                tasks_to_insert.add(changed_owner_task);
            }
        }
        ChangedOwnerCase = new Set<Case>();
        insert tasks_to_insert;
    }

    private Map<Id,User> getUserName(Map<Id, SObject> old_map){
        Set<Id> user_ids = new Set<Id>();
        for(Case updated_case : ChangedOwnerCase){
            Id new_owner_id = updated_case.OwnerId;
            if(String.valueOf(new_owner_id).startsWith('005')){
                user_ids.add(new_owner_id);
            }
            Id old_owner_id = ((Case)old_map.get(updated_case.Id)).OwnerId;
            if(String.valueOf(old_owner_id).startsWith('005')){
                user_ids.add(old_owner_id);
            }
        }
        return new Map<Id,User>([SELECT Name FROM User WHERE Id IN :user_ids]);
    }

    private Map<Id,Group> getQueueName(Map<Id, SObject> old_map){
        Set<Id> queue_ids = new Set<Id>();
        for(Case updated_case : ChangedOwnerCase){
            Id new_owner_id = updated_case.OwnerId;
            if(String.valueOf(new_owner_id).startsWith('00G')){
                queue_ids.add(new_owner_id);
            }
            Id old_owner_id = ((Case)old_map.get(updated_case.Id)).OwnerId;
            if(String.valueOf(old_owner_id).startsWith('00G')){
                queue_ids.add(old_owner_id);
            }
        }
        return new Map<Id,Group>([SELECT Name FROM Group WHERE Id IN :queue_ids]);
    }

    private void insertStatusChangedTasks(Map<Id, SObject> old_map){
        List<Task> tasks_to_insert = new List<Task>();
        for(Case updated_case : ChangedStatusCase){
            String old_status = ((Case)old_map.get(updated_case.Id)).Status;
            if(old_status != updated_case.Status){
                String task_subject = UserInfo.getName() + ' changed the manual underwriting case status from ' + old_status + ' to ' + updated_case.Status;
                Task changed_owner_task = TaskBuilder.getBuilder().setOwner(UserInfo.getUserId())
                                               .setStatus('Completed')
                                               .setSubType('Email')
                                               .setCompletedDateTime(Datetime.now())
                                               .setSubject(task_subject)
                                               .setRelatedTo(updated_case.Id)
                                               .getRecord();
                tasks_to_insert.add(changed_owner_task);
            }
        }
        ChangedStatusCase = new Set<Case>();
        insert tasks_to_insert;
    }
}