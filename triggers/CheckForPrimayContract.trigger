/*
 * Checks all related contract records and displays error message if there are other primary contracts
 */
trigger CheckForPrimayContract on Contract (before insert, before update) 
{
    List<Id> accountIds = new List<Id>();
    List<Id> contractIds = new List<Id>();
    
    for(Contract c : Trigger.new)
    {
        if(c.SBQQ__MasterContract__c == true)
        {
            accountIds.add(c.AccountId);
            contractIds.add(c.Id);
        }
    }
    List<AggregateResult> primaryCounts = [select count(Id) c, AccountId a from contract where SBQQ__MasterContract__c = true AND AccountId in :accountIds and Id not in :contractIds group by AccountId];
    for(AggregateResult result : primaryCounts)
    {
        Integer count = (Integer)result.get('c');
        Id accountId = (Id)result.get('a');
        if(count > 0)
        {
            addErrorToContracts(accountId);
        }
    }
    
    private void addErrorToContracts(Id accountId)
    {
        for(Contract ct : Trigger.new)
        {
            if(ct.AccountId == accountId)
            {
                ct.addError('You may only have 1 master contract per account. Please edit the current master contract for this account before attempting to save this as the master contract.');
            }
        }
    }
}