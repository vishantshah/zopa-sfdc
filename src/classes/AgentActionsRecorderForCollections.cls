public class AgentActionsRecorderForCollections {
    @TestVisible private static final Map<Action, String> SUBJECT_FOR_ACTIONS;
    static {
        SUBJECT_FOR_ACTIONS = new Map<Action, String>{
                Action.CONFIRM_DECEASED => 'changed Loan Status to "Deceased"',
                Action.CONFIRM_COLLECTIONS => 'changed Loan Status to "Collections"',
                Action.SET_WITHDRAWN => 'changed Loan Status to "Withdrawn"',
                Action.CONFIRM_DEFAULT => 'changed Loan Status to "Default"',
                Action.CREATE_DIRECT_DEBIT => 'direct debit was created',
                Action.MISSED_PAYMENT => 'Customer has not made a payment as promised',
                Action.CREATED_REPAYMENT_ARRANGEMENT => 'created Payment Plan',
                Action.UPDATED_REPAYMENT_ARRANGEMENT => 'updated Payment Plan',
                Action.MISSED_REPAYMENT_ARRANGEMENT => 'Customer has missed a payment plan',
                Action.ASSIGN_DCA => 'assigned the loan to DCA',
                Action.RECALL_FROM_DCA => 'unassigned the loan to DCA',
                Action.ASSIGN_DMC => 'assigned Loan to DMC',
                Action.RECALL_FROM_DMC => 'unassigned Loan from DMC',
                Action.CREATE_COLLECTIONS_AND_RECOVERIES_CASE => 'created Collections & Recoveries Case manually'
        };
    }

    public enum Action {
        CONFIRM_DECEASED,
        CONFIRM_COLLECTIONS,
        SET_WITHDRAWN,
        CONFIRM_DEFAULT,
        CREATE_DIRECT_DEBIT,
        MISSED_PAYMENT,
        CREATED_REPAYMENT_ARRANGEMENT,
        UPDATED_REPAYMENT_ARRANGEMENT,
        MISSED_REPAYMENT_ARRANGEMENT,
        ASSIGN_DCA,
        RECALL_FROM_DCA,
        ASSIGN_DMC,
        RECALL_FROM_DMC,
        CREATE_COLLECTIONS_AND_RECOVERIES_CASE
    }

    public static AgentActionsRecorderForCollections getInstance(Action current_action) {
        return getInstance(current_action, '');
    }

    public static AgentActionsRecorderForCollections getInstance(Action current_action, String description) {
        return getInstance(current_action, description, '');
    }

    public static AgentActionsRecorderForCollections getInstance(Action current_action, String description, String action_target) {
        return getInstance(current_action, description, action_target, true);
    }

    public static AgentActionsRecorderForCollections getInstance(Action current_action, String description, String action_target, Boolean add_user_to_subject) {
        String action_subject = SUBJECT_FOR_ACTIONS.get(current_action);
        String task_subject = prepareTaskSubject(action_subject, add_user_to_subject);
        action_target = prepareActionTarget(action_target);
        return new AgentActionsRecorderForCollections(task_subject + action_target, action_subject + action_target, description);
    }

    private static String prepareTaskSubject(String action_subject, Boolean add_user_to_subject) {
        String task_subject = action_subject;
        if(add_user_to_subject) {
            task_subject = UserInfo.getName() + ' ' + task_subject;
        }
        return task_subject;
    }

    private static String prepareActionTarget(String action_target) {
        return String.isNotBlank(action_target) ? ' ' + action_target : '';
    }

    private List<Task> ListTaskForInsert = new List<Task>();
    private List<FeedItem> ListFeedItemForInsert = new List<FeedItem>();
    @TestVisible private Task BaseTask;
    @TestVisible private String FeedMessage;

    private AgentActionsRecorderForCollections(String task_message, String feed_message, String description) {
        BaseTask = TaskBuilder.getBuilder()
                .setOwner(UserInfo.getUserId())
                .setStatus('Completed')
                .setSubType('Email')
                .setCompletedDateTime(Datetime.now())
                .setSubject(task_message)
                .setComment(description)
                .setRecordType(RecordTypeUtility.TASK_COLLECTIONS_RECOVERIES)
                .getRecord();
        FeedMessage = feed_message;
    }

    public void record(Set<Id> loan_ids) {
        if (FeatureSwitch.getSwitch('ZCP-149').isFeatureEnabled()) {
            Set<Id> related_cases_ids = new Map<Id, Case>([
                    SELECT Id
                    FROM Case
                    WHERE Loan__c IN :loan_ids
                    AND IsClosed = false
                    AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
            ]).keySet();
            for(Id loan_id : loan_ids) {
                ListTaskForInsert.add(getCompletedTaskRelatedTo(loan_id));
                ListFeedItemForInsert.add(getChatterPostForObject(loan_id));
            }
            for(Id case_id : related_cases_ids) {
                ListTaskForInsert.add(getCompletedTaskRelatedTo(case_id));
                ListFeedItemForInsert.add(getChatterPostForObject(case_id));
            }
        }
    }

    public void record(Id loan_id) {
        record(new Set<Id> {loan_id});
    }

    public void record(Case case_link_to) {
        if (FeatureSwitch.getSwitch('ZCP-149').isFeatureEnabled() && case_link_to.RecordTypeId == RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)) {
            ListTaskForInsert.addAll(getTasksToInsert(case_link_to.Id, case_link_to.Loan__c));
            ListFeedItemForInsert.addAll(getFeedItemsToInsert(case_link_to.Id, case_link_to.Loan__c));
        }
    }

    public void insertNewTasks() {
        if (ListTaskForInsert.size() != 0) {
            insert ListTaskForInsert;
            ListTaskForInsert = new List<Task>();
        }
    }

    public void insertNewFeedItems() {
        if (ListFeedItemForInsert.size() != 0) {
            insert ListFeedItemForInsert;
            ListFeedItemForInsert = new List<FeedItem>();
        }
    }

    private List<Task> getTasksToInsert(Id case_id, Id loan_id) {
        List<Task> tasks_to_insert = new List<Task>();
        tasks_to_insert.add(getCompletedTaskRelatedTo(case_id, true));
        tasks_to_insert.add(getCompletedTaskRelatedTo(loan_id));
        return tasks_to_insert;
    }

    private Task getCompletedTaskRelatedTo(Id related_to) {
        return TaskBuilder.getBuilder(BaseTask)
                .cloneTask()
                .setRelatedTo(related_to)
                .getRecord();
    }

    private Task getCompletedTaskRelatedTo(Id related_to, Boolean task_copy_for_case) {
        return TaskBuilder.getBuilder(BaseTask)
                .cloneTask()
                .setRelatedTo(related_to)
                .setCopyForCase(task_copy_for_case)
                .getRecord();
    }

    private List<FeedItem> getFeedItemsToInsert(Id case_id, Id loan_id) {
        List<FeedItem> feed_items_to_insert = new List<FeedItem>();
        feed_items_to_insert.add(getChatterPostForObject(case_id));
        feed_items_to_insert.add(getChatterPostForObject(loan_id));
        return feed_items_to_insert;
    }

    private FeedItem getChatterPostForObject(Id parent_object_id) {
        FeedItem post = new FeedItem();
        post.ParentId = parent_object_id;
        post.Body = FeedMessage;
        return post;
    }
}