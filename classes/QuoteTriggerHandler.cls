public without sharing class QuoteTriggerHandler implements ITriggerHandler{

    
    public QuoteTriggerHandler(){
        
    }
    public Boolean IsDisabled(){
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        //populateEndDate(newItems.values());
    	//populateRequestedEndDateToQuoteEndDate(newItems.values());
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        populateRequestedEndDateToQuoteEndDate(newItems.values());
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
    }
    /*
    public static void populateEndDate(List<SBQQ__Quote__c> incomingQuotes){
        Set<id> quoteSetId = new Set<id>();
        List<SBQQ__Quote__c> quotesToUpdate = populateRequestedEndDateToQuoteEndDate(incomingQuotes);
        for(SBQQ__Quote__c quoteId: quotesToUpdate){
            quoteSetId.add(quoteId.Id);
        }
        
        List<SBQQ__Quote__c> finalQuoteToUpdate = [SELECT Id FROM SBQQ__Quote__c WHERE Id IN: quoteSetId];
        if(finalQuoteToUpdate.size()>0){
            update finalQuoteToUpdate;
        }  
        
    }
    */
    public static void populateRequestedEndDateToQuoteEndDate(List<SBQQ__Quote__c> quotes){
        system.debug('before update quotes: ' + quotes);
        Set<Id> quotesIds = new Set<Id>();
        
        for(SBQQ__Quote__c quote: quotes){
            System.debug('quote 1-------@@ ' + quote);
                quotesIds.add(quote.Id);        
        }
        
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        
        for(SBQQ__Quote__c quoteRec: [SELECT Id, Name, ApprovalStatus__c, Justification__c, Requested_Extension_Date__c, SBQQ__EndDate__c 
                                      FROM SBQQ__Quote__c 
                                      WHERE Id IN: quotesIds]){
                                          system.debug('Approval Status: ' + quoteRec.ApprovalStatus__c);
                                          if(quoteRec.ApprovalStatus__c == 'Approved'){
                                              system.debug('This is Approved');
                                              system.debug('end date:' + quoteRec.SBQQ__EndDate__c);
                                              system.debug('extension date: ' + quoteRec.Requested_Extension_Date__c);
                                              quoteRec.SBQQ__EndDate__c = quoteRec.Requested_Extension_Date__c;
                                              quotesToUpdate.add(quoteRec);
                                          }
                       
        }
        if(quotesToUpdate.size()>0){
            update quotesToUpdate;
        }
        
        
        
    }
}