public without sharing class QuoteTriggerHandler implements ITriggerHandler{
    Map<Id,Id> mapEvalQuoteIds= new Map<Id,Id>();
    //public static final String EvalRmaRecordTypeId = '012500000005H0o';
    //public static final String EvalRMAItemRecordTypeId = '012500000005H0y';
    Set<Id> removeUsers = new Set<Id>{'00550000000lhIW','00530000000jZPL'};// remove eric and chris helfer from the APAC and EMEA
    static Set<Id> opportunityIds = new Set<Id>();
    Id rmaRecordTypeId = Schema.SObjectType.RMA__c.getRecordTypeInfosByName().get('Eval RMA').getRecordTypeId();
    Id itemRecordTypeId = Schema.SObjectType.RMA_Item__c.getRecordTypeInfosByName().get('Eval Return').getRecordTypeId();
    public static Set<Id> pendingReturnQuoteIds = new Set<Id>();
    public static Boolean preventRecursion = false;
    
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
        if(newItems!=null && newItems.size()>0)
        {
            for (Id quoteId : newItems.keyset())
            {
                SBQQ__Quote__c newQuoteInfo= (SBQQ__Quote__c)newItems.get(quoteId);
                opportunityIds.add(newQuoteInfo.SBQQ__Opportunity2__c);
                if(newQuoteInfo.SBQQ__Opportunity2__c!=null && newQuoteInfo.SBCF_Evaluation_Quote__c)
                {
                    mapEvalQuoteIds.put(quoteId,newQuoteInfo.SBQQ__Opportunity2__c);
                }
            }
        }
        PopulatePOCApprovers();
        UpdatePOCStatusOnRelatedOpp();
        populateThePocIDinRelatedRecords(newItems.values());
        
       System.debug('QUOTE TRIGGER AFTER INSERT >>>>>>>> QUERIES : ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
       List<Opportunity> lstOppsToUpdate= new List<Opportunity>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id quoteId : newItems.keyset())
            {
                SBQQ__Quote__c newQuoteInfo= (SBQQ__Quote__c)newItems.get(quoteId);
                SBQQ__Quote__c oldQuoteInfo= (SBQQ__Quote__c)oldItems.get(quoteId); 
                if(oldQuoteInfo.POC_Status__c!= newQuoteInfo.POC_Status__c)
                {
                    opportunityIds.add(newQuoteInfo.SBQQ__Opportunity2__c);
                    lstOppsToUpdate.add(new Opportunity(Id= newQuoteInfo.SBQQ__Opportunity2__c,StageName=newQuoteInfo.POC_Status__c) );
                }
                 if(newQuoteInfo.SBCF_Evaluation_Quote__c && oldQuoteInfo.Refresh_Approvers__c!=newQuoteInfo.Refresh_Approvers__c && newQuoteInfo.Refresh_Approvers__c)
                {
                    if(newQuoteInfo.SBQQ__Opportunity2__c!=null)
                    {
                        mapEvalQuoteIds.put(newQuoteInfo.Id,newQuoteInfo.SBQQ__Opportunity2__c);
                    }
                }
                if(oldQuoteInfo.SBQQ__Opportunity2__c!= newQuoteInfo.SBQQ__Opportunity2__c)
                {
                    opportunityIds.add(newQuoteInfo.SBQQ__Opportunity2__c);
                    opportunityIds.add(oldQuoteInfo.SBQQ__Opportunity2__c);
                }
            }
        }
     
       if(CheckRecursive.runOnce() && !preventRecursion){
           PopulatePOCApprovers();
           //populateRequestedEndDateToQuoteEndDate(newItems.values());
           createRmaForEvals(newItems.values(), (Map<Id, SBQQ__Quote__c>)oldItems);
           runShippedExtendedLogic((Map<Id, SBQQ__Quote__c>)oldItems, (List<SBQQ__Quote__c>)newItems.values());
           if(!lstOppsToUpdate.isEmpty()) update lstOppsToUpdate;
           UpdatePOCStatusOnRelatedOpp();
           pocDataDeletion((Map<Id, SBQQ__Quote__c>)oldItems, (List<SBQQ__Quote__c>)newItems.values());
           preventRecursion = true;
       }   
       
       System.debug('QUOTE TRIGGER AFTER UPDATE >>>>>>>> QUERIES : ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
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
    
    public static void runShippedExtendedLogic(Map<Id, SBQQ__Quote__c> oldItems, List<SBQQ__Quote__c> nQuotes) {
        Set<Id> qId = new Set<Id>();
        for(SBQQ__Quote__c qRec : nQuotes) {
            qId.add(qRec.Id);
        }
        Map<Id, Set<Id>> conMap = new Map<Id, Set<Id>>();
        
        for(Contract c : [SELECT Id, SBQQ__Quote__c FROM Contract WHERE SBQQ__Quote__c IN :qId]) {
            if(!conMap.containsKey(c.SBQQ__Quote__c)) conMap.put(c.SBQQ__Quote__c, new Set<Id>());
            conMap.get(c.SBQQ__Quote__c).add(c.Id);
        }
        
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c qRec : nQuotes) {
            if(qRec.POC_Status__c == 'Shipped - Extended' && oldItems.get(qRec.Id).POC_Status__c != 'Shipped - Extended' && conMap.containsKey(qRec.Id)) {
                quotes.add(qRec);
            }
        }
        
        if(!quotes.isEmpty()) {
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

    private static void UpdatePOCStatusOnRelatedOpp()
    {
      
        if(opportunityIds !=null && opportunityIds .size()>0)
        {
            Set<Id> setOppIds= new Set<ID>();
            
            List<Opportunity> lstOpp=[Select Related_Opportunity__c,Related_Opportunity__r.Has_Active_POCs__c,Related_Opportunity__r.POC_History__c from Opportunity where Id in:opportunityIds];
            if(!lstOpp.isEmpty())
            {
                for(Opportunity counter: lstOpp)
                {
                    setOppIds.add(counter.Related_Opportunity__c);
                }
            }
            List<Opportunity> lstCustOpp=[Select Id,AccountID,Has_Active_POCs__c,POC_History__c,(Select Id from RelatedOpportunities__r where Related_Opportunity__c in:setOppIds and POC_Opportunity__c=true and IsClosed__c=0) from Opportunity where Id in:setOppIds];
            if(!lstCustOpp.isEmpty())
            {
                Set<Id> accIds = new Set<Id>();
                for(Opportunity counter: lstCustOpp)
                {
                    counter.Has_Active_POCs__c= counter.RelatedOpportunities__r.size()>0;
                    if(counter.Has_Active_POCs__c == true && counter.POC_History__c == false)
                    {
                        counter.POC_History__c = true;
                    }
                    counter.Bypassing_Validation__c = true;
                    accIds.add(counter.AccountId);
                }
                try
                {
                    update lstCustOpp;
                }
                catch(Exception ex)
                {
                    SilverPeakUtils.logException(ex);
                }
                List<Account> accs = [select Id, POC_Request_Date__c, Has_Active_POCs__c, (select Id from Opportunities where POC_Opportunity__c=false and Has_Active_POCs__c=true limit 1) from Account where Id in :accIds];
                for(Account acc : accs)
                {
                    acc.Has_Active_POCs__c = acc.Opportunities.size() > 0;
                    if(acc.POC_Request_Date__c == null)
                    {
                        acc.POC_Request_Date__c = Date.today();
                    }
                }
                try
                {
                    update accs;
                }
                catch(Exception ex)
                {
                    SilverPeakUtils.logException(ex);
                }
                
            }
        }
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
    
     private void PopulatePOCApprovers() {
        Map<Id,Opportunity> mapOppId= new Map<Id,Opportunity>(); 
        if(mapEvalQuoteIds.size()>0)
        {
            List<Opportunity> lstOpportunity=[Select Id,Account.ECSP__c,OwnerId,Owner.ManagerId,Owner.Manager.ManagerId,Technical_Responsible__c,Technical_Responsible__r.ManagerId,Technical_Responsible__r.Manager.ManagerId, GEO_Region__c from Opportunity where Id in:mapEvalQuoteIds.values()];
            for(Opportunity opp:lstOpportunity)
            {
                if(!mapOppId.containsKey(opp.Id))
                {
                    mapOppId.put(opp.Id,opp);
                }
            }
            List<SBQQ__Quote__c> lstPOCs= new List<SBQQ__Quote__c>();
            for(Id reqId:mapEvalQuoteIds.keySet())
            {
                
                Opportunity finalOpp= mapOppId.get(mapEvalQuoteIds.get(reqId));
                SBQQ__Quote__c pocToUpdate= new SBQQ__Quote__c(Id=reqId);
                pocToUpdate.RSM_Approver_LK__c=finalOpp.OwnerId!=null?finalOpp.OwnerId:null;
                pocToUpdate.SE_Approver_LK__c=finalOpp.Technical_Responsible__c!=null?finalOpp.Technical_Responsible__c:null;
                if(finalOpp.Account.ECSP__c || finalOpp.GEO_Region__c.startsWith('APAC') || finalOpp.GEO_Region__c.startsWith('EMEA') || finalOpp.GEO_Region__c.startsWith('ANZ'))
                {
                    pocToUpdate.RSM_Sales_Director_Approver_LK__c=(finalOpp.Owner.ManagerId!=null && !removeUsers.contains(finalOpp.Owner.ManagerId) )?finalOpp.Owner.ManagerId:null;
                    pocToUpdate.RSM_VP_Sales_Approver_LK__c=(finalOpp.Owner.Manager.ManagerId!=null && !removeUsers.contains(finalOpp.Owner.Manager.ManagerId))?finalOpp.Owner.Manager.ManagerId:null;
                    pocToUpdate.SE_Manager_Approver_LK__c=(finalOpp.Technical_Responsible__r.ManagerId!=null && !removeUsers.contains(finalOpp.Technical_Responsible__r.ManagerId))?finalOpp.Technical_Responsible__r.ManagerId:null;
                    pocToUpdate.SE_Director_Approver_LK__c=(finalOpp.Technical_Responsible__r.Manager.ManagerId!=null && !removeUsers.contains(finalOpp.Technical_Responsible__r.Manager.ManagerId) )?finalOpp.Technical_Responsible__r.Manager.ManagerId:null;
                }
                else
                {
                    pocToUpdate.RSM_Sales_Director_Approver_LK__c=finalOpp.Owner.ManagerId!=null?finalOpp.Owner.ManagerId:null;
                    pocToUpdate.RSM_VP_Sales_Approver_LK__c=finalOpp.Owner.Manager.ManagerId!=null?finalOpp.Owner.Manager.ManagerId:null;
                    pocToUpdate.SE_Manager_Approver_LK__c=finalOpp.Technical_Responsible__r.ManagerId!=null?finalOpp.Technical_Responsible__r.ManagerId:null;
                    pocToUpdate.SE_Director_Approver_LK__c=finalOpp.Technical_Responsible__r.Manager.ManagerId!=null?finalOpp.Technical_Responsible__r.Manager.ManagerId:null;
                }
                pocToUpdate.Refresh_Approvers__c=false;
                lstPocs.add(pocToUpdate);
                
            }
            if(lstPocs.size()>0)
                update lstPocs;
        }
        
    }
}