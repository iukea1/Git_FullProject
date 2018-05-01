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
       
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        populateThePocIDinRelatedRecords(newItems.values());
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        if(CheckRecursive.runOnce()){
           populateRequestedEndDateToQuoteEndDate(newItems.values()); 
        }  
      
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
    }
    
    public static void populateThePocIDinRelatedRecords(List<SBQQ__Quote__c> quotes){
        System.debug('After Insert of Quote');
       
        
        List<SBQQ__Quote__c> evaluationIsTrueQuotes = new List<SBQQ__Quote__c>();
        Set<Id> evaluationQuoteIsTrueIds = new Set<Id>();
        
        
        for(SBQQ__Quote__c quote: quotes){
        	evaluationQuoteIsTrueIds.add(quote.Id);
        }
        
        List<SBQQ__Quote__c> evaluationQuoteIsTrue = [SELECT Id, SBCF_Evaluation_Quote__c, Name FROM SBQQ__Quote__c WHERE Id IN: evaluationQuoteIsTrueIds];
        for(SBQQ__Quote__c q: evaluationQuoteIsTrue){
            System.debug('q.SBCF_Evaluation_Quote__c : ' + q.SBCF_Evaluation_Quote__c);
            if(q.SBCF_Evaluation_Quote__c){
                
                String formattedStr = q.Name;
                
                String[] strArr = formattedStr.split('-');
                String strNumber = '';
                
                if(strArr.size() >1){
                    strNumber = strArr[1];
                    q.POC_ID__c = Integer.valueOf(strNumber);
                    System.debug('q.POC ID' + Integer.valueOf(strNumber));
                    evaluationIsTrueQuotes.add(q);
                }
            }
        }
		
        if(evaluationIsTrueQuotes.size()>0){
            System.debug('evaluationIsTrueQuotes  : ' + evaluationIsTrueQuotes);
            update evaluationIsTrueQuotes;
        }        
        
    }
    
    public static void populateRequestedEndDateToQuoteEndDate(List<SBQQ__Quote__c> quotes){ 
        
        system.debug('before update quotes: ' + quotes);
        Set<Id> quotesIds = new Set<Id>();
        
        for(SBQQ__Quote__c quote: quotes){
            System.debug('quote 1-------@@ ' + quote);
                quotesIds.add(quote.Id);        
        }
        
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        
        for(SBQQ__Quote__c quoteRec: [SELECT Id, Name, ApprovalStatus__c, Justification__c, SBQQ__StartDate__c, Requested_Extension_Date__c, SBQQ__EndDate__c 
                                      FROM SBQQ__Quote__c 
                                      WHERE Id IN: quotesIds]){
                                          
              if(quoteRec.ApprovalStatus__c == 'Approved'){
                  if(quoteRec.Requested_Extension_Date__c != null && quoteRec.SBQQ__StartDate__c != null){
                      if(quoteRec.Requested_Extension_Date__c >= quoteRec.SBQQ__StartDate__c){
                      	  quoteRec.SBQQ__EndDate__c = quoteRec.Requested_Extension_Date__c;
                          quotesToUpdate.add(quoteRec);
                  	  }
                      
                          
                      
                  }
              }
                       
        }
        
        try{
            if(quotesToUpdate.size()>0){
                update quotesToUpdate;
            } 
        }
        catch(Exception e){
            
        }
        
        
        
       
    }
}