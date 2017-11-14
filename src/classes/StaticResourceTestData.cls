@isTest
public class StaticResourceTestData {

    static public void createTestSchedulableJobsStaticResource(){
        StaticResource test_static_resource = new StaticResource();
        test_static_resource.Name = 'SchedulableJobs';
        test_static_resource.Body = Blob.valueOf(''
                + 'Name,Cron Expression,Class Name\n'
                + 'Reevaluate underwriting assignment rules hourly,0 0 * * * ?,ScheduleRunUnderwritingAssignments\n'
                + 'Reevaluate collections assignment rules hourly,0 0 * * * ?,ScheduleRunCollectionsAssignments\n'
                + 'Reevaluate loan pending consolidation queue,0 0 1 * * ?,ScheduleUpdateLoanConsolidationQueue\n'
                + 'Update OAuth Token every 30 mins 1,0 0 * * * ?,ScheduleUpdateZopaOAuth\n'
                + 'Update OAuth Token every 30 mins 2,0 30 * * * ?,ScheduleUpdateZopaOAuth\n'
                + 'Update Case Counters,0 0 6 * * ?,BatchUpdateCaseCounters'
        );
        StaticResourceMocks.getInstance().addStaticResourceMock(test_static_resource);
    }

    static public void createTestFeatureSwitchStaticResource(){
        StaticResource test_static_resource = new StaticResource();
        test_static_resource.Name = 'FeatureSwitch';
        test_static_resource.Body = Blob.valueOf('Name,JiraTicket__c,Description\n'+
                                                    'ZOPA-4,https://pexlify.atlassian.net/browse/ZOPA-1,Create manual underwriting cases\n'+
                                                    'ZOPA-7,https://pexlify.atlassian.net/browse/ZOPA-7,Pending button on manual underwriting cases\n'+
                                                    'ZOPA-9,https://pexlify.atlassian.net/browse/ZOPA-130,Tasks sections on the manual underwriting cases');
        StaticResourceMocks.getInstance().addStaticResourceMock(test_static_resource);
    }

    static public void createTestAccountTypeStaticResource(){
        StaticResource test_static_resource = new StaticResource();
        test_static_resource.Name = 'AccountType';
        test_static_resource.Body = Blob.valueOf('Name,Zopa_Value__c,Row_Type__c\n'+
                                                    'Unknown,Unknown,Both\n'+
                                                    'Bank Default,BankDefault,UnsecuredDebts\n'+
                                                    'Budget Card,BudgetCard,RollingCredit\n'+
                                                    'Hire Purchase,HirePurchase,UnsecuredDebts\n'+
                                                    'Credit Card,CreditCard,RollingCredit\n'+
                                                    'Loan,Loan,UnsecuredDebts\n'+
                                                    'Charge Card,ChargeCard,RollingCredit\n'+
                                                    'Rental,Rental,UnsecuredDebts\n'+
                                                    'Current Account,CurrentAccount,RollingCredit\n'+
                                                    'Fixed Term,FixedTerm,UnsecuredDebts');
        StaticResourceMocks.getInstance().addStaticResourceMock(test_static_resource);
    }
}