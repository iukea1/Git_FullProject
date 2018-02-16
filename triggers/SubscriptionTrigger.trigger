/*********************************************************************
*  Created By: drew.justus@simplus.com
*  Created Date: 2.15.2018
*  Description: Trigger on subscription to populate related asset lookup
*  field with related subscription.
**********************************************************************/
trigger SubscriptionTrigger on SBQQ__Subscription__c (after insert) {

	if(Trigger.isAfter){
		if(Trigger.isInsert){
			SubscriptionTriggerHandler.populateRelatedAssetSubscriptionLookups(Trigger.new);
		}
	}
}