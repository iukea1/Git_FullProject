public without sharing class SubscribedAssetTriggerHandler implements ITriggerHandler{
    
    public static final String PRODUCT_NAME_PREFIX_RENEWAL = 'RENEWAL';
    
    
    public SubscribedAssetTriggerHandler(){
        
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
        cleanSerialNumberCaller(newItems.values());
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        
       //displayIncomingSubscribedAsset(newItems.values());
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
    }
    
    public static Map<Id, Id> assetToOrderMap = new Map<Id,Id>();
    
    
    public static void generateHwSerial(List<SBQQ__SubscribedAsset__c> incomingSubAsset) {
        Set<Id> assetCollect = new Set<Id>();
        Set<Id> subsCollect = new Set<Id>();
        for(SBQQ__SubscribedAsset__c sa : incomingSubAsset) {
            assetCollect.add(sa.SBQQ__Asset__c);
            subsCollect.add(sa.SBQQ__Subscription__c);
        }
        List<Asset> newAssetList = [SELECT Id, SBQQ__QuoteLine__c, SBQQ__OrderProduct__c, SBQQ__OrderProduct__r.OrderId FROM Asset WHERE Product_Family__c = 'Product' AND SerialNumber = NULL AND ID IN :assetCollect];
        
        if(!newAssetList.isEmpty()) AssetTriggerHandler.retrieveAssetSerials(newAssetList);
    }
    
    public static void retrieveShipDate(List<SBQQ__SubscribedAsset__c> incomingSubAsset) {
        
    }
    
    public static void displayIncomingSubscribedAsset(List<SBQQ__SubscribedAsset__c> incomingSubAsset){
        
        System.debug('Subscribed Asset : ' + incomingSubAsset);
        
        Set<Id> saIds = new Set<Id>();
        Map<Id, List<SBQQ__SubscribedAsset__c>> subsToSubscribedAssetMap = new Map<Id, List<SBQQ__SubscribedAsset__c>>();
        Map<Id, Asset> subscribedAssetToAsset = new Map<Id, Asset>();
        
        List<SBQQ__SubscribedAsset__c> subscribedAssetToDelete = new List<SBQQ__SubscribedAsset__c>();
                
        for(SBQQ__SubscribedAsset__c sa: incomingSubAsset){
            
            System.debug('@@---------- Subscription Id for Renewed Subscribed Asset : ' + sa.SBQQ__Subscription__c);
            
            if(sa.SBQQ__Subscription__c != null){
                saIds.add(sa.Id);  
            }
            
        }
        
        Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT ID, Is_Selected_For_Renewal__c FROM Asset WHERE ID IN (SELECT SBQQ__Asset__c FROM SBQQ__SubscribedAsset__c WHERE ID IN :saIds)]);
        Map<Id, SBQQ__Subscription__c> subscriptionMap = new Map<Id, SBQQ__Subscription__c>([SELECT Id, SBQQ__ProductName__c FROM SBQQ__Subscription__c WHERE ID IN (SELECT SBQQ__Subscription__c FROM SBQQ__SubscribedAsset__c WHERE ID IN :saIds)]);
        
        for(SBQQ__SubscribedAsset__c renewalSA: [SELECT Id, SBQQ__Subscription__c, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Asset__c 
                                                 FROM SBQQ__SubscribedAsset__c WHERE ID IN: saIds]){
            
            System.debug('subAssetList SBQQ__Asset__r.Is_Selected for renewal : ' + renewalSA.SBQQ__Asset__r.Is_Selected_For_Renewal__c);
            System.debug('Subscription Record of Incoming Subscribed Asset : ' + subscriptionMap.get(renewalSA.SBQQ__Subscription__c).SBQQ__ProductName__c);
            
            SBQQ__Subscription__c parentSub = subscriptionMap.get(renewalSA.SBQQ__Subscription__c);
            
            System.debug('Parent Subscription : ' + parentSub);
            System.debug('Parent Subscription product name : ' + parentSub.SBQQ__ProductName__c);
            
            
            
            if(!String.isEmpty(parentSub.SBQQ__ProductName__c) && parentSub.SBQQ__ProductName__c.Contains(PRODUCT_NAME_PREFIX_RENEWAL)){
                
                System.debug('Product Name : ' + parentSub.SBQQ__ProductName__c);
                
                Asset parentAsset = assetMap.get(renewalSA.SBQQ__Asset__c);
                
                System.debug('Parent Asset : ' + parentAsset);
                System.debug('Parent Asset is Selected for Renewal : ' + parentAsset.Is_Selected_For_Renewal__c);
                
                if(!parentAsset.Is_Selected_For_Renewal__c){
                    
                    System.debug('asset for delete: ' + parentAsset.Is_Selected_For_Renewal__c);
                    
                    subscribedAssetToDelete.add(renewalSA);
                    
                }
                
                System.debug('Subscribed Asset to be deleted : ' + subscribedAssetToDelete);
            }
            
        }
        
        if(!subscribedAssetToDelete.isEmpty()){
            Database.delete(subscribedAssetToDelete, false);
        }
        
    }
    
    
    public static Boolean isFuture = false;
    public static void cleanSerialNumberCaller(List<SBQQ__SubscribedAsset__c> incomingSubAsset) {
        Set<Id> incomingSubAssetIds = new Set<Id>();
        for(SBQQ__SubscribedAsset__c sa : incomingSubAsset) incomingSubAssetIds.add(sa.Id);
        
        if(!isFuture) cleanSerialNumber(incomingSubAssetIds);
        else cleanSerialSync(incomingSubAssetIds);
    }
    
    
    public static void cleanSerialSync(Set<Id> incomingSubAssetIds) {
    
        List<SBQQ__SubscribedAsset__c> incomingSubAsset = [SELECT Id, SBQQ__Asset__c, SBQQ__Active__c, SBQQ__UsageEndDate__c, SBQQ__ContractId__c, External_ID__c, SBQQ__Subscription__c FROM SBQQ__SubscribedAsset__c WHERE Id IN: incomingSubAssetIds];
    
        generateHwSerial(incomingSubAsset);
    
        List<Asset> assetDelete = new List<Asset>();
        List<Asset> assetUpdate = new List<Asset>();
        Set<Id> asstIds = new Set<Id>();

        for(SBQQ__SubscribedAsset__c sa : incomingSubAsset) {
            asstIds.add(sa.SBQQ__Asset__c);
        }

        Map<Id, Asset> assetSerial = new Map<Id, Asset>([SELECT Id, SerialNumber, SBQQ__OrderProduct__r.OrderId FROM Asset WHERE Id IN :asstIds]);

        Map<String, String> serNumberOldAsset = getAllData(assetSerial.values());
        Boolean doUpdate = false;
        for(SBQQ__SubscribedAsset__c sa : incomingSubAsset) {
            //assetUpdate.add();
            if(assetSerial.containsKey(sa.SBQQ__Asset__c) && serNumberOldAsset.containsKey(assetSerial.get(sa.SBQQ__Asset__c).SerialNumber)) {
                assetDelete.add(new Asset(Id=sa.SBQQ__Asset__c));
                String assetId = serNumberOldAsset.get(assetSerial.get(sa.SBQQ__Asset__c).SerialNumber);
                sa.SBQQ__Asset__c = assetId;
                doUpdate = true;
            }
        }
        if(!assetDelete.isEmpty()) delete assetDelete;
        if(doUpdate) update incomingSubAsset;
    }
    
    @future
    public static void cleanSerialNumber(Set<Id> incomingSubAssetIds) {
        cleanSerialSync(incomingSubAssetIds);
    }
    
    
    private static Map<String, String> getAllData(List<Asset> createdAssets) {
        Map<String, String> serNumberOldAsset = new Map<String, String>();
        Set<String> snSet = new Set<String>();
        Set<Id> orderSet = new Set<Id>();
        
        for(Asset a : createdAssets){
            snSet.add(a.SerialNumber);
            orderSet.add(a.SBQQ__OrderProduct__r.OrderId);
        }
        
        for(Order_Product_Item__c opi : [SELECT Id, Existing_Asset__c, Serial_Number__c FROM Order_Product_Item__c 
        WHERE (NOT Asset__c IN :createdAssets) AND Serial_Number__c IN :snSet AND Existing_Asset__c != NULL AND Order_Product__r.OrderId IN :orderSet]) {
            serNumberOldAsset.put(opi.Serial_Number__c, opi.Existing_Asset__c);
        }

        System.debug('------------------>>> CleanSerialNumber : query: ' + [SELECT Id, Existing_Asset__c, Serial_Number__c FROM Order_Product_Item__c WHERE Asset__c IN :createdAssets AND Existing_Asset__c != NULL]);
        return serNumberOldAsset;
    }
}