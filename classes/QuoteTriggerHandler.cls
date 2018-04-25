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
        populateThePocIDinRelatedRecords(newItems.values());
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        populateRequestedEndDateToQuoteEndDate(newItems.values());
        //populateThePocIDinRelatedRecords(newItems.values());
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
    }
    
    public static void populateThePocIDinRelatedRecords(List<SBQQ__Quote__c> quotes){
        System.debug('After Insert of Quote');
        //List<SBQQ__QuoteLine__c> updateQuoteLinePocId = new List<SBQQ__QuoteLine__c>();
        
        //List<Contract> updateContractPocId = new List<Contract>();
        //List<SBQQ__Subscription__c> updateSubscriptionPocId = new List<SBQQ__Subscription__c>();
        //List<Asset> updateAssetPocId = new List<Asset>();
        
        List<SBQQ__Quote__c> evaluationIsTrueQuotes = new List<SBQQ__Quote__c>();
        Set<Id> evaluationQuoteIsTrueIds = new Set<Id>();
        
        // --- on the parameter of this method, get the integer value of quote name and update
        // --- get also the IDs for child query reference
        for(SBQQ__Quote__c quote: quotes){
           // System.debug('SBCF Evaluation Quote ' + quote.SBCF_Evaluation_Quote__c);
           // if(quote.SBCF_Evaluation_Quote__c){
               //  quote.POC_ID__c = integer.valueOf(quote.Name);
               //  evaluationIsTrueQuotes.add(quote);
                 evaluationQuoteIsTrueIds.add(quote.Id);
            // System.debug('Evaluation Quote : ' + evaluationQuoteIsTrueIds);   
           // }  
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
        //if(evaluationIsTrueQuotes.size()>0){
        //    update evaluationIsTrueQuotes;
        //}
        /*
        //--- get the child records quoteline of quote and update the POC ID field
        for(SBQQ__QuoteLine__c ql: [SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.POC_ID__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: evaluationQuoteIsTrueIds]){
            ql.POC_ID__c = integer.valueOf(ql.SBQQ__Quote__r.POC_ID__c);
            updateQuoteLinePocId.add(ql);
        }
        
        //---- get the child records contracts, subscriptions, and assets update its POC Number. 
        for(SBQQ__SubscribedAsset__c allChildRecordsId: [SELECT Id, SBQQ__Subscription__c, SBQQ__Asset__c, SBQQ__Subscription__r.SBQQ__Contract__c, SBQQ__Subscription__r.SBQQ__Contract__r.SBQQ__Quote__c 
                                                                        FROM SBQQ__SubscribedAsset__c 
                                                                      WHERE SBQQ__Subscription__r.SBQQ__Contract__r.SBQQ__Quote__c IN: evaluationQuoteIsTrueIds]){
                                                                          
           	updateContractPocId.add(new Contract(Id = allChildRecordsId.SBQQ__Subscription__r.SBQQ__Contract__c, POC_ID__c = integer.valueOf(allChildRecordsId.SBQQ__Subscription__r.SBQQ__Contract__r.SBQQ__Quote__r.POC_ID__c)));
            updateSubscriptionPocId.add(new SBQQ__Subscription__c(Id = allChildRecordsId.SBQQ__Subscription__c, POC_ID__c = integer.valueOf(allChildRecordsId.SBQQ__Subscription__r.SBQQ__Contract__r.SBQQ__Quote__r.POC_ID__c)));
            updateAssetPocId.add(new Asset(Id = allChildRecordsId.SBQQ__Asset__c, POC_ID__c = integer.valueOf(allChildRecordsId.SBQQ__Subscription__r.SBQQ__Contract__r.SBQQ__Quote__r.POC_ID__c)));
        }
        
        if(updateQuoteLinePocId.size()>0){
            update updateQuoteLinePocId;
        }
        
        if(updateContractPocId.size()>0){
            update updateContractPocId;
        }
        
        if(updateSubscriptionPocId.size()>0){
            update updateSubscriptionPocId;
        }
        
        if(updateAssetPocId.size()>0){
            update updateAssetPocId;
        }
        */
    }
    
    public static void populateRequestedEndDateToQuoteEndDate(List<SBQQ__Quote__c> quotes){
        /*
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote: quotes){
            
            if(quote.ApprovalStatus__c == 'Approved'){
                 quote.SBQQ__EndDate__c = quote.Requested_Extension_Date__c;
                 quotesToUpdate.add(quote);
            }
        }
        
        if(quotesToUpdate.size()>0){
            update quotesToUpdate;
        }
        */
        
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
                                          
              if(quoteRec.ApprovalStatus__c == 'Approved'){
                 quoteRec.SBQQ__EndDate__c = quoteRec.Requested_Extension_Date__c;
                 quotesToUpdate.add(quoteRec);
               }
                       
        }
        if(quotesToUpdate.size()>0){
            update quotesToUpdate;
        }
        
        
       
    }
}