public class QuoteDiscountInfoController {

    public QuoteWrapper DiscountQuote{get;set;}
    public QuoteDiscountInfoController(ApexPages.StandardController ctrl)
    {
        Id quoteId=(Id)ctrl.getRecord().id;
        SBQQ__Quote__c quoteInfo= [Select Id,Primary_Partner_Account__c,Reseller_Partner__r.Payment_Terms__c,Reseller_Partner__r.Partner_Level__c,Reseller_Partner__r.Partner_Type__c,Reseller_Partner__r.Reseller_Agreement__c,Reseller_Partner__r.Standard_Discount_Product__c,Reseller_Partner__r.Standard_Discount_Service__c,Reseller_Partner__r.Standard_Discount_EdgeConnect__c,Reseller_Partner__r.Registered_Discount_EdgeConnect__c,Reseller_Partner__r.Registered_Discount_Product__c,Reseller_Partner__r.Registered_Discount_Service__c from SBQQ__Quote__c where Id=:quoteId];
        DiscountQuote= new QuoteWrapper(quoteInfo); 
    }
    
     public class QuoteWrapper
    {
        public string PP_PartnerType {get;set;}
        public string PP_PartnerLevel {get;set;}
        public boolean PP_ResellerAgreement {get;set;}
        public string PP_PaymentTerms {get;set;}
        public decimal PP_StandECDiscount{get;set;}
        public decimal PP_StandNXVXDiscount{get;set;}
        public decimal PP_StandServiceDiscount{get;set;}
        public decimal PP_RegECDiscount{get;set;}
        public decimal PP_RegNXVXDiscount{get;set;}
        public decimal PP_RegServiceDiscount{get;set;}
        
        public string RP_PartnerType {get;set;}
        public string RP_PartnerLevel {get;set;}
        public boolean RP_ResellerAgreement {get;set;}
        public string RP_PaymentTerms {get;set;}
        public decimal RP_StandECDiscount{get;set;}
        public decimal RP_StandNXVXDiscount{get;set;}
        public decimal RP_StandServiceDiscount{get;set;}
        public decimal RP_RegECDiscount{get;set;}
        public decimal RP_RegNXVXDiscount{get;set;}
        public decimal RP_RegServiceDiscount{get;set;}
        
        QuoteWrapper(SBQQ__Quote__c quoteInfo)
        {
            RP_PartnerType = quoteInfo.Reseller_Partner__r.Partner_Type__c;
            RP_PartnerLevel = quoteInfo.Reseller_Partner__r.Partner_Level__c;
            RP_ResellerAgreement = quoteInfo.Reseller_Partner__r.Reseller_Agreement__c;
            RP_PaymentTerms = quoteInfo.Reseller_Partner__r.Payment_Terms__c;
            RP_StandECDiscount= quoteInfo.Reseller_Partner__r.Standard_Discount_EdgeConnect__c;
            RP_StandNXVXDiscount= quoteInfo.Reseller_Partner__r.Standard_Discount_Product__c;
            RP_StandServiceDiscount= quoteInfo.Reseller_Partner__r.Standard_Discount_Service__c;
            RP_RegECDiscount = quoteInfo.Reseller_Partner__r.Registered_Discount_EdgeConnect__c;
            RP_RegNXVXDiscount = quoteInfo.Reseller_Partner__r.Registered_Discount_Product__c;
            RP_RegServiceDiscount = quoteInfo.Reseller_Partner__r.Registered_Discount_Service__c ;
            if(quoteInfo.Primary_Partner_Account__c!=null)
            {
                Account accInfo=[Select Payment_Terms__c,Partner_Level__c,Partner_Type__c,Reseller_Agreement__c,Standard_Discount_Product__c,Standard_Discount_Service__c,Standard_Discount_EdgeConnect__c,Registered_Discount_EdgeConnect__c,Registered_Discount_Product__c,Registered_Discount_Service__c  from Account where Id=:quoteInfo.Primary_Partner_Account__c];
                PP_PartnerType = accInfo.Partner_Type__c;
                PP_PartnerLevel = accInfo.Partner_Level__c;
                PP_ResellerAgreement = accInfo.Reseller_Agreement__c;
                PP_PaymentTerms = accInfo.Payment_Terms__c;
                PP_StandECDiscount= accInfo.Standard_Discount_EdgeConnect__c;
                PP_StandNXVXDiscount= accInfo.Standard_Discount_Product__c;
                PP_StandServiceDiscount= accInfo.Standard_Discount_Service__c;
                PP_RegECDiscount = accInfo.Registered_Discount_EdgeConnect__c;
                PP_RegNXVXDiscount = accInfo.Registered_Discount_Product__c;
                PP_RegServiceDiscount = accInfo.Registered_Discount_Service__c ;
            }
        }
    }
}