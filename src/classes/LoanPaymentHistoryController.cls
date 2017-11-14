public with sharing class LoanPaymentHistoryController {
    public List<ZopaLoanRepaymentItemWrapper> PaymentHistoryList {public get; private set;}
    public String ErrorOnLoad {public get; private set;}
    public String LoanId {get; set;}
    public ApiCommandGetLoanDetails.LoanDetails LoanDetails { get; private set;}

    public LoanPaymentHistoryController() {
        PaymentHistoryList = new List<ZopaLoanRepaymentItemWrapper>();
    }

    public PageReference getLoanDetails() {
        if (LoanId != null) {
            ApiCommandGetLoanDetails get_loan_details_command = new ApiCommandGetLoanDetails(LoanId);
            ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);
            if (get_loan_details_command.CommandSuccessful) {
                LoanDetails = get_loan_details_command.getResponse();
            }
        }
        return null;
    }

    public Boolean getIsLoanDetailsRetrieved() {
        return LoanDetails != null;
    }

    public Boolean getLoanHistoryHasAnyPayments(){
        return !PaymentHistoryList.isEmpty();
    }

    public Boolean getIsNoPaymentsMessageVisible(){
        return FeatureSwitch.getSwitch('ZCP-160').isFeatureEnabled() && isNoRecordToDisplay();
    }

    public PageReference getPaymentHistoryInformation() {
        List<ApiResponseLoanInformation.ZopaLoanHistory> list_api_response_loan_info = ApiLoanDataProvider.getInstance(LoanId,new ApiCommandLoanInformation(LoanId)).getData();
        if (list_api_response_loan_info == null) {
            ErrorOnLoad = ApiLoanDataProvider.getInstance(LoanId, new ApiCommandLoanInformation(LoanId)).getError();
        } else {
            fillPaymentHistoryWrapperListFromResponse(list_api_response_loan_info);
        }
        return null;
    }

    public Boolean getIsZcp20IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-20').isFeatureEnabled();
    }

    @TestVisible
    private Boolean isNoRecordToDisplay(){
        return PaymentHistoryList.isEmpty() && String.isEmpty(ErrorOnLoad);
    }

    private void fillPaymentHistoryWrapperListFromResponse(List<ApiResponseLoanInformation.ZopaLoanHistory> response) {
        PaymentHistoryList = new List<ZopaLoanRepaymentItemWrapper>();
        for(ApiResponseLoanInformation.ZopaLoanHistory payment_item : response){
            ZopaLoanRepaymentItemWrapper payment_wrapper = new ZopaLoanRepaymentItemWrapper(
                    payment_item.CountsAsNormalRepayment,
                    payment_item.ThirdPartyFlag,
                    payment_item.RepaymentDate,
                    payment_item.ReceivedDate,
                    payment_item.Type,
                    payment_item.Amount,
                    payment_item.Status
            );
            PaymentHistoryList.add(payment_wrapper);
        }
    }

    public class ZopaLoanRepaymentItemWrapper {
        public Boolean CountsAsNormalRepayment {get; set;}
        public Boolean ThirdPartyFlag {get; set;}
        public String RepaymentDate {get; set;}
        public String ReceivedDate {get; set;}
        public String Type {get; set;}
        public Decimal Amount {get; set;}
        public String Status {get; set;}

        public ZopaLoanRepaymentItemWrapper(Boolean counts_as_normal_repayment, Boolean third_party_flag, String repayment_date, String received_date, String type, Decimal amount, String status){
            this.CountsAsNormalRepayment = counts_as_normal_repayment;
            this.ThirdPartyFlag = third_party_flag;
            this.RepaymentDate =  ApiCommandParserDateTime.parseDate(repayment_date);
            this.ReceivedDate = ApiCommandParserDateTime.parseDate(received_date);
            this.Type = type;
            this.Amount = amount;
            this.Status = status;
        }
    }
}