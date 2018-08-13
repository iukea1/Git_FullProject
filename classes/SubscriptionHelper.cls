public class SubscriptionHelper {
    
     public static Set<Id> GetPortalIds(Set<Id> setUserGroupIds)
    {
        Map<ID, Group> shareGroups;
        List<User> shareUsers;
        List<UserRole> roles;
        Map<ID,Id> roleIDs;              
        Set<Id> setPortalUserOrGroupIds= new Set<Id>();
        if(setUserGroupIds!=null && setUserGroupIds.size()>0)
        {
            shareGroups = new Map<ID, Group>([SELECT Id, Name, RelatedId, Type FROM Group WHEre Id IN:setUserGroupIds]);
            shareUsers= [SELECT Id,Contact.AccountId FROM User Where UserType in('PowerPartner','PowerCustomerSuccess')and IsActive=true and Id IN:setUserGroupIds];
            if(shareUsers!=null && shareUsers.size()>0)
            {
                for (User user : shareUsers) {
                    setPortalUserOrGroupIds.add(user.Id);
                }
            }
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
                    setPortalUserOrGroupIds.add(groupId);
                }
            }
        }
        System.debug('setPortalUserOrGroupIds'+setPortalUserOrGroupIds);
        return setPortalUserOrGroupIds;
    }
    //This method returns the list of AccountId and GroupID.
    public static Map<Id,Set<Id>> GetPortalIdsByAccount(Set<Id> setAcctIds,List<AccountShare> lstAccountsShares,Set<Id> setPortalIds)
    {
        Map<Id,Set<Id>> mapAcctIdsShareIds= new Map<Id,Set<Id>>();
        if(setAcctIds!=null && setAcctIds.size()>0)
        {
            for(Id acctId:setAcctIds)
            {
                Set<Id> userGroupIds= new Set<Id>();
                if(lstAccountsShares!=null && lstAccountsShares.size()>0)
                {
                    for(AccountShare accShare:lstAccountsShares)
                    {
                        if(accShare.AccountId==acctId && setPortalIds.contains(accShare.UserOrGroupId))
                            userGroupIds.add(accShare.UserOrGroupId);
                    }
                }
                mapAcctIdsShareIds.put(acctId,userGroupIds);
            }
           
        }
        return mapAcctIdsShareIds; 
    }    
     //This method returns the list of AccountId and GroupID.
    public static List<SubscriptionWrapper> GetPortalIdsBySubscription(List<SubscriptionWrapper> lstSubData,Set<Id> setPortalIds)
    {
        List<SubscriptionWrapper> lstOutputSub= new List<SubscriptionWrapper>();
        if(lstSubData!=null && lstSubData.size()>0)
        {
            for(SubscriptionWrapper subWrapper:lstSubData)
            {
                Set<Id> userGroupIds= new Set<Id>();
                if(setPortalIds.contains(subWrapper.UserOrGroupId))
                {
                    lstOutputSub.add(subWrapper);
                }
            }
        }
        return lstOutputSub; 
    }   
    
 	   //This method returns the list of AccountId and GroupID.
    public static List<SubscriptionWrapper> GetSubSharesToDelete(List<SubscriptionWrapper> lstSubData,Set<Id> setPortalAcctIds)
    {
        List<SubscriptionWrapper> lstOutputSub= new List<SubscriptionWrapper>();
        if(lstSubData!=null && lstSubData.size()>0)
        {
            for(SubscriptionWrapper subWrapper:lstSubData)
            {
                Set<Id> userGroupIds= new Set<Id>();
                if(!setPortalAcctIds.contains(subWrapper.UserOrGroupId))
                {
                    lstOutputSub.add(subWrapper);
                }
            }
        }
        return lstOutputSub; 
    }      
    
       //This method returns the list of AccountId and GroupID.
    public static Map<Id,Id> GetSubSharesToAdd(Id acctId,List<SBQQ__Subscription__c> lstSubs,List<SubscriptionWrapper> lstSubData,Set<Id> setPortalAcctIds)
    {
        Map<Id,Id> lstOutputSub= new Map<Id,Id>();
        Map<Id,Set<Id>> mapPortalIdsBySubId= new Map<Id,Set<Id>>();
        
        Set<Id> lstSubIds= new Set<Id>();
        if(lstSubs!=null && lstSubs.size()>0)
        {
            for(SBQQ__Subscription__c item:lstSubs)
            {
				if(item.SBQQ__Account__c==acctId)  
                    lstSubIds.add(item.Id);
            }
        }
        
        if(lstSubData!=null && lstSubData.size()>0)
        {
            for(SubscriptionWrapper subData:lstSubData)
            {
                mapPortalIdsBySubId.put(subData.SubId,null);
            }
            if(mapPortalIdsBySubId!=null && mapPortalIdsBySubId.size()>0)
            {
                for(Id counter:mapPortalIdsBySubId.keyset())
                {
                    Set<ID> setPortalIds= new Set<Id>();
                    for(SubscriptionWrapper subData:lstSubData)
                    {
                        if(subData.SubId==counter)
                            setPortalIds.add(subData.UserOrGroupId);
                    }
                    mapPortalIdsBySubId.put(counter,setPortalIds);
                }
            }
        }
        System.debug('setPortalAcctIds'+setPortalAcctIds);
        for(Id accPortalId:setPortalAcctIds)
        {
            for(Id counter:lstSubIds)
            {
                Set<Id> setPortalIdsBySub=mapPortalIdsBySubId.get(counter);
                if(setPortalIdsBySub==null || setPortalIdsBySub.size()==0 ||!setPortalIdsBySub.contains(accPortalId))
                    lstOutputSub.put(counter,accPortalId);
            }
        }
        return lstOutputSub; 
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