public class CaseAssingmentCollectionsHandler {

    @InvocableMethod(label='Assign case to Collections' description='Enforce Move to Collections Case Assignment Rules.')
    public static void assignCaseToCollections(List<Id> case_ids) {
        List<Case> cases = getCases(case_ids);
        setCollectionsAssignmentRules(cases);
        updateCases(cases);
    }

    private static List<Case> getCases(List<Id> case_ids) {
        return [SELECT Id FROM Case WHERE Id IN :case_ids];
    }

    private static void setCollectionsAssignmentRules(List<Case> cases) {
        Database.DMLOptions collections_dml_options = prepareCollectionsDmlOptions();
        for (Case case_item : cases) {
            case_item.setOptions(collections_dml_options);
        }
    }

    private static Database.DMLOptions prepareCollectionsDmlOptions() {
        Database.DMLOptions collections_dml_options = new Database.DMLOptions();
        collections_dml_options.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance()
                .getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_COLLECTIONS);
        return collections_dml_options;
    }

    private static void updateCases(List<Case> cases) {
        if (!cases.isEmpty()) {
            update cases;
        }
    }
}