public without sharing class ContractTriggerHandler implements ITriggerHandler{
        public ContractTriggerHandler(){
            
        }
        public Boolean IsDisabled(){
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
            populateQuoteNumberToPOCIdInContract(newItems.values());
        }
        public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
        {
        }
        public void AfterDelete(Map<Id, SObject> oldItems) 
        {
        }
        public void AfterUndelete(Map<Id, SObject> newItems) 
        {
        }
        
        public static void populateQuoteNumberToPOCIdInContract(List<Contract> contracts){
            Set<Id> contractIds = new Set<Id>();
            List<Contract> contractWithPocID = new List<Contract>();
            
            for(Contract cont: contracts){
                contractIds.add(cont.id);
            }
            
            List<Contract> contractsToUpdate = [SELECT Id, Name, SBQQ__Quote__c, SBQQ__Quote__r.POC_ID__c FROM Contract WHERE Id IN: contractIds];
            
            for(Contract c: contractsToUpdate){
                if(c.SBQQ__Quote__r.POC_ID__c != null){
                    c.POC_ID__c = c.SBQQ__Quote__r.POC_ID__c;
                    contractWithPocID.add(c);
                }
            }
            
            if(contractWithPocID.size()>0){
                update contractWithPocID;
            }
        }
        
        public static void createRMAEval(List<Contract> incomingContract){
            
            List<Contract> expiredContract = new List<Contract>();
            Set<id> contractIds = new Set<Id>();
            
            for(Contract contract: incomingContract){
                contractIds.add(contract.Id);
            }
            
            //List<Contract> contractExpired = [SELECT Id, Status FROM Contract WHERE Id IN: contractIds];
            for(Contract c: [SELECT Id, Status FROM Contract WHERE Id IN: contractIds]){
                if(c.Status == 'Expired'){
                    
                }
            }
            
        }
        
    }