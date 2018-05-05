trigger AttachmentCheckOnDENote on Attachment (before insert, before delete)
{
   /* List<DE_Note__c> lstDENotes = new List<DE_Note__c>();
    Set<Id> setDENoteIds = new Set<Id>();
    Set<Id> setattIds = new Set<Id>();
    List<DE_Note__c> lstFinal = new List<DE_Note__c>();
    
    if(Trigger.isinsert)
    {
        for(Attachment attach: Trigger.new)
        {
            if(attach.ParentId.getSobjectType() == DE_note__c.SobjectType)
            {
                setDENoteIds.add(attach.ParentId);
            }
        }
        lstDENotes = [select Id, Has_Attachment__c from DE_Note__c where Id in : setDENoteIds and Has_Attachment__c !=true];
        
        if(lstDENotes != null && lstDeNotes.size() > 0)
        {
            for(DE_Note__c de: lstDENotes)
            {
                de.Has_Attachment__c = True;
            }
            update lstDENotes;
        }
    }
    if(Trigger.isdelete)
    {
        for(Attachment attach : Trigger.old)
        {
            if(attach.ParentId.getSobjectType() == DE_note__c.SobjectType)
            {
                setDENoteIds.add(attach.ParentId);
                setattIds.add(attach.Id);
            }
        }
        system.debug('setDENoteIds:' + setDENoteIds);
        system.debug('setattIds:' + setattIds);
        lstDENotes = [Select Id, Has_attachment__c, (Select Id, ParentId from Attachments where Id NOT IN:setattIds) from DE_Note__c where Has_Attachment__c = true and Id IN :setDENoteIds];
        system.debug('lstDENotes:'+ lstDENotes);
        if(lstDENotes != null && lstDENotes.size() > 0)
        {
            for(DE_Note__c de: lstDENotes)
            {
                if(de.Attachments.size() == 0)
                {
                    de.Has_Attachment__c = False;
                    lstFinal.add(de);
                }
            }
            system.debug('lstFinal:' + lstFinal);
            update lstFinal;
        }
    } */
}