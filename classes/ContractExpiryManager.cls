global class ContractExpiryManager implements Database.Batchable<sObject> {


    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Contract WHERE EndDate >= LAST_N_DAYS:7 AND SBQQ__Opportunity__r.POC_Opportunity__c = true';
        //TODO: refine query to get only for a specific time 
        
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Contract> scope) {
        List<SBQQ__Subscription__c> subsToDelete = [SELECT Id FROM SBQQ__Subscription__c WHERE Id IN (SELECT SBQQ__Subscription__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Asset__r.Product2.Forecast_Category__c != 'Physical' AND SBQQ__Subscription__r.SBQQ__Contract__c IN :scope)];
        delete subsToDelete;
        
        List<Contract> contractDeletion = [SELECT Id, (SELECT Id FROM SBQQ__Subscriptions__r) subCount FROM Contract WHERE Id IN :scope];
        List<Contract> delContract = new List<Contract>();
        for(Contract c : contractDeletion) {
            if(c.SBQQ__Subscriptions__r.isEmpty()) delContract.add(c);
        }
        delete delContract;
    }
    
    global void finish(Database.BatchableContext BC) {
        ContractExpiryManagerSched m = new ContractExpiryManagerSched();
        String sch = '0 0 23 ? * 6';
        String jobID = system.schedule('ContractExpiryManager', sch, m);
    }
}