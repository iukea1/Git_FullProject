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
        for(SObject newItem : newItems.values())
        {
            newSplits.add((OpportunitySplit)newItem);
        }
    }
    
    public void afterDelete(Map<Id, SObject> oldItems)
    {

    }
    
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        
    }

    private static void trackOpportunitySplits()
    {

    }
}