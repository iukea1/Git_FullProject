public with sharing class HardwareShipmentController {

    public static final Integer CSV_COLUMN_SIZE = 3;

    public static final String STATUS_CUSTOMER_EVALUATION = 'Customer Evaluation';
    public static final String STATUS_CUSTOMER_OWNED = 'Customer Owned';
    public static final String DEFAULT_ORDER_PRODUCT_STATUS = STATUS_CUSTOMER_OWNED;

    public static final String RECORD_TYPE_STANDARD = 'Sandard';
    public static final String RECORD_TYPE_EVAL = 'POC';

	public Order order {get;set;}

    public List<OrderItem> orderProducts {get;set;} 
    public List<OrderShipmentHelper.OrderProductWrapper> orderProductWrappers {get;set;}
    public Document csvFile {get;set;}
    public List<CSVFileRow> fileRowWrappers {get;set;}

    public Boolean uploadedFile {get;set;}
    public Boolean existingAssetsExist {get;set;}

    public HardwareShipmentController(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(OrderShipmentHelper.getAllOrderFieldsAPINames());
        }

        this.order = (Order)stdController.getRecord();
        this.orderProducts = OrderShipmentHelper.queryForOrderProducts(this.order.Id);
        this.orderProductWrappers = OrderShipmentHelper.buildOrderProductWrappers(this.orderProducts);
        this.csvFile = new Document();
        this.fileRowWrappers = new List<CSVFileRow>();

        defaultOrderItemStatus();

        this.uploadedFile = false;
        this.existingAssetsExist = false;
    }

    /**
    *  Public Methods
    **/

    public PageReference checkSerialNumberStatus(){
        Set<String> serialNumbers = getSerialNumbersFromWrappers();
        List<Asset> existingAssets = queryAssetsMatchingSerialNumbers(serialNumbers);
        Map<String, Asset> serialNumberToAssetMap = buildSerialNumberToAssetMap(existingAssets);

        updateOrderProductWrappersExistingAssets(serialNumberToAssetMap);

        return null;
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
    *  checkSericalNumberStatus Helper Methods
    */

    private void updateOrderProductWrappersExistingAssets(Map<String, Asset> serialNumberToAssetMap){
        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            Asset existingAsset = serialNumberToAssetMap.get(orderProductWrapper.orderProduct.Serial_Number__c);

            if(existingAsset == null){
                continue;
            }

            orderProductWrapper.existingAssetId = existingAsset.Id;
        }
    }

    private Map<String, Asset> buildSerialNumberToAssetMap(List<Asset> existingAssets){
        Map<String, Asset> serialNumberToAssetMap = new Map<String, Asset>();

        for(Asset existingAsset: existingAssets){
            serialNumberToAssetMap.put(existingAsset.SerialNumber, existingAsset);
        }

        return serialNumberToAssetMap;
    }

    private List<Asset> queryAssetsMatchingSerialNumbers(Set<String> serialNumbers){
        List<Asset> existingAssets = new List<Asset>();

        try{
            existingAssets = [SELECT Id, SerialNumber FROM Asset WHERE SerialNumber != null AND SerialNumber in :serialNumbers];
        }
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }

        return existingAssets;
    }

    private Set<String> getSerialNumbersFromWrappers(){
        Set<String> serialNumbersFromWrappers = new Set<String>();

        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            if(orderProductWrapper.orderProduct.Serial_Number__c == null){
                // May want to stop here and display message to user. 
                continue;
            }

            serialNumbersFromWrappers.add(orderProductWrapper.orderProduct.Serial_Number__c);
        }

        return serialNumbersFromWrappers;
    }


    /**
    *  defaultOrderItemStatus Helper Methods 
    */

    private void defaultOrderItemStatus(){
        String defaultOrderProductStatus = getDefaultOrderProductStatus();

        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            orderProductWrapper.orderProduct.SBCF_Status__c = defaultOrderProductStatus;
        }
    }   

    private String getDefaultOrderProductStatus(){
        String quoteRecordTypeName = getRecordTypeNameOnQuote();
        System.debug('Quote Record Type Name: ' + quoteRecordTypeName);

        if(quoteRecordTypeName == null){
            return DEFAULT_ORDER_PRODUCT_STATUS;
        }
        else if(quoteRecordTypeName.contains(RECORD_TYPE_STANDARD)){
            return STATUS_CUSTOMER_OWNED;
        }
        else if(quoteRecordTypeName.contains(RECORD_TYPE_EVAL)){
            return STATUS_CUSTOMER_EVALUATION;
        }
        else{
            return DEFAULT_ORDER_PRODUCT_STATUS;
        }
    }

    private String getRecordTypeNameOnQuote(){
        System.debug('Get Record Type Name On Quote');

        String quoteRecordTypeName;

        if(this.order.SBQQ__Quote__c == null){
            // Return null
            System.debug('SBQQ__Quote__c lookup field null');
            return quoteRecordTypeName;
        }

        try{    
            SBQQ__Quote__c relatedQuote = [SELECT RecordType.Name FROM SBQQ__Quote__c WHERE Id = :order.SBQQ__Quote__c LIMIT 1];

            // Should go into catch if null but just in case
            if(relatedQuote != null){
                System.debug('Related Quote Not Null. Assigning relatedQuote record type of: ' + relatedQuote.RecordType.Name);
                quoteRecordTypeName = relatedQuote.RecordType.Name;
            }
            else{
                System.debug('Related Quote is null.');
            }
        }
        catch(QueryException qe){
            System.debug('No quote returned from query');
            system.debug(qe.getMessage());
        }   

        return quoteRecordTypeName;
    }

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