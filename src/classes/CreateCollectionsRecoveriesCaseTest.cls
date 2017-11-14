@isTest
public class CreateCollectionsRecoveriesCaseTest {

    static testMethod void testCreateCollectionsRecoveriesCases() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
            CreateCollectionsRecoveriesCaseHandler.createCollectionsRecoveriesCases(setup_data.TestLoan);
            Test.stopTest();

            System.assertEquals(
                    1,
                    CreateCollectionsRecoveriesCaseHandler.listCollectionsRecoveriesCase.size(),
                    'Should add cases to listCollectionsRecoveriesCase'
            );
        }
    }

    static testMethod void testUpsertCollectionsRecoveriesCases() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            CreateCollectionsRecoveriesCaseHandler.createCollectionsRecoveriesCases(setup_data.TestLoan);

            Test.startTest();
                CreateCollectionsRecoveriesCaseHandler.upsertCollectionsRecoveriesCases();
            Test.stopTest();

            System.assertEquals(
                    1,
                    [
                            SELECT COUNT()
                            FROM Case
                            WHERE Loan__c = :setup_data.TestLoan.id
                            AND RecordType.Name = :CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE
                            AND Status = :CreateCollectionsRecoveriesCaseHandler.STATUS_FOR_NEW_CASE
                            AND Process__c = :CreateCollectionsRecoveriesCaseHandler.PROCESS_FOR_NEW_CASE
                            AND Sub_Process__c = :CreateCollectionsRecoveriesCaseHandler.SUB_PROCESS_FOR_NEW_CASE
                    ],
                    'Should insert case'
            );
        }
    }

    static testMethod void testChangeCaseRelatedToLoan() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestLoan.Arrears_Ratio__c = 0.5;
            update setup_data.TestLoan;
            LoanStatusChecker.LoanIdWithClosedtStatus.add(setup_data.TestLoan.id);
            Test.startTest();
               CreateCollectionsRecoveriesCaseHandler.changeCaseRelatedToLoan(new Set<id> {setup_data.TestLoan.id});
            Test.stopTest();
            System.assertEquals('Closed Paid', CreateCollectionsRecoveriesCaseHandler.MapCollectionsRecoveriesCase.get(setup_data.TestCase.id).Status, 'Should add equal Status of cases');
            System.assert(string.valueOf(CreateCollectionsRecoveriesCaseHandler.MapCollectionsRecoveriesCase.get(setup_data.TestCase.id).OwnerId).startsWith('005'), 'Owner must be a User');
        }
    }

    static testMethod void testIsChanged() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            String value_first = 'value_first';
            String clone_value_first = value_first;
            String value_second = 'value_second';
            String value_third = 'value_third';

            Test.startTest();
               Boolean result_with_identical_value = CreateCollectionsRecoveriesCaseHandler.isChanged(value_first, clone_value_first);
               Boolean result_with_different_value = CreateCollectionsRecoveriesCaseHandler.isChanged(value_second, value_third);
            Test.stopTest();

            System.assertEquals(false, result_with_identical_value);
            System.assertEquals(true, result_with_different_value);
        }
    }

    static testMethod void testHandleArrearsRationChangeOnLoanZeroRatio() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestLoan.Arrears_Ratio__c = 0;

            Test.startTest();
               CreateCollectionsRecoveriesCaseHandler.handleArrearsRatioOnChangeOnLoan(setup_data.TestLoan);
            Test.stopTest();

            System.assertEquals(
                    true,
                    CreateCollectionsRecoveriesCaseHandler.LoanIdsWithCasesNeedToBeClosed.contains(setup_data.TestLoan.Id),
                    'Should contains Loan Id'
            );
        }
    }

    static testMethod void testHandleArrearsRationChangeOnLoanNotZeroRatio() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestLoan.Arrears_Ratio__c = 0.5;

            Test.startTest();
               CreateCollectionsRecoveriesCaseHandler.handleArrearsRatioOnChangeOnLoan(setup_data.TestLoan);
            Test.stopTest();

            System.assertEquals(1, CreateCollectionsRecoveriesCaseHandler.ListCollectionsRecoveriesCase.size(), 'Should create new Case');
        }
    }

    static testMethod void testHandleArrearsRationChangeOnLoanFourRatio() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-157');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestLoan.Arrears_Ratio__c = 4;
            CreateCollectionsRecoveriesCaseHandler.LoansWithOpenCasesSetIds.add(setup_data.TestLoan.Id);

            Test.startTest();
               CreateCollectionsRecoveriesCaseHandler.handleArrearsRatioOnChangeOnLoan(setup_data.TestLoan);
            Test.stopTest();

            System.assertEquals(
                    true,
                    CreateCollectionsRecoveriesCaseHandler.LoanIdsWithCasesNeedToBePreDefault.contains(setup_data.TestLoan.Id),
                    'Should contains Loan Id'
            );
            System.assertEquals(
                    true,
                    CreateCollectionsRecoveriesCaseHandler.LoansUuidForSendApi.contains(setup_data.TestLoan.Loan_id__c),
                    'Should contains Loan uuid'
            );
        }
    }

    static testMethod void testHandleArrearsRationChangeOnLoanCreateCaseRatioFour() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-157');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestLoan.Arrears_Ratio__c = 4;

            Test.startTest();
               CreateCollectionsRecoveriesCaseHandler.handleArrearsRatioOnChangeOnLoan(setup_data.TestLoan);
            Test.stopTest();

            System.assertEquals(1, CreateCollectionsRecoveriesCaseHandler.ListCollectionsRecoveriesCase.size(), 'Should create new Case');
        }
    }

    static testMethod void testUpsertCollectionsRecoveriesCasesWithRatioFour() {
            SetupDataClass setup_data = new SetupDataClass();
            System.runAs(setup_data.TestUser) {
                setup_data.TestLoan.Arrears_Ratio__c = 4;
                CreateCollectionsRecoveriesCaseHandler.createCollectionsRecoveriesCases(setup_data.TestLoan);

                Test.startTest();
                    CreateCollectionsRecoveriesCaseHandler.upsertCollectionsRecoveriesCases();
                Test.stopTest();

                System.assertEquals(
                        1,
                        [
                                SELECT COUNT()
                                FROM Case
                                WHERE Loan__c = :setup_data.TestLoan.id
                                AND RecordType.Name = :CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE
                                AND Status = :CreateCollectionsRecoveriesCaseHandler.STATUS_FOR_NEW_CASE
                                AND Process__c = :CreateCollectionsRecoveriesCaseHandler.PROCESS_FOR_NEW_CASE
                                AND Sub_Process__c = 'Pre-Default'
                        ],
                        'Should insert case, with Pre-Default Sub-Process'
                );
            }
    }

    static testMethod void testHandleArrearsRationChangeOnLoanCreateCaseRatioFourOnClosedCase() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-157');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestCase.Status = 'Closed';
            update setup_data.TestCase;
            setup_data.TestLoan.Arrears_Ratio__c = 4;
            CreateCollectionsRecoveriesCaseHandler.handleArrearsRatioOnChangeOnLoan(setup_data.TestLoan);
            CreateCollectionsRecoveriesCaseHandler.changeCaseRelatedToLoan(new Set<id> {setup_data.TestLoan.id});

            Test.startTest();
               CreateCollectionsRecoveriesCaseHandler.upsertCollectionsRecoveriesCases();
            Test.stopTest();

            System.assertEquals(
                    0,
                    [
                            SELECT COUNT()
                            FROM Case
                            WHERE Loan__c = :setup_data.TestLoan.id
                            AND RecordType.Name = :CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE
                            AND IsClosed = true
                            AND Sub_Process__c = 'Pre-Default'
                            AND Status = 'Pending'
                    ],
                    'Should not update related Case to Pre-Default Sub-Process if it Closed'
            );
        }
    }

    static testMethod void testHandleArrearsRationChangeOnLoanIfCaseOnDefault() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-157');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestCase.Sub_Process__c = 'Default';
            update setup_data.TestCase;
            setup_data.TestLoan.Arrears_Ratio__c = 4;
            CreateCollectionsRecoveriesCaseHandler.LoanIdsWithCasesNeedToBeClosed.add(setup_data.TestLoan.Id);

            Test.startTest();
               CreateCollectionsRecoveriesCaseHandler.changeCaseRelatedToLoan(new Set<Id>());
               CreateCollectionsRecoveriesCaseHandler.upsertCollectionsRecoveriesCases();
            Test.stopTest();

            System.assertEquals(
                    1,
                    [
                            SELECT COUNT()
                            FROM Case
                            WHERE Loan__c = :setup_data.TestLoan.id
                            AND RecordType.Name = :CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE
                            AND IsClosed = false
                            AND Sub_Process__c = 'Default'
                    ],
                    'Should not update related Case to Closed if Sub-Process is Default'
            );
        }
    }

    static testMethod void testHandleArrearsRatioChangeOnLoanIfCaseIsNotDefaultAndRatioIsGreaterThan4() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-157');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestCase.Sub_Process__c = 'Early Arrears';
            update setup_data.TestCase;
            setup_data.TestLoan.Arrears_Ratio__c = 5;
            CreateCollectionsRecoveriesCaseHandler.LoanIdsWithCasesNeedToBePreDefault.add(setup_data.TestLoan.Id);

            Test.startTest();
                CreateCollectionsRecoveriesCaseHandler.changeCaseRelatedToLoan(new Set<Id>());
                CreateCollectionsRecoveriesCaseHandler.upsertCollectionsRecoveriesCases();
            Test.stopTest();

            System.assertEquals(
                    1,
                    [
                            SELECT COUNT()
                            FROM Case
                            WHERE Loan__c = :setup_data.TestLoan.id
                            AND RecordType.Name = :CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE
                            AND IsClosed = false
                            AND Sub_Process__c = 'Pre-Default'
                    ],
                    'Should update related Case to Pre-Default Sub-Process when Ratio is greater than 4 and Sub-Process is not Default.'
            );
        }
    }

    static testMethod void testHandleArrearsRatioChangeOnLoanIfCaseIsDefaultAndRatioIsGreaterThan4() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-157');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestCase.Sub_Process__c = 'Default';
            update setup_data.TestCase;
            setup_data.TestLoan.Arrears_Ratio__c = 5;
            CreateCollectionsRecoveriesCaseHandler.LoanIdsWithCasesNeedToBePreDefault.add(setup_data.TestLoan.Id);

            Test.startTest();
                CreateCollectionsRecoveriesCaseHandler.changeCaseRelatedToLoan(new Set<Id>());
                CreateCollectionsRecoveriesCaseHandler.upsertCollectionsRecoveriesCases();
            Test.stopTest();

            System.assertEquals(
                    1,
                    [
                        SELECT COUNT()
                        FROM Case
                        WHERE Loan__c = :setup_data.TestLoan.id
                        AND RecordType.Name = :CreateCollectionsRecoveriesCaseHandler.COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE
                        AND IsClosed = false
                        AND Sub_Process__c = 'Default'
                    ],
                    'Should not update related Case to Pre-Default Sub-Process when Ratio is greater than 4 and Sub-Process is Default.');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Account TestAccount;
        public Loan__c TestLoan;
        public Case TestCase;
        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' LIMIT 1];
            createAccount();
            createLoan();
        }

        private void createAccount() {
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .save()
                    .getRecord();
        }

        public void createLoan() {
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setExternalId('0000-0000-0000-0001')
                    .save()
                    .getRecord();
        }

        public void createCollectionsRecoveriesCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(TestLoan)
                    .setProcess(CaseUtility.CASE_PROCESS_COLLECTIONS)
                    .save()
                    .getRecord();
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('TestLastName')
                .save()
                .getRecord();
    }
}