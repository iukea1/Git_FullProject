/*
 * Updates the SendT60Email, SendT90Email and SendExpirationEmail on Account when hitting the end date.
 */
global class ContractExpirationNotification implements Schedulable, Database.Batchable<sObject>, Database.Stateful
{
    private Integer t0Contracts;
    private Integer t30Contracts;
    private Integer t60Contracts;
    private Integer t90Contracts;
    
    global void execute(SchedulableContext sc)
    {
        ContractExpirationNotification notification = new ContractExpirationNotification();
        Database.executeBatch(notification, 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        t0Contracts = 0;
        t60Contracts = 0;
        t90Contracts = 0;
        t30Contracts = 0;
        return Database.getQueryLocator([select Id, (select Id, EndDate from Contracts where Status='Activated' and EndDate in (:Date.today().addDays(-1), :Date.today(), :Date.today().addDays(60),:Date.today().addDays(30), :Date.today().addDays(90)) and Perpetual_Product_Count__c>0) from Account where Id in (select AccountId from Contract where Status='Activated' and EndDate in (:Date.today().addDays(-1), :Date.today(), :Date.today().addDays(60), :Date.today().addDays(90),:Date.today().addDays(30)) and Perpetual_Product_Count__c>0)]);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> objs)
    {
        List<Contract> contracts = new List<Contract>();
        if(objs.size() > 0)
        {
            Boolean sending = false;
            Account acc = (Account)objs[0];
            for(Contract ct : acc.Contracts)
            {
                if(ct.EndDate == Date.today().addDays(-1))
                {
                    ct.Status = 'Expired';
                    contracts.add(ct);
                    sending = true;
                }
                else if(ct.EndDate == Date.today())
                {
                    if(hasActiveAssets(ct.Id))
                    {
                        ct.Trigger_Notice__c = 'T0';
                        contracts.add(ct);
                        acc.SendExpirationEmail__c = true;
                        sending = true;
                        t0Contracts++;
                    }
                }
                else if(ct.EndDate == Date.today().addDays(30))
                {
                    ct.Trigger_Notice__c = 'T30';
                    contracts.add(ct);
                    acc.SendExpirationEmail__c = true;
                    sending = true;
                    t30Contracts++;
                }
                else if(ct.EndDate == Date.today().addDays(60))
                {
                    ct.Trigger_Notice__c = 'T60';
                    contracts.add(ct);
                    acc.SendExpirationEmail__c = true;
                    sending = true;
                    t60Contracts++;
                }
                else if(ct.EndDate == Date.today().addDays(90))
                {
                    ct.Trigger_Notice__c = 'T90';
                    contracts.add(ct);
                    acc.SendExpirationEmail__c = true;
                    sending = true;
                    t90Contracts++;
                }
            }
            if(sending)
            {
                try
                {
                    update contracts;
                    update acc;
                }
                catch(Exception ex)
                {
                    String message = 'Error occured when sending the contract expiration email on account: ' + acc.Id + '. The error message is: \r\n' + ex.getMessage();
                    sendEmail('Error occured when sending the contract expiration email', message);
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        String message = 'T0 contracts updated: ' + t0Contracts + '\r\nT60 contracts updated: ' + t60Contracts + '\r\nT90 contracts updated: ' +t90Contracts;
        sendEmail('Contract Expiration Notification Finished', message);
    }
    
    private void sendEmail(String subject, String body)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setSaveAsActivity(false);
        mail.setToAddresses(new String[] { 'notifications@silver-peak.com'});
        mail.setUseSignature(false);
        if(!Test.isRunningTest())
        {
        	Messaging.sendEmail(new Messaging.Email[] { mail });
        }
    }
    
    private Boolean hasActiveAssets(Id contractId)
    {
        for(SBQQ__SubscribedAsset__c asset : [select Id, SBQQ__Asset__r.Status from SBQQ__SubscribedAsset__c where SBQQ__Subscription__r.SBQQ__Contract__c=:contractId and SBQQ__Active__c=true])
        {
            if(asset.SBQQ__Asset__r.Status == 'Conditional PO' || asset.SBQQ__Asset__r.Status == 'Customer Owned' || asset.SBQQ__Asset__r.Status == 'Cold Spare' || asset.SBQQ__Asset__r.Status.startsWith('Pending Return'))
            {
                return true;
            }
        }
        return false;
    }
}