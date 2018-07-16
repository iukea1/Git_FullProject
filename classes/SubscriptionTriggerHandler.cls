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
    public static final String PRODUCT_NAME_PREFIX_RENEWAL = 'RENEWAL';
    public static final String PRODUCT_FORECAST_CATEGORY_VIRTUAL = 'Virtual';

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
       UpdateGMS_Nodes(newItems.values());
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
        List<SBQQ__SubscribedAsset__c> subscriptionAndAssetList = new List<SBQQ__SubscribedAsset__c>();
        List<SBQQ__Subscription__c> newlyGeneratedSubscription = new List<SBQQ__Subscription__c>();
        Set<id> renewalSubscriptions = new Set<id>();
   
        //Start of the process for renewal
        for(SBQQ__Subscription__c subs: incomingSubscriptions){
            if(!String.isEmpty(subs.SBQQ__ProductName__c) && 
               subs.SBQQ__ProductName__c.Contains(PRODUCT_NAME_PREFIX_RENEWAL)){
               
                   System.debug('Renewal Subscription : ' + subs);
                   
                   renewalSubscriptions.add(subs.id); 
                   
            }
            else{
               newlyGeneratedSubscription.add(subs); 
            }
        }
        
        System.debug('Renewed Subscription : ' + renewalSubscriptions);
        System.debug('Newly generated subscription : ' + newlyGeneratedSubscription);
        
        
        if(newlyGeneratedSubscription.size()>0){
            
            Map<Id, List<SBQQ__Subscription__c>> quoteLineIdsToSubscriptions = buildQuoteLineIdsToSubscriptions(newlyGeneratedSubscription);
        
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
            Set<id> newSubs = new Set<id>();
            
            for(Asset assetRec: assetsToUpdate){
                newSubs.add(assetRec.SBCF_Subscription__c);
            }
            boolean isRenewal = false;
            for(SBQQ__Subscription__c subRecs: [SELECT Id, SBQQ__ProductName__c 
                                                FROM SBQQ__Subscription__c 
                                                WHERE Id IN: newSubs 
                                                AND SBQQ__ProductName__c LIKE '%RENEWAL%']){
                if(subRecs.SBQQ__ProductName__c.contains('RENEWAL')){
                    isRenewal = true;
                }
            }
            System.debug(' isRnewal :' + isRenewal);
            // This is the process to populate the related asset to Subscription detail page. 
            for(Asset assetRec: assetsToUpdate){
                
                System.debug('assetRec.SBCF_Subscription__c  : ' + assetRec.SBCF_Subscription__c);
                System.debug('assetRec.Id   : ' + assetRec.Id);
                
                if(!isRenewal){
                     subscriptionAndAssetList.add(new SBQQ__SubscribedAsset__c(SBQQ__Subscription__c = assetRec.SBCF_Subscription__c, SBQQ__Asset__c = assetRec.Id, SBQQ__Active__c = true));
                     System.debug(' subscriptionAndAssetList : ' + subscriptionAndAssetList);
                }
               
            }
            
                if(subscriptionAndAssetList.size()>0){
                    insert subscriptionAndAssetList;
                }
            }
        
        else{
            if(renewalSubscriptions.size()>0){
                system.debug('renewalSubscriptions: ' + renewalSubscriptions);
                List<SBQQ__SubscribedAsset__c> subAssetList = new List<SBQQ__SubscribedAsset__c>();
                
                List<SBQQ__Subscription__c> subList = [SELECT Id, (SELECT Id, Name, SBQQ__Subscription__c, SBQQ__Asset__c, SBQQ__Asset__r.Is_Selected_For_Renewal__c 
                                                                         FROM SBQQ__SubscribedAssets__r 
                                                                         WHERE SBQQ__Subscription__c IN: renewalSubscriptions 
                                                                         AND SBQQ__Asset__r.Is_Selected_For_Renewal__c = TRUE) 
                                                                         FROM SBQQ__Subscription__c WHERE ID IN: renewalSubscriptions];
                
                for(SBQQ__Subscription__c s: subList){
                    List<SBQQ__SubscribedAsset__c> subListAsset = s.SBQQ__SubscribedAssets__r;
                        for(SBQQ__SubscribedAsset__c sa: subListAsset){
                            system.debug('renewal sub asset ' + sa);
                        }
                }
                
                List<SBQQ__SubscribedAsset__c> renewalSubscribedAsset = [SELECT Id, Name, SBQQ__Subscription__c, SBQQ__Asset__c, SBQQ__Asset__r.Is_Selected_For_Renewal__c 
                                                                         FROM SBQQ__SubscribedAsset__c 
                                                                         WHERE SBQQ__Subscription__c IN: renewalSubscriptions 
                                                                         AND SBQQ__Asset__r.Is_Selected_For_Renewal__c = TRUE];
                
                System.debug('renewal Subscribed Asset : ' +  renewalSubscribedAsset);
                
                //createSubscribedAssetForRenewal(renewalSubscriptions);  
            }
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
                                                                               if(subscription == null){
                                                                                   System.debug('No Subscription or Smart Hand Subscription Found for Asset with Id: ' + asset.Id);
                                                                                   continue;
                                                                               }
                                                                               else{
                                                                                   if(subscription != null){
                                                                                       asset.SBCF_Subscription__c = subscription.Id;
                                                                                   }
                                                                                   //if(smartHandsSubscription != null){
                                                                                   //    asset.Smart_Hands_Subscription__c = smartHandsSubscription.Id;
                                                                                   //}
                                                                                   
                                                                                   assetsToUpdate.add(asset);
                                                                               }
                                                                               
                                                                           }
                                                                           
                                                                       }
                                                                       
                                                                       return assetsToUpdate;
                                                                   }
                                                                   
    /*
    Method to update the Asset's GMS Nodes field if the Subscription's Product is Upgraded
    */
    private static void UpdateGMS_Nodes (List<SBQQ__Subscription__c> SubscriptionList){
        
        Set<Id> ContractIds = new Set<Id>();
        Set<Id> OrderIds = new Set<Id>();
        Set<Id> OpportunityIds = new Set<Id>();
        Set<Id> OrderProdIds = new Set<Id>();
        Set<Id> QuoteLineIds = new Set<Id>();
        Set<Id> QuoteIds = new Set<Id>();
        Set<Id> subsIds = new Set<Id>();
        
        List<Asset> updateAsset = new List<Asset>();
        Id SubscriptionContract;
        Boolean MatchedContract = false;
        Id toGetAsset;
        Id CurrentSubscription;
        
        Boolean IsGMS25 = false;
        Boolean IsGMS50 = false;
        Boolean IsGMS100 = false;
        Boolean IsGMS200 = false;
        Boolean IsGMS500 = false;
        Boolean IsGMS1000 = false;
        Boolean IsGMS2000 = false;
        Boolean isNotGMS = false;
        //Loop through the Subscriptions and get the Contract Ids
        for(SBQQ__Subscription__c sub: SubscriptionList){
            
            System.debug('Subscription loop = ' + sub);
            
            ContractIds.add(sub.SBQQ__Contract__c);
            //OrderProdIds.add(sub.SBQQ__OrderProduct__c);
            QuoteLineIds.add(sub.SBQQ__QuoteLine__c);
            SubscriptionContract = sub.SBQQ__Contract__c;
            CurrentSubscription = sub.id;
            
            if(sub.SBQQ__ProductName__c.contains('GMS-25')){
                IsGMS25 = true;
            }
            //----- additional validation @ronald 
            else if(sub.SBQQ__ProductName__c.contains('GMS-50')){
                IsGMS50 = true;
            }
            else if(sub.SBQQ__ProductName__c.contains('GMS-100')){
                IsGMS100 = true;
            }
            else if(sub.SBQQ__ProductName__c.contains('GMS-200')){
                IsGMS200 = true;
            }
            else if(sub.SBQQ__ProductName__c.contains('GMS-500')){
                IsGMS500 = true;
            }
            else if(sub.SBQQ__ProductName__c.contains('GMS-1000')){
                IsGMS1000 = true;
            }
            else if(sub.SBQQ__ProductName__c.contains('GMS-2000')){
                IsGMS2000 = true;
            }
            else{
                isNotGMS = true;
            }
            
        }
        
        System.debug('IsGMS25 = ' + IsGMS25);
        System.debug('ContractIds = ' + ContractIds);
        System.debug('QuoteLineIds = ' + QuoteLineIds);
        System.debug('SubscriptionContract = ' + SubscriptionContract);
        System.debug('CurrentSubscription = ' + CurrentSubscription);
        
        if(!isNotGMS){
             //Loop through Quote Line to get Quote Ids
        for(SBQQ__QuoteLine__c ql: [SELECT Id, Name, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE Id =: QuoteLineIds]){
            QuoteIds.add(ql.SBQQ__Quote__c);
        }
        
        //Loop through Quote to get Opportunity
        for(SBQQ__Quote__c q: [SELECT Id, Name, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id =: QuoteIds]){
            OpportunityIds.add(q.SBQQ__Opportunity2__c);
        }
        
        System.debug('QuoteIds = ' + QuoteIds);
        
        /*
        //Loop through Order Product to get Order Ids
        for(OrderItem op: [SELECT Id, OrderId FROM OrderItem WHERE Id =: OrderProdIds]){
            OrderIds.add(op.OrderId);
        }
        
        //Loop through Contract and get Order Product 
        for(Contract con: [SELECT Id, SBQQ__Order__c,SBQQ__Order__r.OpportunityId, SBQQ__Order__r.Opportunity.SBQQ__AmendedContract__c FROM Contract WHERE Id =: ContractIds]){
            
            System.debug('Contract query = ' + con);
            OrderIds.add(con.SBQQ__Order__c);
        }
        
        
        System.debug('OrderIds = ' + OrderIds);
        
        //Loop through Order and get Opportunity
        for(Order ord : [SELECT Id, OpportunityId FROM Order WHERE Id =: OrderIds]){
            
            System.debug('Order query = ' + ord);
            OpportunityIds.add(ord.OpportunityId);
        }
        */
        
        System.debug('OpportunityIds = ' + OpportunityIds);
        
        //Loop through Opportunity and check if it has amended Contract and the Contract == Subscription's Contract
        for(Opportunity opp: [SELECT Id, Name, SBQQ__AmendedContract__c, SBQQ__AmendedContract__r.id FROM Opportunity WHERE Id =: OpportunityIds]){
            
            System.debug('Opportunity query = ' + opp);
            System.debug('Amended contract = ' + opp.SBQQ__AmendedContract__c);
            System.debug('Amended contract __r id = ' + opp.SBQQ__AmendedContract__r.id);
            
            if(opp.SBQQ__AmendedContract__c == SubscriptionContract){
                MatchedContract = true;
            }
        }
        
        System.debug('SubscriptionContract = ' + SubscriptionContract);
        //System.debug('ContractIds = ' + ContractIds);
        System.debug('MatchedContract = ' + MatchedContract);
        
        //If Contract matches with Amended from Opportunity, query subscriptions to get the Asset
        if(MatchedContract){
            
            //Query the second to the last Subscription
            for(SBQQ__Subscription__c s:  [SELECT Id, Name, SBQQ__Contract__c, CreatedDate  FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =: SubscriptionContract]){
                subsIds.add(s.Id);
            }
            
            System.debug('SectoLast value = ' + subsIds);
            
            //Query the Subscribed Asset to update
            //SBQQ__SubscribedAsset__c[] SubAsset = [SELECT Id, SBQQ__Subscription__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__c =: SectoLast.Id];
            
            //SBQQ__SubscribedAsset__c SubAssetUpdated = SubAsset[0];
            
            //System.debug('SubAssetUpdated value = ' + SubAssetUpdated);
            
            //Query the Asset from the Subscription
            Asset[] AssetToUpdate = [SELECT Id, Name, Product2.Name, SBQQ__Subscription__c FROM Asset WHERE SBCF_Subscription__c IN: subsIds AND  Product2.Name LIKE '%GMS-10%'];
            
            System.debug('AssetToUpdate value = ' + AssetToUpdate);
            
            Asset AssetUpdated = AssetToUpdate[0];
            //Query the Product Name
            //Product2 AssetProd = [SELECT Id, Name FROM Product2 WHERE Id =: AssetToUpdate.Product2Id];
            
            
            System.debug('AssetUpdated value = ' + AssetUpdated);
            for(Asset a: AssetToUpdate){
                if(IsGMS25){
                //Update the Asset GMS Node field
                    a.GMS_Nodes__c = '25';
                    a.SBCF_Subscription__c = CurrentSubscription;
                    updateAsset.add(a);
                //SubAssetUpdated.SBQQ__Subscription__c = CurrentSubscription;
                }
            // ----- additional validation @-- ronald
                else if(IsGMS50){
                    a.GMS_Nodes__c = '50';
                    a.SBCF_Subscription__c = CurrentSubscription;
                    updateAsset.add(a);
                }
                else if(IsGMS100){
                    a.GMS_Nodes__c = '100';
                    a.SBCF_Subscription__c = CurrentSubscription;
                    updateAsset.add(a);
                    
                }
                else if(IsGMS200){
                    a.GMS_Nodes__c = '200';
                    a.SBCF_Subscription__c = CurrentSubscription;
                    updateAsset.add(a);
                }
                else if(IsGMS500){
                    a.GMS_Nodes__c = '500';
                    a.SBCF_Subscription__c = CurrentSubscription;
                    updateAsset.add(a);
                    
                }
            }
            //Check if the Asset's Product Name is GMS-10
            
            
            
            System.debug('AssetToUpdate value = ' + AssetToUpdate);
            
            //update SubAssetUpdated;
            
            if(updateAsset.size()>0){
                update updateAsset;
            }
            
            // Continuation for subscribed Asset @@----- ronald
            for(Asset asset: updateAsset){
                SBQQ__SubscribedAsset__c subscribedAsset = new SBQQ__SubscribedAsset__c(SBQQ__Asset__c = asset.Id, SBQQ__Subscription__c = asset.SBCF_Subscription__c, SBQQ__Active__c = true);
                insert subscribedAsset;
            }
            
        }
       
        }
        
        
        
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
   
    
    private static Map<Id, List<SBQQ__Subscription__c>> buildQuoteLineIdsToSubscriptions(List<SBQQ__Subscription__c> incomingSubscriptions){
        Map<Id, List<SBQQ__Subscription__c>> quoteLineIdsToSubscriptions = new Map<Id, List<SBQQ__Subscription__c>>();
        
        for(SBQQ__Subscription__c subscription: incomingSubscriptions){
           System.debug('Subscription product name : ' + subscription.SBQQ__Product__c); 
           
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
    
   
    
    
    
}