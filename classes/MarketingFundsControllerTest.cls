@isTest
public class MarketingFundsControllerTest {
    @isTest
    public static void testAnonymousUser()
    {
        List<User> crrentUser = [Select Id from User where Profile.Name = 'Silver Peak Partner Community Profile' limit 1];
        if(crrentUser.isEmpty())
        {
            return;
        }
        system.runAs(crrentUser[0])
        {
            MarketingFundsController mfc1 = new MarketingFundsController();
            mfc1.pap1.Country__c = 'USA';
            mfc1.pap1.State__c = 'California';
            mfc1.eventDetails = 'test;test;';
            mfc1.saveMDF();
            mfc1.saveApprovedMDF();
            
            MDF_Request__c mdf = new MDF_Request__c(Type_of_Program__c ='Awareness', Event_Materials_Requested__c = 'test\r\nmessage',
                                                    Silver_Peak_Speaking_Opportunity__c = 'Yes');
            insert mdf;
            List<Attachment> atts = new List<Attachment>();
            Attachment accountAttachment = new Attachment(Name = 'Test', Body = Blob.valueOf('Test Data'), Description = 'Target Account List', ParentId = mdf.Id);
            atts.add(accountAttachment);
            Attachment eventAgendaAttachment = new Attachment(Name = 'Test', Body = Blob.valueOf('Test Data'), Description = 'Event Agenda',ParentId = mdf.Id);
            atts.add(eventAgendaAttachment);
            Attachment invoice = new Attachment(Name = 'Test', Body = Blob.valueOf('Test Data'), Description = 'invoice', ParentId = mdf.Id);
            atts.add(invoice);
            Attachment proof = new Attachment(Name = 'Test', Body = Blob.valueOf('Test Data'), Description = 'proof', ParentId = mdf.Id);
            atts.add(proof);
           	Attachment attendance = new Attachment(Name = 'Test', Body = Blob.valueOf('Test Data'), Description = 'attendance', ParentId = mdf.Id);
            atts.add(attendance);
            insert atts;
            Blob cryptoData = Crypto.encryptWithManagedIV('AES128', Blob.valueOf('SliverPeakCrytpo'), Blob.valueOf(mdf.Id + '|' + Date.today().format()));
            String url = EncodingUtil.base64Encode(cryptoData);
            ApexPages.currentPage().getParameters().put('id',url);
            MarketingFundsController mfc = new MarketingFundsController();
            mfc.pap1.Country__c = '';
            mfc.pap1.State__c = '';
            mfc.saveMDF();
            mfc.saveApprovedMDF();
            
            MarketingFundsController mfc2 = new MarketingFundsController();
            mfc2.accountAttachment.Body = Blob.valueOf('Test Data');
            mfc2.eventAgendaAttachment.Body = Blob.valueOf('Test Data');
            mfc2.request = new MDF_Request__c(Type_of_Program__c ='Awareness', Silver_Peak_Speaking_Opportunity__c = 'No', Approval_Status__c = 'Approved', Activity_Complete__c = true,Expected_Audience_Size__c = 2, Expected_Number_of_Leads__c = 2,Est_Value_of_Expected_Opportunities__c = 2,Event_Location_City__c = 'los', Event_Location_Zip__c = 'testZip');
            mfc2.pap1.Country__c = 'USA';
            mfc2.pap1.State__c = 'California';
            system.assertEquals(true, mfc2.validateFileds());
            try
            {
                mfc2.saveMDF();
            }
            catch(Exception ex)
            {
                ex.getMessage();
            }
            mfc2.saveApprovedMDF();
        }
    }
    
    @isTest
    public static void testLoginUser()
    {
        MarketingFundsController mfc1 = new MarketingFundsController();
        mfc1.pap1.Country__c = 'USA';
        mfc1.pap1.State__c = 'California';
        mfc1.eventDetails = 'test;test;';
        mfc1.saveMDF();
        mfc1.saveApprovedMDF();

        MDF_Request__c mdf = new MDF_Request__c(Type_of_Program__c ='Awareness', Event_Materials_Requested__c = 'test\r\nmessage',
                                                Silver_Peak_Speaking_Opportunity__c = 'Yes');
        insert mdf;
        ApexPages.currentPage().getParameters().put('id',mdf.id);
        MarketingFundsController mfc = new MarketingFundsController();
        mfc.pap1.Country__c = '';
        mfc.pap1.State__c = '';
        mfc.invoice.Body = Blob.valueOf('Test Data');
        mfc.invoice.Name = 'test';
        mfc.proof.Body = Blob.valueOf('Test Data');
        mfc.proof.Name = 'Test';
        mfc.attendance.Body = Blob.valueOf('Test Data');
        mfc.attendance.Name = 'Test';
        mfc.saveMDF();
        mfc.saveApprovedMDF();

        MarketingFundsController mfc2 = new MarketingFundsController();
        mfc2.accountAttachment.Body = Blob.valueOf('Test Data');
        mfc2.eventAgendaAttachment.Body = Blob.valueOf('Test Data');
		mfc2.accountAttachment.Name = 'Test';
        mfc2.eventAgendaAttachment.Name = 'Test';
        mfc2.request = new MDF_Request__c(Type_of_Program__c ='Awareness', Silver_Peak_Speaking_Opportunity__c = 'No', Approval_Status__c = 'Approved', Activity_Complete__c = true,Expected_Audience_Size__c = 2, Expected_Number_of_Leads__c = 2,Est_Value_of_Expected_Opportunities__c = 2,Event_Location_City__c = 'los', Event_Location_Zip__c = 'testZip');
        mfc2.pap1.Country__c = 'USA';
        mfc2.pap1.State__c = 'California';
        system.assertEquals(true, mfc2.validateFileds());
        try
        {
            mfc2.saveMDF();
        }
        catch(Exception ex)
        {
        }
        mfc2.saveApprovedMDF();  
    }
    
    @isTest
    public static void testPartnerController()
    {
        PartnerMDFListingController pmc = new PartnerMDFListingController();
    }
}