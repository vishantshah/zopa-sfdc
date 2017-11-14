public class EquifaxAddressCheck {
    public String Address {get; set;}
    public List<AddressCheckItem> Insights {get; set;}

    public class AddressCheckItem{
        public String Name {get; set;}
        public String DateOfBirth {get; set;}
        public String StartDate {get; set;}
        public String EndDate {get; set;}
        public Decimal Balance {get; set;}
        public Decimal CreditLimit {get; set;}
        public String PaymentHistory {get; set;}
        public String CompanyClass {get; set;}
        public String AccountType {get; set;}
        public String Terms {get; set;}
        public String UpdateDate {get; set;}
        public Decimal DefaultBalance {get; set;}
        public String DelinquentDate {get; set;}
        public String Flags {get; set;}

        public String getDateOfBirthDisplay(){
            return ApiCommandParserDateTime.parseDate(DateOfBirth);
        }

        public String getStartDateDisplay(){
            return ApiCommandParserDateTime.parseDate(StartDate);
        }

        public String getEndDateDisplay(){
            return ApiCommandParserDateTime.parseDate(EndDate);
        }

        public String getUpdateDateDisplay(){
            return ApiCommandParserDateTime.parseDate(UpdateDate);
        }

        public String getDelinquentDateDisplay(){
            return ApiCommandParserDateTime.parseDate(DelinquentDate);
        }
    }
}