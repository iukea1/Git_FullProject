/*
 * 1. Send Email Alert to User When the MDF Past Due 7 Days(Approval_Status = 'Approved' && MDF_Status__c = 'Past Due' And Activity_Complete__c = 'false' )
 * 2. create a campaign after MDF is approved
 *
 */
trigger SendEmailAndCreateCampaignOnMDF on MDF_Request__c (after Update)
{
    List<MDF_Request__c> emailMdf = new List<MDf_Request__c>();
    List<MDf_Request__c> updateMDF = new List<MDF_Request__c>();
    for(MDF_Request__c newMDf : Trigger.new)
    {
        for(MDF_Request__c oldMDF : Trigger.old)
        {
            if( newMDf.Approval_Status__c == 'Approved' && newMDF.SendReminder__c == true && newMDf.MDF_Status__c == 'Past Due')
            {
                if(newMDF.Id == oldMDF.Id)
                {
                    if(newMDF.SendReminder__c == true && oldMDF.SendReminder__c == false)
                    {
                        emailMdf.add(newMDf);
                    }
                }
            }
            if(oldMDF.Approval_Status__c != 'Approved' && newMDf.Approval_Status__c == 'Approved' && newMDF.Campaign__c == null)
            {
                updateMDF.add(newMDF);
            }
        }
    }
    if(!emailMdf.isEmpty())
    {
        List<MDF_Request__c> mdfs = [Select Id, Name, Owner.Name,Owner.FirstName, Owner.Email, Owner.Profile.Name, Contact__c, Contact__r.Name,Contact__r.FirstName, Contact__r.Email from MDF_Request__c where Id in: emailMdf];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> et = [Select Id, Name, Body, HtmlValue,Subject from EmailTemplate where DeveloperName like '%New_MDF_Approved_Post_Event%' limit 1];
        if(!et.isEmpty())
        {
            String url;
            for(MDF_Request__c mdf : mdfs )
            {
                url = SendMdfUrlToClientController.encryptParameter(mdf.Id);
                String recipient = mdf.Owner.Profile.Name == '13g-SP Partner Community' ? mdf.Owner.Email : mdf.Contact__r.Email;
                mail.setToAddresses(new String[] {recipient});
                mail.setSenderDisplayName('The Silver Peak Team');
                mail.setSubject(mergeEmail(et[0].Subject, mdf, url));
                mail.setPlainTextBody(mergeEmail(et[0].Body, mdf, url));
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mails.add(mail);
            }
            Messaging.sendEmail(mails);
        }
    }
    if(!updateMDF.isEmpty())
    {
        List<MDF_Request__c> mdfs = [Select Id, Campaign__c, Activity_Date__c, Event_Campaign_Name__c, Event_Location_City__c, GEO__c, Account__r.Name  from MDF_Request__c where Id in: updateMDF];
        Map<MDF_Request__c,Campaign> mdfAndCampaign = new Map<MDF_Request__c, Campaign>();
        for(MDF_Request__c mdf : mdfs)
        {
            MDFAndCampaign.put(mdf, new Campaign(Name = getCampaignName(mdf)));
        }
        try
        {
            insert mdfAndCampaign.values();
            for(MDF_Request__c mdf : mdfAndCampaign.keySet())
            {
                mdf.Campaign__c = mdfAndCampaign.get(mdf).Id;
            }
            upsert new List<MDF_Request__c>(MDFAndCampaign.keySet());
        }
        catch(Exception ex)
        {
            SilverPeakUtils.logException(ex);
        }
    }
    
    private String mergeEmail(String originalValue, MDF_Request__c mdf, String encryptedLink)
    {
        String recipientName = mdf.Owner.Profile.Name == '13g-SP Partner Community' ? mdf.Owner.FirstName : mdf.Contact__r.FirstName;
        return originalValue.replace('{!MDF_Request__c.Owner.Name}', recipientName).replace('{!MDF_Request__c.OwnerFirstName}', recipientName).replace('{!MDF_Request__c.Link}','https://partners.silver-peak.com/s/MarketingFundsAnonymous?id=' + encryptedLink).replace('{!MDF_Request__c.Name}', mdf.Name);
    }
    
    private String getCampaignName(MDF_Request__c mdf)
    {
        if(mdf != null)
        {
            String fyfq = getQuarter(mdf.Activity_Date__c);
            String activityDate = (mdf.Activity_Date__c == null) ? '' : mdf.Activity_Date__c.format();
            return fyfq + '_' + mdf.GEO__c + '_' + mdf.Event_Campaign_Name__c + '_' + mdf.Account__r.Name + '_' + mdf.Event_Location_City__c + '_' + activityDate;
        }
        else
        {
            return null;
        }
    }
    
    private String getQuarter(Date d)
    {
        if(d != null)
        {
            Integer month = d.month();
            return 'FY' + String.valueOf(d.year()).subString(2,4) + 'Q' + (Integer)Math.ceil(math.mod(month + 5, 12)/4.0);
        }
        else
        {
            return '';
        }
    }
}