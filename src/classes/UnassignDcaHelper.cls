global class UnassignDcaHelper {

    @InvocableMethod(label='Unassign DCA on current case')
    global static void changeCasesAfterUnassignDca(List<id> loans_id) {
        List<Case> cases = [SELECT id, Process__c, Sub_Process__c, Loan__c, Status, OwnerId, AccountDCA__c FROM Case WHERE Loan__c IN :loans_id AND IsClosed = false];
        List<Loan__c> loans = [SELECT id, Loan_id__c FROM Loan__c WHERE id IN :loans_id];
        changeCases(cases);
        changeCollectionAgencyOnZopa(loans);
    }

    private static void changeCases(List<Case> cases){
        for(Case current_case: cases){
            current_case.Status = 'Open - Need to Contact';
            current_case.AccountDCA__c = null;
            if(current_case.Process__c == CaseUtility.CASE_PROCESS_COLLECTIONS){
                current_case.Sub_Process__c = 'Collections';
                current_case.OwnerId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.COLLECTIONS_PRIORITY_1);
            } else if(current_case.Process__c == CaseUtility.CASE_PROCESS_RECOVERIES){
                current_case.Sub_Process__c = 'Litigation';
                current_case.OwnerId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.LITIGATION_REVIEW);
            }
        }
        update cases;
    }

    private static void changeCollectionAgencyOnZopa(List<Loan__c> loans){
        for(Loan__c current_loan: loans){
            CollectionAgencyCommandHelper.sendCollectionsAgencyToZopaAsynchWithoutDcaId(current_loan.Loan_Id__c);
        }
    }
}