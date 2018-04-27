trigger ContractTrigger on Contract (before insert, before delete, after insert, after update, after delete, after undelete) {
	
   if(CheckRecursive.runOnce()){
       TriggerDispatcher.Run(new ContractTriggerHandler());
   }

}