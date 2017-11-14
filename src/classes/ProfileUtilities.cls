public with sharing class ProfileUtilities {
    public enum ProfileType {
        STANDARD_USER,
        SYSADMIN,
        CASE_PREP,
        UNDERWRITER,
        FRAUD,
        TEAM_LEADER,
        COLLECTIONS,
        EARLY_ARREARS,
        PEXLIFY_DEV_TEST_WITH_PERMISSIONS,
        PEXLIFY_DEV_TEST_WITHOUT_PERMISSIONS
    }

    private final Map<ProfileType, String> ProfileNameMap = new Map<ProfileType, String>{
            ProfileType.STANDARD_USER => 'Standard User',
            ProfileType.SYSADMIN => 'System Administrator',
            ProfileType.TEAM_LEADER => 'UW Team Leader',
            ProfileType.UNDERWRITER => 'Underwriter',
            ProfileType.CASE_PREP => 'Case Prep',
            ProfileType.FRAUD => 'Fraud',
            ProfileType.COLLECTIONS => 'Collections agent',
            ProfileType.EARLY_ARREARS => 'Early Arrears',
            ProfileType.PEXLIFY_DEV_TEST_WITH_PERMISSIONS => 'Pexlify Dev Test - With Permissions',
            ProfileType.PEXLIFY_DEV_TEST_WITHOUT_PERMISSIONS => 'Pexlify Dev Test - Without Permissions'
    };

    private final List<ProfileUtilities.ProfileType> AdminProfiles = new List<ProfileUtilities.ProfileType>{
            ProfileUtilities.ProfileType.SYSADMIN
    };

    private Map<String,Id> MapProfileIds;
    private Map<Id,String> MapUserTypes;

    private static ProfileUtilities InstanceOfProfileUtilities = null;
    private static Map<String,String> MapProfileIds;

    static {
        if(MapProfileIds == null){
            MapProfileIds = new Map<String,String>();
            for (Profile user_profile : [Select id, Name, UserType from Profile]){
                MapProfileIds.put(user_profile.Name, user_profile.Id);
            }
        }
    }

    private ProfileUtilities() {
        String profile_name;
        String user_type;
        Id profile_id;

        this.MapProfileIds = new Map<String,Id>();
        this.MapUserTypes = new Map<Id,String>();
        for (Profile user_profile : [Select id, Name, UserType from Profile]){
            this.MapProfileIds.put(user_profile.Name, user_profile.Id);
            this.MapUserTypes.put(user_profile.Id, user_profile.UserType);
        }
    }

    public Boolean isCurrentUserProfileOfType(List<ProfileType> profiles_to_check) {
        Boolean profiles_match = false;
        Id current_user_profile_id = UserInfo.getProfileId();
        for (ProfileType p : profiles_to_check) {
            String profile_name = ProfileNameMap.get(p);
            Id profile_id = getProfileIdForName(profile_name);
            if (profile_id == current_user_profile_id) {
                profiles_match = true;
            }
        }
        return profiles_match;
    }

    public Boolean isCurrentUserProfileOfType(ProfileType profile_to_check) {
        String profile_name = ProfileNameMap.get(profile_to_check);
        return getProfileIdForName(profile_name) == UserInfo.getProfileId();
    }

    public Boolean isCurrentUserAdmin(){
        return isCurrentUserProfileOfType(AdminProfiles);
    }

    public Id getProfileIdForName(String profile_name){
        if(MapProfileIds.containsKey(profile_name))
            return MapProfileIds.get(profile_name);
        return null;
    }

    public Id getProfileIdForType(ProfileType profile_type){
        if(MapProfileIds.containsKey(ProfileNameMap.get(profile_type)))
            return MapProfileIds.get(ProfileNameMap.get(profile_type));
        return null;
    }

    public String getProfileName(ProfileType profile_type) {
        return ProfileNameMap.get(profile_type);
    }

    public String getUserType(Id profile_id) {
        return MapUserTypes.get(profile_id);
    }

    public String getProfileNameById(Id profile_id) {
        return Utility.reverseTwoStringMap(MapProfileIds).get(profile_id);
    }

    public static ProfileUtilities getInstance() {
        if(InstanceOfProfileUtilities == null) InstanceOfProfileUtilities = new ProfileUtilities();
        return InstanceOfProfileUtilities;
    }

    public static string getProfileId(String profile_name){
        if(MapProfileIds.containsKey(profile_name))
            return MapProfileIds.get(profile_name);
        return null;
    }
}