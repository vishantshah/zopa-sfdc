<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CCD_30_50</fullName>
        <description>Campaign Client Development - Over 30k under 50k - tried to phone</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Development_Auto_Emails/CCD_Over30k_under50k_neverContact</template>
    </alerts>
    <alerts>
        <fullName>CCD_M6mth</fullName>
        <description>Campaign Client Development - High Funder (over £10k) - New</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Development_Auto_Emails/CD_More6mths1</template>
    </alerts>
    <alerts>
        <fullName>Campaign_Client_Development_1K_10K_Funded</fullName>
        <description>Campaign - Client Development 1K - 10K Funded</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Development_Auto_Emails/Funded_1k_10kAuto</template>
    </alerts>
    <alerts>
        <fullName>Campaign_Client_Development_High_Funder_over_10k_New</fullName>
        <description>Campaign Client Development - High Funder (over £10k) - New</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Development_Auto_Emails/CCD_New_10k</template>
    </alerts>
    <alerts>
        <fullName>Campaign_DPA_not_liked</fullName>
        <description>Campaign DPA not liked</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Development_Auto_Emails/CCD_NotComfortableDPA</template>
    </alerts>
    <alerts>
        <fullName>Campaign_Test_Alert</fullName>
        <ccEmails>matthew.brunton@zopa.com</ccEmails>
        <description>Campaign Test Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Merge_Folder/Email20170331_Email</template>
    </alerts>
    <alerts>
        <fullName>Client_Development_First_Funded_Under_10k</fullName>
        <description>Client Development - First Funded - Under £10k</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Development_Auto_Emails/Campaign_Client_Development_First_Funded_Under_10k</template>
    </alerts>
</Workflow>
