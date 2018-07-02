public class OpenAssetSubsController {

    
    public List<SBQQ__SubscribedAsset__c> lstSubs {get;set;}
    public List<SBQQ__SubscribedAsset__c> lstAssets {get;set;}
    public Case caseRecord;
    public OpenAssetSubsController(ApexPages.StandardController stdController)
    {
        caseRecord=(Case)stdController.getRecord();
        System.debug('caseRecord '+caseRecord);
        lstSubs= new List<SBQQ__SubscribedAsset__c>();
        lstAssets= new List<SBQQ__SubscribedAsset__c>();
        caseRecord=[Select Id,AssetId,Subscription__c from Case where Id=:caseRecord.Id];
        if(caseRecord.AssetId!=null)
            lstSubs=[Select Id,SBQQ__Subscription__r.SBQQ__Contract__r.ContractNumber,SBQQ__Subscription__r.SBQQ__Product__r.Name,SBQQ__Subscription__r.SBQQ__Contract__r.StartDate,SBQQ__Subscription__r.SBQQ__Contract__r.EndDate,SBQQ__Subscription__r.SBQQ__Contract__r.Contract_Type__c,SBQQ__Subscription__r.SBQQ__Contract__r.Evaluation_Quote__c from SBQQ__SubscribedAsset__c where SBQQ__Asset__c=:caseRecord.AssetId and SBQQ__Active__c=true ];
         if(caseRecord.Subscription__c!=null)
            lstAssets=[Select Id,SBQQ__Asset__r.SerialNumber,SBQQ__Asset__r.Product2.Name,SBQQ__Asset__r.Warranty_Start_Date__c,SBQQ__Asset__r.Warranty_End_Date__c,SBQQ__Asset__r.Status from SBQQ__SubscribedAsset__c where SBQQ__Subscription__c=:caseRecord.Subscription__c and SBQQ__Active__c=true ];
    }
    
}