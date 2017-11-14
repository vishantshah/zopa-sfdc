@isTest
public class CaseUtilityTest {

    static testMethod void testGetInstanceInitTwoMaps() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestQueues();
            setup_data.createTestGroup();
            Test.startTest();
               setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertNotEquals(null, setup_data.ClassUnderTest.QueueNameToIdMap, 'QueueNameToIdMap should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.GroupNameToIdMap, 'GroupNameToIdMap should be initialized');
        }
    }

    static testMethod void testGetGroupIdFromName() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestGroup();
            setup_data.createTestQueues();
            setup_data.initClassUnderTest();
            Test.startTest();
               Id group_id = setup_data.ClassUnderTest.getGroupIdFromName(CaseUtility.GroupName.TEST);
            Test.stopTest();
            System.assertEquals(setup_data.TestGroup.Id, group_id, 'group id should match');
        }
    }

    static testMethod void testGetQueueIdFromName() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestQueues();
            setup_data.initClassUnderTest();
            Test.startTest();
               Id queue_id = setup_data.ClassUnderTest.getQueueIdFromName(CaseUtility.QueueName.PENDING_CASE_PREP);
            Test.stopTest();
            System.assertEquals(setup_data.TestQueues[0].Id, queue_id, 'queue id should match');
        }
    }

    static testMethod void testGetQueueIdSetFromName() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestQueues();
            setup_data.initClassUnderTest();
            Test.startTest();
               Set<Id> queue_ids = setup_data.ClassUnderTest.getQueueIdSetFromName(CaseUtility.QueueName.UNDERWRITER_PRIORITY);
            Test.stopTest();
            System.assertEquals(new Map<Id, Group>(setup_data.TestSetQueues).keySet(), queue_ids, 'queue id should match');
        }
    }

    static testMethod void testGetQueueIdSetFromNameNegative() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestQueues();
            setup_data.initClassUnderTest();
            Test.startTest();
               Set<Id> queue_ids = setup_data.ClassUnderTest.getQueueIdSetFromName(CaseUtility.QueueName.FRAUD_PRIORITY);
            Test.stopTest();
            System.assertNotEquals(new Map<Id, Group>(setup_data.TestSetQueues).keySet(), queue_ids, 'queue id should match');
        }
    }

    static testMethod void testGetQueueIdsFromNames() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestQueues();
            setup_data.initClassUnderTest();
            Test.startTest();
               Set<Id> queue_ids = setup_data.ClassUnderTest.getQueueIdsFromNames(new List<CaseUtility.QueueName> {
                                                                                    CaseUtility.QueueName.PENDING_CASE_PREP,
                                                                                    CaseUtility.QueueName.TEAM_LEADER});
            Test.stopTest();
            System.assertEquals(new Map<Id, Group>(setup_data.TestQueues).keySet(), queue_ids, 'queue ids should match');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public CaseUtility ClassUnderTest;
        public Group TestGroup;
        public List<Group> TestQueues;
        public List<Group> TestSetQueues;
        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'CaseUtilityTest' AND LastName = 'CaseUtilityTest' LIMIT 1];
            TestSetQueues = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName LIKE '%Underwriters_Priority%'];
            TestQueues = new List<Group>();
        }

        public void initClassUnderTest() {
            ClassUnderTest = CaseUtility.getInstance();
            ClassUnderTest.GroupNameMap.put(CaseUtility.GroupName.TEST, 'test_group');
            ClassUnderTest.QueueNameMap.put(CaseUtility.QueueName.PENDING_CASE_PREP, TestQueues.get(0).DeveloperName);
            ClassUnderTest.QueueNameMap.put(CaseUtility.QueueName.TEAM_LEADER, TestQueues.get(1).DeveloperName);
        }

        public void createTestGroup() {
            TestGroup = new Group(DeveloperName = 'test_group', Type = 'Regular', Name='test_group');
            insert TestGroup;
        }

        public void createTestQueues() {
            TestQueues.add(new Group(DeveloperName = 'test_queue1', Type = 'Queue', Name='test_queue1'));
            TestQueues.add(new Group(DeveloperName = 'test_queue2', Type = 'Queue', Name='test_queue2'));
            insert TestQueues;
        }
    }

    @testSetup
    static void setupTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('CaseUtilityTest')
                                     .setLastName('CaseUtilityTest')
                                     .save();
    }
}