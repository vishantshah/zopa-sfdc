public class LoanLitigationDetailsEditController extends LoanLitigationDetailsController{
    public static final List<String> ADDITIONAL_FIELDS_TO_QUERY = new List<string>{'Loan_id__c'};
    public LoanLitigationDetailsEditWrapper LoanLitigationDetailsEdit {get; set;}
    public Boolean IsEditeble {get;set;}

    public LoanLitigationDetailsEditController(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(ADDITIONAL_FIELDS_TO_QUERY);
        }
        IsEditeble = false;
        Loan__c the_loan = (Loan__c)controller.getRecord();
        LoanUuid = the_loan.Loan_id__c;
        getLitigationDetails();
        if (CurrentLoanLitigationDetails != null){
            LoanLitigationDetailsEdit = new LoanLitigationDetailsEditWrapper(CurrentLoanLitigationDetails);
        }
    }

    public void makeEditableFields(){
        if (IsEditeble == true){
            updateLitigationDetails();
        } else {
            IsEditeble = true;
        }
    }

    public void updateLitigationDetails(){
        if (validateField() && ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(LoanUuid)) {
            ApiCommandLoanLitigationEdit command = new ApiCommandLoanLitigationEdit(LoanUuid, LoanLitigationDetailsEdit);
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(command);
            if (command.CommandSuccessful) {
                MessageUtility.addInfoPageMessage('Loan Litigation Details was successfully updated');
                IsEditeble = false;
            } else {
                MessageUtility.addFatalPageMessage(command.CommandError);
            }
        }
    }

    private Boolean validateField (){
        LoanLitigationDetailsEdit.CountyCourtClaimNumber = LoanLitigationDetailsEdit.CountyCourtClaimNumber.deleteWhitespace();
        Pattern correct_integer_pattern = Pattern.compile('\\d{1,}');
        Boolean result = correct_integer_pattern.matcher(LoanLitigationDetailsEdit.CountyCourtClaimNumber).matches();

        return result;
    }

    public class LoanLitigationDetailsEditWrapper{
        public Loan__c ContainerForDefaultNotice {get; set;}
        public Loan__c ContainerForClaimIssued {get; set;}
        public Loan__c ContainerForDateOfDefault {get; set;}
        public Loan__c ContainerForDefendantDeadline {get; set;}
        public Loan__c ContainerForAssignment {get; set;}
        public Loan__c ContainerForJudgmentRequested {get; set;}
        public Loan__c ContainerForLbaSent {get; set;}
        public Loan__c ContainerForJudgmentObtained {get; set;}
        public Loan__c ContainerForClaimSentToCourt {get; set;}
        public Loan__c ContainerForEnforcementCommenced {get; set;}
        public Decimal OriginalCourtFees {get; set;}
        public Loan__c ContainerForWarrantIssued {get; set;}
        public Decimal OutstandingCourtFees {get; set;}
        public Loan__c ContainerForFinalReturn {get; set;}
        public String CountyCourtClaimNumber {get; set;}

        public LoanLitigationDetailsEditWrapper (LoanLitigationDetailsWrapper Current_LoanLitigationDetails){
            this.ContainerForDefaultNotice = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.DefaultNotice));
            this.ContainerForClaimIssued = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.ClaimIssued));
            this.ContainerForDateOfDefault = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.DateOfDefault));
            this.ContainerForDefendantDeadline = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.DefendantDeadline));
            this.ContainerForAssignment = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.Assignment));
            this.ContainerForJudgmentRequested = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.JudgmentRequested));
            this.ContainerForLbaSent = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.LbaSent));
            this.ContainerForJudgmentObtained = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.JudgmentObtained));
            this.ContainerForClaimSentToCourt = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.ClaimSentToCourt));
            this.ContainerForEnforcementCommenced = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.EnforcementCommenced));
            this.OriginalCourtFees = Current_LoanLitigationDetails.OriginalCourtFees;
            this.ContainerForWarrantIssued = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.WarrantIssued));
            this.OutstandingCourtFees = Current_LoanLitigationDetails.OutstandingCourtFees;
            this.ContainerForFinalReturn = new Loan__c (Start_Date__c = parseStringToDate(Current_LoanLitigationDetails.FinalReturn));
            this.CountyCourtClaimNumber = Current_LoanLitigationDetails.CountyCourtClaimNumber.deleteWhitespace();
        }

        private Date parseStringToDate(String string_date) {
            Date result_date;
            try {
                if (!String.isBlank(string_date)){
                    result_date = Date.newInstance(Integer.valueOf(string_date.substring(6,10)), Integer.valueOf(string_date.substring(3,5)), Integer.valueOf(string_date.substring(0,2)));
                }
            } catch (Exception ex){}
            return result_date;
        }
    }
}