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
        //queryRenewalSubscription(newItems.values());
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
    }
    
    
    //public static void queryRenewalSubscription(List<SBQQ__Subscription__c> subscription){
       // for(SBQQ__Subscription__c subs: subscription){
        //    if(!String.isEmpty(subs.SBQQ__ProductName__c) && subs.SBQQ__ProductName__c.Contains(PRODUCT_NAME_PREFIX_RENEWAL)){
                
              //     System.debug('Incoming Subscription contract in after update: ' + subs.SBQQ__Contract__c);
              //     System.debug('Incoming Subscription order in after update: ' + subs.SBQQ__Contract__r.SBQQ__Order__r);
              //     System.debug('Incoming Subscription opportunity in after update: ' + subs.SBQQ__Contract__r.SBQQ__Order__r.OpportunityId);
              //     System.debug('Incoming Subscription Renewed Contract in after update: ' + subs.SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c);    
              //     System.debug('@@@@----------- renewed subscription in after update : ' + subs.SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c);
                
          //  }
       // }       
    // }
  
    public static void populateRelatedAssetSubscriptionLookups(List<SBQQ__Subscription__c> incomingSubscriptions){
        
        // Used in action method
        List<SBQQ__SubscribedAsset__c> subscriptionAndAssetList = new List<SBQQ__SubscribedAsset__c>();
        List<SBQQ__Subscription__c> newlyGeneratedSubscription = new List<SBQQ__Subscription__c>();
        Set<id> renewalSubscriptions = new Set<id>();
   
        //Start of the process for renewal
        for(SBQQ__Subscription__c subs: incomingSubscriptions){
            if(!String.isEmpty(subs.SBQQ__ProductName__c) && 
               subs.SBQQ__ProductName__c.Contains(PRODUCT_NAME_PREFIX_RENEWAL)){
               System.debug('@@----------- renewed subscription in after insert : ' + subs.SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c);
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
            
            // This is the process to populate the related asset to Subscription detail page. 
            for(Asset assetRec: assetsToUpdate){
                //SBQQ__SubscribedAsset__c subscriptionAndAsset = new SBQQ__SubscribedAsset__c();
                //subscriptionAndAsset.SBQQ__Subscription__c = assetRec.SBCF_Subscription__c; 
                //subscriptionAndAsset.SBQQ__Asset__c = assetRec.Id;
                //subscriptionAndAsset.SBQQ__Active__c = true;
                //subscriptionAndAssetList.add(subscriptionAndAsset);
                subscriptionAndAssetList.add(new SBQQ__SubscribedAsset__c(SBQQ__Subscription__c = assetRec.SBCF_Subscription__c, SBQQ__Asset__c = assetRec.Id, SBQQ__Active__c = true));
                //listCS.add(new CS__c(Opportunity__c = o.id));
            }
            
                if(subscriptionAndAssetList.size()>0){
                    insert subscriptionAndAssetList;
                }
            }
        
        else{
            if(renewalSubscriptions.size()>0){
                
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
        Id SubscriptionContract;
        Boolean MatchedContract = false;
        Id toGetAsset;
        Id CurrentSubscription;
        Boolean IsGMS25 = false;
        
        //Loop through the Subscriptions and get the Contract Ids
        for(SBQQ__Subscription__c sub: SubscriptionList){
            ContractIds.add(sub.SBQQ__Contract__c);
            SubscriptionContract = sub.SBQQ__Contract__c;
            CurrentSubscription = sub.id;
            
            if(sub.SBQQ__ProductName__c.contains('GMS-25')){
                IsGMS25 = true;
            }
        }
        
        System.debug('IsGMS25 = ' + IsGMS25);
        System.debug('ContractIds = ' + ContractIds);
        
        //Loop through Contract and get Order Product 
        for(Contract con: [SELECT Id, SBQQ__Order__c FROM Contract WHERE Id =: ContractIds]){
            OrderIds.add(con.SBQQ__Order__c);
        }
        
        System.debug('OrderIds = ' + OrderIds);
        
        //Loop through Order and get Opportunity
        for(Order ord : [SELECT Id, OpportunityId FROM Order WHERE Id =: OrderIds]){
            OpportunityIds.add(ord.OpportunityId);
        }
        
        System.debug('OpportunityIds = ' + OpportunityIds);
        
        //Loop through Opportunity and check if it has amended Contract and the Contract == Subscription's Contract
        for(Opportunity opp: [SELECT Id, Name, SBQQ__AmendedContract__c, SBQQ__AmendedContract__r.id FROM Opportunity WHERE Id =: OpportunityIds]){
            
            System.debug('Opportunity query = ' + opp);
            System.debug('Amended contract = ' + opp.SBQQ__AmendedContract__c);
            
            if(opp.SBQQ__AmendedContract__r.id == SubscriptionContract){
                MatchedContract = true;
            }
        }
        
        System.debug('SubscriptionContract = ' + SubscriptionContract);
        //System.debug('ContractIds = ' + ContractIds);
        System.debug('MatchedContract = ' + MatchedContract);
        
        //If Contract matches with Amended from Opportunity, query subscriptions to get the Asset
        if(MatchedContract){
            
            //Query the second to the last Subscription
            SBQQ__Subscription__c SectoLast = [SELECT Id, Name, SBQQ__Contract__c, CreatedDate  FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =: SubscriptionContract ORDER BY CreatedDate DESC LIMIT 1][1];
            
            //Query the Asset from the Subscription
            Asset AssetToUpdate = [SELECT Id, Name, Product2.Name, SBQQ__Subscription__c FROM Asset WHERE SBQQ__Subscription__c =: SectoLast.Id];
            
            //Query the Product Name
            //Product2 AssetProd = [SELECT Id, Name FROM Product2 WHERE Id =: AssetToUpdate.Product2Id];
            
            System.debug('SectoLast value = ' + SectoLast);
            System.debug('AssetToUpdate value = ' + AssetToUpdate);
            
            //Check if the Asset's Product Name is GMS-10
            if(IsGMS25){
                
                //Update the Asset GMS Node field
                AssetToUpdate.GMS_Nodes__c = '25';
                AssetToUpdate.SBQQ__Subscription__c = CurrentSubscription;
            }
            
            System.debug('AssetToUpdate value = ' + AssetToUpdate);
            
            update AssetToUpdate;
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
    
    //------- populate asset in subscription detail page ------- //
    /*
    @InvocableMethod
    public static void updateTheSelectedAsset(List<Id> renewalSubs){
        
        List<SBQQ__SubscribedAsset__c> subscribedAssetRenewal = new List<SBQQ__SubscribedAsset__c>();
        Set<Id> renewedOrder = new Set<Id>();
        Set<Id> contractRenewalIds = new Set<Id>();
        Set<Id>  orderRenewalIds = new Set<Id>();
        List<Asset> newAssetToUpdate = new List<Asset>();
        Set<id> renewedContractForSubscription = new Set<id>();
        Set<Id> assetsRenewed = new Set<Id>();
        Map<Id, Set<Id>> renewedSubscriptionToRenewedOpportunity = new Map<Id, Set<Id>>();
        
        List<SBQQ__Subscription__c> renewedSubscriptions = [SELECT Id, SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c
                                                                    FROM SBQQ__Subscription__c 
                                                                    WHERE Id IN : renewalSubs];
                
                System.debug('Incoming Subscription : ' + renewedSubscriptions);
                
                
                for(SBQQ__Subscription__c renewedSubscription: renewedSubscriptions){
                    renewedContractForSubscription.add(renewedSubscription.SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c);
                    System.debug('Incoming Subscription : ' + renewedSubscription.SBQQ__Contract__c);
                    System.debug('Incoming Subscription : ' + renewedSubscription.SBQQ__Contract__r.SBQQ__Order__r);
                    System.debug('Incoming Subscription : ' + renewedSubscription.SBQQ__Contract__r.SBQQ__Order__r.OpportunityId);
                    System.debug('Incoming Subscription : ' + renewedSubscription.SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c);
                    renewedSubscriptionToRenewedOpportunity.put(renewedSubscription.Id, renewedContractForSubscription);        
                }
                List<SBQQ__SubscribedAsset__c> renewedAssets = [SELECT Id, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Asset__c, SBQQ__Subscription__r.SBQQ__Contract__c 
                                                                FROM SBQQ__SubscribedAsset__c 
                                                                WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN: renewedContractForSubscription
                                                                AND SBQQ__Asset__r.Is_Selected_For_Renewal__c = TRUE];
                
                System.debug('Subscribed Asset to be selected for Renewal : ' + renewedAssets);
                
                for(SBQQ__SubscribedAsset__c assetIds: renewedAssets){
                    assetsRenewed.add(assetIds.SBQQ__Asset__c);
                }
                
                List<Asset> assetToBeCreateInSubscribeAsset = [SELECT Id, Is_Selected_For_Renewal__c FROM Asset WHERE Id IN: assetsRenewed];
                System.debug('Asset that has been selected for renewal : ' + assetToBeCreateInSubscribeAsset);
                
                for(SBQQ__Subscription__c sub: renewedSubscriptions){
                    for(Asset assetToBeRenewed: assetToBeCreateInSubscribeAsset){
                        assetToBeRenewed.SBCF_Subscription__c = sub.Id;
                        newAssetToUpdate.add(assetToBeRenewed);
                    }
                }
                System.debug('Update the subscription field in Asset ' + newAssetToUpdate);
                
                
                if(newAssetToUpdate.size()>0){
                    update newAssetToUpdate;
                }
                
                for(Asset assetForSubscribedAsset: newAssetToUpdate){
                    SBQQ__SubscribedAsset__c newSubscribedAsset = new SBQQ__SubscribedAsset__c();
                    newSubscribedAsset.SBQQ__Asset__c = assetForSubscribedAsset.Id;
                    newSubscribedAsset.SBQQ__Subscription__c = assetForSubscribedAsset.SBCF_Subscription__c;
                    subscribedAssetRenewal.add(newSubscribedAsset);
                }
                System.debug('Subscribed Asset that will be created ' + subscribedAssetRenewal);
                
                if(subscribedAssetRenewal.size()>0){
                    insert subscribedAssetRenewal;
                }
    } */
    /*
    @future
    public static void createSubscribedAssetForRenewal(Set<id> subsId){
        Set<Id> assetsRenewed = new Set<Id>();
        Set<Id> renewedContractForSubscription = new Set<Id>();
        List<Asset> newAssetToUpdate = new List<Asset>();
        List<SBQQ__SubscribedAsset__c> subscribedAssetRenewal = new List<SBQQ__SubscribedAsset__c>();
        
        List<SBQQ__Subscription__c> renewedSubscriptions = [SELECT Id, SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c
                                                            FROM SBQQ__Subscription__c 
                                                            WHERE Id IN : subsId];
                
        System.debug('Incoming Subscription : ' + renewedSubscriptions);
        
        
        for(SBQQ__Subscription__c renewedSubscription: renewedSubscriptions){
            renewedContractForSubscription.add(renewedSubscription.SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c);
            System.debug('Incoming Subscription : ' + renewedSubscription.SBQQ__Contract__c);
            System.debug('Incoming Subscription : ' + renewedSubscription.SBQQ__Contract__r.SBQQ__Order__r);
            System.debug('Incoming Subscription : ' + renewedSubscription.SBQQ__Contract__r.SBQQ__Order__r.OpportunityId);
            System.debug('Incoming Subscription : ' + renewedSubscription.SBQQ__Contract__r.SBQQ__Order__r.Opportunity.SBQQ__RenewedContract__c);
        }
                
                
        
        List<SBQQ__SubscribedAsset__c> renewedAssets = [SELECT Id, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Asset__c, SBQQ__Subscription__r.SBQQ__Contract__c 
                                                        FROM SBQQ__SubscribedAsset__c 
                                                        WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN: renewedContractForSubscription
                                                        AND SBQQ__Asset__r.Is_Selected_For_Renewal__c = TRUE];
        
        System.debug('Subscribed Asset to be selected for Renewal : ' + renewedAssets);
        
        for(SBQQ__SubscribedAsset__c assetIds: renewedAssets){
            assetsRenewed.add(assetIds.SBQQ__Asset__c);
        }
        
        List<Asset> assetToBeCreateInSubscribeAsset = [SELECT Id, Is_Selected_For_Renewal__c FROM Asset WHERE Id IN: assetsRenewed];
        System.debug('Asset that has been selected for renewal : ' + assetToBeCreateInSubscribeAsset);
        
        
        
        for(SBQQ__Subscription__c sub: renewedSubscriptions){
            for(Asset assetToBeRenewed: assetToBeCreateInSubscribeAsset){
                assetToBeRenewed.SBCF_Subscription__c = sub.Id;
                newAssetToUpdate.add(assetToBeRenewed);
            }
        }
        System.debug('Update the subscription field in Asset ' + newAssetToUpdate);
        
        
        if(newAssetToUpdate.size()>0){
            update newAssetToUpdate;
        }
        
        for(Asset assetForSubscribedAsset: newAssetToUpdate){
            SBQQ__SubscribedAsset__c newSubscribedAsset = new SBQQ__SubscribedAsset__c();
            newSubscribedAsset.SBQQ__Asset__c = assetForSubscribedAsset.Id;
            newSubscribedAsset.SBQQ__Subscription__c = assetForSubscribedAsset.SBCF_Subscription__c;
            subscribedAssetRenewal.add(newSubscribedAsset);
        }
        System.debug('Subscribed Asset that will be created ' + subscribedAssetRenewal);
        
        if(subscribedAssetRenewal.size()>0){
            insert subscribedAssetRenewal;
        }
        
    }*/
    
    
    
}