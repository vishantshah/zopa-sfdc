public class ApiCommandGetLoanDetails extends ApiCommandsFactory.ApiCommandAbstractBuilder{

    public ApiCommandGetLoanDetails(String uuid) {
        super(ApiCommandsFactory.GET_LOAN_DETAILS, uuid);
    }

    public LoanDetails getResponse(){
        String response_body = HttpApiResponse.getBody();
        return (LoanDetails) System.JSON.deserialize(response_body, LoanDetails.class);
    }

    public class LoanDetails {
        public Decimal ArrearsBalance {get; set;}
        public Decimal ArrearsRatio {get; set;}
        public Decimal EarlyRepaymentAmount {get; set;}
        public Decimal HoldingAccountBalance {get; set;}
        public Decimal MonthlyRepaymentAmount {get; set;}
        public Decimal NextRepaymentAdjustment {get; set;}
        public Decimal RemainingBalance {get; set;}
        public Decimal ReplacementAmount {get; set;}
        public String State {get; set;}
        public Decimal TotalActualRepayableAmount {get; set;}
        public String LastRepaymentDate {public get; public set{
                LastRepaymentDate = ApiCommandParserDateTime.parseDate(value);
            }
        }
        public Decimal RepaymentDayofMonth {get; set;}
        public Decimal FirstMonthRepaymentAmount {get; set;}
        public Decimal FirstMonthExtraDays {get; set;}
    }

}