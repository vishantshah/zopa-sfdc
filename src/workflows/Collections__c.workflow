<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Collections</fullName>
        <description>Collections</description>
        <protected>false</protected>
        <recipients>
            <recipient>caroline.connaire@zopa.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>james@zopa.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tomedmunds@zopa.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old/Auto_Response</template>
    </alerts>
    <rules>
        <fullName>Collections Cases</fullName>
        <actions>
            <name>Collections</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Collections__c.Name</field>
            <operation>equals</operation>
            <value>Collections</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
