/**************************************************************************************************************
* Created By: drew.justus@simplus.com
* Created Date: 02/01/2018
* Description: Controller for the HardwareShipment.page. Controller provides functionality to parse a CSV file
* and populate Order Product Items based on data in the file. Controller matches products in file (Req#) to
* the Sales Order Number field on the order. Parse and population occurs on 'Apply Serial Numbers File' button.
* 
* The page also includes functionality to check serial numbers on existing assets in the system. If existing
* assets are found, the Existing Asset lookup field is populated on the Order Product Item. 
*
* Page uses a new Order Product Item object to store Serial Numbers, Part Numbers, Statuses and existing assets
* specific to each Order Product Quantity.
*
* Updated By: drew.justus@simplus.com
* Update Date: 03/05/2018
* Update Description: It was requested on Demo 03/02/2018 that we alert the user if two of the same serial
* numbers exist on the order. Made modification to perform this action. 
*
* @Test - HardwareShipmentControllerTest - 93%
***************************************************************************************************************/
public with sharing class HardwareShipmentController {

    public static final Integer CSV_COLUMN_SIZE = 26;

    public static final String STATUS_CUSTOMER_EVALUATION = 'Customer Evaluation';
    public static final String STATUS_CUSTOMER_OWNED = 'Customer Owned';

    public static final String DEFAULT_ORDER_PRODUCT_STATUS = STATUS_CUSTOMER_OWNED;

    public static final String ACTIVATED_ORDER_STATUS = 'Activated';
    public static final String SAVE_ORDER_SHIPPING_STATUS = 'Shipping - Complete';
    public static final String SAVE_PRICE_CALCULATION_STATUS = 'Completed';

    public static final String WARNING_MESSAGE_EXISTING_ASSET = 'Existing assets found. If you don’t change the serial number, the existing asset will be overridden with new data. Data includes: Account, Product, etc';
    public static final String SUCCESS_MESSAGE_NO_EXISTING_ASSETS = 'No existing assets were found matching the provided serial numbers.';
    public static final String ERROR_EXISTING_ASSET_WITH_STATUS_NOT_CUSTOMER_OWNED = 'A product exists on the order with a serial number matching an existing asset. Products matching existing assets must have a status of Customer Owned.';
    public static final String WARNING_USE_CHECK_SERIAL_NUMBERS_BEFORE_SUBMIT = 'Please Check Serial Numbers Status before Saving.';

    //public static final String RECORD_TYPE_STANDARD = 'Sandard';
    //public static final String RECORD_TYPE_EVAL = 'POC';

    public static final String RETURN_CHARACTER = '\r\n';
    public static final Integer DOUBLE_QUOTE_CHAR_VALUE = 34;

	public Order order {get;set;}

    public List<OrderShipmentHelper.OrderProductWrapper> orderProductWrappers {get;set;}
    public Document csvFile {get;set;}
    transient private List<CSVFileRow> fileRowWrappers {get;set;}

    public String copySerialNumberOrderProductId {get;set;}
    public OrderShipmentHelper.OrderProductWrapper copySerialNumberOrderProductWrapper {get;set;}
    public String copySerialNumbers {get;set;}

    public Boolean uploadedFile {get;set;}
    public Boolean existingAssetsExist {get;set;}
    public Boolean orderIsActivated {get;set;}
    public Boolean noPhysicalOrderProducts {get;set;}
    public Boolean hasCheckedSerialNumbers {get;set;}
    public Boolean hasUpdatedSNsSinceSNsChecked {get;set;}

    public Boolean displayErrorOnly{
        get{
            if(orderIsActivated || noPhysicalOrderProducts){
                return true;
            }

            return false;
        }
    }


    public HardwareShipmentController(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(OrderShipmentHelper.getAllOrderFieldsAPINames());
        }

        this.order = (Order)stdController.getRecord();

        this.orderIsActivated = OrderShipmentHelper.determineIsOrderActivated(this.order);

        if(this.orderIsActivated){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Serial Numbers Cannot be applied to active orders.');
            ApexPages.addMessage(myMsg);
            return;
        }

        List<OrderItem> orderProducts = OrderShipmentHelper.queryForOrderProducts(order.Id, OrderShipmentHelper.PRODUCT_CATEGORY_HARDWARE);
        System.debug('Order Products: ' + orderProducts);

        if(orderProducts == null || orderProducts.size() == 0){
            System.debug('There are no order products with forecast category Physical.');
            this.noPhysicalOrderProducts = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'There are no order products with forecast category physical.');
            ApexPages.addMessage(myMsg);
            return;
        }

        List<Order_Product_Item__c> relatedOrderProductItems = OrderShipmentHelper.queryForOrderProductItems(orderProducts);
        System.debug('Related Order Product Items: ' + relatedOrderProductItems);

        List<OrderShipmentHelper.OrderProductItemWrapper> orderProductItemWrappers = OrderShipmentHelper.buildOrderProductItemWrappers(relatedOrderProductItems, orderProducts);
        System.debug('Order product item wrappers: ' + orderProductItemWrappers);

        this.orderProductWrappers = OrderShipmentHelper.buildOrderProductWrappers(orderProducts, orderProductItemWrappers);
        System.debug('Order product wrappers: ' + this.orderProductWrappers);

        this.csvFile = new Document();
        this.fileRowWrappers = new List<CSVFileRow>();

        defaultOrderItemStatus();

        this.uploadedFile = false;
        this.existingAssetsExist = false;
        this.hasCheckedSerialNumbers = false;
        this.hasUpdatedSNsSinceSNsChecked = false;
        this.noPhysicalOrderProducts = false;

        if(OrderShipmentHelper.hasInsertedOrderProductItems == true){
            checkSerialNumberStatus();
        }

        Boolean result = OrderShipmentHelper.orderProductItemCountMatchesOrderProductQuantity(this.orderProductWrappers);

        if(result == false){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Order Product quantity does not match order product items.');
            ApexPages.addMessage(myMsg);
        }
    }

    /**
    *  Public Methods
    **/

    public PageReference checkSerialNumberStatus(){
        this.hasCheckedSerialNumbers = true;

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
            this.hasUpdatedSNsSinceSNsChecked = false;
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,SUCCESS_MESSAGE_NO_EXISTING_ASSETS);
            ApexPages.addMessage(myMsg);
        }

        this.hasUpdatedSNsSinceSNsChecked = false;

        addPageMessagesForDuplicateSNsOnOrder();

        return null;
    }

    public PageReference rerenderForm(){
        return null;
    }

    public PageReference save(){
        List<Order_Product_Item__c> orderProductItemsToUpsert = OrderShipmentHelper.getOrderProductItemsFromWrappers(this.orderProductWrappers);

        if(orderProductItemsToUpsert.size() > 0){
            upsert orderProductItemsToUpsert;
        }        

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

            System.debug('File rows before filter: ' + this.fileRowWrappers);
            System.debug('File row size before filter: ' + this.fileRowWrappers.size());

            this.fileRowWrappers = filterFileRows(this.fileRowWrappers);
            System.debug('File rows after filter: ' + this.fileRowWrappers);
            System.debug('File row size after filter: ' + this.fileRowWrappers.size());

            Map<String, List<CSVFileRow>> productCodeToCSVRow = buildProductCodeToCSVFileRows();
            populateOrderProductItemWrappersWithFileInfo(productCodeToCSVRow);

            //uploadedFile = true;
        }
        catch(Exception e){
            System.debug('Exception occurred process file.');
            System.debug('Exception Message: ' + e.getMessage());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An error occurred processing the file. Please check ensure the file is in the correct format.');
            ApexPages.addMessage(myMsg);
        }

        checkSerialNumberStatus();
        this.csvFile = new Document();

        return null;
    }

    public PageReference updateCopySerialNumberView(){
        System.debug('Update Copy Serial Number View.');
        System.debug('Copy Serial Number Order Product Id: ' + this.copySerialNumberOrderProductId);

        setCopySerialNumbersOrderProductWrapper();
        setCopySerialNumbers();

        return null;
    }

    /**
    * updateCopySerialNumberView helper methods
    **/

    private void setCopySerialNumbers(){
        copySerialNumbers = '';

        for(OrderShipmentHelper.OrderProductItemWrapper orderProductItemWrapper: this.copySerialNumberOrderProductWrapper.orderProductItems){
            if(orderProductItemWrapper.orderProductItem.Serial_Number__c != null){
                copySerialNumbers += orderProductItemWrapper.orderProductItem.Serial_Number__c + RETURN_CHARACTER;
            }
        }
    }

    private void setCopySerialNumbersOrderProductWrapper(){
        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            if(orderProductWrapper.orderProduct.Id == this.copySerialNumberOrderProductId){
                 this.copySerialNumberOrderProductWrapper = orderProductWrapper;
                 break;
            }
        }
    }

    /**
    *  checkSericalNumberStatus Helper Methods
    */

    // Update - 3/05/2018 - Add page messages if duplicate serial numbers exist on order
    private void addPageMessagesForDuplicateSNsOnOrder(){
        Set<String> serialNumbersOnOrder = new Set<String>();
        Set<String> duplicateSerialNumbers = new Set<String>();

        for(OrderShipmentHelper.OrderProductWrapper orderProduct: this.orderProductWrappers){            

            if(orderProduct.orderProductItems == null){
                continue;
            }

            for(OrderShipmentHelper.OrderProductItemWrapper orderProductItem: orderProduct.orderProductItems){
                if(orderProductItem.orderProductItem != null && orderProductItem.orderProductItem.Serial_Number__c != null){
                    Boolean isDuplicateSN = serialNumbersOnOrder.contains(orderProductItem.orderProductItem.Serial_Number__c);

                    if(isDuplicateSN){
                        duplicateSerialNumbers.add(orderProductItem.orderProductItem.Serial_Number__c);                      
                    }
                    else{
                        serialNumbersOnOrder.add(orderProductItem.orderProductItem.Serial_Number__c);
                    }
                }
            }

            for(String duplicateSN: duplicateSerialNumbers){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Duplicate Serial Number: ' + duplicateSN);
                ApexPages.addMessage(myMsg);
            }
        }
    }

    private void resetExistingAssets(){
        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            for(OrderShipmentHelper.OrderProductItemWrapper orderProductItem: orderProductWrapper.orderProductItems){
                orderProductItem.orderProductItem.Existing_Asset__c = null;
                orderProductItem.existingAsset = null;
            }
        }      
    }

    private Boolean updateOrderProductWrappersExistingAssets(Map<String, Asset> serialNumberToAssetMap){
        Boolean assetsExistMatchingSerialNumbers = false;

        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            for(OrderShipmentHelper.OrderProductItemWrapper orderProductItemWrapper: orderProductWrapper.orderProductItems){
                if(orderProductItemWrapper.orderProductItem.Serial_Number__c == null){
                    // May need validation on Custom activate button to ensure SNs on all or specific order product items.
                    continue;
                }

                Asset existingAsset = serialNumberToAssetMap.get(orderProductItemWrapper.orderProductItem.Serial_Number__c);

                if(existingAsset == null){
                    continue;
                }

                System.debug('Existing asset found!');

                orderProductItemWrapper.orderProductItem.Existing_Asset__c = existingAsset.Id;
                orderProductItemWrapper.existingAsset = existingAsset;
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
            existingAssets = [SELECT Id, SerialNumber, Status FROM Asset WHERE SerialNumber != null AND SerialNumber in :serialNumbers];
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
            for(OrderShipmentHelper.OrderProductItemWrapper orderProductItem: orderProductWrapper.orderProductItems){
                if(orderProductItem.orderProductItem.Serial_Number__c == null){
                    // May want to stop here and display message to user. 
                    continue;
                }

                serialNumbersFromWrappers.add(orderProductItem.orderProductItem.Serial_Number__c);
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
            for(OrderShipmentHelper.OrderProductItemWrapper itemWrapper: orderProductWrapper.orderProductItems){
                if(itemWrapper.orderProductItem.Status__c == null){
                    itemWrapper.orderProductItem.Status__c = defaultOrderProductStatus;
                }
            }
        }
    }   

    private String getDefaultOrderProductStatus(){
        SBQQ__Quote__c relatedQuote = queryForRelatedQuote();

        if(relatedQuote == null){
            return DEFAULT_ORDER_PRODUCT_STATUS;
        }

        if(relatedQuote.SBCF_Evaluation_Quote__c == true){
            return STATUS_CUSTOMER_EVALUATION;
        }
        else{
            return STATUS_CUSTOMER_OWNED;
        }
    }

    private SBQQ__Quote__c queryForRelatedQuote(){
        SBQQ__Quote__c relatedQuote;

        if(this.order.SBQQ__Quote__c == null){
            // return null
            System.debug('SBQQ__Quote__c lookup field null');
            return relatedQuote;
        }
        
        try{
            relatedQuote = [SELECT SBCF_Evaluation_Quote__c, RecordType.Name FROM SBQQ__Quote__c WHERE Id = :order.SBQQ__Quote__c LIMIT 1];
        }   
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }

        return relatedQuote;
    }

    private void populateOrderProductItemWrappersWithFileInfo(Map<String, List<CSVFileRow>> productCodeToCSVRows){
        for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
            List<CSVFileRow> csvRows = productCodeToCSVRows.get(orderProductWrapper.orderProduct.Product2.ProductCode);

            if(csvRows == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Order Product: ' + orderProductWrapper.orderProduct.Product2.Name + ' - No csv rows match product.');
                ApexPages.addMessage(myMsg);
                continue;
            }
            if(orderProductWrapper.orderProductItems == null){
                continue;
            }

            if(csvRows.size() > orderProductWrapper.orderProductItems.size()){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 
                    'Order Product: ' + orderProductWrapper.orderProduct.Product2.Name + ' - ' + csvRows.size() + ' matching products in the file, but only ' + orderProductWrapper.orderProductItems.size() + ' on the order. ');
                ApexPages.addMessage(myMsg);
            }
            else if(orderProductWrapper.orderProductItems.size() > csvRows.size()){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 
                    'Order Product: ' + orderProductWrapper.orderProduct.Product2.Name + ' - ' + orderProductWrapper.orderProductItems.size() + ' products on the order, but only ' + csvRows.size() + ' in the file.');
                ApexPages.addMessage(myMsg);
            }

            for(Integer i=0; i<orderProductWrapper.orderProductItems.size() && i<csvRows.size(); i++){
                OrderShipmentHelper.OrderProductItemWrapper itemWrapper = orderProductWrapper.orderProductItems[i];
                CSVFileRow row = csvRows[i];

                String partNumber = '';

                if(row.column7 != null){
                    List<String> column7Strings = row.column7.split('_');
                    if(column7Strings != null && column7Strings.size() == 2){
                        partNumber = column7Strings[1];
                    }
                }                

                itemWrapper.orderProductItem.Serial_Number__c = row.column8;
                itemWrapper.orderProductItem.Part_Number__c = partNumber;
            }
        }
    }
    
    private Map<String, List<CSVFileRow>> buildProductCodeToCSVFileRows(){
        Map<String, List<CSVFileRow>> productCodeToCSVRows = new Map<String, List<CSVFileRow>>();

        for(CSVFileRow row: this.fileRowWrappers){
            if(row.column7 == null){
                continue;
            }

            String productCode = '';

            if(row.column7 != null){
                List<String> column7Strings = row.column7.split('_');
                if(column7Strings != null && column7Strings.size() >= 1){
                    productCode = column7Strings[0];
                }
            }

            List<CSVFileRow> csvRows = productCodeToCSVRows.get(productCode);

            if(csvRows == null){
                csvRows = new List<CSVFileRow>();
                productCodeToCSVRows.put(productCode, csvRows);
            }

            csvRows.add(row);
        }

        System.debug('Product Code To CSV Rows: ' + productCodeToCSVRows);

        return productCodeToCSVRows;
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

        Integer index = 0;
        Integer nextIndex = 0;

        // Strip the " and the commas out of the Tracking # column
        do{
            index = csvBody.indexOfChar(DOUBLE_QUOTE_CHAR_VALUE, index);

            System.debug('Index of ": ' + index);

            if(index != -1){
                System.debug('Index not equal to -1');

                nextIndex = csvBody.indexOfChar(DOUBLE_QUOTE_CHAR_VALUE, index+1);

                System.debug('Next index: ' + nextIndex);

                if(nextIndex != null){
                    String subString = csvBody.substring(index, nextIndex+1);

                    System.debug('Substring: ' + subString);

                    if(subString != null){
                        String updatedSubString = subString.replaceAll(',', ';');
                        updatedSubString = updatedSubString.replaceAll('"', '');
                        csvBody = csvBody.replaceAll(subString, updatedSubString);
                    }
                }
            }
            
        }while(index != -1 && nextIndex != -1);


        //// Here everything should be truly column delimited.  
        List<String> csvElements = csvBody.split(',');

        return csvElements;
    }

    /*
    * Filter file rows that 
    *   - do not mate order Sales Order Number (col4) 
    *   - do not have a value for the SN. (col8)
    *   - do not have a value for the Product Code (col7)
    *   - do not have a quantity of 1 (col11)
    */
    private List<CSVFileRow> filterFileRows(List<CSVFileRow> unfilteredFileRows){
        List<CSVFileRow> filteredFileRows = new List<CSVFileRow>();

        // Part Number 

        for(CSVFileRow unfilteredRow: unfilteredFileRows){
            if(
                (unfilteredRow.column4 != null && unfilteredRow.column4.equalsIgnoreCase(this.order.Sales_Order_Number__c)) &&
                 unfilteredRow.column8 != null &&
                 unfilteredRow.column7 != null &&
                (unfilteredRow.column11 != null && unfilteredRow.column11.equalsIgnoreCase('1'))
                                                                                                                             ){
                filteredFileRows.add(unfilteredRow);
            }
        }

        return filteredFileRows;
    }

    /**
    *  applyCSVFile Helper Methods - End
    **/

    public class CSVFileRow{

        public String column1 {get;set;}
        public String column2 {get;set;}
        public String column3 {get;set;}
        public String column4 {get;set;} // Req# - Sales Order Number
        public String column5 {get;set;}
        public String column6 {get;set;}
        public String column7 {get;set;} // Item# - Product Code and Part Number - Format ProductCode_PartNumber
        public String column8 {get;set;} // S/N - Serial Number
        public String column9 {get;set;}
        public String column10 {get;set;}
        public String column11 {get;set;} // Qty - Quantity
        public String column12 {get;set;}
        public String column13 {get;set;}
        public String column14 {get;set;}
        public String column15 {get;set;}
        public String column16 {get;set;}
        public String column17 {get;set;}
        public String column18 {get;set;}
        public String column19 {get;set;}
        public String column20 {get;set;}
        public String column21 {get;set;}
        public String column22 {get;set;}
        public String column23 {get;set;}
        public String column24 {get;set;}
        public String column25 {get;set;}
        public String column26 {get;set;}

        public CSVFileRow(List<String> rowElements){
            this.column1 = rowElements[0];
            this.column2 = rowElements[1];
            this.column3 = rowElements[2];
            this.column4 = rowElements[3];
            this.column5 = rowElements[4];
            this.column6 = rowElements[5];
            this.column7 = rowElements[6];
            this.column8 = rowElements[7];
            this.column9 = rowElements[8];
            this.column10 = rowElements[9];
            this.column11 = rowElements[10];
            this.column12 = rowElements[11];
            this.column13 = rowElements[12];
            this.column14 = rowElements[13];
            this.column15 = rowElements[14];
            this.column16 = rowElements[15];
            this.column17 = rowElements[16];
            this.column18 = rowElements[17];
            this.column19 = rowElements[18];
            this.column20 = rowElements[19];
            this.column21 = rowElements[20];
            this.column22 = rowElements[21];
            this.column23 = rowElements[22];
            this.column24 = rowElements[23];
            this.column25 = rowElements[24];
            this.column26 = rowElements[25];
        }   
    }


    /**
    *  Save and Ship Helper Methods -- old code. May be needed if we need to do a custom activation button.
    */ 

    /* Old save and ship when order was being activated.
    public void saveAndShip(){
        String errorValidating = validate();

        if(!hasCheckedSerialNumbers){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, WARNING_USE_CHECK_SERIAL_NUMBERS_BEFORE_SUBMIT);
            ApexPages.addMessage(myMsg);
            return null;
        }

        if(errorValidating != null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorValidating);
            ApexPages.addMessage(myMsg);
            return null;
        }

        Savepoint sp = Database.setSavepoint();

        String errorUpdating;

        errorUpdating = updateOrderProducts();
        
        if(errorUpdating != null){
            Database.rollback(sp);
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating order products. Error Details: ' + errorUpdating);
            //ApexPages.addMessage(myMsg);
            return null;
        }

        errorUpdating = updateOrder();

        if(errorUpdating != null){
            Database.rollback(sp);
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating order. Error Details: ' + errorUpdating);
            //ApexPages.addMessage(myMsg);
            return null;
        }

        printAssetsCreatedInTheLast30Seconds();
    }*/

    //private void printAssetsCreatedInTheLast30Seconds(){
    //    Datetime thirtySecondsAgo = System.now().addSeconds(-30);
    //    List<Asset> assetsCreatedInLast30Seconds = new List<Asset>();


    //    try{
    //        assetsCreatedInLast30Seconds = [SELECT Id, Name FROM Asset WHERE CreatedDate >= :thirtySecondsAgo];
    //    }
    //    catch(QueryException qe){
    //        System.debug(qe.getMessage());
    //    }

    //    System.debug('Assets Created In the Last 30 Seconds: ' + assetsCreatedInLast30Seconds);
    //}

    //private String validate(){
    //    String errorValidating;

    //    errorValidating = ensureCustomerOwnedStatusIfSNMatchesExistingAsset();

    //    return errorValidating;
    //}

    //private String ensureCustomerOwnedStatusIfSNMatchesExistingAsset(){
    //    String errorValidating;

    //    for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
    //        if(orderProductWrapper.existingAssetWrappers.size() > 0 && !STATUS_CUSTOMER_OWNED.equalsIgnoreCase(orderProductWrapper.orderProduct.SBCF_Status__c)){
    //            return ERROR_EXISTING_ASSET_WITH_STATUS_NOT_CUSTOMER_OWNED;
    //        }
    //    }

    //    return errorValidating;
    //}

    //private String updateOrderProducts(){
    //    try{
    //        List<OrderItem> orderProductsRelatedToWrappers = getOrderProductsOnWrappers();
    //        update orderProductsRelatedToWrappers;
    //    }
    //    catch(DMlException e){
    //        System.debug(e.getMessage());
    //        return e.getMessage();
    //    }

    //    return null;
    //}

    //private String updateOrder(){
    //    try{
    //        this.order.Status = ACTIVATED_ORDER_STATUS;
    //        this.order.Shipping_Status__c = SAVE_ORDER_SHIPPING_STATUS;
    //        this.order.SBQQ__Contracted__c = true;
    //        this.order.SBQQ__PriceCalcStatus__c = SAVE_PRICE_CALCULATION_STATUS;
    //        update order;
    //    }
    //    catch(DMLException e){
    //        System.debug(e.getMessage());
    //        return e.getMessage();
    //    }

    //    return null;
    //}

    //private List<OrderItem> getOrderProductsOnWrappers(){
    //    List<OrderItem> orderProductsRelatedToWrappers = new List<OrderItem>();

    //    for(OrderShipmentHelper.OrderProductWrapper orderProductWrapper: this.orderProductWrappers){
    //        orderProductsRelatedToWrappers.add(orderProductWrapper.orderProduct);
    //    }

    //    return orderProductsRelatedToWrappers;
    //}

}