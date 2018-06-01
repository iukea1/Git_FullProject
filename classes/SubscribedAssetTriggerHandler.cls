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
        cleanSerialNumberCaller(newItems);
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        //cleanSerialNumber(newItems.values());
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        
       displayIncomingSubscribedAsset(newItems.values());
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
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
        /*
        for(SBQQ__SubscribedAsset__c renewalSA: subAssetList){
                                                                                                                                                                                                                                                                                                  
            if(subsToSubscribedAssetMap.containsKey(renewalSA.SBQQ__Subscription__c)){
                 List<SBQQ__SubscribedAsset__c> renewalSAs = subsToSubscribedAssetMap.get(renewalSA.SBQQ__Subscription__c);
                 renewalSAs.add(renewalSA);
            }
     
            else{
                 subsToSubscribedAssetMap.put(renewalSA.SBQQ__Subscription__c, new List<SBQQ__SubscribedAsset__c>{renewalSA});
            }
                                                     
            if(assetMap.containsKey(renewalSA.SBQQ__Asset__c)){
                   subscribedAssetToAsset.put(renewalSA.SBQQ__Subscription__c, assetMap.get(renewalSA.SBQQ__Asset__c));
            }                                              
        } */
        
        
        
        //Set<Id> subsIds = subsToSubscribedAssetMap.keySet();
        /*
        for(SBQQ__Subscription__c renewedSub: [SELECT Id, SBQQ__ProductName__c, SBQQ__Product__r.Name FROM SBQQ__Subscription__c WHERE Id IN: subsToSubscribedAssetMap.keySet()]){
            
            System.debug('renewedSub : ' + renewedSub);
            
            
               if(renewedSub.SBQQ__ProductName__c.contains('Renewal')){
                   
                   System.debug('renewedSub.SBQQ__ProductName__c : ' + renewedSub.SBQQ__ProductName__c);
                   
                   if(subscribedAssetToAsset.containsKey(renewedSub.Id)){
                       
                       if(!subscribedAssetToAsset.get(renewedSub.Id).Is_Selected_For_Renewal__c){
                           System.debug('subscribedAssetToAsset.get(renewedSub.Id).Is_Selected_For_Renewal__c : ' + subscribedAssetToAsset.get(renewedSub.Id).Is_Selected_For_Renewal__c);
                          List<SBQQ__SubscribedAsset__c> lstSA = subsToSubscribedAssetMap.get(renewedSub.Id);
                           
                           for(SBQQ__SubscribedAsset__c saRec: lstSA){
                               saRec.SBQQ__Active__c = false;
                               sbaToDeactivate.add(saRec);
                               System.debug('sbaToDeactivate' + sbaToDeactivate);

                           }
                           
                       }
                   }
               } 
               
        }
        */
        
        //List<SBQQ__Subscription__c> renewedSub = [SELECT Id, SBQQ__ProductName__c, SBQQ__Product__r.Name FROM SBQQ__Subscription__c WHERE Id IN: subsIds];
        
        /*
        
        List<SBQQ__SubscribedAsset__c> renewalSubAsset = [SELECT Id, SBQQ__Subscription__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Asset__r.Is_Selected_For_Renewal__c 
                                                          FROM SBQQ__SubscribedAsset__c WHERE ID IN: saIds 
                                                          AND SBQQ__Subscription__r.SBQQ__Product__r.Name = '%RENEWAL%'];
        
        System.debug('RENEWAL SUBSCRIBED ASSET : ' + renewalSubAsset);

        for(SBQQ__SubscribedAsset__c rsa: renewalSubAsset){
            
            if(rsa.SBQQ__Subscription__r.SBQQ__ProductName__c.contains('Renewal')){
                
                if(rsa.SBQQ__Asset__r.Is_Selected_For_Renewal__c){
                    sbaForRenewed.add(rsa);
                }
            
                System.debug('sbaForRenewed : ' + sbaForRenewed);
                
                if(!rsa.SBQQ__Asset__r.Is_Selected_For_Renewal__c){
                    rsa.SBQQ__Active__c = false;
                    sbaToDeactivate.add(rsa);
                }
            }
            
            
            System.debug('sbaToDeactivate : ' + sbaToDeactivate);
 
        }
        
        if(sbaToDeactivate.size()>0){
            update sbaToDeactivate;
        }
        */
        
    }
    public static void cleanSerialNumberCaller(List<SBQQ__SubscribedAsset__c> incomingSubAsset) {
        Set<Id> incomingSubAssetIds = new Set<Id>();
        for(SBQQ__SubscribedAsset__c sa : incomingSubAsset) incomingSubAssetIds .add(sa.Id);
        
        cleanSerialNumber(incomingSubAssetIds);
    }
    @future
    public static void cleanSerialNumber(Set<Id> incomingSubAssetIds) { 
        List<SBQQ__SubscribedAsset__c> incomingSubAsset = [SELECT Id, SBQQ__Asset__c, SBQQ__Active__c, SBQQ__UsageEndDate__c, SBQQ__ContractId__c, External_ID__c, SBQQ__Subscription__c FROM SBQQ__SubscribedAsset__c WHERE Id IN: incomingSubAssetIds];
        System.debug('------------------>>> Entering CleanSerialNumber');
        List<Asset> assetDelete = new List<Asset>();
        List<Asset> assetUpdate = new List<Asset>();
        Map<String, String> serNumberOldAsset = getAllData(incomingSubAsset);
        Set<Id> asstIds = new Set<Id>();

        for(SBQQ__SubscribedAsset__c sa : incomingSubAsset) {
            asstIds.add(sa.SBQQ__Asset__c);
        }

        Map<Id, Asset> assetSerial = new Map<Id, Asset>([SELECT Id, SerialNumber FROM Asset WHERE Id IN :asstIds]);

        System.debug('------------------>>> CleanSerialNumber : serNumberOldAsset : ' + serNumberOldAsset);
        System.debug('------------------>>> CleanSerialNumber : assetSerial : ' + assetSerial);
        
        for(SBQQ__SubscribedAsset__c sa : incomingSubAsset) {
            //assetUpdate.add();
            if(assetSerial.containsKey(sa.SBQQ__Asset__c) && serNumberOldAsset.containsKey(assetSerial.get(sa.SBQQ__Asset__c).SerialNumber)) {
                assetDelete.add(new Asset(Id=sa.SBQQ__Asset__c));
                String assetId = serNumberOldAsset.get(assetSerial.get(sa.SBQQ__Asset__c).SerialNumber);
                System.debug('------------------>>> CleanSerialNumber : subscribe asset update: from ' + sa.SBQQ__Asset__c + ' to ' + assetId);
                sa.SBQQ__Asset__c = assetId;
            }
        }
        System.debug('------------------>>> CleanSerialNumber : assetDelete: ' + assetDelete);
        if(!assetDelete.isEmpty()) delete assetDelete;
    }
    private static Map<String, String> getAllData(List<SBQQ__SubscribedAsset__c> incomingSubAsset) {
        //Map<Id, SBQQ__SubscribedAsset__c> fullData = new Map<Id, SBQQ__SubscribedAsset__c>(
        //        [SELECT Id, SBQQ__Asset__c, SBQQ__Subscription__c, SBQQ__Subscription__r.SBQQ__OrderProduct__c FROM SBQQ__SubscribedAsset__c WHERE Id IN :incomingSubAsset]
        //);
        Set<Id> subsSet = new Set<Id>();
        for(SBQQ__SubscribedAsset__c sa : incomingSubAsset) {
            subsSet.add(sa.SBQQ__Subscription__c);
        }
        Map<Id, SBQQ__Subscription__c> fullData = new Map<Id, SBQQ__Subscription__c>(
                [SELECT Id, SBQQ__OrderProduct__c FROM SBQQ__Subscription__c WHERE Id IN :subsSet]
        );
        System.debug('------------------>>> CleanSerialNumber : fullData : ' + fullData );
        Set<Id> ordProdIds = new Set<Id>();
        for(SBQQ__Subscription__c sa : fullData.values()) {
            ordProdIds.add(sa.SBQQ__OrderProduct__c);
        }
        System.debug('------------------>>> CleanSerialNumber : ordProdIds: ' + ordProdIds);

        Map<String, String> serNumberOldAsset = new Map<String, String>();
        for(OrderItem op : [SELECT Id, (SELECT Id, Existing_Asset__c, Serial_Number__c FROM Order_Product_Items__r) FROM OrderItem WHERE Id IN :ordProdIds]) {
            for(Order_Product_Item__c opi : op.Order_Product_Items__r) {
                serNumberOldAsset.put(opi.Serial_Number__c, opi.Existing_Asset__c);
            }
        }
        System.debug('------------------>>> CleanSerialNumber : query: ' + [SELECT Id, (SELECT Id, Existing_Asset__c, Serial_Number__c FROM Order_Product_Items__r) FROM OrderItem WHERE Id IN :ordProdIds]);
        return serNumberOldAsset;
    }
}