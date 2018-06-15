public class AccountClass {

    public List<AccountWrappercls> wrapperList{get;set;}
    public string sortableField{get;set;}
    public string sortOrder{get;set;}
    public string previoussortfield{get;set;}
    public AccountClass(){
        wrapperList = new List<AccountWrappercls>();
        sortableField = 'name';
        sortOrder = 'asc';
        previoussortfield =sortableField;
        for(Account actobj:[select id,name,CreatedDate,NumberOfEmployees from Account where CreatedDate!=null and NumberOfEmployees!=null LIMIT 10]){
            	DateTime dt= DateTime.newInstance(actobj.CreatedDate.year(), actobj.CreatedDate.month(), actobj.CreatedDate.day());
                AccountWrappercls wrapObj = new AccountWrappercls(dt,actobj.NumberOfEmployees,actobj.name);
                wrapperList.add(wrapObj);
        }           
        wrapperList.sort();
    }
    public pagereference doSort(){      
        //sortorder='asc';      
        if(previoussortfield == sortableField){
            sortorder='desc';
            previoussortfield=null;
        }
        else{
            sortorder='asc';            
            previoussortfield=sortableField;
        }
        System.debug('sortableField:::'+sortableField);
        System.debug('sortOrder::'+sortOrder);
        AccountWrappercls.sortableField = sortableField;
        AccountWrappercls.sortorder = sortOrder;        
        wrapperList.sort();
        return null;
    }



    
}