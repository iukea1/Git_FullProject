<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Is_Hardware_Flag</fullName>
        <field>Is_Hardware__c</field>
        <literalValue>1</literalValue>
        <name>Update Is Hardware Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Is_Hardware_Flag_To_False</fullName>
        <field>Is_Hardware__c</field>
        <literalValue>0</literalValue>
        <name>Update Is Hardware Flag To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Is Hardware Flag To False</fullName>
        <actions>
            <name>Update_Is_Hardware_Flag_To_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote_Line_Address__c.Product_Family__c</field>
            <operation>notEqual</operation>
            <value>Product</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Is Hardware Flag To True</fullName>
        <actions>
            <name>Update_Is_Hardware_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote_Line_Address__c.Product_Family__c</field>
            <operation>equals</operation>
            <value>Product</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
