public class AssociateToQuoteLineAddressController {
    
    public List<QLAWrapper> lstQLA {get;set;}
    public Id quoteAddressId {get;set;}
    public Id quoteId {get;set;}
    public string quoteStatus {get;set;}
    public  Quote_Address__c quoteAddInfo {get;set;}
    public String redirectUrl {public get; private set;}
    public Boolean shouldRedirect {public get; private set;}
    public AssociateToQuoteLineAddressController(ApexPages.StandardController stdController)
    {
        if(lstQLA==null)
            lstQLA = new List<QLAWrapper>();
        quoteAddressId = stdController.getId();
        
        shouldRedirect=false;
        quoteAddInfo=[Select Quote__c, Quote__r.ApprovalStatus__c,(Select Id,Quote_Line__c,Shipping_Quantity__c from Quote_Line_Addresses1__r)  from Quote_Address__c where Id=:quoteAddressId];
        System.debug(quoteAddInfo);
        if(quoteAddInfo!=null && quoteAddInfo.Quote__c!=null)
        {
            quoteId=quoteAddInfo.Quote__c;
            quoteStatus=quoteAddInfo.Quote__r.ApprovalStatus__c;
            List<SBQQ__QuoteLine__c> lstQuoteLines=[Select Id,Name,SBQQ__Quote__c, SBQQ__Product__r.Name, SBQQ__Quantity__c from SBQQ__QuoteLine__c where SBQQ__Product__r.Family='Product' and SBQQ__Bundle__c=false and SBQQ__Quote__c=:quoteAddInfo.Quote__c];
            List<Quote_Line_Address__c> lstQLAData= quoteAddInfo.Quote_Line_Addresses1__r;
            Map<Id,integer> mapQLAOrdered= new Map<Id,integer>();
            List<AggregateResult> aggr= [Select Quote_Line__c, SUM(Shipping_Quantity__c)total from Quote_Line_Address__c where Quote__c=:quoteId and Quote_Address__c!=:quoteAddressId GROUP BY Quote_Line__c];
            System.debug('aggr' + aggr);
            if(aggr!=null && aggr.size()>0)
            {
                for(AggregateResult item: aggr)
                {
                    Id qlId=(Id)item.get('Quote_Line__c');
                    integer total=integer.valueOf(item.get('total'));
                    mapQLAOrdered.put(qlId,total);
                }
                System.debug('mapQLAOrdered'+ mapQLAOrdered);
            }
            Map<Id,integer> mapQLA= new Map<Id,integer>();
            if(lstQLAData!=null && lstQLAData.size()>0)
            {
                for(Quote_Line_Address__c data:lstQLAData)
                {
                    mapQLA.put(data.Quote_Line__c,integer.valueOf(data.Shipping_Quantity__c));
                }
            }
            if(lstQuoteLines!=null && lstQuoteLines.size()>0)
            {
                for(SBQQ__QuoteLine__c ql:lstQuoteLines )
                {
                    integer shipQuantity=0;
                    integer orderedQuantity=0;
                    if(mapQLA.containsKey(ql.Id))
                    {
                        shipQuantity= mapQLA.get(ql.Id);
                    }
                    if(mapQLAOrdered.containsKey(ql.Id))
                    {
                        orderedQuantity= mapQLAOrdered.get(ql.Id);
                        System.debug('orderedQuantity'+ orderedQuantity);
                    }
                    QLAWrapper objQLA= new QLAWrapper(ql,shipQuantity,orderedQuantity);
                    lstQLA.add(objQLA);
                }
            }
        }
        System.debug(lstQLA);
    }
    
    public PageReference SaveData()
    {
        System.savepoint sp= Database.setSavepoint();
        PageReference pr=null;
      
        
        System.debug(redirectURL);
        List<Quote_Line_Address__c> lstQLAddress= new List<Quote_Line_Address__c>();
        try
        {
            SBQQ__Quote__c quoteInfo=[Select Id,ApprovalStatus__c from SBQQ__Quote__c where Id=:quoteId];
            System.debug('quoteInfo.ApprovalStatus__c '+quoteInfo.ApprovalStatus__c);
            if(Validatedata())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You have ordered quantity in another address record.'));
                shouldRedirect=false;
                return null;
            }
            if(quoteInfo.ApprovalStatus__c=='Draft' || quoteInfo.ApprovalStatus__c==null)
            {
                // Delete the current data 
                List<Quote_Line_Address__c> qlaAddressLine=quoteAddInfo.Quote_Line_Addresses1__r;
                System.debug('qlaAddressLine'+ qlaAddressLine );
                if(qlaAddressLine!=null && qlaAddressLine.size()>0)
                    delete qlaAddressLine;
                // 
                //Insert new Data
                System.debug(lstQLA);
                if(lstQLA!=null && lstQLA.size()>0)
                {
                    for(QLAWrapper obj : lstQLA)
                    {
                        if(obj.ShippingQuantity>0)
                        {
                            Quote_Line_Address__c objData = new Quote_Line_Address__c(Quote_Address__c=quoteAddressId,Quote_Line__c=obj.QLData.Id,Shipping_Quantity__c=obj.ShippingQuantity,Quote__c=obj.QLData.SBQQ__Quote__c);
                            lstQLAddress.add(objData);
                        }
                        
                    }
                    System.debug(lstQLAddress);
                    insert lstQLAddress;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Data is saved successfully'));
                    shouldRedirect=true;
                    SBQQ__Quote__c quote= new SBQQ__Quote__c();
                    quote.Id=quoteId;
                    ApexPages.StandardController std1= new ApexPages.StandardController(quote);
                    redirectUrl = std1.view().getUrl(); 
                    return null;
                }
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
    private boolean Validatedata()
    {
        if(lstQLA!=null && lstQLA.size()>0)
        {
            for(QLAWrapper obj : lstQLA)
            {
                if(obj.ShippingQuantity>0 && ((obj.OrderedQuantity+obj.ShippingQuantity )>obj.QLData.SBQQ__Quantity__c))
                    return true;
            }
        }
        return false;
    }
    public class QLAWrapper
    {
        public SBQQ__QuoteLine__c QLData {get;set;}
        public integer ShippingQuantity{get;set;}
        public integer OrderedQuantity{get;set;}
        public QLAWrapper(SBQQ__QuoteLine__c item, integer quantity,integer ordQuantity)
        {
            QLData=item;
            ShippingQuantity=quantity;
            OrderedQuantity=ordQuantity;
        }
        
    }
}