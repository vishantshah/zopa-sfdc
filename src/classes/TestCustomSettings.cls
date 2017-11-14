public class TestCustomSettings {
    public Enum Type {ASSIGNMENT_RULE, ZOPA_API}

    @TestVisible private static Case_Assignment_Rules__c AssignmentRulesCS;
    @TestVisible private static Zopa_API_Security__c ZopaAPISecurityCS;

    static {
        AssignmentRulesCS = getDefaultAsignmentRuleCS();
        ZopaAPISecurityCS = getDefaultZopaAPISecurityCS();
    }

    public static void saveCustomSettings(sObject custom_settings) {
        if (Test.isRunningTest()) {
            if (custom_settings instanceof Case_Assignment_Rules__c) {
                AssignmentRulesCS = (Case_Assignment_Rules__c)custom_settings;
            } else if (custom_settings instanceof Zopa_API_Security__c){
                ZopaAPISecurityCS = (Zopa_API_Security__c)custom_settings;
            }
        } else {
            upsert custom_settings;
        }
    }

    public static Case_Assignment_Rules__c getAssignmentRulesCS() {
        if (Test.isRunningTest()) {
            return AssignmentRulesCS;
        } else {
            return Case_Assignment_Rules__c.getOrgDefaults();
        }
    }

    public static Zopa_API_Security__c getZopaAPISecurityCS() {
        if (Test.isRunningTest()) {
            return ZopaAPISecurityCS;
        } else {
            return Zopa_API_Security__c.getOrgDefaults();
        }
    }

    private static Zopa_API_Security__c getDefaultZopaAPISecurityCS() {
        return new Zopa_API_Security__c(SetupOwnerId = UserInfo.getOrganizationId(), X_Api_Key_Header__c = 'asdasdasdas');
    }

    private static Case_Assignment_Rules__c getDefaultAsignmentRuleCS() {
        return new Case_Assignment_Rules__c(
                            SetupOwnerId = UserInfo.getOrganizationId(),
                            Case_Prep__c = 'Move_To_Case_Prep',
                            Creation_Manual_Underwriting__c = 'Creation_Manual_Underwriting',
                            Fraud__c = 'Move_To_Fraud',
                            Underwriter__c = 'Move_To_Underwriter');
    }
}