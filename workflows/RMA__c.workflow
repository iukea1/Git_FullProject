<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CMA_Conversion_Request_Has_Been_Processed</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>CMA Conversion Request Has Been Processed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/CmaRequestProcessedResult</template>
    </alerts>
    <alerts>
        <fullName>DispatchStateChanged</fullName>
        <ccEmails>returns@silver-peak.com</ccEmails>
        <description>DispatchStateChanged</description>
        <protected>false</protected>
        <senderAddress>returns@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/RMADispatchStateChanged</template>
    </alerts>
    <alerts>
        <fullName>DispatchStateNotChanged</fullName>
        <ccEmails>returns@silver-peak.com</ccEmails>
        <description>DispatchStateNotChanged</description>
        <protected>false</protected>
        <senderAddress>returns@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/RMADispatchStateNotChanged</template>
    </alerts>
    <alerts>
        <fullName>EvalRMAClosed</fullName>
        <ccEmails>returns@silver-peak.com</ccEmails>
        <description>Notify customer and account team that all units have been received back</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Contact_Loc_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact_Loc_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact_Loc_3__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact_Loc_4__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Account_Manager_Email_1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Account_Manager_Email_2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>System_Engineer_Email_1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>System_Engineer_Email_2__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>returns@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/RMAClosure</template>
    </alerts>
    <alerts>
        <fullName>NX_Appliance_Recycling_Instructions</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>NX Appliance Recycling Instructions</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Contact_Loc_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact_Loc_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Account_Manager_Email_1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Account_Manager_Email_2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email_Loc_2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email_Loc_3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email_Loc_4__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>System_Engineer_Email_1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>System_Engineer_Email_2__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/NXApplianceRecyclingInstructions</template>
    </alerts>
    <alerts>
        <fullName>RMAisClosed</fullName>
        <description>RMA is Closed</description>
        <protected>false</protected>
        <recipients>
            <recipient>dennis@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ttedijanto@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/RMAClosure</template>
    </alerts>
    <alerts>
        <fullName>Return_Shipment_Instructions</fullName>
        <ccEmails>notifications@silver-peak.com,returns@silver-peak.com</ccEmails>
        <description>Return Shipment Instructions</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Contact_Loc_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact_Loc_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Account_Manager_Email_1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Account_Manager_Email_2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email_Loc_2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email_Loc_3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email_Loc_4__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>System_Engineer_Email_1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>System_Engineer_Email_2__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>POC/Return_Shipping_Instructions_2010</template>
    </alerts>
    <alerts>
        <fullName>Return_Shipment_Instructions_Non_Eval_RMA</fullName>
        <description>Return Shipment Instructions - Non Eval RMA&apos;s</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>lquilici@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pmusunuru@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/NonEvalReturn_Shipping_Instructions</template>
    </alerts>
    <alerts>
        <fullName>Send_Recycling_Instructions</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <ccEmails>tseteam@silver-peak.com</ccEmails>
        <description>Send Recycling Instructions</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Contact_Loc_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact_Loc_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Account_Manager_Email_1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Account_Manager_Email_2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email_Loc_2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email_Loc_3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email_Loc_4__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>System_Engineer_Email_1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>System_Engineer_Email_2__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/NonEvalReturn_Recycling_Instructions</template>
    </alerts>
    <alerts>
        <fullName>Send_Tracking_Information_Email</fullName>
        <description>Send Tracking Information Email</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Contact_Email_Loc_4__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>cs@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dennis@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>returns@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/RMA_Tracking_Info</template>
    </alerts>
    <fieldUpdates>
        <fullName>ClearIsRecyclingField</fullName>
        <field>IsRecycling__c</field>
        <literalValue>0</literalValue>
        <name>Clear IsRecycling Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EDIAckRecd</fullName>
        <field>Pending_EDI_Ack__c</field>
        <literalValue>0</literalValue>
        <name>EDIAckRecd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RMAContactEmailLoc1</fullName>
        <field>Contact_Email__c</field>
        <formula>if(OR(ischanged(Contact_Loc_1__c ),isnew()), Contact_Loc_1__r.Email , Contact_Email__c )</formula>
        <name>RMAContactEmailLoc1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RMAContactEmailLoc2</fullName>
        <field>Contact_Email_Loc_2__c</field>
        <formula>if(OR(ischanged( Contact_Loc_2__c),isnew()) , Contact_Loc_2__r.Email , Contact_Email_Loc_2__c )</formula>
        <name>RMAContactEmailLoc2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RMAContactEmailLoc3</fullName>
        <field>Contact_Email_Loc_3__c</field>
        <formula>if(OR(ischanged( Contact_Loc_3__c ),isnew()), Contact_Loc_3__r.Email , Contact_Email_Loc_3__c )</formula>
        <name>RMAContactEmailLoc3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RMAContactEmailLoc4</fullName>
        <field>Contact_Email_Loc_4__c</field>
        <formula>if(OR(ischanged( Contact_Loc_4__c ),isnew()), Contact_Loc_4__r.Email , Contact_Email_Loc_4__c )</formula>
        <name>RMAContactEmailLoc4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RMAContactPhoneLoc1</fullName>
        <description>Update the RMA Contact Phone if the Contact is selected</description>
        <field>Contact_Phone__c</field>
        <formula>if(OR(ischanged( Contact_Loc_1__c ), isnew()), Contact_Loc_1__r.Phone ,  Contact_Phone__c  )</formula>
        <name>RMAContactPhoneLoc1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RMAContactPhoneLoc2</fullName>
        <field>Contact_Phone_Loc_2__c</field>
        <formula>if(OR(ischanged( Contact_Loc_2__c),isnew()) , Contact_Loc_2__r.Phone , Contact_Phone_Loc_2__c )</formula>
        <name>RMAContactPhoneLoc2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RMAContactPhoneLoc3</fullName>
        <field>Contact_Phone_Loc_3__c</field>
        <formula>if(OR(ischanged( Contact_Loc_3__c ),isnew()), Contact_Loc_3__r.Phone , Contact_Phone_Loc_3__c )</formula>
        <name>RMAContactPhoneLoc3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RMAContactPhoneLoc4</fullName>
        <field>Contact_Phone_Loc_4__c</field>
        <formula>if(OR(ischanged( Contact_Loc_4__c ),isnew()), Contact_Loc_4__r.Phone , Contact_Phone_Loc_4__c )</formula>
        <name>RMAContactPhoneLoc4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetPendingEDIAck</fullName>
        <field>Pending_EDI_Ack__c</field>
        <literalValue>1</literalValue>
        <name>SetPendingEDIAck</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetRMAforDispatch</fullName>
        <field>Status__c</field>
        <literalValue>Dispatched</literalValue>
        <name>SetRMAforDispatch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatePartnerRMANoticeEmail</fullName>
        <description>This will update the email field with the text version copied over from an account. The acocunt email is validated upon entry should we assume here that the data will pass validation too</description>
        <field>Partner_Notification__c</field>
        <formula>Partner_Notification_Text__c</formula>
        <name>UpdatePartnerRMANoticeEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AutoDispatchCustomerRMA%27s</fullName>
        <actions>
            <name>SetRMAforDispatch</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>equals</operation>
            <value>Customer Portal Manager,Customer Portal User,High Volume Portal</value>
        </criteriaItems>
        <description>when a customer portal user creates an RMA, then auto dispatch it</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Cma Request Processed Result</fullName>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CMA_Conversion_Request_Has_Been_Processed</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>DispatchAccepted</fullName>
        <actions>
            <name>DispatchStateChanged</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>EDIAckRecd</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Notify RMA Owner and Creator when a dispatch is accepted</description>
        <formula>And( ISCHANGED( Status__c ) ,  ISPICKVAL( Status__c , &apos;Dispatch Accepted&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DispatchMade</fullName>
        <actions>
            <name>SetPendingEDIAck</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule is designed to send an email alert when the EDI order has been dispatched.</description>
        <formula>And(
 ISPICKVAL( Status__c , &apos;Initiated&apos;) ,
 ISPICKVAL(PRIORVALUE( Status__c) , &apos;Dispatched&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DispatchMadeAwaitingResponse</fullName>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.Pending_EDI_Ack__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This rule is designed to when the EDI order has been dispatched and when we get a response. If no response in 60 minutes, then fire an email to owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>DispatchStateNotChanged</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>DispatchRejected</fullName>
        <actions>
            <name>DispatchStateChanged</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>EDIAckRecd</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Notify RMA Owner and Creator when a dispatch is rejected</description>
        <formula>And( ISCHANGED( Status__c ) ,  ISPICKVAL( Status__c , &apos;Dispatch Rejected&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NX Appliance Recycling Instructions</fullName>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.IsRecycling__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>NX_Appliance_Recycling_Instructions</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>ClearIsRecyclingField</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>POC RMA Closure notification</fullName>
        <actions>
            <name>EvalRMAClosed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.Type__c</field>
            <operation>equals</operation>
            <value>Eval Return</value>
        </criteriaItems>
        <description>Notice sent when a POC RMA is closed after all items are returned</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMA Closure notification</fullName>
        <actions>
            <name>RMAisClosed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>RMA__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.Type__c</field>
            <operation>notEqual</operation>
            <value>Eval Return</value>
        </criteriaItems>
        <description>Notice sent to tseteam and seteam upon RMA closure for feedback loop</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMA Email Trigger</fullName>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.Type__c</field>
            <operation>equals</operation>
            <value>Eval Return</value>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.IsRecycling__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>An email sent whenever an Eval RMA is created. Additionally emails will go out to the contacts on the RMA with the return shipping instructions.</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Return_Shipment_Instructions</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>RMA Email Trigger-NonEval</fullName>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.Type__c</field>
            <operation>notEqual</operation>
            <value>Eval Return</value>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.IsRecycling__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>An email sent whenever a non-eval RMA is created. Additionally emails will go out to the contacts on the RMA with the return shipping instructions.</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Return_Shipment_Instructions_Non_Eval_RMA</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>RMA__c.Trigger_Time_05__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>RMA Email Trigger-Recycling</fullName>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>CMA</value>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.IsRecycling__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>An email sent whenever a non-eval RMA is created. Additionally emails will go out to the contacts on the RMA with the return shipping instructions.</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Recycling_Instructions</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>RMATriggerforFieldUpdates</fullName>
        <actions>
            <name>RMAContactEmailLoc1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RMAContactEmailLoc2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RMAContactEmailLoc3</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RMAContactEmailLoc4</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RMAContactPhoneLoc1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RMAContactPhoneLoc2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RMAContactPhoneLoc3</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RMAContactPhoneLoc4</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Eval RMA</value>
        </criteriaItems>
        <description>FieldUpdates watch for contacts to be edited and then update phone and email form the contact record when a contact is selected.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Tracking Information</fullName>
        <actions>
            <name>Send_Tracking_Information_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Contact, Creator and Account Owner when tracking information is updated.</description>
        <formula>AND(
ISCHANGED( Tracking_Information__c ),
ISPICKVAL( Status__c, &apos;Shipped&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePartnerRMANoticeEmail</fullName>
        <actions>
            <name>UpdatePartnerRMANoticeEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Eval RMA</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
