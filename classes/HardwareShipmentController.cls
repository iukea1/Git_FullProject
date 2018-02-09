public with sharing class HardwareShipmentController {

    public static final Integer CSV_COLUMN_SIZE = 4;

    public static final String STATUS_CUSTOMER_EVALUATION = 'Customer Evaluation';
    public static final String STATUS_CUSTOMER_OWNED = 'Customer Owned';
    public static final String DEFAULT_ORDER_PRODUCT_STATUS = STATUS_CUSTOMER_OWNED;

    public static final String WARNING_MESSAGE_EXISTING_ASSET = 'Existing assets found. If you don’t change the serial number, the existing asset will be overridden with new data. Data includes: Account, Product, etc';
    public static final String SUCCESS_MESSAGE_NO_EXISTING_ASSETS = 'No existing assets were found matching the provided serial numbers.';
    public static final String ERROR_EXISTING_ASSET_WITH_STATUS_NOT_CUSTOMER_OWNED = 'A product exists on the order with a serial number matching an existing asset. Products matching existing assets must have a status of Customer Owned.';

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
        this.existingAssetsExist = false;
        resetExistingAssets();

        Set<String> serialNumbers = getSerialNumbersFromWrappers();

        System.debug('Serial numbers from wrappers: ' + serialNumbers);

        List<Asset> existingAssets = queryAssetsMatchingSerialNumbers(serialNumbers);
        Map<String, Asset> serialNumberToAssetMap = buildSerialNumberToAssetMap(existingAssets);

        Boolean assetsExistMatchingSerialNumbers = updateOrderProductWrappersExistingAssets(serialNumberToAssetMap);

        if(assetsExistMatchingSerialNumbers){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,WARNING_MESSAGE_EXISTING_ASSET);
            ApexPages.addMessage(myMsg);
            this.existingAssetsExist = true;
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,SUCCESS_MESSAGE_NO_EXISTING_ASSETS);
            ApexPages.addMessage(myMsg);
        }

        return null;
    }

    public PageReference rerenderForm(){
        return null;
    }

    public PageReference saveAndShip(){
        String errorValidating = validate();

        if(errorValidating != null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorValidating);
            ApexPages.addMessage(myMsg);
            return null;
        }

        updateOrderProducts();

        PageReference page = new PageReference('/' + order.Id);
        page.setRedirect(true);
        return page;
    }

    public PageReference returnToOrder(){
        PageReference page = new PageReference('/' + order.Id);
        page.setRedirect(true);
        return page;
    }

    public PageReference applyCSVFile(){
        System.debug('Applying CSV File.');

        if(csvFile.Body == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No CSV file uploaded.');
            ApexPages.addMessage(myMsg);
            return null;
        }

        try{
            List<String> csvElements = buildCSVElements();
            this.fileRowWrappers = buildFileRowWrappers(csvElements);
            Map<String, CSVFileRow> productCodeToCSVRow = buildProductCodeToCSVFileRow();
            populateOrderProductWrappersWithFileInfo(productCodeToCSVRow);

            uploadedFile = true;
        }
        catch(Exception e){
            System.debug('Exception occurred process file.');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An error occurred processing the file. Please check ensure the file is in the correct format.');
            ApexPages.addMessage(myMsg);
        }

        return null;
    }

    /**
    *  Save and Ship Helper Methods
    */ 

    private String validate(){
        String errorValidating;

        errorValidating = ensureCustomerOwnedStatusIfSNMatchesExistingAsset();

        return errorValidating;
    }

    private String ensureCustomerOwnedStatusIfSNMatchesExistingAsset(){
        String errorValidating;

        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            if(orderProductWrapper.existingAssetWrappers.size() > 0 && !STATUS_CUSTOMER_OWNED.equalsIgnoreCase(orderProductWrapper.orderProduct.SBCF_Status__c)){
                return ERROR_EXISTING_ASSET_WITH_STATUS_NOT_CUSTOMER_OWNED;
            }
        }

        return errorValidating;
    }

    private void updateOrderProducts(){
        List<OrderItem> orderProductsRelatedToWrappers = getOrderProductsOnWrappers();
        update orderProductsRelatedToWrappers;
    }

    private List<OrderItem> getOrderProductsOnWrappers(){
        List<OrderItem> orderProductsRelatedToWrappers = new List<OrderItem>();

        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            orderProductsRelatedToWrappers.add(orderProductWrapper.orderProduct);
        }

        return orderProductsRelatedToWrappers;
    }

    /**
    *  checkSericalNumberStatus Helper Methods
    */

    private void resetExistingAssets(){
        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            orderProductWrapper.existingAssetWrappers = new List<OrderShipmentHelper.ExistingAssetWrapper>();
        }      
    }

    private Boolean updateOrderProductWrappersExistingAssets(Map<String, Asset> serialNumberToAssetMap){
        Boolean assetsExistMatchingSerialNumbers = false;

        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            if(orderProductWrapper.orderProduct.Serial_Number__c == null){
                continue;
            }

            List<String> parsedSerialNumbers = orderProductWrapper.orderProduct.Serial_Number__c.split(';');

            for(String serialNumber:parsedSerialNumbers){
                Asset existingAsset = serialNumberToAssetMap.get(serialNumber);

                if(existingAsset == null){
                    continue;
                }

                System.debug('Existing asset found!');

                //orderProductWrapper.existingAssetIds.add(existingAsset.Id);
                orderProductWrapper.existingAssetWrappers.add(new OrderShipmentHelper.ExistingAssetWrapper(existingAsset.Id, SerialNumber, existingAsset));
                assetsExistMatchingSerialNumbers = true;                
            }
        }

        return assetsExistMatchingSerialNumbers;
    }

    private Map<String, Asset> buildSerialNumberToAssetMap(List<Asset> existingAssets){
        Map<String, Asset> serialNumberToAssetMap = new Map<String, Asset>();

        for(Asset existingAsset: existingAssets){
            serialNumberToAssetMap.put(existingAsset.SerialNumber, existingAsset);
        }

        System.debug('Serial Number to Asset Map: ' + serialNumberToAssetMap);

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

        System.debug('Existing Assets: ' + existingAssets);

        return existingAssets;
    }

    private Set<String> getSerialNumbersFromWrappers(){
        Set<String> serialNumbersFromWrappers = new Set<String>();

        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            if(orderProductWrapper.orderProduct.Serial_Number__c == null){
                // May want to stop here and display message to user. 
                continue;
            }

            List<String> parsedSerialNumbers = orderProductWrapper.orderProduct.Serial_Number__c.split(';');

            if(parsedSerialNumbers != null){
                for(String serialNumber: parsedSerialNumbers){
                    serialNumbersFromWrappers.add(SerialNumber);
                }
            }            
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

            orderProductWrapper.orderProduct.Quantity = Decimal.valueOf(csvRow.column2);
            orderProductWrapper.orderProduct.Part_Number__c = csvRow.column3;
            orderProductWrapper.orderProduct.Serial_Number__c = csvRow.column4;
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
        public String column4 {get;set;}

        public CSVFileRow(List<String> rowElements){
            this.column1 = rowElements[0];
            this.column2 = rowElements[1];
            this.column3 = rowElements[2];
            this.column4 = rowElements[3];
        }   
    }

}