public class PortalDataWrapper implements comparable
    {
        public Id RecordId {get;set;}
        public string ProductName {get;set;}
        public string SerialNumber {get;set;}
        public string AccountName {get;set;}
        public Date ShipDate {get;set;}
        public decimal Quantity {get;set;}
        public Date ContractEndDate {get;set;}
        public Date LicenseEndDate {get;set;}
        public Date SmartHandsEndDate {get;set;}
        public Date WarrantyEndDate {get;set;}
        public Date WarrantyStartDate {get;set;}
        public Date EndOfMaintenance {get;set;}
        public string LicenseKey {get;set;}
        public string CustomerNotes {get;set;}
        public string Status {get;set;}
        public string Model {get;set;}
        public string ProductType {get;set;}
        public string ProductFamily {get;set;}
        public string OldCustomerNotes {get;set;}
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
                 if(sortableField == 'ContractEndDate'){     
                    if (ContractEndDate == compWrap.ContractEndDate) return 0;
                    if (ContractEndDate > compWrap.ContractEndDate) return 1;
                    return -1;        
                }
                if(sortableField == 'ShipDate'){     
                    if (ShipDate == compWrap.ShipDate) return 0;
                    if (ShipDate > compWrap.ShipDate) return 1;
                    return -1;        
                }
                if(sortableField == 'LicenseKey'){     
                    if (LicenseKey == compWrap.LicenseKey) return 0;
                    if (LicenseKey > compWrap.LicenseKey) return 1;
                    return -1;        
                }
                if(sortableField == 'WarrantyStartDate'){     
                    if (WarrantyStartDate == compWrap.WarrantyStartDate) return 0;
                    if (WarrantyStartDate > compWrap.WarrantyStartDate) return 1;
                    return -1;        
                }
                  if(sortableField == 'WarrantyEndDate'){     
                    if (WarrantyEndDate == compWrap.WarrantyEndDate) return 0;
                    if (WarrantyEndDate > compWrap.WarrantyEndDate) return 1;
                    return -1;        
                }
                if(sortableField == 'EndOfMaintenance'){     
                    if (EndOfMaintenance == compWrap.EndOfMaintenance) return 0;
                    if (EndOfMaintenance > compWrap.EndOfMaintenance) return 1;
                    return -1;        
                }
                 if(sortableField == 'LicenseEndDate'){     
                    if (LicenseEndDate == compWrap.LicenseEndDate) return 0;
                    if (LicenseEndDate > compWrap.LicenseEndDate) return 1;
                    return -1;        
                }
                 if(sortableField == 'CustomerNotes'){     
                    if (CustomerNotes == compWrap.CustomerNotes) return 0;
                    if (CustomerNotes > compWrap.CustomerNotes) return 1;
                    return -1;        
                }
                if(sortableField == 'Quantity'){     
                    if (Quantity == compWrap.Quantity) return 0;
                    if (Quantity > compWrap.Quantity) return 1;
                    return -1;        
                }
                  if(sortableField == 'Status'){     
                    if (Status == compWrap.Status) return 0;
                    if (Status > compWrap.Status) return 1;
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
                 if(sortableField == 'ContractEndDate'){     
                    if (ContractEndDate == compWrap.ContractEndDate) return 0;
                    if (ContractEndDate > compWrap.ContractEndDate) return -1;
                    return 1;        
                }
                if(sortableField == 'ShipDate'){     
                    if (ShipDate == compWrap.ShipDate) return 0;
                    if (ShipDate > compWrap.ShipDate) return -1;
                    return 1;        
                }
                if(sortableField == 'LicenseKey'){     
                    if (LicenseKey == compWrap.LicenseKey) return 0;
                    if (LicenseKey > compWrap.LicenseKey) return -1;
                    return 1;        
                }
                  if(sortableField == 'WarrantyStartDate'){     
                    if (WarrantyStartDate == compWrap.WarrantyStartDate) return 0;
                    if (WarrantyStartDate > compWrap.WarrantyStartDate) return -1;
                    return 1;        
                }
                  if(sortableField == 'WarrantyEndDate'){     
                    if (WarrantyEndDate == compWrap.WarrantyEndDate) return 0;
                    if (WarrantyEndDate > compWrap.WarrantyEndDate) return -1;
                    return 1;        
                }
                if(sortableField == 'EndOfMaintenance'){     
                    if (EndOfMaintenance == compWrap.EndOfMaintenance) return 0;
                    if (EndOfMaintenance > compWrap.EndOfMaintenance) return -1;
                    return 1;        
                }
                 if(sortableField == 'LicenseEndDate'){     
                    if (LicenseEndDate == compWrap.LicenseEndDate) return 0;
                    if (LicenseEndDate > compWrap.LicenseEndDate) return -1;
                    return 1;        
                }
                if(sortableField == 'CustomerNotes'){     
                    if (CustomerNotes == compWrap.CustomerNotes) return 0;
                    if (CustomerNotes > compWrap.CustomerNotes) return -1;
                    return 1;        
                }
                if(sortableField == 'Quantity'){     
                    if (Quantity == compWrap.Quantity) return 0;
                    if (Quantity > compWrap.Quantity) return -1;
                    return 1;        
                }
                 if(sortableField == 'Status'){     
                    if (Status == compWrap.Status) return 0;
                    if (Status > compWrap.Status) return -1;
                    return 1;        
                }
                
            }
            
            return null;
        }    
        
    }