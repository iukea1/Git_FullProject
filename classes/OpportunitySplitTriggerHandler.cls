public class OpportunitySplitTriggerHandler implements ITriggerHandler 
{
    public OpportunitySplitTriggerHandler()
    {
        
    }    
    public Boolean IsDisabled()
    {
        return false;
    }
    public void beforeInsert(List<SObject> newItems)
    {
        
    }
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        
    }
    public void beforeDelete(Map<Id, SObject> oldItems)
    {

    }
    public void afterUndelete(Map<Id, SObject> newItems)
    {
    }

    public void afterInsert(Map<Id, SObject> newItems)
    {
        List<OpportunitySplit> newSplits = new List<OpportunitySplit>();
        OpportunitySplit newSplit;
        for(SObject newItem : newItems.values())
        {
            newSplit = (OpportunitySplit)newItem;
            // The Revenue splits are always auto-created, even if it's inactive, we need exclude them.
            if(newSplit.IsActive__c)
            {
                newSplits.add(newSplit);
            }            
        }

        // save the opportunity splits history in OpportunitySplitLog__c
        if(!newSplits.isEmpty())
        {
            trackOpportunitySplits(newSplits, null, newSplits.size(), 'Insert');
        }        
    }
    
    public void afterDelete(Map<Id, SObject> oldItems)
    {
        List<OpportunitySplit> oldSplits = new List<OpportunitySplit>();
        OpportunitySplit oldSplit;
        for(SObject oldItem : oldItems.values())
        {
            oldSplit = (OpportunitySplit)oldItem;
            if(oldSplit.IsActive__c)
            {
                oldSplits.add(oldSplit);
            }            
        }

        // save the opportunity splits history in OpportunitySplitLog__c
        if(!oldSplits.isEmpty())
        {
            trackOpportunitySplits(null, oldSplits, oldSplits.size(), 'Delete');
        }        
    }
    
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        List<OpportunitySplit> newSplits = new List<OpportunitySplit>();
        List<OpportunitySplit> oldSplits = new List<OpportunitySplit>();
        OpportunitySplit newSplit, oldSplit;

        for(Id splitId : newItems.keySet())
        {
            newSplit = (OpportunitySplit)newItems.get(splitId);
            oldSplit = (OpportunitySplit)oldItems.get(splitId);
            if(newSplit.IsActive__c)
            {
                // track the history when split percent or split owner or note changes
                if(newSplit.SplitPercentage != oldSplit.SplitPercentage 
                || newSplit.SplitOwnerId != oldSplit.SplitOwnerId
                || newSplit.SplitNote != oldSplit.SplitNote)
                {
                    newSplits.add(newSplit);
                    oldSplits.add(oldSplit);
                }
            }                        
        }

        if(!newSplits.isEmpty())
        {
            trackOpportunitySplits(newSplits, oldSplits, newSplits.size(), 'Update');
        }
    }

    private static void trackOpportunitySplits(List<OpportunitySplit> newSplits, List<OpportunitySplit> oldSplits, Integer size, String event)    
    {
        List<OpportunitySplitLog__c> splitLogs = new List<OpportunitySplitLog__c>();
        OpportunitySplit newSplit, oldSplit;
        for(Integer i = 0; i < size; i++)
        {
            newSplit = newSplits != null ? newSplits[i] : null;
            oldSplit = oldSplits != null ? oldSplits[i] : null;
            splitLogs.add(getSplitLog(newSplit, oldSplit, event));
        }

        if(!splitLogs.isEmpty())
        {
            insert splitLogs;
        }
    }

    private static OpportunitySplitLog__c getSplitLog(OpportunitySplit newSplit, OpportunitySplit oldSplit, String event)
    {
        return new OpportunitySplitLog__c(
            OpportunityId__c = newSplit != null ? newSplit.OpportunityId : oldSplit.OpportunityId,
            Opportunity_Split_ID__c = newSplit != null ? newSplit.Id : oldSplit.Id,
            Opportunity_Split_Type__c = newSplit != null ? newSplit.Opportunity_Split_Type__c : oldSplit.Opportunity_Split_Type__c,
            Team_Member_New__c = newSplit != null ? newSplit.SplitOwnerId : null,
            Team_Member_Old__c = oldSplit != null ? oldSplit.SplitOwnerId : null,
            SplitPercent_New__c = newSplit != null ? newSplit.SplitPercentage : null,
            SplitPercent_Old__c = oldSplit != null ? oldSplit.SplitPercentage : null,
            Split_Amount_New__c = newSplit != null ? newSplit.SplitAmount : null,
            Split_Amount_Old__c = oldSplit != null ? oldSplit.SplitAmount : null,
            Note_New__c = newSplit != null ? newSplit.SplitNote : null,
            Note_Old__c = oldSplit != null ? oldSplit.SplitNote : null,
            Event__c = event
        );
    }
}