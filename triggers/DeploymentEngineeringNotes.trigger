Trigger DeploymentEngineeringNotes on DE_Note__c (after insert, before update) 
{
    Set<Id> setAccountIds = new Set<Id>();
    Map<Id, list<Case>> mapAcctCases = new map<Id, List<Case>>();
    List<DE_Case_Note__c> lstDECaseNotes = new List<DE_Case_Note__c>();
    List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
    
    if(Trigger.isInsert)
    {
        for(DE_Note__c de: Trigger.new)
        {
            SetAccountIds.add(de.Account_Name__c);
        }
        system.debug('SetAccountIds:'+ SetAccountIds);
        
        if(SetAccountIds != null && SetAccountIds.size()>0)
        {
            List<Account> lstAccts = [Select Id, Name, (Select Id, ClosedDate, CaseNumber, Owner.Email from Cases where RecordtypeId IN ('012500000005AuO','012500000005Aui') AND ClosedDate = NULL)
                                      from Account where Id IN :SetAccountIds];
            for(Account acc: lstAccts)
            {
                mapAcctCases.put(acc.Id, acc.Cases);
            }
            system.debug('mapAcctCases:'+ mapAcctcases);
            
            for(DE_Note__c denote: Trigger.new)
            {
                List<Case> lstCases = mapAcctCases.get(denote.Account_Name__c);
                if(lstCases != null && lstCases.size()>0)
                {
                    for(Case c: lstCases)
                    {
                        DE_Case_Note__c decnote= new DE_Case_Note__c();
                        decnote.Case_Number__c = c.Id;
                        decnote.DE_Note__c = denote.Id;
                        decnote.Case_Owner_Email__c = c.Owner.Email;
                        lstDECaseNotes.add(decnote);
                    }
                } 
            }
            insert lstDECaseNotes;
        }
    }
    if(Trigger.isUpdate)
    {
        for(DE_Note__c newDE: Trigger.new)
        {
            DE_Note__c oldDE = Trigger.Oldmap.get(newDE.Id);
            String oldRecipients = oldDE.Additional_Email_Recipients__c ;
            String newRecipients = newDE.Additional_Email_Recipients__c ; 
            
            if((newRecipients !=NULL) && (oldRecipients != newRecipients))
            {
                List<String> lstRecipient = newRecipients.split('[;,]',0);
                
                system.debug('Previous List Size:'+ lstRecipient.size()); 
                
                //Check for email format validation 
                List<String> lstFinal = new List<String>();
                List<String> lstInvalidEmails = new List<String>();
                String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
                for (Integer i=0; i<lstRecipient.size(); i++ ){
                    String s = lstRecipient[i];
                    Pattern MyPattern = Pattern.compile(emailRegex);
                    Matcher MyMatcher = MyPattern.matcher(s);
                    
                    if (MyMatcher.matches()) 
                    {
                        lstFinal.add(s);
                    }
                    else{
                        lstInvalidEmails.add(s);
                        newDE.addError('Invalid Email Format. Please check following emails:' + lstInvalidEmails);  
                        system.debug('Previous List Size:'+ lstRecipient.size()); 
                        system.debug('Final List Size:'+ lstFinal.size()); 
                    }      
                }
                
                system.debug('Previous List Size:'+ lstRecipient.size()); 
                system.debug('Final List Size:'+ lstFinal.size()); 
                system.debug('Final List Size:'+ lstInvalidEmails.size());
                
                if(lstFinal !=Null && lstInvalidEmails.size()==0 )
                {
                    String body = 'A new Deployment Engineering Note has been created for'+' '+ newDE.Account_Name__r.Name + ' ' + ' by ' + UserInfo.getName() + '\n' + '\n';
                    body += 'Deployment Engineering Notes: '+ '\n' ;
                    body += newDe.DE_Notes__c;
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(lstFinal);
                    mail.setUseSignature(false); 
                    mail.setBccSender(false); 
                    mail.setSaveAsActivity(false);
                    mail.setSubject('DE Note:' + ' ' + newDe.Name + ' ' + 'Created');
                    mail.setPlainTextBody(body);
                    lstMails.add(mail);    
                    
                }
            }
            
        }
        Messaging.sendEmail(lstMails); 
    }
}