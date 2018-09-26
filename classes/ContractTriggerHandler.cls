public without sharing class ContractTriggerHandler implements ITriggerHandler{
        
    //public static final String EvalRmaRecordTypeId = '012500000005H0o';
    //public static final String EvalRMAItemRecordTypeId = '012500000005H0y';
    public static String rmaRecordTypeId = Schema.SObjectType.RMA__c.getRecordTypeInfosByName().get('Eval RMA').getRecordTypeId();
    public static String itemRecordTypeId = Schema.SObjectType.RMA_Item__c.getRecordTypeInfosByName().get('Eval Return').getRecordTypeId();


    
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
        rollupContractEndDate(newItems.values());
        recalculateLicenseEndDateEcAddon(newItems.values(), oldItems);
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        populateQuoteNumberToPOCIdInContract(newItems.values());
        setContractEndDate(newItems.values());
        //renewalContractDateSetup(newItems.values());
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        createRMAEval(newItems.values(), oldItems);
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
    }
    public static void recalculateLicenseEndDateEcAddon(List<Contract> contracts, Map<Id, SObject> oldMap) {
        Map<Id, Contract> oldContracts = (Map<Id, Contract>)oldMap;
        Set<Id> pOrders = new Set<Id>();
        for(Contract c : contracts) {
            if(c.SBQQ__Order__c != oldContracts.get(c.Id).SBQQ__Order__c && c.Product_Type__c == 'EDGECONNECT') {
                pOrders.add(c.SBQQ__Order__c);
            }
        }
        Map<Id, Order> pOrderMap = new Map<Id, Order>([SELECT Id, License_End_Date__c, Type FROM Order WHERE Id IN :pOrders]);
        for(Contract c : contracts) {
            if(c.SBQQ__Order__c != oldContracts.get(c.Id).SBQQ__Order__c && c.Product_Type__c == 'EDGECONNECT' && pOrderMap.containsKey(c.SBQQ__Order__c)) {
                Order ord = pOrderMap.get(c.SBQQ__Order__c);
                if(ord.License_End_Date__c > c.EndDate) {
                    c.EndDate = ord.License_End_Date__c ;
                }
            }
        }
    }
    
    public static void rollupContractEndDate(List<Contract> contracts) {
        Set<Id> quoteId = new Set<Id>();
        for(Contract cont: contracts){
            if(cont.Evaluation_Quote__c && cont.RecalcEndDate__c) {
                quoteId.add(cont.SBQQ__Quote__c);
            }
        }
        Map<Id, SBQQ__Quote__c> parentQuotes = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__ExpirationDate__c FROM SBQQ__Quote__c WHERE Id IN :quoteId]);
        Map<Id, SBQQ__Quote__c> qUpdate = new Map<Id, SBQQ__Quote__c>();
        
        for(Contract cont: contracts){
            if(cont.Evaluation_Quote__c && cont.RecalcEndDate__c && parentQuotes.containsKey(cont.SBQQ__Quote__c)) {
                SBQQ__Quote__c pQuote = parentQuotes.get(cont.SBQQ__Quote__c);
                pQuote.SBQQ__ExpirationDate__c = cont.EndDate;
                cont.RecalcEndDate__c = false;
                qUpdate.put(pQuote.Id, pQuote);
            }
        }
        update qUpdate.values();
        
    }
    public static void setContractEndDate(List<Contract> newContracts) {
    
        List<Contract> contracts = [SELECT Id, Evaluation_Quote__c, SBQQ__Quote__c, StartDate, EndDate FROM Contract WHERE Id IN :newContracts AND Evaluation_Quote__c = true];
        Set<Id> quoteId = new Set<Id>();
        for(Contract cont: contracts){
            if(cont.Evaluation_Quote__c) {
                quoteId.add(cont.SBQQ__Quote__c);
            }
        }
        
        Map<Id, SBQQ__Quote__c> parentQuotes = new Map<Id, SBQQ__Quote__c>([SELECT Id, POC_Duration__c,SBQQ__ExpirationDate__c, (SELECT Id FROM SBQQ__Contracts__r WHERE NOT ID IN :contracts) FROM SBQQ__Quote__c WHERE Id IN :quoteId]);
        for(Contract cont: contracts) {
            SBQQ__Quote__c pQuote = parentQuotes.get(cont.SBQQ__Quote__c);
            if(cont.Evaluation_Quote__c && pQuote != null) {
                Integer i = Integer.valueOf(pQuote.POC_Duration__c);
                if(pQuote.SBQQ__Contracts__r.isEmpty()) {
                    cont.EndDate = cont.StartDate.addDays(i);
                    cont.RecalcEndDate__c = true;
                } else {
                    cont.EndDate = pQuote.SBQQ__ExpirationDate__c;
                }
            }
            
        }
        update contracts;
    }
    
    public static void populateQuoteNumberToPOCIdInContract(List<Contract> contracts){
        Set<Id> contractIds = new Set<Id>();
        List<Contract> contractWithPocID = new List<Contract>();
        
        for(Contract cont: contracts){
            contractIds.add(cont.id);
        }
        
        List<Contract> contractsToUpdate = [SELECT Id, Name, SBQQ__Quote__c, SBQQ__Quote__r.POC_ID__c, SBQQ__Order__c FROM Contract WHERE Id IN: contractIds];
        //setContractEndDate(contractsToUpdate);
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
        Set<Id> quoteParents = new Set<Id>();           
        
        Set<id> contractIds = new Set<Id>();
        Set<id> accountIds = new Set<Id>();
        List<Contract> contractExpired = new List<Contract>(); //[SELECT Id, Status, Evaluation_Quote__c, SBQQ__Quote__c, SBQQ__Quote__r.POC_Contact__c, Contract.AccountId FROM Contract WHERE Id IN: contractIds];
        
        for(Contract con: incomingContract){ //contractExpired){
            if(con.Status == 'Expired' && ((Contract)oldItems.get(con.Id)).Status != 'Expired') {
                contractExpired.add(con);
                accountIds.add(con.AccountId);
                contractIds.add(con.Id);
                quoteParents.add(con.SBQQ__Quote__c);
            }
        
        }
        if(contractExpired.isEmpty()) {
            //do nothing
        } else {
            List<RMA_Item__c> items = new List<RMA_Item__c>();
            List<SBQQ__SubscribedAsset__c> saList = new List<SBQQ__SubscribedAsset__c>();
            //List<Asset> assets = [SELECT Id, Product2Id, Status FROM Asset WHERE Id IN: assetIdsToUpdate AND Status != 'Customer Owned'];
            Map<Id, List<Asset>> assetContracts = new Map<Id, List<Asset>>();
            for(Asset a : [SELECT Id, Product2Id, Status, Product2.Product_Family_Clean__c, (SELECT Id, SBQQ__Subscription__r.SBQQ__Contract__c FROM SBQQ__Subscriptions__r) FROM Asset WHERE Id IN (SELECT SBQQ__Asset__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN :contractIds) ]) {
                Id conId;
                if(!a.SBQQ__Subscriptions__r.isEmpty()) {
                    conId = a.SBQQ__Subscriptions__r[0].SBQQ__Subscription__r.SBQQ__Contract__c;
                    if(!assetContracts.containsKey(conId)) assetContracts.put(conId, new List<Asset>());
                    assetContracts.get(conId).add(a);
                    for(SBQQ__SubscribedAsset__c sa : a.SBQQ__Subscriptions__r) {
                        saList.add(new SBQQ__SubscribedAsset__c(Id=sa.Id, SBQQ__Active__c = false));
                    }
                }
            }
            
            // processing
            List<Asset> astUpdate = new List<Asset>();
            Map<Id, Set<Id>> quoteToContractMap = new Map<Id, Set<Id>>();
            Map<Id, Id> assetToContractMap = new Map<Id, Id>();
            for(Contract c: contractExpired) {
                Rma__c rma;
                if(c.Evaluation_Quote__c) {
                    if(!quoteToContractMap.containsKey(c.SBQQ__Quote__c)) quoteToContractMap.put(c.SBQQ__Quote__c, new Set<Id>());
                    rma = new RMA__c(
                        Account__c=c.AccountId, 
                        RecordTypeId=rmaRecordTypeId, 
                        POC_Quote__c = c.SBQQ__Quote__c, 
                        Status__c='Initiated', 
                        Type__c='Eval Return', 
                        Contact_Loc_1__c= c.SBQQ__Quote__r.POC_Contact__c,
                        Source_Contract__c = c.Id
                    );
                }
                if(assetContracts.containsKey(c.Id)) {
                    List<Asset> assets = assetContracts.get(c.Id);
                    for(Asset asset: assets) {
                        assetToContractMap.put(asset.Id, c.Id);
                        
                        if(asset.Status == 'Customer Subscription Active') asset.Status = 'Customer Subscription Expired';
                        else if(asset.Status != 'Customer Subscription Expired' && c.Evaluation_Quote__c) asset.Status = 'Pending Return – Eval';
                        
                        astUpdate.add(asset);
                        if((asset.Product2.Product_Family_Clean__c == 'Physical' || asset.Product2.Product_Family_Clean__c == 'Product') && c.Evaluation_Quote__c) {
                            items.add(
                                new RMA_Item__c(
                                    Asset__c = asset.Id,
                                    Product2__c = asset.Product2Id, 
                                    RecordTypeId = itemRecordTypeId,
                                    Type__c = 'Return - Refurbish and Stock', 
                                    Status__c = 'Not Dispatched'
                                )
                            );
                        }
                    }
                }
                if(items.size() > 0) rmas.add(rma);
            }
            
            if(!rmas.isEmpty()) {
                insert rmas;
                Map<Id, RMA__c> contToRma = new Map<Id, RMA__c>();
                for(RMA__c rma : rmas) {
                    contToRma.put(rma.Source_Contract__c, rma);
                }
                
                List<RMA_Item__c> insertRma = new List<RMA_Item__c>();
                for(RMA_Item__c item : items){
                    if(assetToContractMap.containsKey(item.Asset__c)) {
                        item.RMA__c = contToRma.get(assetToContractMap.get(item.Asset__c)).Id;
                        insertRma.add(item);
                    }
                }
                upsert insertRma;
            }
            update saList;
            update astUpdate;
            
            List<SBQQ__Quote__c> quoteUpdate = new List<SBQQ__Quote__c>();
            
            for(SBQQ__Quote__c sbq : [SELECT Id, POC_Status__c, SBCF_Evaluation_Quote__c, (SELECT Id FROM SBQQ__Contracts__r WHERE Status != 'Expired' AND (NOT Id IN :contractExpired)) FROM SBQQ__Quote__c WHERE Id IN :quoteParents]) {
                if(sbq.SBQQ__Contracts__r.isEmpty() && !QuoteTriggerHandler.pendingReturnQuoteIds.contains(sbq.Id) && sbq.SBCF_Evaluation_Quote__c) {
                    sbq.POC_Status__c = 'Pending Return';
                    quoteUpdate.add(sbq);
                }
            }
            update quoteUpdate;
            
        }        
         

    }
    
    
    
}