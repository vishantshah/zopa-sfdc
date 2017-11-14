@isTest
private class ApiCommandParserDateTimeTest {

    static testMethod void testParseDateTime() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                String parsed_datetime = ApiCommandParserDateTime.parseDateTime('2016-10-04T03:13:23+02:00');
            Test.stopTest();
            System.assertEquals('04/10/2016 02:13', parsed_datetime, 'Parse datetime returned the wrong datetime');
        }
    }

    static testMethod void testParseDate() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                String parsed_date = ApiCommandParserDateTime.parseDate('2016-10-04T03:13:23');
            Test.stopTest();
            System.assertEquals('04/10/2016', parsed_date, 'Parse date returned the wrong date');
        }
    }

    static testMethod void testParseDateTimeWithoutLocalPart() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                String parsed_datetime = ApiCommandParserDateTime.parseDateTimeWithoutLocalPart('2016-10-04T00:00:00');
            Test.stopTest();
            System.assertEquals('04/10/2016 01:00', parsed_datetime, 'Parse datetime returned the wrong datetime');
        }
    }

    private class SetupDataClass {
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandParserDateTimeTest' AND LastName = 'ApiCommandParserDateTimeTest' LIMIT 1];
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('ApiCommandParserDateTimeTest')
                                     .setLastName('ApiCommandParserDateTimeTest')
                                     .save();
    }
}