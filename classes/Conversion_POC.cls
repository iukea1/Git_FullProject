public class Conversion_POC {
    
    
    // Step 1
    public static void ConvertToEvalQuotes()
    {
        Id evalEnterprisePricebook='01s0x00000096Kf';
        Id evalSPPricebook='01s0x00000096Ka';
        Id evalApprovedQuoteRT='0120x0000000DfM';
        Id evalInitialQuoteRT='0120x0000000Dex';
        Map<string,Id> mapProductIds= new Map<string,Id>();
        List<Opportunity> lstOpps= new List<Opportunity>();
        List<SBQQ__Quote__c> lstQuotes= new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        List<Quote_Address__c> lstQuoteAddr= new List<Quote_Address__c>();
        List<Quote_Line_Address__c> lstQuoteLineAddr= new List<Quote_Line_Address__c>();
        List<Request__c> lstReqToUpdate= new List<Request__c>();
        Map<Id,Request__c> pocIds= new Map<Id,Request__c>();
        // Take all the POC where Convert=true
        
        List<PricebookEntry> lstPriceEntries= [Select Product2Id,Product2.Name from PricebookEntry where PriceBook2Id in('01s0x00000096Kf','01s0x00000096Ka') and IsActive=true];
        if(lstPriceEntries!=null && lstPriceEntries.size()>0)
        {
            for(PricebookEntry pr:lstPriceEntries)
                mapProductIds.put(pr.Product2.Name,pr.Product2Id);
        }
        
        List<Request__c > lstReq=[Select Id,Contract_Number__c,Actual_Ship_Date__c,Name,OwnerId,CreatedDate,Opportunity__r.Type,Opportunity__r.Deal_Type__c,Opportunity__r.CloseDate,Extension_Justification__c,Opportunity__r.RecordTypeId,Opportunity__r.StageName,Opportunity__r.OwnerId,Opportunity__r.Technical_Responsible__c,Opportunity__r.Account.ECSP__c,Opportunity__r.Patch__c,Opportunity__r.Name,RSM__c,RSM_Manager__c,RSM_VP_Sales__c,SE__c,SE_Manager__c,SE_Director__c,Account_ID__c,Opportunity__c,POC_Type__c,Target_End_Date__c,POC_Contact__c,Status__c,Problem_Criteria__c,Testing_Criteria__c,Success_Criteria__c,Project_Budget__c,International_Shipping__c,Expedited_Shipping__c,CC_List_1__c,CC_List_2__c,CC_List_3__c,CC_List_4__c,CC_List_5__c,VirtualProduct1__c, VirtualProduct2__c,VirtualProduct3__c,VirtualProduct4__c,VirtualProduct5__c ,VirtualQuantity1__c,VirtualQuantity2__c,VirtualQuantity3__c ,VirtualQuantity4__c,VirtualQuantity5__c ,PhysicalProduct1__c,PhysicalProduct3__c,PhysicalProduct2__c ,PhysicalProduct4__c,PhysicalProduct5__c ,PhysicalQuantity1__c,PhysicalQuantity2__c,PhysicalQuantity3__c,PhysicalQuantity4__c,PhysicalQuantity5__c ,EndCustomerName1__c,EndCustomerName2__c,EndCustomerName3__c,EndCustomerName4__c,EndCustomerName5__c ,PhysicalLocation1__c,PhysicalLocation2__c,PhysicalLocation3__c,PhysicalLocation4__c,PhysicalLocation5__c
                                  from Request__c where Convert_to_CPQ__c=true  and  Converted__c=false LIMIT 200];
        if(lstReq!=null && lstReq.size()>0)
        {
            for(Request__c req:lstReq)
            {
                if(req.Status__c=='Shipped'||req.Status__c=='Shipped - Extended'||req.Status__c=='Pending Return' )
                    pocIds.put(req.Id,req);
                
                Id pbId=evalEnterprisePricebook;
                if(req.Opportunity__r.Account.ECSP__c) pbId=evalSPPricebook;
                Opportunity opp= new Opportunity(CloseDate=req.Opportunity__r.CloseDate,Type='Evaluation',Deal_Type__c='Evaluation', POC_Request__c=req.Name,AccountId=req.Account_ID__c,Related_Opportunity__c=req.Opportunity__c,Name='POC for '+req.Opportunity__r.Name,POC_Opportunity__c=true,Pricebook2Id=pbId,Patch__c=req.Opportunity__r.Patch__c,OwnerId=req.Opportunity__r.OwnerId,Technical_Responsible__c=req.Opportunity__r.Technical_Responsible__c,RecordTypeId=req.Opportunity__r.RecordTypeId,StageName=req.Status__c);
                lstOpps.add(opp);
                Opportunity oppRef= new Opportunity(POC_Request__c=req.Name);
                SBQQ__Quote__c objQuote= new SBQQ__Quote__c(OwnerId=req.OwnerId,POC_Request_Ref__c=req.Id,SBQQ__Opportunity2__r=oppRef, SBQQ__StartDate__c=Date.valueOf(req.CreatedDate),POC_Contact__c=req.POC_Contact__c,Quote_External_Id__c=req.Name,POC_Status__c=req.Status__c,Product_Type__c=req.POC_Type__c,SBQQ__Primary__c=true,SBQQ__Type__c='Quote',Define_Problem__c=req.Problem_Criteria__c,Testing_Criteria__c=req.Testing_Criteria__c,Success_Criteria__c=req.Success_Criteria__c,Project_Budget__c=req.Project_Budget__c,International_Shipping__c=req.International_Shipping__c,Expedited_Shipping__c=req.Expedited_Shipping__c,CC_List_1__c=findContactByEmailAddress(req.CC_List_1__c),CC_List_2__c=findContactByEmailAddress(req.CC_List_2__c),CC_List_3__c=findContactByEmailAddress(req.CC_List_3__c),CC_List_4__c=findContactByEmailAddress(req.CC_List_4__c),CC_List_5__c=findContactByEmailAddress(req.CC_List_5__c))	;
                objQuote.SBQQ__ExpirationDate__c=req.Target_End_Date__c;
                objQuote.RSM_Approver_LK__c=req.RSM__c;
                objQuote.RSM_Sales_Director_Approver_LK__c=req.RSM_Manager__c;
                objQuote.RSM_VP_Sales_Approver_LK__c=req.RSM_VP_Sales__c;
                objQuote.SE_Approver_LK__c=req.SE__c;
                objQuote.SE_Manager_Approver_LK__c=req.SE_Manager__c;
                objQuote.SE_Director_Approver_LK__c=req.SE_Director__c;
                objQuote.Justification__c=req.Extension_Justification__c;
                if(req.Status__c=='Open') 
                {
                    objQuote.ApprovalStatus__c='Draft';
                    objQuote.RecordTypeId=evalInitialQuoteRT;
                }
                else
                {
                    objQuote.ApprovalStatus__c='Approved';
                    objQuote.RecordTypeId=evalApprovedQuoteRT;
                }
                
                
                
                lstQuotes.add(objQuote);
                SBQQ__Quote__c quoteRef= new SBQQ__Quote__c(Quote_External_Id__c=req.Name);
                
                if(req.VirtualProduct1__c!=null)
                {
                    if(mapProductIds.get(req.VirtualProduct1__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql1', SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.VirtualProduct1__c),SBQQ__Quantity__c=req.VirtualQuantity1__c);
                        lstQuoteLines.add(ql1);
                        SBQQ__QuoteLine__c ql1Ref= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql1');
                        
                        
                        if(req.POC_Type__c=='WAN Op')
                        {
                            string POCSubscription=req.VirtualProduct1__c+ ' POC Subscription';
                            
                            SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql1sub',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.VirtualQuantity1__c);
                            lstQuoteLines.add(ql2);
                        }
                    }
                    
                }
                if(req.VirtualProduct2__c!=null)
                {
                    if(mapProductIds.get(req.VirtualProduct2__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql2',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.VirtualProduct2__c),SBQQ__Quantity__c=req.VirtualQuantity2__c);
                        lstQuoteLines.add(ql1);
                        SBQQ__QuoteLine__c ql1Ref= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql2');
                        if(req.POC_Type__c=='WAN Op')
                        {
                            string POCSubscription=req.VirtualProduct2__c+ ' POC Subscription';
                            SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql2sub',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.VirtualQuantity2__c);
                            lstQuoteLines.add(ql2);
                        }
                    }
                }
                if(req.VirtualProduct3__c!=null)
                {
                    if(mapProductIds.get(req.VirtualProduct3__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql3',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.VirtualProduct3__c),SBQQ__Quantity__c=req.VirtualQuantity3__c);
                        lstQuoteLines.add(ql1);
                        SBQQ__QuoteLine__c ql1Ref= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql3');
                        if(req.POC_Type__c=='WAN Op')
                        {
                            string POCSubscription=req.VirtualProduct3__c+ ' POC Subscription';
                            SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql3sub',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.VirtualQuantity3__c);
                            lstQuoteLines.add(ql2);
                        }
                    }
                }
                if(req.VirtualProduct4__c!=null)
                {
                    if(mapProductIds.get(req.VirtualProduct4__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql4',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.VirtualProduct4__c),SBQQ__Quantity__c=req.VirtualQuantity4__c);
                        lstQuoteLines.add(ql1);
                        SBQQ__QuoteLine__c ql1Ref= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql4');
                        if(req.POC_Type__c=='WAN Op')
                        {
                            string POCSubscription=req.VirtualProduct4__c+ ' POC Subscription';
                            SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql4sub',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.VirtualQuantity4__c);
                            lstQuoteLines.add(ql2);
                        }
                    }
                }
                if(req.VirtualProduct5__c!=null)
                {
                    if(mapProductIds.get(req.VirtualProduct5__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql5',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.VirtualProduct5__c),SBQQ__Quantity__c=req.VirtualQuantity5__c);
                        lstQuoteLines.add(ql1);
                        SBQQ__QuoteLine__c ql1Ref= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql5');
                        if(req.POC_Type__c=='WAN Op')
                        {
                            string POCSubscription=req.VirtualProduct5__c+ ' POC Subscription';
                            SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' vql5sub',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.VirtualQuantity5__c);
                            lstQuoteLines.add(ql2);
                        }
                    }
                }
                
                if(req.PhysicalProduct1__c!=null)
                {
                    if(mapProductIds.get(req.PhysicalProduct1__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql1', SBQQ__Bundle__c=true, SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.PhysicalProduct1__c),SBQQ__Quantity__c=req.PhysicalQuantity1__c);
                        lstQuoteLines.add(ql1);
                        SBQQ__QuoteLine__c ql1Ref= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql1');
                        
                        string POCSubscription=req.PhysicalProduct1__c+ ' POC Subscription';
                        SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql1sub',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.PhysicalQuantity1__c);
                        lstQuoteLines.add(ql2);
                        Quote_Address__c addr=CreateAddressfromHardware(quoteRef,req.PhysicalLocation1__c,req.Name,req.EndCustomerName1__c);
                        addr.Quote_Addr_Ext_Id__c= req.Name + '-1';
                        lstQuoteAddr.add(addr);
                        Quote_Address__c quoteAddrRef= new Quote_Address__c(Quote_Addr_Ext_Id__c=req.Name + '-1');
                        Quote_Line_Address__c quotelineAddr1 = new Quote_Line_Address__c(Quote_Address__r=quoteAddrRef,Shipping_Quantity__c=req.PhysicalQuantity1__c,Is_Hardware__c=true,Quote__r=quoteRef, Quote_Line__r=ql1Ref);
                        lstQuoteLineAddr.add(quotelineAddr1);
                        
                    }
                    
                }
                
                
                if(req.PhysicalProduct2__c!=null)
                {
                    if(mapProductIds.get(req.PhysicalProduct2__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql2', SBQQ__Bundle__c=true, SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.PhysicalProduct2__c),SBQQ__Quantity__c=req.PhysicalQuantity2__c);
                        lstQuoteLines.add(ql1);
                        SBQQ__QuoteLine__c ql1Ref= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql2');
                        
                        string POCSubscription=req.PhysicalProduct2__c+ ' POC Subscription';
                        SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql2sub',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.PhysicalQuantity2__c);
                        lstQuoteLines.add(ql2);
                        Quote_Address__c addr=CreateAddressfromHardware(quoteRef,req.PhysicalLocation2__c,req.Name,req.EndCustomerName2__c);
                        addr.Quote_Addr_Ext_Id__c= req.Name + '-2';
                        lstQuoteAddr.add(addr);
                        Quote_Address__c quoteAddrRef= new Quote_Address__c(Quote_Addr_Ext_Id__c=req.Name + '-2');
                        Quote_Line_Address__c quotelineAddr1 = new Quote_Line_Address__c(Quote_Address__r=quoteAddrRef,Shipping_Quantity__c=req.PhysicalQuantity2__c,Is_Hardware__c=true,Quote__r=quoteRef, Quote_Line__r=ql1Ref);
                        lstQuoteLineAddr.add(quotelineAddr1);
                        
                    }
                    
                }
                if(req.PhysicalProduct3__c!=null)
                {
                    if(mapProductIds.get(req.PhysicalProduct3__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql3', SBQQ__Bundle__c=true, SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.PhysicalProduct3__c),SBQQ__Quantity__c=req.PhysicalQuantity3__c);
                        lstQuoteLines.add(ql1);
                        SBQQ__QuoteLine__c ql1Ref= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql3');
                        
                        string POCSubscription=req.PhysicalProduct3__c+ ' POC Subscription';
                        SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql3sub',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.PhysicalQuantity3__c);
                        lstQuoteLines.add(ql2);
                        Quote_Address__c addr=CreateAddressfromHardware(quoteRef,req.PhysicalLocation3__c,req.Name,req.EndCustomerName3__c);
                        addr.Quote_Addr_Ext_Id__c= req.Name + '-3';
                        lstQuoteAddr.add(addr);
                        Quote_Address__c quoteAddrRef= new Quote_Address__c(Quote_Addr_Ext_Id__c=req.Name + '-3');
                        Quote_Line_Address__c quotelineAddr1 = new Quote_Line_Address__c(Quote_Address__r=quoteAddrRef,Shipping_Quantity__c=req.PhysicalQuantity3__c,Is_Hardware__c=true,Quote__r=quoteRef, Quote_Line__r=ql1Ref);
                        lstQuoteLineAddr.add(quotelineAddr1);
                        
                    }
                    
                }
                if(req.PhysicalProduct4__c!=null)
                {
                    if(mapProductIds.get(req.PhysicalProduct4__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql4', SBQQ__Bundle__c=true, SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.PhysicalProduct4__c),SBQQ__Quantity__c=req.PhysicalQuantity4__c);
                        lstQuoteLines.add(ql1);
                        SBQQ__QuoteLine__c ql1Ref= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql4');
                        
                        string POCSubscription=req.PhysicalProduct4__c+ ' POC Subscription';
                        SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql4sub',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.PhysicalQuantity4__c);
                        lstQuoteLines.add(ql2);
                        Quote_Address__c addr=CreateAddressfromHardware(quoteRef,req.PhysicalLocation4__c,req.Name,req.EndCustomerName4__c);
                        addr.Quote_Addr_Ext_Id__c= req.Name + '-4';
                        lstQuoteAddr.add(addr);
                        Quote_Address__c quoteAddrRef= new Quote_Address__c(Quote_Addr_Ext_Id__c=req.Name + '-4');
                        Quote_Line_Address__c quotelineAddr1 = new Quote_Line_Address__c(Quote_Address__r=quoteAddrRef,Shipping_Quantity__c=req.PhysicalQuantity4__c,Is_Hardware__c=true,Quote__r=quoteRef, Quote_Line__r=ql1Ref);
                        lstQuoteLineAddr.add(quotelineAddr1);
                        
                    }
                    
                }
                
                if(req.PhysicalProduct5__c!=null)
                {
                    if(mapProductIds.get(req.PhysicalProduct5__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql5', SBQQ__Bundle__c=true, SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.PhysicalProduct5__c),SBQQ__Quantity__c=req.PhysicalQuantity5__c);
                        lstQuoteLines.add(ql1);
                        SBQQ__QuoteLine__c ql1Ref= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql5');
                        
                        string POCSubscription=req.PhysicalProduct5__c+ ' POC Subscription';
                        SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(QL_Ext_Id__c= req.Name+' pql5sub',SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.PhysicalQuantity5__c);
                        lstQuoteLines.add(ql2);
                        Quote_Address__c addr=CreateAddressfromHardware(quoteRef,req.PhysicalLocation4__c,req.Name,req.EndCustomerName5__c);
                        addr.Quote_Addr_Ext_Id__c= req.Name + '-5';
                        lstQuoteAddr.add(addr);
                        Quote_Address__c quoteAddrRef= new Quote_Address__c(Quote_Addr_Ext_Id__c=req.Name + '-5');
                        Quote_Line_Address__c quotelineAddr1 = new Quote_Line_Address__c(Quote_Address__r=quoteAddrRef,Shipping_Quantity__c=req.PhysicalQuantity5__c,Is_Hardware__c=true,Quote__r=quoteRef, Quote_Line__r=ql1Ref);
                        lstQuoteLineAddr.add(quotelineAddr1);
                        
                    }
                    
                }
                lstReqToUpdate.add(new Request__c(Id=req.Id,Converted__c=true));
            }
            System.debug('lstOpps'+lstOpps);
            System.debug('lstQuotes'+lstQuotes);
            System.debug('lstQuoteLines'+lstQuoteLines);
            SObject[] sobjList = new List<SObject>();
            sobjList.addAll(lstOpps);
            sobjList.addAll(lstQuotes);
            sobjList.addAll(lstQuoteLines);
            sobjList.addAll(lstQuoteAddr);
            sobjList.addAll(lstQuoteLineAddr);
            Database.SaveResult[] lsr = Database.insert(sobjList,true);// rollback if there is any error
            boolean isSuccessful=false;
            System.debug('lsr.count'+ lsr.size());
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Conversion Successful');
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
                UpdateRequiredByFieldonSubQuoteLine(lstQuotes);
                ConvertAssetsIntoSubscriptions(pocIds,mapProductIds);
                //Update the POC to be converted to true
                
                update lstReqToUpdate;
            }  
        }
        
    }
    
    
    
    private static void ConvertAssetsIntoSubscriptions(Map<ID,Request__c> pocIds,Map<string,Id> mapProducts)
    {
        List<Contract> lstContracts= new List<Contract>();
        List<Contract> lstContractsToUpdate= new List<Contract>();
        List<SBQQ__Subscription__c> lstSubscription= new List<SBQQ__Subscription__c>();
        List<SBQQ__SubscribedAsset__c> lstSubscriptionAsset= new List<SBQQ__SubscribedAsset__c>();
        List<Asset> lstAssetsToUpdate= new List<Asset>();
        Map<Id,Id> mapQuotePocIds= new Map<Id,Id>();
        Map<Id,Id> mapOppPocIds= new Map<Id,Id>();
        
        if(pocIds!=null && pocIds.size()>0)
        {
            List<Asset> lstAsset= [Select Id,POC_Request_Status__c, POCRequest__r.Contract_Number__c, POCRequest__r.Name,AccountId,Status,Quantity,Bandwidth_Nodes__c,Licenses_Nodes__c,Product2Id,Product2.Family,Product2.Name,SerialNumber,POCRequest__r.POC_Type__c,POCRequest__r.Status__c from Asset where Status in('Customer Evaluation','Pending Return – Eval') and POCRequest__r.POC_Type__c in ('WAN Op','EdgeConnect','EC-SP-Metered','EC-SP-Metered +Orch-SP')  and POCRequest__c in:pocIds.keyset() ];
            List<SBQQ__Quote__c> lstQuotes=[Select Id,POC_Request_Ref__c,SBQQ__opportunity2__c from SBQQ__Quote__C where POC_Request_Ref__c in:pocIds.keyset()  ];
            if(lstQuotes!=null && lstQuotes.size()>0)
            {
                for(SBQQ__Quote__c quote:lstQuotes)
                {
                    mapQuotePocIds.put(quote.POC_Request_Ref__c,quote.Id);
                    mapOppPocIds.put(quote.POC_Request_Ref__c,quote.SBQQ__opportunity2__c);
                }
            }
            for(Id pocId:pocIds.keyset())
            {
                Request__c pocReq=pocIds.get(pocId);
                if(pocReq.POC_Type__c=='WAN Op'|| pocReq.POC_Type__c=='EdgeConnect')
                {
                    string conStatus=pocReq.Status__c=='Pending Return'?'Expired':'Draft';
                    lstContracts.add(new Contract(Contract_External_Id__c=pocReq.Name,SBQQ__Opportunity__c=mapOppPocIds.get(pocReq.Id) ,SBQQ__Quote__c=mapQuotePocIds.get(pocReq.Id),AccountId=pocReq.Account_ID__c,Contract_Type__c='Evaluation',Status=conStatus,StartDate=pocReq.Actual_Ship_Date__c,EndDate=pocReq.Target_End_Date__c));
                }
                else if(pocReq.POC_Type__c=='EC-SP-Metered'||pocReq.POC_Type__c=='EC-SP-Metered +Orch-SP')
                {
                    lstContractsToUpdate.add(new Contract(Id=pocReq.Contract_Number__c, Contract_External_Id__c=pocReq.Name,SBQQ__Opportunity__c=mapOppPocIds.get(pocReq.Id) ,SBQQ__Quote__c=mapQuotePocIds.get(pocReq.Id)));
                }    
                
                
            }
            
            if(lstAsset!=null && lstAsset.size()>0)
            {
                for(Asset assetInfo:lstAsset)
                {
                    if(assetInfo.POCRequest__r.POC_Type__c=='EdgeConnect' && assetInfo.Product2.Family=='Virtual Image' && assetInfo.Product2.Name.startsWith('EC-BOOST'))
                    {
                        lstSubscription.add(new SBQQ__Subscription__c(SBQQ__Account__c=assetInfo.AccountId,Quote__c=mapQuotePocIds.get(assetInfo.POCRequest__c),Subscription_External_Id__c=assetInfo.POCRequest__r.Name+'-'+assetInfo.SerialNumber, SerialNumber__c=assetInfo.SerialNumber, SBQQ__Product__c=assetInfo.Product2Id,SBQQ__Quantity__c=assetInfo.Bandwidth_Nodes__c));
                        lstAssetsToUpdate.add(new Asset(Id=assetInfo.Id,Status='Converted to Subscription'));
                    }
                    else if(assetInfo.POCRequest__r.POC_Type__c=='EdgeConnect' && assetInfo.Product2.Family=='Virtual Image' && !assetInfo.Product2.Name.startsWith('EC-BOOST') && !assetInfo.Product2.Name.startsWith('EC-SAAS') && !assetInfo.Product2.Name.startsWith('EC-ORCH'))
                    {
                        lstSubscription.add(new SBQQ__Subscription__c(SBQQ__Account__c=assetInfo.AccountId,Quote__c=mapQuotePocIds.get(assetInfo.POCRequest__c),Subscription_External_Id__c=assetInfo.POCRequest__r.Name+'-'+assetInfo.SerialNumber, SerialNumber__c=assetInfo.SerialNumber, SBQQ__Product__c=assetInfo.Product2Id,SBQQ__Quantity__c=assetInfo.Licenses_Nodes__c));
                        lstAssetsToUpdate.add(new Asset(Id=assetInfo.Id,Status='Converted to Subscription'));
                    }
                    else if(assetInfo.POCRequest__r.POC_Type__c=='EdgeConnect' && assetInfo.Product2.Family=='Virtual Image')
                    {
                        lstSubscription.add(new SBQQ__Subscription__c(SBQQ__Account__c=assetInfo.AccountId,Quote__c=mapQuotePocIds.get(assetInfo.POCRequest__c),Subscription_External_Id__c=assetInfo.POCRequest__r.Name+'-'+assetInfo.SerialNumber, SerialNumber__c=assetInfo.SerialNumber, SBQQ__Product__c=assetInfo.Product2Id,SBQQ__Quantity__c=assetInfo.Quantity));
                        lstAssetsToUpdate.add(new Asset(Id=assetInfo.Id,Status='Converted to Subscription'));
                    }
                    else if((assetInfo.POCRequest__r.POC_Type__c=='EC-SP-Metered'||assetInfo.POCRequest__r.POC_Type__c=='EC-SP-Metered +Orch-SP' ) && assetInfo.Product2.Family=='Virtual Image')
                    {
                        lstSubscription.add(new SBQQ__Subscription__c(SBQQ__Account__c=assetInfo.AccountId,Quote__c=mapQuotePocIds.get(assetInfo.POCRequest__c),SBQQ__Contract__c=assetInfo.POCRequest__r.Contract_Number__c,  Subscription_External_Id__c=assetInfo.POCRequest__r.Name+'-'+assetInfo.SerialNumber, SerialNumber__c=assetInfo.SerialNumber, SBQQ__Product__c=assetInfo.Product2Id,SBQQ__Quantity__c=assetInfo.Quantity));
                        lstAssetsToUpdate.add(new Asset(Id=assetInfo.Id,Status='Converted to Subscription'));
                    }
                    else if(assetInfo.POCRequest__r.POC_Type__c=='WAN Op' || assetInfo.Product2.Family=='Product')
                    {
                        string pocSubId= mapProducts.get(assetInfo.Product2.Name +' POC Subscription');
                        Id contractId=null;
                        if(assetInfo.POCRequest__r.POC_Type__c=='EC-SP-Metered'||assetInfo.POCRequest__r.POC_Type__c=='EC-SP-Metered +Orch-SP' )
                         	contractId=assetInfo.POCRequest__r.Contract_Number__c;
                        
                        lstSubscription.add(new SBQQ__Subscription__c(SBQQ__Account__c=assetInfo.AccountId,SBQQ__Contract__c=contractId,Quote__c=mapQuotePocIds.get(assetInfo.POCRequest__c),Subscription_External_Id__c=assetInfo.POCRequest__r.Name+'-'+assetInfo.SerialNumber, SBQQ__Product__c=pocSubId,SBQQ__Quantity__c=assetInfo.Quantity));
                        SBQQ__Subscription__c subRef=new SBQQ__Subscription__c(Subscription_External_Id__c=assetInfo.POCRequest__r.Name+'-'+assetInfo.SerialNumber);
                        lstSubscriptionAsset.add(new SBQQ__SubscribedAsset__c(SBQQ__Asset__c=assetInfo.Id,SBQQ__Subscription__r=subRef,SBQQ__Active__c=assetInfo.POC_Request_Status__c=='Pending Return'?false:true));
                        lstAssetsToUpdate.add(new Asset(Id=assetInfo.Id,Quote__c=mapQuotePocIds.get(assetInfo.POCRequest__c)));
                    }
                    
                        
                }
            }
            SObject[] sobjList = new List<SObject>();
            sobjList.addAll(lstContracts);
            sobjList.addAll(lstSubscription);
            sobjList.addAll(lstSubscriptionAsset);
            Database.SaveResult[] lsr = Database.insert(sobjList,true);
            boolean isSuccessful=false;
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('ConvertWanOPECAssetsIntoSubscriptions  Successful');
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
                 System.debug('lstSubscription'+lstSubscription);
                 System.debug('lstAssetsToUpdate' +lstAssetsToUpdate);
                 update lstAssetsToUpdate;
                 if(lstContractsToUpdate!=null && lstContractsToUpdate.size()>0)
                	update lstContractsToUpdate;
                 AssociateSubWithContracts(lstContracts,lstSubscription); // This will associate sub with contracts
                 AssociateCurrentSubscriptionToAsset(lstSubscription,lstAsset); // This will update current subscription field on asset
                 AssociateRMARecordTOEvalQuotes(pocIds,mapQuotePocIds); // This will populate Quote id on RMA record.
            }
            
        }
        
    }
    
   
    private static void AssociateSubWithContracts(List<Contract> lstContracts, List<SBQQ__Subscription__c> lstSubscriptions)
    {
        List<SBQQ__Subscription__c> lstSubscriptionToUpdate= new List<SBQQ__Subscription__c>();
        Map<string,Id> mapContract= new Map<string,Id>();
        if(lstContracts!=null && lstContracts.size()>0)
        {
            for(Contract contractInfo:lstContracts)
            {
                mapContract.put(contractInfo.Contract_External_Id__c,contractInfo.Id);
            }
        }
        
        if(lstSubscriptions!=null && lstSubscriptions.size()>0)
        {
            for(SBQQ__Subscription__c subInfo:lstSubscriptions)
            {
                string subExternalId=subInfo.Subscription_External_Id__c;
                subExternalId=subExternalId.substringBefore('-');
                if(mapContract!=null && mapContract.size()>0 && mapContract.containsKey(subExternalId))
                    lstSubscriptionToUpdate.add(new SBQQ__Subscription__c(Id=subInfo.Id,SBQQ__Contract__c=mapContract.get(subExternalId)));
            }
            if(lstSubscriptionToUpdate!=null && lstSubscriptionToUpdate.size()>0)
            {
                update lstSubscriptionToUpdate;
            }
            
        }
    }
    
    private static void AssociateCurrentSubscriptionToAsset(List<SBQQ__Subscription__c> lstSubs,List<Asset> lstAssets)
    {
        List<Asset> lstAssetsToUpdate = new List<Asset>();
        if(lstAssets!=null && lstAssets.size()>0)
        {
            for(Asset assetInfo: lstAssets)
            {
                if(assetInfo.POCRequest__r.POC_Type__c=='WAN Op' || assetInfo.Product2.Family=='Product' )
                {
                    if(lstSubs!=null && lstSubs.size()>0)
                    {
                        for(SBQQ__Subscription__c subInfo: lstSubs)
                        {
                            string sn= subInfo.Subscription_External_Id__c.substringAfter('-');
                            if(sn==assetInfo.SerialNumber)
                            {
                                lstAssetsToUpdate.add(new Asset(Id=assetInfo.Id,SBQQ__CurrentSubscription__c=subInfo.Id));
                            }
                        }
                    }
                }
                
            }
            if(lstAssetsToUpdate!=null && lstAssetsToUpdate.size()>0)
            {
                update lstAssetsToUpdate;
            }
        }
        
    }
    
    private static void UpdateRequiredByFieldonSubQuoteLine(List<SBQQ__Quote__c>lstQuotes)
    {
        Set<Id> quoteIds= new Set<Id>();
        List<SBQQ__QuoteLine__c> qlSubsToUpdate= new List<SBQQ__QuoteLine__c>();
        System.debug('UpdateRequiredByFieldonSubQuoteLine' + lstQuotes.size());
        
        if(lstQuotes!=null && lstQuotes.size()>0)
        {
            for(SBQQ__Quote__c quote:lstQuotes)
            {
                System.debug('quote.Id'+ quote.Id);
                quoteIds.add(quote.Id);
            }
            
            List<SBQQ__QuoteLine__c> qlSubs=[Select Id,SBQQ__RequiredBy__c,Required_by_Ext_Id__c,QL_Ext_Id__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in:quoteIds and  SBQQ__ProductName__c like '%POC Subscription%'];
            List<SBQQ__QuoteLine__c> qlAssets=[Select Id,SBQQ__RequiredBy__c,Required_by_Ext_Id__c,QL_Ext_Id__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in:quoteIds and (NOT SBQQ__ProductName__c like '%POC Subscription%')];
            if(qlSubs!=null && qlSubs.size()>0)
            {
                for(SBQQ__QuoteLine__c qlSub:qlSubs)
                {
                    string extId= qlSub.QL_Ext_Id__c;
                    System.debug('extId'+ extId);
                    extId=extId.removeEnd('sub');
                    if(qlAssets!=null && qlAssets.size()>0)
                    {
                        for(SBQQ__QuoteLine__c qlAsset:qlAssets)
                        {
                            System.debug('qlAsset.QL_Ext_Id__c'+qlAsset.QL_Ext_Id__c);
                            if(extId==qlAsset.QL_Ext_Id__c)
                            {
                                qlSub.SBQQ__RequiredBy__c=qlAsset.Id;
                                qlSubsToUpdate.add(qlSub);
                                break;
                            }
                        }
                    }
                }
                
                if(qlSubsToUpdate!=null && qlSubsToUpdate.size()>0)
                {
                    update qlSubsToUpdate;
                }
                
            }
        }
    }
    
    
    private static Quote_Address__c CreateAddressfromHardware(SBQQ__Quote__c quoteRef, string location, string reqName, string endCustomerName)
    {
        //Fill address section
        CustomPOCRequestController.SiteLocationInfo siteLoc= new CustomPOCRequestController.SiteLocationInfo(location);
        Quote_Address__c addr1 = new Quote_Address__c(Quote__r=quoteRef,Country__c=siteLoc.ShippingAddress.Country,State__c=GetStateName(siteLoc.ShippingAddress.State,siteLoc.ShippingAddress.StateList),City__c=siteLoc.ShippingAddress.City, Street__c=siteLoc.ShippingAddress.Street,Postal_Code__c=siteLoc.ShippingAddress.Code);
        addr1.Name=siteLoc.ShippingAddress.Country + ' - ' +siteLoc.ShippingContact.Firstname+' - '+siteLoc.ShippingContact.LastName;
        addr1.First_Name__c=siteLoc.ShippingContact.Firstname;
        addr1.Last_Name__c=siteLoc.ShippingContact.Lastname;
        addr1.Phone__c=siteLoc.ShippingContact.Phone;
        addr1.Company__c=siteLoc.ShippingContact.Company;
        addr1.End_Customer_Contact_Name__c=endCustomerName;
        addr1.Is_final_dest_in_a_different_country__c=siteLoc.DestinationAddress.IsFinalDestination;
        addr1.FD_Country__c=siteLoc.DestinationAddress.Country;
        addr1.FD_Company__c=siteLoc.DestinationContact.Company;
        addr1.FD_First_Name__c=siteLoc.DestinationContact.Firstname;
        addr1.FD_Last_Name__c=siteLoc.DestinationContact.Lastname;
        addr1.VAT_Addr__c=siteLoc.VAT.VATAddress;
        addr1.VAT_Company__c=siteLoc.VAT.VATCompany;
        addr1.VAT_ID__c=siteLoc.VAT.VATId;
        
        return addr1;
        
    }
    private static string GetStateName(string stateCode,List<SelectOption> stateList)
    {
        if(stateList!=null && stateList.size()>0)
        {
            for(SelectOption st:stateList)
            {
                if(st.getValue()==stateCode)
                    return st.getLabel();
            }
        }
        
        return '';
    }
    private static Id findContactByEmailAddress(string email)
    {
        if(string.isBlank(email))
            return null;
        List<Contact> lstCon=[Select Id from Contact where Email=:email];
        if(lstCon!=null && lstCon.size()>0) return lstCon[0].Id;
        return null;
    }
    
    
  
    // Step 5
    private static void AssociateRMARecordTOEvalQuotes(Map<ID,Request__c> pocIds, Map<Id,Id> mapQuotes)
    {
        List<RMA__c> lstRMAToUpdate= new List<RMA__c>();
        if(pocIds!=null && pocIds.size()>0)
        {
            List<RMA__c> lstRMA= [Select Id,Request__c from RMA__c where Request__c in:pocIds.keyset() ];
            
            if(lstRMA!=null && lstRMA.size()>0)
            {
                for(RMA__c rma:lstRMA)
                {
                    if(mapQuotes.containsKey(rma.Request__c))
						lstRMAToUpdate.add(new RMA__c(Id=rma.Id,POC_Quote__c=mapQuotes.get(rma.Request__c)));               
                }
            }
            if(lstRMAToUpdate!=null && lstRMAToUpdate.size()>0)
            {
                update lstRMAToUpdate;
            }
        }
        
        
        
    }
    
    
    
    
}