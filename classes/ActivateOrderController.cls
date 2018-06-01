public class ActivateOrderController {
    public Order order {get;set;}
    public Boolean orderIsActivated {get;set;}
    public Boolean needSerial {get;set;}
    public Boolean runUpdate {get;set;}
    public SBQQ__Quote__c quote {get;set;}
    
    public ActivateOrderController(ApexPages.StandardController controller) {
        this.order = (Order)controller.getRecord();
        this.order = [SELECT Id, Status, Product_Type__c, SBQQ__Quote__c, SerialNumberApplied__c FROM Order WHERE Id = :this.order.Id LIMIT 1];
        this.orderIsActivated = order.Status == 'Activated';
        this.runUpdate = false;
        if(this.orderIsActivated){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'This order is already Active');
            ApexPages.addMessage(myMsg);
            return;
        } else {
            //check if hardware or software
            this.quote = [SELECT Id FROM SBQQ__Quote__c WHERE Id = :order.SBQQ__Quote__c];
            List<SBQQ__QuoteLine__c> qLineItems = [SELECT Id, SBQQ__ProductFamily__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id AND SBQQ__ProductFamily__c = 'Product'];
            if(!qLineItems.isEmpty() && !order.SerialNumberApplied__c) {
                needSerial = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Serial Numbers are required when Hardware products are quoted.');
                ApexPages.addMessage(myMsg);
                return;
            } else {
                runUpdate  = true;
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
        return page;
    }

}