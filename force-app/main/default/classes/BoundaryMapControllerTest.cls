@isTest
public class BoundaryMapControllerTest {

    @isTest
    public static void getBoundaryMapTest() {
        List<Account> accList = new List<Account>();
        List<Route__c> routeList = new List<Route__c>();
        
        Account accRec = new Account();
        accRec.Name = 'Test FSL';
        accRec.BillingStreet = 'JP nagar';
        accRec.BillingCity = 'Bangalore';
        accRec.SAP_Update_Customer__c = true;
        insert accRec;
        accList.add(accRec);
        
        Route__c routeRec = new Route__c();
        routeRec.Predefined_Area__c = 'JP Nagar';
        routeRec.Route_Name_del__c = 'JP Nagar';
        routeRec.Sales_User__c = userinfo.getuserid();
        insert routeRec;
        routeList.add(routeRec);
        
        BoundaryMapController.getBoundaryMap();
    }
}