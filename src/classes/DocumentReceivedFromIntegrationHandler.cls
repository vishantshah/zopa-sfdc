public with sharing class DocumentReceivedFromIntegrationHandler {
    private static DocumentReceivedFromIntegrationHandler Singleton;
    @TestVisible private List<Case> AllCasesToUpdate;
    @TestVisible private List<Messaging.SingleEmailMessage> AllMessagesToSend;
    @TestVisible private Map<Id, Case> LoanIdToUnderwritingCaseToUpdate;

    public static DocumentReceivedFromIntegrationHandler getInstance(){
        if (Singleton == null) {
            Singleton = new DocumentReceivedFromIntegrationHandler();
        }
        return Singleton;
    }

    private DocumentReceivedFromIntegrationHandler() {
        AllCasesToUpdate = new List<Case>();
        AllMessagesToSend = new List<Messaging.SingleEmailMessage>();
        LoanIdToUnderwritingCaseToUpdate = new Map<Id, Case>();
    }

    public void updateAllCasesAndSendEmails() {
        if (AllCasesToUpdate.size() > 0) {
            update AllCasesToUpdate;
            AllCasesToUpdate.clear();
        }
        if (AllMessagesToSend.size() > 0) {
            Messaging.sendEmail(AllMessagesToSend, false);
            AllMessagesToSend.clear();
        }
    }

    public void queryUnderwritingCasesForOldLoan(Map<Id, sObject> old_loan_map) {
        LoanIdToUnderwritingCaseToUpdate = new Map<Id, Case>();
        for (Case underwriting_case : [SELECT Status, Loan_Application__c, Owner.ProfileId, OwnerId, Owner.FirstName, Account.Name, CaseNumber, IsClosed
                                    FROM Case WHERE Loan_Application__c in :old_loan_map.keyset()
                                    AND Is_Case_Currently_Locked__c = false
                                    AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING) FOR UPDATE]) {
            if (!LoanIdToUnderwritingCaseToUpdate.containsKey(underwriting_case.Loan_Application__c)) {
                LoanIdToUnderwritingCaseToUpdate.put(underwriting_case.Loan_Application__c, underwriting_case);
            }
        }
    }

    public void updateManualUnderwitingCaseForOldLoan(Loan_Application__c old_loan, Loan_Application__c new_loan) {
        Case manual_underwriting_case = LoanIdToUnderwritingCaseToUpdate.get(old_loan.Id);
        if (manual_underwriting_case != null && isDocumentsLastUploadedFieldUpdated(old_loan, new_loan) && !manual_underwriting_case.isClosed) {
            updateStatusToDocumentRecievedAndAddToTheAllCases(manual_underwriting_case);
            if (isOwnedByCasePrepPendingQueue(manual_underwriting_case.OwnerId)) {
                addAssignmentRuleOption(manual_underwriting_case);
            } else if (isOwnedByUser(manual_underwriting_case.Owner.ProfileId)) {
                addEmailNotificationEmail(manual_underwriting_case);
            }
        } else if (manual_underwriting_case != null && isDocumentsLastUploadedFieldUpdated(old_loan, new_loan) && manual_underwriting_case.isClosed && isOwnedByUser(manual_underwriting_case.Owner.ProfileId)) {
            addEmailNotificationEmail(manual_underwriting_case);
        }
    }

    private Boolean isDocumentsLastUploadedFieldUpdated(Loan_Application__c old_loan, Loan_Application__c new_loan) {
        return old_loan.Documents_Last_Updated_Date__c != new_loan.Documents_Last_Updated_Date__c;
    }

    private void addAssignmentRuleOption(Case parent_case) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_CASE_PREP);
        parent_case.setOptions(dmo);
    }

    @TestVisible
    private void updateStatusToDocumentRecievedAndAddToTheAllCases(Case manual_underwriting_case) {
        if(!manual_underwriting_case.Status.Contains('Document Received')){
                if (manual_underwriting_case.Status == 'Open') {
                manual_underwriting_case.Status = 'Open - Document Received';
            } else {
                manual_underwriting_case.Status = 'In Progress - Document Received';
            }
        }
        AllCasesToUpdate.add(manual_underwriting_case);
    }

    private Boolean isOwnedByCasePrepPendingQueue(Id owner_id) {
        return owner_id == CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_CASE_PREP);
    }

    private Boolean isOwnedByUser(Id owner_profile_id) {
        return owner_profile_id != null;
    }

    private void addEmailNotificationEmail(Case underwriting_case) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(underwriting_case.OwnerId);
        mail.setSubject('Document uploaded');
        String body = 'Hey ' + underwriting_case.Owner.FirstName + ', <br><br>';
        body += underwriting_case.Account.Name + ' just uploaded documents to your case ' + underwriting_case.CaseNumber + '.<br><br>';
        body += 'Please follow up on this case: <br>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + underwriting_case.Id;
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(false);
        AllMessagesToSend.add(mail);
    }
}