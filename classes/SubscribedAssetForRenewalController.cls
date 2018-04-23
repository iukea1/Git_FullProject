public class SubscribedAssetForRenewalController {
    public Order order {get;set;}
    public Contract contract {get;set;}
    Set<Id> renewedContract = new Set<Id>();
	
    Map<Id, List<SBQQ__Subscription__c>> renewedContractsToSubscription = new Map<Id, List<SBQQ__Subscription__c>>();
	Map<Id, List<SBQQ__SubscribedAsset__c>> subscribedAssetToAsset = new Map<Id, List<SBQQ__SubscribedAsset__c>>();
    List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
    List<SBQQ__SubscribedAsset__c> subscribedAssetToCreate = new List<SBQQ__SubscribedAsset__c>();
    List<Asset> assetToUpdate = new List<Asset>();
   	
    public boolean isSave {get;set;}
	
    public SubscribedAssetForRenewalController(ApexPages.StandardController stdController){
        
        if(!Test.isRunningTest()){
            stdController.addFields(getAllOrderFieldsAPINames());
        }
        
        this.order = (Order)stdController.getRecord();
        
        
    }
    
    
    
    
    public PageReference createRenewal(){
        
        this.isSave = false;
        
        if(this.order.Subscribed_Asset_Created__c){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The subscribed asset was already created.'));
            return null;
        }
        
		Order currentOrder = [SELECT Id, Opportunity.SBQQ__RenewedContract__c, SBQQ__Contracted__c FROM Order WHERE Id =: this.order.Id]; 
        if(currentOrder.Opportunity.SBQQ__RenewedContract__c == null || currentOrder.Opportunity.SBQQ__RenewedContract__c ==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'This is for Renewal Asset only.'));
            return null;
        }
        
        for(SBQQ__Subscription__c rSub: [SELECT Id, SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c, SBQQ__Contract__r.SBQQ__Order__c 
                                                        FROM SBQQ__Subscription__c 
                                                        WHERE SBQQ__Contract__r.SBQQ__Order__c =: this.order.Id 
                                                        AND SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c NOT IN ('', Null)]){
             subscriptionList.add(rSub);
             if(renewedContractsToSubscription.containsKey(rSub.SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c)){
                 List<SBQQ__Subscription__c> renewedSub = renewedContractsToSubscription.get(rSub.SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c);
                 renewedSub.add(rSub);
                 
             }
     
             else{
                 renewedContractsToSubscription.put(rSub.SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c, new List<SBQQ__Subscription__c>{rSub});
             }
                                                            
        }
        
        if(!currentOrder.SBQQ__Contracted__c && subscriptionList.size()<1){
           	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Activate the order. The contract and subscription are not yet available'));
            return null;
        }
        
        Set<Id> renewedContractId = renewedContractsToSubscription.keySet();
        
        for(SBQQ__SubscribedAsset__c assetsRenewed: [SELECT Id, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Asset__c, SBQQ__Subscription__r.SBQQ__Contract__c 
                                                     FROM SBQQ__SubscribedAsset__c 
                                                     WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN: renewedContractId
                                                     AND SBQQ__Asset__r.Is_Selected_For_Renewal__c = TRUE]){
                                                         
             if(subscribedAssetToAsset.containsKey(assetsRenewed.SBQQ__Asset__c)){
             	List<SBQQ__SubscribedAsset__c> subsribedAssetRenewed = subscribedAssetToAsset.get(assetsRenewed.SBQQ__Asset__c);
                subsribedAssetRenewed.add(assetsRenewed); 
             }
             else{
                List<SBQQ__SubscribedAsset__c> subsribedAssetRenewed = new List<SBQQ__SubscribedAsset__c>();
                subsribedAssetRenewed.add(assetsRenewed); 
                subscribedAssetToAsset.put(assetsRenewed.SBQQ__Asset__c, subsribedAssetRenewed);
             }
        }
        
        Set<Id> selectedAssetsIds = subscribedAssetToAsset.keySet();
        
        List<Asset> assetToBeCreateInSubscribeAsset = [SELECT Id, Is_Selected_For_Renewal__c FROM Asset WHERE Id IN: selectedAssetsIds AND Is_Selected_For_Renewal__c = TRUE];
        for(SBQQ__Subscription__c renSub: subscriptionList){
            for(Asset asset: assetToBeCreateInSubscribeAsset){
                asset.SBCF_Subscription__c = renSub.Id;
                assetToUpdate.add(asset);
            }
        }
        
        if(assetToUpdate.size()>0){
            update assetToUpdate;
        }
        
        for(Asset renewedAsset: assetToUpdate){
            SBQQ__SubscribedAsset__c renewedSubs = new SBQQ__SubscribedAsset__c();
            renewedSubs.SBQQ__Subscription__c = renewedAsset.SBCF_Subscription__c;
            renewedSubs.SBQQ__Asset__c = renewedAsset.Id;
            subscribedAssetToCreate.add(renewedSubs);
        }
        
        if(subscribedAssetToCreate.size()>0){
            insert subscribedAssetToCreate;
        }
        
        Order thisOrder = new Order();
        thisOrder.Id = currentOrder.Id;
        thisOrder.Subscribed_Asset_Created__c = true;
        update thisOrder;
        
        isSave = thisOrder.Subscribed_Asset_Created__c;
        
        PageReference page = new PageReference('/' + this.order.Id);
        page.setRedirect(true);
        return page;
        
    }
    
    public PageReference returnToOrder(){
        PageReference page = new PageReference('/' + this.order.Id);
        page.setRedirect(true);
        return page;
    }
    
    public static List<String> getAllOrderFieldsAPINames(){
        List<String> quoteFieldAPINames = new List<String>();

        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Order.fields.getMap();
        
        system.debug('Order Fields: ' + schemaFieldMap.keySet());
        
        for(String fieldAPIName: schemaFieldMap.keySet()){
            quoteFieldAPINames.add(fieldAPIName);
        }

        return quoteFieldAPINames;
    }
	}