public class QuoteSubscribedAssetsExtension {
    
    public List<AssetWrapper> lstAssets{get;set;}
    private Id QuoteId{get;set;}
    public QuoteSubscribedAssetsExtension(ApexPages.StandardController stdController)
    {
        QuoteId= stdController.getId();
        lstAssets= new List<AssetWrapper>();
        if(quoteId!=null)
        {
                List<SBQQ__SubscribedAsset__c> lstSubAsset=[Select Id,SBQQ__Asset__r.Product2.Name, SBQQ__Asset__r.SerialNumber,SBQQ__Subscription__r.SBQQ__Contract__r.EndDate from SBQQ__SubscribedAsset__c where SBQQ__Active__c=true and SBQQ__Subscription__c in(Select SBQQ__RenewedSubscription__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId)];
                if(lstSubAsset!=null && lstSubAsset.size()>0)
                {
                    for(SBQQ__SubscribedAsset__c item: lstSubAsset)
                    {
                        lstAssets.add(new AssetWrapper(false,item));
                    }
                }
            }
            
            
        }
    public PageReference save()
    {
        string saveAssets;
        if(lstAssets!=null && lstAssets.size()>0)
        {
            for(AssetWrapper item: lstAssets)
            {
                if(item.IsChecked)
                {
                    if(saveAssets==null)
                        saveAssets=item.SerialNumber+', ';
                    else
                        saveAssets+=item.SerialNumber+', ';
                }
                
                
            }
            if(saveAssets!=null)
            {
                saveAssets=saveAssets.removeEnd(', ');
                SBQQ__Quote__c obj= new SBQQ__Quote__c(Id=QuoteId, Serial_Number_Notes__c=saveAssets);
                update obj;
                if(ApexPages.currentPage() != null)
                {
                    
                    ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Succeeded. <script type="text/javascript">top.opener.location="/' + QuoteId + '";window.setTimeout("top.close();", 2000);</script>');
                    ApexPages.addMessage(pageMsg);
                    
                }
            }
            else
            {
                 ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select atleast one serial number.');
                    ApexPages.addMessage(pageMsg);
            }
            
        }
        return null;
    }
    
    
    public class AssetWrapper
    {
        public boolean IsChecked{get;set;}
        public string SerialNumber{get;set;}
        public string ProductName{get;set;}
        public Date LicenseEndDate{get;set;}
       
        public AssetWrapper(boolean isChecked, SBQQ__SubscribedAsset__c sub)
        {
            IsChecked=isChecked;
            SerialNumber=sub.SBQQ__Asset__r.SerialNumber;
            ProductName=sub.SBQQ__Asset__r.Product2.Name;
            LicenseEndDate=sub.SBQQ__Subscription__r.SBQQ__Contract__r.EndDate;
        }
    }        
    
}