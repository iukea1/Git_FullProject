public class SBQQSubscriptionDataController {
    public ID ContractId{get;set;}
    public ID OrderId{get;set;}
    public string OrderType{get;set;}
    public List<Asset> lstVXSubAssets{
        get
        {
            List<Asset> lstData=new List<Asset>();
            if(ContractId!=null)
            {
                lstData=[Select Id, Product2.Name,SerialNumber from Asset where Product2.Product_Type__c='NX/VX' and Product2.Family='Virtual Image' and SBQQ__CurrentSubscription__c in (Select Id from SBQQ__Subscription__c where SBQQ__Contract__c=:ContractId)];
            }
            
            return lstData ;
        }
    }
    public List<AssetWrapper> lstOrderAssetView
    {
        get
        {
            List<AssetWrapper> lstData=new List<AssetWrapper>();
            if(OrderId!=null)
            {
                List<Contract> lstContract=[Select Id from Contract where SBQQ__Order__c=:OrderId];
                if(lstContract!=null && lstContract.size()>0)
                {
                    Id contractId=lstContract[0].Id;
                    List<SBQQ__Subscription__c> lstSubsData=[Select Id,SBQQ__Product__r.Name,SerialNumber__c,SBQQ__Contract__r.Product_Type__c,SBQQ__Product__r.Family,(Select SBQQ__Asset__r.Product2.Name,SBQQ__Asset__r.SerialNumber,SBQQ__Asset__r.License_End_Date__c from SBQQ__SubscribedAssets__r where SBQQ__Active__c=true and SBQQ__Asset__r.Product2.Name like : OrderType +'%') from SBQQ__Subscription__c where SBQQ__Contract__c =:contractId ];
                    if(lstSubsData!=null && lstSubsData.size()>0)
                    {
                        for(SBQQ__Subscription__c item: lstSubsData)
                        {
                            
                            if(item.SBQQ__SubscribedAssets__r!=null && item.SBQQ__SubscribedAssets__r.size()>0)
                            {
                                for(SBQQ__SubscribedAsset__c subAssetData: item.SBQQ__SubscribedAssets__r)
                                {
                                    lstData.add(new AssetWrapper(subAssetData.SBQQ__Asset__r.Product2.Name,subAssetData.SBQQ__Asset__r.SerialNumber,subAssetData.SBQQ__Asset__r.License_End_Date__c));
                                    
                                }
                            } 
                        }
                    }
                }
            }
            return lstData ;
        }
    }
    
public List<AssetWrapper> lstOrderSubView
    {
        get
        {
            List<AssetWrapper> lstData=new List<AssetWrapper>();
            if(OrderId!=null)
            {
                List<OrderItem> lstSubsData=[Select Product_Name__c,SBQQ__Subscription__r.SBQQ__SubscriptionEndDate__c from OrderItem where OrderId =:OrderId ];
                if(lstSubsData!=null && lstSubsData.size()>0)
                {
                    for(OrderItem item: lstSubsData)
                    {
                        lstData.add(new AssetWrapper(item.Product_Name__c,null,item.SBQQ__Subscription__r.SBQQ__SubscriptionEndDate__c));
                    }
                }
            }
        
        return lstData ;
    }
}
public List<AssetWrapper> lstAssetWrapper{
    get
    {
        List<AssetWrapper> lstData=new List<AssetWrapper>();
        if(ContractId!=null)
        {
            System.debug('ContractId'+ ContractId);
            List<SBQQ__Subscription__c> lstSubsData=[Select Id,SBQQ__Product__r.Name,SerialNumber__c,SBQQ__Contract__r.Product_Type__c,SBQQ__Product__r.Family,(Select SBQQ__Asset__r.Product2.Name,SBQQ__Asset__r.SerialNumber from SBQQ__SubscribedAssets__r where SBQQ__Active__c=true) from SBQQ__Subscription__c where SBQQ__Contract__c=:ContractId ];
            if(lstSubsData!=null && lstSubsData.size()>0)
            {
                for(SBQQ__Subscription__c item: lstSubsData)
                {
                    if(item.SBQQ__Contract__r.Product_Type__c=='EDGECONNECT')
                        lstData.add(new AssetWrapper(item.SBQQ__Product__r.Name,null,null));
                    else
                    {
                        if(item.SBQQ__SubscribedAssets__r!=null && item.SBQQ__SubscribedAssets__r.size()>0)
                        {
                            for(SBQQ__SubscribedAsset__c subAssetData: item.SBQQ__SubscribedAssets__r)
                            {
                                lstData.add(new AssetWrapper(subAssetData.SBQQ__Asset__r.Product2.Name,subAssetData.SBQQ__Asset__r.SerialNumber,null));
                                
                            }
                        } 
                    }
                }
            }
            
        }
        System.debug(lstData);
        return lstData ;
    }
}
public SBQQSubscriptionDataController()
{
    
}

public class AssetWrapper
{
    public string ProductName {get;private set;}
    public string SerialNumber {get;private set;}
    public Date LicenseEndDate {get;private set;}
    public AssetWrapper(string prodName,String sn,Date licEndDate)
    {
        ProductName=prodName;
        SerialNumber=sn;
        LicenseEndDate=licEndDate;
    }
}
}