public class MFRUploadFileController {
	public MFRUploadFileController(ApexPages.StandardController controller)
    {
        
    }
    
    public String AWSConfig { get; set; }
    public Boolean AllUploaded { get; set; }
    public Boolean UploadResponse { get; set; }
    public String RelateToObjectLabel { get; set; }
    public String LinkToObjectLabel { get; set; }
    public Boolean ShowLinkToObject { get; set; }
    
    public PageReference saveFile()
    {
        return null;
    }
}