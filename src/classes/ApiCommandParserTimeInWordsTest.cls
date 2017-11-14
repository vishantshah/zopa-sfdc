@isTest
private class ApiCommandParserTimeInWordsTest {

    static testMethod void testGetTimeInTextFullYears() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                String time_in_words = ApiCommandParserTimeInWords.getTimeInText(36);
            Test.stopTest();
            System.assertEquals('3 Years', time_in_words, 'Got the wrong time in words');
        }
    }

    static testMethod void testGetTimeInTextNotFullYears() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                String time_in_words = ApiCommandParserTimeInWords.getTimeInText(30);
            Test.stopTest();
            System.assertEquals('2 Years, 6 Months', time_in_words, 'Got the wrong time in words');
        }
    }

    static testMethod void testGetTimeInTextLessThan2Years() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                String time_in_words = ApiCommandParserTimeInWords.getTimeInText(22);
            Test.stopTest();
            System.assertEquals('1 Year, 10 Months', time_in_words, 'Got the wrong time in words');
        }
    }

    static testMethod void testGetTimeInText1Year() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                String time_in_words = ApiCommandParserTimeInWords.getTimeInText(12);
            Test.stopTest();
            System.assertEquals('1 Year', time_in_words, 'Got the wrong time in words');
        }
    }

    static testMethod void testGetTimeInTextLessThan1Year() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                String time_in_words = ApiCommandParserTimeInWords.getTimeInText(4);
            Test.stopTest();
            System.assertEquals('4 Months', time_in_words, 'Got the wrong time in words');
        }
    }

    static testMethod void testGetTimeInTextOneMonth() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                String time_in_words = ApiCommandParserTimeInWords.getTimeInText(37);
            Test.stopTest();
            System.assertEquals('3 Years, 1 Month', time_in_words, 'Got the wrong time in words');
        }
    }

    static testMethod void testGetTimeInTextOnlyOneMonth() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                String time_in_words = ApiCommandParserTimeInWords.getTimeInText(1);
            Test.stopTest();
            System.assertEquals('1 Month', time_in_words, 'Got the wrong time in words');
        }
    }

    static testMethod void testGetTimeInTextZero() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                String time_in_words = ApiCommandParserTimeInWords.getTimeInText(0);
            Test.stopTest();
            System.assertEquals('0 Months', time_in_words, 'Got the wrong time in words');
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