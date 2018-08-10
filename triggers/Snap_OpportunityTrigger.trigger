/**
 * A trigger dispatcher, catches all the events for Opportunity.
 *
 * @author: SnapBI
 *
 * @changelog
 * 08/06/2018 Jason Zhao - Created.
 * 08/06/2018 Jason Zhao - Add before update, after insert and after update.
 */
trigger Snap_OpportunityTrigger on Opportunity (before insert, after insert, before update, after update)
{
    new Snap_OpportunityTriggerHandler().run();   
}