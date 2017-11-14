public with sharing class ElectoralRollAddressesViewController {
    public List<ElectoralRollAddressWrapper> ElectoralRollAddressList {public get; private set;}
    public String ErrorOnLoad {public get; private set;}
    public String LoanAppId {get; set;}

    public ElectoralRollAddressesViewController() {}

    public PageReference getElectoralRollAddressInformation() {
        ApiResponseLoanCommonInformation api_response_loan_info = ApiLoanCommonDataProvider.getInstance(LoanAppId).getData();
        if (api_response_loan_info == null) {
            ErrorOnLoad = ApiLoanCommonDataProvider.getInstance(LoanAppId).getError();
        } else {
            fillElectoralRollAddressWrapperListFromResponse(api_response_loan_info);
        }
        return null;
    }

    public Boolean getIsZopa147IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-147').isFeatureEnabled();
    }

    private void fillElectoralRollAddressWrapperListFromResponse(ApiResponseLoanCommonInformation response) {
        ElectoralRollAddressList = new List<ElectoralRollAddressWrapper>();
        if (response != null && response.ElectoralRollAddresses != null){
            for(ApiResponseLoanCommonInformation.ElectoralRollAddresses era : response.ElectoralRollAddresses){
                ElectoralRollAddressWrapper era_wrapper = new ElectoralRollAddressWrapper(era.Address, era.ElectoralEnrollments);
                ElectoralRollAddressList.add(era_wrapper);
            }
        }
    }


    public class ElectoralRollAddressWrapper {
        public String Address {get; set;}
        public List<ElectoralRollAddressItemWrapper> ElectoralRollAddressItems {get; set;}

        public ElectoralRollAddressWrapper(String address, List<ApiResponseLoanCommonInformation.ElectoralEnrollments> era_items) {
            this.Address = address;
            ElectoralRollAddressItems = new List<ElectoralRollAddressItemWrapper>();
            for(ApiResponseLoanCommonInformation.ElectoralEnrollments era_item : era_items){
                ElectoralRollAddressItemWrapper era_item_wrapper = new ElectoralRollAddressItemWrapper(era_item.VotersName, era_item.Period, era_item.IsApplicant);
                ElectoralRollAddressItems.add(era_item_wrapper);
            }
        }

        public Boolean getHasElectoralRollAddressItems(){
            return ElectoralRollAddressItems.size() > 0;
        }

        public Integer getElectoralRollAddressItemsNumber(){
            return ElectoralRollAddressItems.size();
        }
    }

    public class ElectoralRollAddressItemWrapper {
        public String VotersName {get; set;}
        public String Period {get; set;}
        public Boolean IsApplicant {get; set;}

        public ElectoralRollAddressItemWrapper(String name, String period, Boolean is_applicant){
            this.VotersName = name;
            this.Period = period;
            this.IsApplicant = is_applicant;
        }
    }

}