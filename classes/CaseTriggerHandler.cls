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
        Map<Id,Id> mapCaseEC= new Map<Id,Id>();
        Map<Id,Id> mapCaseNonEC= new Map<Id,Id>();
        Map<Id,Id> mapCaseAcc = new map<Id,Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id caseId : newItems.keyset())
            {
                Case newCase= (Case)newItems.get(caseId);
                if(newCase.AssetId!=null && newCase.AccountId!=null && newCase.Product_Family__c=='EDGECONNECT')
                {
                    mapCaseEC.put(newCase.Id,newCase.AccountId);
                }
                if(newCase.AssetId!=null && newCase.Product_Family__c!='EDGECONNECT')
                {
                    mapCaseNonEC.put(newCase.Id,newCase.AssetId);
                }
                if(newCase.RecordTypeId =='012500000005AuO' || newCase.RecordTypeId == '012500000005Aui')
                {
                    mapCaseAcc.put(newcase.Id, newCase.AccountId);
                }
            }
            PopulateMainContract(mapCaseNonEC);
            PopulateECBaseContract(mapCaseEC);
            CreateDECaseNotes(mapCaseAcc);
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        Map<Id,Id> mapCaseEC= new Map<Id,Id>();
        Map<Id,Id> mapCaseNonEC= new Map<Id,Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id caseId : newItems.keyset())
            {
                Case newCase= (Case)newItems.get(caseId);
                Case oldCase= (Case)oldItems.get(caseId);
                if(newCase.AssetId!=null && newCase.AssetId!=oldCase.AssetId && newCase.AccountId!=null && newCase.Product_Family__c=='EDGECONNECT')
                {
                    mapCaseEC.put(newCase.Id,newCase.AccountId);
                }
                if(newCase.AssetId!=null && newCase.AssetId!=oldCase.AssetId  && newCase.Product_Family__c!='EDGECONNECT')
                {
                    mapCaseNonEC.put(newCase.Id,newCase.AssetId);
                }
            }
            PopulateMainContract(mapCaseNonEC);
            PopulateECBaseContract(mapCaseEC);
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
    
    private static void PopulateMainContract(Map<Id,Id> mapCaseAssets)
    {
        if(mapCaseAssets!=null && mapCaseAssets.size()>0)
        {
            List<Case> lstCases= new List<Case>();
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
            if(lstCases.size()>0)
                update lstCases;
        }
    }
    private static void PopulateECBaseContract(Map<Id,Id> mapCaseAccounts)
    {
        if(mapCaseAccounts!=null && mapCaseAccounts.size()>0)
        {
            List<Case> lstCases= new List<Case>();
            List<Contract> lstContract=[Select Id,AccountId from Contract where status='Activated' and Evaluation_Quote__c=false and Product_Type__c='EDGECONNECT' and AccountId in:mapCaseAccounts.values() and Id in(Select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Product__r.Name like 'EC-BASE%' and SBQQ__Product__r.Product_Type__c='EDGECONNECT')];
            
            for(Id caseId:mapCaseAccounts.keySet())
            {
                Id accountId= mapCaseAccounts.get(caseId);
                for(Contract item:lstContract)
                {
                    if(item.AccountId==accountId )
                    {
                        Case caseData= new Case(Id=caseId,Asset_Sub_Contract__c=item.Id);
                        lstCases.add(caseData);
                        break;
                    }
                }
            }
            if(lstCases.size()>0)
                update lstCases;
        }
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