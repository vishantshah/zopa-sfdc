public class CaseUtility {
    private static CaseUtility Self;
    public static final String CASE_PROCESS_RECOVERIES = 'Recoveries';
    public static final String CASE_PROCESS_COLLECTIONS = 'Collections';
    public static final String CASE_PROCESS_SENSITIVE_CUSTOMERS = 'Sensitive Customers';

    public enum AssignmentRuleName {
        CASE_CREATION,
        MOVE_TO_CASE_PREP,
        MOVE_TO_UNDERWRITER,
        MOVE_TO_FRAUD,
        MOVE_TO_COLLECTIONS,
        MOVE_TO_RECOVERIES,
        MOVE_TO_SENSITIVE
    }
    public enum QueueName {
        PENDING_LOAN_CONSOLIDATION,
        PENDING_CASE_PREP,
        TEAM_LEADER,
        CASE_PREP_PRIORITY,
        CASE_PREP_PRIORITY1,
        CASE_PREP_PRIORITY2,
        CASE_PREP_PRIORITY3,
        CASE_PREP_PRIORITY4,
        CASE_PREP_PRIORITY5,
        FRAUD_PRIORITY,
        FRAUD_PRIORITY1,
        FRAUD_PRIORITY2,
        FRAUD_PRIORITY3,
        FRAUD_PRIORITY4,
        FRAUD_PRIORITY5,
        UNDERWRITER_PRIORITY,
        UNDERWRITER_PRIORITY1,
        UNDERWRITER_PRIORITY2,
        UNDERWRITER_PRIORITY3,
        UNDERWRITER_PRIORITY4,
        UNDERWRITER_PRIORITY5,
        COLLECTIONS_PRIORITY_1,
        COLLECTIONS_PRIORITY_2,
        COLLECTIONS_PRIORITY_3,
        COLLECTIONS_PRIORITY_4,
        COLLECTIONS_PRIORITY_5,
        ON_HOLD,
        NEED_TO_CONTACT,
        SENSITIVE,
        LITIGATION_REVIEW,
        PRE_DEFAULT,
        READY_FOR_DEFAULT,
        RECOVERIES_PRIORITY_1,
        RECOVERIES_PRIORITY_2,
        RECOVERIES_PRIORITY_3,
        RECOVERIES_PRIORITY_4,
        RECOVERIES_PRIORITY_5,
        SENSITIVE_PRIORITY_1,
        SENSITIVE_PRIORITY_2,
        SENSITIVE_PRIORITY_3,
        SENSITIVE_PRIORITY_4,
        SENSITIVE_PRIORITY_5
    }
    public enum GroupName {
        TEST
    }

    Case_Assignment_Rules__c OrganizationCaseAssignmentRules;

    @testVisible private Map<AssignmentRuleName, String> AssignmentRuleMap;
    @testVisible private Map<QueueName, String> QueueNameMap = new Map<QueueName, String>{
            QueueName.PENDING_CASE_PREP => 'Pending_Case_Prep',
            QueueName.TEAM_LEADER => 'Team_Leader',
            QueueName.CASE_PREP_PRIORITY => 'Case_Prep_Priority',
            QueueName.CASE_PREP_PRIORITY1 => 'Case_Prep_Priority_1',
            QueueName.CASE_PREP_PRIORITY2 => 'Case_Prep_Priority_2',
            QueueName.CASE_PREP_PRIORITY3 => 'Case_Prep_Priority_3',
            QueueName.CASE_PREP_PRIORITY4 => 'Case_Prep_Priority_4',
            QueueName.CASE_PREP_PRIORITY5 => 'Case_Prep_Priority_5',
            QueueName.FRAUD_PRIORITY => 'Fraud_Priority',
            QueueName.FRAUD_PRIORITY1 => 'Fraud_Priority_1',
            QueueName.FRAUD_PRIORITY2 => 'Fraud_Priority_2',
            QueueName.FRAUD_PRIORITY3 => 'Fraud_Priority_3',
            QueueName.FRAUD_PRIORITY4 => 'Fraud_Priority_4',
            QueueName.FRAUD_PRIORITY5 => 'Fraud_Priority_5',
            QueueName.UNDERWRITER_PRIORITY => 'Underwriters_Priority',
            QueueName.UNDERWRITER_PRIORITY1 => 'Underwriters_Priority_1',
            QueueName.UNDERWRITER_PRIORITY2 => 'Underwriters_Priority_2',
            QueueName.UNDERWRITER_PRIORITY3 => 'Underwriters_Priority_3',
            QueueName.UNDERWRITER_PRIORITY4 => 'Underwriters_Priority_4',
            QueueName.UNDERWRITER_PRIORITY5 => 'Underwriters_Priority_5',
            QueueName.PENDING_LOAN_CONSOLIDATION => 'Pending_Loan_Consolidation',
            QueueName.COLLECTIONS_PRIORITY_1 => 'Collections_Priority_1',
            QueueName.COLLECTIONS_PRIORITY_2 => 'Collections_Priority_2',
            QueueName.COLLECTIONS_PRIORITY_3 => 'Collections_Priority_3',
            QueueName.COLLECTIONS_PRIORITY_4 => 'Collections_Priority_4',
            QueueName.COLLECTIONS_PRIORITY_5 => 'Collections_Priority_5',
            QueueName.ON_HOLD => 'On_Hold',
            QueueName.NEED_TO_CONTACT => 'Need_to_Contact',
            QueueName.SENSITIVE => 'SensitiveCases',
            QueueName.LITIGATION_REVIEW => 'Litigation_Review',
            QueueName.PRE_DEFAULT => 'Pre_Default',
            QueueName.READY_FOR_DEFAULT => 'Ready_for_Default',
            QueueName.RECOVERIES_PRIORITY_1 => 'Recoveries_Priority_1',
            QueueName.RECOVERIES_PRIORITY_2 => 'Recoveries_Priority_2',
            QueueName.RECOVERIES_PRIORITY_3 => 'Recoveries_Priority_3',
            QueueName.RECOVERIES_PRIORITY_4 => 'Recoveries_Priority_4',
            QueueName.RECOVERIES_PRIORITY_5 => 'Recoveries_Priority_5',
            QueueName.SENSITIVE_PRIORITY_1 => 'Sensitive_Priority_1',
            QueueName.SENSITIVE_PRIORITY_2 => 'Sensitive_Priority_2',
            QueueName.SENSITIVE_PRIORITY_3 => 'Sensitive_Priority_3',
            QueueName.SENSITIVE_PRIORITY_4 => 'Sensitive_Priority_4',
            QueueName.SENSITIVE_PRIORITY_5 => 'Sensitive_Priority_5'
    };
    @testVisible private Map<GroupName, String> GroupNameMap = new Map<GroupName, String>{
    };
    @testVisible private Map<String, Id> QueueNameToIdMap;
    @testVisible private Map<Id, String> QueueIdToNameMap;
    @testVisible private Map<String, Id> GroupNameToIdMap;
    @testVisible private Map<String, Id> AssignmentRuleNameToIdMap;

    public static CaseUtility getInstance() {
        if (Self == null) {
            Self = new CaseUtility();
        }
        return Self;
    }
    private CaseUtility() {
        OrganizationCaseAssignmentRules = TestCustomSettings.getAssignmentRulesCS();
        AssignmentRuleMap = new Map<AssignmentRuleName, String>{
                AssignmentRuleName.CASE_CREATION => OrganizationCaseAssignmentRules.Creation_Manual_Underwriting__c,
                AssignmentRuleName.MOVE_TO_CASE_PREP => OrganizationCaseAssignmentRules.Case_Prep__c,
                AssignmentRuleName.MOVE_TO_UNDERWRITER => OrganizationCaseAssignmentRules.Underwriter__c,
                AssignmentRuleName.MOVE_TO_FRAUD => OrganizationCaseAssignmentRules.Fraud__c,
                AssignmentRuleName.MOVE_TO_COLLECTIONS => OrganizationCaseAssignmentRules.Collections__c,
                AssignmentRuleName.MOVE_TO_RECOVERIES => OrganizationCaseAssignmentRules.Recoveries__c,
                AssignmentRuleName.MOVE_TO_SENSITIVE => OrganizationCaseAssignmentRules.Sensitive__c
        };
        QueueIdToNameMap = new Map<Id, String>();
        QueueNameToIdMap = new Map<String, Id>();
        GroupNameToIdMap = new Map<String, Id>();
        for (Group group_or_queue : [SELECT Id, DeveloperName, Type FROM Group WHERE Type = 'Queue' OR Type = 'Regular']) {
            if (group_or_queue.Type == 'Queue') {
                QueueNameToIdMap.put(group_or_queue.DeveloperName, group_or_queue.Id);
                QueueIdToNameMap.put(group_or_queue.Id, group_or_queue.DeveloperName);
            } else if (group_or_queue.Type == 'Regular') {
                GroupNameToIdMap.put(group_or_queue.DeveloperName, group_or_queue.Id);
            }
        }
        initAssignmentRule();
    }

    public String getQueueNameFromId(Id queue_id) {
        return QueueIdToNameMap.get(queue_id);
    }

    public Id getQueueIdFromName(QueueName queue_name) {
        return QueueNameToIdMap.get(QueueNameMap.get(queue_name));
    }

    public Set<Id> getQueueIdSetFromName(QueueName queue_name) {
        Set<Id> queue_id = new Set<Id>();
        for (String key : QueueNameToIdMap.keySet()) {
            if (key.contains(QueueNameMap.get(queue_name))) {
                queue_id.add(QueueNameToIdMap.get(key));
            }
        }
        return queue_id;
    }

    public Set<Id> getQueueIdsFromNames(List<QueueName> queue_names) {
        Set<Id> queue_ids = new Set<Id>();
        for (QueueName queue_name : queue_names) {
            queue_ids.add(getQueueIdFromName(queue_name));
        }
        return queue_ids;
    }

    public Id getGroupIdFromName(GroupName group_name) {
        return GroupNameToIdMap.get(GroupNameMap.get(group_name));
    }

    public Id getAssignmentRuleIdByName(AssignmentRuleName rule_name) {
        return AssignmentRuleNameToIdMap.get(AssignmentRuleMap.get(rule_name));
    }

    public Set<String> getExistingAssignmentRuleNames() {
        return AssignmentRuleNameToIdMap.keySet();
    }

    private void initAssignmentRule() {
        AssignmentRuleNameToIdMap = new Map<String, Id>();
        for (AssignmentRule case_rule : [SELECT Id, Name FROM AssignmentRule WHERE SobjectType = 'Case']) {
            AssignmentRuleNameToIdMap.put(case_rule.Name, case_rule.Id);
        }
    }

    public static Boolean isManualUnderwritingCaseClosed(Case case_to_check) {
        if (FeatureSwitch.getSwitch('ZOPA-17').isFeatureEnabled()) {
            return case_to_check.IsClosed && !CustomPermissions.getInstance().isCustomPermissionAvailable('Profile_Token_SysAdmin');
        } else {
            return false;
        }
    }
}