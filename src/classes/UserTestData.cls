@isTest
public class UserTestData {
    public static Builder getUserForTest(){
        return new Builder();
    }

    public class Builder{
        private User Record;

        private Builder(){
            Record = new User();
            Record.Username = 'testuser' + Utility.getRandomString(5) + '@test.test';
            Record.Email = Record.Username;
            Record.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Application_Support_Team' LIMIT 1].Id;
            Record.Alias = Utility.getRandomString(5);
            Record.LastName = 'TestMan';
            Record.CommunityNickname = 'Comunity' + Utility.getRandomString(5);
            Record.IsActive = true;
            Record.EmailEncodingKey = 'UTF-8';
            Record.TimeZoneSidKey = 'Europe/London';
            Record.LanguageLocaleKey = 'en_US';
            Record.LocaleSidKey = 'en_IE_EURO';
        }

        public Builder setIsActive(Boolean is_user_active) {
            Record.IsActive = is_user_active;
            return this;
        }

        public Builder save(){
            insert Record;
            return this;
        }

        public Builder setFirstName(String first_name){
            Record.FirstName = first_name;
            return this;
        }

        public Builder setLastName(String last_name){
            Record.LastName = last_name;
            return this;
        }

        public Builder setAboutMe(String about_me_text){
            Record.AboutMe = about_me_text;
            return this;
        }
        public Builder setProfile(ProfileUtilities.ProfileType profile_type){
            String profile_name = ProfileUtilities.getInstance().getProfileName(profile_type);
            String profile_id = ProfileUtilities.getProfileId(profile_name);
            Record.ProfileId = profile_id;
            return this;
        }

        public Builder setContactIdAndSetRoleToNull(Id contact_id){
            Record.ContactId = contact_id;
            Record.UserRoleId = null;
            return this;
        }

        public Builder setAlias(String alias){
            Record.Alias = alias;
            return this;
        }

        public User getRecord(){
            return Record;
        }
    }
}