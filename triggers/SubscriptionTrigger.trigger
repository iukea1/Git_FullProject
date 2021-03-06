/*********************************************************************
*  Created By: drew.justus@simplus.com
*  Created Date: 2.15.2018
*  Description: Trigger on subscription to populate related asset lookup
*  field with related subscription. Locates related asset through required
*  by field on subscription quote lines. 
*
*  @Test - SubscriptionTriggerTest - 100%
*
*  ** Trigger will need to be modifed to meet updated requirement once they
*     are fully defined.
*
**********************************************************************/
trigger SubscriptionTrigger on SBQQ__Subscription__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
        TriggerDispatcher.Run(new SubscriptionTriggerHandler());
}