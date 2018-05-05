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
}