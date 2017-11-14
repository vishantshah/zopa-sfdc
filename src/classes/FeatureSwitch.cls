public class FeatureSwitch {
    Feature_Switch__c FeatureSwitch {get; set;}

    private final Boolean FeatureIsActive = true;
    private final Boolean FeatureIsNotActive = false;
    @TestVisible private static transient Map<String, Feature_Switch__c> FeatureSwitches;

    public FeatureSwitch(){
        if(FeatureSwitches == null){
            FeatureSwitches = new Map<String, Feature_Switch__c>();
            for(Feature_Switch__c feature_switch : [SELECT
                                                        Name,
                                                        readyForQA__c,
                                                        readyForRelease__c,
                                                        Delivered__c
                                                    FROM
                                                        Feature_Switch__c
                                                    WHERE
                                                        Delivered__c = false])
                FeatureSwitches.put(feature_switch.Name, feature_switch);
        }
    }

    public Boolean isFeatureSwitchActive(String jira_ticket){
        Feature_Switch__c feature_switch = FeatureSwitches.get(jira_ticket);
        if(feature_switch == null)
            return getDefaultFeatureSwitchStateForCurrentEnviroment();
        else
            return getFeatureSwitchStateForCurrentEnviroment(feature_switch);
    }

    private Boolean getDefaultFeatureSwitchStateForCurrentEnviroment(){
        if(Utility.isSandbox()){
            return FeatureIsActive;
        }else{
            return FeatureIsNotActive;
        }
    }

    private Boolean getFeatureSwitchStateForCurrentEnviroment(Feature_Switch__c feature_switch){
        if(Utility.isSandbox())
            return feature_switch.readyForQA__c;
        else
            return feature_switch.readyForRelease__c;
    }

    private static Map<String, FSwitch> Switches;
    @TestVisible private static Boolean IsSandbox;
    @TestVisible private static Boolean IsRunningTest;

    static {
        IsSandbox = Utility.isSandbox();
        IsRunningTest = Test.isRunningTest();
    }

    public static FSwitch getSwitch(String ticket_number){
        createSwitchMapIfNull();
        if(Switches.containsKey(ticket_number)){
            return Switches.get(ticket_number);
        } else if(!IsRunningTest){
            if(IsSandbox){
                return new DefaultSandboxSwitch();
            } else {
                return new DefaultLiveSwitch();
            }
        } else {
            if (Trigger.isExecuting){
                System.debug(LoggingLevel.WARN, 'Feature Switch: ' + ticket_number + ' was not explicitly set but was called in Trigger context');
                return new DefaultInTriggerContextSwitch();
            } else {
                throw new FeatureSwitchException(ticket_number + ' Feature Switch Must Be Explicitly Created or Overridden in Tests');
            }
        }
    }

    @TestVisible private static void enable(Set<String> enable_switches){
        createSwitchMapIfNull();
        for(String s:enable_switches){
            Switches.put(s, new OverrideSwitch(true));
        }
    }

    @TestVisible private static void disable(Set<String> disable_switches){
        createSwitchMapIfNull();
        for(String s:disable_switches){
            Switches.put(s, new OverrideSwitch(false));
        }
    }

    @TestVisible private static void enable(String enable_switch){
        createSwitchMapIfNull();
        Switches.put(enable_switch, new OverrideSwitch(true));
    }

    @TestVisible private static void disable(String disable_switch){
        createSwitchMapIfNull();
        Switches.put(disable_switch, new OverrideSwitch(false));
    }

    private static void createSwitchMapIfNull(){
        if(Switches == null){
            Switches = new Map<String, FSwitch>();
            for(Feature_Switch__c feature_switch : [SELECT Name, readyForQA__c, readyForRelease__c, Delivered__c
                                            FROM Feature_Switch__c
                                            WHERE Delivered__c = false]){
                if(IsSandbox){
                    Switches.put(feature_switch.Name, new SandBoxSwitch(feature_switch));
                } else {
                    Switches.put(feature_switch.Name, new LiveSwitch(feature_switch));
                }
            }
        }
    }

    public abstract class FSwitch{
        private Boolean IsEnabled = false;
        private Feature_Switch__c SwitchRecord;

        private FSwitch(Feature_Switch__c fs){
            this.SwitchRecord = fs;
            this.IsEnabled = getSwitchState();
        }

        private virtual Boolean getSwitchState(){
            return SwitchRecord.readyForRelease__c;
        }


        public Boolean isFeatureEnabled(){
            return this.IsEnabled;
        }

        public Boolean isFeatureDisabled(){
            return !this.isFeatureEnabled();
        }

    }

    public class LiveSwitch extends FSwitch{
        private LiveSwitch(Feature_Switch__c fs){
            super(fs);
        }
    }

    public class SandboxSwitch extends FSwitch{
        private SandboxSwitch(Feature_Switch__c fs){
            super(fs);
        }

        private override Boolean getSwitchState(){
            return SwitchRecord.readyForQA__c;
        }
    }

    public class DefaultSandboxSwitch extends FSwitch{
        private DefaultSandboxSwitch(){
            super(new Feature_Switch__c(
                Name='SandboxDefault',
                readyForRelease__c = true
                )
            );
        }
    }

    public class DefaultInTriggerContextSwitch extends FSwitch{
        private DefaultInTriggerContextSwitch(){
            super(new Feature_Switch__c(
                Name='InTriggerContextDefault',
                readyForRelease__c = true
                )
            );
        }
    }

    public class DefaultLiveSwitch extends FSwitch{
        private DefaultLiveSwitch(){
            super(new Feature_Switch__c(
                Name='LiveDefault',
                readyForRelease__c = false
                )
            );
        }
    }

    public class OverrideSwitch extends FSwitch{
        private OverrideSwitch(Boolean enabled){
            super(new Feature_Switch__c(
                Name='LiveDefault',
                readyForRelease__c = enabled
                )
            );
        }
    }

    public class FeatureSwitchException extends Exception{}

}