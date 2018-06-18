public with sharing class PortalViewController_SDWAN extends PortalViewBase{

    public PortalViewController_SDWAN()
    {
        PageNumber = 0;
        PageCount = 0;
        IsSearchForActive=false;
        initSort();
        loadData();
        if(lstResults!=null && lstResults.size()>0)
            lstResults.sort();
    }  
    protected override string BuildAssetSearch()
    {
        String escapedKeyword = String.escapeSingleQuotes(SearchParameter == null ? '' : SearchParameter);
        String maskKeyword = '%' + escapedKeyword.replaceAll('\\*', '_') + '%';
        string result='Select Id,Product2.Name,SBQQ__CurrentSubscription__r.SBQQ__SubscriptionEndDate__c,Product2.Product_Type__c,SerialNumber,Status,Account.Name,Product2.Model__c,Product2.Family,Customer_Notes__c	,Ship_Date__c,License_End_Date__c,License_Key__c,Warranty_End_Date__c,Warranty_Start_Date__c,End_of_Maintenance__c from Asset';
        result += ' where (Product2.Name like \'EC%\') and SBQQ__CurrentSubscription__c in(Select SBQQ__Subscription__c from SBQQ__SubscribedAsset__c where SBQQ__Active__c=true)  and Product2.Product_Type__c = \'EDGECONNECT\' and Status in(\'Customer Owned\',\'Customer Subscription Active\',\'Customer Evaluation\') and (SerialNumber=\'' + escapedKeyword + '\' or Model__c like \'' + maskKeyword + '\' or Product2.Name like \'' + maskKeyword + '\' or Customer_Notes__c like \'' + maskKeyword + '\')';
        if(IsSearchForActive==true)
            result+= 'and SBQQ__CurrentSubscription__r.SBQQ__SubscriptionEndDate__c!=null and SBQQ__CurrentSubscription__r.SBQQ__SubscriptionEndDate__c >=today';
        
        result += ' limit 10000';
        
        System.debug(result);
        return result;
    }
    protected override string BuildAssetQuery()
    {
       	String query = '';
        query = 'select Id,Product2.Name,SBQQ__CurrentSubscription__r.SBQQ__SubscriptionEndDate__c,Product2.Product_Type__c,SerialNumber,Status,Account.Name,Product2.Model__c,Product2.Family,Customer_Notes__c	,Ship_Date__c,License_End_Date__c,License_Key__c,Warranty_End_Date__c,Warranty_Start_Date__c,End_of_Maintenance__c';
        query += ' from Asset';
        query += ' where (Product2.Name like \'EC%\') and SBQQ__CurrentSubscription__c in(Select SBQQ__Subscription__c from SBQQ__SubscribedAsset__c where SBQQ__Active__c=true)  and Product2.Product_Type__c = \'EDGECONNECT\'  and Status in(\'Customer Owned\',\'Customer Subscription Active\',\'Customer Evaluation\')';
        query += ' limit 10000';
        System.debug(query);
        return query;
    }
    protected override string BuildSubSearch()
    {
        String escapedKeyword = String.escapeSingleQuotes(SearchParameter == null ? '' : SearchParameter);
        String maskKeyword = '%' + escapedKeyword.replaceAll('\\*', '_') + '%';
        string result='Select Id,SBQQ__Product__r.Name,SBQQ__Product__r.Product_Type__c,SBQQ__Account__r.Name,SBQQ__StartDate__c,SBQQ__Contract__r.EndDate,Customer_Notes__c,SBCF_Subscription_Status__c,SerialNumber__c,SBQQ__Product__r.Family,SBQQ__Product__r.Model__c from SBQQ__Subscription__c';
        result += ' where (SBQQ__Product__r.Name like \'EC%\') and SBCF_Subscription_Status__c in(\'Customer Subscription Active\',\'Customer Subscription Expired\') and SBQQ__Product__r.Product_Type__c = \'EDGECONNECT\' and (SerialNumber__c=\'' + escapedKeyword + '\' or SBQQ__Product__r.Model__c like \'' + maskKeyword + '\' or SBQQ__Product__r.Name like \'' + maskKeyword + '\' or Customer_Notes__c like \'' + maskKeyword + '\')';        
        result += ' limit 10000';
        
        System.debug(result);
        return result;
    }
    protected override string BuildSubQuery()
    {
       	String query = '';
        query = 'Select Id,SBQQ__Product__r.Name,SBQQ__Product__r.Product_Type__c,SBQQ__Account__r.Name,SBQQ__StartDate__c,SBQQ__Contract__r.EndDate,Customer_Notes__c,SBCF_Subscription_Status__c,SerialNumber__c,SBQQ__Product__r.Family,SBQQ__Product__r.Model__c from SBQQ__Subscription__c';
        query += ' where (SBQQ__Product__r.Name like \'EC%\') and SBCF_Subscription_Status__c in(\'Customer Subscription Active\',\'Customer Subscription Expired\') and SBQQ__Product__r.Product_Type__c = \'EDGECONNECT\'';
        query += ' limit 10000';
        System.debug(query);
        return query;
    }
    protected override  List<PortalDataWrapper> BuildData(List<Asset> lstAssetData,List<SBQQ__Subscription__c> lstSubscriptions)
    {
        System.debug('lstAssetData'+lstAssetData);
        System.debug('lstSubData'+lstSubscriptions);
        List<PortalDataWrapper> lstData= new List<PortalDataWrapper>();
        if(lstSubscriptions!=null && lstSubscriptions.size()>0)
        {
            
            for(SBQQ__Subscription__c item:lstSubscriptions)
            {
                PortalDataWrapper data= new PortalDataWrapper();
                data.SerialNumber= item.SerialNumber__c;
                data.RecordId= item.Id;
                data.AccountName= item.SBQQ__Account__r.Name;
                data.ProductName= item.SBQQ__Product__r.Name;
                data.Status= item.SBCF_Subscription_Status__c;
                data.ProductType= item.SBQQ__Product__r.Product_Type__c;
                data.ProductFamily= item.SBQQ__Product__r.Family;
                data.Model= item.SBQQ__Product__r.Model__c;
                data.CustomerNotes= item.Customer_Notes__c;
                data.ShipDate=item.SBQQ__StartDate__c;
                data.LicenseEndDate= item.SBQQ__Contract__r.EndDate;
                lstData.add(data);
            }
        }
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
                data.ShipDate=item.Ship_Date__c;
                data.LicenseEndDate= item.Status=='Customer Subscription Active'? item.SBQQ__CurrentSubscription__r.SBQQ__SubscriptionEndDate__c:null;
                data.ContractEndDate= item.Status=='Customer Owned'? item.SBQQ__CurrentSubscription__r.SBQQ__SubscriptionEndDate__c:null;
                data.WarrantyEndDate= item.Status=='Customer Owned'? item.Warranty_End_Date__c:null;
                data.WarrantyStartDate= item.Status=='Customer Owned'? item.Warranty_Start_Date__c:null;
                data.EndOfMaintenance= item.Status=='Customer Owned'? item.End_of_Maintenance__c:null;
                lstData.add(data);
            }
        }
        System.debug('lstData'+ lstData );
        return lstData;
    }
    
    
    
    
}