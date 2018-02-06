public with sharing class HardwareShipmentController {

    public static final Integer CSV_COLUMN_SIZE = 3;

	public Order order {get;set;}

    public List<OrderItem> orderProducts {get;set;} 
    public List<OrderShipmentHelper.OrderProductWrapper> orderProductWrappers {get;set;}
    public Document csvFile {get;set;}
    public List<CSVFileRow> fileRowWrappers {get;set;}

    public Boolean uploadedFile {get;set;}

    public HardwareShipmentController(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(OrderShipmentHelper.getAllOrderFieldsAPINames());
        }

        this.order = (Order)stdController.getRecord();
        this.orderProducts = OrderShipmentHelper.queryForOrderProducts(this.order.Id);
        this.orderProductWrappers = OrderShipmentHelper.buildOrderProductWrappers(this.orderProducts);
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

    public PageReference returnToOrder(){
        PageReference page = new PageReference('/' + order.Id);
        page.setRedirect(true);
        return page;
    }

    public void applyCSVFile(){
        System.debug('Applying CSV File.');

        if(csvFile.Body == null){
            return;
        }

        List<String> csvElements = buildCSVElements();
        this.fileRowWrappers = buildFileRowWrappers(csvElements);
        Map<String, CSVFileRow> productCodeToCSVRow = buildProductCodeToCSVFileRow();
        populateOrderProductWrappersWithFileInfo(productCodeToCSVRow);

        uploadedFile = true;
    }

    /**
    *  applyCSVFile Helper Methods - Start
    */

    private void populateOrderProductWrappersWithFileInfo(Map<String, CSVFileRow> productCodeToCSVRow){
        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            CSVFileRow csvRow = productCodeToCSVRow.get(orderProductWrapper.orderProduct.Product2.ProductCode);

            if(csvRow == null){
                continue;
            }

            orderProductWrapper.orderProduct.Part_Number__c = csvRow.column2;
            orderProductWrapper.orderProduct.Serial_Number__c = csvRow.column3;
        }
    }
    
    private Map<String, CSVFileRow> buildProductCodeToCSVFileRow(){
        Map<String, CSVFileRow> productCodeToCSVRow = new Map<String, CSVFileRow>();

        for(CSVFileRow row: this.fileRowWrappers){
            productCodeToCSVRow.put(row.column1, row);
        }

        return productCodeToCSVRow;
    }

    private List<CSVFileRow> buildFileRowWrappers(List<String> csvElements){
        List<CSVFileRow> fileRowWrappers = new List<CSVFileRow>();

        for(Integer i = 0; i < csvElements.size(); i = i+CSV_COLUMN_SIZE){
            List<String> rowElements = new List<String>();

            for(Integer j = i; j < i + CSV_COLUMN_SIZE; j++){
                rowElements.add(csvElements[j]);
            }   

            fileRowWrappers.add(new CSVFileRow(rowElements));
        }

        return fileRowWrappers;
    }

    private List<String> buildCSVElements(){
        String csvBody = csvFile.Body.toString();
         
        System.debug('CSV File Body: ' + csvBody);
        csvBody = csvBody.replaceAll('(\\r|\\n)+', ',');
        System.debug('CSV File Body After removing linebreaks');

        // Here everything should be truly column delimited.  

        List<String> csvElements = csvBody.split(',');

        System.debug('CSV File Elements: ' + csvElements);

        return csvElements;
    }

    /**
    *  applyCSVFile Helper Methods - End
    **/

    public class CSVFileRow{

        public String column1 {get;set;}
        public String column2 {get;set;}
        public String column3 {get;set;}

        public CSVFileRow(List<String> rowElements){
            this.column1 = rowElements[0];
            this.column2 = rowElements[1];
            this.column3 = rowElements[2];
        }   
    }

}