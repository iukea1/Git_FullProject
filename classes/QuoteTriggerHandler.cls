public without sharing class QuoteTriggerHandler implements ITriggerHandler{
    
    //public static final String EvalRmaRecordTypeId = '012500000005H0o';
    //public static final String EvalRMAItemRecordTypeId = '012500000005H0y';
    Id rmaRecordTypeId = Schema.SObjectType.RMA__c.getRecordTypeInfosByName().get('Eval RMA').getRecordTypeId();
    Id itemRecordTypeId = Schema.SObjectType.RMA_Item__c.getRecordTypeInfosByName().get('Eval Return').getRecordTypeId();
    public static Set<Id> pendingReturnQuoteIds = new Set<Id>();
    
    public QuoteTriggerHandler(){
        
    }
    public Boolean IsDisabled(){
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        defaultTerms(newItems);
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
           //populateRequestedEndDateToQuoteEndDate(newItems.values());
           createRmaForEvals(newItems.values(), (Map<Id, SBQQ__Quote__c>)oldItems);
       }   
       runShippedExtendedLogic((Map<Id, SBQQ__Quote__c>)oldItems, (List<SBQQ__Quote__c>)newItems.values());
       pocDataDeletion((Map<Id, SBQQ__Quote__c>)oldItems, (List<SBQQ__Quote__c>)newItems.values());
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
    }
    
    public static void defaultTerms(List<SBQQ__Quote__c> quotes) {
        Set<Id> oppCollect = new Set<Id>();
        for(SBQQ__Quote__c q : quotes) {
            oppCollect.add(q.SBQQ__Opportunity2__c);
        }
        
        Map<Id, Opportunity> parentOps = new Map<Id, Opportunity>([SELECT Id, Account.Payment_Terms__c FROM Opportunity WHERE Id IN :oppCollect]);
        
        for(SBQQ__Quote__c q : quotes) {
            if(parentOps.containsKey(q.SBQQ__Opportunity2__c)) {
                q.SBQQ__PaymentTerms__c = parentOps.get(q.SBQQ__Opportunity2__c).Account.Payment_Terms__c;
            }
        }
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
        Set<Id> qId = new Set<Id>();
        for(SBQQ__Quote__c qRec : quotes) {
            qId.add(qRec.Id);
        }
        Map<Id, Set<Id>> conMap = new Map<Id, Set<Id>>();
        
        for(Contract c : [SELECT Id, SBQQ__Quote__c FROM Contract WHERE SBQQ__Quote__c IN :qId]) {
            if(!conMap.containsKey(c.SBQQ__Quote__c)) conMap.put(c.SBQQ__Quote__c, new Set<Id>());
            conMap.get(c.SBQQ__Quote__c).add(c.Id);
        }
        
        Map<Id, Set<Id>> astMap = new Map<Id, Set<Id>>();
        for(Asset a : [SELECT Id, SBQQ__QuoteLine__r.SBQQ__Quote__c FROM Asset WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c IN :qId]) {
            if(!astMap.containsKey(a.SBQQ__QuoteLine__r.SBQQ__Quote__c)) astMap.put(a.SBQQ__QuoteLine__r.SBQQ__Quote__c, new Set<Id>());
            astMap.get(a.SBQQ__QuoteLine__r.SBQQ__Quote__c).add(a.Id);
        }
        
        Map<Id, Set<Id>> subMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> subAMap = new Map<Id, Set<Id>>();
        for(SBQQ__Subscription__c a : [SELECT Id, SBQQ__QuoteLine__r.SBQQ__Quote__c, (SELECT Id FROM SBQQ__SubscribedAssets__r) FROM SBQQ__Subscription__c WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c IN :qId]) {
            if(!subMap.containsKey(a.SBQQ__QuoteLine__r.SBQQ__Quote__c)) subMap.put(a.SBQQ__QuoteLine__r.SBQQ__Quote__c, new Set<Id>());
            subMap.get(a.SBQQ__QuoteLine__r.SBQQ__Quote__c).add(a.Id);
            
            if(!subAMap.containsKey(a.Id)) subAMap.put(a.Id, new Set<Id>());
            for(SBQQ__SubscribedAsset__c sa : a.SBQQ__SubscribedAssets__r) subAMap.get(a.Id).add(sa.Id);
        }

        List<Contract> contUpdate = new List<Contract>();
        List<Asset> astUpdate = new List<Asset>();
        List<SBQQ__Subscription__c> subUpdate = new List<SBQQ__Subscription__c>();
        List<SBQQ__SubscribedAsset__c> subAUpdate = new List<SBQQ__SubscribedAsset__c>();
        Set<Id> shippedQuotes = new Set<Id>();
        for(SBQQ__Quote__c qRec : quotes) {
            if(qRec.POC_Status__c == 'Shipped - Extended' && oldItems.get(qRec.Id).POC_Status__c != 'Shipped - Extended' && conMap.containsKey(qRec.Id)) {
                //qRec.SBQQ__EndDate__c = qRec.Requested_Extension_Date__c;
                //qRec.SBQQ__ExpirationDate__c = qRec.Requested_Extension_Date__c;
                shippedQuotes.add(qRec.Id);
                for(Id i : conMap.get(qRec.Id)) {
                    contUpdate.add(
                        new Contract(
                            Id = i,
                            EndDate = qRec.Requested_Extension_Date__c,
                            Status = 'Activated'
                        )
                    );
                }
                for(Id i : astMap.get(qRec.Id)) {
                    astUpdate.add(
                        new Asset(
                            Id = i,
                            Evaluation_End_Date__c = qRec.Requested_Extension_Date__c,
                            Create_License__c = true,
                            Status = 'Customer Evaluation'
                        )
                    );
                }
                for(Id i : subMap.get(qRec.Id)) {
                    subUpdate.add(
                        new SBQQ__Subscription__c(
                            Id = i,
                            End_Date__c = qRec.Requested_Extension_Date__c
                        )
                    );
                    if(subAMap.containsKey(i)) {
                        for(Id sa : subAMap.get(i)) {
                            subAUpdate.add(
                                new SBQQ__SubscribedAsset__c(Id=sa, SBQQ__Active__c = true)  
                            );
                        }
                    }
                }
            }
        }
        if(!contUpdate.isEmpty()) update contUpdate;
        if(!astUpdate.isEmpty()) update astUpdate;
        if(!subUpdate.isEmpty()) update subUpdate;
        if(!subAUpdate.isEmpty()) update subAUpdate;
        if(!shippedQuotes.isEmpty()) {
            deleteRMA(shippedQuotes);
        }
    }
    
    @future
    public static void deleteRMA(Set<Id> shippedQuotes) {
        delete [SELECT Id FROM Rma_Item__c WHERE Rma__r.POC_Quote__c IN :shippedQuotes];
        delete [SELECT Id FROM Rma__c WHERE POC_Quote__c IN :shippedQuotes];
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
    
    /**
    *   Sets End date and expiration dates of quote record to the value from requested extension date when record gets approved
    *
    **/
    public static void populateRequestedEndDateToQuoteEndDate(List<SBQQ__Quote__c> quotes) {
        Set<Id> quotesIds = new Set<Id>();
        
        for(SBQQ__Quote__c quote: quotes){
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
        
        try {
            if(quotesToUpdate.size()>0){
                update quotesToUpdate;
            } 
        } catch(Exception e) {}
    }

    
    private static void createRmaForEvals(List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> oldQuotes) {
        //POC_Quote__c
        List<RMA__c> rmaInsert = new List<RMA__c>();
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Eval_RMA' AND sObjectType = 'RMA__c' LIMIT 1];
        Map<Integer, List<RMA_Item__c>> rmaIdxToRmaItem = new Map<Integer, List<RMA_Item__c>>();
        
        Map<Id, List<Asset>> quoteAssets = new Map<Id, List<Asset>>();
        for(Asset a : [SELECT Id, Product2Id, SBQQ__QuoteLine__r.SBQQ__Quote__c FROM Asset WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c IN :quotes]) {
            if(!quoteAssets.containsKey(a.SBQQ__QuoteLine__r.SBQQ__Quote__c)) quoteAssets.put(a.SBQQ__QuoteLine__r.SBQQ__Quote__c, new List<Asset>());
            quoteAssets.get(a.SBQQ__QuoteLine__r.SBQQ__Quote__c).add(a);
        }
        
        List<Contract> expireList = new List<Contract>();
        for(SBQQ__Quote__c q : quotes) {
            if(oldQuotes.get(q.Id).POC_Status__c != 'Pending Return' && q.POC_Status__c == 'Pending Return' && q.SBCF_Evaluation_Quote__c) {
                pendingReturnQuoteIds.add(q.Id);
            }
        }
        for(Contract c : [SELECT Id FROM Contract WHERE SBQQ__Quote__c IN :pendingReturnQuoteIds AND Status != 'Expired']) {
            c.Status = 'Expired';
            expireList.add(c);
        }
        if(!expireList.isEmpty()) update expireList;
        
        
    }
}