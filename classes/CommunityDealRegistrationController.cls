global with sharing class CommunityDealRegistrationController 
{
    private String regionFilters;
    private Contact currUserCont;
    private Account currUserAct;
    private User currUser { get; set; }
    private List<SelectOption> resellers { get; set; }
    private List<SelectOption> distributors { get; set; }
    
    public Lead leadRecord { get; set; }
    public String selectedResellerId { get; set;}
    public String selectedDistributorId { get; set; }
    public String countryError { get; set; }
    public String stateError { get; set; }
    
    public Boolean isSavedSuccess {get; set;}
    
    public CommunityDealRegistrationController()
    {
        resellers = new List<SelectOption>();
        distributors = new List<SelectOption>();
        currUserAct = new Account();
        currUserCont = new Contact();
        this.leadRecord = new Lead();
        selectedResellerId = '';
        selectedDistributorId = '';
        String currUserId = UserInfo.getUserId();
        leadRecord.RecordTypeId = '012500000005KAN';
        isSavedSuccess = false;
        
        List<User> users = Database.query('select Id, Name, ContactId from User where Id = :currUserId limit 1');
        try
        {
            loadCurrUser();
            loadCurrUserContact();
            loadCurrAccount();
        }catch(Exception ex)
        {
            System.debug(ex.getMessage());
        }
    }
    
    public Account getCurrUserAct()
    {
        if(currUserAct == null)
        {
            loadCurrAccount();
            return currUserAct;
        }
        else
        {
            return currUserAct;
        }
    }
    
    private void loadCurrUser()
    {
        List<User> users = [select Id, Name, ContactId from User where Id = :UserInfo.getUserId() limit 1];
        if(users.size() > 0)
        {
            this.currUser = users[0];
        }
    }
    
    private void loadCurrUserContact()
    {
       if(currUser != null && currUser.ContactId != null)
       {
           List<Contact> cts = [select Id, Name, AccountId from Contact where Id = :currUser.ContactId limit 1];
           //System.debug('Contacts: '+cts);
           if(cts.size() > 0)
           {
               currUserCont = cts[0];
           }
           //System.debug('Contact: '+currUserCont);
       }
    }
    
    private void loadCurrAccount()
    {
       if(currUserCont!=null && currUserCont.AccountId != null)
       {
           List<Account> acts = [select Id, Name, GEO_Supported__c, Partner_Type__c from Account where Id = :currUserCont.AccountId limit 1];
           //System.debug('Accounts: '+acts);
           if(acts.size() > 0)
           {
               currUserAct = acts[0];
               regionFilters = '()';
               if(String.isNotBlank(currUserAct.GEO_Supported__c))
               {
                   String  [] regions = currUserAct.GEO_Supported__c.split(';');
                   for(Integer num = 0; num < regions.size(); num ++)
                   {
                       regions[num] = '\'' + regions[num] +'\'';
                   }
                   regionFilters = '(' + String.join(regions, ',') + ')'; 
               }
           }
           //System.debug('Account: '+currUserAct);
       } 
    }
    
    private Boolean validateLead(Lead record)
    {
        Boolean isValidated = true;
            
        //Required fields
        if(String.isBlank(record.Company)){ leadRecord.Company.addError('Please input a company name'); isValidated = false;}
        if(String.isBlank(record.FirstName)){ leadRecord.FirstName.addError('Please input first name of customer'); isValidated = false;}
        if(String.isBlank(record.LastName)){ leadRecord.FirstName.addError('Please input last name of customer'); isValidated = false;}
        if(String.isBlank(record.Phone)){ leadRecord.Phone.addError('Please input phone number'); isValidated = false; }
        if(String.isBlank(record.PostalCode)){ leadRecord.PostalCode.addError('Please input zip code'); isValidated = false; }
        if(String.isBlank(record.Street)){ leadRecord.Street.addError('Please input street information'); isValidated = false; }
        if(String.isBlank(record.City)){ leadRecord.City.addError('Please input city name'); isValidated = false; }
        if(String.isBlank(record.State)){ stateError = 'Please input state name'; isValidated = false; }
        if(String.isBlank(record.Country)){ countryError = 'Please input country name'; isValidated = false;}
        if(String.isBlank(record.Project_Name__c)){ leadRecord.Project_Name__c.addError('Please input a project name'); isValidated = false; }
        if(String.isBlank(record.Project_Description__c)){ leadRecord.Project_Description__c.addError('Please input project description'); isValidated = false; }
        if(String.isBlank(record.Project_Budget_Amount__c)){ leadRecord.Project_Budget_Amount__c.addError('Please input peoject budget amount'); isValidated = false;}
        if(String.isBlank(record.Competition__c)){ leadRecord.Competition__c.addError('Please input competition'); isValidated = false; }
        if(String.isBlank(record.Deal_Source__c)){ leadRecord.Deal_Source__c.addError('Please input deal source'); isValidated = false; }
        if(String.isBlank(record.Deal_Type__c)){ leadRecord.Deal_Type__c.addError('Please select a deal type'); isValidated = false; }
        if(String.isBlank(record.I_brought_this_deal_to_Silver_Peak__c)){ leadRecord.I_brought_this_deal_to_Silver_Peak__c.addError('Please select a value'); isValidated = false; }
        if(String.isBlank(record.Deal_is_a_result_of_a_SP_funded_event__c)){ leadRecord.Deal_is_a_result_of_a_SP_funded_event__c.addError('Please select Yes or No'); isValidated = false; }
        
        //Conditions
        if(record.NoDealRegistrationResellerContact__c && String.isNotBlank(record.Deal_Registration_Reseller_Contact__c)){ isValidated = false; }  
        if(currUserAct.Partner_Type__c != 'Reseller' && record.NoDealRegistrationResellerContact__c == false && String.isBlank(record.Deal_Registration_Reseller_Contact__c) && !selectedResellerId.equalsIgnoreCase('other')){ record.Deal_Registration_Reseller_Contact__c.addError('Please select a reseller contact'); isValidated = false;}
        if(record.Are_u_registering_this_opp_for_someone__c == true)
        {
            if(String.isBlank(record.Partner_Rep_Name__c) || String.isBlank(record.Partner_Rep_Email__c) || String.isBlank(record.Partner_Rep_Phone_Number__c))
            {
                record.Partner_Rep_Name__c.addError('This field cannot be blank');
                record.Partner_Rep_Email__c.addError('This field cannot be blank');
                record.Partner_Rep_Phone_Number__c.addError('This field cannot be blank');   
                isValidated = false;
            }
        }
        if(currUserAct.Partner_Type__c == 'Distributor')
        {
           if(String.isNotBlank(selectedResellerId))
           {
               if(selectedResellerId.equalsIgnoreCase('other') && String.isBlank(record.DealReg_Reseller_Text__c))
               {
                   isValidated = false;
               }
           }else
           {
               isValidated = false;
           }
        }
        return isValidated;
    }
    
    public PageReference Save()
    {
        leadRecord.DealRegistrationDistributor__c  = String.isBlank(selectedDistributorId)?null:selectedDistributorId.equalsIgnoreCase('Other')?null:String.isBlank(selectedDistributorId)?null:(ID)selectedDistributorId;
        leadRecord.Deal_Registration_Reseller__c  = selectedResellerId.equalsIgnoreCase('Other')?null:String.isBlank(selectedResellerId)?null:(ID)selectedResellerId;
        leadRecord.Deal_Registration_Reseller_Contact__c = (leadRecord.NoDealRegistrationResellerContact__c)?null:(ID)leadRecord.Deal_Registration_Reseller_Contact__c;
        //Default Lead Values
        leadRecord.Deal_Reg__c = true;
        leadRecord.Deal_Reg_By_Partner_Id__c = currUser.id;
        leadRecord.Registered_Partner__c = currUserAct.id;
        leadRecord.Registered_Partner_Sales_Rep__c = currUserCont.id;
        leadRecord.Trigger_Submission__c = true;
        //Default Lead Values End
        if(validateLead(leadRecord))
        {
            SavePoint sp = Database.setSavepoint();
            try
            {
                leadRecord.Id = null;
                insert leadRecord;
                isSavedSuccess = true;
            }
            catch(Exception ex)
            {
                ApexPages.AddMessages(ex);
                Database.rollback(sp);
            }
        }else
        {
            System.debug('Not a validated lead');
        }
        return null;
    }
    
    public List<SelectOption> getResellers()
    {
        if(this.resellers.size() == 0)
        {
            resellers.add(new SelectOption('', '--None--'));
            if(this.currUserAct != null)
            {
                for(sObject obj : Database.query('select Id, Name from Account where Partner_Type__c = \'Reseller\' and GEO_Supported__c includes '+regionFilters))
                {
                    this.resellers.add(new SelectOption((String)obj.get('Id'), (String)obj.get('Name')));
                }
            }
            resellers.add(new SelectOption('other', 'Other'));
            return resellers;
        }else
        {
            return this.resellers;
        }
    }
    
    public List<SelectOption> getDistributors()
    {
        if(distributors.size() == 0)
        {
            distributors.add(new SelectOption('', '--None--'));
            if(currUserAct != null)
            {
                for(sObject obj : Database.query('select Id, Name from Account where Partner_Type__c = \'Distributor\' and GEO_Supported__c includes '+regionFilters))
                {
                    this.distributors.add(new SelectOption((String)obj.get('Id'), (String)obj.get('Name')));
                }
            }
            distributors.add(new SelectOption('other', 'Other'));
            return distributors;
        }else
        {
            return distributors;
        }
    }
    
    @RemoteAction
    global static List<Contact> getResellerContacts(String id)
    {
        List<Contact> contacts = new List<Contact>();
        if(String.isNotBlank(id) && id instanceof ID)
        {
            contacts = [select id, Name from Contact where AccountId = :id];
        }
        return contacts;
    }
}