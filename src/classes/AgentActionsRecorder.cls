public class AgentActionsRecorder {
    private static Map<Action, String> SubjectForAction;
    static {
        SubjectForAction = new Map<Action, String> {Action.DECLINE_LOAN => 'declined the loan application',
                                                    Action.CANCEL_LOAN => 'cancelled the loan application',
                                                    Action.MAKE_QUICK_PAY => 'made the loan application quick pay',
                                                    Action.APPROVE_LOAN_AND_WAIVE_QUICK_PAY => 'approved the loan application and waived it quick pay',
                                                    Action.MOVE_TO_UNDERWRITERS => 'moved the case to the Underwriter queue',
                                                    Action.PENDING => 'marked the case as Pending',
                                                    Action.MOVE_TO_CASE_PREP => 'moved the case to the Case-Prep queue',
                                                    Action.MOVE_TO_FRAUD => 'moved the case to the Fraud queue',
                                                    Action.TEAM_LEADER => 'approved the case and moved it to the Team Leader queue',
                                                    Action.PENDING_LOAN_CONSOLIDATION => 'approved the case and moved it to the Pending Loan Consolidation queue',
                                                    Action.UPDATE_AFFORDABILITY => 'updated the affordability details',
                                                    Action.BULK_APPROVE => 'admin approved the loan application',
                                                    Action.AUTO_CANCEL => 'has automatically auto cancelled the loan application'
        };
    }

    public enum Action {DECLINE_LOAN,
                        CANCEL_LOAN,
                        MAKE_QUICK_PAY,
                        APPROVE_LOAN_AND_WAIVE_QUICK_PAY,
                        MOVE_TO_FRAUD,
                        MOVE_TO_CASE_PREP,
                        MOVE_TO_UNDERWRITERS,
                        TEAM_LEADER,
                        PENDING,
                        UPDATE_AFFORDABILITY,
                        BULK_APPROVE,
                        AUTO_CANCEL,
                        PENDING_LOAN_CONSOLIDATION
    }

    public static AgentActionsRecorder getInstance(Action current_action) {
        if (current_action == Action.AUTO_CANCEL) {
            return new AgentActionsRecorder('System ' + SubjectForAction.get(current_action), SubjectForAction.get(current_action));
        } else {
            return new AgentActionsRecorder(UserInfo.getName() + ' ' + SubjectForAction.get(current_action), SubjectForAction.get(current_action));
        }
    }

    private Task BaseTask;
    private String FeedMessage;

    private AgentActionsRecorder(String task_message, String feed_message){
        BaseTask = TaskBuilder.getBuilder().setOwner(UserInfo.getUserId())
                                           .setStatus('Completed')
                                           .setSubType('Email')
                                           .setCompletedDateTime(Datetime.now())
                                           .setSubject(task_message)
                                           .getRecord();
        FeedMessage = feed_message;
    }

    public void record(Id loan_id) {
        if (FeatureSwitch.getSwitch('ZOPA-89').isFeatureEnabled()) {
            Id case_id = [SELECT Id FROM Case WHERE Loan_Application__c = :loan_id AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING) LIMIT 1].Id;
            insert getTasksToInsert(case_id, loan_id);
            insert getChatterPostForObject(case_id);
        }
    }

    public void record(Case case_link_to) {
        if (FeatureSwitch.getSwitch('ZOPA-89').isFeatureEnabled()) {
            insert getTasksToInsert(case_link_to.Id, case_link_to.Loan_Application__c);
            insert getChatterPostForObject(case_link_to.Id);
        }
    }

    public void record(List<Case> cases_link_to) {
        if (FeatureSwitch.getSwitch('ZOPA-89').isFeatureEnabled()) {
            List<Task> tasks_to_insert = new List<Task>();
            List<FeedItem> feed_items = new List<FeedItem>();
            for (Case case_link_to : cases_link_to) {
                tasks_to_insert.addAll(getTasksToInsert(case_link_to.Id, case_link_to.Loan_Application__c));
                feed_items.add(getChatterPostForObject(case_link_to.Id));
            }
            insert tasks_to_insert;
            insert feed_items;
        }
    }

    private List<Task> getTasksToInsert(Id case_id, Id loan_id) {
        List<Task> tasks_to_insert = new List<Task>();
        tasks_to_insert.add(getCompledTaskRelatedTo(case_id, true));
        tasks_to_insert.add(getCompledTaskRelatedTo(loan_id));
        return tasks_to_insert;
    }

    private Task getCompledTaskRelatedTo(Id related_to) {
        return TaskBuilder.getBuilder(BaseTask).cloneTask().setRelatedTo(related_to)
                                                          .getRecord();
    }

    private Task getCompledTaskRelatedTo(Id related_to, Boolean task_copy_for_case) {
        return TaskBuilder.getBuilder(BaseTask).cloneTask().setRelatedTo(related_to).setCopyForCase(task_copy_for_case)
                                                          .getRecord();
    }

    private FeedItem getChatterPostForObject(Id parent_object_id){
        FeedItem post = new FeedItem();
        post.ParentId = parent_object_id;
        post.Body = FeedMessage;
        return post;
    }

    public static void makeChatterPosts(Set<Id> objects_link_to, String feed_message) {
        List<FeedItem> feed_items = new List<FeedItem>();
        for (Id object_id_link_to : objects_link_to) {
            feed_items.add(getChatterPostForObjectWithMessage(object_id_link_to, feed_message));
        }
        insert feed_items;
    }

    private static FeedItem getChatterPostForObjectWithMessage(Id parent_object_id, String feed_message){
        FeedItem post = new FeedItem();
        post.ParentId = parent_object_id;
        post.Body = feed_message;
        return post;
    }
}