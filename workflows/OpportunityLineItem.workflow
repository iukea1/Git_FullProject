<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>training_order_closed</fullName>
        <ccEmails>curtisc@silver-peak.com</ccEmails>
        <description>training_order_closed</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Support/Training_order_closed</template>
    </alerts>
    <alerts>
        <fullName>wanstart_order_closed</fullName>
        <description>wanstart_order_closed</description>
        <protected>false</protected>
        <recipients>
            <recipient>curtisc@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/WANstart_order_closed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Inject_Term</fullName>
        <field>Subscription_Term__c</field>
        <formula>SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c</formula>
        <name>Inject Term</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Product_Set_Product_Type</fullName>
        <field>Product_Type__c</field>
        <formula>TEXT(Product2.Product_Type__c)</formula>
        <name>Opportunity Product: Set Product Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetLineDesciptiontoProductName</fullName>
        <field>Description</field>
        <formula>PricebookEntry.Product2.ProductCode</formula>
        <name>SetLineDesciptiontoProductName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>FU%3A SetLineDescriptionEqualToProduct</fullName>
        <actions>
            <name>SetLineDesciptiontoProductName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>1/1/2000</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Product%3A Created or Edited</fullName>
        <actions>
            <name>Opportunity_Product_Set_Product_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Subscription Price</fullName>
        <actions>
            <name>Inject_Term</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>NOT(ISBLANK( Opportunity.SBQQ__PrimaryQuote__c ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>training_order</fullName>
        <actions>
            <name>training_order_closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.ProductCode</field>
            <operation>equals</operation>
            <value>300013-001</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.ProductCode</field>
            <operation>equals</operation>
            <value>300013-002</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>wanstart_order</fullName>
        <actions>
            <name>wanstart_order_closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.ProductCode</field>
            <operation>equals</operation>
            <value>300019-002</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.ProductCode</field>
            <operation>equals</operation>
            <value>300019-001</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>WANstartOrderClosed</fullName>
        <assignedTo>dennis@silver-peak.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>An WANstart order was closed won</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>WANstart Order Closed</subject>
    </tasks>
</Workflow>
