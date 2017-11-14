<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ISA_Amber_Flag</fullName>
        <field>Flag__c</field>
        <formula>&quot;Amber&quot;</formula>
        <name>ISA - Amber Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISA_Green_Flag</fullName>
        <field>Flag__c</field>
        <formula>&quot;Green&quot;</formula>
        <name>ISA - Green Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISA_Red_Flag</fullName>
        <field>Flag__c</field>
        <formula>&quot;Red&quot;</formula>
        <name>ISA - Red Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_ISA_Transfer</fullName>
        <field>Form_Sent__c</field>
        <formula>now()</formula>
        <name>Update ISA Transfer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ISA - Amber</fullName>
        <actions>
            <name>ISA_Amber_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ISA_Transfer_In__c.Current_Timer__c</field>
            <operation>lessOrEqual</operation>
            <value>4</value>
        </criteriaItems>
        <criteriaItems>
            <field>ISA_Transfer_In__c.Current_Timer__c</field>
            <operation>greaterOrEqual</operation>
            <value>2</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISA - Green</fullName>
        <actions>
            <name>ISA_Green_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ISA_Transfer_In__c.Current_Timer__c</field>
            <operation>greaterThan</operation>
            <value>4</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISA - Red</fullName>
        <actions>
            <name>ISA_Red_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ISA_Transfer_In__c.Current_Timer__c</field>
            <operation>lessThan</operation>
            <value>2</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Contact</fullName>
        <active>false</active>
        <formula>NOT(ISBLANK(Account_Name__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
