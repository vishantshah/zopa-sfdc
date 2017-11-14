public with sharing class LoanApplicationTriggerHandler extends TriggerHandler implements LoanApplicationTriggerHandler.ITrigger{

    public LoanApplicationTriggerHandler(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, List<SObject> oldList, List<SObject> newList){
        super(oldMap, newMap, oldList, newList);
    }

    public void bulkBefore(){
        if (Trigger.isUpdate && FeatureSwitch.getSwitch('ZOPA-82').isFeatureEnabled()) {
            AutoClosingUnderwritingCase.getInstance().handleOldLoanApplicationsAndPrepareCasesToUpdate((Map<Id,Loan_Application__c>)oldMap, (Map<Id,Loan_Application__c>)newMap);
        }
    }

    public void bulkAfter(){
        if (Trigger.isUpdate && FeatureSwitch.getSwitch('ZOPA-4').isFeatureEnabled()) {
            ManualUnderwritingCaseHandler.getInstance().queryUnderwritingCasesForOldLoan(Trigger.oldMap);
        }
        if (Trigger.isInsert && FeatureSwitch.getSwitch('ZOPA-4').isFeatureEnabled()) {
            ManualUnderwritingCaseHandler.getInstance().queryAccountEmailForManualunderwritingCase(Trigger.newMap);
        }
        if (Trigger.isUpdate && FeatureSwitch.getSwitch('ZOPA-130').isFeatureEnabled()) {
            CaseAssignmentHandler.getInstance().queryUnderwritingCasesForOldLoan(Trigger.oldMap);
        }
        if (Trigger.isUpdate && FeatureSwitch.getSwitch('ZOPA-72').isFeatureEnabled()) {
            DocumentReceivedFromIntegrationHandler.getInstance().queryUnderwritingCasesForOldLoan(Trigger.oldMap);
        }
    }

    public void beforeInsert(SObject so){}

    public void beforeUpdate(SObject oldSo, SObject so){
    }

    public void beforeDelete(SObject so){}

    public void afterInsert(SObject so){
        if (FeatureSwitch.getSwitch('ZOPA-4').isFeatureEnabled()) {
            ManualUnderwritingCaseHandler.getInstance().createManualUnderwitingCaseForNewLoan((Loan_Application__c)so);
        }
    }

    public void afterUpdate(SObject oldSo, SObject so){
        if (Trigger.isUpdate && FeatureSwitch.getSwitch('ZOPA-130').isFeatureEnabled()) {
            CaseAssignmentHandler.getInstance().updateManualUnderwitingCaseForOldLoan((Loan_Application__c)oldSo, (Loan_Application__c)so);
        }
        if (FeatureSwitch.getSwitch('ZOPA-4').isFeatureEnabled()) {
            ManualUnderwritingCaseHandler.getInstance().updateManualUnderwitingCaseForOldLoan((Loan_Application__c)oldSo, (Loan_Application__c)so);
        }
        if (FeatureSwitch.getSwitch('ZOPA-72').isFeatureEnabled()) {
            DocumentReceivedFromIntegrationHandler.getInstance().updateManualUnderwitingCaseForOldLoan((Loan_Application__c)oldSo, (Loan_Application__c)so);
        }
        if (FeatureSwitch.getSwitch('ZOPA-180').isFeatureEnabled()) {
            ManualUnderwritingCaseHandler.getInstance().checkIfLoanApplicationIsPickedUpInAdminSystem((Loan_Application__c)oldSo, (Loan_Application__c)so);
        }
    }

    public void afterDelete(SObject so){}

    public void postProcessing(){
        if (Trigger.isUpdate && FeatureSwitch.getSwitch('ZOPA-130').isFeatureEnabled()) {
            CaseAssignmentHandler.getInstance().updateAllCases();
        }
        if (FeatureSwitch.getSwitch('ZOPA-4').isFeatureEnabled()) {
            ManualUnderwritingCaseHandler.getInstance().upsertAllCases();
        }
        if (FeatureSwitch.getSwitch('ZOPA-72').isFeatureEnabled()) {
            DocumentReceivedFromIntegrationHandler.getInstance().updateAllCasesAndSendEmails();
        }
        if (FeatureSwitch.getSwitch('ZOPA-82').isFeatureEnabled()) {
            AutoClosingUnderwritingCase.getInstance().updateCases();
        }
        if (FeatureSwitch.getSwitch('ZOPA-180').isFeatureEnabled()) {
            ManualUnderwritingCaseHandler.getInstance().takeManualUnderwritingCasesOutOfTheQueues();
        }
    }
}