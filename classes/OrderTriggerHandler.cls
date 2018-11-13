public class OrderTriggerHandler implements ITriggerHandler {
    
    public Boolean IsDisabled() {
        return false;
    }
    public static Boolean runRecalc = true;
    
    public void BeforeInsert(List<SObject> newItems) {
        setInitialRecalc((List<Order>)newItems);
        setDefaultDates((List<Order>)newItems, new Map<Id, Order>());
    }
    public void AfterInsert(Map<Id, SObject> newItems) {}
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        setDefaultDates((List<Order>)newItems.values(), (Map<Id, Order>)oldItems);
        if(runRecalc) recalculateEcAddOnValues((List<Order>)newItems.values(), (Map<Id, Order>) oldItems);
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        rolldownShipDate((List<Order>)newItems.values(), (Map<Id, Order>) oldItems);
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
            
            Map<Id, SBQQ__Quote__c> parentQuotes = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__StartDate__c, End_Date__c FROM SBQQ__Quote__c WHERE Id = :quoteIds]);
            
            for(Order o : newItems) {
                Boolean proceed = (Trigger.isInsert ? o.SBQQ__Quote__c != null : o.TemporaryStartDateHolder__c != null);
                if(parentQuotes.containsKey(o.SBQQ__Quote__c)) {
                    if(proceed && parentQuotes.get(o.SBQQ__Quote__c).SBQQ__StartDate__c != null) {
                        if(o.EffectiveDate != parentQuotes.get(o.SBQQ__Quote__c).SBQQ__StartDate__c && parentQuotes.containsKey(o.SBQQ__Quote__c) && parentQuotes.get(o.SBQQ__Quote__c).End_Date__c != null) {
                            if(o.TemporaryStartDateHolder__c == null) { // on insert
                                o.TemporaryStartDateHolder__c = o.EffectiveDate;
                                Integer daysBetween = parentQuotes.get(o.SBQQ__Quote__c).SBQQ__StartDate__c.daysBetween(parentQuotes.get(o.SBQQ__Quote__c).End_Date__c);
                                o.EndDate = o.TemporaryStartDateHolder__c.addDays(daysBetween);
                            } else {
                                o.TemporaryStartDateHolder__c = null;
                            }
                        } else {
                            o.EndDate = parentQuotes.get(o.SBQQ__Quote__c).End_Date__c;
                        }
                    }
                    if(Trigger.isUpdate) {
                        if(o.Type == 'Amendment' && oldItems.get(o.Id).Type != 'Amendment') {
                            Integer daysBetween = parentQuotes.get(o.SBQQ__Quote__c).SBQQ__StartDate__c.daysBetween(parentQuotes.get(o.SBQQ__Quote__c).End_Date__c);
                            o.EndDate = o.EffectiveDate.addDays(daysBetween);
                        }
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
    
    private static void rolldownShipDate(List<Order> newItems, Map<Id, Order> oldItems) {
        Map<Id, Date> newShipDate = new Map<Id, Date>();
        for(Order o : newItems) {
            if(o.Ship_Date__c != oldItems.get(o.Id).Ship_Date__C) {
                newShipDate.put(o.Id, o.Ship_Date__c);
            }
        }
        List<Asset> assetUpdate = new List<Asset>();
        for(SBQQ__SubscribedAsset__c sa : [SELECT Id, SBQQ__Subscription__r.SBQQ__Contract__r.SBQQ__Order__c, SBQQ__Asset__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__r.SBQQ__Contract__r.SBQQ__Order__c IN :newShipDate.keySet()]) {
            assetUpdate.add(new Asset(
                Id = sa.SBQQ__Asset__c,
                Ship_Date__c = newShipDate.get(sa.SBQQ__Subscription__r.SBQQ__Contract__r.SBQQ__Order__c)
            ));
        }
        if(!assetUpdate.isEmpty()) update assetUpdate;
    }
    
    private static void recalculateEcAddOnValues(List<Order> newItems, Map<Id, Order> oldItems) {
        Set<Id> orderIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();
        
        Map<Id, List<OrderItem>> quoteLinesOriginal = new Map<Id, List<OrderItem>>();
        Map<Id, List<OrderItem>> quoteLinesAddOn = new Map<Id, List<OrderItem>>();
        Boolean runLogic = false;
        for(Order o : newItems) {
            Boolean runCode = (o.EffectiveDate != oldItems.get(o.Id).EffectiveDate) || (o.Ship_Date__c != oldItems.get(o.Id).Ship_Date__c) || o.RecalculateFields__c;
            if(o.Type == 'Amendment' && runCode) {
                runLogic = true;
                orderIds.add(o.Id);
                quoteIds.add(o.SBQQ__Quote__c);
            }
        }
        if(runLogic) {
            Map<Id, SBQQ__Quote__c> parentQuote = new Map<Id, SBQQ__Quote__c>(
                [SELECT Id, Daily_Rate_Original__c, SBQQ__StartDate__c, End_Date__c, Daily_Rate_Add_on__c, Cumulative_Daily_Value__c, Days_to_Credit__c, Days_of_Value__c, Credit_Value__c, License_End_Date__c, Length_In_Years__c, 
                    SBQQ__MasterContract__r.StartDate, SBQQ__MasterContract__r.EndDate, SBQQ__MasterContract__r.ContractTerm, SBQQ__MasterContract__r.SBQQ__Quote__r.SBQQ__StartDate__c, Calculate_EC_End_Date__c,
                (SELECT Id FROM SBQQ__Orders__r),
                (SELECT Id, SBQQ__UpgradedSubscription__r.Net_Total__c FROM SBQQ__LineItems__r WHERE SBQQ__EffectiveQuantity__c = 0)
                FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment']
            );
            
            for(OrderItem oi : [SELECT Id, TotalPrice, SBQQ__ProrateMultiplier__c, Net_Total__c, SBQQ__OrderedQuantity__c, EndDate, End_Date__c, ServiceDate, SBQQ__SubscriptionTerm__c, Quantity, OrderId, SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c FROM OrderItem WHERE OrderId IN :orderIds]) {
                if(!quoteLinesOriginal.containsKey(oi.OrderId)) quoteLinesOriginal.put(oi.OrderId, new List<OrderItem>());
                if(!quoteLinesAddOn.containsKey(oi.OrderId)) quoteLinesAddOn.put(oi.OrderId, new List<OrderItem>());
                
                if(oi.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c <= 0) {
                    quoteLinesOriginal.get(oi.OrderId).add(oi);
                } else {
                    quoteLinesAddOn.get(oi.OrderId).add(oi);
                }
            }
            
            for(Order o : newItems) {
                Boolean runCode = (o.EffectiveDate != oldItems.get(o.Id).EffectiveDate) || (o.Ship_Date__c != oldItems.get(o.Id).Ship_Date__c) || o.RecalculateFields__c;
                SBQQ__Quote__c pq = parentQuote.get(o.SBQQ__Quote__c);
                if(runCode && o.Type == 'Amendment' && o.Status != 'Activated' && o.Product_Type__c == 'EDGECONNECT') {
                    Integer orderCount = pq.SBQQ__Orders__r.size();
                    Date lastEndDateAddOn = System.today();
                    Decimal orgnalDailyPricing = 0;
                    Decimal quotedQtyPricing;
                    Integer contTerm = (pq.SBQQ__MasterContract__r.ContractTerm/12);
                    
                    if(quoteLinesAddOn.containsKey(o.Id)) {
                        for(SBQQ__QuoteLine__c ql : pq.SBQQ__LineItems__r) {
                            try { orgnalDailyPricing += ql.SBQQ__UpgradedSubscription__r.Net_Total__c; } catch(Exception e) {}
                        }
                        if(orgnalDailyPricing != 0) orgnalDailyPricing  /= (365 * contTerm);
                        for(OrderItem oi : quoteLinesAddOn.get(o.Id)) {
                            lastEndDateAddOn = (pq.Calculate_EC_End_Date__c ? oi.ServiceDate.addDays(365 * contTerm) : oi.EndDate);
                            //quotedQuantity.put(oi.Id, oi.SBQQ__OrderedQuantity__c / oi.SBQQ__QuotedQuantity__c)
                            quotedQtyPricing = oi.Net_Total__c / (pq.Calculate_EC_End_Date__c ? (365 * contTerm) : (365 * oi.SBQQ__ProrateMultiplier__c));
                        }
                        if(o.Product_Type__c == 'EDGECONNECT') {
                            try { o.Daily_Rate_Original__c = orgnalDailyPricing;                                                                                  } catch(Exception e) {}
                            try { o.Daily_Rate_Add_on__c = quotedQtyPricing ;                                                                                     } catch(Exception e) {}//pq.Daily_Rate_Add_on__c;   
                            try { o.Cumulative_Daily_Value__c = o.Daily_Rate_Original__c + o.Daily_Rate_Add_on__c;                                                } catch(Exception e) {}//pq.Cumulative_Daily_Value__c;
                            try { o.Days_to_Credit__c = pq.SBQQ__MasterContract__r.EndDate.daysBetween(lastEndDateAddOn);                                       } catch(Exception e) {}
                            try { o.Credit_Value__c = o.Daily_Rate_Add_on__c * o.Days_to_Credit__c;                                                               } catch(Exception e) {}
                            try { o.Days_of_Value__c = o.Credit_Value__c / o.Cumulative_Daily_Value__c;                                                           } catch(Exception e) {}
                            try { 
                                o.License_End_Date__c = pq.SBQQ__MasterContract__r.EndDate.addDays(Integer.valueOf(o.Days_of_Value__c) + 1);   
                            } catch(Exception e) {}
                        }
                    }
                }
            }
        
        }
    }
    
}