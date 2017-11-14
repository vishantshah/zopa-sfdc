@isTest
private class FeatureSwitchTest {

    static testMethod void testFeatureSwitchOn(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestingUser){
            setup_data.initializeTestData(true, false);
            setup_data.instantiateClassUnderTest();
            Test.startTest();
                Boolean feature_switch_on = setup_data.ClassUnderTest.isFeatureSwitchActive('UKOPS-TEST');
            Test.stopTest();
            System.assertEquals(true, feature_switch_on);
        }
    }

    static testMethod void testFeatureSwitchOff(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestingUser){
            setup_data.initializeTestData(false, false);
            setup_data.instantiateClassUnderTest();
            Test.startTest();
                Boolean feature_switch_on = setup_data.ClassUnderTest.isFeatureSwitchActive('UKOPS-TEST');
            Test.stopTest();
            System.assertEquals(false, feature_switch_on);
        }
    }

    static testMethod void testFeatureSwitchHasRightDefaultValue(){
        FeatureSwitch feature_switch = new FeatureSwitch();
        Test.startTest();
            Boolean feature_switch_on = feature_switch.isFeatureSwitchActive('UKOPS-TEST');
        Test.stopTest();
        if(!Utility.isSandbox())
            System.assertEquals(false, feature_switch_on);
        else
            System.assertEquals(true, feature_switch_on);
    }

    static testMethod void testDeliveredFeatureSwitchesAreExcludedFromQuery(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestingUser){
            setup_data.initializeTestData(false, true);
            setup_data.instantiateClassUnderTest();
            Test.startTest();
                List<Feature_Switch__c> delivered_feature_switch_list = [SELECT
                                                                    Name,
                                                                    readyForQA__c,
                                                                    readyForRelease__c,
                                                                    Delivered__c
                                                                FROM
                                                                    Feature_Switch__c
                                                                WHERE
                                                                    Delivered__c = false];
            Test.stopTest();
            System.assertEquals(delivered_feature_switch_list.size(), FeatureSwitch.FeatureSwitches.size());
        }
    }

    static testMethod void testNewImplementationThrowsExceptionInTestIfNoSwitchCreated(){
        boolean exception_thrown = false;
        Test.startTest();
            try{
                FeatureSwitch.getSwitch('TestSwitch');
            } catch (FeatureSwitch.FeatureSwitchException fse) {
                exception_thrown = true;
            }
        Test.stopTest();
        System.assert(exception_thrown, 'FeatureSwitch Exception was not Thrown');
    }

    static testMethod void testNewImplementationDefaultForSandboxIsFeatureEnabled(){
        FeatureSwitch.IsRunningTest = false;
        FeatureSwitch.IsSandbox = true;
        System.assert(FeatureSwitch.getSwitch('TestSwitchInSandbox').isFeatureEnabled(), 'Feature Switch Default is Not Active');
        System.assertEquals(false, FeatureSwitch.getSwitch('TestSwitchInSandbox').isFeatureDisabled(), 'Feature Switch Default is Not Active');
    }

    static testMethod void testNewImplementationDefaultForProductionIsFeatureDisabled(){
        FeatureSwitch.IsRunningTest = false;
        FeatureSwitch.IsSandbox = false;
        System.assertEquals(false, FeatureSwitch.getSwitch('TestSwitchInLive').isFeatureEnabled(), 'Feature Switch Default is Not Disabled');
        System.assert(FeatureSwitch.getSwitch('TestSwitchInLive').isFeatureDisabled(), 'Feature Switch Default is Not Disabled');
    }

    static testMethod void testNewImplementationReturnsReadyForQAValueInSandbox(){
        FeatureSwitch.IsRunningTest = false;
        FeatureSwitch.IsSandbox = true;
        FeatureSwitchTestData.getFeatureSwitchForTest('TEST-1234')
                                .setReadyForQA(true)
                                .setReadyForRelease(false)
                                .save();
        Boolean result;
        Test.startTest();
            result = FeatureSwitch.getSwitch('TEST-1234').isFeatureEnabled();
        Test.stopTest();
        System.assert(result, 'IsFeatureEnabled is false but should be true');
    }

    static testMethod void testNewImplementationReturnsReadyForReleaseValueInLive(){
        FeatureSwitch.IsRunningTest = false;
        FeatureSwitch.IsSandbox = false;
        FeatureSwitchTestData.getFeatureSwitchForTest('TEST-1235')
                                .setReadyForQA(true)
                                .setReadyForRelease(false)
                                .save();
        Boolean result;
        Test.startTest();
            result = FeatureSwitch.getSwitch('TEST-1235').isFeatureEnabled();
        Test.stopTest();
        System.assertEquals(false, result, 'IsFeatureEnabled is true but should be false');
    }

    static testMethod void testEnableOverrideWorksForcesIsEnabledToReturnTrue(){
        FeatureSwitch.IsSandbox = true;
        FeatureSwitchTestData.getFeatureSwitchForTest('TEST-1236')
                                .setReadyForQA(false)
                                .save();
        Test.startTest();
            FeatureSwitch.enable(new Set<String>{'TEST-1236'});
        Test.stopTest();
        System.assert(FeatureSwitch.getSwitch('TEST-1236').isFeatureEnabled(), 'Override should have set IsEnabled to True');
        System.assertEquals(false, FeatureSwitch.getSwitch('TEST-1236').isFeatureDisabled(), 'Override should have set IsDisabled to False');
    }

    static testMethod void testDisableOverrideWorksForcesIsEnabledToReturnFalse(){
        FeatureSwitch.IsSandbox = true;
        FeatureSwitchTestData.getFeatureSwitchForTest('TEST-1237')
                                .setReadyForQA(true)
                                .save();
        Test.startTest();
            FeatureSwitch.disable(new Set<String>{'TEST-1237'});
        Test.stopTest();
        System.assert(FeatureSwitch.getSwitch('TEST-1237').isFeatureDisabled(), 'Override should have set IsDisabled to True');
        System.assertEquals(false, FeatureSwitch.getSwitch('TEST-1237').isFeatureEnabled(), 'Override should have set IsEnabled to False');
    }

    static testMethod void testEnableOverrideWorksForcesIsEnabledToReturnTrueForSingleSwitch(){
        FeatureSwitch.IsSandbox = true;
        FeatureSwitchTestData.getFeatureSwitchForTest('TEST-1236')
                                .setReadyForQA(false)
                                .save();
        Test.startTest();
            FeatureSwitch.enable('TEST-1236');
        Test.stopTest();
        System.assert(FeatureSwitch.getSwitch('TEST-1236').isFeatureEnabled(), 'Override should have set IsEnabled to True');
        System.assertEquals(false, FeatureSwitch.getSwitch('TEST-1236').isFeatureDisabled(), 'Override should have set IsDisabled to False');
    }

    static testMethod void testDisableOverrideWorksForcesIsEnabledToReturnFalseForSingleSwitch(){
        FeatureSwitch.IsSandbox = true;
        FeatureSwitchTestData.getFeatureSwitchForTest('TEST-1237')
                                .setReadyForQA(true)
                                .save();
        Test.startTest();
            FeatureSwitch.disable('TEST-1237');
        Test.stopTest();
        System.assert(FeatureSwitch.getSwitch('TEST-1237').isFeatureDisabled(), 'Override should have set IsDisabled to True');
        System.assertEquals(false, FeatureSwitch.getSwitch('TEST-1237').isFeatureEnabled(), 'Override should have set IsEnabled to False');
    }

    private class SetupDataClass {
        public Integer NumberOfDeliveredFeatureSwitches {get; set;}
        public Integer NumberOfUndeliveredFeatureSwitches {get; set;}
        Feature_Switch__c TestFeatureSwitch {get; set;}
        FeatureSwitch ClassUnderTest {get; set;}
        public User TestingUser {get; set;}

        private SetupDataClass(){
            TestingUser = [SELECT Id FROM User WHERE LastName = 'FeatureSwitchTest' LIMIT 1];
        }

        private void initializeTestData(Boolean single_feature_switch_on, Boolean multiple_feature_switches){
            if(!single_feature_switch_on && !multiple_feature_switches)
                createSingleFeatureSwitch(false);
            else if(single_feature_switch_on && !multiple_feature_switches)
                createSingleFeatureSwitch(true);
            if(multiple_feature_switches) {
                createMultipleDeliveredFeatureSwitch();
                createMultipleUndeliveredFeatureSwitch();
            }
        }

        private void createSingleFeatureSwitch(Boolean feature_switch_is_on){
            TestFeatureSwitch = FeatureSwitchTestData.getFeatureSwitchForTest('UKOPS-TEST')
                                                        .setReadyForRelease(feature_switch_is_on)
                                                        .setReadyForQA(feature_switch_is_on)
                                                        .setReleaseNotes('Release notes')
                                                        .setTrainingNotes('Training notes')
                                                        .setUATApprovedBy('UAT approver')
                                                        .setDemoApprovedBy('Demo approver')
                                                        .save().getRecord();
        }

        private void createMultipleDeliveredFeatureSwitch(){
            NumberOfDeliveredFeatureSwitches = 5;
            Boolean delivered = true;
            createFeatureSwitches(delivered, NumberOfDeliveredFeatureSwitches);
        }

        private void createMultipleUndeliveredFeatureSwitch(){
            NumberOfUndeliveredFeatureSwitches = 5;
            Boolean delivered = false;
            createFeatureSwitches(delivered, NumberOfUndeliveredFeatureSwitches);
        }

        private void instantiateClassUnderTest(){
            ClassUnderTest = new FeatureSwitch();
        }

        private void createFeatureSwitches(Boolean is_delivered, Integer feature_switch_count){
            for(Integer i = 0; i<feature_switch_count; i++){
                if(is_delivered) CustomSettingData.createDeliveredFeatureSwitch('UKOPS-DELIVERED-'+i, true);
                else CustomSettingData.createFeatureSwitch('UKOPS-UNDELIVERED-'+i, true);
            }
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.STANDARD_USER)
                                     .setLastName('FeatureSwitchTest')
                                     .save();
    }
}