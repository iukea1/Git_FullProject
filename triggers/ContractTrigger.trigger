trigger ContractTrigger on Contract (before insert, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.Run(new ContractTriggerHandler());
}