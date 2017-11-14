public class LoanDuplicatesFixBatch implements Database.Batchable<SObject>, Database.Stateful {
    Map<String, Loan__c> valid_loans = new Map<String, Loan__c>();
    List<Loan__c> dup_loans = new List<Loan__c>();
    Boolean delete_duplicates;
    
    public LoanDuplicatesFixBatch () {
        this(false);
    }
    
    public LoanDuplicatesFixBatch (Boolean delete_duplicates) {
        this.delete_duplicates = delete_duplicates;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id, Loan_Id__c, CreatedDate From Loan__c WHERE Loan_Id__c != null');
    }

    public void execute(Database.BatchableContext BC, List<Loan__c> scope){
        for(Loan__c loan : scope){
            if(valid_loans.containsKey(loan.Loan_Id__c.toUpperCase())) {
                Loan__c current_valid_loan = valid_loans.get(loan.Loan_Id__c.toUpperCase());
                if(current_valid_loan.CreatedDate < loan.CreatedDate) {
                    dup_loans.add(loan);
                } else {
                    dup_loans.add(current_valid_loan);
                    valid_loans.put(loan.Loan_Id__c.toUpperCase(), loan);
                }
            } else {
                valid_loans.put(loan.Loan_Id__c.toUpperCase(), loan);
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        String email_body = '';        
        if(dup_loans.isEmpty()) {
            email_body += 'Duplicates not found!';
        } else {
            email_body += 'Found ' + dup_loans.size() + ' duplicates!';
        }
        
        if(delete_duplicates) {
            if(!dup_loans.isEmpty()) {
                if(dup_loans.size() > 5000) {
                    for(Integer i = dup_loans.size() - 1; i >= 5000; i--) {
                        dup_loans.remove(i);
                    }
                }
                delete dup_loans;
                email_body += '\n' + dup_loans.size() + ' Duplicates deleted successfully!';
            }
        } else {
            email_body += '\nDuplicates Report:';
            email_body += '\n\nDuplicate Id, Duplicate ExternalId, Original Id, Original ExternalId';
            for(Loan__c dup_loan : dup_loans) {
                Loan__c valid_loan = valid_loans.get(dup_loan.Loan_Id__c.toUpperCase());
                email_body += '\n'+ dup_loan.Id + ', ' + dup_loan.Loan_Id__c + ', ' + valid_loan.Id + ', ' + valid_loan.Loan_Id__c;
            }
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
        email.setSaveAsActivity(false);
        email.setSubject('Duplicates report');
        email.setPlainTextBody(email_body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}