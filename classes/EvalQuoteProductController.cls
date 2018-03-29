global class EvalQuoteProductController {
    
    global Id QuoteId { get; set; }
    global List<Quote_Line_Address__c> HWProd
    {
       get
        {
            if(QuoteId != null)
            {
                return [Select Id,Quote_Line__r.SBQQ__Product__r.Name,Shipping_Quantity__c,Quote_Address__r.City__c,Quote_Address__r.Country__c,Quote_Address__r.State__c,Quote_Address__r.Street__c,Quote_Address__r.Postal_Code__c from Quote_Line_Address__c where Quote_Line__r.SBQQ__Product__r.Family='Product' and Quote__c=:QuoteId];
            }
            else
            {
                return new List<Quote_Line_Address__c>();
            }
        }
    }
    
    global List<SBQQ__QuoteLine__c> SWProd
    {
        get
        {
            if(QuoteId != null)
            {
                return [Select Id,SBQQ__Product__r.Name,SBQQ__Quantity__c from SBQQ__QuoteLine__c where SBQQ__Product__r.Family='Virtual Image' and SBQQ__Quote__c=:QuoteId];
            }
            else
            {
                return new List<SBQQ__QuoteLine__c>();
            }
        }
       
    }
    
}