/*
* Change Log:
* 2016OCT18: Andy Getz - created method to query contact and account records to display better error messaging Case:20160929-192046
* 2016OCT19: Jimmy Li - changed class access permissions from with sharing to without sharing, adjust the statement structure of method forgotPassword
* 2016OCT24: Andy Getz - added else condition to display error message if user or contact is not found
*/

public without sharing class PartnerPortalForgotPasswordController 
{
    public String Username {get; set;}
    public Boolean ShowError {get; set;}
    public String errorMsg {get; set;}
    public String emailadd {get; set;}

    public PartnerPortalForgotPasswordController() {}
  
    public PageReference forgotPassword() 
    {
        PageReference ref = null;
        
        if(Username != null)
        {
        emailadd = Username;

        String formattedUsername = (Username != null && !Username.endsWith('.sp')) ? (Username + '.sp') : Username;

        User foundUser = PartnerPortalLoginController.getUserByEmail(new List<String> {formattedUsername, Username});
        if(foundUser != null)
        { 
            ShowError = false;
            Boolean success = Site.forgotPassword(foundUser.Username);
            PageReference confirmPage = Page.PartnerPortalForgotPasswordConfirm;
            confirmPage.setRedirect(true);
            if(success) 
            {  
                return confirmPage;
            }
        } 
        else
        {
            //error message method call
            errorMsg = getErrorMsg(emailadd);
            ShowError = true;
        }
        }
        return ref;
    }
    
    //new error messaging method
    public String getErrorMsg(String emailadd)
    {
        List<Contact> con = [select id, email, Account.isPartner from Contact where email = :emailadd LIMIT 1];
        if(!con.isEmpty())
        {
            Boolean conPartnerStatus = con[0].Account.isPartner;
            if(conPartnerStatus == true)
            {
                errorMsg = 'Please request a login <a href=\" https://partners.silver-peak.com/PartnerPortalIndividualReg\">here</a>';
            }
            else
            {
                errorMsg = 'Please apply to become a partner <a href=\"https://partners.silver-peak.com/BecomePartner\">here</a>';
            }
        }
        else
        {
            errorMsg = 'Your username or email cannot be found.';
        }
        return errorMsg;
    }
    
    @isTest
    static void testForgotPasswordController () {
        PartnerPortalForgotPasswordController  controller = new PartnerPortalForgotPasswordController ();
        controller.Username = UserInfo.getUsername();            
        System.assertEquals(controller.forgotPassword(),null);                           
    } 
}