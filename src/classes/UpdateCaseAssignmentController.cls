public class UpdateCaseAssignmentController {
    public Case_Assignment_Rules__c OrganizationCaseAssignmentRules {get;set;}
    public final String CASES_UPDATE_STARTED = Label.Update_Case_Assignment_Update_Started;
    public final String ERROR_UPDATING_CASES = Label.Update_Case_Assignment_Error_Updating_Cases;
    public final String ASSIGNMENT_RULES_UPDATED_SUCCESSFULLY = Label.Update_Case_Assignment_Assignment_Rules_Updated_Successfully;
    public final String ERROR_UPDATING_ASSIGNMENT_RULES = Label.Update_Case_Assignment_Error_Updating_Assignment_Rules;
    @TestVisible private String ErrorString;
    @TestVisible private String SelectedAppLabel;

    public UpdateCaseAssignmentController() {
        OrganizationCaseAssignmentRules = TestCustomSettings.getAssignmentRulesCS();
        ErrorString = '';
        SelectedAppLabel = getSelectedAppLabel();
    }

    public String getSelectedAppLabel() {
        for (Schema.DescribeTabSetResult describe_tab_set : Schema.describeTabs()) {
            if (describe_tab_set.isSelected()) {
                return describe_tab_set.getLabel();
            }
        }
        return '';
    }

    public void updateAssignments() {
        try {
            BatchUpdateCaseAssignments.JobMode job_mode;
            if(getIsManualUnderwritingAppSelected()) {
                job_mode = BatchUpdateCaseAssignments.JobMode.UNDERWRITING;
            } else if(getIsCollectionsAndRecoveriesAppSelected()) {
                job_mode = BatchUpdateCaseAssignments.JobMode.COLLECTIONS;
            }
            Database.executebatch(new BatchUpdateCaseAssignments(job_mode));
            MessageUtility.addInfoPageMessage(CASES_UPDATE_STARTED);
        } catch (Exception ex) {
            MessageUtility.addErrorPageMessage(ERROR_UPDATING_CASES + ': ' + ex.getMessage());
        }
    }

    public void updateAssignmentRulesInUse() {
        try {
            if (isNewRulesExist()) {
                TestCustomSettings.saveCustomSettings(OrganizationCaseAssignmentRules);
                MessageUtility.addInfoPageMessage(ASSIGNMENT_RULES_UPDATED_SUCCESSFULLY);
            } else {
                ErrorString = ErrorString.removeEnd(', ');
                MessageUtility.addErrorPageMessage(ERROR_UPDATING_ASSIGNMENT_RULES + ': ' + ErrorString);
            }
        } catch (Exception ex) {
            MessageUtility.addErrorPageMessage(ERROR_UPDATING_ASSIGNMENT_RULES + ': ' + ex.getMessage());
        }
    }

    private Boolean isNewRulesExist() {
        ErrorString = '';
        Set<String> existing_assignment_rule_names = CaseUtility.getInstance().getExistingAssignmentRuleNames();
        for (String new_rule_name : getSetOfNewAssignmentRuleNames()) {
            if (new_rule_name != null && !existing_assignment_rule_names.contains(new_rule_name)) {
                ErrorString += new_rule_name + ', ';
            }
        }
        return ErrorString == '';
    }

    private Set<String> getSetOfNewAssignmentRuleNames() {
        return new Set<String>{
                OrganizationCaseAssignmentRules.Case_Prep__c,
                OrganizationCaseAssignmentRules.Underwriter__c,
                OrganizationCaseAssignmentRules.Fraud__c,
                OrganizationCaseAssignmentRules.Creation_Manual_Underwriting__c,
                OrganizationCaseAssignmentRules.Collections__c,
                OrganizationCaseAssignmentRules.Recoveries__c,
                OrganizationCaseAssignmentRules.Sensitive__c
        };
    }

    public Boolean getIsManualUnderwritingAppSelected() {
        return SelectedAppLabel == 'Underwriting App';
    }

    public Boolean getIsCollectionsAndRecoveriesAppSelected() {
        return SelectedAppLabel == 'Collections';
    }
}