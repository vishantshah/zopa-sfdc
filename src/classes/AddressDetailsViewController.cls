public with sharing class AddressDetailsViewController {
    public List<AddressHistoryWrapper> AddressHistoryList {public get; private set;}
    public String ErrorOnLoad {public get; private set;}
    public String LoanAppId {get; set;}

    public AddressDetailsViewController() {}

    public PageReference getAddressHistoryInformation() {
        ApiResponseLoanCommonInformation api_response_loan_info = ApiLoanCommonDataProvider.getInstance(LoanAppId).getData();
        if (api_response_loan_info == null) {
            ErrorOnLoad = ApiLoanCommonDataProvider.getInstance(LoanAppId).getError();
        } else {
            fillAddressHistoryWrapperListFromResponse(api_response_loan_info);
        }
        return null;
    }

    public Boolean getIsZopa83IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-83').isFeatureEnabled();
    }

    public Boolean getNoRecordToDisplay(){
        return (AddressHistoryList == null || AddressHistoryList.isEmpty()) && ErrorOnLoad == null;
    }

    private void fillAddressHistoryWrapperListFromResponse(ApiResponseLoanCommonInformation response) {
        AddressHistoryList = new List<AddressHistoryWrapper>();
        for(ApiResponseLoanCommonInformation.AddressHistory address : response.AddressHistory){
            AddressHistoryWrapper address_wrapper = new AddressHistoryWrapper(address.Address, address.ArrivedDate, address.MonthsAtAddress);
            AddressHistoryList.add(address_wrapper);
        }
    }

    public class AddressHistoryWrapper {
        public String Address {get; set;}
        public String ArrivedDate {get; set;}
        public String TimeAtAddress {get; set;}

        public AddressHistoryWrapper(String address, String arrived_date, Integer months_at_address) {
            this.Address = address;
            this.ArrivedDate = ApiCommandParserDateTime.parseDate(arrived_date);
            this.TimeAtAddress = ApiCommandParserTimeInWords.getTimeInText(months_at_address);
        }
    }
}