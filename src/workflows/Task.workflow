<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Time_moved_by_CP</fullName>
        <description>Time case was moved to Underwriting</description>
        <field>Moved_To_Underwriting__c</field>
        <formula>IF(
AND(
ISPICKVAL(Status,&apos;Completed&apos;),
ISNULL( Moved_To_Underwriting__c )
),

NOW(),

IF(ISPICKVAL(Status,&apos;Completed&apos;),Moved_To_Underwriting__c , null)
)</formula>
        <name>Time moved by CP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Add Account to task</fullName>
        <active>false</active>
        <formula>AND (NOT(isBlank( WhatId)),isBlank (Account_Name__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CP Moved to Underwriting</fullName>
        <actions>
            <name>Time_moved_by_CP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>To enable timestamp for when CP agents press Move to Underwriting button</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Test Task</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>equals</operation>
            <value>Email: You Zopa ISA application is in progress</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
