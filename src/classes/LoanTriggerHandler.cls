public with sharing class LoanTriggerHandler extends TriggerHandler implements LoanTriggerHandler.ITrigger{

    public LoanTriggerHandler(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, List<SObject> oldList, List<SObject> newList){
        super(oldMap, newMap, oldList, newList);
    }

    public void bulkBefore(){
        if(Trigger.isInsert && FeatureSwitch.getSwitch('ZCP-128').isFeatureEnabled()){
            LoanToAccountLinker.getInstance().getAllAccountIdsByMemberIds((List<Loan__c>)newList);
        }
        if(Trigger.isUpdate && FeatureSwitch.getSwitch('ZCP-104').isFeatureEnabled()){
            CreateCollectionsRecoveriesCaseHandler.getOpenCasesFromExistingLoans(newMap.keySet());
        }
    }

    public void bulkAfter(){
        CreateCollectionsRecoveriesCaseHandler.listCollectionsRecoveriesCase = new List<Case>();
        if(Trigger.isUpdate){
            LoanStateChangedHandler.createChatterPostsForLoansWithChangedState((List<Loan__c>) oldList, (List<Loan__c>) newList);
        }
    }

    public void beforeInsert(SObject so){
        if(FeatureSwitch.getSwitch('ZCP-128').isFeatureEnabled()){
            LoanToAccountLinker.getInstance().setAccountIdForLoan((Loan__c)so);
        }
    }

    public void beforeUpdate(SObject oldSo, SObject so){
        if (FeatureSwitch.getSwitch('ZOPA-195').isFeatureEnabled()){
            LoanArrearsRatioManager.checkArrearsRatio(oldSo, so);
        }
    }

    public void beforeDelete(SObject so){}

    public void afterInsert(SObject so){
        Loan__c the_loan = (Loan__c)so;
        if(FeatureSwitch.getSwitch('ZCP-104').isFeatureEnabled()){
            CreateCollectionsRecoveriesCaseHandler.handleArrearsRatioOnChangeOnLoan(the_loan);
        }
        if (LoanStatusChecker.isClosedStatus(the_loan.State__c)){
            LoanStatusChecker.LoanIdWithClosedtStatus.add(the_loan.id);
        }
    }

    public void afterUpdate(SObject oldSo, SObject so){
        Loan__c the_old_loan = (Loan__c)oldSo;
        Loan__c the_new_loan = (Loan__c)so;
        MissedPlanPaymentHandler.getInstance().checkIsChangedDateOfLastMissedPlanPayment(the_old_loan, the_new_loan);
        if (CreateCollectionsRecoveriesCaseHandler.isChanged(the_old_loan.Arrears_Ratio__c, the_new_loan.Arrears_Ratio__c) && FeatureSwitch.getSwitch('ZCP-104').isFeatureEnabled()){
            CreateCollectionsRecoveriesCaseHandler.handleArrearsRatioOnChangeOnLoan(the_new_loan);
        }
        if (CreateCollectionsRecoveriesCaseHandler.isChanged(the_old_loan.State__c,the_new_loan.State__c) && LoanStatusChecker.isClosedStatus(the_new_loan.State__c) && FeatureSwitch.getSwitch('ZCP-104').isFeatureEnabled()){
            LoanStatusChecker.LoanIdWithClosedtStatus.add(the_new_loan.id);
        }
        if (FeatureSwitch.getSwitch('ZOPA-135').isFeatureEnabled()){
            DcaAccountLinkingHandler.getInstance().checkIsChangedDCA(oldSo, so);
        }
    }

    public void afterDelete(SObject so){}

    public void postProcessing(){
        MissedPlanPaymentHandler.getInstance().updateCasesWithMissedPayments();
        Set<Id> set_loans_id = new Set<id>();
        set_loans_id.addAll(LoanStatusChecker.LoanIdWithClosedtStatus);
        CreateCollectionsRecoveriesCaseHandler.changeCaseRelatedToLoan(set_loans_id);
        if (FeatureSwitch.getSwitch('ZOPA-135').isFeatureEnabled() && Trigger.isUpdate){
            DcaAccountLinkingHandler.getInstance().updateRelatedRecordDCALookup();
        }
        CreateCollectionsRecoveriesCaseHandler.upsertCollectionsRecoveriesCases();
    }
}