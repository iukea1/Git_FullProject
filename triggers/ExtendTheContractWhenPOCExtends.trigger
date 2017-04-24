trigger ExtendTheContractWhenPOCExtends on Request__c (after update) {
    List<Contract> lstContract= new List<Contract>();
    for(Request__c item:Trigger.New)
    {
        Request__c oldPoc= Trigger.oldMap.get(item.Id);
        if(item.Poc_Type__c =='Perpetual' || item.Poc_Type__c =='Metered'|| item.Poc_Type__c =='Perpetual-Orchestrator SP'|| item.Poc_Type__c =='Metered-Orchestrator SP')
        {
            if(oldPoc.Target_End_Date__c!=item.Target_End_Date__c && item.Contract_Number__c!=null)
            {
                lstContract.add(new Contract(Id=item.Contract_Number__c,EndDate=item.Target_End_Date__c));
            }
        }
    }
    
    if(lstContract.size()>0)
    {
        update lstContract;
    }

}