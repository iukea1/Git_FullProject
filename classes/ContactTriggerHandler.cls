public class ContactTriggerHandler implements ITriggerHandler {
    Map<Id,string> mapGEOUsers= new Map<Id,string>();
    public ContactTriggerHandler()
    {
        List<User> lstStandardUsers=[Select Id,GEO_Region__c from User where UserType='Standard' and IsActive=true];
        if(lstStandardUsers!=null && lstStandardUsers.size()>0)
        {
            for(User usrData:lstStandardUsers)
            {
                mapGEOUsers.put(usrData.Id,usrData.GEO_Region__c);
            }
        }
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Contact con : (List<Contact>)newItems)
            {
                if(con.TechnicalPresalesReady__c)
                {
                    con.TechnicalPresalesReadyCertifiedBy__c = UserInfo.getUserId();
                }
                if(con.OwnerId!=null)
                {
                    if(mapGEOUsers!=null && mapGEOUsers.containsKey(con.OwnerId))
                    {
                        con.GEO__c= mapGEOUsers.get(con.OwnerId);
                    }
                }
               
                
            }
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id conId : newItems.keyset())
            {
                Contact oldContact=(Contact)oldItems.get(conId);
                Contact newContact=(Contact)newItems.get(conId);
                if(newContact.TechnicalPresalesReady__c!=oldContact.TechnicalPresalesReady__c)
                {
                    newContact.TechnicalPresalesReadyCertifiedBy__c= newContact.TechnicalPresalesReady__c?UserInfo.getUserId():null;
                }
                if(newContact.OwnerId!=oldContact.OwnerId)
                {
                    if(mapGEOUsers!=null && mapGEOUsers.containsKey(newContact.OwnerId))
                    {
                        newContact.GEO__c= mapGEOUsers.get(newContact.OwnerId);
                    }
                    
                }
                
            }
        }
    }
    public void BeforeDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id conId : newItems.keyset())
            {
                Contact oldContact=(Contact)oldItems.get(conId);
                Contact newContact=(Contact)newItems.get(conId);
                if(newContact.Partner_Role__c != oldContact.Partner_Role__c && newContact.Partner_Role__c != null)
                {
                    accountIds.add(newContact.AccountId);
                    contactIds.add(newContact.Id);
                }
            }
            if(!accountIds.isEmpty() && !contactIds.isEmpty())
            {
                UpdateUserPartnerRoleTriggerHandler.UpdateUsersRole(contactIds, accountIds);
            }
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> oldItems) 
    {
        
    }
    
 
}