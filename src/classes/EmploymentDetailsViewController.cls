public class EmploymentDetailsViewController {

    public String LoanAppId {get; set;}
    public String ErrorOnLoad {public get; private set;}

    public Employer CurrentEmployer {public get; private set;}
    public Employer PreviousEmployer {public get; private set;}

    public EmploymentDetailsViewController() {}

    public PageReference getEmploymentDetailsInformation() {
        ApiResponseLoanCommonInformation api_response_loan_info = ApiLoanCommonDataProvider.getInstance(LoanAppId).getData();
        if (api_response_loan_info == null) {
            ErrorOnLoad = ApiLoanCommonDataProvider.getInstance(LoanAppId).getError();
        } else {
            fillEmploymentDetailsFromResponse(api_response_loan_info);
        }
        return null;
    }

    private void fillEmploymentDetailsFromResponse(ApiResponseLoanCommonInformation api_response_loan_info){
        CurrentEmployer = new Employer();
        CurrentEmployer.JobTitle = api_response_loan_info.Employment.CurrentEmployer.JobTitle;
        CurrentEmployer.Name = api_response_loan_info.Employment.CurrentEmployer.Name;
        CurrentEmployer.Address = api_response_loan_info.Employment.CurrentEmployer.Address;
        CurrentEmployer.PostCode = api_response_loan_info.Employment.CurrentEmployer.PostCode;
        CurrentEmployer.Telephone = api_response_loan_info.Employment.CurrentEmployer.Telephone;
        CurrentEmployer.TimeAtEmployer = ApiCommandParserTimeInWords.getTimeInText(api_response_loan_info.Employment.CurrentEmployer.MonthsAtEmployer);
        CurrentEmployer.ContactInfo = api_response_loan_info.Employment.CurrentEmployer.ContactInfo;
        if(api_response_loan_info.Employment.PreviousEmployer != null){
            PreviousEmployer = new Employer();
            PreviousEmployer.JobTitle = api_response_loan_info.Employment.PreviousEmployer.JobTitle;
            PreviousEmployer.Name = api_response_loan_info.Employment.PreviousEmployer.Name;
            PreviousEmployer.Address = api_response_loan_info.Employment.PreviousEmployer.Address;
            PreviousEmployer.PostCode = api_response_loan_info.Employment.PreviousEmployer.PostCode;
            PreviousEmployer.Telephone = api_response_loan_info.Employment.PreviousEmployer.Telephone;
            PreviousEmployer.TimeAtEmployer = ApiCommandParserTimeInWords.getTimeInText(api_response_loan_info.Employment.PreviousEmployer.MonthsAtEmployer);
            PreviousEmployer.ContactInfo = api_response_loan_info.Employment.PreviousEmployer.ContactInfo;
        }
    }

    public Boolean getIsZopa73IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-73').isFeatureEnabled();
    }

    public class Employer {
        public String JobTitle {get; set;}
        public String Name {get; set;}
        public String Address {get; set;}
        public String PostCode {get; set;}
        public String Telephone {get; set;}
        public String TimeAtEmployer {get; set;}
        public String ContactInfo {get; set;}
    }
}