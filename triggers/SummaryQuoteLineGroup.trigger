/*
 * Summarizes total to line group
 */
trigger SummaryQuoteLineGroup on SBQQ__QuoteLine__c (after insert, after update, after delete, after undelete) 
{
	if(Trigger.isInsert || Trigger.isUndelete)
    {
        SummaryQuoteLineGroupHandler.rollUpQuoteLinesOnCreate(Trigger.new);
    }
    else if(Trigger.isUpdate)
    {
        SummaryQuoteLineGroupHandler.rollUpQuoteLinesOnUpdate(Trigger.oldMap, Trigger.newMap);
    }
    else if(Trigger.isDelete)
    {
        SummaryQuoteLineGroupHandler.rollUpQuoteLinesOnDelete(Trigger.oldMap);
    }
}