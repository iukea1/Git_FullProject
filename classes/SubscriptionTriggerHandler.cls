/*********************************************************************
*  Created By: drew.justus@simplus.com
*  Created Date: 2.15.2018
*  Description: Trigger on subscription to populate related asset lookup
*  field with related subscription. Locates related asset through required
*  by field on subscription quote lines. 
*
*  @Test: SubscriptionTriggerTest - 89%
*
*  ** Trigger will need to be modifed to meet updated requirement once they
*     are fully defined.
*
**********************************************************************/
public without sharing class SubscriptionTriggerHandler implements ITriggerHandler{
    
    public static final String PRODUCT_NAME_PREFIX_SMART_HANDS = 'SMRT-HND';
    public static final Datetime THIRTY_SECONDS_AGO = System.now().addSeconds(-30);
    
    public SubscriptionTriggerHandler()
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
        if(newItems!=null && newItems.size()>0)
        {
            for (Id subId : newItems.keyset())
            {
               
            }
            
        }
        
       populateRelatedAssetSubscriptionLookups(newItems.values());
       //populateRelatedSubscriptionAssetLookups(newItems.values());
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
    }
  
    public static void populateRelatedAssetSubscriptionLookups(List<SBQQ__Subscription__c> incomingSubscriptions){
        // Used in action method
        Map<Id, Id> assetTosubscription = new Map<Id, Id>();
        Set<id> assetThatHasSubscription = new Set<Id>();
		List<SBQQ__Subscription__c> subscriptionWithAsset = new List<SBQQ__Subscription__c>();
        
        Map<Id, List<SBQQ__Subscription__c>> quoteLineIdsToSubscriptions = buildQuoteLineIdsToSubscriptions(incomingSubscriptions);
        
        if(quoteLineIdsToSubscriptions.keySet() == null){
            System.debug('There are no quote lines related to incoming subscriptions. ');
            return;
        }
        
        Set<Id> subscriptionQuoteLineIds = quoteLineIdsToSubscriptions.keySet();
        // Map quote line Id to Quote Line
        Map<Id, SBQQ__QuoteLine__c> subscriptionQuoteLineMap = queryForSubscriptionQuoteLines(subscriptionQuoteLineIds);
        
        if(subscriptionQuoteLineMap.size() == 0){
            System.debug('No quote lines were returned related to subscription quote lines.');
            return;
        }
        
        //Map<Id, Set<Id>> subscriptionQuoteLineIdToRequiredByQuoteLineIds = buildSubscriptionQuoteLineIdToRequiredByQuoteLineIds(subscriptionQuoteLineMap.values());
        
        //if(subscriptionQuoteLineIdToRequiredByQuoteLineIds.size() == 0){
        //	System.debug('No subscription quote lines with required by quote line populated.');
        //}
        
        //Set<Id> requiredByQuoteLineIds = getRequiredByQuoteLineIds(subscriptionQuoteLineIdToRequiredByQuoteLineIds.values());
        Set<Id> requiredByQuoteLineIds = getRequiredByQuoteLineIds(subscriptionQuoteLineMap.values());
        List<Asset> assetsRelatedToSubscriptions = queryForAssetsRelatedToSubscriptionsRequiredByIds(requiredByQuoteLineIds);
        
        if(assetsRelatedToSubscriptions.size() == 0){
            System.debug('No assets were found relating to the subscription quote lines required by quote line.');
            return;
        }
        
        Map<Id, Set<Id>> subscriptionRequiredByIdToSubscriptionQuoteLineIds = buildSubscriptionRequiredByIdToSubscriptionQuoteLineIds(subscriptionQuoteLineMap.values());
        
        List<Asset> assetsToUpdate = updateAssetsWithSubscriptionLookups(assetsRelatedToSubscriptions, subscriptionRequiredByIdToSubscriptionQuoteLineIds, quoteLineIdsToSubscriptions);
        
        System.debug('Assets to update: ' + assetsToUpdate);
        
        if(assetsToUpdate.size() > 0){
            update assetsToUpdate;
        }
        
        // This is the process to populate the related asset to Subscription detail page. 
        for(Asset assetRec: assetsToUpdate){
            assetThatHasSubscription.add(assetRec.SBCF_Subscription__c);
            assetTosubscription.put(assetRec.SBCF_Subscription__c, assetRec.Id);
        }
        
        List<SBQQ__Subscription__c> subsInAsset = queryForAllSubscriptionsInAsset(assetThatHasSubscription);
        
        for(SBQQ__Subscription__c subs: subsInAsset){
            subs.SBCF_Asset__c = assetToSubscription.get(subs.Id);
            subscriptionWithAsset.add(subs);
        }
        
        if(subscriptionWithAsset.size()>0){
            update subscriptionWithAsset;
        }
        
        
    }
    
    // Action
    private static List<Asset> updateAssetsWithSubscriptionLookups(List<Asset> assetsRelatedToSubscriptions, Map<Id, Set<Id>> subscriptionRequiredByIdToSubscriptionQuoteLineIds,
                                                                   Map<Id, List<SBQQ__Subscription__c>> quoteLineIdsToSubscriptions){
                                                                       
                                                                       System.debug('Update Assets With Subscription Lookups Method.');
                                                                       List<Asset> assetsToUpdate = new List<Asset>();
                                                                       
                                                                       for(Asset asset: assetsRelatedToSubscriptions){
                                                                           Set<Id> subscriptionQuoteLineIds = subscriptionRequiredByIdToSubscriptionQuoteLineIds.get(asset.SBQQ__QuoteLine__c);
                                                                           
                                                                           if(subscriptionQuoteLineIds == null){
                                                                               System.debug('No subscription quote line Ids related to Assets for Asset: ' + asset);
                                                                               continue;
                                                                           }
                                                                           
                                                                           List<SBQQ__Subscription__c> subscriptionsRelatedToAsset = new List<SBQQ__Subscription__c>();
                                                                           for(Id subscriptionQuoteLineId: subscriptionQuoteLineIds){
                                                                               List<SBQQ__Subscription__c> subscriptions = quoteLineIdsToSubscriptions.get(subscriptionQuoteLineId);
                                                                               if(subscriptions == null){
                                                                                   System.debug('No subscription in quoteLineIdsToSubscriptions map with id: ' + subscriptionQuoteLineId);
                                                                                   continue;
                                                                               }
                                                                               subscriptionsRelatedToAsset.addAll(subscriptions);
                                                                           }
                                                                           
                                                                           if(subscriptionsRelatedToAsset.size() == 0){
                                                                               System.debug('There were no subscriptions related to asset with Id: ' + asset.Id);
                                                                           }
                                                                           else{
                                                                               System.debug('Subscriptions found related to asset.');
                                                                               System.debug('Updating asset with Id: ' + asset.Id + ' with subscription lookups with the following subscriptions: ' + subscriptionsRelatedToAsset);
                                                                               
                                                                               SBQQ__Subscription__c subscription;
                                                                               SBQQ__Subscription__c smartHandsSubscription;
                                                                               
                                                                               for(SBQQ__Subscription__c relatedSubscription: subscriptionsRelatedToAsset){
                                                                                   if(!String.isEmpty(relatedSubscription.SBQQ__ProductName__c) && relatedSubscription.SBQQ__ProductName__c.Contains(PRODUCT_NAME_PREFIX_SMART_HANDS)){
                                                                                       System.debug('Smart hand Subscription found: ' + relatedSubscription.Id);
                                                                                       smartHandsSubscription = relatedSubscription;
                                                                                   }else{
                                                                                       System.debug('Non smart hand subscription found: ' + relatedSubscription.Id);
                                                                                       subscription = relatedSubscription;
                                                                                   }
                                                                               }
                                                                               
                                                                               // Should not be the case since the trigger is on subscription
                                                                               if(subscription == null && smartHandsSubscription == null){
                                                                                   System.debug('No Subscription or Smart Hand Subscription Found for Asset with Id: ' + asset.Id);
                                                                                   continue;
                                                                               }
                                                                               else{
                                                                                   if(subscription != null){
                                                                                       asset.SBCF_Subscription__c = subscription.Id;
                                                                                   }
                                                                                   if(smartHandsSubscription != null){
                                                                                       asset.Smart_Hands_Subscription__c = smartHandsSubscription.Id;
                                                                                   }
                                                                                   
                                                                                   assetsToUpdate.add(asset);
                                                                               }
                                                                               
                                                                           }
                                                                           
                                                                       }
                                                                       
                                                                       return assetsToUpdate;
                                                                   }
    
    private static Map<Id, Set<Id>> buildSubscriptionRequiredByIdToSubscriptionQuoteLineIds(List<SBQQ__QuoteLine__c> subscriptionQuoteLines){
        Map<Id, Set<Id>> subscriptionRequiredByIdToSubscriptionQuoteLineIds = new Map<Id, Set<Id>>();
        
        System.debug('subscription Quote Lines in buildSubscriptionRequiredByIdToSubscriptionQuoteLineIds: ' + subscriptionQuoteLines);
        
        for(SBQQ__QuoteLine__c subscriptionQuoteLine: subscriptionQuoteLines){
            if(subscriptionQuoteLine.SBQQ__RequiredBy__c == null){
                continue;
            }
            
            Set<Id> subscriptionQuoteLineIds = subscriptionRequiredByIdToSubscriptionQuoteLineIds.get(subscriptionQuoteLine.SBQQ__RequiredBy__c);
            
            if(subscriptionQuoteLineIds == null){
                subscriptionQuoteLineIds = new Set<Id>();
                subscriptionRequiredByIdToSubscriptionQuoteLineIds.put(subscriptionQuoteLine.SBQQ__RequiredBy__c, subscriptionQuoteLineIds);
            }
            
            subscriptionQuoteLineids.add(subscriptionQuoteLine.Id);
        }
        
        System.debug('Subscription Required By Id To Subsciprition Quote Line Ids: ' + subscriptionRequiredByIdToSubscriptionQuoteLineIds);
        
        return subscriptionRequiredByIdToSubscriptionQuoteLineIds;
    }
    
    private static List<Asset> queryForAssetsRelatedToSubscriptionsRequiredByIds(Set<Id> requiredBySubscriptionQuoteLineIds){
        List<Asset> assetsRelatedToSubscriptions = new List<Asset>();
        
        try{
            assetsRelatedToSubscriptions = [SELECT Id, SBQQ__QuoteLine__c, SBQQ__Subscription__c, Smart_Hands_Subscription__c FROM Asset WHERE SBQQ__QuoteLine__c IN :requiredBySubscriptionQuoteLineIds AND LastModifiedDate >= :THIRTY_SECONDS_AGO];
        }
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }
        
        System.debug('Assets related to Subscriptions: ' + assetsRelatedToSubscriptions);
        
        return assetsRelatedToSubscriptions;
    } 
    
    //private static Set<Id> getRequiredByQuoteLineIds(List<Set<Id>> requiredByQuoteLineIds){
    //	Set<Id> requiredByQuoteLineIdsFullList = new Set<Id>();
    
    //	for(Set<Id> quoteLineIdsRequiredBySubQuoteLine: requiredByQuoteLineIds){
    //		requiredByQuoteLineIdsFullList.addAll(quoteLineIdsRequiredBySubQuoteLine);
    //	}
    
    //	System.debug('Required By Quote Line Ids Full List: ' + requiredByQuoteLineIdsFullList);
    //	return requiredByQuoteLineIdsFullList;
    //}
    
    private static Set<Id> getRequiredByQuoteLineIds(List<SBQQ__QuoteLine__c> subscriptionQuoteLines){
        Set<Id> requiredByQuoteLineIds = new Set<Id>();
        
        for(SBQQ__QuoteLine__c quoteLine: subscriptionQuoteLines){
            if(quoteLine.SBQQ__RequiredBy__c == null){
                continue;
            }
            
            requiredByQuoteLineIds.add(quoteLine.SBQQ__RequiredBy__c);
        }
        
        return requiredByQuoteLineIds;
    }
    
    //private static Map<Id, Set<Id>> buildSubscriptionQuoteLineIdToRequiredByQuoteLineIds(List<SBQQ__QuoteLine__c> subscriptionQuoteLines){
    //	Map<Id, Set<Id>> subscriptionQuoteLineIdToRequiredByQuoteLineIds = new Map<Id, Set<Id>>();
    
    //	for(SBQQ__QuoteLine__c subscriptionQuoteLine: subscriptionQuoteLines){
    //		if(subscriptionQuoteLine.SBQQ__RequiredBy__c == null){
    //			continue;
    //		}
    
    //		Set<Id> requiredByQuoteLineIds = subscriptionQuoteLineIdToRequiredByQuoteLineIds.get(subscriptionQuoteLine.SBQQ__RequiredBy__c);
    
    //		if(requiredByQuoteLineIds == null){
    //			requiredByQuoteLineIds = new Set<Id>();
    //			subscriptionQuoteLineIdToRequiredByQuoteLineIds.put(subscriptionQuoteLine.SBQQ__RequiredBy__c, requiredByQuoteLineIds);
    //		}
    
    //		requiredByQuoteLineIds.add(subscriptionQuoteLine.SBQQ__RequiredBy__c);
    //	}
    
    //	System.debug('Subscription Quote Line Id To Required By Quote Line Ids: ' + subscriptionQuoteLineIdToRequiredByQuoteLineIds);
    //	return subscriptionQuoteLineIdToRequiredByQuoteLineIds;
    //}
    
    private static Map<Id, List<SBQQ__Subscription__c>> buildQuoteLineIdsToSubscriptions(List<SBQQ__Subscription__c> incomingSubscriptions){
        Map<Id, List<SBQQ__Subscription__c>> quoteLineIdsToSubscriptions = new Map<Id, List<SBQQ__Subscription__c>>();
        
        for(SBQQ__Subscription__c subscription: incomingSubscriptions){
            if(subscription.SBQQ__QuoteLine__c == null){
                continue;
            }
            
            List<SBQQ__Subscription__c> subscriptionsRelatedToQuoteLine = quoteLineIdsToSubscriptions.get(subscription.SBQQ__QuoteLine__c);
            
            if(subscriptionsRelatedToQuoteLine == null){
                subscriptionsRelatedToQuoteLine = new List<SBQQ__Subscription__c>();
                quoteLineIdsToSubscriptions.put(subscription.SBQQ__QuoteLine__c, subscriptionsRelatedToQuoteLine);
            }
            
            subscriptionsRelatedToQuoteLine.add(subscription);
        }
        
        System.debug('Quote Line Id To Subscription Id: ' + quoteLineIdsToSubscriptions);
        return quoteLineIdsToSubscriptions;
    }
    
    private static Map<Id, SBQQ__QuoteLine__c> queryForSubscriptionQuoteLines(Set<Id> subscriptionQuoteLineIds){
        Map<Id, SBQQ__QuoteLine__c> subscriptionQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        
        try{
            subscriptionQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE Id IN :subscriptionQuoteLineIds]);
        }
        catch(QueryException qe){
            system.debug(qe.getMessage());
        }
        
        System.debug('Subscription Quote Line Map: ' + subscriptionQuoteLineMap);
        return subscriptionQuoteLineMap;
    }
    
    
    // Populate the related Asset to the Subsccription's Asset Lookup field
    // Author: Ronald Pascual 
    // Date: March 20, 2018
    // Description: Reuse the logic that was currently implemented to the Asset's subscription lookup, which will be apply this logic to Subcription's Asset Lookup field. 
    public static List<SBQQ__Subscription__c> queryForAllSubscriptionsInAsset(Set<Id> assetThatHasSubs){
        List<SBQQ__Subscription__c> subscriptionInAsset = new List<SBQQ__Subscription__c>();
        
        try{
            subscriptionInAsset = [SELECT Id, SBCF_Asset__c FROM SBQQ__Subscription__c WHERE Id IN: assetThatHasSubs];
        }
        catch(QueryException qe){
            system.debug(qe.getMessage());
        }
        return subscriptionInAsset;
    }
    
    public static void populateRelatedSubscriptionAssetLookups(List<SBQQ__Subscription__c> incomingSubs){
        List<SBQQ__Subscription__c> subcriptionsToUpdate = new List<SBQQ__Subscription__c>();
        Set<Id> subscriptionIdsSet = new Set<Id>();
        Map<Id, Id> subscriptionToAssetMap = new Map<Id, Id>();
        
        for(SBQQ__Subscription__c subscription: incomingSubs){
            subscriptionIdsSet.add(subscription.Id);
        }
        
        for(Asset asset: [SELECT Id, SBQQ__Subscription__c FROM Asset WHERE SBQQ__Subscription__c IN :subscriptionIdsSet]){
            subscriptionToAssetMap.put(asset.SBQQ__Subscription__c, asset.Id);
        }
        
        for(SBQQ__Subscription__c subs: incomingSubs){
            subs.SBCF_Asset__c = subscriptionToAssetMap.get(subs.Id);
            subcriptionsToUpdate.add(subs);
        }
        
        if(subcriptionsToUpdate.size()>0){
            update subcriptionsToUpdate;
        }
        
        
        //List<SBQQ__Subscription__c> quoteLineRelatedToAsset = [SELECT Id, Name (SELECT Id, Name FROM SBQQ__SubscribedAsset__c) FROM SBQQ__Subscription__c WHERE Id IN: subscriptionIdsSet];
        
    }
    
}