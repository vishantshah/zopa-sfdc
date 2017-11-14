public with sharing class ApiCommandLoanGetPaymentPlans extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    public ApiCommandLoanGetPaymentPlans(String uuid) {
        super(ApiCommandsFactory.LOAN_GET_PAYMENT_PLANS, uuid);
    }

    public List<PaymentPlan> getResponse(String response_body){
        return (List<PaymentPlan>) System.JSON.deserialize(response_body, List<PaymentPlan>.class);
    }

    public class PaymentPlan{
        public String PaymentPlanId {get;set;}
        public String Duration {get;set;}
        public String Arrangement {get;set;}
        public DateTime CreatedDate {get;set;}
        public Decimal Amount {get;set;}
        public String Frequency {get;set;}
        public String PaymentDay {get;set;}
        public String Method {get;set;}
        public String ArrearsReason {get;set;}
        public String State {get;set;}
        public DateTime EndDate {get;set;}

        public PaymentPlan(){}

        public PaymentPlan(String payment_plan_id, String duration, String arrangement, DateTime created_date, Decimal amount, String frequency, String payment_day, String method, String arrears_reason, String state, DateTime end_date){
            PaymentPlanId = payment_plan_id;
            Duration = duration;
            Arrangement = arrangement;
            CreatedDate = created_date;
            Amount = amount;
            Frequency = frequency;
            PaymentDay = payment_day;
            Method = method;
            ArrearsReason = arrears_reason;
            State = state;
            EndDate = end_date;
        }

        public Boolean equal(PaymentPlan payment_plan){
            return (this.PaymentPlanId == payment_plan.PaymentPlanId &&
                    this.Duration == payment_plan.Duration &&
                    this.Arrangement == payment_plan.Arrangement &&
                    this.CreatedDate == payment_plan.CreatedDate &&
                    this.Amount == payment_plan.Amount &&
                    this.Frequency == payment_plan.Frequency &&
                    this.PaymentDay == payment_plan.PaymentDay &&
                    this.Method == payment_plan.Method &&
                    this.ArrearsReason == payment_plan.ArrearsReason &&
                    this.State == payment_plan.State &&
                    this.EndDate == payment_plan.EndDate);
        }
    }
}