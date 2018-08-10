public class SubscriptionSharingJob implements  Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([Select Id,CompletedDate from AsyncApexJob where JobType='BatchApex'  and Status='Completed' and ApexClass.Name='SubscriptionSharingJob' order by CompletedDate desc LIMIT 1]);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        DateTime targetDate=Date.today();
        
        System.debug('New Batch');
        List<AccountShare> accShares= new List<AccountShare>();
        Set<Id> setAccIds= new Set<ID>();
        Set<Id> setAddUserGroupIds= new Set<ID>();
        List<AsyncApexJob> lstJobs = (List<AsyncApexJob>)scope;
        List<SBQQ__Subscription__Share> lstAddSubscriptionShare= new List<SBQQ__Subscription__Share>();
        List<SBQQ__Subscription__Share> lstDeleteSubShareIds= new List<SBQQ__Subscription__Share>();
        if(lstJobs!=null&& lstJobs.size()>0)
        {
            //targetDate=Date.valueOf(lstJobs[0].CompletedDate);
        	Integer offset = UserInfo.getTimezone().getOffset(lstJobs[0].CompletedDate);
			Datetime local = lstJobs[0].CompletedDate.addSeconds(offset/1000);
            targetDate=local;
            System.debug('targetDate.time()'+targetDate);
        }
      
        // Find Account Shares For Account
        if(targetDate!=null)
            accShares = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause FROM AccountShare WHERE Account.Type in('Customer','Partner')and LastModifiedDate >=:targetDate AND isDeleted = false];
       
        if(accShares.size()>0)
        {
            for(AccountShare accShare: accShares)
                setAccIds.add(accShare.AccountId);
        }
        System.debug('setAccIds'+setAccIds);
        if(setAccIds!=null && setAccIds.size()>0)
        {
            // Get list of accounts and roleIds
            Map<Id,Set<Id>> mapAccountRoleIds=SubscriptionHelper.GetAccountRoleIds(setAccIds);
             // Get list of accounts and userIds
            Map<Id,Set<Id>> mapAccountUserIds=SubscriptionHelper.GetAccountUserIds(setAccIds);
            Map<Id,List<SubscriptionHelper.SubscriptionWrapper>> mapSubData=new Map<Id,List<SubscriptionHelper.SubscriptionWrapper>>();
            List<SBQQ__Subscription__c> lstSubs=[select Id,SBQQ__Account__c from SBQQ__subscription__c where SBQQ__Account__c in:setAccIds];
            List<SBQQ__Subscription__Share> lstSubShares=[SELECT Id,ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE IsDeleted=false and ParentId in(select Id from SBQQ__subscription__c where SBQQ__Account__c in:setAccIds)];
            mapSubData=SubscriptionHelper.GetSubscriptionByAcctIds(setAccIds,lstSubs,lstSubShares);
            
            //List<SubscriptionHelper.SubscriptionWrapper> lstAllSubWrapper= mapSubData.getValues();
          
            System.Savepoint sp= Database.setSavepoint();
            try
            {
                System.debug('lstDeleteSubShareIds'+lstDeleteSubShareIds);
                System.debug('lstAddSubscriptionShare'+lstAddSubscriptionShare);
                SubscriptionHelper.DeleteSubscriptionsShareRecords(lstDeleteSubShareIds);
                SubscriptionHelper.AddSubscriptionShare(lstAddSubscriptionShare);
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