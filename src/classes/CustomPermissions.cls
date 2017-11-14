public class CustomPermissions {

    private static CustomPermissions CustomPermissionsInstance;

    private Set<String> CustomPermissionNames;
    private Map<String, Id> PermissionSetIdReferencedByName;
    @testVisible private Map<Id, Set<String>> CustomPermissionsForUserByUserId;
    private Map<Id, Set<String>> CustomPermissionsForPermissionSetById;
    private Map<Id, String> CustomPermissionNamesById;
    private Map<String, Id> CustomPermissionIdsByName;

    public static void reset() {
        CustomPermissionsInstance = null;
    }

    public static CustomPermissions getInstance() {
        if (CustomPermissionsInstance == null) {
            CustomPermissionsInstance = new CustomPermissions();
        }
        return CustomPermissionsInstance;
    }

    private CustomPermissions() {
        CustomPermissionNames = new Set<String>();
        CustomPermissionsForUserByUserId = new Map<Id, Set<String>>();
        CustomPermissionNamesById = new Map<Id, String>();
        CustomPermissionIdsByName = new Map<String, Id>();
        initialiseAllCustomPermissionsNames();
    }

    public Id getPermissionSetId(String permissionset_name) {
        if (String.isBlank(permissionset_name)) {
            throw new CustomPermissionsException('PermissionSet Name cannot be Blank or null "' + permissionset_name + '"');
        }
        return getPermissionSetIdReferencedByName().get(permissionset_name.toLowerCase().trim());
    }

    private Map<String, Id> getPermissionSetIdReferencedByName() {
        if (PermissionSetIdReferencedByName == null) {
            createPermissionSetIdReferencedByName();
        }
        return PermissionSetIdReferencedByName;
    }

    public Id getCustomPermissionId(String developer_name_of_custom_permission) {
        if (String.isBlank(developer_name_of_custom_permission)) {
            throw new CustomPermissionsException('Custom Permission Name cannot be Blank or null "' + developer_name_of_custom_permission + '"');
        }
        checkCustomPermissionExistsOrThrowException(developer_name_of_custom_permission);
        return CustomPermissionIdsByName.get(developer_name_of_custom_permission.toLowerCase().trim());
    }

    private void initialiseAllCustomPermissionsNames() {
        List<CustomPermission> all_custom_permissions =
                [SELECT Id, DeveloperName FROM CustomPermission where NamespacePrefix = null];
        for (CustomPermission each_custom_permission : all_custom_permissions) {
            CustomPermissionNames.add(each_custom_permission.DeveloperName.toLowercase().trim());
            CustomPermissionNamesById.put(each_custom_permission.Id, each_custom_permission.DeveloperName.toLowercase().trim());
            CustomPermissionIdsByName.put(each_custom_permission.DeveloperName.toLowercase().trim(), each_custom_permission.Id);
        }
    }

    public Boolean isCustomPermissionAvailable(String custom_permission_name) {
        if (String.isBlank(custom_permission_name)) {
            return false;
        }
        checkCustomPermissionExistsOrThrowException(custom_permission_name);
        Id current_user_id = UserInfo.getUserId();
        if (!CustomPermissionsForUserByUserId.keyset().contains(current_user_id)) {
            initialiseAllCustomPermissionsForUserId(current_user_id);
        }
        return CustomPermissionsForUserByUserId.get(current_user_id).contains(custom_permission_name.toLowerCase().trim());
    }

    private void checkCustomPermissionExistsOrThrowException(String developer_name_of_custom_permission) {
        String custom_permission_name_lowercase = developer_name_of_custom_permission.toLowerCase().trim();
        if(!CustomPermissionNames.contains(custom_permission_name_lowercase)) {
            throw new CustomPermissionsException('Custom Permission "' + developer_name_of_custom_permission + '" is not a valid Custom Permission!');
        }

    }
    private void initialiseAllCustomPermissionsForUserId(Id user_id) {
        Set<String> custom_permissions_for_user_id = new Set<String>();
        List<SetupEntityAccess> setup_entities =
            [SELECT SetupEntityId FROM SetupEntityAccess
                WHERE SetupEntityId in :CustomPermissionNamesById.keySet() AND
                      ParentId IN (SELECT PermissionSetId
                                    FROM PermissionSetAssignment
                                    WHERE AssigneeId = :user_id)];

        for(SetupEntityAccess each_setup_entity : setup_entities) {
            custom_permissions_for_user_id.add(CustomPermissionNamesById.get(each_setup_entity.SetupEntityId));
        }
        CustomPermissionsForUserByUserId.put(user_id, custom_permissions_for_user_id);
    }

    public Boolean isCustomPermissionAvailableForPermissionSet(String custom_permission_name, String permissionset_name) {
        if (String.isBlank(custom_permission_name) || String.isBlank(permissionset_name) ) {
            return false;
        }
        checkCustomPermissionExistsOrThrowException(custom_permission_name);
        if (! getPermissionSetIdReferencedByName().containsKey(permissionset_name.toLowerCase().trim())) {
            return false;
        }
        return isPermissionSetContainingCustomPermission(custom_permission_name.toLowercase().trim(), permissionset_name.toLowerCase().trim());
    }

    private Boolean isPermissionSetContainingCustomPermission(String custom_permission_name, String permissionset_name) {
        Boolean is_custom_permission_contianed = false;
        if (CustomPermissionsForPermissionSetById == null) {
            createCustomPermissionsForPermissionSetById();
        }
        Id permissionset_id = getPermissionSetIdReferencedByName().get(permissionset_name);
        if (CustomPermissionsForPermissionSetById.get(permissionset_id) == null ) {
            return false;
        }
        return CustomPermissionsForPermissionSetById.get(permissionset_id).contains(custom_permission_name);
    }

    private void createCustomPermissionsForPermissionSetById() {
        CustomPermissionsForPermissionSetById = new Map<Id, Set<String>>();
        List<SetupEntityAccess> all_setup_entity_access_for_permissionsets =
                [SELECT ParentId, SetupEntityId FROM SetupEntityAccess];
        for (SetupEntityAccess each_setup_entity : all_setup_entity_access_for_permissionsets) {
            if (! CustomPermissionsForPermissionSetById.containsKey(each_setup_entity.ParentId)) {
                CustomPermissionsForPermissionSetById.put(each_setup_entity.ParentId, new Set<String>());
            }
            CustomPermissionsForPermissionSetById.get(each_setup_entity.ParentId).add(CustomPermissionNamesById.get(each_setup_entity.SetupEntityId));
        }
    }

    private void createPermissionSetIdReferencedByName() {
        List<PermissionSet> all_current_permissionsets = [SELECT Id, Name FROM PermissionSet];
        PermissionSetIdReferencedByName = new Map<String, Id>();
        for (PermissionSet each_permissionset : all_current_permissionsets) {
            PermissionSetIdReferencedByName.put(each_permissionset.Name.toLowercase().trim(), each_permissionset.Id);
        }
    }

    @testVisible
    private void removeCustomPermissionsForUser(Id user_id) {
        CustomPermissionsForUserByUserId.remove(user_id);
    }

    public List<User> getListOfUsersForCustomPermission(String developer_name_of_custom_permission) {
        Set<String> permission_set_ids = new Set<String>();
        Set<String> user_id_set = new Set<String>();
        String custom_permission_id = getCustomPermissionId(developer_name_of_custom_permission);
        List<SetupEntityAccess> setup_entity_access_list = [SELECT Id, ParentId FROM SetupEntityAccess WHERE SetupEntityId=:custom_permission_id];
        for (SetupEntityAccess setup_entity_access : setup_entity_access_list) {
            permission_set_ids.add(setup_entity_access.ParentId);
        }

        List<PermissionSetAssignment> permission_set_assignment_list = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN: permission_set_ids];
        for (PermissionSetAssignment permission_set_assignment : permission_set_assignment_list) {
            user_id_set.add(permission_set_assignment.AssigneeId);
        }
        List<User> user_list = [SELECT Email, ProfileId FROM User WHERE Id IN: user_id_set];
        return user_list;
    }

    public class CustomPermissionsException extends Exception {}
}