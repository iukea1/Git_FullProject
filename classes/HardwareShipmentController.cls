public with sharing class HardwareShipmentController {

    public static final Integer CSV_COLUMN_SIZE = 2;

	public Order order {get;set;}

    public List<OrderItem> orderProducts {get;set;} 
    public Document csvFile {get;set;}
    public List<CSVFileRow> fileRowWrappers {get;set;}

    public Boolean uploadedFile {get;set;}

    public HardwareShipmentController(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(OrderShipmentHelper.getAllOrderFieldsAPINames());
        }

        this.order = (Order)stdController.getRecord();
        this.orderProducts = OrderShipmentHelper.queryForOrderProducts(this.order.Id);
        this.csvFile = new Document();
        this.fileRowWrappers = new List<CSVFileRow>();
        this.uploadedFile = false;
    }

    public void checkSerialNumberStatus(){

    }

    public PageReference rerenderForm(){
        return null;
    }

    public PageReference saveAndShip(){
        PageReference page = new PageReference('/' + order.Id);
        page.setRedirect(true);
        return page;
    }

    public void applyCSVFile(){
        System.debug('Applying CSV File.');

        if(csvFile.Body == null){
            return;
        }

        String csvBody = csvFile.Body.toString();
         
        System.debug('CSV File Body: ' + csvBody);
        csvBody = csvBody.replaceAll('(\\r|\\n)+', ',');
        System.debug('CSV File Body After removing linebreaks');

        // Here everything should be truly column delimited.  

        List<String> csvElements = csvBody.split(',');

        System.debug('CSV File Elements: ' + csvElements);

        for(Integer i = 0; i < csvElements.size(); i = i+CSV_COLUMN_SIZE){
            List<String> rowElements = new List<String>();

            for(Integer j = i; j < i + CSV_COLUMN_SIZE; j++){
                rowElements.add(csvElements[j]);
            }   

            this.fileRowWrappers.add(new CSVFileRow(rowElements));
        }

        uploadedFile = true;
    }

    public PageReference returnToOrder(){
        PageReference page = new PageReference('/' + order.Id);
        page.setRedirect(true);
        return page;
    }

    public class CSVFileRow{

        public String column1 {get;set;}
        public String column2 {get;set;}

        public CSVFileRow(List<String> rowElements){
            this.column1 = rowElements[0];
            this.column2 = rowElements[1];
        }   
    }

}