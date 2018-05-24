public class CheckVirtualSubscriptionsSyncFlag implements Schedulable, Database.Batchable<sObject>, Database.Stateful {    
    
    
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new CheckVirtualSubscriptionsSyncFlag(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id,Name from Account where Id in (SELECT SBQQ__Account__c FROM SBQQ__Subscription__c where Sync_With_Cloud_Portal__c =true) ]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        List<Account> lstAccounts=  (List<Account>) scope;
        List<Account> lstAccountsToUpdate= new List<Account>();
        Set<Id> setSoftwareAccIds= new Set<Id>();
        Set<Id> setHardwareAccIds= new Set<Id>();
        Set<Id> setAccIds= new Set<Id>();
        if(lstAccounts.size()>0)
        {
            for(Account acc :lstAccounts)
            {
                setAccIds.add(acc.Id);
            }
            List<SBQQ__Subscription__c> lstSub =[Select Id, SBQQ__Account__c, SBQQ__Product__r.Family from SBQQ__Subscription__c where SBQQ__Account__c in:setAccIds and Sync_With_Cloud_Portal__c =true];
            if(lstSub!=null && lstSub.size()>0)
            {
                for(SBQQ__Subscription__c item: lstSub)
                {
                    if(item.SBQQ__Product__r.Family=='Virtual Image')
                        setSoftwareAccIds.add(item.SBQQ__Account__c);
                    if(item.SBQQ__Product__r.Family=='Product')
                        setHardwareAccIds.add(item.SBQQ__Account__c);
                }
                for(Id item: setAccIds)
                {
                    Account acc= new Account(Id=item);
                    if(setSoftwareAccIds.size()>0 && setSoftwareAccIds.contains(item))
                    {
                        acc.Sync_Virtual_Assets_with_CP__c=true;
                    }
                    if(setHardwareAccIds.size()>0 && setHardwareAccIds.contains(item))
                    {
                        acc.Sync_with_Cloud_Portal__c=true;
                    }
                    lstAccountsToUpdate.add(acc);
                }
                if(lstAccounts.size()>0)
                {
                    update lstAccountsToUpdate;
                }
            }
            
        }
        
    }
    public void finish(Database.BatchableContext context)
    {
        if(!Test.isRunningTest())
        {
            CheckVirtualAssetsSyncFlag obj= new CheckVirtualAssetsSyncFlag();
            System.scheduleBatch(obj, 'Trigger Assets to sync in Cloud Portal', 30, 10);
        }
    }
    
    
    
}