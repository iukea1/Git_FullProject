/*
*  Controller of VF Page MarketingFunds
*  05AUG2016 @Author Daniel Wu
*/
public with sharing class MarketingFundsController 
{
    public MDF_Request__c request { get; set; }
    Public Attachment accountAttachment { get; set; }
    public Attachment eventAgendaAttachment { get; set; }
    public Attachment invoice { get; set; }
    public Attachment proof { get; set; }
    public Attachment attendance { get; set;}
    public String EventMaterials {get; set; }
    public String eventDetails {get; set; }
    public Partner_Account_Profile__c  pap1 { get; set; } //just for data binding of the region/country fields
    public String userProfile { get; set; }
    
    public MarketingFundsController()
    {
        eventDetails = '';
        userProfile = '';
        String requestId = apexPages.currentPage().getParameters().get('id');
        accountAttachment = new Attachment();
        eventAgendaAttachment = new Attachment();
        invoice = new Attachment();
        proof = new Attachment();
        attendance = new Attachment();
        request = new MDF_Request__c();
        EventMaterials = getEventMaterials();
        pap1 = new Partner_Account_Profile__c();
        String profileId = UserInfo.getProfileId();
        List<profile> pro = [Select Id, Name from profile where Id =: profileId];
        if(pro.size() > 0)
        {
            if(pro[0].Name == 'Silver Peak Partner Community Profile')
            {
                String anRequestId = isAnonymousUser();
                if(String.isNotBlank(anRequestId)){
                    userProfile = 'siteUser';
                    getAttcahment(anRequestId);
                }
                else 
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'The page you requested has expired, or the record has been submitted. If you have any questions, please contact us at channel@silver-peak.com.'));
                }
            }
            else if(pro[0].Name == '13g-SP Partner Community')
            {
                userProfile = 'loginUser';
                getAttcahment(requestId);
            }
            else
            {
                getAttcahment(requestId);
                userProfile = 'otherUser';
            }
        }
        if(String.isNotBlank(request.Id) && String.isNotBlank(request.Event_Materials_Requested__c))
        {
            eventDetails = request.Event_Materials_Requested__c.replaceAll('\r\n',';');
        }
    }
    
    public PageReference saveMDF()
    {
        if(!validateFileds())
        {
            return null;
        }
        Savepoint sp = Database.setSavepoint();
        try
        {
            if(String.isBlank(request.OwnerId))
            {
                request.OwnerId = UserInfo.getUserId();   
            }
            if(String.isNotBlank(eventDetails))
            {
                request.Event_Materials_Requested__c = eventDetails.replaceAll(';', '\r\n');
            }
            //binding data from Partner_Portal_Account_Profile_Address__c to MDF_Reqeust__c
            if(String.isNotBlank(pap1.Country__c))
            {
                request.Event_Location_Country__c = pap1.Country__c;
            }
            if(String.isNotBlank(pap1.State__c))
            {
                request.Event_Location_State__c = pap1.State__c;
            }
            upsert request;
            submitMDFToProcess(request.Id);
            request = getMDF(request.Id);
            if(request.Type_of_Program__c != 'Enablement')
            {
                if(String.isBlank(accountAttachment.ParentId)){
                    accountAttachment.ParentId = request.Id;
                }
                accountAttachment.Description = 'Target Account List';
                if(String.isBlank(eventAgendaAttachment.ParentId))
                {
                    eventAgendaAttachment.ParentId = request.Id;
                }
                eventAgendaAttachment.Description = 'Event Agenda';
                upsert accountAttachment;
                if(eventAgendaAttachment.Body != null)
                {
                	upsert eventAgendaAttachment;
                }
                accountAttachment = new Attachment(Id=accountAttachment.Id, Name=accountAttachment.Name);
                eventAgendaAttachment =new Attachment(Id=accountAttachment.Id, Name=accountAttachment.Name);
            }
            String reminder = userProfile == 'siteUser' ? 'Thank you for submitting your Marketing Fund request. We will review your submission and contact you shortly.' : 
            'Thank you for submitting your Marketing Fund request. We will review your submission and contact you shortly. To check the status of your request, please click the Track Requests tab above.'
                + '<br/><a style="color:#0000ee;margin:0;font-size:100%;" href="/s" target="_top">Click here to go back the home page </a> <br/> <a style="color:#0000ee;margin:0;font-size:100%;"href="/s/MarketingFunds" target="_top">Click here to submit another Marketing Fund request</a>';
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,reminder));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            ApexPages.AddMessages(ex);
        }
        return null;
    }
    public PageReference saveApprovedMDF()
    {
        SavePoint sp = Database.setSavepoint();
        if(request.Approval_Status__c=='Approved')
        {
            request.Activity_Complete__c = true;
            request.Feedback_Complete__c = true;
        }
        try
        {
            upsert request;
            uploadFiles();
            String reminder = userProfile == 'siteUser' ? 'Thank you for submitting your activity results.' : 
            'Thank you for submitting your activity results.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,reminder));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            ApexPages.AddMessages(ex);
        }
        return null;
    }
    
    public Boolean validateFileds()
    {
        Boolean isPassed = true;
        if(request.Type_of_Program__c == 'Enablement')
        {
            if(String.isBlank(request.Event_Location_City__c))
            {
                isPassed = false;
                request.Event_Location_City__c.addError('City cannot be blank');
            }
            if(String.isBlank(pap1.Country__c))
            {
                isPassed = false;
                pap1.Country__c.addError('Country cannot be blank');
            }
            if(String.isBlank(pap1.State__c))
            {
                isPassed = false;
                pap1.State__c.addError('State cannot be blank');
            }
            if(String.isBlank(request.Event_Location_Zip__c))
            {
                isPassed = false;
                request.Event_Location_Zip__c.addError('Postal Code cannot be blank');
            }
        }
        else
        {   
            if(request.Expected_Audience_Size__c == null)
            {
                isPassed = false;
                request.Expected_Audience_Size__c.addError('Expected Audience Size cannot be blank');
            }
            if(request.Expected_Number_of_Leads__c == null)
            {
                isPassed = false;
                request.Expected_Number_of_Leads__c.addError('Expected number of Leads cannot be blank');
            }
            if(request.Expected_Audience_Size__c != null && request.Expected_Number_of_Leads__c != null && request.Expected_Number_of_Leads__c > request.Expected_Audience_Size__c)
            {
                isPassed = false;
                request.Expected_Number_of_Leads__c.addError('Expected number of Leads not to exceed the expected audience size');
            }
            if(request.Est_Value_of_Expected_Opportunities__c == null)
            {
                isPassed = false;
                request.Est_Value_of_Expected_Opportunities__c.addError('Estimated Value of Opportunities cannot be blank');
            }
            if(String.isBlank(request.Silver_Peak_Speaking_Opportunity__c))
            {
                isPassed = false;
                request.Silver_Peak_Speaking_Opportunity__c.addError('Silver Peak Speaking Opportunities cannot be blank');
            }
            else if(request.Silver_Peak_Speaking_Opportunity__c == 'Yes')
            {
                if(String.isBlank(request.Speaking_Opportunity_Duration__c))
                {
                    isPassed = false;
                    request.Speaking_Opportunity_Duration__c.addError('Duration cannot be blank');
                }
                if(String.isBlank(request.Speaking_Opportunity_Type__c))
                {
                    isPassed = false;
                    request.Speaking_Opportunity_Type__c.addError('Type cannot be blank');
                }
                if(String.isBlank(request.Speaking_Opportunity_Abstract__c))
                {
                    isPassed = false;
                    request.Speaking_Opportunity_Abstract__c.addError('Abstract cannot be blank');
                }
            }
            if(String.isBlank(request.Event_Location_City__c))
            {
                isPassed = false;
                request.Event_Location_City__c.addError('Event City cannot be blank');
            }
            if(String.isBlank(pap1.Country__c))
            {
                isPassed = false;
                pap1.Country__c.addError('Event Country cannot be blank');
            }
            if(String.isBlank(pap1.State__c))
            {
                isPassed = false;
                pap1.State__c.addError('Event State cannot be blank');
            }
            if(String.isBlank(request.Event_Location_Zip__c))
            {
                isPassed = false;
                request.Event_Location_Zip__c.addError('Postal Code cannot be blank');
            }
            if(accountAttachment.Body == null)
            {
                accountAttachment.name.addError('Target Account List cannot be blank');
                isPassed = false;
            }
        }
		return isPassed;
    }
    
    private MDF_Request__c getMDF(String requetId)
    {
        List<String> fields = new List<String>(MDF_Request__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ' select ' + String.join(fields, ',')
            + ' from MDF_Request__c'
            + ' where Id=:requetId limit 1';
        List<MDF_Request__c> requests = Database.query(soql);
        return requests.size() == 1 ? requests[0] : new MDF_Request__c();
    }
    
    public void submitMDFToProcess(Id requestId)
    {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(requestId);
        Approval.ProcessResult result = Approval.Process(req);
    }
    
    public String getEventMaterials()
    {
        String eventMaterials = '';
        
        Schema.DescribeFieldResult fieldResult = MDF_Request__c.Event_Materials__c .getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            eventMaterials += f.getValue() + ';';
        }
        return eventMaterials.removeEnd(';');
    }
    
    public String isAnonymousUser()
    {   
        String c = apexPages.currentPage().getParameters().get('id');   
        if(String.isNotBlank(c))
        {
            String url = '';
            try
            {
                url = Crypto.decryptWithManagedIV('AES128', Blob.valueOf('SliverPeakCrytpo'), EncodingUtil.base64Decode(c.replaceAll(' ','\\+'))).toString();
            }
            catch(Exception ex)
            {
                return null;
            }
            String [] idAndDate = url.split('\\|');
            if(idAndDate.size() == 2)
            {
                try{
                    String[] urlDate = idAndDate[1].split('\\/');
                    String year = urlDate[2];
                    string month = urlDate[0];
                    String day = urlDate[1];
                    date d = date.valueOf(year + '-' + month + '-' + day);
                    return d.daysBetween(date.today()) <= 3 ?  idAndDate[0] : null;
                }
                catch(Exception ex)
                {
                    return null;
                }
            }
            else
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }
    
    public void getAttcahment (String requestId)
    {
        if(requestId instanceOf Id)
        {
            request = getMDF(requestId);
            if(request.Type_of_Program__c !='Enablement')
            {
                List<Attachment> atts = [Select Id, Name, Body, Description, ParentId  from Attachment where ParentId =:request.Id];
                if(!atts.isEmpty())
                {
                    for(Attachment att : atts)
                    {
                        if(att.Description == 'Target Account List')
                        {
                            accountAttachment = att;
                        }
                        else if(att.Description == 'Event Agenda')
                        {
                            eventAgendaAttachment = att;
                        }
                        else if(att.Description == 'invoice')
                        {
                            invoice = att;
                        }
                        else if(att.Description == 'proof')
                        {
                            proof = att;
                        }
                        else if(att.Description == 'attendance')
                        {
                            attendance = att;
                        }
                    }
                }
            }
        }
    }
    
    public void uploadFiles()
    {
        invoice.ParentId = request.Id;
        invoice.Description = 'invoice';
        proof.ParentId = request.Id;
        proof.Description = 'proof';
        attendance.ParentId = request.Id;
        attendance.Description = 'attendance';
        Boolean validation = true;
        if(invoice.Body == null)
        {
            invoice.name.addError('invoice cannot be blank');
            validation = false;
        }
        if(proof.Body == null)
        {
            invoice.name.addError('proof cannot be blank');
            validation = false;
        }
        if(attendance.Body == null)
        {
            invoice.name.addError('attendance cannot be blank');
            validation = false;
        }
        if(!validation)
        {
            return;
        }
        upsert invoice;
        upsert proof;
        upsert attendance;
        invoice = new Attachment(Id=invoice.Id, Name=invoice.Name);
        proof = new Attachment(Id=proof.Id, Name=proof.Name);
        attendance = new Attachment(Id=attendance.Id, Name=attendance.Name);
    }
}