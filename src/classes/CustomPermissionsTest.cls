@isTest
private class CustomPermissionsTest {

    static testMethod void testIsCustomPermissionAvailableAfterCustomPermissionIsAssignedToUserReturnsTrue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean user_has_permission = CustomPermissions.getInstance().isCustomPermissionAvailable(setup_data.TEST_CUSTOM_PERMISSION);
            Test.stopTest();

            System.assertEquals(true, user_has_permission, 'The Running user should have the permission as it was specifically granted to them');
        }
    }

    static testMethod void testIsCustomPermissionAvailableAfterCustomPermissionIsNotAssignedToUserReturnsFalse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Boolean user_has_permission = CustomPermissions.getInstance().isCustomPermissionAvailable(setup_data.TEST_CUSTOM_PERMISSION);
            Test.stopTest();

            System.assertEquals(false, user_has_permission, 'The Running user should not have the permission as it was not granted to them');
        }
    }

    static testMethod void testIsCustomPermissionAvailableWithNullAttributeReturnsFalse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Boolean user_has_permission = CustomPermissions.getInstance().isCustomPermissionAvailable(null);
            Test.stopTest();

            System.assertEquals(false, user_has_permission, 'The Running user should not have the null custom permission');
        }
    }

    static testMethod void testIsCustomPermissionAvailableWithEmptyAttributeReturnsFalse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Boolean user_has_permission = CustomPermissions.getInstance().isCustomPermissionAvailable('');
            Test.stopTest();

            System.assertEquals(false, user_has_permission, 'The Running user should not have the empty custom permission');
        }
    }

    static testMethod void testIsCustomPermissionAvailableWithInvalidCustomPermissionThrowsException() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                Boolean exception_was_thrown = false;
                try {
                    CustomPermissions.getInstance().isCustomPermissionAvailable('Not_An_Actual_Custom_Permission');
                } catch (Exception e) {
                    exception_was_thrown = true;
                    System.assertEquals('Custom Permission "Not_An_Actual_Custom_Permission" is not a valid Custom Permission!', e.getMessage(),
                        'Expected CustomPermissionsException Exception with correct message but got: ' + e.getMessage());
                }
            Test.stopTest();

            System.assertEquals(true, exception_was_thrown, 'There should have been an exception thrown as an invalid Custom Permission name was used');
        }
    }

    static testMethod void testGetPermissionSetIdWithEmptyPermissionSetNameThrowsException() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean exception_was_thrown = false;
                try {
                    CustomPermissions.getInstance().getPermissionSetId('');
                } catch (Exception e) {
                    exception_was_thrown = true;
                    System.assertEquals('PermissionSet Name cannot be Blank or null ""', e.getMessage(),
                        'Expected CustomPermissionsException Exception with correct message but got: ' + e.getMessage());
                }
            Test.stopTest();

            System.assertEquals(true, exception_was_thrown, 'There should have been an exception thrown as a blank name to check was passed in');
        }
    }

    static testMethod void testGetPermissionSetIdWithNullPermissionSetNameThrowsException() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean exception_was_thrown = false;
                try {
                    CustomPermissions.getInstance().getPermissionSetId(null);
                } catch (Exception e) {
                    exception_was_thrown = true;
                    System.assertEquals('PermissionSet Name cannot be Blank or null "null"', e.getMessage(),
                        'Expected CustomPermissionsException Exception with correct message but got: ' + e.getMessage());
                }
            Test.stopTest();

            System.assertEquals(true, exception_was_thrown, 'There should have been an exception thrown as a null name to check was passed in');
        }
    }

    static testMethod void testGetPermissionSetIdWithValidPermissionSetNameReturnsCorrectly() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Id permission_set_id = CustomPermissions.getInstance().getPermissionSetId('Custom_Permissions_Set_Test');
            Test.stopTest();

            System.assertEquals(setup_data.TestPermissionSet.Id, permission_set_id, 'The PermissionSet Id returned should have been the same as the test PermissionSet Id');
        }
    }

    static testMethod void testGetPermissionSetIdWithInValidPermissionSetNameReturnsNull() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Id permission_set_id = CustomPermissions.getInstance().getPermissionSetId('Custom_Permissions_Set_Tests');
            Test.stopTest();

            System.assertEquals(null, permission_set_id, 'There should have been null returned as no PermissionSet Id exists for that Name');
        }
    }

    static testMethod void testGetCustomPermissionIdWithEmptyPermissionSetNameThrowsException() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean exception_was_thrown = false;
                try {
                    CustomPermissions.getInstance().getCustomPermissionId('');
                } catch (Exception e) {
                    exception_was_thrown = true;
                    System.assertEquals('Custom Permission Name cannot be Blank or null ""', e.getMessage(),
                        'Expected CustomPermissionsException Exception with correct message but got: ' + e.getMessage());
                }
            Test.stopTest();

            System.assertEquals(true, exception_was_thrown, 'There should have been an exception thrown as a blank name to check was passed in');
        }
    }

    static testMethod void testGetCustomPermissionIdWithNullPermissionSetNameThrowsException() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean exception_was_thrown = false;
                try {
                    CustomPermissions.getInstance().getCustomPermissionId(null);
                } catch (Exception e) {
                    exception_was_thrown = true;
                    System.assertEquals('Custom Permission Name cannot be Blank or null "null"', e.getMessage(),
                        'Expected CustomPermissionsException Exception with correct message but got: ' + e.getMessage());
                }
            Test.stopTest();

            System.assertEquals(true, exception_was_thrown, 'There should have been an exception thrown as a null name to check was passed in');
        }
    }

    static testMethod void testGetCustomPermissionIdWithValidPermissionSetNameReturnsCorrectly() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Id custom_permission_id = CustomPermissions.getInstance().getCustomPermissionId(setup_data.TEST_CUSTOM_PERMISSION);
            Test.stopTest();

            System.assertEquals(setup_data.getCustomPermissionId(), custom_permission_id, 'The Custom Permission Id returned should have been the same as the test Custom Permission Id');
        }
    }

    static testMethod void testGetCustomPermissionIdWithInValidPermissionSetNameReturnsNull() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean exception_was_thrown = false;
                try {
                    CustomPermissions.getInstance().getCustomPermissionId('Not_A_Valid_Custom_Permission');
                } catch (Exception e) {
                    exception_was_thrown = true;
                    System.assertEquals('Custom Permission "Not_A_Valid_Custom_Permission" is not a valid Custom Permission!', e.getMessage(),
                        'Expected CustomPermissionsException Exception with correct message but got: ' + e.getMessage());
                }
            Test.stopTest();

            System.assertEquals(true, exception_was_thrown, 'There should have been an exception thrown as an invalid value was passed in');
        }
    }

    static testMethod void testRemoveCustomPermissionsForUserActuallyRemovesAllPermissionsReferenced() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            CustomPermissions.getInstance().isCustomPermissionAvailable(setup_data.TEST_CUSTOM_PERMISSION);
            Set<String> custom_permissions_assigned_to_running_user_before_removal = CustomPermissions.getInstance().CustomPermissionsForUserByUserId.get(setup_data.TestUser.Id);
            Test.startTest();
                CustomPermissions.getInstance().removeCustomPermissionsForUser(setup_data.TestUser.Id);
                Set<String> custom_permissions_assigned_to_running_user_after_removal = CustomPermissions.getInstance().CustomPermissionsForUserByUserId.get(setup_data.TestUser.Id);
            Test.stopTest();

            System.assertEquals(1, custom_permissions_assigned_to_running_user_before_removal.size(),
                    'There should have one Custom Permission Assigned to the test user before the test was performed');
            System.assertEquals(null, custom_permissions_assigned_to_running_user_after_removal,
                    'There set returned should have been null as it was removed from the variable holding the data');
        }
    }

    static testMethod void testIsCustomPermissionAvailableForPermissionSetWithEmptyCustomPermissionNameReturnsFalse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean is_available = CustomPermissions.getInstance().isCustomPermissionAvailableForPermissionSet('', 'Customer_Support_PL');
            Test.stopTest();

            System.assertEquals(false, is_available, 'False should have been returned as the Custom Permission Name was blank');
        }
    }

    static testMethod void testIsCustomPermissionAvailableForPermissionSetWithNullCustomPermissionNameReturnsFalse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean is_available = CustomPermissions.getInstance().isCustomPermissionAvailableForPermissionSet(null, 'Customer_Support_PL');
            Test.stopTest();

            System.assertEquals(false, is_available, 'False should have been returned as the Custom Permission Name was null');
        }
    }

    static testMethod void testIsCustomPermissionAvailableForPermissionSetWithEmptyPermissionSetNameReturnsFalse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean is_available = CustomPermissions.getInstance().isCustomPermissionAvailableForPermissionSet(setup_data.TEST_CUSTOM_PERMISSION, '');
            Test.stopTest();

            System.assertEquals(false, is_available, 'False should have been returned as the PermissionSet Name was blank');
        }
    }

    static testMethod void testIsCustomPermissionAvailableForPermissionSetWithNullPermissionSetNameReturnsFalse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean is_available = CustomPermissions.getInstance().isCustomPermissionAvailableForPermissionSet(setup_data.TEST_CUSTOM_PERMISSION, null);
            Test.stopTest();

            System.assertEquals(false, is_available, 'False should have been returned as the PermissionSet Name was null');
        }
    }

    static testMethod void testIsCustomPermissionAvailableForPermissionSetWithValidPermissionSetNameButInvalidCustomPermissionNameThrowsException() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean exception_was_thrown = false;
                try {
                    CustomPermissions.getInstance().isCustomPermissionAvailableForPermissionSet('Not_A_Valid_Custom_Permission', 'Custom_Permissions_Set_Test');
                } catch (Exception e) {
                    exception_was_thrown = true;
                    System.assertEquals('Custom Permission "Not_A_Valid_Custom_Permission" is not a valid Custom Permission!', e.getMessage(),
                        'Expected CustomPermissionsException Exception with correct message but got: ' + e.getMessage());
                }
            Test.stopTest();

            System.assertEquals(true, exception_was_thrown, 'There should have been an exception thrown as an invalid Custom Permission Name passed in');
        }
    }

    static testMethod void testIsCustomPermissionAvailableForPermissionSetWithAllValidNamesButCustomPermissionNotAssociatedReturnsFalse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithNoAssignedCustomPermissions();
            Test.startTest();
                Boolean is_available = CustomPermissions.getInstance().isCustomPermissionAvailableForPermissionSet(setup_data.TEST_CUSTOM_PERMISSION, 'Custom_Permissions_Set_Test');
            Test.stopTest();

            System.assertEquals(false, is_available, 'False should have been returned as the Custom Permission Is NOT Associated to the Permission Set');
        }
    }

    static testMethod void testIsCustomPermissionAvailableForPermissionSetWithAllNamesFilledButInvalidPermissionSetNameReturnsFalse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithNoAssignedCustomPermissions();
            Test.startTest();
                Boolean is_available = CustomPermissions.getInstance().isCustomPermissionAvailableForPermissionSet(setup_data.TEST_CUSTOM_PERMISSION, 'Not_A_Valid_Permission_Set_Name');
            Test.stopTest();

            System.assertEquals(false, is_available, 'False should have been returned as an invalid PermissionSet Name was passed in');
        }
    }

    static testMethod void testIsCustomPermissionAvailableForPermissionSetWithAllValidNamesAndCustomPersissionAssociatedReturnsTrue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                Boolean is_available = CustomPermissions.getInstance().isCustomPermissionAvailableForPermissionSet(setup_data.TEST_CUSTOM_PERMISSION, 'Custom_Permissions_Set_Test');
            Test.stopTest();

            System.assertEquals(true, is_available, 'True should have been returned as the Custom Permission Is Associated to the Permission Set');
        }
    }

    static testMethod void testGetListOfUsersForCustomPermission() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createPermissionSetWithCustomPermissionAndAsisgnToTestUser();
            Test.startTest();
                List<User> user_list = CustomPermissions.getInstance().getListOfUsersForCustomPermission(setup_data.TEST_CUSTOM_PERMISSION);
            Test.stopTest();

            Integer count_of_users=0;
            for (User single_user : user_list) {
                if (single_user.Email.contains('testuser')) {
                    count_of_users++;
                }
            }
            System.assertEquals(1, count_of_users, 'The running user should be in list of users with input custom permission');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public final String TEST_CUSTOM_PERMISSION;
        public PermissionSet TestPermissionSet;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE LastName = 'CustomPermissionsTest' LIMIT 1];
            TEST_CUSTOM_PERMISSION = 'Case_Edit';
        }

        public void createPermissionSetWithCustomPermissionAndAsisgnToTestUser() {
            TestPermissionSet = new PermissionSet();
            TestPermissionSet.Name = 'Custom_Permissions_Set_Test';
            TestPermissionSet.Label = 'Custom Permissions Test';
            insert TestPermissionSet;

            SetupEntityAccess setup_entity_access = new SetupEntityAccess();
            setup_entity_access.ParentId = TestPermissionSet.Id;
            setup_entity_access.SetupEntityId = [SELECT Id FROM CustomPermission WHERE DeveloperName = :TEST_CUSTOM_PERMISSION][0].Id;
            insert setup_entity_access;

            PermissionSetAssignment permission_set_assignment = new PermissionSetAssignment();
            permission_set_assignment.AssigneeId = TestUser.Id;
            permission_set_assignment.PermissionSetId = TestPermissionSet.Id;
            insert permission_set_assignment;
        }

        public void createPermissionSetWithNoAssignedCustomPermissions() {
            TestPermissionSet = new PermissionSet();
            TestPermissionSet.Name = 'Custom_Permissions_Set_Test';
            TestPermissionSet.Label = 'Custom Permissions Test';
            insert TestPermissionSet;
        }

        public Id getCustomPermissionId() {
            CustomPermission test_custom_permission = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = :TEST_CUSTOM_PERMISSION LIMIT 1];
            return test_custom_permission.Id;
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.STANDARD_USER)
                                     .setLastName('CustomPermissionsTest')
                                     .save();
    }
}