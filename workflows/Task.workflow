<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Meeting_Feedback_RSM</fullName>
        <description>Meeting Feedback RSM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>prane@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/RSM_Meeting_Request_Feedback</template>
    </alerts>
    <alerts>
        <fullName>Send_an_email_to_BDR</fullName>
        <description>Send an email to BDR</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <recipient>prane@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Send_an_email_to_BDR_for_reschedule</template>
    </alerts>
    <rules>
        <fullName>New BDR Meeting Feedback</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>contains</operation>
            <value>New BDR Meeting</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Meeting_Feedback_RSM</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>New BDR Meeting Feedback1</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>contains</operation>
            <value>New BDR Meeting</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Meeting_Feedback_RSM</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>RSM No Show update</fullName>
        <actions>
            <name>Send_an_email_to_BDR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  OR(LastModifiedBy.Profile.Name == &quot;1.1- Regional Sales Manager&quot;, LastModifiedBy.Profile.Name == &quot;1.4- Intl Regional Sales Manager&quot; ),CONTAINS(Subject,&quot;New BDR Meeting&quot;), ISPICKVAL( Meeting_Rating__c,&quot;No Show/Cancelled&quot;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
