public class SubscriptionSharingJob implements  Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([Select Id,CompletedDate from AsyncApexJob where JobType='BatchApex'  and Status='Completed' and ApexClass.Name='SubscriptionSharingJob' order by CompletedDate desc LIMIT 1]);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        Date targetDate=Date.today();
        
        System.debug('New Batch');
        List<AccountShare> accShares= new List<AccountShare>();
        Set<Id> setAccIds= new Set<ID>();
        Set<Id> setAddUserGroupIds= new Set<ID>();
        List<AsyncApexJob> lstJobs = (List<AsyncApexJob>)scope;
        List<SBQQ__Subscription__Share> lstAddSubscriptionShare= new List<SBQQ__Subscription__Share>();
        List<SBQQ__Subscription__Share> lstDeleteSubShareIds= new List<SBQQ__Subscription__Share>();
        if(lstJobs!=null&& lstJobs.size()>0)
        {
            targetDate=Date.valueOf(lstJobs[0].CompletedDate)   ;
             System.debug('targetDate.time()'+lstJobs[0].CompletedDate);
        }
        System.debug('targetDate'+targetDate.format());
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
            for(Id acctId: setAccIds)
            {
                Set<Id> setShareRoles=new Set<Id>();
                Set<Id> setShareUsers=new Set<Id>();
                Set<Id> roleIds= new Set<Id>();
                Set<Id> userIds= new Set<Id>();
                // Extract roleIds for each account from the map values
                if(mapAccountRoleIds!=null && mapAccountRoleIds.size()>0)
                    roleIds=mapAccountRoleIds.get(acctId);
                if(mapAccountUserIds!=null && mapAccountUserIds.size()>0)
                    userIds=mapAccountUserIds.get(acctId);
                // Extract userIds for each account from the map values
                System.debug('acc roleIds'+roleIds);
                System.debug('acc userIds'+userIds);
                //for each account get sub share and usergroup Ids
                Map<Id,Id> mapSubRoleIds=SubscriptionHelper.GetSubRoleIds(acctId);
                System.debug('mapSubRoleIds' +mapSubRoleIds);
                Map<Id,Id> mapSubUserIds=SubscriptionHelper.GetSubUserIds(acctId);
                System.debug('mapSubUserIds' +mapSubUserIds);
                //loop for each roles and check whether exists. If not delete.
                if(mapSubRoleIds!=null && mapSubRoleIds.size()>0)
                {
                    for(Id subId:mapSubRoleIds.keyset())
                    {
                        Id roleId=mapSubRoleIds.get(subId);
                        if(!roleIds.contains(roleId) || roleIds.size()==0)
                        {
                            lstDeleteSubShareIds.add(new SBQQ__Subscription__Share(Id=subId));
                        }
                    }
                    List<Id> lstShareRoles=mapSubRoleIds.values();
                    setShareRoles.addAll(lstShareRoles);                        
                }
                System.debug('userIds '+userIds);
                //loop for each users and check whether exists. If not delete.
                if(mapSubUserIds!=null && mapSubUserIds.size()>0)
                {
                    for(Id subId:mapSubUserIds.keyset())
                    {
                        Id userId=mapSubUserIds.get(subId);
                        System.debug('userId '+userId);
                        if(!userIds.contains(userId) || userIds.size()==0)
                        {
                            lstDeleteSubShareIds.add(new SBQQ__Subscription__Share(Id=subId));
                        }
                    }
                    List<Id> lstShareUsers=mapSubUserIds.values();
                    setShareUsers.addAll(lstShareUsers);  
                }
                if(roleIds!=null &&roleIds.size()>0)
                {
                    for(Id item:roleIds)
                    {
                        if(!setShareRoles.contains(item))
                        {
                            setAddUserGroupIds.add(item);
                        }
                    }
                }
                if(userIds!=null &&userIds.size()>0)
                {
                    for(Id item:userIds)
                    {
                        if(!setShareUsers.contains(item))
                        {
                            setAddUserGroupIds.add(item);
                        }
                    }
                }
                
                if(setAddUserGroupIds.size()>0)
                {
                    List<SBQQ__Subscription__c> lstSubToInsert=SubscriptionHelper.RetreiveExistingSubs(acctId);
                    for(Id counter:setAddUserGroupIds)
                    {
                        if(lstSubToInsert!=null && lstSubToInsert.size()>0)
                        {
                            for(SBQQ__Subscription__c item:lstSubToInsert)
                            {
                                lstAddSubscriptionShare.add(new SBQQ__Subscription__Share(ParentId=item.Id,AccessLevel='Read',UserOrGroupId=counter));
                            }
                        }
                    }
                }
            }
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
            System.scheduleBatch(obj, 'SubscriptionSharing', 15);        
        }
    }
    
    
    
}