public class OmniChannelHandler {

    public static Boolean populateInitialUnderwriter(Case new_case, Id owner_profile_id) {
        if(FeatureSwitch.getSwitch('ZOPA-23').isFeatureEnabled() && new_case.Initial_Underwriter__c == null && isManualUnderwritingCase(new_case) && isPickedByUnderwriterOrFraud(owner_profile_id) ) {
            new_case.Initial_Underwriter__c = new_case.OwnerId;
            return true;
        }
        return false;
    }

    public static Boolean changeStatusToInProgress(Case new_case, Id owner_profile_id) {
        if((FeatureSwitch.getSwitch('ZOPA-16').isFeatureEnabled() && new_case.Status == 'Open' && isManualUnderwritingCase(new_case) && owner_profile_id != null) ||
        (FeatureSwitch.getSwitch('ZCP-74').isFeatureEnabled() && isCollectionsRecoveriesCase(new_case) && new_case.Status == 'New' && owner_profile_id != null)){
            new_case.Status = 'In Progress';
            return true;
        }
        return false;
    }

    @TestVisible private static Boolean isManualUnderwritingCase(Case new_case) {
        return RecordTypeUtility.getKeyById(new_case.RecordTypeId) == RecordTypeUtility.CASE_MANUAL_UNDERWRITING;
    }

    @TestVisible private static Boolean isCollectionsRecoveriesCase(Case new_case) {
        return RecordTypeUtility.getKeyById(new_case.RecordTypeId) == RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES;
    }

    @TestVisible private static Boolean isPickedByUnderwriterOrFraud(String owner_profile_id) {
        return owner_profile_id == ProfileUtilities.getInstance().getProfileIdForType(ProfileUtilities.ProfileType.UNDERWRITER) || owner_profile_id == ProfileUtilities.getInstance().getProfileIdForType(ProfileUtilities.ProfileType.FRAUD);
    }

    @TestVisible private static void fillInitialUnderwriterField(Case new_case) {
        new_case.Initial_Underwriter__c = new_case.OwnerId;
    }
}