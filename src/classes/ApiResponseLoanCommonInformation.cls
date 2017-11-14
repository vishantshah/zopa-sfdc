public class ApiResponseLoanCommonInformation {
    public BankDetails BankDetails;
    public CallValidateBankDetails CallValidateBankDetails;
    public AddressHistory[] AddressHistory;
    public Employment Employment;
    public FullAffordabilityDetails Affordability;
    public ZopaLoanHistory[] ZopaLoanHistory;
    public CcJs[] CcJs;
    public Cifas[] Cifas;
    public ElectoralRollAddresses[] ElectoralRollAddresses;
    public TelephoneMatchAddresses[] TelephoneMatchAddresses;

    public static ApiResponseLoanCommonInformation parse(String json) {
        return (ApiResponseLoanCommonInformation) System.JSON.deserialize(json, ApiResponseLoanCommonInformation.class);
    }

    public class BankDetails {
        public String BankName;
        public String AccountHolderName;
        public String AccountNumber;
        public String SortCode;
    }

    public class CallValidateBankDetails {
        public String MatchLevel;
    }

    public class AddressHistory {
        public String Address;
        public String ArrivedDate;
        public Integer MonthsAtAddress;
    }

    public class Employment {
        public Employer CurrentEmployer;
        public Employer PreviousEmployer;
    }
    public class Employer {
        public String JobTitle;
        public String Name;
        public String Address;
        public String PostCode;
        public String Telephone;
        public Integer MonthsAtEmployer;
        public String ContactInfo;
    }

    public class FullAffordabilityDetails {
        public Decimal DeclaredAnnualIncome;
        public Decimal ConfirmedAnnualIncome;
        public String IncomeCheckResult;
        public Decimal AdditionalIncome;
        public Decimal MonthlyNetIncome;
        public Decimal RentMortgage;
        public Decimal Mortgage;
        public Decimal ConfirmedRentMortgage;
        public RollingCreditLine[] RollingCreditLines;
        public UnsecuredDebt[] UnsecuredDebts;
        public Decimal TotalMonthlyRepaymentAmount;
        public Decimal TotalUnsecuredDebtAmount;
        public Decimal DisposableIncome;
        public Decimal DebtToIncome;
        public Decimal LowDebtToIncome;
        public String Notes;
    }
    public class RollingCreditLine {
        public String CompanyClass;
        public String AccountType;
        public String Source;
        public Decimal Total;
        public Decimal Monthly;
    }
    public class UnsecuredDebt {
        public Decimal Monthly;
        public String CompanyClass;
        public String AccountType;
        public String Source;
        public Decimal Total;
    }

    public class ZopaLoanHistory {
        public String LoanId;
        public ZopaLoanRepayment[] PaymentHistory;
    }

    public class ZopaLoanRepayment {
        public String RepaymentDate;
        public String Type;
        public Decimal Amount;
        public String Status;
    }

    public class CcJs {
        public String Address;
        public CcJs[] CcJs;
        public String Name;
        public String DateOfBirth;
        public Decimal Value;
        public String CourtDate;
        public String SatisfiedDate;
    }

    public class Cifas {
        public String Address;
        public CifasItems[] CifasItems;
    }
    public class CifasItems {
        public String Name;
        public String DateOfBirth;
        public String FraudDate;
        public String CaseNumber;
        public String Category;
        public String SupplyingMember;
        public String ReferenceText;
    }

    public class ElectoralRollAddresses{
        public String Address;
        public ElectoralEnrollments[] ElectoralEnrollments;
    }

    public class ElectoralEnrollments{
        public String VotersName;
        public String Period;
        public Boolean IsApplicant;
    }

    public class TelephoneMatchAddresses{
        public String Address;
        public TelephoneMatches[] TelephoneMatches;
    }

    public class TelephoneMatches{
        public String Name;
        public String TelephoneNumber;
    }
}