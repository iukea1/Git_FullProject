public class Conversion_CustomerQuotesGeneration {

    
    public static void ConvertQuotes()
    {
        Id DraftRT='0120x0000000De9';
        Id ApprovedRT='0120x0000000Df7';
        ID SubmittedRT='0120x0000000Df2';
        Map<string, Id> mapRenewalProductIds= new Map<string,Id>();
        Map<string, Id> mapSubsAssetProductIds= new Map<string,Id>();
        List<SBQQ__Quote__c> lstQuotes= new List<SBQQ__Quote__c>();
           List<Quote__c> lstOldQuotes= new List<Quote__c>();
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        Map<Id,Quote__c> lstSPQuotes= new Map<Id,Quote__c>([Select Id,Name,Quote_Name__c,PaymentTerm__c,Shipping_Postal_Code__c,Shipping_Address__c,Approval_Status__c,Opportunity__r.Account.ECSP__c,
                                    	Opportunity__c,Opportunity__r.Type,Opportunity__r.PriceBook2Id, Quote_Valid_Until__c,Tier_1_Partner__c,Tier_2_Partner__c,Tier_3_Partner__c,
                                    	Special_Instructions__c,Quote_Date__c,PreparedFor__c,Primary__c,Discount_Justification__c,
                                    	Ship_To_City__c,Ship_To_Country__c,Ship_To_Zip__c,Ship_To_State__c,Ship_To_Address__c,Approval_Level_Needed__c
                                    from Quote__c where Convert_to_CPQ__c=true and Converted__c=false LIMIT 200]);
        List<Product2> lstValidProducts= [Select Id, Name,ProductCode,SBQQ__RenewalProduct__c from Product2 where IsActive=true and isQuotable__c=true ];
        if(!lstValidProducts.isEmpty())
        {
             for(Product2 prod: lstValidProducts)
             {
                 mapRenewalProductIds.put(prod.ProductCode,prod.SBQQ__RenewalProduct__c);
                 mapSubsAssetProductIds.put(prod.ProductCode,prod.Id);
             }
        }
        if(!lstSPQuotes.isEmpty())
        {
            List<Quote_Line__c> lstSPQuotesLines=[Select Quote__c,ID,Name,Product__r.Family,Product__c,Product__r.Name,Product__r.ProductCode,Product__r.SBQQ__RenewalProduct__c,Quantity__c,Discount_Percent__c,ApprovalLevel__c,Product_Quote_Type__c from Quote_Line__c where Quote__c in:lstSPQuotes.keyset()];
            for(Quote__c quote: lstSPQuotes.values())
            {
                SBQQ__Quote__c cpqQuote= new SBQQ__Quote__c();
                cpqQuote.Quote_Name__c=quote.Quote_Name__c;
                cpqQuote.SBQQ__ExpirationDate__c=quote.Quote_Valid_Until__c;
                cpqQuote.SBQQ__PaymentTerms__c=quote.PaymentTerm__c;
                if(quote.Approval_Status__c=='Approved')
                    cpqQuote.ApprovalStatus__c='Pending Review';
                else if(quote.Approval_Status__c=='Pending')
                    cpqQuote.ApprovalStatus__c='Draft';
                else
                    cpqQuote.ApprovalStatus__c=quote.Approval_Status__c;
                cpqQuote.SBQQ__Opportunity2__c=quote.Opportunity__c;
                cpqQuote.SBQQ__EndDate__c=quote.Quote_Valid_Until__c;
                cpqQuote.Reseller_Partner__c=quote.Tier_1_Partner__c;
                cpqQuote.Distributor_Partner__c=quote.Tier_2_Partner__c;
                cpqQuote.Tier_3_Partner__c=quote.Tier_3_Partner__c;
                cpqQuote.Special_Instructions__c=quote.Special_Instructions__c;
                cpqQuote.SBQQ__StartDate__c=quote.Quote_Date__c;
                //cpqQuote.Prepared_For__c=quote.PreparedFor__c;
                cpqQuote.SBQQ__Primary__c=quote.Primary__c;
                cpqQuote.Discount_Justification__c=quote.Discount_Justification__c;
                cpqQuote.SBQQ__ShippingCity__c=quote.Ship_To_City__c;
                cpqQuote.SBQQ__ShippingCountry__c=quote.Ship_To_Country__c;
                cpqQuote.SBQQ__ShippingPostalCode__c=quote.Shipping_Postal_Code__c;
                cpqQuote.SBQQ__ShippingState__c=quote.Ship_To_State__c;
                cpqQuote.SBQQ__ShippingStreet__c=quote.Shipping_Address__c;
                cpqQuote.SBQQ__WatermarkShown__c=quote.Approval_Status__c=='Approved'?false:true;
                cpqQuote.SBQQ__Type__c='Quote';
                cpqQuote.Quote_External_Id__c=quote.Name;
                cpqQuote.Silver_Peak_Quote__c=quote.Id;
                cpqQuote.Product_Type__c='EDGECONNECT';
                if(quote.Approval_Status__c=='Approved')
                    cpqQuote.RecordTypeId=ApprovedRT;
                else if(quote.Approval_Status__c=='Submitted')
                    cpqQuote.RecordTypeId=SubmittedRT;
                else
                    cpqQuote.RecordTypeId=DraftRT;
                cpqQuote.SBQQ__PriceBook__c=quote.Opportunity__r.PriceBook2Id;
                lstQuotes.add(cpqQuote);
                lstOldQuotes.add(new Quote__c(Id=quote.id,Converted__c=true));
                SBQQ__Quote__c quoteRef= new SBQQ__Quote__c(Quote_External_Id__c=quote.Name);
                if(!lstSPQuotesLines.isEmpty())
                {
                    for(Quote_Line__c quoteLine: lstSPQuotesLines)
                    {
                        if(quoteLine.Quote__c==quote.Id)
                        {
                            SBQQ__QuoteLine__c cpqQl= new SBQQ__QuoteLine__c();
                            cpqQl.SBQQ__Product__c=quoteLine.Product__c;
                            cpqQl.SBQQ__Quantity__c=quoteLine.Quantity__c;
                            cpqQl.Additional_Discount__c=quoteLine.Discount_Percent__c;
                            cpqQl.Level__c=quoteLine.ApprovalLevel__c;
                            cpqQl.SBQQ__Quote__r=quoteRef;
                            cpqQl.QL_Ext_Id__c=quoteLine.Name;
                            if(quoteLine.Product_Quote_Type__c=='EDGECONNECT' && quoteLine.Product__r.Family=='Virtual Image' && !quoteLine.Product__r.Name.contains('MO'))
                            {
                                cpqQl.SBQQ__StartDate__c=quote.Quote_Date__c;
                                string productName=quoteLine.Product__r.Name;
                                integer yearD=Integer.valueOf(productName.substring(productName.length()-2, productName.length()-1));
                                cpqQl.SBQQ__EndDate__c=quote.Quote_Date__c.addyears(yearD).addDays(-1);
                            }
                            lstQuoteLines.add(cpqQl);
                        }
                    }
                }

            }
            SObject[] sobjList = new List<SObject>();
            sobjList.addAll(lstQuotes);
            sobjList.addAll(lstQuoteLines);
            Database.SaveResult[] lsr = Database.insert(sobjList,true);
            boolean isSuccessful=false;
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('QuoteCreation  Successful');
                    isSuccessful=true;
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Data affected this error: ' + err.getFields());
                    }
                }   
            }
            if(isSuccessful)
            {
                update lstOldQuotes;
                
            }
          
            
        }  
    }
    
    
    public static void CreateECContracts()
    {
        List<contract> lstContractsToCreate= new List<Contract>();
        List<SBQQ__Subscription__c> lstSubscriptions= new List<SBQQ__Subscription__c>();
        List<Asset> lstAssetsToUpdate= new List<Asset>();
        List<AggregateResult> lstECAssets=[Select AccountId, License_End_Date__c, Min(Ship_Date__c)ShipDate from Asset where Convert_to_CPQ__c=true and Converted__c=false and License_End_Date__c!=null and Product_Quote_Type__c='EDGECONNECT' 
                                           	GROUP BY AccountId, License_End_Date__c order by AccountId ];
        List<Asset> lstAssets=[Select id, SerialNumber,Name,AccountId,Product2Id,Quantity,Product2.Name,Bandwidth_Nodes__c,Licenses_Nodes__c, License_End_Date__c from Asset where Convert_to_CPQ__c=true and Converted__c=false and License_End_Date__c!=null  and Product_Quote_Type__c='EDGECONNECT'  ];
        
        if(!lstECAssets.isEmpty())
        {
            integer counter=1;
            for(AggregateResult ar:lstECAssets)
            {
                Date shipDate= Date.valueOf(ar.get('ShipDate'));
                Date endDate= Date.valueOf(ar.get('License_End_Date__c'));
                integer months= shipDate.monthsBetween(endDate);
                Id accId= (Id)ar.get('AccountId');
                string extid=accid+'-'+'EC'+counter;
                lstContractsToCreate.add( new Contract(StartDate=shipDate, EndDate=endDate,AccountId=accId,ContractTerm=months,Contract_External_Id__c=extid,LegacyContractType__c='EDGECONNECT'));
                
                if(!lstAssets.isEmpty())
                {
                    for(Asset assetInfo:lstAssets)
                    {
                        if(assetInfo.AccountId==accId && assetInfo.License_End_Date__c==endDate)
                        {
                            SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SerialNumber__c=assetInfo.SerialNumber,SBQQ__Account__c=assetInfo.AccountId,SBQQ__Product__c=assetInfo.Product2Id,Subscription_External_Id__c=assetInfo.Name+'-'+extid, SBQQ__SubscriptionStartDate__c=shipDate);
                            if(assetInfo.Product2.Name.contains('BASE') || assetInfo.Product2.Name.contains('MINI')||assetInfo.Product2.Name.contains('PLUS'))
                                sub.SBQQ__Quantity__c=assetInfo.Licenses_Nodes__c;
                            else if(assetInfo.Product2.Name.contains('BOOST'))
                                sub.SBQQ__Quantity__c=assetInfo.Bandwidth_Nodes__c;
                            else
                                sub.SBQQ__Quantity__c=assetInfo.Quantity;
                            
                            lstAssetsToUpdate.add(new Asset(Id=assetInfo.Id,Status='Converted to Subscription',Converted__c=true));
                            lstSubscriptions.add(sub);
                        }
                        
                    }
                }
              counter++;
            }
            
            SObject[] sobjList = new List<SObject>();
            sobjList.addAll(lstContractsToCreate);
            sobjList.addAll(lstSubscriptions);
            Database.SaveResult[] lsr = Database.insert(sobjList,true);
            boolean isSuccessful=false;
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('  Successful');
                    for(Contract con:lstContractsToCreate)
                    {
                        string conextId=con.Contract_External_Id__c;
                         for(SBQQ__Subscription__c sub:lstSubscriptions)
                         {
                             string subExtId=sub.Subscription_External_Id__c;
                             string updExtId=subExtId.substringAfter('-');
                             if(updExtId==conExtId)
                             {
                                 sub.SBQQ__Contract__c=con.Id;
                             }
                         }
                    }
                    update lstSubscriptions;
                    isSuccessful=true;
                    
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Data affected this error: ' + err.getFields());
                        
                    }
                }   
            }
            if(isSuccessful)
            {
                update lstAssetsToUpdate;
                
            }
        }
    }
    
    public static void CreateSubscriptionContracts()
    {
        List<contract> lstContractsToCreate= new List<Contract>();
        List<SBQQ__Subscription__c> lstSubscriptions= new List<SBQQ__Subscription__c>();
        List<SBQQ__SubscribedAsset__c> lstSubscribedAssets= new List<SBQQ__SubscribedAsset__c>();
        List<Asset> lstAssetsToUpdate= new List<Asset>();
        List<AggregateResult> lstNXVXAssets=[Select AccountId, License_End_Date__c, Min(Ship_Date__c)ShipDate from Asset where Convert_to_CPQ__c=true and Converted__c=false and License_End_Date__c!=null  and Product_Quote_Type__c='NX/VX' 
                                           	GROUP BY AccountId, License_End_Date__c order by AccountId ];
        List<Asset> lstAssets=[Select id, SerialNumber,Name,AccountId,Product2Id,Quantity,Product2.Name,Bandwidth_Nodes__c,Licenses_Nodes__c, License_End_Date__c from Asset where Convert_to_CPQ__c=true and Converted__c=false and License_End_Date__c!=null and Product_Quote_Type__c='NX/VX'  ];
        Map<string,Id> mapSubAssetProd= new Map<string,Id>();
        Map<Id,Product2> mapProduct2= new Map<Id,Product2>([Select Id,Name from Product2 where IsActive=true and IsQuotable__c=true and Name like '%(Asset)%']);
        for(Product2 prodId:mapProduct2.values())
            {
                mapSubAssetProd.put(prodId.Name,prodId.Id);
            }
        if(!lstNXVXAssets.isEmpty())
        {
            integer counter=1;
            for(AggregateResult ar:lstNXVXAssets)
            {
                Date shipDate= Date.valueOf(ar.get('ShipDate'));
                Date endDate= Date.valueOf(ar.get('License_End_Date__c'));
                Id accId= (Id)ar.get('AccountId');
                string extid=accid+'-'+'SUB'+counter;
                lstContractsToCreate.add( new Contract(StartDate=shipDate, EndDate=endDate,AccountId=accId,Contract_External_Id__c=extid,LegacyContractType__c='NX/VX'));
                
                if(!lstAssets.isEmpty())
                {
                    for(Asset assetInfo:lstAssets)
                    {
                        if(assetInfo.AccountId==accId && assetInfo.License_End_Date__c==endDate)
                        {
                            Id assetProdId=mapSubAssetProd.get(assetInfo.Product2.Name+' (Asset)');
                            SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SerialNumber__c=assetInfo.SerialNumber,SBQQ__Quantity__c=assetInfo.Quantity,SBQQ__Account__c=assetInfo.AccountId,SBQQ__Product__c=assetInfo.Product2Id,Subscription_External_Id__c=assetInfo.Name+'-'+extid, SBQQ__SubscriptionStartDate__c=shipDate);
                            lstAssetsToUpdate.add(new Asset(Id=assetInfo.Id,Product2Id=assetProdId,Converted__c=true));
                            SBQQ__Subscription__c subRef= new SBQQ__Subscription__c(Subscription_External_Id__c=assetInfo.Name);
                            SBQQ__SubscribedAsset__c subAsset= new SBQQ__SubscribedAsset__c(SBQQ__Asset__c=assetInfo.Id,SBQQ__Subscription__r=subRef,SBQQ__Active__c=true);
                            lstSubscriptions.add(sub);
                            lstSubscribedAssets.add(subAsset);
                        }
                    }
                }
                counter++;
            }
            SObject[] sobjList = new List<SObject>();
            sobjList.addAll(lstContractsToCreate);
            sobjList.addAll(lstSubscriptions);
            sobjList.addAll(lstSubscribedAssets);
            Database.SaveResult[] lsr = Database.insert(sobjList,true);
            boolean isSuccessful=false;
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('  Successful');
                    for(Contract con:lstContractsToCreate)
                    {
                        string conextId=con.Contract_External_Id__c;
                         for(SBQQ__Subscription__c sub:lstSubscriptions)
                         {
                             string subExtId=sub.Subscription_External_Id__c;
                             string updExtId=subExtId.substringAfter('-');
                             if(updExtId==conExtId)
                             {
                                 sub.SBQQ__Contract__c=con.Id;
                             }
                         }
                    }
                    update lstSubscriptions;
                    isSuccessful=true;
                    
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Data affected this error: ' + err.getFields());
                    }
                }   
            }
            if(isSuccessful)
            {
                update lstAssetsToUpdate;
                
            }
        }
        
    }
    public static void CreatePerpetualContracts()
    {
        List<contract> lstContractsToUpdate= new List<Contract>();
        List<SBQQ__Subscription__c> lstSubscriptions= new List<SBQQ__Subscription__c>();
        List<SBQQ__SubscribedAsset__c> lstSubscribedAssets= new List<SBQQ__SubscribedAsset__c>();
        List<Asset> lstAssetsToUpdate= new List<Asset>();
        
        Set<Id> setContracts= new Set<Id>();
        List<Asset> lstAssets=[Select id,SerialNumber,Product2.Model__c,Contract_Number__c,Contract_Number__r.Contract_Type__c,Contract_Number__r.StartDate, Name,AccountId,Product2Id,Quantity,Product2.Name,Product2.Description,Bandwidth_Nodes__c,Licenses_Nodes__c, License_End_Date__c from Asset where Convert_to_CPQ__c=true and Converted__c=false and License_End_Date__c!=null and Product_Quote_Type__c='NX/VX'  ];
        Map<string,Id> mapSubAssetProd= new Map<string,Id>();
        Map<Id,Product2> mapProduct2= new Map<Id,Product2>([Select Id,Name,Model__c,Description from Product2 where IsActive=true and IsQuotable__c=true and Family='Service' and SBQQ__RenewalProduct__c!=null and Name like'%ADJ%']);
        for(Product2 prodId:mapProduct2.values())
            {
                mapSubAssetProd.put(prodId.Description.substringAfter('-')+prodId.Model__c,prodId.Id);
            }
        
                if(!lstAssets.isEmpty())
                {
                    for(Asset assetInfo:lstAssets)
                    {
                       		setContracts.add(assetInfo.Contract_Number__c);
                            string subProd= assetInfo.Contract_Number__r.Contract_Type__c.toUpperCase()+assetInfo.Product2.Model__c;
                            Id prodId=mapSubAssetProd.get(subProd);
                            lstAssetsToUpdate.add(new Asset(Id=assetInfo.Id,Converted__c=true));
                            SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SerialNumber__c=assetInfo.SerialNumber,SBQQ__Quantity__c=assetInfo.Quantity,SBQQ__Account__c=assetInfo.AccountId,SBQQ__Product__c=prodId,Subscription_External_Id__c=assetInfo.Name,SBQQ__SubscriptionStartDate__c=assetInfo.Contract_Number__r.StartDate);
                            SBQQ__Subscription__c subRef= new SBQQ__Subscription__c(Subscription_External_Id__c=assetInfo.Name);
                            SBQQ__SubscribedAsset__c subAsset= new SBQQ__SubscribedAsset__c(SBQQ__Asset__c=assetInfo.Id,SBQQ__Subscription__r=subRef,SBQQ__Active__c=true);
                            lstSubscriptions.add(sub);
                            lstSubscribedAssets.add(subAsset);
                        
                    }
                }
            
            SObject[] sobjList = new List<SObject>();
            sobjList.addAll(lstSubscriptions);
         	sobjList.addAll(lstSubscribedAssets);
            Database.SaveResult[] lsr = Database.insert(sobjList,true);
            boolean isSuccessful=false;
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    isSuccessful=true;
                   
                    if(!setContracts.isempty())
                    {
                        for(Id conId:setContracts)
                        {
                            lstContractsToUpdate.add(new Contract(Id=conId,LegacyContractType__c='NX/VX'));
                        }
                    }
                    update lstContractsToUpdate;
                    update lstAssetsToUpdate;
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Data affected this error: ' + err.getFields());
                    }
                }   
            }
        }
    
    
}