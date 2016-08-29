trigger SetApprovalLevel on SBQQ__QuoteLine__c (after insert,after update) {
    Set<Id> quoteLineIds= new Set<Id>();
    List<SBQQ__QuoteLine__c> quotesToUpdate= new List<SBQQ__QuoteLine__c>();
    
    if(Trigger.IsInsert)
    {
        for(SBQQ__QuoteLine__c item: Trigger.New)
        {
            quoteLineIds.add(item.Id);
        }
    }
    if(Trigger.IsUpdate)
    {
        for(SBQQ__QuoteLine__c item: Trigger.New)
        {
            SBQQ__QuoteLine__c oldQuoteItem= Trigger.OldMap.get(item.Id);
              System.debug('oldQuoteItem.SBQQ__Product__c'+ oldQuoteItem.SBQQ__Product__c);
            System.debug('item.SBQQ__Product__c'+ item.SBQQ__Product__c);
            System.debug('oldQuoteItem.Additional_Discount__c'+ oldQuoteItem.Additional_Discount__c);
            System.debug('item.Additional_Discount__c'+ item.Additional_Discount__c);
            if(oldQuoteItem.SBQQ__Product__c!=item.SBQQ__Product__c || oldQuoteItem.Additional_Discount__c!=item.Additional_Discount__c )
            {
                quoteLineIds.add(item.Id);
            }
            
        }
    }
    
    if(quoteLineIds.size()>0)    
    {
        for(Id item: quoteLineIds)
        {
            SBQQ__QuoteLine__c lineItem=[Select Id,Tier_1_Approval__c,Tier_2_Approval__c,Tier_3_Approval__c,Tier_4_Approval__c,SBQQ__Product__r.Name,SBQQ__Product__r.Family,Additional_Discount__c ,SBQQ__Product__r.Product_Category_Group__c,SBQQ__Product__r.Term__c from SBQQ__QuoteLine__c where Id=: item];
            string prodName= lineItem.SBQQ__Product__r.Name;
            string prodFamily=lineItem.SBQQ__Product__r.Family;
            string prodCategory=lineItem.SBQQ__Product__r.Product_Category_Group__c;
            decimal prodTerm=lineItem.SBQQ__Product__r.Term__c;
            decimal additionalDisc=lineItem.Additional_Discount__c;
            string tierToAllocate='';
            if(prodFamily!=null && prodFamily=='Product')
            {
                if(prodName.startsWith('EC'))
                {
                    if(additionalDisc >=1)
                    {
                        tierToAllocate='Tier 4';
                    }
                    else if(additionalDisc >=0.08)
                    {
                        tierToAllocate='Tier 3';
                    }
                    else if(additionalDisc >=0.05)
                    {
                        tierToAllocate='Tier 2';
                    }
                    else if(additionalDisc >0)
                    {
                        tierToAllocate='Tier 1';
                    }
                    
                   
                     
                }
                if((prodName =='NX-700'|| prodName =='NX-1700'))
                {
                    if(additionalDisc >=0.15)
                    {
                        tierToAllocate='Tier 4';
                    }
                    else if(additionalDisc >=0.05)
                    {
                        tierToAllocate='Tier 3';
                    }
                    else if(additionalDisc >=0.05)
                    {
                        tierToAllocate='Tier 2';
                    }
                    else if(additionalDisc >0)
                    {
                        tierToAllocate='Tier 1';
                    }
                    
                    
                    
                }
                if((prodName.startsWith('NX-2')|| prodName.startsWith('NX-3')||prodName.startsWith('NX-4')|| prodName.startsWith('NX-5') || prodName.startsWith('NX-6')|| prodName.startsWith('NX-8')|| prodName.startsWith('NX-9')))
                {
                    if(additionalDisc >=0.20)
                    {
                        tierToAllocate='Tier 4';
                    }
                    else if(additionalDisc >=0.14)
                    {
                        tierToAllocate='Tier 3';
                    }
                    else if(additionalDisc >=0.05)
                    {
                        tierToAllocate='Tier 2';
                    }
                    else if(additionalDisc >0)
                    {
                        tierToAllocate='Tier 1';
                    } 
                }
            }
            else if(prodFamily!=null && prodFamily=='Service')
            {
                if(prodName.startsWith('WANSTART'))
                {
                    if(additionalDisc >=1)
                    {
                        tierToAllocate='Tier 4';
                    }
                    else if(additionalDisc >=1)
                    {
                        tierToAllocate='Tier 3';
                    }
                    else if(additionalDisc >=0.30)
                    {
                        tierToAllocate='Tier 2';
                    }
                    else if(additionalDisc >0)
                    {
                        tierToAllocate='Tier 1';
                    }
                }
                if(prodCategory=='Maintenance' && prodTerm==3.0 &&(prodName.startsWith('NX')|| prodName.startsWith('VX')))
                {
                    if(additionalDisc >=0.22)
                    {
                        tierToAllocate='Tier 4';
                    }
                    else if(additionalDisc >=0.17)
                    {
                        tierToAllocate='Tier 3';
                    }
                    else if(additionalDisc >=0.14)
                    {
                        tierToAllocate='Tier 2';
                    }
                    else if(additionalDisc >=0.09)
                    {
                        tierToAllocate='Tier 1';
                    }
                }
                if(prodCategory=='Maintenance' && prodTerm!=3.0 &&(prodName.startsWith('NX')|| prodName.startsWith('VX')))
                {
                    if(additionalDisc >=0.17)
                    {
                        tierToAllocate='Tier 4';
                    }
                    else if(additionalDisc >=0.11)
                    {
                        tierToAllocate='Tier 3';
                    }
                    else if(additionalDisc >=0.05)
                    {
                        tierToAllocate='Tier 2';
                    }
                    else if(additionalDisc >0)
                    {
                        tierToAllocate='Tier 1';
                    }
                   
                }
            }
            else if(prodFamily!=null && prodFamily=='Virtual Image')
            {
                if(prodName.startsWith('EC-BASE')|| prodName.startsWith('EC-PLUS'))
                {
                    
                    if(additionalDisc >=0.20)
                    {
                        tierToAllocate='Tier 4';
                    }
                    else if(additionalDisc >=0.08)
                    {
                        tierToAllocate='Tier 3';
                    }
                    else if(additionalDisc >=0.03)
                    {
                        tierToAllocate='Tier 2';
                    }
                    else if(additionalDisc >0)
                    {
                        tierToAllocate='Tier 1';
                    }
                   
                   
                    
                }
                else if(prodName.startsWith('EC-BOOST'))
                {
                    if(additionalDisc >=0.50)
                    {
                        tierToAllocate='Tier 4';
                    }
                    else if(additionalDisc >=0.11)
                    {
                        tierToAllocate='Tier 3';
                    }
                    else if(additionalDisc >=0.05)
                    {
                        tierToAllocate='Tier 2';
                    }
                    else if(additionalDisc >0)
                    {
                        tierToAllocate='Tier 1';
                    }
                    
                   
                    
                }
                else if(prodName.startsWith('VX'))
                {
                    if(additionalDisc >=0.30)
                    {
                        tierToAllocate='Tier 4';
                    }
                    else if(additionalDisc >=0.19)
                    {
                        tierToAllocate='Tier 3';
                    }
                    else if(additionalDisc >=0.09)
                    {
                        tierToAllocate='Tier 2';
                    }
                    else if(additionalDisc >0)
                    {
                        tierToAllocate='Tier 1';
                    }
                }
                
            }
            
            if( tierToAllocate=='Tier 4')            
            {
                lineItem.Tier_4_Approval__c='Discount Tier 4';
                lineItem.Tier_3_Approval__c='Discount Tier 3';
                lineItem.Tier_2_Approval__c='Discount Tier 2';
                lineItem.Tier_1_Approval__c='Discount Tier 1';
            }
            else if(tierToAllocate=='Tier 3')
            {
                lineItem.Tier_3_Approval__c='Discount Tier 3';
                lineItem.Tier_2_Approval__c='Discount Tier 2';
                lineItem.Tier_1_Approval__c='Discount Tier 1';
            }
            else if(tierToAllocate=='Tier 2')
            {
                lineItem.Tier_2_Approval__c='Discount Tier 2';
                lineItem.Tier_1_Approval__c='Discount Tier 1';
            }
            else if(tierToAllocate=='Tier 1')
            {
                lineItem.Tier_1_Approval__c='Discount Tier 1';
            }
            
            quotesToUpdate.add(lineItem);
        }
    }
    if(quotesToUpdate.size()>0)
    {
        update quotesToUpdate;
    }
    
}