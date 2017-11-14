public with sharing class AnonymousApex {
    public static void executeBeforeDeployAnonymousApex(){
        SchedulerAnonymousApex.abortAllSchedulableJobs();
    }

    public static void executeAfterDeployAnonymousApex(){
        SchedulerAnonymousApex.restoreSchedulableJobs();
        CustomSettingInitialization.createDefaultZopaDocumentTypes();
        CustomSettingInitialization.createDefaultMUTaskSubjects();
        CustomSettingInitialization.createCompanyClassOptions();
        CustomSettingInitialization.createAccountTypeOption();
        CustomSettingInitialization.createDefaultCRTaskSubjects();
        CustomSettingInitialization.createDefaultCRTaskReasons();
        CustomSettingInitialization.createSettingsForMock();
        CustomSettingInitialization.createOtherOptionsForLogACall();
        DataImportAnonymousApex.importFeatureSwitchesFromResource();
    }
}