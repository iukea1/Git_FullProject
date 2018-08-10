public class SubscriptionHelper {
    
    //This method returns the list of AccountId and GroupID.
    public static Map<Id,Set<Id>> GetAccountRoleIds(Set<Id> setAcctIds)
    {
        Map<ID, Group> shareGroups;
        Map<ID,Id> roleIDs;
        Set<Id> setPortalGroupIds= new Set<Id>();
        Map<Id,Set<Id>>setResultIds= new Map<Id,Set<Id>>();// roleId and UserOrGroupId
        
        Map<Id,Set<Id>> mapAcctIdsShareIds= new Map<Id,Set<Id>>();
        Set<Id> setUserGroupIds= new Set<Id>();
        List<AccountShare> lstAccountsShares=[Select Id,AccountId,UserOrGroupId from AccountShare where AccountId in:setAcctIds ];
        if(setAcctIds!=null && setAcctIds.size()>0)
        {
            for(Id acctId:setAcctIds)
            {
                Set<Id> userGroupIds= new Set<Id>();
                if(lstAccountsShares!=null && lstAccountsShares.size()>0)
                {
                    
                    for(AccountShare accShare:lstAccountsShares)
                    {
                        setUserGroupIds.add(accShare.UserOrGroupId);
                        if(accShare.AccountId==acctId)
                            userGroupIds.add(accShare.UserOrGroupId);
                    }
                    //System.debug('userGroupIds'+ userGroupIds.size());
                }
                mapAcctIdsShareIds.put(acctId,userGroupIds);
            }
            
            
            //System.debug('mapAcctIdsShareIds'+ mapAcctIdsShareIds.size());
            shareGroups = new Map<ID, Group>([SELECT Id, Name, RelatedId, Type FROM Group WHEre Id IN:setUserGroupIds]);
            // Get Role IDs
            roleIDs = new Map<ID,Id>();
            for (Group shareGroup1 : shareGroups.values()) {
                roleIDs.put(shareGroup1.Id,shareGroup1.RelatedId);
            }
            //System.debug('roleIDs'+ roleIDs);
            Map<Id,UserRole>mapRoles = new Map<Id,UserRole>([SELECT Id,Name,ParentRoleId,PortalAccountId,PortalAccountOwnerId,PortalRole,PortalType FROM UserRole WHERE id IN :roleIDs.values() and PortalType in('CustomerPortal','Partner')]);
            Set<Id> setRoleIds=mapRoles.keyset();
            ////System.debug('setRoleIds' + setRoleIds);
            
            Set<Id> setGroupIds= new Set<Id>();
            for(Id groupId:roleIds.keyset())
            {
                Id roleId=roleIds.get(groupId);
                if(setRoleIds.contains(roleId))
                {
                    setPortalGroupIds.add(groupId);
                }
            }
            //System.debug('setPortalGroupIds'+setPortalGroupIds);
            
            for(Id item:mapAcctIdsShareIds.keySet())
            {
                Set<Id> lstGroupIds=mapAcctIdsShareIds.get(item);
                Set<Id> finalGroupIds= new Set<Id>();
                //System.debug('lstRoleIds'+ lstGroupIds);
                for(Id roleId:lstGroupIds)
                {
                    if(setPortalGroupIds.contains(roleId))
                        finalGroupIds.add(roleId);
                }
                //System.debug('lstRoleIds'+ finalGroupIds);
                setResultIds.put(item,finalGroupIds);
                
            } 
        }
        //System.debug('setResultIds'+setResultIds);
        return setResultIds;
    }
    public static Map<Id,Set<Id>> GetAccountUserIds(Set<Id> setAcctIds)
    {
        Map<ID, Group> shareGroups;
        Map<Id,User> shareUsers;
        List<UserRole> roles;
        List<ID> roleIDs;
        Map<Id,Set<Id>> setResultIds= new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> mapAcctIdsShareIds= new Map<Id,Set<Id>>();
        Set<Id> setUserGroupIds= new Set<Id>();
        List<AccountShare> lstAccountsShares=[Select AccountId,UserOrGroupId from AccountShare where AccountId in:setAcctIds ];
        
        
        for(Id acctId:setAcctIds)
        {
            Set<Id> userGroupIds= new Set<Id>();
            if(lstAccountsShares!=null && lstAccountsShares.size()>0)
            {
                for(AccountShare accShare:lstAccountsShares)
                {
                    setUserGroupIds.add(accShare.UserOrGroupId);
                    if(accShare.AccountId==acctId)
                        userGroupIds.add(accShare.UserOrGroupId);
                }
                //System.debug('userGroupIds'+ userGroupIds.size());
            }
            mapAcctIdsShareIds.put(acctId,userGroupIds);
        }
        
        shareUsers= new Map<Id,User>([SELECT Id,Contact.AccountId FROM User Where UserType in('PowerPartner','PowerCustomerSuccess')and IsActive=true and Id IN :(setUserGroupIds)]);
        Set<Id> portalUserIds= shareUsers.keyset();
        //System.debug('portalUserIds'+ portalUserIds);
        for(Id accId:mapAcctIdsShareIds.keySet())
        {
            Set<Id> userOrGroupIdonAcc= mapAcctIdsShareIds.get(accId);
            Set<Id> finalUserIds= new Set<Id>();
            for (Id userId : userOrGroupIdonAcc) {
                if(portalUserIds!=null && portalUserIds.size()>0)
                {
                    if(portalUserIds.contains(userId))
                    {
                        finalUserIds.add(userId);
                    }
                }
            }
            setResultIds.put(accId,finalUserIds);
        }
        
        
        
        return setResultIds;
    }
    
    //This method returns the List of Share Id and PortalRoleIds
    public static Map<Id,Id> GetSubRoleIds(Id AccountID)
    {
        Map<ID, Group> shareGroups;
        List<User> shareUsers;
        List<UserRole> roles;
        Map<ID,Id> roleIDs;
        Set<Id> setSubShare= new Set<Id>();
        Map<Id,Id> mapRoleGroupIds= new Map<Id,Id>();// ShareId and UserOrGroupId
        Map<Id,Id> setResultIds= new Map<Id,Id>();// ShareId and UserOrGroupId
        Set<Id> setPortalGroupIds= new Set<Id>();
        List<SBQQ__Subscription__Share> lstSubShares=[SELECT ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE IsDeleted=false and ParentId in(select Id from SBQQ__subscription__c where SBQQ__Account__c =:AccountID)];
        if(lstSubShares!=null && lstSubShares.size()>0)
        {
            for (SBQQ__Subscription__Share subShare : lstSubShares) {
                setSubShare.add(subShare.UserOrGroupId);
            }
            shareGroups = new Map<ID, Group>([SELECT Id, Name, RelatedId, Type FROM Group WHEre Id IN:setSubShare]);
            
            // Get Role IDs
            roleIDs = new Map<ID,Id>();
            for (Group shareGroup1 : shareGroups.values()) {
                roleIDs.put(shareGroup1.Id,shareGroup1.RelatedId);
            }
            
            System.debug('roleIDs'+ roleIDs);
            Map<Id,UserRole>mapRoles = new Map<Id,UserRole>([SELECT Id,Name,ParentRoleId,PortalAccountId,PortalAccountOwnerId,PortalRole,PortalType FROM UserRole WHERE id IN :roleIDs.values() and PortalType in('CustomerPortal','Partner')]);
            Set<Id> setRoleIds=mapRoles.keyset();
            System.debug('setRoleIds' + setRoleIds);
            
            Set<Id> setGroupIds= new Set<Id>();
            for(Id groupId:roleIds.keyset())
            {
                Id roleId=roleIds.get(groupId);
                if(setRoleIds.contains(roleId))
                {
                    setPortalGroupIds.add(groupId);
                }
            }
            System.debug('setPortalGroupIds'+setPortalGroupIds);
            for (SBQQ__Subscription__Share subShare : lstSubShares) {
                if(setPortalGroupIds.contains(subshare.UserOrGroupId))
                    setResultIds.put(subShare.Id,subShare.UserOrGroupId);
            }
        }
        return setResultIds;
    }
    //This method returns the List of Share Id and UserIds
    public static Map<Id,Id> GetSubUserIds(Id AccountID)
    {
        Map<Id,Id> mapResult= new Map<Id,Id>();// userId--subId
        Set<Id> setPartnerUsers= new Set<Id>();
        Map<Id,Id> mapSubShare= new Map<Id,Id>();
        List<SBQQ__Subscription__Share> lstSubShares=[SELECT ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE IsDeleted=false and ParentId in(select Id from SBQQ__subscription__c where SBQQ__Account__c =:AccountID)];
        System.debug('lstSubShares'+lstSubShares.size());
        if(lstSubShares!=null && lstSubShares.size()>0)
        {
            for (SBQQ__Subscription__Share subShare : lstSubShares) {
                mapSubShare.put(subShare.Id, subShare.UserOrGroupId);
            }
            System.debug('mapSubShare'+mapSubShare.size());
            List<User> shareUsers= [SELECT Id,Contact.AccountId FROM User Where UserType in('PowerPartner','PowerCustomerSuccess')and IsActive=true and Id IN:mapSubShare.values() ];
            if(shareUsers!=null && shareUsers.size()>0)
            {
                for (User user : shareUsers) {
                    setPartnerUsers.add(user.Id);
                }
            }
            System.debug('setPartnerUsers'+setPartnerUsers);
            for (Id subShareId : mapSubShare.keySet()) {
                Id userId=mapSubShare.get(subShareId);
                if(setPartnerUsers.contains(userId))
                    mapResult.put(subShareId, userId);
            }
        }
        System.debug('users'+ mapResult);
        return mapResult;
    }
    
    
    public static Set<Id> GetPortalRoleIds(Set<Id> setUserGroupIds)
    {
        Map<ID, Group> shareGroups;
        List<User> shareUsers;
        List<UserRole> roles;
        Map<ID,Id> roleIDs;              
        
        Set<Id> setPortalGroupIds= new Set<Id>();
        if(setUserGroupIds!=null && setUserGroupIds.size()>0)
        {
            shareGroups = new Map<ID, Group>([SELECT Id, Name, RelatedId, Type FROM Group WHEre Id IN:setUserGroupIds]);
            // Get Role IDs
            roleIDs = new Map<ID,Id>();
            for (Group shareGroup1 : shareGroups.values()) {
                roleIDs.put(shareGroup1.Id,shareGroup1.RelatedId);
            }
            
            System.debug('roleIDs'+ roleIDs);
            Map<Id,UserRole>mapRoles = new Map<Id,UserRole>([SELECT Id,Name,ParentRoleId,PortalAccountId,PortalAccountOwnerId,PortalRole,PortalType FROM UserRole WHERE id IN :roleIDs.values() and PortalType in('CustomerPortal','Partner')]);
            Set<Id> setRoleIds=mapRoles.keyset();
            System.debug('setRoleIds' + setRoleIds);
            
            Set<Id> setGroupIds= new Set<Id>();
            for(Id groupId:roleIds.keyset())
            {
                Id roleId=roleIds.get(groupId);
                if(setRoleIds.contains(roleId))
                {
                    setPortalGroupIds.add(groupId);
                }
            }
        }
        return setPortalGroupIds;
    }
    
    public static Set<Id> GetPortalUserIds(Set<Id> setUserGroupIds)
    {
        Set<Id> setPartnerUsers= new Set<Id>();
        List<User> shareUsers= [SELECT Id,Contact.AccountId FROM User Where UserType in('PowerPartner','PowerCustomerSuccess')and IsActive=true and Id IN:setUserGroupIds];
        if(shareUsers!=null && shareUsers.size()>0)
        {
            for (User user : shareUsers) {
                setPartnerUsers.add(user.Id);
            }
        }
        return setPartnerUsers;
    }
    
    
    
    public static List<SubscriptionWrapper> GetSubscriptionByRoleIds(List<SubscriptionWrapper> lstSubWrapper)
    {
        		Map<Id,List<SubscriptionWrapper>> mapResult= new Map<Id,List<SubscriptionWrapper>>();// ShareId and UserOrGroupId
                Map<ID, Group> shareGroups;
                List<User> shareUsers;
                List<UserRole> roles;
                Map<ID,Id> roleIDs;
                Set<Id> setSubShare= new Set<Id>();
                Map<Id,Id> mapRoleGroupIds= new Map<Id,Id>();// ShareId and UserOrGroupId
                Set<Id> setPortalGroupIds= new Set<Id>();
                List<SubscriptionWrapper> lstFinalSub= new List<SubscriptionWrapper>();
                
                if(lstSubWrapper!=null && lstSubWrapper.size()>0)
                {
                    for (SubscriptionWrapper subShare : lstSubWrapper) {
                        setSubShare.add(subShare.UserOrGroupId);
                    }
                    shareGroups = new Map<ID, Group>([SELECT Id, Name, RelatedId, Type FROM Group WHEre Id IN:setSubShare]);
                    
                    // Get Role IDs
                    roleIDs = new Map<ID,Id>();
                    for (Group shareGroup1 : shareGroups.values()) {
                        roleIDs.put(shareGroup1.Id,shareGroup1.RelatedId);
                    }
                    
                    System.debug('roleIDs'+ roleIDs);
                    Map<Id,UserRole>mapRoles = new Map<Id,UserRole>([SELECT Id,Name,ParentRoleId,PortalAccountId,PortalAccountOwnerId,PortalRole,PortalType FROM UserRole WHERE id IN :roleIDs.values() and PortalType in('CustomerPortal','Partner')]);
                    Set<Id> setRoleIds=mapRoles.keyset();
                    System.debug('setRoleIds' + setRoleIds);
                    
                    Set<Id> setGroupIds= new Set<Id>();
                    for(Id groupId:roleIds.keyset())
                    {
                        Id roleId=roleIds.get(groupId);
                        if(setRoleIds.contains(roleId))
                        {
                            setPortalGroupIds.add(groupId);
                        }
                    }
                    for (SubscriptionWrapper subShare : lstSubWrapper) {
                        if(setPortalGroupIds.contains(subshare.UserOrGroupId))
                            lstFinalSub.add(subShare);
                    }
                }
        
        return lstFinalSub;
    }
    
    public static Map<Id,List<SubscriptionWrapper>> GetSubscriptionByUserIds(Map<Id,List<SubscriptionWrapper>> mapSubIds){
        Map<Id,List<SubscriptionWrapper>> mapResult= new Map<Id,List<SubscriptionWrapper>>();// ShareId and UserOrGroupId
        if(mapSubIds!=null && mapSubIds.size()>0)
        {
            for(Id accId: mapSubIds.keySet())
            {
                Set<Id> setSubShare= new Set<Id>();
                Set<Id> setPartnerUsers= new Set<Id>();
                List<SubscriptionWrapper> lstFinalSub= new List<SubscriptionWrapper>();
                List<SubscriptionWrapper> lstSubWrapper= mapSubIds.get(accId);
                if(lstSubWrapper!=null && lstSubWrapper.size()>0)
                {
                    for (SubscriptionWrapper subShare : lstSubWrapper) {
                        setSubShare.add(subShare.UserOrGroupId);
                    }
                    System.debug('setSubShare'+setSubShare.size());
                    List<User> shareUsers= [SELECT Id,Contact.AccountId FROM User Where UserType in('PowerPartner','PowerCustomerSuccess')and IsActive=true and Id IN:setSubShare ];
                    if(shareUsers!=null && shareUsers.size()>0)
                    {
                        for (User user : shareUsers) {
                            setPartnerUsers.add(user.Id);
                        }
                    }
                    for (SubscriptionWrapper subShare : lstSubWrapper) {
                        if(setPartnerUsers.contains(subshare.UserOrGroupId))
                            lstFinalSub.add(subShare);
                    }
                }
                mapResult.put(accId,lstFinalSub);
            }
            
            
        }
        
        return mapResult;
    }
    
    public static Map<Id,List<SubscriptionWrapper>> GetSubscriptionByAcctIds(Set<Id> setAcctIds,List<SBQQ__Subscription__c> lstSub,List<SBQQ__Subscription__Share> lstSubShare)
    {
        List<SubscriptionWrapper> lstSubWrapper= new List<SubscriptionWrapper>();
        Map<Id,Id> mapSubAccId= new Map<Id,Id>();
        Map<Id,List<SubscriptionWrapper>> mapResult= new Map<Id,List<SubscriptionWrapper>>();
        if(lstSub!=null && lstSub.size()>0)
        {
            for(SBQQ__Subscription__c sub:lstSub)
            {
                mapSubAccId.put(sub.Id,sub.SBQQ__Account__c);
            }
            
        }
        if(lstSubShare!=null && lstSubShare.size()>0)
        {
            for(SBQQ__Subscription__Share subShare:lstSubShare)
            {
                if(mapSubAccId.containskey(subShare.ParentId))
                {
                    Id accId=mapSubAccId.get(subShare.ParentId);
                    lstSubWrapper.add(new SubscriptionWrapper(subShare.ParentId,subShare.Id,subShare.UserOrGroupId,accId));
                }
            } 
        }
        
        if(setAcctIds!=null && setAcctIds.size()>0)
        {
            for(Id accId:setAcctIds)
            {
                List<SubscriptionWrapper> lstSubData= new List<SubscriptionWrapper>();
                for(SubscriptionWrapper subWrapper:lstSubWrapper)
                {
                    if(accId==subWrapper.AccountId)
                        lstSubData.add(subWrapper);
                }
                mapResult.put(accId,lstSubData);
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
            insert lstSubShares;
        
        
        
    }
    
    public static List<SBQQ__Subscription__c> RetreiveExistingSubs(Id acctId)
    {
        return [Select Id from SBQQ__Subscription__c where SBQQ__Account__c=:acctId];
    }
    
    public class SubscriptionWrapper
    {
        public Id AccountId{get;set;}
        public Id SubId{get;set;}
        public Id SubShareId{get;set;}
        public Id UserOrGroupId{get;set;}
        
        public SubscriptionWrapper(Id subscriptionId,Id subscriptionShareId,Id userOrRoleId, Id acctId)
        {
            AccountId=acctId;
            SubId=subscriptionId;
            SubShareId=subscriptionShareId;
            UserOrGroupId=userOrRoleId;
        }
        
    }
    
}