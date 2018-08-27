public without sharing class ContractTriggerHandler implements ITriggerHandler{
        
    public static final String EvalRmaRecordTypeId = '012500000005H0o';
    public static final String EvalRMAItemRecordTypeId = '012500000005H0y';
    String rmaRecordTypeId = Schema.SObjectType.RMA__c.getRecordTypeInfosByName().get('Eval RMA').getRecordTypeId();
    String itemRecordTypeId = Schema.SObjectType.RMA_Item__c.getRecordTypeInfosByName().get('Eval Return').getRecordTypeId();


    
    public ContractTriggerHandler(){
            
        
    }
    public Boolean IsDisabled(){
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
        populateQuoteNumberToPOCIdInContract(newItems.values());
        //renewalContractDateSetup(newItems.values());
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
        createRMAEval(newItems.values(), oldItems);
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
    }
    
    public static void populateQuoteNumberToPOCIdInContract(List<Contract> contracts){
        Set<Id> contractIds = new Set<Id>();
        List<Contract> contractWithPocID = new List<Contract>();
        
        for(Contract cont: contracts){
            contractIds.add(cont.id);
        }
        
        List<Contract> contractsToUpdate = [SELECT Id, Name, SBQQ__Quote__c, SBQQ__Quote__r.POC_ID__c FROM Contract WHERE Id IN: contractIds];
        
        for(Contract c: contractsToUpdate){
            if(c.SBQQ__Quote__r.POC_ID__c != null){
                c.POC_ID__c = c.SBQQ__Quote__r.POC_ID__c;
                contractWithPocID.add(c);
            }
        }
        
        if(contractWithPocID.size()>0){
            update contractWithPocID;
        }
    }
    
    public static void createRMAEval(List<Contract> incomingContract, Map<Id, SObject> oldItems){
        
        List<RMA__c> rmas = new List<RMA__c>();
        List<SBQQ__SubscribedAsset__c> subsAndAsset = new List<SBQQ__SubscribedAsset__c>();
        List<Contract> expiredContract = new List<Contract>();
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();           
        
        Set<id> contractIds = new Set<Id>();
        Set<id> accountIds = new Set<Id>();
        
        Map<Id, List<SBQQ__SubscribedAsset__c>> assetToSubscribedAssetMap = new Map<Id, List<SBQQ__SubscribedAsset__c>>();
        Map<Id, List<RMA_Item__c>> accountToRMAItemMap = new Map<Id, List<RMA_Item__c>>();

        for(Contract contract: incomingContract){
            contractIds.add(contract.Id);
        }
        
        List<Contract> contractExpired = [SELECT Id, Status, Evaluation_Quote__c, SBQQ__Quote__c, SBQQ__Quote__r.POC_Contact__c, Contract.AccountId FROM Contract WHERE Id IN: contractIds];
        
        for(Contract con: contractExpired){
            accountIds.add(con.AccountId);
        }
                    
        //List<Contact> contactInContract = [SELECT Id, AccountId FROM Contact WHERE AccountId IN: accountIds LIMIT 1];
        
        List<SBQQ__SubscribedAsset__c> assetToUpdate = [SELECT Id, SBQQ__Asset__c, SBQQ__Subscription__r.SBQQ__Contract__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN: contractIds];
        
        for(SBQQ__SubscribedAsset__c asset: assetToUpdate){
            
            if(assetToSubscribedAssetMap.containsKey(asset.SBQQ__Asset__c)){
                List<SBQQ__SubscribedAsset__c> subscribedAssetList = assetToSubscribedAssetMap.get(asset.SBQQ__Asset__c);
                subscribedAssetList.add(asset);
                assetToSubscribedAssetMap.put(asset.SBQQ__Asset__c, subscribedAssetList);
            }
            
            else{
                assetToSubscribedAssetMap.put(asset.SBQQ__Asset__c, new List<SBQQ__SubscribedAsset__c>{asset});
            }   
        }
        
        Set<Id> assetIdsToUpdate = assetToSubscribedAssetMap.keySet();
        List<RMA_Item__c> items = new List<RMA_Item__c>();
        List<Asset> assets = [SELECT Id, Product2Id, Status FROM Asset WHERE Id IN: assetIdsToUpdate AND Status != 'Customer Owned'];
        // processing
        
        for(Contract c: contractExpired){
        
            if(c.Status == 'Pending Return' && c.Evaluation_Quote__c){
                
                SBQQ__Quote__c quoteToUpdate = new SBQQ__Quote__c(Id = c.SBQQ__Quote__c, POC_Status__c='Pending Return');
                quotesToUpdate.add(quoteToUpdate);
                
                RMA__c rma = new RMA__c(Account__c=c.AccountId, RecordTypeId=EvalRmaRecordTypeId, POC_Quote__c = c.SBQQ__Quote__c, Status__c='Initiated', Type__c='Eval Return', Contact_Loc_1__c= c.SBQQ__Quote__r.POC_Contact__c);

                for(Asset asset: assets){
                    items.add(new RMA_Item__c(Asset__c=asset.Id, Product2__c=asset.Product2Id, RecordTypeId=EvalRMAItemRecordTypeId, Type__c='Return - Refurbish and Stock', Status__c='Not Dispatched'));
                }
                if(items.size()>0){
                    rmas.add(rma);
                }
                //accountToRMAItemMap.put(c.AccountId, items);
            }
                

        }
        
        upsert rmas;
        
        List<RMA_Item__c> rmaItems = new List<RMA_Item__c>();
        
        for(RMA__c rmaRec: rmas){
           
            //List<RMA_Item__c> items = accountToRMAItemMap.get(rmaRec.Account__c);
            
            if(items != null){
                
                for(RMA_Item__c item : items){
                    item.RMA__c = rmaRec.Id;
                    rmaItems.add(item);
                }
                
            }
            
        }
        
        
        if(!quotesToUpdate.isEmpty()){
            update quotesToUpdate;    
        }
        upsert rmaItems;
        
        for(Asset a: assets){
            if(a.Status == 'Customer Subscription Active') a.Status = 'Customer Subscription Expired';
            else if(a.Status != 'Customer Subscription Expired') a.Status = 'Pending Return – Eval';
        }
        
        update assets;
    }
    
    
    
}