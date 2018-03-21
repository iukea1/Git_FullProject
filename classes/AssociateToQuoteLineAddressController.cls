public class AssociateToQuoteLineAddressController {
    
    public List<QLAWrapper> lstQLA {get;set;}
    public Id quoteAddressId {get;set;}
    public  Quote_Address__c quoteAddInfo {get;set;}
    public AssociateToQuoteLineAddressController(ApexPages.StandardController stdController)
    {
        if(lstQLA==null)
            lstQLA = new List<QLAWrapper>();
        quoteAddressId = stdController.getId();
        quoteAddInfo=[Select Quote__c, (Select Id,Quote_Line__c,Shipping_Quantity__c from Quote_Line_Addresses1__r)  from Quote_Address__c where Id=:quoteAddressId];
        System.debug(quoteAddInfo);
        if(quoteAddInfo!=null && quoteAddInfo.Quote__c!=null)
        {
            List<SBQQ__QuoteLine__c> lstQuoteLines=[Select Id,Name,SBQQ__Quote__c, SBQQ__Product__r.Name, SBQQ__Quantity__c from SBQQ__QuoteLine__c where SBQQ__Product__r.Family='Product' and SBQQ__Quote__c=:quoteAddInfo.Quote__c];
            List<Quote_Line_Address__c> lstQLAData= quoteAddInfo.Quote_Line_Addresses1__r;
            Map<Id,integer> mapQLA= new Map<Id,integer>();
            if(lstQLAData!=null && lstQLAData.size()>0)
            {
                for(Quote_Line_Address__c data:lstQLAData)
                {
                    mapQLA.put(data.Quote_Line__c,integer.valueOf(data.Shipping_Quantity__c));
                }
            }
            for(SBQQ__QuoteLine__c ql:lstQuoteLines )
            {
                integer shipQuantity=0;
                if(mapQLA.containsKey(ql.Id))
                {
                    shipQuantity= mapQLA.get(ql.Id);
                }
                QLAWrapper objQLA= new QLAWrapper(ql,shipQuantity);
                lstQLA.add(objQLA);
            }
        }
        
    }
    
    public PageReference SaveData()
    {
        System.savepoint sp= Database.setSavepoint();
        PageReference pr=null;
        List<Quote_Line_Address__c> lstQLAddress= new List<Quote_Line_Address__c>();
        try
        {
            
            // Delete the current data 
            List<Quote_Line_Address__c> qlaAddressLine=quoteAddInfo.Quote_Line_Addresses1__r;
            if(qlaAddressLine!=null && qlaAddressLine.size()>0)
                delete qlaAddressLine;
            // 
            //Insert new Data
            System.debug(lstQLA);
            if(lstQLA!=null && lstQLA.size()>0)
            {
                
                for(QLAWrapper obj : lstQLA)
                {
                    Quote_Line_Address__c objData = new Quote_Line_Address__c(Quote_Address__c=quoteAddressId,Quote_Line__c=obj.QLData.Id,Shipping_Quantity__c=obj.ShippingQuantity,Quote__c=obj.QLData.SBQQ__Quote__c);
                    lstQLAddress.add(objData);
                }
                System.debug(lstQLAddress);
                insert lstQLAddress;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Data is saved successfully'));
               
                
                
            }
            
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            System.debug(ex);
            SilverPeakUtils.logException(ex);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        
        
        
        return null;
    }
    
    public class QLAWrapper
    {
        public SBQQ__QuoteLine__c QLData {get;set;}
        public integer ShippingQuantity{get;set;}
        public QLAWrapper(SBQQ__QuoteLine__c item, integer quantity)
        {
            QLData=item;
            ShippingQuantity=quantity;
        }
        
    }
}