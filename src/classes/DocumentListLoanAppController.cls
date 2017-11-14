public class DocumentListLoanAppController {

    @TestVisible public List<ApiCommandLoanDocuments.LoanDocumentsResponse> DocumentsList {public get; private set;}
    public String LoanAppId {get; set;}
    public String LoanInternalId {get; set;}
    public Id MUCaseId {
        get {
            if (MUCaseId == null) {
                List<Case> mu_child_cases = [SELECT Id FROM Case WHERE Loan_Application__c = :LoanInternalId
                        AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)];
                if (mu_child_cases.size() > 0) {
                    MUCaseId = mu_child_cases.get(0).Id;
                }
            }
            return MUCaseId;
        }
        private set;
    }
    public String NewDocumentType {get; set;}
    public String DocumentIdToChangeType {get; set;}
    public String ErrorOnLoad {get; private set;}

    public DocumentListLoanAppController() {}

    public PageReference getDocumentsListFromBackEnd() {
        if (isExternalIdOfLoanCorrect(LoanAppId)) {
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(new ApiCommandLoanDocuments(LoanAppId));
            if (handleCommandResponseSuccess(response)) {
                setDocumentListResponse(response);
            }
        }
        return null;
    }

    public PageReference showPopupForclassifyDocumentAction() {
        return null;
    }

    public void classifyDocumentAction() {
        HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(new ApiCommandClassifyDocumentType(LoanAppId, DocumentIdToChangeType, NewDocumentType));
        handleCommandResponseSuccess(response);
        hidePopup();
        getDocumentsListFromBackEnd();
    }

    public void hidePopup() {
        DocumentIdToChangeType = null;
    }

    public List<SelectOption> getAvailableDocumentTypes() {
        List<SelectOption> options = new List<SelectOption>();
        for (Available_Document_Types__c doc_type : Available_Document_Types__c.getall().values()) {
            options.add(new SelectOption(doc_type.Zopa_Value__c, doc_type.Name));
        }
        return options;
    }

    public Boolean getIsZopa58IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-58').isFeatureEnabled();
    }

    @TestVisible
    private Boolean isExternalIdOfLoanCorrect(String loan_external_id) {
        if (loan_external_id == null) {
            ErrorOnLoad = 'This loan doesn\'t have an Id. Can\'t retrieve information.';
            return false;
        } else {
            return true;
        }
    }

    @TestVisible
    private Boolean handleCommandResponseSuccess(HttpResponse response) {
        try{
            if (response.getStatusCode() == 200 && response.getStatus() == 'OK') {
                return true;
            } else if (response.getStatusCode() == 403){
                ErrorOnLoad = 'Access Denied. Please ask administrator to check credentials.';
                return false;
            }else if (response.getStatusCode() == 404){
                DocumentsList = new List<ApiCommandLoanDocuments.LoanDocumentsResponse>();
                return false;
            } else {
                ErrorOnLoad = 'Bad request. ' + (String)((Map<String, Object>)JSON.deserializeUntyped(response.getBody())).get('message');
                return false;
            }
        } catch (Exception e) {
            ErrorOnLoad = 'Error on parsing response: ' + response.getBody();
            System.debug('Error on parsing response: ' + e.getMessage());
            return false;
        }
    }

    @TestVisible
    private Boolean setDocumentListResponse(HttpResponse response) {
        try{
            DocumentsList = (List<ApiCommandLoanDocuments.LoanDocumentsResponse>)JSON.deserializeStrict(removeTamperDataFromResponce(response.getBody()), List<ApiCommandLoanDocuments.LoanDocumentsResponse>.class);
            if (DocumentsList == null) {
                DocumentsList = new List<ApiCommandLoanDocuments.LoanDocumentsResponse>();
            }
            List<Available_Document_Types__c> document_type_settings = Available_Document_Types__c.getall().values();
            for(ApiCommandLoanDocuments.LoanDocumentsResponse document : DocumentsList){
                for(Available_Document_Types__c document_type_setting : document_type_settings){
                    if(document.DocumentType == document_type_setting.Zopa_Value__c){
                        document.DocumentType = document_type_setting.Name;
                    }
                }
            }
            return true;
        } catch (Exception e) {
            ErrorOnLoad = 'Error on parsing response: ' + response.getBody();
            System.debug('Error on parsing response: ' + e.getMessage());
            return false;
        }
    }

    @TestVisible
    private String removeTamperDataFromResponce(String response_body){
        List<String> response_body_splited = response_body.split('"tamperData":');
        for(Integer i = 1; i < response_body_splited.size(); ++i){
            String after_temper_part = response_body_splited[i].split(',"documentType":')[1];
            response_body_splited[i] = ' null,"documentType":' + after_temper_part;
        }
        String result = response_body_splited[0];
        for(Integer i = 1; i < response_body_splited.size(); ++i){
            result += '"tamperData":'+response_body_splited[i];
        }
        return result;
    }

    public Boolean getIsZopa54IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-54').isFeatureEnabled();
    }
}