global class SendEmailAlertHWhenMDFisPastDue implements Schedulable 
{
    global void execute(SchedulableCOntext sc)
    {
    	sendEmailAlert();
    }
    public void sendEmailAlert()
    {
    	List<MDF_Request__c> mdfs = [Select Id, Name, Owner.Name, Owner.Email from MDF_Request__c where Approval_Status__c = 'Approved' and Activity_Date__c > Today and Activity_complete__c = false ];
        if(!mdfs.isEmpty())
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        	for(MDF_Request__c mdf : mdfs )
            {
                Blob cryptoData = Crypto.encryptWithManagedIV('AES128', Blob.valueOf('DanielMDfURLToUs'), Blob.valueOf(mdf.Id + '|' + Date.today().format()));
                String url = EncodingUtil.base64Encode(cryptoData).replaceAll('\\+', '%2B');
                List<String> toAddress = new String[]{'daniel@snapbi.com'};
                mail.setReplyTo('wt_1993@foxmial.com');
                mail.setSenderDisplayName('The Silver Peak Team');
                mail.setSubject('Silver Peak MDF Request ' + mdf.Name + ' is Past Due');
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setHtmlBody('Dear ' + mdf.Owner.Name+ ',<br/><br/> Your Request Fund has been created: <a href="https://full-silverpeak.cs51.force.com/s/MarketingFundsAnonymous?id='+ url +'">'+ mdf.Name +'</a> Please complete this request.<br/><br/>If you have any questions, please contact your local Channel Sales Manager or e-mail us at channel@silver-peak.com.<br/><br/>Sincerely, <br/><br/>Silver Peak Channel Marketing');
                mail.setToAddresses(toAddress);
                mails.add(mail);
            }
            Messaging.sendEmail(mails);
        }
        
        
    }
}