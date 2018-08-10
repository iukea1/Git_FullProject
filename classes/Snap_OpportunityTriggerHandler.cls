/**
 * A trigger handler class, includes all the trigger methods for Opportunity.
 *
 * @author: SnapBI
 *
 * @changelog
 * 08/06/2018 Jason Zhao - Created.
 * 08/06/2018 Jason Zhao - Add: Create/Delete opportunity split when opportunity owner Or technical responsible is changed.
 * 08/10/2018 Eric He - Update: Leverage static variables to avoid recurring trigger.
 */
public class Snap_OpportunityTriggerHandler extends Snap_TriggerHandler
{
    public override void afterInsert()
    {
        createOppSplits();
    }

    public override void beforeUpdate()
    {
        deleteOppSplits();     
    }

    public override void afterUpdate()
    {
        createOppSplits();
    }

    private void createOppSplits()
    {
        List<OpportunitySplitType> splitTypes = [select Id from OpportunitySplitType where IsActive = true];
        if(!splitTypes.isEmpty())
        {
            List<OpportunitySplit> newSplits = new List<OpportunitySplit>();
            Opportunity newOpp, oldOpp;
            for(SObject sobj : Trigger.new)
            {
                newOpp = (Opportunity)sobj;
                if(Trigger.isInsert)
                {
                    // add Opportunity owner to the split
                    addSplits(newSplits, newOpp, newOpp.OwnerId, splitTypes);
                    // add Technical_Responsible__c to the split
                    if(newOpp.Technical_Responsible__c != null)
                    {
                        addSplits(newSplits, newOpp, newOpp.Technical_Responsible__c, splitTypes);
                    }
                }
                else if(Trigger.isUpdate)
                {
                    oldOpp = (Opportunity)Trigger.oldMap.get(newOpp.Id);
                    // add new Opportunity owner to the split                    
                    if(isFieldValueChanged(newOpp.OwnerId, oldOpp.OwnerId, SNAP_OpportunityTriggerController.oppOwnerInAfterUpdate))
                    {                        
                        addSplits(newSplits, newOpp, newOpp.OwnerId, splitTypes);
                        SNAP_OpportunityTriggerController.oppOwnerInAfterUpdate = newOpp.OwnerId;
                    }

                    // add new Technical_Responsible__c to the split
                    if(isFieldValueChanged(newOpp.Technical_Responsible__c, oldOpp.Technical_Responsible__c, SNAP_OpportunityTriggerController.oppTRInAfterUpdate))
                    {
                        SNAP_OpportunityTriggerController.oppTRInAfterUpdate = newOpp.Technical_Responsible__c;
                        if(newOpp.Technical_Responsible__c != null)
                        {
                            addSplits(newSplits, newOpp, newOpp.Technical_Responsible__c, splitTypes);
                        }
                    }
                }
            }   
            if(!newSplits.isEmpty())
            {
                // In case duplicate splits are added, this DML allows the splits to be partially created.
                Database.insert(newSplits, false);
            }
        }
    }

    private void deleteOppSplits()
    {
        Opportunity newOpp, oldOpp;
        Map<String, Set<Id>> oppIdMap = new Map<String, Set<Id>>{
            'RSM' => new Set<Id>(), 
            'SE' => new Set<Id>()
        };
            
        for(SObject sobj : Trigger.new)
        {
            newOpp = (Opportunity)sobj;
            oldOpp = (Opportunity)Trigger.oldMap.get(newOpp.Id);

            // delete all old RSM splits when the Opportunity owner is changed.
            if(isFieldValueChanged(newOpp.OwnerId, oldOpp.OwnerId, SNAP_OpportunityTriggerController.oppOwnerInBeforeUpdate))
            {
                oppIdMap.get('RSM').add(newOpp.Id);
                SNAP_OpportunityTriggerController.oppOwnerInBeforeUpdate = newOpp.OwnerId;
            }            

            // delete all old SE splits when the Technical_Responsible__c is changed.
            if(isFieldValueChanged(newOpp.Technical_Responsible__c, oldOpp.Technical_Responsible__c, SNAP_OpportunityTriggerController.oppTRInBeforeUpdate))
            {
                oppIdMap.get('SE').add(newOpp.Id);
                SNAP_OpportunityTriggerController.oppTRInBeforeUpdate = newOpp.Technical_Responsible__c;
            }
        }
        for(String roleType : oppIdMap.keySet())
        {
            Set<Id> oppIds = oppIdMap.get(roleType);
            if(!oppIds.isEmpty())
            {
                delete [select Id from OpportunitySplit where SplitType.IsActive = true and OpportunityId in :oppIds and Role_Type__c = :roleType];
            }
        }
    }

    private void addSplits(List<OpportunitySplit> newSplits, Opportunity opp, Id ownerId, List<OpportunitySplitType> splitTypes)
    {
        for(OpportunitySplitType sType : splitTypes)
        {
            newSplits.add(new OpportunitySplit(SplitOwnerId = ownerId, OpportunityId = opp.Id, SplitTypeId = sType.Id, SplitPercentage = 100));
        }
    }

    private static Boolean isFieldValueChanged(String newFieldValue, String oldFieldValue, String auditFieldValue)
    {
        if(auditFieldValue == '')
        {
            return newFieldValue != oldFieldValue;
        }
        else
        {
            return newFieldValue != auditFieldValue;
        }
    }
}