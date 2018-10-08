public class POCLegacyDataConversion {
    
    
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
        List<Request__c> lstReqToUpdate= new List<Request__c>();
        // Take all the POC where Convert=true
        
        List<PricebookEntry> lstPriceEntries= [Select Product2Id,Product2.Name from PricebookEntry where PriceBook2Id in('01s0x00000096Kf','01s0x00000096Ka') and IsActive=true];
        if(lstPriceEntries!=null && lstPriceEntries.size()>0)
        {
            for(PricebookEntry pr:lstPriceEntries)
                mapProductIds.put(pr.Product2.Name,pr.Product2Id);
        }
        
        List<Request__c > lstReq=[Select Id,Name,CreatedDate,Opportunity__r.Type,Opportunity__r.Deal_Type__c,Opportunity__r.CloseDate,Extension_Justification__c,Opportunity__r.RecordTypeId,Opportunity__r.StageName,Opportunity__r.OwnerId,Opportunity__r.Technical_Responsible__c,Opportunity__r.Account.ECSP__c,Opportunity__r.Patch__c,Opportunity__r.Name,RSM__c,RSM_Manager__c,RSM_VP_Sales__c,SE__c,SE_Manager__c,SE_Director__c,Account_ID__c,Opportunity__c,POC_Type__c,Target_End_Date__c,POC_Contact__c,Status__c,Problem_Criteria__c,Testing_Criteria__c,Success_Criteria__c,Project_Budget__c,International_Shipping__c,Expedited_Shipping__c,CC_List_1__c,CC_List_2__c,CC_List_3__c,CC_List_4__c,CC_List_5__c,VirtualProduct1__c, VirtualProduct2__c,VirtualProduct3__c,VirtualProduct4__c,VirtualProduct5__c ,VirtualQuantity1__c,VirtualQuantity2__c,VirtualQuantity3__c ,VirtualQuantity4__c,VirtualQuantity5__c ,PhysicalProduct1__c,PhysicalProduct3__c,PhysicalProduct2__c ,PhysicalProduct4__c,PhysicalProduct5__c ,PhysicalQuantity1__c,PhysicalQuantity2__c,PhysicalQuantity3__c,PhysicalQuantity4__c,PhysicalQuantity5__c from Request__c where Convert_to_CPQ__c=true  and  Converted__c=false LIMIT 200];
        if(lstReq!=null && lstReq.size()>0)
        {
            for(Request__c req:lstReq)
            {
                Id pbId=evalEnterprisePricebook;
                if(req.Opportunity__r.Account.ECSP__c) pbId=evalSPPricebook;
                Opportunity opp= new Opportunity(CloseDate=req.Opportunity__r.CloseDate,Type=req.Opportunity__r.Type,Deal_Type__c=req.Opportunity__r.Deal_Type__c, POC_Request__c=req.Name,AccountId=req.Account_ID__c,Related_Opportunity__c=req.Opportunity__c,Name='POC for '+req.Opportunity__r.Name,POC_Opportunity__c=true,Pricebook2Id=pbId,Patch__c=req.Opportunity__r.Patch__c,OwnerId=req.Opportunity__r.OwnerId,Technical_Responsible__c=req.Opportunity__r.Technical_Responsible__c,RecordTypeId=req.Opportunity__r.RecordTypeId,StageName=req.Opportunity__r.StageName );
                lstOpps.add(opp);
                Opportunity oppRef= new Opportunity(POC_Request__c=req.Name);
                SBQQ__Quote__c objQuote= new SBQQ__Quote__c(SBQQ__Opportunity2__r=oppRef, SBQQ__StartDate__c=Date.valueOf(req.CreatedDate),POC_Contact__c=req.POC_Contact__c,POC_Request__c=req.Name,POC_Status__c=req.Status__c,Product_Type__c=req.POC_Type__c,SBQQ__Primary__c=true,SBQQ__Type__c='Quote',Define_Problem__c=req.Problem_Criteria__c,Testing_Criteria__c=req.Testing_Criteria__c,Success_Criteria__c=req.Success_Criteria__c,Project_Budget__c=req.Project_Budget__c,International_Shipping__c=req.International_Shipping__c,Expedited_Shipping__c=req.Expedited_Shipping__c,CC_List_1__c=findContactByEmailAddress(req.CC_List_1__c),CC_List_2__c=findContactByEmailAddress(req.CC_List_2__c),CC_List_3__c=findContactByEmailAddress(req.CC_List_3__c),CC_List_4__c=findContactByEmailAddress(req.CC_List_4__c),CC_List_5__c=findContactByEmailAddress(req.CC_List_5__c))	;
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
                SBQQ__Quote__c quoteRef= new SBQQ__Quote__c(POC_Request__c=req.Name);
                
                if(req.VirtualProduct1__c!=null)
                {
                    if(mapProductIds.get(req.VirtualProduct1__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.VirtualProduct1__c),SBQQ__Quantity__c=req.VirtualQuantity1__c);
                        lstQuoteLines.add(ql1);
                        if(req.POC_Type__c=='WAN Op')
                        {
                            string POCSubscription=req.VirtualProduct1__c+ ' POC Subscription';
                            SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.VirtualQuantity1__c);
                            lstQuoteLines.add(ql2);
                        }
                    }
                    
                }
                if(req.VirtualProduct2__c!=null)
                {
                    if(mapProductIds.get(req.VirtualProduct2__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.VirtualProduct2__c),SBQQ__Quantity__c=req.VirtualQuantity2__c);
                        lstQuoteLines.add(ql1);
                        if(req.POC_Type__c=='WAN Op')
                        {
                            string POCSubscription=req.VirtualProduct2__c+ ' POC Subscription';
                            SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.VirtualQuantity2__c);
                            lstQuoteLines.add(ql2);
                        }
                    }
                }
                if(req.VirtualProduct3__c!=null)
                {
                    if(mapProductIds.get(req.VirtualProduct3__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.VirtualProduct3__c),SBQQ__Quantity__c=req.VirtualQuantity3__c);
                        lstQuoteLines.add(ql1);
                        if(req.POC_Type__c=='WAN Op')
                        {
                            string POCSubscription=req.VirtualProduct3__c+ ' POC Subscription';
                            SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.VirtualQuantity3__c);
                            lstQuoteLines.add(ql2);
                        }
                    }
                }
                if(req.VirtualProduct4__c!=null)
                {
                    if(mapProductIds.get(req.VirtualProduct4__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.VirtualProduct4__c),SBQQ__Quantity__c=req.VirtualQuantity4__c);
                        lstQuoteLines.add(ql1);
                        if(req.POC_Type__c=='WAN Op')
                        {
                            string POCSubscription=req.VirtualProduct4__c+ ' POC Subscription';
                            SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.VirtualQuantity4__c);
                            lstQuoteLines.add(ql2);
                        }
                    }
                }
                if(req.VirtualProduct5__c!=null)
                {
                    if(mapProductIds.get(req.VirtualProduct5__c)!=null)
                    {
                        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(req.VirtualProduct5__c),SBQQ__Quantity__c=req.VirtualQuantity5__c);
                        lstQuoteLines.add(ql1);
                        if(req.POC_Type__c=='WAN Op')
                        {
                            string POCSubscription=req.VirtualProduct5__c+ ' POC Subscription';
                            SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(SBQQ__Quote__r=quoteRef, SBQQ__Product__c=mapProductIds.get(POCSubscription),SBQQ__Quantity__c=req.VirtualQuantity5__c);
                            lstQuoteLines.add(ql2);
                        }
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
            Database.SaveResult[] lsr = Database.insert(sobjList,true);
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Conversion Successful');
                    update lstReqToUpdate;
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
            // Loop over the POCs and create an eval opp and eval quote 
            //Insert opps 
            //Insert quotes
            // Associate quotes and opps.
            // 
            // 
            // Loop over the physical products and virtual products 
            // for physical, call method from Custom POC Request and add in quote lineaddresss 2) add subscriptiopn line items
            // for virtual, add subscription line items into quote line
            // 
            
            
            
            
            
        }
        
    }
    
    // Step 2
    public static void ConvertNXVXShippedAssets()
    {
        
        
        
        
        
    }
    
    private static Id findContactByEmailAddress(string email)
    {
        if(string.isBlank(email))
            return null;
        List<Contact> lstCon=[Select Id from Contact where Email=:email];
        if(lstCon!=null && lstCon.size()>0) return lstCon[0].Id;
        return null;
    }
    // Step 3
    public static void ConvertECShippedAssets()
    {
        
        
        
        
        
    }
    // Step 4
    public static void ConvertServiceProviderAssets()
    {
        
        
        
        
        
    }
    // Step 5
    public static void AssociateRMARecordTOEvalQuotes()
    {
        
        
        
        
        
    }
    
    
    
    
}