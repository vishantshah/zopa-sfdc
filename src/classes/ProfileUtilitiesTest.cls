@isTest
private class ProfileUtilitiesTest {
    static testMethod void testGetProfileIdReturnsValidProfileId() {
        Profile test_profile = [SELECT Id, Name FROM Profile LIMIT 1];
        SetupDataClass setup = new SetupDataClass();
        Test.startTest();
            setup.setProfileId(test_profile.Name);
        Test.stopTest();
        System.assertEquals(test_profile.Id, setup.ProfileId);
    }

    static testMethod void testGetNonExistingProfileNameReturnsNull() {
        SetupDataClass setup = new SetupDataClass();
        Test.startTest();
            setup.setProfileId('Some Fake Profile ');
        Test.stopTest();
        System.assertEquals(null, setup.ProfileId);
    }

    static testMethod void testGetProfileNameSystemAdministratorReturnsCorrectsValue() {
        SetupDataClass setup = new SetupDataClass();
        String expected_profile_name = ProfileUtilities.getInstance().getProfileName(ProfileUtilities.ProfileType.SYSADMIN);
        Test.startTest();
            String actual_profile_name = setup.ClassUnderTest.getProfileName(ProfileUtilities.ProfileType.SYSADMIN);
        Test.stopTest();
        System.assertEquals(expected_profile_name, actual_profile_name, 'The profile names don\'t match');
    }

    static testMethod void testGetProfileNameStandardUserReturnsCorrectsValue() {
        SetupDataClass setup = new SetupDataClass();
        String expected_profile_name = 'Standard User';
        Test.startTest();
            String actual_profile_name = setup.ClassUnderTest.getProfileName(ProfileUtilities.ProfileType.STANDARD_USER);
        Test.stopTest();
        System.assertEquals(expected_profile_name, actual_profile_name, 'The profile names don\'t match');
    }

    static testMethod void testIsCurrentUserProfileOfTypeSysAdminMatch() {
        SetupDataClass setup = new SetupDataClass();
        List<ProfileUtilities.ProfileType> profiles_to_validate = new List<ProfileUtilities.ProfileType>{
                ProfileUtilities.ProfileType.STANDARD_USER, ProfileUtilities.ProfileType.SYSADMIN};
        Boolean is_user_sysadmin;
        setup.setRunningUser(ProfileUtilities.ProfileType.SYSADMIN);
        System.runAs(setup.RunningUser) {
            Test.startTest();
                is_user_sysadmin = setup.ClassUnderTest.isCurrentUserProfileOfType(profiles_to_validate);
            Test.stopTest();
        }
        System.assertEquals(true, is_user_sysadmin, 'The user should have been detected as a CRM Administrator');
    }

    static testMethod void testIsCurrentUserProfileOfTypeSysAdminMatchReverseOrder() {
        SetupDataClass setup = new SetupDataClass();
        List<ProfileUtilities.ProfileType> profiles_to_validate = new List<ProfileUtilities.ProfileType>{
                ProfileUtilities.ProfileType.SYSADMIN, ProfileUtilities.ProfileType.STANDARD_USER};
        Boolean is_user_sysadmin;
        setup.setRunningUser(ProfileUtilities.ProfileType.SYSADMIN);
        System.runAs(setup.RunningUser) {
            Test.startTest();
                is_user_sysadmin = setup.ClassUnderTest.isCurrentUserProfileOfType(profiles_to_validate);
            Test.stopTest();
        }
        System.assertEquals(true, is_user_sysadmin, 'The user should have been detected as a CRM Administrator');
    }


    static testMethod void testIsCurrentUserProfileOfTypeSysAdminNoMatch() {
        SetupDataClass setup = new SetupDataClass();
        List<ProfileUtilities.ProfileType> profiles_to_validate = new List<ProfileUtilities.ProfileType>{
                ProfileUtilities.ProfileType.SYSADMIN};
        Boolean is_user_sysadmin;
        setup.setRunningUser(ProfileUtilities.ProfileType.STANDARD_USER);
        System.runAs(setup.RunningUser) {
            Test.startTest();
                is_user_sysadmin = setup.ClassUnderTest.isCurrentUserProfileOfType(profiles_to_validate);
            Test.stopTest();
        }
        System.assertEquals(false, is_user_sysadmin, 'The user shouldn\'t have been detected as a CRM Administrator');
    }

    static testMethod void testIsCurrentUserProfileOfTypeStandardUserMatch() {
        SetupDataClass setup = new SetupDataClass();
        List<ProfileUtilities.ProfileType> profiles_to_validate = new List<ProfileUtilities.ProfileType>{
                ProfileUtilities.ProfileType.SYSADMIN, ProfileUtilities.ProfileType.STANDARD_USER};
        Boolean is_standard_user;
        setup.setRunningUser(ProfileUtilities.ProfileType.STANDARD_USER);
        System.runAs(setup.RunningUser) {
            Test.startTest();
                is_standard_user = setup.ClassUnderTest.isCurrentUserProfileOfType(profiles_to_validate);
            Test.stopTest();
        }
        System.assertEquals(true, is_standard_user, 'The user should have been detected as a Standard User');
    }

    static testMethod void testIsCurrentUserProfileOfTypeStandardUserNoMatch() {
        SetupDataClass setup = new SetupDataClass();
        List<ProfileUtilities.ProfileType> profiles_to_validate = new List<ProfileUtilities.ProfileType>{
                ProfileUtilities.ProfileType.STANDARD_USER};
        Boolean is_standard_user;
        setup.setRunningUser(ProfileUtilities.ProfileType.SYSADMIN);
        System.runAs(setup.RunningUser) {
            Test.startTest();
                is_standard_user = setup.ClassUnderTest.isCurrentUserProfileOfType(profiles_to_validate);
            Test.stopTest();
        }
        System.assertEquals(false, is_standard_user, 'The user shouldn\'t have been detected as a Standard User');
    }

     static testMethod void testGetProfileIdForNameReturnsValidProfileId() {
        Profile test_profile = [SELECT Id, Name FROM Profile LIMIT 1];
        SetupDataClass setup = new SetupDataClass();
        Id returned_profile_id;
        Test.startTest();
            returned_profile_id = setup.ClassUnderTest.getProfileIdForName(test_profile.Name);
        Test.stopTest();
        System.assertEquals(test_profile.Id, returned_profile_id, 'The incorrect Profile Id was returned!!!, returned Profile was meant to be '
                +test_profile.Id + ' but instead ' + returned_profile_id + ' was returned!');
    }

     static testMethod void testGetProfileIdForNameReturnsNullForInvalidProfileName() {
        String invalid_profile_name = 'S1Ystaq£"$%eam ADsm3£12traTWWEors';
        SetupDataClass setup = new SetupDataClass();
        Id returned_profile_id;
        Test.startTest();
            returned_profile_id = setup.ClassUnderTest.getProfileIdForName(invalid_profile_name);
        Test.stopTest();
        System.assertEquals(null, returned_profile_id, 'The method should have returned back null for a profile with name ' + invalid_profile_name);
    }

    static testMethod void testIsCurrentUserAdminReturnsFalseForNonAdminUser(){
        Boolean is_user_admin;
        SetupDataClass setup = new SetupDataClass();
        setup.setRunningUser(ProfileUtilities.ProfileType.STANDARD_USER);
        System.runAs(setup.RunningUser) {
            is_user_admin = setup.ClassUnderTest.isCurrentUserAdmin();
        }
        System.assertEquals(false, is_user_admin);
    }

    static testMethod void testIsCurrentUserAdminReturnsTrueForAdminUser(){
        Boolean is_user_admin;
        SetupDataClass setup = new SetupDataClass();
        setup.setRunningUser(ProfileUtilities.ProfileType.SYSADMIN);
        System.runAs(setup.RunningUser) {
            is_user_admin = setup.ClassUnderTest.isCurrentUserAdmin();
        }
        System.assertEquals(true, is_user_admin);
    }

    static testMethod void testGetUserTypeForProfileId() {
        final String STANDARD_USER_TYPE = 'Standard';

        SetupDataClass setup = new SetupDataClass();
        setup.setRunningUser(ProfileUtilities.ProfileType.SYSADMIN);
        String profile_name = ProfileUtilities.getInstance().getProfileName(ProfileUtilities.ProfileType.STANDARD_USER);
        Id profile_id = setup.getProfileIdForName(profile_name);

        System.runAs(setup.RunningUser) {
            Test.startTest();
            String user_type = ProfileUtilities.getInstance().getUserType(profile_id);
            Test.stopTest();

            System.assertEquals(STANDARD_USER_TYPE,user_type);
        }
    }

   public class SetupDataClass{
        public Id ProfileId {get; private set;}
        public User RunningUser {get; private set;}
        public ProfileUtilities ClassUnderTest {get; private set;}

        public SetupDataClass() {
            ClassUnderTest = ProfileUtilities.getInstance();
        }

        public void setProfileId(String profile_name){
            profileId = ProfileUtilities.getProfileId(profile_name);
        }

        public void setRunningUser(ProfileUtilities.ProfileType profile_type){
            RunningUser = UserTestData.getUserForTest().setProfile(profile_type).save().getRecord();
        }

        public Id getProfileIdForName(String name_of_profile) {
            List<Profile> the_profile_to_be_returned = [SELECT Id FROM Profile WHERE name = :name_of_profile];
            return the_profile_to_be_returned.get(0).Id;
        }
    }
}