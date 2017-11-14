public class CaseViewExtension {
    public static final List<String> ADDITIONAL_FIELDS_TO_QUERY = new List<String>{'RecordTypeId'};
    public final Case TheCase;

    public CaseViewExtension (ApexPages.StandardController controller) {
        if(FeatureSwitch.getSwitch('ZCP-212').isFeatureEnabled()){
            if(!Test.isRunningTest()) {
                controller.addFields(ADDITIONAL_FIELDS_TO_QUERY);
            }
        }
        this.TheCase = (Case)controller.getRecord();
    }

    public PageReference doRedirect() {
        PageReference page_reference;
        if(RecordTypeUtility.getKeyById(TheCase.RecordTypeId) == RecordTypeUtility.CASE_MANUAL_UNDERWRITING) {
            page_reference = Page.CaseManualUnderwriting;
        } else if (RecordTypeUtility.getKeyById(TheCase.RecordTypeId) == RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES){
            page_reference = Page.CaseCollectionsRecoveries;
        }
        if(page_reference != null) {
            page_reference.setRedirect(true);
            page_reference.getParameters().put('id',TheCase.id);
        }
        return page_reference;
    }
}