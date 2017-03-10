trigger CapCaseOnNewCase on Case (after insert) {
    
    for (Case newCase : Trigger.new){ 
        if (newCase.RecordTypeId =='012500000005AuO' || newCase.RecordTypeId == '012500000005Aui'){
        List<Cap__c> openCap = [Select Id, Account_Name__c, Account_Name__r.IsCap__c, Status__c  from Cap__c where Status__c = 'Open' 
                                and Account_Name__c = :newCase.AccountId and Account_Name__r.IsCap__c= True];
        List<Cap_Case__c> lstNewCapCase = new List<Cap_Case__c>();
        
        if (OpenCap!= null && OpenCap.size()>0){
            Cap_Case__c newcCase    = New Cap_Case__c ();
            newcCase.Cap_Name__c    = OpenCap[0].Id;
            newcCase.Case_Number__c = newCase.Id;
            newcCase.Comments__c    = newCase.LastUpdateNote__c;
            lstNewCapCase.add(newcCase);
        }
        if (lstNewCapCase.size()>0){
            insert lstNewCapCase;
        }
       }
    }  
}