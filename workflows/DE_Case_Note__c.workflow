<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_Notification_to_Case_Owners</fullName>
        <description>Send Email Notification to Case Owners</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Deployment_Engineering_Notifications</template>
    </alerts>
    <rules>
        <fullName>Send Email to Case Owners ON DE Case Note Creation</fullName>
        <actions>
            <name>Send_Email_Notification_to_Case_Owners</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>DE_Note__c.Send_Email_To_Case_Owners__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
