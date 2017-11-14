public with sharing class PaymentHistoryViewController {
    public List<ZopaLoanHistoryWrapper> PaymentHistoryList {public get; private set;}
    public String ErrorOnLoad {public get; private set;}
    public String LoanAppId {get; set;}


    public PaymentHistoryViewController() {}

    public Boolean getLoanHistoryHasAnyPayments(){
        if(PaymentHistoryList != null){
            for(ZopaLoanHistoryWrapper loan_payments_history : PaymentHistoryList){
                if(loan_payments_history.getHasZopaLoanHistoryItems()){
                    return true;
                }
            }
        }
        return false;
    }

    public PageReference getPaymentHistoryInformation() {
        ApiResponseLoanCommonInformation api_response_loan_info = ApiLoanCommonDataProvider.getInstance(LoanAppId).getData();
        if (api_response_loan_info == null) {
            ErrorOnLoad = ApiLoanCommonDataProvider.getInstance(LoanAppId).getError();
        } else {
            fillPaymentHistoryWrapperListFromResponse(api_response_loan_info);
        }
        return null;
    }

    public Boolean getIsZopa74IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-74').isFeatureEnabled();
    }

    public Boolean getNoRecordToDisplay(){
        return (PaymentHistoryList == null || PaymentHistoryList.isEmpty()) && ErrorOnLoad == null;
    }

    private void fillPaymentHistoryWrapperListFromResponse(ApiResponseLoanCommonInformation response) {
        PaymentHistoryList = new List<ZopaLoanHistoryWrapper>();
        for(ApiResponseLoanCommonInformation.ZopaLoanHistory payment : response.ZopaLoanHistory){
            ZopaLoanHistoryWrapper payment_wrapper = new ZopaLoanHistoryWrapper(payment.LoanId, payment.PaymentHistory);
            PaymentHistoryList.add(payment_wrapper);
        }
    }

    public class ZopaLoanHistoryWrapper {
        public String LoanExternalId {get; set;}
        public Id LoanId {get; set;}
        public List<ZopaLoanRepaymentItemWrapper> ZopaLoanRepaymentItems {get; set;}

        public ZopaLoanHistoryWrapper(String loan_id, List<ApiResponseLoanCommonInformation.ZopaLoanRepayment> payment_items) {
            this.LoanExternalId = loan_id;
            ZopaLoanRepaymentItems = new List<ZopaLoanRepaymentItemWrapper>();
            for(ApiResponseLoanCommonInformation.ZopaLoanRepayment payment_item : payment_items){
                ZopaLoanRepaymentItemWrapper payment_item_wrapper = new ZopaLoanRepaymentItemWrapper(payment_item.RepaymentDate, payment_item.Type, payment_item.Amount, payment_item.Status);
                ZopaLoanRepaymentItems.add(payment_item_wrapper);
            }
        }

        public Boolean getLoanIdIsExist(){
            List<Loan_Application__c> loan_with_external_id = getLoanObjectByExternalId();
            if(loan_with_external_id.size() > 0){
                LoanId = loan_with_external_id[0].Id;
            }
            return loan_with_external_id.size() > 0;
        }

        public Boolean getHasZopaLoanHistoryItems(){
            return ZopaLoanRepaymentItems.size() > 0;
        }

        public Integer getZopaLoanHistoryItemsNumber(){
            return ZopaLoanRepaymentItems.size();
        }

        private List<Loan_Application__c> getLoanObjectByExternalId(){
            return [SELECT Id FROM Loan_Application__c WHERE Loan_Id__c = :LoanExternalId];
        }
    }

    public class ZopaLoanRepaymentItemWrapper {
        public String RepaymentDate {get; set;}
        public String Type {get; set;}
        public Decimal Amount {get; set;}
        public String Status {get; set;}

        public ZopaLoanRepaymentItemWrapper(String repayment_date, String type, Decimal amount, String status){
            this.RepaymentDate =  ApiCommandParserDateTime.parseDate(repayment_date);
            this.Type = type;
            this.Amount = amount;
            this.Status = status;
        }
    }
}