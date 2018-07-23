public class SubscriptionHelper {
    
    
    
    //This method returns the list of UserGroupId and roleId.
    public static Map<Id,Id> GetAccountRoleIds(Id AccountID)
    {
        Map<ID, Group> shareGroups;
        List<User> shareUsers;
        List<UserRole> roles;
        Map<ID,Id> roleIDs;
        Map<Id,Id> setResultIds= new Map<Id,Id>();// roleId and UserOrGroupId
        shareGroups = new Map<ID, Group>([SELECT Id, Name, RelatedId, Type FROM Group WHEre Id IN (SELECT UserOrGroupId FROM AccountShare WHERE AccountId = :AccountID)]);
        shareUsers= [SELECT Id,Contact.AccountId FROM User Where UserType in('PowerPartner')and IsActive=true and Id IN (SELECT UserOrGroupId FROM AccountShare WHERE AccountId = :AccountID)];
        // Get Role IDs
        roleIDs = new Map<ID,Id>();
        for (Group shareGroup1 : shareGroups.values()) {
            roleIDs.put(shareGroup1.RelatedId,shareGroup1.Id);
        }
        
        roles = [SELECT Id,Name,ParentRoleId,PortalAccountId,PortalAccountOwnerId,PortalRole,PortalType FROM UserRole WHERE id IN :roleIDs.keyset() and PortalType in('CustomerPortal','Partner')];
        if(roles!=null && roles.size()>0)
        {
            for (UserRole role : roles) {
                Id groupId= roleIDs.get(role.Id);
                setResultIds.put(groupId,role.Id);
                
            }
        }
        
        return setResultIds;
    }
    
    public static Set<Id> GetAccountUserIds(Id AccountID)
    {
        Map<ID, Group> shareGroups;
        List<User> shareUsers;
        List<UserRole> roles;
        List<ID> roleIDs;
        Set<Id> setResultIds= new Set<Id>();
        
        shareUsers= [SELECT Id,Contact.AccountId FROM User Where UserType in('PowerPartner')and IsActive=true and Id IN (SELECT UserOrGroupId FROM AccountShare WHERE AccountId = :AccountID)];
        if(shareUsers!=null && shareUsers.size()>0)
        {
            for (User user : shareUsers) {
                setResultIds.add(user.Id);
            }
        }
        return setResultIds;
    }
    
    //This method returns the list of Subscription Based UserOrGroupId and role Id 
    public static Map<Id,Id> GetSubRoleIds(Id AccountID)
    {
        Map<ID, Group> shareGroups;
        List<User> shareUsers;
        List<UserRole> roles;
        Map<ID,Id> roleIDs;
        Set<Id> setSubShare= new Set<Id>();
        Map<Id,Id> mapRoleGroupIds= new Map<Id,Id>();// ShareId and UserOrGroupId
        Map<Id,Id> setResultIds= new Map<Id,Id>();// ShareId and UserOrGroupId
        
        List<SBQQ__Subscription__Share> lstSubShares=[SELECT ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE ParentId in(select Id from SBQQ__subscription__c where SBQQ__Account__c =:AccountID)];
        if(lstSubShares!=null && lstSubShares.size()>0)
        {
            for (SBQQ__Subscription__Share subShare : lstSubShares) {
                setSubShare.add(subShare.UserOrGroupId);
            }
            shareGroups = new Map<ID, Group>([SELECT Id, Name, RelatedId, Type FROM Group WHEre Id IN:setSubShare]);
            
            // Get Role IDs
            roleIDs = new Map<ID,Id>();
            for (Group shareGroup1 : shareGroups.values()) {
                roleIDs.put(shareGroup1.RelatedId,shareGroup1.Id);
            }
            
            roles = [SELECT Id,Name,ParentRoleId,PortalAccountId,PortalAccountOwnerId,PortalRole,PortalType FROM UserRole WHERE id IN :roleIDs.keyset() and PortalType in('CustomerPortal','Partner')];
            if(roles!=null && roles.size()>0)
            {
                for (UserRole role : roles) {
                    Id groupId= roleIDs.get(role.Id);
                    mapRoleGroupIds.put(groupId,role.Id);// userOrgroupId and roleID
                    
                }
            }
             for (SBQQ__Subscription__Share subShare : lstSubShares) {
                if(mapRoleGroupIds.containsKey(subshare.UserOrGroupId))
                	setResultIds.put(subShare.Id,subShare.UserOrGroupId);
            }
        }
        
        
        return setResultIds;
    }
    
    public static Map<Id,Id> GetSubUserIds(Id AccountID)
    {
        Map<Id,Id> mapResult= new Map<Id,Id>();// userId--subId
        Set<Id> setPartnerUsers= new Set<Id>();
        Map<Id,Id> mapSubShare= new Map<Id,Id>();
        List<SBQQ__Subscription__Share> lstSubShares=[SELECT ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE ParentId in(select Id from SBQQ__subscription__c where SBQQ__Account__c =:AccountID)];
        if(lstSubShares!=null && lstSubShares.size()>0)
        {
            for (SBQQ__Subscription__Share subShare : lstSubShares) {
                mapSubShare.put(subShare.ParentId, subShare.UserOrGroupId);
            }
            
            List<User> shareUsers= [SELECT Id,Contact.AccountId FROM User Where UserType in('PowerPartner')and IsActive=true and Id IN:mapSubShare.values() ];
            if(shareUsers!=null && shareUsers.size()>0)
            {
                for (User user : shareUsers) {
                    setPartnerUsers.add(user.Id);
                }
            }
            for (Id subShareId : mapSubShare.keySet()) {
                Id userId=mapSubShare.get(subShareId);
                if(setPartnerUsers.contains(userId))
                    mapResult.put(subShareId, userId);
            }
        }
        return mapResult;
    }
    
    public static void DeleteSubscriptionsShareRecords(List<SBQQ__Subscription__Share> lstSubShares)
    {
        if(lstSubShares!=null&& lstSubShares.size()>0)
            delete lstSubShares;   
    }
    public static void AddSubscriptionShare(List<SBQQ__Subscription__Share> lstSubShares)
    {
        if(lstSubShares!=null && lstSubShares.size()>0)
        {
            insert lstSubShares;
        }
        
        
    }
}