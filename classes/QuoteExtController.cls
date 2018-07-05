public with sharing class QuoteExtController {
    private Id quoteId;
    public SBAA__Approval__c[] approvals {get; set;}

    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
    }

    public PageReference onSubmit() {
        if (quoteId != null) {
            if(!CheckHardwareAddressAssociation(quoteId))
            {
                SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
                return new PageReference('/' + quoteId);
            }
            else
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The address has not been associated with the hardware products in the quote. Please go to the Quote Address section and add shipping quantities. Click on the quote <a href="https://' + URL.getSalesforceBaseUrl().getHost() + '/' + quoteId + '">' +'Back to the Quote'+ '</a>','Quote Error'));
        }
       return null;
    }

    public PageReference onRecall() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
            return new PageReference('/' + quoteId);
            
        }
         return null;
    }

    public PageReference onPreview() {
        if (quoteId != null) {
            approvals = SBAA.ApprovalAPI.preview(quoteId, SBAA__Approval__c.Quote__c);
        }
        return null;    }
    
    private boolean CheckHardwareAddressAssociation(Id quoteId)
    {
        SBQQ__Quote__c quoteInfo=[Select Id,SBCF_Evaluation_Quote__c,Hw_Count_Qty_QL__c,Hw_Count_Qty_QLA__c,Hw_Sum_Qty_QLA__c,Hw_Sum_Qty_QL__c from SBQQ__Quote__c where Id=:quoteId];
        if(quoteInfo.SBCF_Evaluation_Quote__c && quoteInfo.Hw_Count_Qty_QL__c>0 )
        {
            if(quoteInfo.Hw_Count_Qty_QL__c>0 && quoteInfo.Hw_Count_Qty_QL__c!=quoteInfo.Hw_Count_Qty_QLA__c)
                return true;
             if(quoteInfo.Hw_Sum_Qty_QL__c>0 && quoteInfo.Hw_Sum_Qty_QL__c!=quoteInfo.Hw_Sum_Qty_QLA__c)
                return true;
            
        }
        return false;
    }
}