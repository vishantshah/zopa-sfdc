public class AffordabilityDetailsController {

    public String LoanAppId {get; set;}
    public String LoanInternalId {get; set;}
    public String RowIndexToRemove {get; set;}
    public String ErrorOnLoad {get; private set;}

    public Decimal DeclaredAnnualIncome {get; private set;}
    public Decimal ConfirmedAnnualIncome {get; set;}
    public String IncomeCheckResult {get; private set;}
    public Decimal AdditionalIncome {get; private set;}
    public Decimal MonthlyNetIncome {get; set;}
    public Decimal RentMortgage {get; private set;}
    public Decimal BureauMortgage {get; private set;}
    public Decimal ConfirmedRentMortgage {get; set;}
    public List<RollingCreditLine> RollingCreditLines {get; set;}
    public List<UnsecuredDebt> UnsecuredDebts {get; set;}
    public Decimal TotalMonthlyRepaymentAmount {get; private set;}
    public Decimal TotalUnsecuredDebtAmount {get; private set;}
    public Decimal DisposableIncome {get; private set;}
    public Decimal DebtToIncome {get; private set;}
    public Decimal LowDebtToIncome {get; private set;}
    public String Notes {get; private set;}
    public Boolean IsWarningLDTI {get; private set;}
    public Boolean IsWarningDTI {get; private set;}
    public Boolean IsWarningDI {get; private set;}
    public List<SelectOption> AccountTypeOptionUnsecuredDebts {get; private set;}
    public List<SelectOption> AccountTypeOptionRollingCredit {get; private set;}
    public List<SelectOption> CompanyClassOptions {get; private set;}

    private transient Map<String, Company_Class_Options_MU__c> CompanyClassSettings;
    private transient Map<String, Account_Type_Option_MU__c> AccountTypeSettings;

    public AffordabilityDetailsController() {}

    public AffordabilityDetailsController(ApexPages.StandardController controller) {
        this();
        if (!Test.isRunningTest()) {
            controller.addFields(new List<string>{'Loan_ID__c'});
        }
        LoanAppId = (String)controller.getRecord().get('Loan_ID__c');
        LoanInternalId = (String)controller.getRecord().Id;
    }

    public PageReference getAffordabilityDetailsInformation() {
        ApiResponseLoanCommonInformation api_response_loan_info = ApiLoanCommonDataProvider.getInstance(LoanAppId).getData();
        if (api_response_loan_info == null) {
            ErrorOnLoad = ApiLoanCommonDataProvider.getInstance(LoanAppId).getError();
        } else {
            fillAffordabilityDetailsFromResponse(api_response_loan_info.Affordability);
        }
        setCompanyClassOptions();
        setAccountTypeOption();
        return null;
    }

    private void fillAffordabilityDetailsFromResponse(ApiResponseLoanCommonInformation.FullAffordabilityDetails affordability_response_loan_info){
        if(affordability_response_loan_info != null){
            DeclaredAnnualIncome = setScaleForDecimal(affordability_response_loan_info.DeclaredAnnualIncome);
            ConfirmedAnnualIncome = setScaleForDecimal(affordability_response_loan_info.ConfirmedAnnualIncome);
            IncomeCheckResult = affordability_response_loan_info.IncomeCheckResult;
            AdditionalIncome = setScaleForDecimal(affordability_response_loan_info.AdditionalIncome);
            MonthlyNetIncome = setScaleForDecimal(affordability_response_loan_info.MonthlyNetIncome);
            RentMortgage = setScaleForDecimal(affordability_response_loan_info.RentMortgage);
            ConfirmedRentMortgage = setScaleForDecimal(affordability_response_loan_info.ConfirmedRentMortgage);
            TotalMonthlyRepaymentAmount = setScaleForDecimal(affordability_response_loan_info.TotalMonthlyRepaymentAmount);
            TotalUnsecuredDebtAmount = setScaleForDecimal(affordability_response_loan_info.TotalUnsecuredDebtAmount);
            DisposableIncome = setScaleForDecimal(affordability_response_loan_info.DisposableIncome);
            DebtToIncome = affordability_response_loan_info.DebtToIncome;
            LowDebtToIncome = affordability_response_loan_info.LowDebtToIncome;
            BureauMortgage = affordability_response_loan_info.Mortgage;
            checkRangesOfIncome();
            setRollingCreditLinesAndUnsecuredDebt(affordability_response_loan_info);
        }else{
            RollingCreditLines = new List<RollingCreditLine>();
            UnsecuredDebts = new List<UnsecuredDebt>();
        }
    }

    @TestVisible
    private void setCompanyClassOptions(){
        CompanyClassOptions = new List<SelectOption>();
        Map<String, Company_Class_Options_MU__c> company_class_settings = Company_Class_Options_MU__c.getAll();
        CompanyClassOptions.add(new SelectOption('Unknown', 'Unknown'));
        for(Company_Class_Options_MU__c field : company_class_settings.values()){
            if(field.Name != 'Unknown'){
                CompanyClassOptions.add(new SelectOption(field.Zopa_Value__c, field.Name));
            }
        }
        CompanyClassOptions = sortSelectOptions(CompanyClassOptions);
    }

    @TestVisible
    private void setAccountTypeOption(){
        AccountTypeOptionUnsecuredDebts = new List<SelectOption>();
        AccountTypeOptionRollingCredit = new List<SelectOption>();

        Map<String, Account_Type_Option_MU__c> account_type_settings = Account_Type_Option_MU__c.getAll();
        AccountTypeOptionUnsecuredDebts.add(new SelectOption('Unknown', 'Unknown'));
        AccountTypeOptionRollingCredit.add(new SelectOption('Unknown', 'Unknown'));
        for(Account_Type_Option_MU__c field : account_type_settings.values()){
            if(field.Name != 'Unknown'){
                if(field.Row_Type__c == 'Both' || field.Row_Type__c == 'UnsecuredDebts'){
                    AccountTypeOptionUnsecuredDebts.add(new SelectOption(field.Zopa_Value__c, field.Name));
                }
                if(field.Row_Type__c == 'Both' || field.Row_Type__c == 'RollingCredit'){
                    AccountTypeOptionRollingCredit.add(new SelectOption(field.Zopa_Value__c, field.Name));
                }
            }
        }
        AccountTypeOptionUnsecuredDebts = sortSelectOptions(AccountTypeOptionUnsecuredDebts);
        AccountTypeOptionRollingCredit = sortSelectOptions(AccountTypeOptionRollingCredit);
    }

    private List<SelectOption> sortSelectOptions(List<SelectOption> sorting_list) {
        for (Integer i =0; i < sorting_list.size(); i++) {
            for (Integer j = i; j > 0; j--) {
                if (sorting_list[j-1].getLabel() > sorting_list[j].getLabel()){
                    SelectOption temp = sorting_list[j];
                    sorting_list[j] = sorting_list[j-1];
                    sorting_list[j-1] = temp;
                }
            }
        }
        return sorting_list;
    }

    @TestVisible
    private Decimal setScaleForDecimal(Decimal value){
        if(value != null){
            value = value.setScale(2);
        }
        return value;
    }

    private void setRollingCreditLinesAndUnsecuredDebt(ApiResponseLoanCommonInformation.FullAffordabilityDetails affordability_response_loan_info){
        RollingCreditLines = new List<RollingCreditLine>();
        CompanyClassSettings = Company_Class_Options_MU__c.getAll();
        AccountTypeSettings = Account_Type_Option_MU__c.getAll();
        for(ApiResponseLoanCommonInformation.RollingCreditLine rolling_credit_line : affordability_response_loan_info.RollingCreditLines){
            if(rolling_credit_line.Source != 'Underwriter'){
                rolling_credit_line.CompanyClass = translateCompanyClass(rolling_credit_line.CompanyClass);
                rolling_credit_line.AccountType = translateAccountType(rolling_credit_line.AccountType);
            }
            RollingCreditLine rolling_credit_line_row = new RollingCreditLine(rolling_credit_line.CompanyClass, rolling_credit_line.AccountType, rolling_credit_line.Source, rolling_credit_line.Total, rolling_credit_line.Monthly);
            RollingCreditLines.add(rolling_credit_line_row);
        }
        setRollingCreditLinesRowsIndex();

        UnsecuredDebts = new List<UnsecuredDebt>();
        for(ApiResponseLoanCommonInformation.UnsecuredDebt unsecured_debt : affordability_response_loan_info.UnsecuredDebts){
            if(unsecured_debt.Source != 'Underwriter'){
                unsecured_debt.CompanyClass = translateCompanyClass(unsecured_debt.CompanyClass);
                unsecured_debt.AccountType = translateAccountType(unsecured_debt.AccountType);
            }
            UnsecuredDebt unsecured_debt_row = new UnsecuredDebt(unsecured_debt.Monthly, unsecured_debt.CompanyClass, unsecured_debt.AccountType, unsecured_debt.Source, unsecured_debt.Total);
            UnsecuredDebts.add(unsecured_debt_row);
        }
        setUnsecuredDebtsRowsIndex();
    }

    private String translateCompanyClass(String zopa_company_class){
        for(Company_Class_Options_MU__c field : CompanyClassSettings.values()){
            if(field.Zopa_Value__c == zopa_company_class){
                return field.Name;
            }
        }
        return zopa_company_class;
    }

    private String translateAccountType(String zopa_account_type){
        for(Account_Type_Option_MU__c field : AccountTypeSettings.values()){
            if(field.Zopa_Value__c == zopa_account_type){
                return field.Name;
            }
        }
        return zopa_account_type;
    }

    private void setRollingCreditLinesRowsIndex(){
        for(Integer i = 0; i < RollingCreditLines.size(); i++){
            RollingCreditLines.get(i).Index = i;
        }
    }

    private void setUnsecuredDebtsRowsIndex(){
        for(Integer i = 0; i < UnsecuredDebts.size(); i++){
            UnsecuredDebts.get(i).Index = i;
        }
    }

    public void addRollingCreditLinesRow(){
        RollingCreditLine monthly_payment_row = new RollingCreditLine();
        RollingCreditLines.add(monthly_payment_row);
        setRollingCreditLinesRowsIndex();
    }

    public void addUnsecuredDebtsRow(){
        UnsecuredDebt unsecured_debt_row = new UnsecuredDebt();
        UnsecuredDebts.add(unsecured_debt_row);
        setUnsecuredDebtsRowsIndex();
    }

    public void removeRollingCreditLinesRow(){
        Integer row_index = Integer.valueOf(RowIndexToRemove);
        RollingCreditLines.remove(row_index);
        setRollingCreditLinesRowsIndex();
    }

    public void removeUnsecuredDebtsRow(){
        Integer row_index = Integer.valueOf(RowIndexToRemove);
        UnsecuredDebts.remove(row_index);
        setUnsecuredDebtsRowsIndex();
    }

    public Boolean getIsZopa78IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-78').isFeatureEnabled();
    }

    public Boolean getIsZopa79IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-79').isFeatureEnabled();
    }

    public Boolean getIsIncomeCheckPass(){
        if(IncomeCheckResult == null){
            return false;
        }
        return IncomeCheckResult.toLowerCase() == 'pass';
    }

    public void calculateAffordabilityDetails() {
        translateCompanyClassAndAccountType();
        if(validateInput()){
            ApiCommandCalculateAffordability calculate_affordability_command = new ApiCommandCalculateAffordability(LoanAppId, ConfirmedAnnualIncome, MonthlyNetIncome, ConfirmedRentMortgage, RollingCreditLines, UnsecuredDebts);
            ApiCommandsFactory.getInstance().performApiCommandCallout(calculate_affordability_command);
            if(calculate_affordability_command.CommandSuccessful){
                ApiCommandCalculateAffordability.AffordabilityCalculationResponse affordability_response_loan_info = calculate_affordability_command.getResponse();
                setCalculateResponse(affordability_response_loan_info);
            } else {
                MessageUtility.addErrorPageMessage(calculate_affordability_command.CommandError);
            }
        }
    }

    @TestVisible
    private void setCalculateResponse(ApiCommandCalculateAffordability.AffordabilityCalculationResponse affordability_response_loan_info){
        LowDebtToIncome = affordability_response_loan_info.LDTI;
        DebtToIncome = affordability_response_loan_info.DTI;
        DisposableIncome = affordability_response_loan_info.DI;
        checkRangesOfIncome();
    }

    private void checkRangesOfIncome(){
        IsWarningDI = false;
        IsWarningLDTI = false;
        IsWarningDTI = false;
        if(LowDebtToIncome >= 60){
            IsWarningLDTI = true;
        }
        if(DebtToIncome >=100){
            IsWarningDTI = true;
        }
        if(DisposableIncome <= 450){
            IsWarningDI = true;
        }
    }

    public void updateAffordabilityDetails() {
        translateCompanyClassAndAccountType();
        if(validateInput()){
            ApiCommandUpdateAffordability update_affordability_command = new ApiCommandUpdateAffordability(LoanAppId, ConfirmedAnnualIncome, MonthlyNetIncome, ConfirmedRentMortgage, RollingCreditLines, UnsecuredDebts);
            ApiCommandsFactory.getInstance().performApiCommandCallout(update_affordability_command);
            if(update_affordability_command.CommandSuccessful){
                MessageUtility.addConfirmPageMessage('Affordability details updated successfully');
                AgentActionsRecorder.getInstance(AgentActionsRecorder.Action.UPDATE_AFFORDABILITY).record((Id)LoanInternalId);
            } else {
                MessageUtility.addErrorPageMessage(update_affordability_command.CommandError);
            }
        }
    }

    public void translateCompanyClassAndAccountType(){
        CompanyClassSettings = Company_Class_Options_MU__c.getAll();
        AccountTypeSettings = Account_Type_Option_MU__c.getAll();
        for(RollingCreditLine rolling_credit_line : RollingCreditLines){
            if(CompanyClassSettings.containsKey(rolling_credit_line.CompanyClass)){
                rolling_credit_line.CompanyClass = CompanyClassSettings.get(rolling_credit_line.CompanyClass).Zopa_Value__c;
            }
            if(AccountTypeSettings.containsKey(rolling_credit_line.AccountType)){
                rolling_credit_line.AccountType = AccountTypeSettings.get(rolling_credit_line.AccountType).Zopa_Value__c;
            }
        }
        for(UnsecuredDebt unsecured_debt : UnsecuredDebts){
            if(CompanyClassSettings.containsKey(unsecured_debt.CompanyClass)){
                unsecured_debt.CompanyClass = CompanyClassSettings.get(unsecured_debt.CompanyClass).Zopa_Value__c;
            }
            if(AccountTypeSettings.containsKey(unsecured_debt.AccountType)){
                unsecured_debt.AccountType = AccountTypeSettings.get(unsecured_debt.AccountType).Zopa_Value__c;
            }
        }
    }

    private Boolean validateInput(){
        Boolean all_fields_are_valid = true;
        if(ErrorOnLoad != null){
            MessageUtility.addErrorPageMessage('Can\'t process information due to an error retriving the data');
            all_fields_are_valid = false;
        } else {
            if(ConfirmedAnnualIncome == null){
                MessageUtility.addErrorPageMessage('You must enter Verified Gross Annual Income');
                all_fields_are_valid = false;
            }
            if(MonthlyNetIncome == null){
                MessageUtility.addErrorPageMessage('You must enter Monthly Net Income');
                all_fields_are_valid = false;
            }
            for(RollingCreditLine monthly_payment : RollingCreditLines){
                if(monthly_payment.Total == null){
                    MessageUtility.addErrorPageMessage('You must enter Total value for Rolling Credit Line in row ' + String.valueOf(monthly_payment.Index + 1));
                    all_fields_are_valid = false;
                }
            }

            for(UnsecuredDebt unsecured_debt : UnsecuredDebts){
                if(unsecured_debt.Total == null){
                    MessageUtility.addErrorPageMessage('You must enter Total for Unsecured Debt in row ' + String.valueOf(unsecured_debt.Index + 1));
                    all_fields_are_valid = false;
                }
                if(unsecured_debt.Monthly == null){
                    MessageUtility.addErrorPageMessage('You must enter a Monthly value for Unsecured Debt in row ' + String.valueOf(unsecured_debt.Index + 1));
                    all_fields_are_valid = false;
                }
            }
        }
        return all_fields_are_valid;
    }

    public class RollingCreditLine {
        public String CompanyClass {get; set;}
        public String AccountType {get; set;}
        public String Source {get; set;}
        public Decimal Total {get; set;}
        public Decimal Monthly {get{
            if(Total != null){
                Decimal monthly_payment = Total * 0.05;
                Monthly = monthly_payment.setScale(2);
                return monthly_payment.setScale(2);
            }
            return null;
            } set;}

        public Integer Index {get; set;}

        public RollingCreditLine(){
            Source = 'Underwriter';
            AccountType = 'Unknown';
            CompanyClass = 'Unknown';
        }

        public RollingCreditLine(String company_class, String account_type, String source, Decimal total, Decimal monthly){
            this.CompanyClass = company_class;
            this.AccountType = account_type;
            this.Source = source;
            this.Total = total;
            this.Monthly = monthly;
        }
    }

    public class UnsecuredDebt {
        public Decimal Monthly {get; set;}
        public String CompanyClass {get; set;}
        public String AccountType {get; set;}
        public String Source {get; set;}
        public Decimal Total {get; set;}
        public Integer Index {get; set;}

        public UnsecuredDebt(){
            Source = 'Underwriter';
            AccountType = 'Unknown';
            CompanyClass = 'Unknown';
        }

        public UnsecuredDebt(Decimal monthly, String company_class, String account_type, String source, Decimal total){
            this.Monthly = monthly;
            this.CompanyClass = company_class;
            this.AccountType = account_type;
            this.Source = source;
            this.Total = total;
        }
    }
}