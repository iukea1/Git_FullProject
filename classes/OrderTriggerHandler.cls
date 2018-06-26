public class OrderTriggerHandler implements ITriggerHandler {
    
    public Boolean IsDisabled() {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) {
        setInitialRecalc((List<Order>)newItems);
    }
    public void AfterInsert(Map<Id, SObject> newItems) {}
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        setDefaultDates((List<Order>)newItems.values(), (Map<Id, Order>)oldItems);
        recalculateEcAddOnValues((List<Order>)newItems.values(), (Map<Id, Order>) oldItems);
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) {}
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> newItems) {}
    
    //methods
    public static Boolean disableSetDate = false;
    private static void setDefaultDates(List<Order> newItems, Map<Id, Order> oldItems) {
        if(!disableSetDate) {
            Set<Id> quoteIds = new Set<Id>();
            Set<Id> orderIds = new Set<Id>();
            for(Order o : newItems) {
                quoteIds.add(o.SBQQ__Quote__c);
            }
            
            Map<Id, SBQQ__Quote__c> parentQuotes = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE Id = :quoteIds]);
            
            for(Order o : newItems) {
                if(o.SBQQ__Quote__c != null && oldItems.get(o.Id).SBQQ__Quote__c == null) {
                    //System.assertEquals(parentQuotes+'', o+' ');
                    if(o.EffectiveDate != parentQuotes.get(o.SBQQ__Quote__c).SBQQ__StartDate__c) {
                        o.TemporaryStartDateHolder__c = o.EffectiveDate;
                        o.EffectiveDate = parentQuotes.get(o.SBQQ__Quote__c).SBQQ__StartDate__c;
                        orderIds.add(o.Id);
                    }
                }
            }
            disableSetDate = true;
        }
    }
    
    
    private static void setInitialRecalc(List<Order> newItems) {
        for(Order o : newItems) {
            o.RecalculateFields__c = true;
        }
    }

    private static void recalculateEcAddOnValues(List<Order> newItems, Map<Id, Order> oldItems) {
        Set<Id> orderIds = new Set<Id>();
        //System.assertEquals(123, 234);
        Map<Id, List<OrderItem>> quoteLinesOriginal = new Map<Id, List<OrderItem>>();
        Map<Id, List<OrderItem>> quoteLinesAddOn = new Map<Id, List<OrderItem>>();
        
        for(Order o : newItems) {
            orderIds.add(o.Id);
        }
        
        for(OrderItem oi : [SELECT Id, TotalPrice, EndDate, ServiceDate, SBQQ__SubscriptionTerm__c, Quantity, OrderId, SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c FROM OrderItem WHERE OrderId IN :orderIds]) {
            if(!quoteLinesOriginal.containsKey(oi.OrderId)) quoteLinesOriginal.put(oi.OrderId, new List<OrderItem>());
            if(!quoteLinesAddOn.containsKey(oi.OrderId)) quoteLinesAddOn.put(oi.OrderId, new List<OrderItem>());
            
            if(oi.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c <= 0) {
                quoteLinesOriginal.get(oi.OrderId).add(oi);
            } else {
                quoteLinesAddOn.get(oi.OrderId).add(oi);
            }
        }
        
        for(Order o : newItems) {
            Boolean runCode = (o.EffectiveDate != oldItems.get(o.Id).EffectiveDate) || (o.Ship_Date__c!= oldItems.get(o.Id).Ship_Date__c) || o.RecalculateFields__c;
            
            if(runCode) {
                Decimal totalPriceOriginal = 0.0;
                Decimal totalPriceAddOn = 0.0;
                Date lastEndDateAddOn = System.today();
                Integer term = 12; //Integer.valueOf(q.Term__c != null ? q.Term__c : '1');      
                
                if(quoteLinesOriginal.containsKey(o.Id)) {
                    for(OrderItem oi : quoteLinesOriginal.get(o.Id)) {
                        totalPriceOriginal += oi.TotalPrice;
                    }
                }
                if(quoteLinesAddOn.containsKey(o.Id)) {
                    for(OrderItem oi : quoteLinesAddOn.get(o.Id)) {
                        totalPriceAddOn  += oi.TotalPrice;
                        if(lastEndDateAddOn < oi.EndDate) lastEndDateAddOn = oi.EndDate;
                    }
                }
                
                o.Daily_Rate_Original__c = totalPriceOriginal / (term * 365);
                o.Daily_Rate_Add_on__c = totalPriceAddOn / (term * 365);
                o.Cumulative_Daily_Value__c = o.Daily_Rate_Original__c + o.Daily_Rate_Add_on__c;
                //o.Days_to_Credit__c = lastEndDateAddOn.daysBetween(o.License_End_Date__c);
                o.Credit_Value__c = o.Daily_Rate_Add_on__c * 1;// o.Days_to_Credit__c;
                o.Days_of_Value__c = o.Credit_Value__c / (o.Cumulative_Daily_Value__c == 0 ? 1 : o.Cumulative_Daily_Value__c);
                //o.License_End_Date__c = o.License_End_Date__c.addDays(Integer.valueOf(o.Days_of_Value__c));
            }
        }
        
        
        
    }
}