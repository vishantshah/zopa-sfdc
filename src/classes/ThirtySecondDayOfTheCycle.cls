global class ThirtySecondDayOfTheCycle {
    @TestVisible private static Id DcaAccountId;
    @TestVisible private static Id CaseOwnerId;
    @TestVisible private static String DcaUuid;

    @InvocableMethod(label='Change Case after Thirty Second Day Of The Cycle')
    global static void changeCasesAfterThirtyDayOfTheCycle(List<ConvertCaseActionRequest> requests) {
        Set<Id> set_case_id = new Set<Id>();
        Set<Id> set_loan_id = new Set<Id>();
        for (convertCaseActionRequest request: requests) {
            set_case_id.add(request.TheCase.Id);
            set_loan_id.add(request.TheCase.Loan__c);
        }
        setDcaAccountId(requests[0].NameDCA);
        setCaseOwnerId(requests[0].OwnerName);
        List<Loan__c> list_loans = [SELECT id, AccountDCA__c, AccountDCA__r.DCA_Id__c, Loan_id__c, State__c FROM Loan__c WHERE id IN :set_loan_id];
        List<Case> list_cases = [SELECT id, OwnerId, AccountDCA__c, CreatedDate, Default_Notice_Sent_Date__c, Loan__c FROM Case WHERE id IN :set_case_id];
        changeOwnerAndDcaCases(list_cases);
        changeDcaLoans(list_loans);
        sendCollectionsAgencyToZopaAfterThirtySecondDay(list_loans, list_cases);
    }

    @TestVisible
    private static void setDcaAccountId(String name_dca_account){
        List<Account> dca_accounts = [SELECT Id, DCA_Id__c From Account WHERE Name = :name_dca_account LIMIT 1];
        if (dca_accounts.size() != 0){
            DcaAccountId = dca_accounts[0].id;
            DcaUuid = dca_accounts[0].DCA_Id__c;
        }
    }

    @TestVisible
    private static void setCaseOwnerId(String owner_name){
        List<Group> the_groups = [SELECT Id FROM Group WHERE Name = :owner_name and Type = 'Queue' LIMIT 1];
        if (the_groups.size() != 0){
            CaseOwnerId = the_groups[0].id;
        }
    }

    @TestVisible
    private static void changeOwnerAndDcaCases(List<Case> list_cases){
        if (list_cases.size() != 0) {
            for (Case current_case: list_cases){
                current_case.OwnerId = CaseOwnerId;
                current_case.AccountDCA__c = DcaAccountId;
            }
            update list_cases;
        }
    }

    @TestVisible
    private static void changeDcaLoans(List<Loan__c> list_loans){
        if (list_loans.size() != 0) {
            for (Loan__c current_loan: list_loans){
                current_loan.AccountDCA__c = DcaAccountId;
            }
            update list_loans;
        }
    }

    private static void sendCollectionsAgencyToZopaAfterThirtySecondDay(List<Loan__c> list_loans, List<Case> list_cases) {
        Map<String, Datetime> map_loan_uuid_to_default_date = createMapLoanUuidToDefaultDate(list_loans, list_cases);
        CollectionAgencyCommandHelper.sendBulkPostsCollectionsAgencyToZopa(DcaUuid, map_loan_uuid_to_default_date);
    }

    @TestVisible
    private static Map<String, Datetime> createMapLoanUuidToDefaultDate(List<Loan__c> list_loans, List<Case> list_cases){
        Map<String, Datetime> map_loan_uuid_to_default_date = new Map<String, Datetime>();
        for (Loan__c current_loan: list_loans){
            for (Case current_case: list_cases){
                if (current_loan.Id == current_case.Loan__c){
                    if(current_loan.State__c == 'Default'){
                        map_loan_uuid_to_default_date.put(current_loan.Loan_Id__c, current_case.Default_Notice_Sent_Date__c);
                    } else {
                        map_loan_uuid_to_default_date.put(current_loan.Loan_Id__c, current_case.CreatedDate);
                    }
                }
            }
        }
        return map_loan_uuid_to_default_date;
    }

    global class ConvertCaseActionRequest {
        @InvocableVariable(required=true)
        global Case TheCase;

        @InvocableVariable(required=true)
        global String OwnerName;

        @InvocableVariable(required=true)
        global String NameDCA;
    }
}