public  class ContactOwnershipHelper {
    
    @future
    public static void DisableAllowSelfReg(Set<Id> conList)
    {
        List<Contact> lstConToUpdate= new List<Contact>();
        for(Id con: conList)
        {
            System.debug('CanAllowPortalSelfReg');
            Contact item= new Contact();
            item.Id=con;
            item.CanAllowPortalSelfReg=false;
            lstConToUpdate.add(item);
            
        }
        
        if(lstConToUpdate.size()>0)
        {
            update lstConToUpdate;
        }
    }   
}