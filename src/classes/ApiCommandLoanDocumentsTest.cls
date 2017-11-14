@IsTest
public class ApiCommandLoanDocumentsTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.DOCUMENT_LOAN_COMMAND, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            System.assertEquals('', body, 'Body should be empty in GET request');
        }
    }

    static testMethod void testSetLoanDocumentsResponseGreen() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                ApiCommandLoanDocuments.LoanDocumentsResponse test_response = new ApiCommandLoanDocuments.LoanDocumentsResponse();
                test_response.Id = 'Id';
                test_response.FileName = 'test';
                test_response.UploadTime = '2016-10-19T18:49:00.000+01:00';
                test_response.TamperData = 'test';
                test_response.TamperTrafficLightScore = 'green';
                test_response.DocumentType = 'some_type';
                test_response.TamperDetailsUrl = 'some_type';
                test_response.DocumentUrl = 'some_type';
            Test.stopTest();
            System.assertEquals('Id', test_response.Id, 'Property was setted incorrect');
            System.assertEquals('test', test_response.FileName, 'Property was setted incorrect');
            System.assertEquals('19/10/2016 18:49', test_response.UploadTime, 'Property was setted incorrect');
            System.assertEquals('test', test_response.TamperData, 'Property was setted incorrect');
            System.assertEquals('/img/msg_icons/confirm16.png', test_response.TamperTrafficLightScore, 'Property was setted incorrect');
            System.assertEquals('some_type', test_response.DocumentType, 'Property was setted incorrect');
            System.assertEquals('some_type', test_response.TamperDetailsUrl, 'Property was setted incorrect');
            System.assertEquals('some_type', test_response.DocumentUrl, 'Property was setted incorrect');
        }
    }

    static testMethod void testSetLoanDocumentsResponseYellow() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                ApiCommandLoanDocuments.LoanDocumentsResponse test_response = new ApiCommandLoanDocuments.LoanDocumentsResponse();
                test_response.Id = 'Id';
                test_response.FileName = 'test';
                test_response.UploadTime = '2016-10-19T18:49:00.000+01:00';
                test_response.TamperData = 'test';
                test_response.TamperTrafficLightScore = 'yellow';
                test_response.DocumentType = 'some_type';
            Test.stopTest();
            System.assertEquals('Id', test_response.Id, 'Property was setted incorrect');
            System.assertEquals('test', test_response.FileName, 'Property was setted incorrect');
            System.assertEquals('19/10/2016 18:49', test_response.UploadTime, 'Property was setted incorrect');
            System.assertEquals('test', test_response.TamperData, 'Property was setted incorrect');
            System.assertEquals('/img/msg_icons/warning16.png', test_response.TamperTrafficLightScore, 'Property was setted incorrect');
            System.assertEquals('some_type', test_response.DocumentType, 'Property was setted incorrect');
        }
    }

    static testMethod void testSetLoanDocumentsResponseRed() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                ApiCommandLoanDocuments.LoanDocumentsResponse test_response = new ApiCommandLoanDocuments.LoanDocumentsResponse();
                test_response.Id = 'Id';
                test_response.FileName = 'test';
                test_response.UploadTime = '2016-10-19T18:49:00.000+01:00';
                test_response.TamperData = 'test';
                test_response.TamperTrafficLightScore = 'red';
                test_response.DocumentType = 'some_type';
            Test.stopTest();
            System.assertEquals('Id', test_response.Id, 'Property was setted incorrect');
            System.assertEquals('test', test_response.FileName, 'Property was setted incorrect');
            System.assertEquals('19/10/2016 18:49', test_response.UploadTime, 'Property was setted incorrect');
            System.assertEquals('test', test_response.TamperData, 'Property was setted incorrect');
            System.assertEquals('/img/msg_icons/error16.png', test_response.TamperTrafficLightScore, 'Property was setted incorrect');
            System.assertEquals('some_type', test_response.DocumentType, 'Property was setted incorrect');
        }
    }

    static testMethod void testParcingDateTime() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                ApiCommandLoanDocuments.LoanDocumentsResponse test_response = new ApiCommandLoanDocuments.LoanDocumentsResponse();
                test_response.Id = 'Id';
                test_response.FileName = 'test';
                test_response.UploadTime = '2016-10-19T18:49:00.000+01:00';
                test_response.TamperData = 'test';
                test_response.TamperTrafficLightScore = 'red';
                test_response.DocumentType = 'some_type';
            Test.stopTest();

            Datetime expected = Datetime.newInstance(2016, 10, 19, 18, 49, 0);
            System.assertEquals(expected.format(), test_response.UploadTime, 'Property was setted incorrect');

        }
    }

    private class SetupDataClass {
        public ApiCommandLoanDocuments ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandLoanDocumentsTest' AND LastName = 'ApiCommandLoanDocumentsTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandLoanDocuments(UUID);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandLoanDocumentsTest')
                                     .setLastName('ApiCommandLoanDocumentsTest')
                                     .save();
    }
}