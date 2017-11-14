public class ApiCommandLoanCallCredit extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    public ApiCommandLoanCallCredit(String uuid) {
        super(ApiCommandsFactory.LOAN_CALLCREDIT, uuid);
    }

    public CallCreditDetails getResponse(){
        String response_body = HttpApiResponse.getBody();
        return (CallCreditDetails) System.JSON.deserialize(response_body, CallCreditDetails.class);
    }

    public class CallCreditDetails {
        public ApplicantSummaryDetails ApplicantSummary {get; set;}
        public List<SummaryAddress> SummaryAddresses {get; set;}
        public List<ElectoralRollHistory> ApplicantsCurrentAddressElectoralRoll {get; set;}
        public Boolean IsIndividualReport {get; set;}
        public List<ShareAccount> UnsettledShareAccounts {get; set;}
        public List<ShareAccount> SettledShareAccounts {get; set;}
        public List<AddressLink> AddressLinks {get; set;}
        public List<AssociateLink> AssociateLinks {get; set;}
    }

    public class ApplicantSummaryDetails {
        public Decimal TotalBalancesActive {get; set;}
        public Decimal TotalBalancesLoans {get; set;}
        public Decimal TotalBalancesMortgages {get; set;}
        public Decimal TotalBalancesRevolve {get; set;}
        public Decimal TotalLimitsRevolve {get; set;}
        public Decimal BalanceLimitRatioRevolve {get; set;}
        public Decimal TotalValueCashAdvances12Months {get; set;}
        public Decimal TotalValueCashAdvances36Months {get; set;}
        public Integer TotalDelinqs12Months {get; set;}
        public String WorstPayStatus12Months {get; set;}
        public String WorstPayStatus36Months {get; set;}
        public Integer TotalDefaults12Months {get; set;}
        public Integer TotalDefaults36Months {get; set;}
        public Boolean CurrentlyInsolvent {get; set;}
        public Integer TotalDischargedBAIs {get; set;}
        public Integer TotalActiveJudgements {get; set;}
        public Integer TotalSatisfiedJudgements {get; set;}
        public Integer TotalHomeCreditSearches3Months {get; set;}
    }

    public class SummaryAddress{
        public Boolean Current {get; set;}
         public String Address {get; set;}
        public String Level {get; set;}
        public String Source {get; set;}
    }

    public class ElectoralRollHistory {
        public String Address {get; set;}
        public String Resident {get; set;}
        public String Duration {get; set;}
    }

    public class ShareAccount {
        public String AccountHolderName {get; set;}
        public String AccountHolderAddress {get; set;}
        public List<String> HistoricPaymentStatus {get; set;}
        public List<String> HistoricAccountStatus {get; set;}
        public String AccountHolderDob {get; set;}
        public String AccountState {get; set;}
        public String AccountType {get; set;}
        public Decimal CurrentBalance {get; set;}
        public String DateUpdated {get; set;}
        public Decimal CreditLimitOverdraft {get; set;}
        public String OrganisationType {get; set;}
        public String AccountStartDate {get; set;}
        public String AccountEndDate {get; set;}
        public Decimal StartingBalance {get; set;}
        public Decimal StatementBalance {get; set;}
        public String PaymentFrequency {get; set;}
        public Decimal RegularPayment {get; set;}
        public Integer RepaymentPeriodPayment {get; set;}
        public Boolean Defaulted {get; set;}
        public String DefaultDate {get; set;}
        public Decimal OriginalDefaultBalance {get; set;}
        public String DateDefaultSatisfied {get; set;}
        public List<AccountHistoryItem> AccountHistory {get; set;}

        public String getDateUpdatedDisplay(){
            return ApiCommandParserDateTime.parseDate(DateUpdated);
        }

        public String getAccountStartDateDisplay(){
            return ApiCommandParserDateTime.parseDate(AccountStartDate);
        }

        public String getAccountEndDateDisplay(){
            return ApiCommandParserDateTime.parseDate(AccountEndDate);
        }

        public String getDefaultDateDisplay(){
            return ApiCommandParserDateTime.parseDate(DefaultDate);
        }

        public String getDateDefaultSatisfiedDisplay(){
            return ApiCommandParserDateTime.parseDate(DateDefaultSatisfied);
        }

        public String getAccountHolderDobDisplay(){
            return ApiCommandParserDateTime.parseDate(AccountHolderDob);
        }
    }

    public class AccountHistoryItem {
        public String Month {get; set;}
        public Decimal CurrentBalance {get; set;}
        public Decimal StatementBalance {get; set;}
        public Decimal CreditLimit {get; set;}
        public Decimal PaymentAmount {get; set;}
        public Integer NumberOfCashAdvances {get; set;}
        public Decimal ValueOfCashAdvances {get; set;}
    }

    public class AddressLink {
        public String Value {get; set;}
    }

    public class AssociateLink {
        public String SupplierType {get; set;}
        public String LastConfirmationDate {get; set;}
        public String EarliestConfirmationDate {get; set;}

        public String getLastConfirmationDateDisplay(){
            return ApiCommandParserDateTime.parseDate(LastConfirmationDate);
        }

        public String getEarliestConfirmationDateDisplay(){
            return ApiCommandParserDateTime.parseDate(EarliestConfirmationDate);
        }
    }
}