public without sharing class QuoteTriggerHandler implements ITriggerHandler{
    
    public static final String EvalRmaRecordTypeId = '012500000005H0o';
    public static final String EvalRMAItemRecordTypeId = '012500000005H0y';
    Id rmaRecordTypeId = Schema.SObjectType.RMA__c.getRecordTypeInfosByName().get('Eval RMA').getRecordTypeId();
    Id itemRecordTypeId = Schema.SObjectType.RMA_Item__c.getRecordTypeInfosByName().get('Eval Return').getRecordTypeId();
    
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
       runShippedExtendedLogic((Map<Id, SBQQ__Quote__c>)oldItems, (List<SBQQ__Quote__c>)newItems.values());
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
       pocDataDeletion((Map<Id, SBQQ__Quote__c>)oldItems, (List<SBQQ__Quote__c>)newItems.values());
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
    }
    
    
    public static void pocDataDeletion(Map<Id, SBQQ__Quote__c> oldItems, List<SBQQ__Quote__c> quotes) {
        //run for evaluation quotes only
        Set<String> statusSet = new Set<String>();
        statusSet.add('Closed - Won');
        statusSet.add('Closed - Denied');
        statusSet.add('Closed - Returned');    
        Set<Id> quoteIdCollect = new Set<Id>();
        for(SBQQ__Quote__c qRec : quotes) {
            if(qRec.SBCF_Evaluation_Quote__c && statusSet.contains(qRec.POC_Status__c) && !statusSet.contains(oldItems.get(qRec.Id).POC_Status__c)) {
                quoteIdCollect.add(qRec.Id);
            }
        }

        if(!quoteIdCollect.isEmpty()) {
            delete [SELECT Id FROM Contract WHERE SBQQ__Quote__c IN :quoteIdCollect];
            List<SBQQ__Subscription__c> delSubs = [SELECT Id FROM SBQQ__Subscription__c WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c IN :quoteIdCollect];
            delete [SELECT Id FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__c IN :delSubs];
            delete delSUbs;
            delete [SELECT Id FROM Asset WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c IN :quoteIdCollect AND Product2.Forecast_Category__c != 'Physical'];
        }

    }
    
    public static void runShippedExtendedLogic(Map<Id, SBQQ__Quote__c> oldItems, List<SBQQ__Quote__c> quotes) {
        Set<Id> opsList = new Set<Id>();
        for(SBQQ__Quote__c qRec : quotes) {
            opsList.add(qRec.SBQQ__Opportunity2__c);
        }
        Map<Id, Opportunity> opsMap = new Map<Id, Opportunity>([SELECT Id, ContractId, SBQQ__AmendedContract__c, SBQQ__RenewedContract__c, (SELECT Id FROM Contracts__r) FROM Opportunity WHERE Id IN :opsList]);



        List<Contract> contUpdate = new List<Contract>();
        for(SBQQ__Quote__c qRec : quotes) {
            if(qRec.POC_Status__c == 'Shipped - Extended' && oldItems.get(qRec.Id).POC_Status__c != 'Shipped - Extended') {
                qRec.SBQQ__EndDate__c = qRec.Requested_Extension_Date__c;
                if(opsMap.containsKey(qRec.SBQQ__Opportunity2__c) && opsMap.get(qRec.SBQQ__Opportunity2__c).ContractId != null) {
                    contUpdate.add(
                        new Contract(
                            Id = opsMap.get(qRec.SBQQ__Opportunity2__c).ContractId,
                            EndDate = qRec.Requested_Extension_Date__c
                        )
                    );
                }
            }
        }
        update contUpdate;
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
        
        for(SBQQ__Quote__c quoteRec: [SELECT Id, Name, SBQQ__ExpirationDate__c, ApprovalStatus__c, Justification__c, SBQQ__StartDate__c, Requested_Extension_Date__c, SBQQ__EndDate__c 
                                      FROM SBQQ__Quote__c 
                                      WHERE Id IN: quotesIds]){
                                          
              if(quoteRec.ApprovalStatus__c == 'Approved'){
                  if(quoteRec.Requested_Extension_Date__c != null && quoteRec.SBQQ__StartDate__c != null){
                      if(quoteRec.Requested_Extension_Date__c >= quoteRec.SBQQ__StartDate__c){
                          quoteRec.SBQQ__EndDate__c = quoteRec.Requested_Extension_Date__c;
                          quoteRec.SBQQ__ExpirationDate__c = quoteRec.Requested_Extension_Date__c;
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