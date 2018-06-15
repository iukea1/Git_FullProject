public class PortalViewController_WanOp extends PortalViewBase{

    public PortalViewController_WanOp()
    {
        PageNumber = 0;
        PageCount = 0;
        initSort();
        loadData();
        if(lstResults!=null && lstResults.size()>0)
            lstResults.sort();
    }  
    protected override string BuildAssetSearch()
    {
        String escapedKeyword = String.escapeSingleQuotes(SearchParameter == null ? '' : SearchParameter);
        String maskKeyword = '%' + escapedKeyword.replaceAll('\\*', '_') + '%';
        string result='Select Id,Product2.Name,SBQQ__CurrentSubscription__r.SBQQ__SubscriptionEndDate__c,Product2.Product_Type__c,SerialNumber,Status,Account.Name,Product2.Model__c,Family,Customer_Notes__c	,Ship_Date__c,License_End_Date__c,License_Key__c,Warranty_End_Date__c from Asset where (Product2.Name like \'NX%\' or Product2.Name like \'GMS-10%\') and Status=\'Customer Owned\' and Contract_Status__c = \'Activated\'  and Contract_End__c >=today and Model__c in :models and (SerialNumber=\'';
        result += ' where (NOT Product2.Name like \'EC%\') and (SerialNumber=\'' + escapedKeyword + '\' or Model__c like \'' + maskKeyword + '\' or Product2.Name like \'' + maskKeyword + '\' or Customer_Notes__c like \'' + maskKeyword + '\')';
        if(IsSearchForActive)
            result+= 'and SBQQ__CurrentSubscription__r.SBQQ__SubscriptionEndDate__c >today';
        result += ' limit 10000';
        return result;
    }
    protected override string BuildAssetQuery()
    {
       	String query = '';
        query = 'select Id,Product2.Name,SBQQ__CurrentSubscription__r.SBQQ__SubscriptionEndDate__c,Product2.Product_Type__c,SerialNumber,Status,Account.Name,Product2.Model__c,Product2.Family,Customer_Notes__c	,Ship_Date__c,License_End_Date__c,License_Key__c,Warranty_End_Date__c';
        query += ' from Asset';
        query += ' where (NOT Product2.Name like \'EC%\') and AccountId=\'0015000000u6rqo\' and Status in(\'Customer Owned\',\'Customer Subscription Active\',\'Customer Evaluation\')';
        query += ' limit 10000';
        System.debug(query);
        return query;
    }
    protected override string BuildSubSearch()
    {
        return '';
    }
    protected override string BuildSubQuery()
    {
        return '';
    }
    protected override  List<PortalDataWrapper> BuildData(List<Asset> lstAssetData,List<SBQQ__Subscription__c> lstSubscriptions)
    {
        System.debug('lstAssetData'+lstAssetData);
        List<PortalDataWrapper> lstData= new List<PortalDataWrapper>();
        if(lstAssetData!=null && lstAssetData.size()>0)
        {
            
            for(Asset item:lstAssetData)
            {
                PortalDataWrapper data= new PortalDataWrapper();
                data.SerialNumber= item.SerialNumber;
                data.RecordId= item.Id;
                data.AccountName= item.Account.Name;
                data.ProductName= item.Product2.Name;
                data.Status= item.Status;
                data.ProductType= item.Product2.Product_Type__c;
                data.ProductFamily= item.Product2.Family;
                data.Model= item.Product2.Model__c;
                data.CustomerNotes= item.Customer_Notes__c;
                data.LicenseKey=item.License_Key__c;
                data.LicenseEndDate= item.Status=='Customer Subscription Active'? item.SBQQ__CurrentSubscription__r.SBQQ__SubscriptionEndDate__c:null;
                data.ContractEndDate= item.Status=='Customer Owned'? item.SBQQ__CurrentSubscription__r.SBQQ__SubscriptionEndDate__c:null;
                data.WarrantyEndDate= item.Status=='Customer Owned'? item.Warranty_End_Date__c:null;
                lstData.add(data);
            }
        }
        System.debug('lstData'+ lstData );
        return lstData;
    }
    
    
    
}