<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>test</fullName>
        <description>test</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>prane@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Welcome_Email_Test</template>
    </alerts>
    <fieldUpdates>
        <fullName>SBCF_Set_Contracted_to_True</fullName>
        <field>SBQQ__Contracted__c</field>
        <literalValue>1</literalValue>
        <name>SBCF Set Contracted to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SBCF_Set_Contracting_Method</fullName>
        <field>SBQQ__ContractingMethod__c</field>
        <literalValue>Single Contract</literalValue>
        <name>SBCF Set Contracting Method</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SBCF Set Contracted to True</fullName>
        <actions>
            <name>SBCF_Set_Contracted_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SBCF Set Contracting Method</fullName>
        <actions>
            <name>SBCF_Set_Contracting_Method</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( SBQQ__Quote__r.Product_Type__c , &quot;EDGECONNECT&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
