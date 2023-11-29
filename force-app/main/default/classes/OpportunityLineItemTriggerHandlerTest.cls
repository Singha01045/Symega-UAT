@isTest
public class OpportunityLineItemTriggerHandlerTest {
    
    @isTest(SeeAllData=true)
    public static void  getTest1(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Parent').getRecordTypeId();
        
        Opportunity opp = new Opportunity(Name='PQR', StageName ='New', CloseDate= system.today(), 
                                          Annual_Volume_Full__c = 88, Annual_Volume_in_units__c = 'Kg', 
                                          Target_Price_Kg__c = 6767, End_Use_Application__c = 'Spirits', End_Use_Category__c = ' Beverages',RecordTypeId = oppRecordTypeId);
        insert opp;
         Product2 prod = new Product2(IsActive=true, Name='AAM PANNA', To_Be_Sold_By__c ='Direct', Product_Visibility__c = 'Public', Product_Used_By__c = 'Tailor Made');
        insert prod;
          OpportunityLineItem oli = new OpportunityLineItem();
        oli.Packaging_Type__c = 'Single';
        oli.OpportunityId = opp.Id;
        oli.Discount = 55;
        oli.Quantity = 87;
        oli.TotalPrice=999;
        oli.Product2Id = prod.Id;
        oli.FERT_Code__c = 'PrdCode';
        insert oli;
    }
}