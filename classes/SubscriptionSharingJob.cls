public class SubscriptionSharingJob implements  Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([Select Id,CompletedDate from AsyncApexJob where JobType='BatchApex'  and Status='Completed' and ApexClass.Name='SubscriptionSharingJob' order by CompletedDate desc LIMIT 1]);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        DateTime targetDate=null;
        ID roleID;
        String str;
        UserRole role;
        List<ID> roleIDs;
        ID UserOrGroupId;
        Group shareGroup;
        Map<ID, UserRole> roles;
        Map<ID, Group> shareGroups;
        List<AccountShare> accShares;
        List<AsyncApexJob> lstJobs = (List<AsyncApexJob>)scope;
        if(lstJobs!=null&& lstJobs.size()>0)
        {
            targetDate=lstJobs[0].CompletedDate;
        }
        // Find Account Shares For Account
        if(targetDate!=null)
            accShares = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause FROM AccountShare WHERE Account.Type in('Customer','Partner')and LastModifiedDate >=:targetDate AND isDeleted = false];
        else
            accShares = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause FROM AccountShare WHERE Account.Type in('Customer','Partner')and isDeleted = false];
        try
        {
            
            
            
            
        }
        
        catch(Exception ex)
        {
            //Database.rollback(sp);
            System.debug(ex);
            SilverPeakUtils.logException('Subscription Sharing Job Failure',ex.getMessage());
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
    
    private Set<Id> GetUserAndRoleIds(Id AccountID)
    {
        Map<ID, Group> shareGroups;
        List<User> shareUsers;
        List<UserRole> roles;
        List<ID> roleIDs;
        Set<Id> setResultIds= new Set<Id>();
        shareGroups = new Map<ID, Group>([SELECT Id, Name, RelatedId, Type FROM Group WHEre Id IN (SELECT UserOrGroupId FROM AccountShare WHERE AccountId = :AccountID)]);
        shareUsers= [SELECT Id,Contact.AccountId FROM User Where UserType in('PowerPartner')and IsActive=true and Id IN (SELECT UserOrGroupId FROM AccountShare WHERE AccountId = :AccountID)];
        // Get Role IDs
        roleIDs = new List<ID>();
        for (Group shareGroup1 : shareGroups.values()) {
            roleIDs.add(shareGroup1.RelatedId);
        }
        
        roles = [SELECT Id,Name,ParentRoleId,PortalAccountId,PortalAccountOwnerId,PortalRole,PortalType FROM UserRole WHERE id IN :roleIDs and PortalType in('CustomerPortal','Partner')];
        if(roles!=null && roles.size()>0)
        {
            for (UserRole role : roles) {
                setResultIds.add(role.Id);
            }
        }
        if(shareUsers!=null && shareUsers.size()>0)
        {
            for (User user : shareUsers) {
                setResultIds.add(user.Id);
            }
        }
        return setResultIds;
    }
}