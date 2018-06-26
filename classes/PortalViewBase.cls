public with sharing abstract class PortalViewBase {
    public List<AccountInfo> AccountKeyList{get;set;}
    public Set<String> models;
    public string SearchParameter{get;set;}
    public boolean IsSearchForActive{get;set;}
    public List<PortalDataWrapper> lstResults{get;set;}
    public Integer PageNumber { get; protected set; }
    public Integer PageCount { get; protected set; }
    public String SearchAsset { get; set; }
    public String SortFunction { get; set; }
    public String FieldName { get; set; } 
    public String PreviousFieldName { get; set; } 
    public Double PAGE_SIZE = 50.0; //The number of records on each page.
    public String sortField = '';
    
    public Boolean HasNext
    {
        get
        {
            return  PageNumber < PageCount - 1;
        }
    }
    
    public void initSort()
    {
        FieldName = 'ProductName';
        PreviousFieldName=FieldName;
        SortFunction = 'asc';
    }
    
    protected void InitiateAccountNameKey()
    {
        List<User> lstUser=  [Select Id , Name, ProfileId,UserType,Contact.Account.Name,Contact.AccountId from User where Id=:UserInfo.getUserId()];
        
        if(lstUser!=null && lstUser.size()>0)
        {
            AccountKeyList = new List<AccountInfo>();
            List<Account> lstAccount=null;
            
            lstAccount=[Select Id,Name,Cloud_Portal_Account_Key__c,Cloud_Portal_Account_Name__c from Account where Id=:lstUser[0].Contact.AccountId ];
            
            if(lstAccount!=null && lstAccount.size()>0)
            {
                for(Account acc: lstAccount)
                {
                    AccountInfo acctInfo=new AccountInfo();
                    acctInfo.AccountKey=acc.Cloud_Portal_Account_Key__c;
                    acctInfo.ProductName='EC';
                    acctInfo.AccountName=string.isBlank(acc.Cloud_Portal_Account_Name__c)?acc.Name:acc.Cloud_Portal_Account_Name__c;
                    AccountKeyList.add(acctInfo);
                }
                
            }
        }
    }
    
    protected List<PortalDataWrapper> doQuery()
    {
        List<Asset> allAssetRecords= new List<Asset>();
        List<SBQQ__Subscription__c> allSubRecords= new List<SBQQ__Subscription__c>();
        String query='';
        System.debug('SearchParameter'+ SearchParameter);
        System.debug('IsSearchForActive'+ IsSearchForActive);
        if((String.isNotBlank(SearchParameter) && SearchParameter.length() >= 2)|| IsSearchForActive)
        {
            System.debug('In Search');
            query = BuildAssetSearch();
            if(query!='')
                allAssetRecords = Database.query(query);
            query = BuildSubSearch();
            if(query!='')
                allSubRecords = Database.query(query);
            
        }
        else
        {
            query = BuildAssetQuery();
            if(query!='')
                allAssetRecords = Database.query(query);
            query = BuildSubQuery();
            if(query!='')
                allSubRecords = Database.query(query);
            
        }
        return BuildData(allAssetRecords,allSubRecords); 
    }
    
    
    public virtual PageReference  saveAsset()
    {
        try
        {
            List<Asset> lstAsset= new List<Asset>();
            InternalAssetUpdator updator = new InternalAssetUpdator();
            if(lstResults!=null && lstResults.size()>0)
            {
                for(PortalDataWrapper data: lstResults)
                {
                    if(data.OldCustomerNotes!=data.CustomerNotes)
                        updator.addAsset(data.RecordId, data.CustomerNotes);
                    
                }
                updator.save();
            
            }
            
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    public PageReference previous()
    {
        PageNumber = Math.max(PageNumber - 1, 0);
        loadData();
        return null;
    }
    
    
    public PageReference next()
    {
        PageNumber++;
        loadData();
        return null;
    }
    
    public PageReference searchAssets()
    {
        System.debug('isSearchforactive' + IsSearchForActive);
        loadData();
        PageNumber = 0;
        return null;
    }
    
    public PageReference sortTable()
    {
        FieldName = Apexpages.currentPage().getParameters().get('fieldName');
        searchAssets();
        if(PreviousFieldName == FieldName){
            SortFunction='desc';
            PreviousFieldName=null;
        }
        else{
            SortFunction='asc';            
            PreviousFieldName=FieldName;
        }
        System.debug('sortableField:::'+FieldName);
        System.debug('sortOrder::'+SortFunction);
        PortalDataWrapper.sortableField = FieldName;
        PortalDataWrapper.sortorder = SortFunction; 
        System.debug('lstResults' +lstResults);
        lstResults.sort();
        return null;
    }
    public PageReference sendListToCurrentUser()
    {
        try
        {
            sendAssetsToCurrentUser(getAssetsCSV());
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    public virtual void SendAssetsToCurrentUser(String assetCSV)
    {
        User currentUser = [select Email from User where Id = :UserInfo.getUserId()];
        String targetEmail = currentUser.Email;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Silver Peak Customer Portal:Your Asset List');
        mail.setPlainTextBody('Use attached spreadsheet to view and update the customer notes. Reply with the updated spreadsheet to batch update.\r\n\r\n');
        mail.setToAddresses(new String[] {targetEmail});
        
        OrgWideEmailAddress orgId=[select id, Address,DisplayName from OrgWideEmailAddress where DisplayName='Silver Peak Notifications' LIMIT 1];
        mail.setOrgWideEmailAddressId(orgId.Id);
        mail.setReplyTo(getEmailServiceAddress());
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName('Assets.csv');
        efa.setBody(Blob.valueOf(assetCSV));
        efa.setContentType('application/csv');
        mail.setFileAttachments(new List<Messaging.Emailfileattachment>{efa});
        try
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'An email has been sent to your email address [' + targetEmail + ']'));
            
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            
        }
    }
    
    private String getEmailServiceAddress()
    {
        
        String address = '';
        if(SilverPeakUtils.IsProduction())
        {
            address='spdataloader@5feojp8e8w1xl9fm32xtndfpp.3-byveaq.na3.apex.salesforce.com';
        }
        else
        {
            List<EmailServicesAddress> emailServices = [select LocalPart, EmailDomainName from EmailServicesAddress where IsActive=true and Function.FunctionName = 'Asset List Editor'];
            if(emailServices.size() > 0)
            {
                address = emailServices[0].LocalPart + '@' + emailServices[0].EmailDomainName;
            }
        }
        return address;
    }
    
    private String getAssetsCSV()
    {
        String csvBody = '';
        String csvHeader = 'Id,Product Name,Serial Number,';
        csvHeader += 'License Date,';
        csvHeader += 'Ship Date,';
        csvHeader += 'Warranty End Date,';
        csvHeader += 'Customer Notes\r';
        
        transient List<PortalDataWrapper> allAssetsToExport = doQuery();
        if(allAssetsToExport.size() > 0)
        {
            for(PortalDataWrapper item : allAssetsToExport)
            {
                Schema.DescribeSObjectResult r= item.RecordId.getsobjecttype().getDescribe();
                if(r.getName()=='Asset')
                {
                    csvBody += escapeCsvCell(item.RecordId) + ',';
                    csvBody += escapeCsvCell(item.ProductName) + ',';
                    csvBody += escapeCsvCell(item.SerialNumber) + ',';
                    csvBody += escapeCsvCell(item.LicenseEndDate) + ',';
                    csvBody += escapeCsvCell(item.ShipDate) + ',';
                    csvBody += escapeCsvCell(item.WarrantyEndDate) + ',';
                    csvBody += escapeCsvCell(item.CustomerNotes);
                    csvBody += '\r';
                }
                
            }
        }
        return csvHeader + csvBody;
    }
    protected void loadData()
    {
        
        try
        {
            List<PortalDataWrapper> lstData=doQuery();
            System.debug(lstData);
            lstResults= new List<PortalDataWrapper>();
            if(lstData!=null && lstData.size()>0)
            {
                PageCount = Math.ceil(lstData.size() * 1.0 / PAGE_SIZE).intValue();
                for(Integer i = PageNumber * PAGE_SIZE.intValue(); i < lstData.size() && i < (PageNumber+1) * PAGE_SIZE; i++)
                {
                    PortalDataWrapper portalData= new PortalDataWrapper();
                    portalData.AccountName= lstData[i].AccountName;
                    portalData.ProductName= lstData[i].ProductName;
                    portalData.SerialNumber= lstData[i].SerialNumber;
                    portalData.RecordId= lstData[i].RecordId;
                    portalData.Status= lstData[i].Status;
                    portalData.ProductType= lstData[i].ProductType;
                    portalData.ProductFamily= lstData[i].ProductFamily;
                    portalData.Model= lstData[i].Model;
                    portalData.CustomerNotes= lstData[i].CustomerNotes;
                    portalData.Quantity= lstData[i].Quantity;
                    portalData.LicenseKey=lstData[i].LicenseKey;
                    portalData.LicenseEndDate= lstData[i].LicenseEndDate;
                    portalData.ContractEndDate= lstData[i].ContractEndDate;
                    portalData.WarrantyEndDate= lstData[i].WarrantyEndDate;
                    portalData.WarrantyStartDate= lstData[i].WarrantyStartDate;
                    portalData.EndOfMaintenance= lstData[i].EndOfMaintenance;
                    portalData.ShipDate= lstData[i].ShipDate;
                    portalData.oldCustomerNotes= lstData[i].CustomerNotes;
                    lstResults.add(portalData);
                }      
                
            }
            
        } 
        catch(Exception ex) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to query data. ' + ex.getMessage()+  ex.getStackTraceString()));
        }
    }
    private String escapeCsvCell(String value)
    {
        if(String.isBlank(value))
        {
            return '""';
        }
        else if(value.contains(',') ||value.contains('"'))
        {
            value = value.replaceAll('"', '""');
            return '"' + value + '"';
        }
        else
        {
            return value;
        }
    }
    private String escapeCsvCell(Date dateValue)
    {
        if(dateValue == null)
        {
            return '""';
        }
        else
        {
            return Datetime.newInstance(dateValue, Time.newInstance(0, 0, 0, 0)).format('M/dd/yyyy');
        }
    }
    
    private Date parseDate(String dateValue)
    {
        if(String.isNotBlank(dateValue))
        {
            try
            {
                if(dateValue.indexOf('-') > 0)
                {
                    String[] parts = dateValue.split('-');
                    return Date.newInstance(Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), Integer.valueOf(parts[2]));
                }
                else if(dateValue.indexOf('/') > 0)
                {
                    String[] parts = dateValue.split('/');
                    return Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[0]), Integer.valueOf(parts[1]));
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Incorrect date format [MM/dd/yyyy]'));
            }
        }
        return null;
    }
     protected void SetAccountNameKey()
    {
        
    }
    protected abstract string BuildAssetSearch();
    protected abstract string BuildAssetQuery();
    protected abstract string BuildSubSearch();
    protected abstract string BuildSubQuery();
    protected abstract List<PortalDataWrapper> BuildData(List<Asset> lstAssetData,List<SBQQ__Subscription__c> lstSubscriptions);
    
     public without sharing class InternalAssetUpdator
    {
        private List<Asset> assets = new List<Asset>();
        
        public void addAsset(Id assetId, String customerNotes)
        {
            assets.add(new Asset(Id=assetId, Customer_Notes__c=customerNotes));
        }
        
        public void addAsset(Id assetId, String customerNotes, Date deploymentDate, String endCustomer, String reference)
        {
            assets.add(new Asset(Id=assetId, Customer_Notes__c=customerNotes, Deployment_Date__c = deploymentDate, End_Customer__c = endCustomer, Reference__c = reference));
        }
        
        public void save()
        {
            if(assets.size() > 0)
            {
                update assets;
            }
        }
    }
    
    public class AccountInfo
    {
        public string AccountName {get;set;}
        public string ProductName {get;set;}
        public string AccountKey {get;set;}
        public AccountInfo()
        {
            
        }
        
    }
}