public class CalculateActiveSubCountBatch implements Database.Batchable<sObject>, Database.Stateful 
{
	
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select AccountId from Contract where Trigger_Account_Sync__c=true and Evaluation_Quote__c=false]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        List<Contract> lstContract=(List<Contract>)scope;
        Set<Id> accIds= new Set<Id>();
        List<Account> lstAccountToUpdate= new List<Account>();
        List<Contract> lstContractToUpdate= new List<Contract>();
        Map<Id,Account> mapAccountCount= new Map<Id,Account>();
        Map<Id,Account> mapCustomerDate= new Map<Id,Account>();
        for(Contract item: lstContract)
        {
            accIds.add(item.AccountId);
        }
        mapAccountCount=CalculateAssetCount(accIds);
        mapCustomerDate=CalculateCustomerDate(accIds);
         for(Id accountId: accIds)
        {
            Account acc= new Account(Id=accountId);
            if(mapAccountCount.containsKey(accountId))
            {
                Account outputAcc=mapAccountCount.get(accountId);
                acc.Active_Asset_Count__c=outputAcc.Active_Asset_Count__c;
            }
            
            if(mapCustomerDate.containsKey(accountId))
            {
                Account outputAcc=mapCustomerDate.get(accountId);
                System.debug('outputAcc.WAN_OP_Customer_Date__c'+outputAcc.WAN_OP_Customer_Date__c);
                System.debug('outputAcc.EC_Customer_Date__c'+outputAcc.EC_Customer_Date__c);
                if(outputAcc.WAN_OP_Customer_Date__c!=null)
                    acc.WAN_OP_Customer_Date__c=outputAcc.WAN_OP_Customer_Date__c;
                if(outputAcc.EC_Customer_Date__c!= null)
                    acc.EC_Customer_Date__c=outputAcc.EC_Customer_Date__c;   
            }
            System.debug('output acc'+ acc);
            lstAccountToUpdate.add(acc);
        }
        System.Savepoint sp= Database.setSavepoint();
        try
        {
           if(lstAccountToUpdate.size()>0)
            {
                update lstAccountToUpdate;
               System.debug('accts are updated');
            }
            for(Contract item: lstContract)
            {
                lstContractToUpdate.add(new Contract(Id=item.Id,Trigger_Account_Sync__c=false));
            }
            if(lstContractToUpdate.size()>0)
            {
                update lstContractToUpdate;
            }
        }
        catch(Exception ex)
        {
            Database.Rollback(sp);
            System.debug('Error in log'+ ex);
            SilverPeakUtils.logException(ex);
        }
        
    }
    
    public void finish(Database.BatchableContext context)
    {
        if(!Test.isRunningTest())
        {
            CalculateActiveSubCountBatch obj= new CalculateActiveSubCountBatch();
            System.scheduleBatch(obj, 'Trigger Sub Count and Customer Date', 60);
        }
        
    }
  	private static Map<Id,Account> CalculateAssetCount(Set<Id> setAccIds)
    {
        
        AggregateResult[] lstNXVXCount=[Select SBQQ__Account__c, Sum(Active_Sub_Count__c)counter from SBQQ__Subscription__c where SBQQ__Account__c in:setAccIds and SBQQ__Contract__r.Evaluation_Quote__c=false and SBQQ__Product__r.Product_Type__c='NX/VX' and SBCF_Subscription_Status__c ='Customer Subscription Active'  GROUP BY SBQQ__Account__c];
       	AggregateResult[] lstECSub=[Select SBQQ__Account__c, Count(Id)counter from SBQQ__Subscription__c where SBQQ__Account__c in:setAccIds and SBQQ__Product__r.Product_Type__c='EDGECONNECT' and SBQQ__Contract__r.Evaluation_Quote__c=false and SBQQ__Product__r.Name like 'EC%' and SBCF_Subscription_Status__c ='Customer Subscription Active'  GROUP BY SBQQ__Account__c];
        Map<Id,integer> mapVirtualAssets= new Map<Id,integer>();
        Map<Id,integer> mapVirtualOwnedAssets= new Map<Id,integer>();
        Map<Id,Account> mapAccountToUpdate= new Map<Id,Account>();
        System.debug('lstNXVXCount'+ lstNXVXCount);
        if(lstNXVXCount!=null && lstNXVXCount.size()>0)
        {
            mapVirtualAssets=GetCountfromList(lstNXVXCount);
        }
        if(lstECSub!=null && lstECSub.size()>0)
        {
            mapVirtualOwnedAssets=GetCountfromList(lstECSub);
        }
        for(Id accId :setAccIds)
        {
            integer assetCount=0;
            if(mapVirtualAssets.containsKey(accId))
            {
                assetCount+=mapVirtualAssets.get(accId);
            }
            if(mapVirtualOwnedAssets.containsKey(accId))
            {
                assetCount+=mapVirtualOwnedAssets.get(accId);
            }
            mapAccountToUpdate.put(accId,new Account(Id=accId,Active_Asset_Count__c=assetCount));
        }
        
        return mapAccountToUpdate;
    }
    
    private static Map<Id,Account> CalculateCustomerDate(Set<Id> setAccIds)
    {
        Map<Id,Date> mapWanOpIds= new Map<Id,Date>();
        Map<Id,Date> mapECIds= new Map<Id,Date>();
        Map<Id,account> lstAccountToUpdate= new Map<Id,Account>();
        AggregateResult[] ecAggr=[Select AccountId, Min(StartDate) custDate  from Contract where AccountId in:setAccIds and Status='Activated' and Evaluation_Quote__c=false and Product_Type__c='EDGECONNECT' GROUP BY AccountId];
        AggregateResult[] wanOppAggr=[Select AccountId, Min(StartDate)custDate  from Contract where AccountId in:setAccIds and Status='Activated' and Evaluation_Quote__c=false and Product_Type__c='NX/VX' GROUP BY AccountId];
        if(ecAggr!=null&& ecAggr.size()>0)
        {
            for(AggregateResult ar: ecAggr)
            {
                Id accId= (Id) ar.get('AccountId');
                Date custDate=Date.valueOf(ar.get('custDate'));
                mapECIds.put(accId,custDate);
            }
        }
        if(wanOppAggr!=null&& wanOppAggr.size()>0)
        {
            for(AggregateResult ar: wanOppAggr)
            {
                Id accId= (Id) ar.get('AccountId');
                Date custDate=Date.valueOf(ar.get('custDate'));
                mapWanOpIds.put(accId,custDate);
            }
        }
        for(Id accId: setAccIds)
        {    
            Account newAcc= new Account(Id=accId);
            if(mapWanOpIds.containsKey(accId))
            {
                Date dt=mapWanOpIds.get(accId);
                if(dt!=null){
                    newAcc.WAN_OP_Customer_Date__c=DateTime.newInstanceGmt(dt.year(), dt.month(), dt.day(), 23, 59, 59);}
            }
            if(mapECIds.containsKey(accId))
            {
                Date dt=mapECIds.get(accId);
                if(dt!=null){
                    newAcc.EC_Customer_Date__c=DateTime.newInstanceGmt(dt.year(), dt.month(), dt.day(), 23, 59, 59);}
            }
            if(newAcc.EC_Customer_Date__c!=null || newAcc.WAN_OP_Customer_Date__c!=null)
            {
                System.debug(newAcc);
                lstAccountToUpdate.put(newAcc.Id, newAcc);
            }
            
        }
        return lstAccountToUpdate;
        
    }
    private static Map<Id,integer> GetCountfromList(AggregateResult[] lstSubs)
    {
        Map<Id,integer> mapReturnData= new Map<Id,integer>();
        if(lstSubs!=null && lstSubs.size()>0)
        {
            for(AggregateResult ar:lstSubs)
            {
                integer count= integer.valueOf(ar.get('counter'));
                mapReturnData.put((Id)ar.get('SBQQ__Account__c'),count);
            }
        }
        
        return mapReturnData;
    }
}