public class MFRUploadFileController {
    public String AWSConfig { get; set; }
    public Boolean AllUploaded { get; set; }
    public Boolean UploadResponse { get; set; }
    public String RelateToObjectLabel { get; set; }
    public String LinkToObjectLabel { get; set; }
    public Boolean ShowLinkToObject { get; set; }
    public Boolean LinkToParentObject { get; set; }
    
    public MFRUploadFileController(ApexPages.StandardController controller)
    {
        AllUploaded = false; 
        UploadResponse = false;
        RelateToObjectLabel = 'S3 file';
        LinkToobjectLabel = 'S3 file test';
        ShowLinkToObject = false;
        LinkToParentObject = false;
        AWSConfig = '{\"Ensemblestorage__Bucket__c\":\"newmfr\", \"Ensemblestorage__AWSAccessKey__c\":\"AKIAIT3WTVSCGVGBHLHQ\", \"Ensemblestorage__AWSSecretKey__c\":\"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\", \"region\":\"us-east-1\"}';
    }
    
    public PageReference saveFile()
    {
        return null;
    }
}