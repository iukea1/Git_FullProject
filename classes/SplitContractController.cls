public class SplitContractController {
    
    public Contract contract {get;set;}
    public List<Contract> lstContract {get;set;}
    public Map<Id, List<SBQQ__SubscribedAsset__c>> subsToSubscribedAssetMap {get;set;}
    public List<Asset> assetsToUpdate {get;set;}
    
    public List<SBQQ__Subscription__c> updateTheQuantityOfSubs {get;set;}
    
    public List<SBQQ__Subscription__c> existingSubscription {get;set;}
    public boolean subsToSplitAndSelectedAssetAreEqual {get;set;}    
    
    Set<Id> subIds = new Set<Id>();
    
    public SplitContractController(ApexPages.StandardController stdController){
        
        if(!Test.isRunningTest()){
            stdController.addFields(getAllContractFieldsAPINames());
        }
        
        this.contract = (Contract)stdController.getRecord();
        
        existingSubscription = [SELECT Id, Name, SBQQ__Product__r.Name, SBQQ__ProductName__c, SBQQ__Quantity__c, Quoted_Quantity__c, SBQQ__Contract__c, SBQQ__ListPrice__c, SBQQ__CreditProductId__c, No_of_Subscription_to_Split__c,
                                SBQQ__SubscriptionEndDate__c, SBQQ__SubscriptionStartDate__c, SBCF_Subscription_Status__c, SBQQ__NetPrice__c, SBQQ__CustomerPrice__c,
                                (SELECT Id, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_to_Split__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAssets__r) 
                                FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =: this.contract.Id];
        
        if(existingSubscription == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'There are no renewal subscription available.');
            ApexPages.addMessage(myMsg);
            return;
        }
        
        
        
    }
    public PageReference saveContract(){
        
        updateTheQuantityOfSubs = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c s: existingSubscription){
            
            subsToSubscribedAssetMap = new Map<Id, List<SBQQ__SubscribedAsset__c>>();
            // Create the parent child mapping - Subscription to Subscribed Asset Map
            for(SBQQ__SubscribedAsset__c sa: s.SBQQ__SubscribedAssets__r){
                if(sa.SBQQ__Asset__r.Is_Selected_to_Split__c){
                    if(subsToSubscribedAssetMap.containsKey(s.Id)){
                        List<SBQQ__SubscribedAsset__c> subAssetInSubscription = subsToSubscribedAssetMap.get(s.Id);
                        subAssetInSubscription.add(sa);
                        subsToSubscribedAssetMap.put(s.Id, subAssetInSubscription);
                    }
                    else{
                        subsToSubscribedAssetMap.put(s.Id, new List<SBQQ__SubscribedAsset__c>{sa});
                    }
                }      
            }
            // End of mapping - Subscription to Subscribed Asset Map                   
           
            if(s.No_of_Subscription_to_Split__c	 > 0){
                updateTheQuantityOfSubs.add(s);
            }
            
            else if(s.No_of_Subscription_to_Split__c > s.SBQQ__Quantity__c){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: The number of subscription to split must not be greater than quantity'));
               	return null;
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: The number of subscription to split must not be greater than quantity'));
               	return null;
            }
             
        }
        
        if(updateTheQuantityOfSubs.size()>0){
            update updateTheQuantityOfSubs;
        }
        assetsToUpdate = new List<Asset>();
        for(SBQQ__Subscription__c existingSub: updateTheQuantityOfSubs){
            List<SBQQ__SubscribedAsset__c> selectedAssets = subsToSubscribedAssetMap.get(existingSub.Id);
            for(SBQQ__SubscribedAsset__c selectedAsset: selectedAssets){
                if(selectedAsset.SBQQ__Asset__r.Is_Selected_to_Split__c){
                    Asset updateAsset = new Asset();
                    updateAsset.Id = selectedAsset.SBQQ__Asset__c;
                    updateAsset.Is_Selected_to_Split__c = true;
                    assetsToUpdate.add(updateAsset);
                }
            }
            
            if(existingSub.No_of_Subscription_to_Split__c != assetsToUpdate.size()){
                subsToSplitAndSelectedAssetAreEqual = false;
            }
            else if(existingSub.No_of_Subscription_to_Split__c == assetsToUpdate.size()){
                subsToSplitAndSelectedAssetAreEqual = true;
            }
        }
        
        if(!subsToSplitAndSelectedAssetAreEqual){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: The number of subscription to split must be equal to selected Asset'));
            return null;
        }
        else{
            if(assetsToUpdate.size()>0){
                update assetsToUpdate;
            }
        }
        //validateAndUpdateInputs();
        
        PageReference page = new PageReference('/' + this.contract.Id);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference returnToContract(){
        
        
        
        PageReference page = new PageReference('/' + this.contract.Id);
        page.setRedirect(true);
        return page;
        
    }
    
    public void validateAndUpdateInputs(List<SBQQ__Subscription__c> subs){
        
        
        // End of for loop of Subscription 
         
        
    }
    
    public static List<String> getAllContractFieldsAPINames(){
        List<String> contractFieldAPINames = new List<String>();

        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Contract.fields.getMap();
        
        system.debug('Contract Fields: ' + schemaFieldMap.keySet());
        
        for(String fieldAPIName: schemaFieldMap.keySet()){
            contractFieldAPINames.add(fieldAPIName);
        }

        return contractFieldAPINames;
    }
}