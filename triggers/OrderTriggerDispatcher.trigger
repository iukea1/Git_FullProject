trigger OrderTriggerDispatcher on Order (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!SilverPeakUtils.BypassingTriggers)
    {
        //TriggerHandler handler = new ContactTriggerHandlerForSDC();
        //handler.execute();
        if(system.isFuture()) return;
        
        TriggerDispatcher.Run(new OrderTriggerHandler());
    }
}