trigger EmailNotificationOnCapComments on Cap__c (before update) {
    
   for(Cap__c cap: Trigger.new){
    
    Cap__c oldCap = Trigger.OldMap.get(cap.Id);
    String oldComments = oldCap.Cap_Comments__c;
    String newComments = cap.Cap_Comments__c;
    String recipients  = cap.Cap_Comments_Recipients__c;
    List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
       
        if((newComments !=NULL) && (oldComments != newComments) && (recipients !=NULL)){
           List<String> lstRecipient = recipients.split('[\\s,;:]');
           system.debug(lstRecipient.size());  
           
           List<String> lstFinal = new List<String>();
           List<String> lstInvalidEmails = new List<String>();
           String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
            for (Integer i=0; i<lstRecipient.size(); i++ ){
            String s = lstRecipient[i];
            Pattern MyPattern = Pattern.compile(emailRegex);
    		Matcher MyMatcher = MyPattern.matcher(s);
			
            if (MyMatcher.matches()) {
                lstFinal.add(s);
            	}
            else{
                lstInvalidEmails.add(s);
                cap.addError('Invalid Email Format. Please check following emails:' + lstInvalidEmails);  
                system.debug('Previous List Size:'+ lstRecipient.size()); 
           		system.debug('Final List Size:'+ lstFinal.size()); 
                //break;
                }      
            }
           
           system.debug('Previous List Size:'+ lstRecipient.size()); 
           system.debug('Final List Size:'+ lstFinal.size()); 
           system.debug('Final List Size:'+ lstInvalidEmails.size());
            
           if(lstFinal !=Null && lstInvalidEmails.size()==0 ){
           OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName='No Reply' limit 1]; 
       	   String body = 'Below new comment has been added to the Cap'+' '+ Cap.Name+ ' by ' + UserInfo.getName() + '\n' + '\n';
           body += Cap.Cap_Comments__c;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> ccTo = new List<String>();
            ccTo.add('pmusunuru@silver-peak.com');
            ccTo.add('vdubey@silver-peak.com');
            mail.setCcAddresses(ccTo);
            mail.setToAddresses(lstFinal);
            mail.setOrgWideEmailAddressId(owa.id);  
			mail.setUseSignature(false); 
			mail.setBccSender(false); 
            mail.setSaveAsActivity(false);
            mail.setSubject('Cap:' + Cap.Name +'- New comment added');
            mail.setPlainTextBody(body);
            lstMails.add(mail);
           Messaging.sendEmail(lstMails);   
        }
       }
    }  
         
}