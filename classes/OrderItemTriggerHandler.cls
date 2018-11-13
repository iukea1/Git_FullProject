public class OrderItemTriggerHandler implements ITriggerHandler {
    
    public Boolean IsDisabled() {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) {
        setDates(newItems);
    }
    public void AfterInsert(Map<Id, SObject> newItems) {
       //updateStartDateForRenewals(newItems);
   }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        //setDates(newItems.values());
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void BeforeDelete(Map<Id,SObject> oldItems) {}
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> newItems) {}
    
    
    
    private static void setDates(List<OrderItem> newList) {
        Set<Id> orderIds = new Set<Id>();
        Set<Id> quoteLineIds = new Set<Id>();
        for(OrderItem oi : newList) {
            orderIds.add(oi.OrderId);
            quoteLineIds.add(oi.SBQQ__QuoteLine__c);
        }
        Map<Id, Order> parentOrders = new Map<Id, Order>([SELECT Id, TemporaryStartDateHolder__c, Ship_Date__c, EffectiveDate, EndDate, End_Date__c, Type, Product_Type__c FROM Order WHERE Id IN :orderIds]);
        Map<Id, SBQQ__QuoteLine__c> parentQls = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c, End_Date__c, SBQQ__Quote__r.End_Date__c, SBQQ__Quote__r.SBQQ__StartDate__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds]);
        
        Map<Id, Order> parentOrderUpdate = new Map<Id, Order>();
        
        Set<Id> parentOrderIds = new Set<Id>();
        for(OrderItem oi : newList) {
            if(parentQls.containsKey(oi.SBQQ__QuoteLine__c)) {
                SBQQ__QuoteLine__c ql = parentQls.get(oi.SBQQ__QuoteLine__c);
                Order pOrder = parentOrders.get(oi.OrderId);
                
                if(pOrder.Type == 'Amendment' && pOrder.Product_Type__c == 'NX/VX') parentOrderIds.add(pOrder.Id); //end date adjustment for nx/vx upgrade
                
                if(ql.SBQQ__SubscriptionTerm__c != null && ql.SBQQ__SubscriptionTerm__c != 0) {
                    oi.CotermEndDate__c = oi.EndDate;
                    if(oi.ServiceDate != ql.SBQQ__StartDate__c && ql.End_Date__c != null && ql.SBQQ__StartDate__c != null) {
                        Integer daysBetween = ql.SBQQ__StartDate__c.daysBetween(ql.End_Date__c);
                        
                        //if(Userinfo.getFirstName() == 'Ronald') System.assertEquals('>>> ' +pOrder.EffectiveDate + '-'+  pOrder.EndDate,  ' >> ' + oi.ServiceDate + ' ' + oi.EndDate + ' '+daysBetween);
                        oi.EndDate = oi.ServiceDate.addDays(daysBetween);
                        
                        if(oi.EndDate > pOrder.EndDate) oi.EndDate = pOrder.EndDate;
                        
                    } else if(oi.ServiceDate == ql.SBQQ__StartDate__c && ql.End_Date__c != null) {
                        oi.EndDate = ql.End_Date__c;
                    }
                }
            }
            
        }
        if(!parentOrderIds.isEmpty() && Trigger.isInsert) runNxVxUpgradeResetEndDates(parentOrderIds);
        
    }
    
    //set the order and order product end dates to the custom end date's value 
    @future
    public static void runNxVxUpgradeResetEndDates(Set<Id> orderIds) {
        List<Order> orderUpdate = new List<Order>();
        List<OrderItem> orderItemUpdate = new List<OrderItem>();
        Map<Id, SBQQ__QuoteLine__c> quoteLineUpdateInitial = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> quoteLineSetEndDateBack = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, Date> finalDateHolder = new Map<Id, Date>();
        
        for(Order o : [SELECT Id, EndDate, SBQQ__Quote__r.End_Date__c, EffectiveDate, (SELECT Id, EndDate, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__EndDate__c, SBQQ__QuoteLine__r.End_Date__c FROM OrderItems) FROM Order WHERE Id IN :orderIds AND Type = 'Amendment' AND Product_Type__c  = 'NX/VX']) {
            o.EndDate = o.SBQQ__Quote__r.End_Date__c;
            for(OrderItem oi : o.OrderItems) {
                //oi.ServiceDate= o.EffectiveDate;
                //quoteUpdate.put()
                oi.End_Date__c = oi.SBQQ__QuoteLine__r.End_Date__c;
                quoteLineUpdateInitial.put(oi.SBQQ__QuoteLine__c, new SBQQ__QuoteLine__c(Id = oi.SBQQ__QuoteLine__c,SBQQ__EndDate__c=oi.EndDate));
                quoteLineSetEndDateBack.put(oi.SBQQ__QuoteLine__c, new SBQQ__QuoteLine__c(Id = oi.SBQQ__QuoteLine__c,SBQQ__EndDate__c=oi.SBQQ__QuoteLine__r.SBQQ__EndDate__c));
                orderItemUpdate.add(oi);
            }
            orderUpdate.add(o);
        }
        update orderUpdate;
        update orderItemUpdate;
    }
    
}