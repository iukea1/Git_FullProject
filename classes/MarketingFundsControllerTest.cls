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
            //mfc1.saveApprovedMDF();
            
            MDF_Request__c mdf = new MDF_Request__c(Type_of_Program__c ='Awareness', Event_Materials_Requested__c = 'test\r\nmessage',
                                                    Silver_Peak_Speaking_Opportunity__c = 'Yes');
            insert mdf;
            Blob cryptoData = Crypto.encryptWithManagedIV('AES128', Blob.valueOf('SliverPeakCrytpo'), Blob.valueOf(mdf.Id + '|' + Date.today().format()));
            String url = EncodingUtil.base64Encode(cryptoData);
            ApexPages.currentPage().getParameters().put('id',url);
            MarketingFundsController mfc = new MarketingFundsController();
            mfc.pap1.Country__c = '';
            mfc.pap1.State__c = '';
            mfc.saveMDF();
            //mfc.saveApprovedMDF();
            
            MarketingFundsController mfc2 = new MarketingFundsController();
            mfc2.request = new MDF_Request__c(Type_of_Program__c ='Awareness', Silver_Peak_Speaking_Opportunity__c = 'No', Approval_Status__c = 'Approved', Activity_Complete__c = true,Expected_Audience_Size__c = 2, Expected_Number_of_Leads__c = 2,Est_Value_of_Expected_Opportunities__c = 2,Event_Location_City__c = 'los', Event_Location_Zip__c = 'testZip');
            mfc2.pap1.Country__c = 'USA';
            mfc2.pap1.State__c = 'California';
            system.assertEquals(true, mfc2.validateFileds());
            mfc2.request = new MDF_Request__c(Type_of_Program__c ='Enablement');
            mfc2.pap1.Country__c = '';
            mfc2.pap1.State__c = '';
            system.assertEquals(false, mfc2.validateFileds());
            try
            {
                mfc2.saveMDF();
            }
            catch(Exception ex)
            {
                ex.getMessage();
            }
            //mfc2.saveApprovedMDF();
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
        //mfc1.saveApprovedMDF();

        MDF_Request__c mdf = new MDF_Request__c(Type_of_Program__c ='Awareness', Event_Materials_Requested__c = 'test\r\nmessage',
                                                Silver_Peak_Speaking_Opportunity__c = 'Yes');
        insert mdf;
        ApexPages.currentPage().getParameters().put('id',mdf.id);
        MarketingFundsController mfc = new MarketingFundsController();
        mfc.pap1.Country__c = '';
        mfc.pap1.State__c = '';
        mfc.saveMDF();
        
        AWSConfig__c config = new AWSConfig__c(name='Active');
        insert config;
        mfc.getAWSConfig();
        mfc.getFile(mdf.Id);
        //mfc.saveApprovedMDF();

        MarketingFundsController mfc2 = new MarketingFundsController();
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
        
		MarketingFundsController.MDF newMDF = new MarketingFundsController.MDF();
        newMDF.Total_Attendees = '10';
        newMDF.Event_Results_Opportunities = '20';
        newMDf.Total_Qualified_Leads = '30';
        newMDF.Estimated_Pipeline_Value = '40';
        newMDF.Result_Detail = '50';
        newMDF.Requested_Reimbursement_Amount = '60';
        newMDF.Topic_Course = '70';
        newMDF.Number_of_Certifications = '80';
        newMDF.invoice = 1;
        newMDF.proof = 2;
        newMDF.attendance = 3;
        
        MarketingFundsController.AWSResponse aws = new MarketingFundsController.AWSResponse();
        aws.FileName = 'test';
        aws.S3Key = 'mfr/';
		aws.FileSize = 1.231;
        aws.S3Bucket = 'MFR';
        aws.FileType = 'proof';
        
        //insert 5 s3 file for testing
        List<Ensemblestorage__EnsembleFile__c> files = new List<Ensemblestorage__EnsembleFile__c>();
        Ensemblestorage__EnsembleFile__c file1 = new Ensemblestorage__EnsembleFile__c(file_type__c='Target Account', Funding_Requests__c=mdf.Id);
        Ensemblestorage__EnsembleFile__c file2 = new Ensemblestorage__EnsembleFile__c(file_type__c='Event Agenda', Funding_Requests__c=mdf.Id);
        Ensemblestorage__EnsembleFile__c file3 = new Ensemblestorage__EnsembleFile__c(file_type__c='invoice', Funding_Requests__c=mdf.Id);
        Ensemblestorage__EnsembleFile__c file4 = new Ensemblestorage__EnsembleFile__c(file_type__c='proof', Funding_Requests__c=mdf.Id);
        Ensemblestorage__EnsembleFile__c file5 = new Ensemblestorage__EnsembleFile__c(file_type__c='Attendance List', Funding_Requests__c=mdf.Id);
		files.add(file1);
        files.add(file2);
        files.add(file3);
        files.add(file4);
        files.add(file5);
        insert files;
        
        mfc2.getFile(mdf.Id);
        
        
        MarketingFundsController.linkFileToMFR(aws, mdf.Id, false);
        MarketingFundsController.linkFileToMFR(aws, mdf.Id, true);
        MarketingFundsController.updateMDF(newMDF,'');
        MarketingFundsController.updateMDF(newMDF, mdf.Id);
        MDF_Request__c eMdf = new MDF_Request__c(Type_of_Program__c ='Enablement', Event_Materials_Requested__c = 'test\r\nmessage',
                                                Silver_Peak_Speaking_Opportunity__c = 'Yes');
        insert eMdf;
        MarketingFundsController.updateMDF(newMDF, eMdf.Id);
        newMDF.Total_Attendees='';
        newMDF.Requested_Reimbursement_Amount = 'Error Data';
        mfc2.getFile(eMdf.Id);
        MarketingFundsController.updateMDF(newMDF, eMdf.Id);
    }
    
    @isTest
    public static void testPartnerController()
    {
        PartnerMDFListingController pmc = new PartnerMDFListingController();
    }
}