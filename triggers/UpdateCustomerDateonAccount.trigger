trigger UpdateCustomerDateonAccount on Asset (after insert,after update) {
    Set<Id> setAcctIds= new Set<Id>();
    Map<Id,Datetime> mapWanOpIds= new Map<Id,Datetime>();
    Map<Id,Datetime> mapECIds= new Map<Id,Datetime>();
    if(Trigger.isInsert)
    {
        for(Asset counter: Trigger.New)
        {
            if(counter.AccountId!=null)
            {
                setAcctIds.add(counter.AccountId);                
            }
        }
    }
    if(Trigger.isUpdate)
    {
        for(Asset counter: Trigger.New)
        {
            Asset oldAsset= Trigger.oldMap.get(counter.Id);
            if(counter.AccountId!=null && counter.AccountId!=oldAsset.AccountId)
            {
                setAcctIds.add(counter.AccountId);                
            }
        } 
    }
    List<account> lstAccountToUpdate= new List<Account>();
    if(setAcctIds.size()>0)
    {
        List<Account> lstECAccount=[Select Id, (select Id,Name, CreatedDate from Assets where Product2.Name like 'EC%' and Status in('Customer Subscription Active','Customer Owned' ) order by CreatedDate asc LIMIT 1) from Account where Id in:setAcctIds and EC_Customer_Date__c=null];
        List<Account> lstWanOpAccount=[Select Id, (select Id,Name, CreatedDate from Assets where Product2.Product_Type__c='NX/VX' and Status in('Customer Subscription','Customer Owned' ) order by CreatedDate asc LIMIT 1) from Account where Id in:setAcctIds and WAN_OP_Customer_Date__c=null];
        if(lstECAccount!=null && lstECAccount.size()>0)
        {
            for(Account acc: lstECAccount)
            {
                List<Asset> lstAsset = acc.Assets;
                if(lstAsset!=null && lstAsset.size()>0)
                {
                    mapECIds.put(acc.Id,lstAsset[0].CreatedDate);
                }
            }
        }
        if(lstWanOpAccount!=null && lstWanOpAccount.size()>0)
        {
            for(Account acc: lstWanOpAccount)
            {
                List<Asset> lstAsset = acc.Assets;
                if(lstAsset!=null && lstAsset.size()>0)
                {
                    mapWanOpIds.put(acc.Id,lstAsset[0].CreatedDate);
                }
            }
        }
        for(Id accId: setAcctIds)
        {    
            Account newAcc= new Account(Id=accId);
            if(mapWanOpIds.containsKey(accId))
            {
                newAcc.WAN_OP_Customer_Date__c=mapWanOpIds.get(accId);
            }
            if(mapECIds.containsKey(accId))
            {
                newAcc.EC_Customer_Date__c=mapECIds.get(accId);
            }
            if(newAcc.EC_Customer_Date__c!=null || newAcc.WAN_OP_Customer_Date__c!=null)
            {
                lstAccountToUpdate.add(newAcc);
            }
            
        }
        if(lstAccountToUpdate.size()>0)
        {
            update lstAccountToUpdate;
        }
    }
}