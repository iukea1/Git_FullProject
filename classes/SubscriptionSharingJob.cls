public class SubscriptionSharingJob implements  Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([Select Id,CompletedDate from AsyncApexJob where JobType='BatchApex'  and Status='Completed' and ApexClass.Name='SubscriptionSharingJob' order by CompletedDate desc LIMIT 1]);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        DateTime targetDate=null;
        List<AccountShare> accShares;
        Set<Id> setAccIds= new Set<ID>();
        List<AsyncApexJob> lstJobs = (List<AsyncApexJob>)scope;
        List<SBQQ__Subscription__Share> lstSubscriptionShare= new List<SBQQ__Subscription__Share>();
        if(lstJobs!=null&& lstJobs.size()>0)
        {
            targetDate=lstJobs[0].CompletedDate;
        }
        // Find Account Shares For Account
        if(targetDate!=null)
            accShares = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause FROM AccountShare WHERE Account.Type in('Customer','Partner')and LastModifiedDate >=:targetDate AND isDeleted = false];
        else
            accShares = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause FROM AccountShare WHERE Account.Type in('Customer','Partner')and isDeleted = false];
        
        for(AccountShare accShare: accShares)
            setAccIds.add(accShare.AccountId);
        
        if(setAccIds!=null && setAccIds.size()>0)
        {
           
            for(Id acctId: setAccIds)
        {
            //List<SBQQ__Subscription__Share> lstSubShares= [Select ParentId,UserOrGroupId from SBQQ__Subscription__Share where ParentId in(Select Id from SBQQ__Subscription__c where SBQQ__Account__c in:setAccIds)];
            
            try{
                
                
                
            }
            catch(Exception ex)
            {
                //Database.rollback(sp);
                System.debug(ex);
                SilverPeakUtils.logException('Subscription Sharing Job Failure',ex.getMessage());
            }
        }
        }
        
        
        
        
    }  
    public void finish(Database.BatchableContext BC)
    {
        if(!Test.isRunningTest())
        {
            SubscriptionSharingJob obj= new SubscriptionSharingJob();
            System.scheduleBatch(obj, 'SubscriptionSharing', 15);        
        }
    }
    
   
    
}