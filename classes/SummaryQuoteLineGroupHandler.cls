public class SummaryQuoteLineGroupHandler {
    public static void rollUpQuoteLinesOnCreate(List<SBQQ__QuoteLine__c> lines)
    {
        Set<String> groupIds = new Set<String>();
        for(SBQQ__QuoteLine__c line : lines)
        {
            if(line.SBQQ__Group__c != null)
            {
                groupIds.add(line.SBQQ__Group__c);
            }
        }
        
        if(!groupIds.isEmpty())
        {
            calculateTotalPrice(groupIds);
        }
    }
    
    public static void rollUpQuoteLinesOnUpdate(Map<Id,SBQQ__QuoteLine__c> oldMap, Map<Id,SBQQ__QuoteLine__c> newMap)
    {
        SBQQ__QuoteLine__c oldLine;
        Set<String> groupIds = new Set<String>();
        for(SBQQ__QuoteLine__c newLine : newMap.values())
        {
            oldLine = oldMap.get(newLine.Id);
            if(oldLine.SBQQ__Group__c != newLine.SBQQ__Group__c)
            {
                if(String.isNotEmpty(oldLine.SBQQ__Group__c))
                {
                    groupIds.add(oldLine.SBQQ__Group__c);
                }
                if(String.isNotEmpty(newLine.SBQQ__Group__c))
                {
                    groupIds.add(newLine.SBQQ__Group__c);
                }
            }
            else
            {
                if (oldLine.SBQQ__Group__c != null && validateTotal(oldLine, newLine))
                {
                    groupIds.add(oldLine.SBQQ__Group__c);
                }
            }
        }
        
        if(!groupIds.isEmpty())
        {
            calculateTotalPrice(groupIds);
        }
    }    
        
    public static void rollUpQuoteLinesOnDelete(Map<Id, SBQQ__QuoteLine__c> oldMap)
    {
        Set<String> groupIds = new Set<String>();
        for(SBQQ__QuoteLine__c oldLine : oldMap.values())
        {
            if(oldLine.SBQQ__Group__c != null)
            {
                groupIds.add(oldLine.SBQQ__Group__c);    
            }
        }
        if(!groupIds.isEmpty())
        {
            calculateTotalPrice(groupIds);            
        }
    }    
        
    private static void  calculateTotalPrice(Set<String> groupIds)
    {
        /*
        List<SBQQ__QuoteLineGroup__c> lineGroups = [select Id, SBQQ__EndDate__c, SBQQ__ListTotal__c, SBQQ__NetTotal__c, SBQQ__CustomerTotal__c, 
                                                     (select Id, SBQQ__ListTotal__c, SBQQ__NetTotal__c, SBQQ__CustomerTotal__c from SBQQ__LineItems__r)
                                                    from SBQQ__QuoteLineGroup__c where Id in :groupIds];
        
        for(SBQQ__QuoteLineGroup__c lineGroup : lineGroups)
        {
            Decimal listTotal = 0;
            Decimal netTotal = 0;
            Decimal customerTotal = 0;
            for(SBQQ__QuoteLine__c line : lineGroup.SBQQ__LineItems__r)
            {
                listTotal += line.SBQQ__ListTotal__c == null ? 0 : line.SBQQ__ListTotal__c;
                netTotal += line.SBQQ__NetTotal__c == null ? 0 : line.SBQQ__NetTotal__c;
                customerTotal += line.SBQQ__CustomerTotal__c == null ? 0 : line.SBQQ__CustomerTotal__c;
            }
            lineGroup.SBQQ__ListTotal__c = listTotal;
            lineGroup.SBQQ__NetTotal__c = netTotal;
            lineGroup.SBQQ__CustomerTotal__c = customerTotal; 
            lineGroup.SBQQ__EndDate__c = Date.today();
        }  
        
        
        List<SBQQ__QuoteLineGroup__c> lineGroups = [select Id, SBQQ__EndDate__c, SBQQ__ListTotal__c, SBQQ__NetTotal__c, SBQQ__CustomerTotal__c, 
                                                     (select Id, sum(SBQQ__ListTotal__c) listTotal, sum(SBQQ__NetTotal__c) netToal, sum(SBQQ__CustomerTotal__c) customerTotal from SBQQ__LineItems__r)
                                                    from SBQQ__QuoteLineGroup__c where Id in :groupIds];
        */
        List<SBQQ__QuoteLineGroup__c> lineGroups = [select Id, SBQQ__EndDate__c, SBQQ__ListTotal__c, SBQQ__NetTotal__c, SBQQ__CustomerTotal__c
                                                    from SBQQ__QuoteLineGroup__c where Id in :groupIds];
        
        for(AggregateResult result : [select SBQQ__Group__c, sum(SBQQ__ListTotal__c) listTotal, sum(SBQQ__NetTotal__c) netTotal, sum(SBQQ__CustomerTotal__c) customerTotal from SBQQ__QuoteLine__c where SBQQ__Group__c in :groupIds group by SBQQ__Group__c])
        {
            for(SBQQ__QuoteLineGroup__c lineGroup : lineGroups)
            {
                if(lineGroup.Id == result.get('SBQQ__Group__c'))
                {
                    lineGroup.SBQQ__ListTotal__c = (Decimal)result.get('listTotal');
                    lineGroup.SBQQ__NetTotal__c = (Decimal)result.get('netTotal');
                    lineGroup.SBQQ__CustomerTotal__c = (Decimal)result.get('customerTotal');
                }
            }
        }
        //summing only license totals
        for(AggregateResult result : [select SBQQ__Group__c, sum(SBQQ__NetTotal__c) netLicenseTotal from SBQQ__QuoteLine__c where 
                SBQQ__Product__r.Family = 'Virtual Image' AND SBQQ__Product__r.Name LIKE 'EC%' 
                AND SBQQ__Group__c in :groupIds group by SBQQ__Group__c ])
        {
            for(SBQQ__QuoteLineGroup__c lineGroup : lineGroups)
            {
                if(lineGroup.Id == result.get('SBQQ__Group__c'))
                {
                    
                    lineGroup.GroupLicenseValue__c = (Decimal)result.get('netLicenseTotal');
                    
                }
            }
        }
System.debug('before : ' + lineGroups);        
        update lineGroups;
System.debug('after : ' + [select Id, SBQQ__EndDate__c, SBQQ__ListTotal__c, SBQQ__NetTotal__c, SBQQ__CustomerTotal__c from SBQQ__QuoteLineGroup__c where Id in :groupIds]);        
    }
    
    private static Boolean validateTotal(SBQQ__QuoteLine__c oldLine, SBQQ__QuoteLine__c newLine)
    {
        return ((oldLine.SBQQ__ListTotal__c != newLine.SBQQ__ListTotal__c) || 
                (oldLine.SBQQ__NetTotal__c != newLine.SBQQ__NetTotal__c) ||
                (oldLine.SBQQ__CustomerTotal__c != newLine.SBQQ__CustomerTotal__c));
    }
}