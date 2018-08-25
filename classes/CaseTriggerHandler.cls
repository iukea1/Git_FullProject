public class CaseTriggerHandler implements ITriggerHandler {
    
    public CaseTriggerHandler()
    {
        
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems)
    {
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
        
    }
    public void BeforeDelete(Map<Id,SObject> oldItems)
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        Map<Id,Id> mapAssets= new Map<Id,Id>();
        Map<Id,Id> mapSubs= new Map<Id,Id>();
        Map<Id,Id> mapCaseAcc = new map<Id,Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id caseId : newItems.keyset())
            {
                Case newCase= (Case)newItems.get(caseId);
                if(newCase.AssetId!=null)
                {
                    mapAssets.put(newCase.Id,newCase.AssetId);
                }
                if(newCase.Subscription__c!=null)
                {
                    mapSubs.put(newCase.Id,newCase.Subscription__c);
                }
                if(newCase.RecordTypeId =='012500000005AuO' || newCase.RecordTypeId == '012500000005Aui')
                {
                    mapCaseAcc.put(newcase.Id, newCase.AccountId);
                }
            }
           	PopulateContractInfo(mapAssets,mapSubs);
            CreateDECaseNotes(mapCaseAcc);
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        Map<Id,Id> mapAssets= new Map<Id,Id>();
        Map<Id,Id> mapSubs= new Map<Id,Id>();
        Map<Id,Id> lstCase= new  Map<Id,Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id caseId : newItems.keyset())
            {
                Case newCase= (Case)newItems.get(caseId);
                Case oldCase= (Case)oldItems.get(caseId);
                if(newCase.AssetId!=null && newCase.AssetId!=oldCase.AssetId)
                {
                    mapAssets.put(newCase.Id,newCase.AssetId);
                }
                if(newCase.Subscription__c!=null && newCase.Subscription__c!=oldCase.Subscription__c)
                {
                    mapSubs.put(newCase.Id,newCase.Subscription__c);
                }
                if(newCase.Is_EC_V__c && newCase.Is_EC_V__c!=oldCase.Is_EC_V__c && newCase.AssetId==null && newCase.Subscription__c==null)
                    lstCase.put(newCase.Id,newCase.AccountId);
            }
            PopulateContractInfo(mapAssets,mapSubs);
            PopulateBaseContract(lstCase);
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
    
     private static void PopulateBaseContract(Map<Id,Id> mapCases)
     {
         
         List<Case> lstCases= new List<Case>();
         if(mapCases!=null && mapCases.size()>0)
         {
             List<SBQQ__Subscription__c> lstSub=[Select Id,SBQQ__Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Name like 'EC-BASE%' and SBQQ__Contract__r.Status='Activated' and SBQQ__Contract__r.Evaluation_Quote__c=false and SBQQ__Account__c in:mapCases.values()];
             if(lstSub!=null && lstSub.size()>0)
             {
                 for(Id caseId: mapCases.keyset())
                 {
                     Id acctId= mapCases.get(caseId);
                     for(SBQQ__Subscription__c sub: lstSub)
                     {
                         if(acctId==sub.SBQQ__Account__c)
                             lstCases.add(new Case(ID=caseId,Subscription__c=sub.Id));
                     }
                 }
                 
             }
         }
         if(lstCases!=null && lstCases.size()>0)
         {
             update lstCases;
         }
     }
    
    private static void PopulateContractInfo(Map<Id,Id> mapCaseAssets,Map<Id,Id> mapCaseSubs)
    {
        List<Case> lstCases= new List<Case>();
        if(mapCaseAssets!=null && mapCaseAssets.size()>0)
        {
            List<Asset> lstAssets=[Select Id,Status,Product2.Product_Type__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__c from Asset where Id in:mapCaseAssets.values()];
            for(Id caseId:mapCaseAssets.keySet())
            {
                Id assetId= mapCaseAssets.get(caseId);
                for(Asset item:lstAssets)
                {
                    if(item.Id==assetId )
                    {
                        Case caseData= new Case(Id=caseId,Asset_Sub_Contract__c=item.SBQQ__CurrentSubscription__r.SBQQ__Contract__c);
                        lstCases.add(caseData);
                        break;
                    }
                }
            }
           
        }
        if(mapCaseSubs!=null && mapCaseSubs.size()>0)
        {
            List<SBQQ__Subscription__c> lstSubs=[Select Id,SBQQ__Contract__c,SBCF_Subscription_Status__c from SBQQ__Subscription__c where Id in:mapCaseSubs.values()];
            for(Id caseId:mapCaseSubs.keySet())
            {
                Id subId= mapCaseSubs.get(caseId);
                for(SBQQ__Subscription__c item:lstSubs)
                {
                    if(item.Id==subId )
                    {
                        Case caseData= new Case(Id=caseId,Asset_Sub_Contract__c=item.SBQQ__Contract__c);
                        lstCases.add(caseData);
                        break;
                    }
                }
            }
         
        }
        if(lstCases!=null && lstCases.size()>0)
         	update lstCases; 
        
    }
  
    private void CreateDECaseNotes(Map<Id,Id> mapCaseAccounts)
    {
        if(mapCaseAccounts != null && mapCaseAccounts.size()>0)
        {
            List<DE_Case_Note__c> lstDECaseNotes = new List<DE_Case_Note__c>();
            Id caseAccountId;
            List<DE_Note__c> lstAssocDENotes = [Select Id, Account_Name__c from DE_Note__c where Account_Name__c IN :mapCaseAccounts.values()];
            if(lstAssocDENotes != null && lstAssocDENotes.size()>0)
            {
                for(Id caseId: mapCaseAccounts.keySet())
                {
                    caseAccountId = mapCaseAccounts.get(caseId);
                    if(caseAccountId != null)
                    {
                        for(DE_Note__c de: lstAssocDENotes)
                        {
                            if(de.Account_Name__c == caseAccountId)
                            {
                                DE_Case_Note__c decnote= new DE_Case_Note__c();
                                decnote.Case_Number__c = caseId;
                                decnote.DE_Note__c = de.Id;
                                lstDECaseNotes.add(decnote);
                            }
                        }
                    }
                }
            }
            if(lstDECaseNotes != null && lstDECaseNotes.size()>0)
            {
                insert lstDECaseNotes;
            }    
        } 
    }
}