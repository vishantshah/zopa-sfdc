public with sharing class CountyCourtJudgmentViewCont {
    public List<CountyCourtJudgmentWrapper> CountyCourtJudgmentList {public get; private set;}
    public String ErrorOnLoad {public get; private set;}
    public String LoanAppId {get; set;}

    public CountyCourtJudgmentViewCont() {}

    public PageReference getCountyCourtJudgmentInformation() {
        ApiResponseLoanCommonInformation api_response_loan_info = ApiLoanCommonDataProvider.getInstance(LoanAppId).getData();
        if (api_response_loan_info == null) {
            ErrorOnLoad = ApiLoanCommonDataProvider.getInstance(LoanAppId).getError();
        } else {
            fillCountyCourtJudgmentWrapperListFromResponse(api_response_loan_info);
        }
        return null;
    }

    public Boolean getIsZopa77IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-77').isFeatureEnabled();
    }

    private void fillCountyCourtJudgmentWrapperListFromResponse(ApiResponseLoanCommonInformation response) {
        CountyCourtJudgmentList = new List<CountyCourtJudgmentWrapper>();
        if (response != null && response.CcJs != null){
            for(ApiResponseLoanCommonInformation.CcJs county_court_judgment : response.CcJs){
                CountyCourtJudgmentWrapper county_court_judgment_wrapper = new CountyCourtJudgmentWrapper(county_court_judgment.Address, county_court_judgment.CcJs);
                CountyCourtJudgmentList.add(county_court_judgment_wrapper);
            }
        }
    }

    public class CountyCourtJudgmentWrapper {
        public String Address {get; set;}
        public List<CountyCourtJudgmentItemWrapper> CountyCourtJudgmentItems {get; set;}

        public CountyCourtJudgmentWrapper(String address, List<ApiResponseLoanCommonInformation.CcJs> county_court_judgment_items) {
            this.Address = address;
            CountyCourtJudgmentItems = new List<CountyCourtJudgmentItemWrapper>();
            for(ApiResponseLoanCommonInformation.CcJs county_court_judgment_item : county_court_judgment_items){
                CountyCourtJudgmentItemWrapper county_court_judgment_item_wrapper = new CountyCourtJudgmentItemWrapper(county_court_judgment_item.Name, county_court_judgment_item.DateOfBirth, county_court_judgment_item.Value, county_court_judgment_item.CourtDate, county_court_judgment_item.SatisfiedDate);
                CountyCourtJudgmentItems.add(county_court_judgment_item_wrapper);
            }
        }

        public Boolean getHasCountyCourtJudgmentItems(){
            return CountyCourtJudgmentItems.size() > 0;
        }

        public Integer getCountyCourtJudgmentItemsNumber(){
            return CountyCourtJudgmentItems.size();
        }
    }

    public class CountyCourtJudgmentItemWrapper {
        public String Name {get; set;}
        public String DateOfBirth {get; set;}
        public Decimal Value {get; set;}
        public String CourtDate {get; set;}
        public String SatisfiedDate {get; set;}

        public CountyCourtJudgmentItemWrapper(String name, String date_of_birth, Decimal value, String court_date, String satisfied_date){
            this.Name = name;
            this.DateOfBirth = ApiCommandParserDateTime.parseDate(date_of_birth);
            this.Value = value;
            this.CourtDate = ApiCommandParserDateTime.parseDate(court_date);
            this.SatisfiedDate = ApiCommandParserDateTime.parseDate(satisfied_date);
        }
    }
}