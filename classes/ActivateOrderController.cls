public class ActivateOrderController {
    public Order order {get;set;}
    public Boolean orderIsActivated {get;set;}
    public Boolean needSerial {get;set;}
    public Boolean runUpdate {get;set;}
    public SBQQ__Quote__c quote {get;set;}
    
    public ActivateOrderController(ApexPages.StandardController controller) {
        this.order = (Order)controller.getRecord();
        this.order = [SELECT Status, SBQQ__Quote__r.SBCF_Evaluation_Quote__c, Quote_Address__c, SBCF_Shipping_Address__c, SBCF_Shipping_Country__c, Tracking_Information__c, PurchaseOrder__c, Physical_Product_Count__c, SerialNumberApplied__c FROM Order WHERE Id = :this.order.Id LIMIT 1];
        this.runUpdate = false;
            
        if(this.order.Status == 'Activated'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This order is already Active.');
            ApexPages.addMessage(myMsg);
            return;
        } else if (this.order.SBQQ__Quote__r.SBCF_Evaluation_Quote__c && this.order.Physical_Product_Count__c > 0 && this.order.Quote_Address__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Quote Address is required for EVAL Orders with physical products -- please select a Quote Address from the available list in the Shipping Info section of this Order.');
            ApexPages.addMessage(myMsg);
            return;
        } else if (!this.order.SBQQ__Quote__r.SBCF_Evaluation_Quote__c && this.order.Physical_Product_Count__c > 0 && (this.order.SBCF_Shipping_Address__c == null || this.order.SBCF_Shipping_Country__c == null || this.order.Tracking_Information__c == null)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Shipping Address, Shipping Country, and Tracking Information are required to activate an Order with physical products.');
            ApexPages.addMessage(myMsg);
            return;
        } else {
            if(this.order.Physical_Product_Count__c > 0 && !order.SerialNumberApplied__c) {
                needSerial = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Serial Numbers are required when Hardware products are quoted.');
                ApexPages.addMessage(myMsg);
                return;
            } else {
                runUpdate = true;
            }
        }
    }
     
    public PageReference checkUpdate() {
        if(runUpdate) {
            try {
                update new Order(
                    Id = this.order.Id,
                    Status = 'Activated',
                    ActivatedDate = System.today(),
                    ActivatedById = Userinfo.getUserId()
                );
                
                if(this.quote.SBCF_Evaluation_Quote__c) {
                    this.quote.POC_Status__c = 'Shipped';
                    update this.quote;
                }
                
                update new Order(
                    Id = this.order.Id,
                    SBQQ__Contracted__c = false
                );
                
                update new Order(
                    Id = this.order.Id,
                    SBQQ__Contracted__c = true
                );
                
                PageReference page = new PageReference('/' + order.Id);
                page.setRedirect(true);
                return page;
            } catch(DmlException dle) {
                needSerial = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,dle.getMessage());
                ApexPages.addMessage(myMsg);
                return null;
            }
        } else {
            return null;
        }
    }

    public PageReference returnToOrder(){
        PageReference page = new PageReference('/' + order.Id);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference runSerialNumberPage() {
        PageReference page = Page.HardwareShipment;
        page.setRedirect(true);
        page.getParameters().put('Id', this.order.Id);
        system.debug('this page is ' +  page);
        return page;
    }
}