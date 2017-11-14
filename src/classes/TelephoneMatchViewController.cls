public with sharing class TelephoneMatchViewController {

    public List<TelephoneMatchWrapper> TelephoneMatchList {public get; private set;}
    public String ErrorOnLoad {public get; private set;}
    public String LoanAppId {get; set;}

    public TelephoneMatchViewController() {}

    public PageReference getTelephoneMatchInformation() {
        ApiResponseLoanCommonInformation api_response_loan_info = ApiLoanCommonDataProvider.getInstance(LoanAppId).getData();
        if (api_response_loan_info == null) {
            ErrorOnLoad = ApiLoanCommonDataProvider.getInstance(LoanAppId).getError();
        } else {
            fillTelephoneMatchWrapperListFromResponse(api_response_loan_info);
        }
        return null;
    }

    public Boolean getIsZopa147IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-147').isFeatureEnabled();
    }

    private void fillTelephoneMatchWrapperListFromResponse(ApiResponseLoanCommonInformation response) {
        TelephoneMatchList = new List<TelephoneMatchWrapper>();
        if (response != null && response.TelephoneMatchAddresses != null){
            for(ApiResponseLoanCommonInformation.TelephoneMatchAddresses telephone_match : response.TelephoneMatchAddresses){
                TelephoneMatchWrapper telephone_match_wrapper = new TelephoneMatchWrapper(telephone_match.Address, telephone_match.TelephoneMatches);
                TelephoneMatchList.add(telephone_match_wrapper);
            }
        }
    }


    public class TelephoneMatchWrapper {
        public String Address {get; set;}
        public List<TelephoneMatchItemWrapper> TelephoneMatchItems {get; set;}

        public TelephoneMatchWrapper(String address, List<ApiResponseLoanCommonInformation.TelephoneMatches> telephone_match_items) {
            this.Address = address;
            TelephoneMatchItems = new List<TelephoneMatchItemWrapper>();
            for(ApiResponseLoanCommonInformation.TelephoneMatches telephone_match_item : telephone_match_items){
                TelephoneMatchItemWrapper telephone_match_item_wrapper = new TelephoneMatchItemWrapper(telephone_match_item.Name, telephone_match_item.TelephoneNumber);
                TelephoneMatchItems.add(telephone_match_item_wrapper);
            }
        }

        public Boolean getHasTelephoneMatchItems(){
            return TelephoneMatchItems.size() > 0;
        }

        public Integer getTelephoneMatchItemsNumber(){
            return TelephoneMatchItems.size();
        }
    }

    public class TelephoneMatchItemWrapper {
        public String Name {get; set;}
        public String TelephoneNumber {get; set;}

        public TelephoneMatchItemWrapper(String name, String telephone_number){
            this.Name = name;
            this.TelephoneNumber = telephone_number;
        }
    }

}