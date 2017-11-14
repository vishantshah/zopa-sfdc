<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>Send_SMS</fullName>
        <apiVersion>35.0</apiVersion>
        <description>Sends SMS to Contact</description>
        <endpointUrl>http://api.txtlocal.com/send/</endpointUrl>
        <fields>Id</fields>
        <fields>MemberID__c</fields>
        <fields>MobilePhone__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>admin@zopa.com</integrationUser>
        <name>Send SMS</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
</Workflow>
