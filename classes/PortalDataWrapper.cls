public class PortalDataWrapper implements comparable
    {
        public Id RecordId {get;set;}
        public string ProductName {get;set;}
        public string SerialNumber {get;set;}
        public string AccountName {get;set;}
        public Date ShipDate {get;set;}
        public Date ContractEndDate {get;set;}
        public Date LicenseEndDate {get;set;}
        public Date SmartHandsEndDate {get;set;}
        public Date WarrantyEndDate {get;set;}
        public string LicenseKey {get;set;}
        public string CustomerNotes {get;set;}
        public string Status {get;set;}
        public string Model {get;set;}
        public string ProductType {get;set;}
        public string ProductFamily {get;set;}
        public  static String sortableField='ProductName';
  		public  static String sortOrder='asc';  
        public PortalDataWrapper()
        {}
        
        public  Integer compareTo(Object compareTo) {
            PortalDataWrapper compWrap = (PortalDataWrapper)compareTo;
            if(sortOrder == 'asc')
            {
                if(sortableField == 'ProductName'){     
                    if (ProductName == compWrap.ProductName) return 0;
                    if (ProductName > compWrap.ProductName) return 1;
                    return -1;        
                }
                if(sortableField == 'AccountName'){     
                    if (AccountName == compWrap.AccountName) return 0;
                    if (AccountName > compWrap.AccountName) return 1;
                    return -1;        
                }
                 if(sortableField == 'SerialNumber'){     
                    if (SerialNumber == compWrap.SerialNumber) return 0;
                    if (SerialNumber > compWrap.SerialNumber) return 1;
                    return -1;        
                }
            }      
            else{
                if(sortableField == 'ProductName'){     
                    if (ProductName == compWrap.ProductName) return 0;
                    if (ProductName > compWrap.ProductName) return -1;
                    return 1;        
                }
                if(sortableField == 'AccountName'){     
                    if (AccountName == compWrap.AccountName) return 0;
                    if (AccountName > compWrap.AccountName) return -1;
                    return 1;        
                }
                if(sortableField == 'SerialNumber'){     
                    if (SerialNumber == compWrap.SerialNumber) return 0;
                    if (SerialNumber > compWrap.SerialNumber) return -1;
                    return 1;        
                }
            }
            
            return null;
        }    
        
    }