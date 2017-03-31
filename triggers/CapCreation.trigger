trigger CapCreation on Account (after update) {
    
    Cap__c cap = new Cap__c();
    for(Account acct : Trigger.new)
    {
        Account oldAcct = Trigger.oldMap.get(acct.Id);
        
        Boolean oldCap = oldAcct.IsCap__c;
        Boolean newCap = acct.IsCap__c;
        
        if((oldCap != newCap) && acct.IsCap__c == TRUE)
        {
            cap.Account_Name__c = acct.Id; 
            cap.Status__c       = 'Open';
            insert cap; 
            
            if(cap.Id != null){
                List<Cap_Case__c> lstCapCase = new List<cap_Case__c>();
                List<Case> lstAscCases = [Select Id, ClosedDate, CaseNumber, LastUpdateNote__c  from Case where 
                                       RecordtypeId IN ('012500000005AuO','012500000005Aui') AND ClosedDate = NULL
                                       AND AccountId =:acct.Id];
                
                if (lstAscCases.size()> 0) 
                {
                    for(Case c : lstAscCases)
                    {    
                        Cap_Case__c cCase    = new Cap_Case__c();
                        cCase.Cap_Name__c    = cap.Id;
                        cCase.Case_Number__c = c.Id;
                        cCase.Comments__c    = c.LastUpdateNote__c;
                        
                        lstCapCase.add(cCase); 
                    }
                }
                if (lstCapCase.size()> 0)  
                    insert lstCapCase;
            }
        }
    }
}