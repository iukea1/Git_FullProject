public class SBQQSubscriptionDataController {
    public ID ContractId{get;set;}
    public ID QuoteId{get;set;}
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
    
    public  SBQQSubscriptionDataController() {  }
    
    
public List<AssetWrapper> lstOrderAssetView
    {
        get
        {
            
            List<AssetWrapper> lstData=new List<AssetWrapper>();
            if(OrderId!=null)
            {
                System.debug('OrderType'+OrderType);
                Map<Id,Contract> lstContract= new Map<Id,Contract>([Select Id from Contract where SBQQ__Order__c=:OrderId]);
                if(lstContract!=null && lstContract.size()>0)
                {
                    List<SBQQ__Subscription__c> lstSubsData=null;
                    if(OrderType!='')
                    	lstSubsData=[Select Id,SBQQ__Product__r.Name,SerialNumber__c,SBQQ__Contract__r.Product_Type__c,SBQQ__Product__r.Family,(Select SBQQ__Asset__r.SBQQ__CurrentSubscription__r.SBQQ__Contract__r.EndDate,SBQQ__Asset__r.SBQQ__CurrentSubscription__r.SBQQ__Product__r.Description,SBQQ__Asset__r.Product2.Name,SBQQ__Asset__r.SerialNumber,SBQQ__Asset__r.License_End_Date__c,SBQQ__Asset__r.GMS_Nodes__c from SBQQ__SubscribedAssets__r where SBQQ__Active__c=true) from SBQQ__Subscription__c where SBQQ__ProductName__c like : OrderType +'%' and  SBQQ__Contract__c in:lstContract.keySet() ];
                    else
                        lstSubsData=[Select Id,SBQQ__Product__r.Name,SerialNumber__c,SBQQ__Contract__r.Product_Type__c,SBQQ__Product__r.Family,(Select SBQQ__Asset__r.SBQQ__CurrentSubscription__r.SBQQ__Contract__r.EndDate,SBQQ__Asset__r.SBQQ__CurrentSubscription__r.SBQQ__Product__r.Description,SBQQ__Asset__r.Product2.Name,SBQQ__Asset__r.SerialNumber,SBQQ__Asset__r.License_End_Date__c,SBQQ__Asset__r.GMS_Nodes__c from SBQQ__SubscribedAssets__r where SBQQ__Active__c=true) from SBQQ__Subscription__c where SBQQ__Contract__c in:lstContract.keySet() ];
                    if(lstSubsData!=null && lstSubsData.size()>0)
                    {
                        for(SBQQ__Subscription__c item: lstSubsData)
                        {
                            
                            if(item.SBQQ__SubscribedAssets__r!=null && item.SBQQ__SubscribedAssets__r.size()>0)
                            {
                                for(SBQQ__SubscribedAsset__c subAssetData: item.SBQQ__SubscribedAssets__r)
                                {
                                    System.debug(subAssetData.SBQQ__Asset__r.GMS_Nodes__c);
                                    string productName=subAssetData.SBQQ__Asset__r.Product2.Name;
                                    string productDesc='N/A';
                                    if(subAssetData.SBQQ__Asset__r.Product2.Name.contains('Asset'))
                                        productName=productName.remove('(Asset)');
                                    if(subAssetData.SBQQ__Asset__r.SBQQ__CurrentSubscription__r.SBQQ__Product__r.Description!=null &&(subAssetData.SBQQ__Asset__r.SBQQ__CurrentSubscription__r.SBQQ__Product__r.Description.contains('PLATINUM') || subAssetData.SBQQ__Asset__r.SBQQ__CurrentSubscription__r.SBQQ__Product__r.Description.contains('GOLD')))
                                        productDesc=subAssetData.SBQQ__Asset__r.SBQQ__CurrentSubscription__r.SBQQ__Product__r.Description;
                                    
                                    lstData.add(new AssetWrapper(productName,subAssetData.SBQQ__Asset__r.SerialNumber,subAssetData.SBQQ__Asset__r.License_End_Date__c,subAssetData.SBQQ__Asset__r.GMS_Nodes__c,productDesc,subAssetData.SBQQ__Asset__r.SBQQ__CurrentSubscription__r.SBQQ__Contract__r.EndDate));
                                    
                                }
                            } 
                        }
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
            List<SBQQ__Subscription__c> lstSubsData=[Select Id,SBQQ__Product__r.Name,SerialNumber__c,SBQQ__Contract__r.Product_Type__c,SBQQ__Product__r.Family,(Select SBQQ__Asset__r.Product2.Name,SBQQ__Asset__r.SerialNumber,SBQQ__Asset__r.GMS_Nodes__c,SBQQ__Asset__r.License_End_Date__c from SBQQ__SubscribedAssets__r where SBQQ__Active__c=true) from SBQQ__Subscription__c where SBQQ__Contract__c=:ContractId ];
            if(lstSubsData!=null && lstSubsData.size()>0)
            {
                for(SBQQ__Subscription__c item: lstSubsData)
                {
                    if(item.SBQQ__Contract__r.Product_Type__c=='EDGECONNECT')
                        lstData.add(new AssetWrapper(item.SBQQ__Product__r.Name,item.SerialNumber__c,null,null));
                    else
                    {
                        if(item.SBQQ__SubscribedAssets__r!=null && item.SBQQ__SubscribedAssets__r.size()>0)
                        {
                            for(SBQQ__SubscribedAsset__c subAssetData: item.SBQQ__SubscribedAssets__r)
                            {
                                lstData.add(new AssetWrapper(subAssetData.SBQQ__Asset__r.Product2.Name,subAssetData.SBQQ__Asset__r.SerialNumber,subAssetData.SBQQ__Asset__r.License_End_Date__c,subAssetData.SBQQ__Asset__r.GMS_Nodes__c));
                                
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
    
    public List<AssetWrapper> lstAssetWrapperQuote{
    get
    {
        List<AssetWrapper> lstData=new List<AssetWrapper>();
        if(QuoteId!=null)
        {
            System.debug('QuoteId'+ QuoteId);
            List<SBQQ__Subscription__c> lstSubsData=[Select Id,SBQQ__Product__r.Name,SerialNumber__c,SBQQ__Contract__r.Product_Type__c,SBQQ__Product__r.Family,(Select SBQQ__Asset__r.Product2.Name,SBQQ__Asset__r.SerialNumber,SBQQ__Asset__r.GMS_Nodes__c,SBQQ__Asset__r.License_End_Date__c from SBQQ__SubscribedAssets__r where SBQQ__Active__c=true) from SBQQ__Subscription__c where SBQQ__Contract__c in(Select Id from Contract where SBQQ__Quote__c =:QuoteId) ];
            if(lstSubsData!=null && lstSubsData.size()>0)
            {
                for(SBQQ__Subscription__c item: lstSubsData)
                {
                    if(item.SBQQ__Contract__r.Product_Type__c=='EDGECONNECT')
                        lstData.add(new AssetWrapper(item.SBQQ__Product__r.Name,item.SerialNumber__c,null,null));
                    else
                    {
                        if(item.SBQQ__SubscribedAssets__r!=null && item.SBQQ__SubscribedAssets__r.size()>0)
                        {
                            for(SBQQ__SubscribedAsset__c subAssetData: item.SBQQ__SubscribedAssets__r)
                            {
                                lstData.add(new AssetWrapper(subAssetData.SBQQ__Asset__r.Product2.Name,subAssetData.SBQQ__Asset__r.SerialNumber,subAssetData.SBQQ__Asset__r.License_End_Date__c,subAssetData.SBQQ__Asset__r.GMS_Nodes__c));
                                
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


public class AssetWrapper
{
    public string ProductName {get;private set;}
    public string SerialNumber {get;private set;}
    public Date LicenseEndDate {get;private set;}
    public string GmsQuantity {get;private set;}
    public string ProdDesc {get;private set;}
    public Date ConEndDate {get;private set;}
    public AssetWrapper(string prodName,String sn,Date licEndDate,string gmsNodes)
    {
        System.debug('1');
        System.debug(gmsNodes);
        ProductName=prodName;
        SerialNumber=sn;
        LicenseEndDate=licEndDate;
        GmsQuantity=gmsNodes;
        ProdDesc='N/A';
        ConEndDate=null;
    }
     public AssetWrapper(string prodName,String sn,Date licEndDate,string gmsNodes,string description,Date contractEndDate)
    {
        System.debug('2');
         System.debug(gmsNodes);
        ProductName=prodName;
        SerialNumber=sn;
        LicenseEndDate=licEndDate;
        GmsQuantity=gmsNodes;
        ProdDesc=description;
        ConEndDate=contractEndDate;
        System.debug('final');
          System.debug(GmsQuantity);
            
    }
    
}
}