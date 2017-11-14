public with sharing class LoanArrearsRatioManager {

    public static void checkArrearsRatio(SObject old_record, SObject new_record){
        Loan__c old_loan = (Loan__c) old_record;
        Loan__c new_loan = (Loan__c) new_record;
        if(isChangedArrearsRatio(old_loan, new_loan)){
            if(new_loan.Arrears_Ratio__c >= 4){
                new_loan.AccountDca__c = null;
            }
        }
    }

    private static Boolean isChangedArrearsRatio(Loan__c old_loan, Loan__c new_loan){
        return old_loan.Arrears_Ratio__c != new_loan.Arrears_Ratio__c;
    }
}