trigger DECaseNotesonNewCase on Case (after insert) 
{
    Set<Id> setAccountIds = new Set<Id>();
    Map<Id, List<DE_Note__c>> mapAcctDENotes = new map<Id, List<DE_Note__c>>();
    List<DE_Case_Note__c> lstDECaseNotes = new List<DE_Case_Note__c>();
    
    for(Case newcase: Trigger.new)
    {
        if (newCase.RecordTypeId =='012500000005AuO' || newCase.RecordTypeId == '012500000005Aui')
        {
            setAccountIds.add(newcase.AccountId);
        }
    }
    system.debug('setAccountIds:'+ setAccountIds);
    
    if(SetAccountIds != null && SetAccountIds.size()>0)
    {
        List<Account> lstAccts = [Select Id, Name, (Select Id, Account_Name__c , DE_Notes__c  from DE_Notes__r)
                                  from Account where Id IN :SetAccountIds];
        for(Account acc: lstAccts)
        {
            mapAcctDENotes.put(acc.Id, acc.DE_Notes__r);
        }
        
        for(Case newcase: Trigger.new)
        {
            List<DE_Note__c> lstDENotes = mapAcctDENotes.get(newcase.AccountId);
            if(lstDENotes != null && lstDENotes.size()>0)
            {
                for(DE_Note__c de: lstDENotes)
                {
                    DE_Case_Note__c decnote= new DE_Case_Note__c();
                    decnote.Case_Number__c = newcase.Id;
                    decnote.DE_Note__c = de.Id; 
                    lstDECaseNotes.add(decnote);
                }
            }
        }
        insert lstDECaseNotes;
    } 
}