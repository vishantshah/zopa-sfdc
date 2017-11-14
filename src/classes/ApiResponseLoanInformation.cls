public with sharing class ApiResponseLoanInformation {
    public List<ZopaLoanHistory> ListZopaLoanHistory;

    public static List<ApiResponseLoanInformation.ZopaLoanHistory> parse(String json) {
        return (List<ZopaLoanHistory>) System.JSON.deserialize(json, List<ZopaLoanHistory>.class);
    }

    public class ZopaLoanHistory {
        public Boolean CountsAsNormalRepayment;
        public Boolean ThirdPartyFlag;
        public String ReceivedDate;
        public String RepaymentDate;
        public String Type;
        public Decimal Amount;
        public String Status;
    }
}