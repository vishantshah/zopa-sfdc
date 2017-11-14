public class BankDetailsSectionController {

    public List<BankDetailWrapper> BankDetailsList {public get; private set;}
    public String ErrorOnLoad {public get; private set;}
    public String ErrorOnLoadValidateDetails {public get; private set;}
    public String LoanAppId {get; set;}
    public ApiCommandValidateBankDetails.ValidateBankDetails ValidateBankDetails {get; private set;}
    public Boolean LazyLoadFinished {get; private set;}
    public Boolean IsShownValidateBankDetailsPopUp {get; private set;}

    public BankDetailsSectionController() {}

    public void showValidateBankDetailsPopup(){
        IsShownValidateBankDetailsPopUp = true;
        validateBankDetails();
    }

    public PageReference endActionValidateBankDetails(){
        IsShownValidateBankDetailsPopUp = false;
        getBankDetailsInformation();
        return null;
    }

    public PageReference validateBankDetails() {
        ApiCommandValidateBankDetails validate_bank_details_command = new ApiCommandValidateBankDetails(LoanAppId);
        HttpResponse http_response = ApiCommandsFactory.getInstance().performApiCommandCallout(validate_bank_details_command);
        if(validate_bank_details_command.CommandSuccessful){
            ValidateBankDetails = validate_bank_details_command.getResponse();
            LazyLoadFinished = true;
        } else {
            if(http_response.getStatusCode() == 500){
                ErrorOnLoadValidateDetails = 'Something whent wrong while proccessing the request';
            } else {
                MessageUtility.addErrorPageMessage(validate_bank_details_command.CommandError);
            }
        }
        return null;
    }

    public PageReference getBankDetailsInformation() {
        ApiResponseLoanCommonInformation api_response_loan_info = ApiLoanCommonDataProvider.getInstance(LoanAppId).getData();
        if (api_response_loan_info == null) {
            ErrorOnLoad = ApiLoanCommonDataProvider.getInstance(LoanAppId).getError();
        } else {
            fillBankDetailWrapperListFromResponse(api_response_loan_info);
        }
        return null;
    }

    public Boolean getIsZopa57IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-57').isFeatureEnabled();
    }

    public Boolean getIsZopa156IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-156').isFeatureEnabled();
    }

    private void fillBankDetailWrapperListFromResponse(ApiResponseLoanCommonInformation response) {
        BankDetailsList = new List<BankDetailWrapper>();
        addBankDetailWrapper('Bank Name', response.BankDetails.BankName);
        addBankDetailWrapper('Account Holder Name', response.BankDetails.AccountHolderName);
        addBankDetailWrapper('Sort Code', response.BankDetails.SortCode);
        addBankDetailWrapper('Account Number', response.BankDetails.AccountNumber);
        addBankDetailWrapper('Bank Check', response.CallValidateBankDetails.MatchLevel);
    }

    private void addBankDetailWrapper(String detail_label, String customer_mandate) {
        BankDetailsList.add(new BankDetailWrapper(detail_label, customer_mandate));
    }

    public class BankDetailWrapper {
        public String DetailLabel {get; set;}
        public String CustomerDirectDebitMandate {get; set;}

        public BankDetailWrapper(String detail_label, String customer_mandate) {
            this.DetailLabel = detail_label;
            this.CustomerDirectDebitMandate = customer_mandate;
        }

    }
}