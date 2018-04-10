trigger QuoteTrigger on SBQQ__Quote__c (before insert, before delete, after insert, after update, after delete, after undelete) {
    if(CheckRecursive.runOnce()){
        TriggerDispatcher.Run(new QuoteTriggerHandler());
    }
    
}