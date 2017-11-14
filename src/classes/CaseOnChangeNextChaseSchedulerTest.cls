@isTest
public class CaseOnChangeNextChaseSchedulerTest {
    static Integer BULK_SIZE = 10;

    static testMethod void testHandleCasesAssignedToUserWithChangedNextReviewDate() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            Datetime next_review_date = Datetime.now();
            setup_data.createOldCollectionsAndRecoveriesCases(BULK_SIZE, next_review_date, setup_data.TestUser.Id);
            setup_data.createNewCollectionsAndRecoveriesCases(next_review_date.addDays(2), setup_data.TestUser.Id);

            Test.startTest();
                CaseOnChangeNextChaseScheduler.handleCasesWithChangedNextReviewDate(setup_data.TestOldCases, setup_data.TestNewCases);
            Test.stopTest();

            for(Case new_case : setup_data.TestNewCases) {
                System.assertEquals(true, new_case.CollectCaseScheduleChaseFlag__c, 'CollectCaseScheduleChaseFlag__c should be set to true');
                System.assertEquals(true, new_case.IsLockedFromUpdatesInProcess__c, 'IsLockedFromUpdatesInProcess__c should be set to true');
                System.assertEquals(setup_data.getOnHoldQueueId(), new_case.OwnerId, 'OwnerId should be set to On-Hold queue Id');
                System.assertEquals(1, new_case.Review_Counter__c, 'Review_Counter__c should be increased');
            }
        }
    }

    static testMethod void testHandleCasesAssignedToOnHoldQueueWithChangedNextReviewDate() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            Datetime next_review_date = Datetime.now();
            setup_data.createOldCollectionsAndRecoveriesCases(BULK_SIZE, next_review_date, setup_data.getOnHoldQueueId());
            setup_data.createNewCollectionsAndRecoveriesCases(next_review_date.addDays(2), setup_data.getOnHoldQueueId());

            Test.startTest();
                CaseOnChangeNextChaseScheduler.handleCasesWithChangedNextReviewDate(setup_data.TestOldCases, setup_data.TestNewCases);
            Test.stopTest();

            for(Case new_case : setup_data.TestNewCases) {
                System.assertEquals(true, new_case.CollectCaseScheduleChaseFlag__c, 'CollectCaseScheduleChaseFlag__c should be set to true');
                System.assertEquals(true, new_case.IsLockedFromUpdatesInProcess__c, 'IsLockedFromUpdatesInProcess__c should be set to true');
                System.assertEquals(setup_data.getOnHoldQueueId(), new_case.OwnerId, 'OwnerId should be set to On-Hold queue Id');
                System.assertEquals(null, new_case.Review_Counter__c, 'Review_Counter__c should not be increased');
            }
        }
    }

    static testMethod void testHandleCasesAssignedToUserWithNotChangedNextReviewDate() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            Datetime next_review_date = Datetime.now();
            setup_data.createOldCollectionsAndRecoveriesCases(BULK_SIZE, next_review_date, setup_data.TestUser.Id);
            setup_data.createNewCollectionsAndRecoveriesCases(next_review_date, setup_data.TestUser.Id);

            Test.startTest();
                CaseOnChangeNextChaseScheduler.handleCasesWithChangedNextReviewDate(setup_data.TestOldCases, setup_data.TestNewCases);
            Test.stopTest();

            for(Case new_case : setup_data.TestNewCases) {
                System.assertEquals(false, new_case.CollectCaseScheduleChaseFlag__c, 'CollectCaseScheduleChaseFlag__c should not be set to true');
                System.assertEquals(false, new_case.IsLockedFromUpdatesInProcess__c, 'IsLockedFromUpdatesInProcess__c should not be set to true');
                System.assertNotEquals(setup_data.getOnHoldQueueId(), new_case.OwnerId, 'OwnerId should not be set to On-Hold queue Id');
                System.assertEquals(null, new_case.Review_Counter__c, 'Review_Counter__c should not be increased');
            }
        }
    }

    static testMethod void testHandleCasesWithNextReviewDateAfterInsertWhenNextReviewDateIsSet() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            Datetime next_review_date = Datetime.now();
            setup_data.createOldCollectionsAndRecoveriesCases(BULK_SIZE, next_review_date, setup_data.TestUser.Id);

            Test.startTest();
                CaseOnChangeNextChaseScheduler.handleCasesWithNextReviewDateAfterInsert(setup_data.TestOldCases);
            Test.stopTest();

            System.assertEquals(
                    BULK_SIZE,
                    [
                            SELECT Count()
                            FROM Task
                            WHERE WhatId IN :new Map<Id, Case>(setup_data.TestOldCases).keySet()
                            AND Subject = 'For Review'
                            AND IsClosed = false
                            AND Review_Due_Date__c = :next_review_date
                            AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL)
                    ],
                    BULK_SIZE + ' "For Review" tasks should be created with ReviewDueDate equal: ' + next_review_date
            );
        }
    }

    static testMethod void testHandleCasesWithNextReviewDateAfterInsertWhenNextReviewDateIsNotSet() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            Datetime next_review_date = Datetime.now();
            setup_data.createOldCollectionsAndRecoveriesCases(BULK_SIZE, setup_data.TestUser.Id);

            Test.startTest();
                CaseOnChangeNextChaseScheduler.handleCasesWithNextReviewDateAfterInsert(setup_data.TestOldCases);
            Test.stopTest();

            System.assertEquals(
                    0,
                    [
                            SELECT Count()
                            FROM Task
                            WHERE WhatId IN :new Map<Id, Case>(setup_data.TestOldCases).keySet()
                            AND Subject = 'For Review'
                            AND IsClosed = false
                            AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL)
                    ],
                    '"For Review" tasks should not be created'
            );
        }
    }

    static testMethod void testHandleCasesWithChangedNextReviewDateAfterUpdateWhenNullNextReviewDateChanged() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            Datetime next_review_date = Datetime.now();
            setup_data.createOldCollectionsAndRecoveriesCases(BULK_SIZE, setup_data.TestUser.Id);
            setup_data.createNewCollectionsAndRecoveriesCases(next_review_date, setup_data.TestUser.Id);

            Test.startTest();
                CaseOnChangeNextChaseScheduler.handleCasesWithChangedNextReviewDateAfterUpdate(setup_data.TestOldCases, setup_data.TestNewCases);
            Test.stopTest();

            System.assertEquals(
                    BULK_SIZE,
                    [
                            SELECT Count()
                            FROM Task
                            WHERE WhatId IN :new Map<Id, Case>(setup_data.TestNewCases).keySet()
                            AND Subject = 'For Review'
                            AND IsClosed = false
                            AND Review_Due_Date__c = :next_review_date
                            AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL)
                    ],
                    BULK_SIZE + ' "For Review" tasks should be created with ReviewDueDate equal: ' + next_review_date
            );
        }
    }

    static testMethod void testHandleCasesWithChangedNextReviewDateAfterUpdateWhenNotNullNextReviewDateChanged() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            Datetime next_review_date = Datetime.now();
            setup_data.createOldCollectionsAndRecoveriesCases(BULK_SIZE, next_review_date, setup_data.TestUser.Id);
            setup_data.createNewCollectionsAndRecoveriesCases(next_review_date.addDays(2), setup_data.TestUser.Id);

            Test.startTest();
                CaseOnChangeNextChaseScheduler.handleCasesWithChangedNextReviewDateAfterUpdate(setup_data.TestOldCases, setup_data.TestNewCases);
            Test.stopTest();

            System.assertEquals(
                    BULK_SIZE,
                    [
                            SELECT Count()
                            FROM Task
                            WHERE WhatId IN :new Map<Id, Case>(setup_data.TestNewCases).keySet()
                            AND Subject = 'For Review'
                            AND IsClosed = false
                            AND Review_Due_Date__c = :next_review_date.addDays(2)
                            AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL)
                    ],
                    BULK_SIZE + ' "For Review" tasks should be updated with ReviewDueDate equal: ' + next_review_date.addDays(2)
            );
        }
    }

    static testMethod void testHandleCasesWithChangedNextReviewDateAfterUpdateWhenNullNextReviewDateNotChanged() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            Datetime next_review_date = Datetime.now();
            setup_data.createOldCollectionsAndRecoveriesCases(BULK_SIZE, setup_data.TestUser.Id);
            setup_data.createNewCollectionsAndRecoveriesCases(setup_data.TestUser.Id);

            Test.startTest();
                CaseOnChangeNextChaseScheduler.handleCasesWithChangedNextReviewDateAfterUpdate(setup_data.TestOldCases, setup_data.TestNewCases);
            Test.stopTest();

            System.assertEquals(
                    0,
                    [
                            SELECT Count()
                            FROM Task
                            WHERE WhatId IN :new Map<Id, Case>(setup_data.TestNewCases).keySet()
                            AND Subject = 'For Review'
                            AND IsClosed = false
                            AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL)
                    ],
                    '"For Review" tasks should not be created.'
            );
        }
    }

    static testMethod void testHandleCasesWithChangedNextReviewDateAfterUpdateWhenNotNullNextReviewDateNotChanged() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            Datetime next_review_date = Datetime.now();
            setup_data.createOldCollectionsAndRecoveriesCases(BULK_SIZE, next_review_date, setup_data.TestUser.Id);
            setup_data.createNewCollectionsAndRecoveriesCases(setup_data.TestUser.Id);

            Test.startTest();
                CaseOnChangeNextChaseScheduler.handleCasesWithChangedNextReviewDateAfterUpdate(setup_data.TestOldCases, setup_data.TestNewCases);
            Test.stopTest();

            System.assertEquals(
                    BULK_SIZE,
                    [
                            SELECT Count()
                            FROM Task
                            WHERE WhatId IN :new Map<Id, Case>(setup_data.TestNewCases).keySet()
                            AND Subject = 'For Review'
                            AND IsClosed = false
                            AND Review_Due_Date__c = :next_review_date
                            AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.TASK_COLLECTIONS_CALL)
                    ],
                    BULK_SIZE + ' "For Review" tasks should exist with not changed ReviewDueDate equal: ' + next_review_date
            );
        }
    }

    static testMethod void testIncreaseReviewCounterWhenCurrentValueIsNull() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createOldCollectionsAndRecoveriesCases(1, Datetime.now(), setup_data.TestUser.Id);
            Case test_case = setup_data.TestOldCases[0];
            test_case.Review_Counter__c = null;

            Test.startTest();
                CaseOnChangeNextChaseScheduler.increaseReviewCounter(test_case);
            Test.stopTest();

            System.assertEquals(1, test_case.Review_Counter__c, 'Review_Counter__c should be set to 1.');
        }
    }

    static testMethod void testIncreaseReviewCounterWhenCurrentValueIs5() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createOldCollectionsAndRecoveriesCases(1, Datetime.now(), setup_data.TestUser.Id);
            Case test_case = setup_data.TestOldCases[0];
            test_case.Review_Counter__c = 5;

            Test.startTest();
                CaseOnChangeNextChaseScheduler.increaseReviewCounter(test_case);
            Test.stopTest();

            System.assertEquals(6, test_case.Review_Counter__c, 'Review_Counter__c should be increased to 6.');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Account TestAccount;
        public List<Case> TestOldCases;
        public List<Case> TestNewCases;

        public SetupDataClass() {
            FeatureSwitch.disable('ZOPA-4');
            FeatureSwitch.disable('ZOPA-72');
            FeatureSwitch.disable('ZOPA-130');
            TestUser = [SELECT Id FROM User WHERE LastName = 'CollectionsLastName' AND FirstName = 'CollectionsFirstName' LIMIT 1];
        }

        public void createTestAccount() {
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .setRecordType(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT)
                    .save()
                    .getRecord();
        }

        public void createOldCollectionsAndRecoveriesCases(Integer size, Id owner_id) {
            TestOldCases = CaseBuilder.getBuilder(TestAccount)
                    .setOwner(owner_id)
                    .setStatus('Open')
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .getRecordList(size);
            insert TestOldCases;
        }

        public void createOldCollectionsAndRecoveriesCases(Integer size, Datetime next_review_date, Id owner_id) {
            TestOldCases = CaseBuilder.getBuilder(TestAccount)
                    .setOwner(owner_id)
                    .setStatus('Open')
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setNextReviewDate(next_review_date)
                    .getRecordList(size);
            insert TestOldCases;
        }

        public void createNewCollectionsAndRecoveriesCases(Id owner_id) {
            TestNewCases = TestOldCases.deepClone(true);
            for(Case new_case : TestNewCases) {
                CaseBuilder.getBuilder(new_case)
                        .setOwner(owner_id);
            }
        }

        public void createNewCollectionsAndRecoveriesCases(Datetime next_review_date, Id owner_id) {
            TestNewCases = TestOldCases.deepClone(true);
            for(Case new_case : TestNewCases) {
                CaseBuilder.getBuilder(new_case)
                        .setNextReviewDate(next_review_date)
                        .setOwner(owner_id);
            }
        }

        public Set<Id> getListOfIdsFromListOfCases(List<Case> case_list) {
            return new Map<Id, Case>(case_list).keySet();
        }

        public Id getOnHoldQueueId() {
            return CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD);
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.COLLECTIONS)
                .setFirstName('CollectionsFirstName')
                .setLastName('CollectionsLastName')
                .save()
                .getRecord();
    }
}