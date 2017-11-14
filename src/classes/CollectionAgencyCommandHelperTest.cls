@isTest
private class CollectionAgencyCommandHelperTest {
    static Integer BULK_SIZE = 5;

    static testMethod void testSendCollectionsAgencyToZopaAsynch() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            Boolean is_error = false;
            Test.startTest();
                try {
                    CollectionAgencyCommandHelper.sendCollectionsAgencyToZopaAsynch('loan_uuid','dca_uuid', System.now(), 'case_agency_id');
                } catch (Exception e){
                    is_error = true;
                }
            Test.stopTest();
            System.assertEquals(false, is_error, 'The API command must have completed successfully');
        }
    }

    static testMethod void testSendCollectionsAgencyToZopa() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            Boolean is_error = false;
            Boolean result;
            Test.startTest();
                try {
                   result = CollectionAgencyCommandHelper.sendCollectionsAgencyToZopa('loan_uuid','dca_uuid', System.now(), 'case_agency_id');
                } catch (Exception e){
                    is_error = true;
                }
            Test.stopTest();
            System.assertEquals(true, result, 'Should return true, if command ended successfully');
            System.assertEquals(false, is_error, 'The API command must have completed successfully');
        }
    }

    static testMethod void testSendCollectionsAgencyToZopaAsynchWithoutDcaId() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForGetResponse(true);
            Boolean is_error = false;
            Test.startTest();
                try {
                    CollectionAgencyCommandHelper.sendCollectionsAgencyToZopaAsynchWithoutDcaId('loan_uuid');
                } catch (Exception e){
                    is_error = true;
                }
            Test.stopTest();
            System.assertEquals(false, is_error, 'The API command must have completed successfully');
        }
    }

    static testMethod void testSendPostCollectionsAgencyToZopa() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            Boolean is_error = false;
            Test.startTest();
                try {
                    CollectionAgencyCommandHelper.sendPostCollectionsAgencyToZopa('loan_uuid','dca_uuid', System.now());
                } catch (Exception e){
                    is_error = true;
                }
            Test.stopTest();
            System.assertEquals(false, is_error, 'The API command must have completed successfully');
        }
    }

    static testMethod void testSendPostCollectionsAgencyToZopaAndReturnCommandWithCalloutSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);

            Test.startTest();
                ApiCommandPostCollectionAgency result = CollectionAgencyCommandHelper.sendPostCollectionsAgencyToZopaAndReturnCommand('loan_uuid','dca_uuid', System.now());
            Test.stopTest();

            System.assertNotEquals(null, result, 'Should return command');
            System.assertEquals(true, result.CommandSuccessful, 'Should return true because of successfull callout mock');
        }
    }

    static testMethod void testSendPostCollectionsAgencyToZopaAndReturnCommandWithCalloutFail() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(false);

            Test.startTest();
                ApiCommandPostCollectionAgency result = CollectionAgencyCommandHelper.sendPostCollectionsAgencyToZopaAndReturnCommand('loan_uuid','dca_uuid', System.now());
            Test.stopTest();

            System.assertNotEquals(null, result, 'Should return command');
            System.assertEquals(false, result.CommandSuccessful, 'Should return false because of unsuccessfull callout mock');
        }
    }

    static testMethod void testSendBulkPostsCollectionsAgencyToZopa() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            setup_data.prepareTestUuidToDateTimeMap();
            Boolean is_error = false;
            Test.startTest();
                try {
                    CollectionAgencyCommandHelper.sendBulkPostsCollectionsAgencyToZopa('dca_uuid', setup_data.TestUuidToDateTimeMap);
                } catch (Exception e){
                    is_error = true;
                }
            Test.stopTest();
            System.assertEquals(false, is_error, 'The API command must have completed successfully.');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Map<String, Datetime> TestUuidToDateTimeMap;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'CollectionAgencyCommandHelperTest' AND LastName = 'CollectionAgencyCommandHelperTest' LIMIT 1];
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public void setMockForGetResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandGetCollectionAgencyMock(is_success, 200));
        }

        public void prepareTestUuidToDateTimeMap() {
            TestUuidToDateTimeMap = new Map<String, Datetime>();
            for(Integer i = 0; i < BULK_SIZE; i++) {
                TestUuidToDateTimeMap.put('0000-0000-0000-000' + i, Datetime.now().addDays(i));
            }
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('CollectionAgencyCommandHelperTest')
                                     .setLastName('CollectionAgencyCommandHelperTest')
                                     .save();
    }
}