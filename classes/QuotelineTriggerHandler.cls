public without sharing class QuotelineTriggerHandler implements ITriggerHandler{
	public QuotelineTriggerHandler(){
        
    }
    public Boolean IsDisabled(){
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for(Id qlId:newItems.keyset())
            {
                SBQQ__QuoteLine__c newItem= (SBQQ__QuoteLine__c)newItems.get(qlId);
                SBQQ__QuoteLine__c oldItem= (SBQQ__QuoteLine__c)oldItems.get(qlId);
                if(newItem.SBQQ__Quantity__c<newItem.Renewal_Original_Quantity__c)
                    newItem.Reduction_QL__c=1;
                else
                     newItem.Reduction_QL__c=0;
            }
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        //populateQuoteNumberToPOCId(newItems.values());
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
    
    public static void populateQuoteNumberToPOCId(List<SBQQ__QuoteLine__c> quoteLine){
        System.debug('After Insert POC Id from QuoteLine');
		Set<Id> quoteLineIds = new Set<Id>();        
		List<SBQQ__QuoteLine__c> updateQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c ql: quoteLine){
            quoteLineIds.add(ql.Id);
        }
        
        for(SBQQ__QuoteLine__c qlToUpdate: [SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.SBCF_Evaluation_Quote__c, POC_ID__c FROM SBQQ__QuoteLine__c]){
            if(qlToUpdate.SBQQ__Quote__r.SBCF_Evaluation_Quote__c){
                String formattedStr = qlToUpdate.SBQQ__Quote__r.Name;
                
                String[] strArr = formattedStr.split('-');
                String strNumber = '';
                
                if(strArr.size() >1){
                    strNumber = strArr[1];
                    qlToUpdate.POC_ID__c = Integer.valueOf(strNumber);
                    System.debug('qlToUpdate.POC_ID__c' + Integer.valueOf(strNumber));
                    updateQuoteLines.add(qlToUpdate);
                }
            }
        }
        
        if(updateQuoteLines.size()>0){
            update updateQuoteLines;
        }
        
    }
}