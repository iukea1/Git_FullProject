/*********************************************************************
*  Created By: drew.justus@simplus.com
*  Created Date: 2.15.2018
*  Description: Trigger on subscription to populate related asset lookup
*  field with related subscription.
**********************************************************************/
public without sharing class SubscriptionTriggerHandler {

	public static final String PRODUCT_NAME_PREFIX_SMART_HANDS = 'SMRT-HND';
	
	public static void populateRelatedAssetSubscriptionLookups(List<SBQQ__Subscription__c> incomingSubscriptions){
		// Used in action method
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

		Map<Id, Set<Id>> subscriptionQuoteLineIdToRequiredByQuoteLineIds = buildSubscriptionQuoteLineIdToRequiredByQuoteLineIds(subscriptionQuoteLineMap.values());

		if(subscriptionQuoteLineIdToRequiredByQuoteLineIds.size() == 0){
			System.debug('No subscription quote lines with required by quote line populated.');
		}

		Set<Id> requiredByQuoteLineIds = getRequiredByQuoteLineIds(subscriptionQuoteLineIdToRequiredByQuoteLineIds.values());
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
					if(String.isEmpty(relatedSubscription.SBQQ__ProductName__c)){
						// this should never be the case but precondition checking
						System.debug('Product Name on subscription is empty.');
						continue;
					}
					if(relatedSubscription.SBQQ__ProductName__c.Contains(PRODUCT_NAME_PREFIX_SMART_HANDS)){
						smartHandsSubscription = relatedSubscription;
					}
					else{
						subscription = smartHandsSubscription;
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
			assetsRelatedToSubscriptions = [SELECT Id, SBQQ__QuoteLine__c, SBQQ__Subscription__c, Smart_Hands_Subscription__c FROM Asset WHERE SBQQ__QuoteLine__c IN :requiredBySubscriptionQuoteLineIds];
		}
		catch(QueryException qe){
			System.debug(qe.getMessage());
		}

		System.debug('Assets related to Subscriptions: ' + assetsRelatedToSubscriptions);

		return assetsRelatedToSubscriptions;
	} 

	private static Set<Id> getRequiredByQuoteLineIds(List<Set<Id>> requiredByQuoteLineIds){
		Set<Id> requiredByQuoteLineIdsFullList = new Set<Id>();

		for(Set<Id> quoteLineIdsRequiredBySubQuoteLine: requiredByQuoteLineIds){
			requiredByQuoteLineIdsFullList.addAll(quoteLineIdsRequiredBySubQuoteLine);
		}

		System.debug('Required By Quote Line Ids Full List: ' + requiredByQuoteLineIdsFullList);
		return requiredByQuoteLineIdsFullList;
	}

	private static Map<Id, Set<Id>> buildSubscriptionQuoteLineIdToRequiredByQuoteLineIds(List<SBQQ__QuoteLine__c> subscriptionQuoteLines){
		Map<Id, Set<Id>> subscriptionQuoteLineIdToRequiredByQuoteLineIds = new Map<Id, Set<Id>>();

		for(SBQQ__QuoteLine__c subscriptionQuoteLine: subscriptionQuoteLines){
			if(subscriptionQuoteLine.SBQQ__RequiredBy__c == null){
				continue;
			}

			Set<Id> requiredByQuoteLineIds = subscriptionQuoteLineIdToRequiredByQuoteLineIds.get(subscriptionQuoteLine.SBQQ__RequiredBy__c);

			if(requiredByQuoteLineIds == null){
				requiredByQuoteLineIds = new Set<Id>();
				subscriptionQuoteLineIdToRequiredByQuoteLineIds.put(subscriptionQuoteLine.SBQQ__RequiredBy__c, requiredByQuoteLineIds);
			}

			requiredByQuoteLineIds.add(subscriptionQuoteLine.SBQQ__RequiredBy__c);
		}

		System.debug('Subscription Quote Line Id To Required By Quote Line Ids: ' + subscriptionQuoteLineIdToRequiredByQuoteLineIds);
		return subscriptionQuoteLineIdToRequiredByQuoteLineIds;
	}

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

}