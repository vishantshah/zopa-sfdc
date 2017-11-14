public with sharing class CaseInitialUnderwriterPopulationHelper {
    private static CaseInitialUnderwriterPopulationHelper instance;
    @TestVisible private Map<Id, Id> OwnerIdToProfileId;

    public static CaseInitialUnderwriterPopulationHelper getInstance(Map<Id, Case> new_map) {
        if (instance == null) {
            instance = new CaseInitialUnderwriterPopulationHelper(new_map);
        }
        return instance;
    }

    private CaseInitialUnderwriterPopulationHelper(Map<Id, Case> new_map) {
        Set<Id> owners_ids = new Set<Id>();
        for (Case new_case : new_map.values()) {
            owners_ids.add(new_case.OwnerId);
        }
        OwnerIdToProfileId = new Map<Id, Id>();
        for (User owner : [SELECT Id, ProfileId FROM User WHERE Id in :owners_ids]) {
            OwnerIdToProfileId.put(owner.Id, owner.ProfileId);
        }
    }

    public void populateInitialUnderwriter(Case old_case, Case new_case){
        populateInitialUnderwriterForFirstUnderwriterOwner(old_case, new_case);
        updatePopulationDateIfInitialUnderwriterChanged(old_case, new_case);
    }


    @TestVisible private void populateInitialUnderwriterForFirstUnderwriterOwner(Case old_case, Case new_case) {
        if(new_case.Initial_Underwriter__c == null && isManualUnderwritingCase(new_case) && old_case.OwnerId != new_case.OwnerId && isPickedByUnderwriterOrFraudOrUWTeamLead(new_case.OwnerId)) {
            fillInitialUnderwriterField(new_case);
        }
    }

    @TestVisible private void updatePopulationDateIfInitialUnderwriterChanged(Case old_case, Case new_case){
        if(new_case.Initial_Underwriter__c != old_case.Initial_Underwriter__c) {
            new_case.Initial_Underwriter_Date__c = Datetime.now();
        }
    }

    @TestVisible private Boolean isManualUnderwritingCase(Case new_case) {
        return RecordTypeUtility.getKeyById(new_case.RecordTypeId) == RecordTypeUtility.CASE_MANUAL_UNDERWRITING;
    }

    @TestVisible private Boolean isPickedByUnderwriterOrFraudOrUWTeamLead(Id owner_id) {
        String profile_name = ProfileUtilities.getInstance().getProfileNameById(OwnerIdToProfileId.get(owner_id));
        return profile_name == ProfileUtilities.getInstance().getProfileName(ProfileUtilities.ProfileType.UNDERWRITER)
            || profile_name == ProfileUtilities.getInstance().getProfileName(ProfileUtilities.ProfileType.FRAUD)
            || profile_name == ProfileUtilities.getInstance().getProfileName(ProfileUtilities.ProfileType.TEAM_LEADER);
    }

    @TestVisible private void fillInitialUnderwriterField(Case new_case) {
        new_case.Initial_Underwriter__c = new_case.OwnerId;
    }
}