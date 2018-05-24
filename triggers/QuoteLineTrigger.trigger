trigger QuoteLineTrigger on Quote_Line__c (before insert, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new QuotelineTriggerHandler());
}