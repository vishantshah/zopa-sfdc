public with sharing class CifaDetailsViewController {
    public List<CifaWrapper> CifaList {public get; private set;}
    public String ErrorOnLoad {public get; private set;}
    public String LoanAppId {get; set;}

    public CifaDetailsViewController() {}

    public PageReference getCifaInformation() {
        ApiResponseLoanCommonInformation api_response_loan_info = ApiLoanCommonDataProvider.getInstance(LoanAppId).getData();
        if (api_response_loan_info == null) {
            ErrorOnLoad = ApiLoanCommonDataProvider.getInstance(LoanAppId).getError();
        } else {
            fillCifaWrapperListFromResponse(api_response_loan_info);
        }
        return null;
    }

    public Boolean getIsZopa76IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-76').isFeatureEnabled();
    }

    private void fillCifaWrapperListFromResponse(ApiResponseLoanCommonInformation response) {
        CifaList = new List<CifaWrapper>();
        if (response != null && response.Cifas != null){
            for(ApiResponseLoanCommonInformation.Cifas cifa : response.Cifas){
                CifaWrapper cifa_wrapper = new CifaWrapper(cifa.Address, cifa.CifasItems);
                CifaList.add(cifa_wrapper);
            }
        }
    }

    public class CifaWrapper {
        public String Address {get; set;}
        public List<CifaItemWrapper> CifaItems {get; set;}

        public CifaWrapper(String address, List<ApiResponseLoanCommonInformation.CifasItems> cifa_items) {
            this.Address = address;
            CifaItems = new List<CifaItemWrapper>();
            for(ApiResponseLoanCommonInformation.CifasItems cifa_item : cifa_items){
                CifaItemWrapper cifa_item_wrapper = new CifaItemWrapper(cifa_item.Name, cifa_item.DateOfBirth, cifa_item.FraudDate, cifa_item.CaseNumber, cifa_item.Category, cifa_item.SupplyingMember, cifa_item.ReferenceText);
                CifaItems.add(cifa_item_wrapper);
            }
        }

        public Boolean getHasCifaItems(){
            return CifaItems.size() > 0;
        }

        public Integer getCifaItemsNumber(){
            return CifaItems.size();
        }
    }

    public class CifaItemWrapper {
        public String Name {get; set;}
        public String DateOfBirth {get; set;}
        public String FraudDate {get; set;}
        public String CaseNumber {get; set;}
        public String Category {get; set;}
        public String SupplyingMember {get; set;}
        public String ReferenceText {get; set;}

        public CifaItemWrapper(String name, String date_of_birth, String fraud_date, String case_number, String category, String supplying_member, String reference_text){
            this.Name = name;
            this.DateOfBirth = ApiCommandParserDateTime.parseDate(date_of_birth);
            this.FraudDate = ApiCommandParserDateTime.parseDate(fraud_date);
            this.CaseNumber = case_number;
            this.Category = category;
            this.SupplyingMember = supplying_member;
            this.ReferenceText = reference_text;
        }
    }
}