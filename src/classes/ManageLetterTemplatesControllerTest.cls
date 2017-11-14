@IsTest
public class ManageLetterTemplatesControllerTest {
    private static final String TEST_USER = 'testUserTemplates';

    static testMethod void testInitClassUnderTest(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.LazyLoadFinishedPickTemplate, 'Wrong value on create controller');
            System.assertEquals(false, setup_data.ClassUnderTest.LazyLoadFinishedTemplateBlock, 'Wrong value on create controller');
            System.assertEquals(false, setup_data.ClassUnderTest.IsEditMode, 'Wrong value on create controller');
            System.assertEquals(false, setup_data.ClassUnderTest.IsShownPreview, 'Wrong value on create controller');
        }
    }

    static testMethod void testGetAllLetterTemplatesSuccess(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setMockForResponseGetAllTemplate(true);

            Test.startTest();
                setup_data.ClassUnderTest.getAllLetterTemplates();
            Test.stopTest();

            System.assertEquals(12, setup_data.ClassUnderTest.AllTemplatesOptions.size(), 'Wrong number of select options was created');
            System.assertEquals(true, setup_data.ClassUnderTest.LazyLoadFinishedPickTemplate, 'Lazay load was not finished to spin');
        }
    }

    static testMethod void testGetAllLetterTemplatesNotSuccess(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setMockForResponseGetAllTemplate(false);

            Test.startTest();
                setup_data.ClassUnderTest.getAllLetterTemplates();
            Test.stopTest();

            System.assertEquals(true, MessageUtility.checkListContents('Internal Server Error: Internal Error',ApexPages.getMessages(), false), 'Error message was not set correct');
            System.assertEquals(true, setup_data.ClassUnderTest.LazyLoadFinishedPickTemplate, 'Lazay load was not finished to spin');
        }
    }

    static testMethod void testClickSetTemplateSuccess(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.ClassUnderTest.SelectedTemplateName = 'testTemplate';
            setup_data.setMockForResponseGetTemplate(true);

            Test.startTest();
                setup_data.ClassUnderTest.onClickSetTemplate();
            Test.stopTest();

            System.assertEquals('test', setup_data.ClassUnderTest.SelectedTemplate.Name, 'Selected template was set incorrect');
            System.assertEquals(true, setup_data.ClassUnderTest.LazyLoadFinishedTemplateBlock, 'Lazay load was not finished to spin');
        }
    }

    static testMethod void testClickSetTemplateNotSuccess(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.ClassUnderTest.SelectedTemplateName = 'testTemplate';
            setup_data.setMockForResponseGetTemplate(false);

            Test.startTest();
                setup_data.ClassUnderTest.onClickSetTemplate();
            Test.stopTest();

            System.assertEquals(true, MessageUtility.checkListContents('Internal Server Error: Internal Error',ApexPages.getMessages(), false), 'Error message was not set correct');
            System.assertEquals(true, setup_data.ClassUnderTest.LazyLoadFinishedTemplateBlock, 'Lazay load was not finished to spin');
        }
    }

    static testMethod void testOnClickSaveTemplateSuccess(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.ClassUnderTest.SelectedTemplate = setup_data.getTemplate();
            setup_data.ClassUnderTest.SelectedTemplateName = 'testTemplate';
            setup_data.setMockForResponseGetTemplate(true);

            Test.startTest();
                setup_data.ClassUnderTest.onClickSaveTemplate();
            Test.stopTest();

            System.assertEquals(true, MessageUtility.checkListContents('Template was successfuly saved!',ApexPages.getMessages(), false), 'Success message was not set correct');
            System.assertEquals(true, setup_data.ClassUnderTest.LazyLoadFinishedTemplateBlock, 'Lazay load was not finished to spin');
        }
    }

    static testMethod void testOnClickSaveTemplateNotSuccess(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.ClassUnderTest.SelectedTemplate = setup_data.getTemplate();
            setup_data.ClassUnderTest.SelectedTemplateName = 'testTemplate';
            setup_data.setMockForResponseGetTemplate(false);

            Test.startTest();
                setup_data.ClassUnderTest.onClickSaveTemplate();
            Test.stopTest();

            System.assertEquals(true, MessageUtility.checkListContents('Internal Server Error: Internal Error',ApexPages.getMessages(), false), 'Success message was not set correct');
            System.assertEquals(true, setup_data.ClassUnderTest.LazyLoadFinishedTemplateBlock, 'Lazay load was not finished to spin');
        }
    }

    static testMethod void testOnClickSaveTemplateEmptyHtml(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.ClassUnderTest.SelectedTemplateName = 'testTemplate';
            setup_data.setMockForResponseGetTemplate(true);
            setup_data.ClassUnderTest.SelectedTemplate = setup_data.getTemplate();
            setup_data.ClassUnderTest.SelectedTemplate.Html = null;

            Test.startTest();
                setup_data.ClassUnderTest.onClickSaveTemplate();
            Test.stopTest();

            System.assertEquals(true, MessageUtility.checkListContents('Template Body should not be empty!',ApexPages.getMessages(), false), 'Success message was not set correct');
        }
    }

    static testMethod void testOnClickTurnEditMode(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.onClickTurnEditMode();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsEditMode, 'Edit mode should be enable');
        }
    }

    static testMethod void testOnClickTurnViewMode(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.onClickTurnViewMode();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsEditMode, 'Edit mode should be disabled');
        }
    }
        
    static testMethod void testShowPreviewMode(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.showPreviewMode();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsShownPreview, 'Preview should be enabled');
        }
    }

    static testMethod void testHidePreviewMode(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.hidePreviewMode();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsShownPreview, 'Preview should be disabled');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public ManageLetterTemplatesController ClassUnderTest;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        public void initController() {
            ClassUnderTest = new ManageLetterTemplatesController();
        }

        public void setMockForResponseGetAllTemplate(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLetterTemplatesTestMock(is_success, ApiCommandLetterTemplatesTestMock.CommandsName.GET_ALL_LETTER_TEMPLATES));
        }

        public void setMockForResponseGetTemplate(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLetterTemplatesTestMock(is_success, ApiCommandLetterTemplatesTestMock.CommandsName.GET_LETTER_TEMPLATE));
        }

        public ApiCommandLetterTemplatesGet.LetterTemplate getTemplate(){
            ApiCommandLetterTemplatesGet.LetterTemplate template = new ApiCommandLetterTemplatesGet.LetterTemplate();
            template.Name = 'nameTest';
            template.Html = 'test';
            return template;
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName(TEST_USER)
                                     .save();
    }
}