public class SubscriptionSharingJob implements  Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([Select Id,CompletedDate from AsyncApexJob where NumberOfErrors=0 and JobType='BatchApex'  and Status='Completed' and ApexClass.Name='SubscriptionSharingJob' order by CompletedDate desc LIMIT 1]);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        DateTime targetDate=Datetime.now();
        System.debug('New Batch');
        List<AccountShare> accShares= new List<AccountShare>();
        Set<Id> setAccIds= new Set<ID>();
        Set<Id> setAddUserGroupIds= new Set<ID>();
        Set<Id> setAllUserOrGroupIds= new Set<Id>();
        List<AsyncApexJob> lstJobs = (List<AsyncApexJob>)scope;
        List<SBQQ__Subscription__Share> lstAddSubscriptionShare= new List<SBQQ__Subscription__Share>();
        List<SBQQ__Subscription__Share> lstDeleteSubShareIds= new List<SBQQ__Subscription__Share>();
        if(lstJobs!=null&& lstJobs.size()>0)
        {
        	Integer offset = UserInfo.getTimezone().getOffset(lstJobs[0].CompletedDate);
			Datetime local = lstJobs[0].CompletedDate.addSeconds(offset/1000);
            targetDate=local;
           
            System.debug('targetDate.time()'+targetDate);
        }
       	System.debug('targetDate.time()'+targetDate);
        // Find Account Shares For Account
        if(targetDate!=null)
            accShares = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause FROM AccountShare WHERE LastModifiedDate >=:targetDate AND isDeleted = false];
       
        if(accShares.size()>0)
        {
            for(AccountShare accShare: accShares)
            {
                setAccIds.add(accShare.AccountId);
            	setAllUserOrGroupIds.add(accShare.UserOrGroupId);
            }
            accShares = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause FROM AccountShare WHERE AccountId in:setAccIds AND isDeleted = false];
        }
        if(setAccIds!=null && setAccIds.size()>0)
        {
         	List<SBQQ__Subscription__Share> lstDelSubs= new List<SBQQ__Subscription__Share>();
            Map<Id,List<SubscriptionHelper.SubscriptionWrapper>> mapSubData=new Map<Id,List<SubscriptionHelper.SubscriptionWrapper>>();
            List<SBQQ__Subscription__c> lstSubs=[select Id,SBQQ__Account__c from SBQQ__subscription__c where SBQQ__Account__c in:setAccIds];
            List<SBQQ__Subscription__Share> lstSubShares=[SELECT Id,ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE IsDeleted=false and ParentId in(select Id from SBQQ__subscription__c where SBQQ__Account__c in:setAccIds)];
            if(lstSubShares!=null && lstSubShares.size()>0)
            {
                for(SBQQ__Subscription__Share subShare: lstSubShares)
                {
                    setAllUserOrGroupIds.add(subShare.UserOrGroupId);
                }
            }
            
            Set<Id> setAllPortalIds=SubscriptionHelper.GetPortalIds(setAllUserOrGroupIds);
           
            
            Map<Id,Set<Id>> mapAccountRoleIds=SubscriptionHelper.GetPortalIdsByAccount(setAccIds,accShares,setAllPortalIds);
            System.debug('mapAccountRoleIds'+mapAccountRoleIds);
            mapSubData=SubscriptionHelper.GetSubscriptionByAcctIds(setAccIds,lstSubs,lstSubShares);
            System.debug('mapSubData'+mapSubData);
            if(mapAccountRoleIds!=null && mapAccountRoleIds.size()>0)
            {
                for(Id acctId: mapAccountRoleIds.keyset())
                {
                    System.debug('New Account');
                    Set<Id> setAcctPortalIds= mapAccountRoleIds.get(acctId);
                    List<SubscriptionHelper.SubscriptionWrapper> lstSubsByAccount= new List<SubscriptionHelper.SubscriptionWrapper>();
                    List<SubscriptionHelper.SubscriptionWrapper> lstPortalSubsByAccount= new List<SubscriptionHelper.SubscriptionWrapper>();
                    if(mapSubData!=null&& mapSubData.size()>0)
                    {
                        lstSubsByAccount=mapSubData.get(acctId);
                        lstPortalSubsByAccount=SubscriptionHelper.GetPortalIdsBySubscription(lstSubsByAccount,setAllPortalIds);
                        System.debug('lstPortalSubsByAccount'+lstPortalSubsByAccount);
                        List<SubscriptionHelper.SubscriptionWrapper> lstPortalSubsToDelete=SubscriptionHelper.GetSubSharesToDelete(lstPortalSubsByAccount,setAcctPortalIds);
                        System.debug('lstPortalSubsToDelete'+lstPortalSubsToDelete);
                        if(lstPortalSubsToDelete!=null && lstPortalSubsToDelete.size()>0)
                        {
                            for(SubscriptionHelper.SubscriptionWrapper item:lstPortalSubsToDelete)
                                lstDeleteSubShareIds.add(new SBQQ__Subscription__Share(Id=item.SubShareId));
                        }
                    }
                   
                    
                    Map<Id,Id> mapSubToAdd=SubscriptionHelper.GetSubSharesToAdd(acctId,lstSubs,lstPortalSubsByAccount,setAcctPortalIds);
                     System.debug('mapSubToAdd'+mapSubToAdd);
                    if(mapSubToAdd!=null && mapSubToAdd.size()>0)
                    {
                        for(Id item:mapSubToAdd.keyset())
                        	lstAddSubscriptionShare.add(new SBQQ__Subscription__Share(ParentId=item,AccessLevel='Read',UserOrGroupID=mapSubToAdd.get(item)));
                    }
                }
            }
            System.Savepoint sp= Database.setSavepoint();
            try
            {
                System.debug('lstDeleteSubShareIds'+lstDeleteSubShareIds);
                System.debug('lstAddSubscriptionShare'+lstAddSubscriptionShare);
                if(lstDeleteSubShareIds!=null&& lstDeleteSubShareIds.size()>0)
                    delete lstDeleteSubShareIds; 
                if(lstAddSubscriptionShare!=null && lstAddSubscriptionShare.size()>0)
                    insert lstAddSubscriptionShare;
                
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                System.debug(ex);
                SilverPeakUtils.logException('Subscription Sharing Job Failure',ex.getMessage());
            }
            
        }
        
        
        
        
    }  
    public void finish(Database.BatchableContext BC)
    {
        if(!Test.isRunningTest())
        {
            SubscriptionSharingJob obj= new SubscriptionSharingJob();
            System.scheduleBatch(obj, 'SubscriptionSharing', 15,1);        
        }
    }
    
    
    
}