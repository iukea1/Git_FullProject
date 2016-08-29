global without sharing class PartnerPortalController
{
    global Boolean IsAuthorized
    {
        get
        {
            return UserInfo.getUserType() != 'Guest';
        }
    }
    
    @RemoteAction
    global static String getDownloadLink(String docNumber)
    {
        return PartnerPortalDocumentDownloadController.getDownloadUrl(docNumber);
    }
    
    @isTest
    static void test()
    {
        PartnerPortalController controller = new PartnerPortalController();
        System.assertEquals(true, controller.IsAuthorized);
        
        System.assertEquals(null, PartnerPortalController.getDownloadLink('abcd'));
    }
}