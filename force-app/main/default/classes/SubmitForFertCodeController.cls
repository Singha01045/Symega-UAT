public without sharing class SubmitForFertCodeController {
    
    @AuraEnabled
    public static oppProdWrapper getOpportunityprods(String OppId){
        
        try{
            List<string> missingFieldsList = new List<string>();
            List<OpportunityLineItem> oppLineItemList = [SELECT ID, Name, Product2Id,Packaging_Type__c, Art_Work__c, OpportunityId, Opportunity.Account_Billing_Address__c, Opportunity.Account.Customer_Code_SAP__c, Opportunity.AccountId, Opportunity.Account.Name, Opportunity.Billing_Country__c, Opportunity.Billing_State__c, Opportunity.Billing_Street__c, Opportunity.Billing_City__c, Opportunity.Billing_Postal_Code__c,Quantity,Fert_Description__c,Unit_Of_Measure__c,ProductCode,Packaging_Quantity__c, Product2.Shelf_Life__c, Product2.Allergen_Status_Required__c,Product2.Veg_Nonveg_Logo_In_Label__c,Ingredients_List_Declared_With_Customer__c,Customized_Label__c,Ingredient_list__c,Reveal_Symega_Identity__c,Cusinery_identity__c,Label__c,Sales_Remarks__c, Product2.Plant__c,Product2.Control_Code_HSN_Code__c,Primary__c,Secondary__c,Tertiary__c FROM OpportunityLineItem WHERE OpportunityId =:OppId];
            //List<Dispatch_Address__c> disPatchAddList = [SELECT ID,Address__c,Account__c,SAP_Customer_Code__c From Dispatch_Address__c where Account__c =: oppLineItemList[0].Opportunity.AccountId];
            System.debug('oppLineItemList---->'+oppLineItemList);
            //System.debug('disPatchAddList---->'+disPatchAddList);

            
            oppProdWrapper opWrap = new oppProdWrapper();
            opWrap.oliList = oppLineItemList;
            opWrap.missingFieldsList = getOppRelatedAccountDetails(oppLineItemList[0].Opportunity.AccountId);
            opwrap.accId = oppLineItemList[0].Opportunity.AccountId;
            return opWrap;
        }
        catch(Exception e){
            System.debug('Exception Line Number-->'+e.getLineNumber());
            System.debug('Exception Message-->'+e.getMessage());
            return null;
        }
    }

    public class oppProdWrapper{
        @AuraEnabled
        public  List<OpportunityLineItem> oliList;
        @AuraEnabled
        public Id accId;
        @AuraEnabled
        public List<String> missingFieldsList;
    }
    
    @AuraEnabled
    Public Static Map<String,Map<String,List<String>>> GetPicklistValues_Object(){
        string ObjectName,FieldApi_Name;
        
        ObjectName='OpportunityLineItem';FieldApi_Name='Label__c';
        getPickListValuesIntoList(ObjectName,FieldApi_Name);
        
        Map<String,Map<String,List<String>>> ObjectName_FieldApiName_PickListValue=new Map<String,Map<String,List<String>>>();
        
        if(FieldApi_Name=='Label__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name); 
            ObjectName_FieldApiName_PickListValue.put('Label',getPickListValuesIntoList);
            ObjectName='OpportunityLineItem';FieldApi_Name='Ingredients_List_Declared_With_Customer__c';
        }
        if(FieldApi_Name=='Ingredients_List_Declared_With_Customer__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Ingredients_List_Declared_With_Customer',getPickListValuesIntoList);
            ObjectName='OpportunityLineItem';FieldApi_Name='Packaging_Type__c';
            
        }
        if(FieldApi_Name=='Packaging_Type__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Packaging_Type',getPickListValuesIntoList);
            
        }
        return ObjectName_FieldApiName_PickListValue;
    }
        
    public static Map<String,List<String>> getPickListValuesIntoList(String ObjectName,String FieldApiName){
        
        Map<String,List<String>> ObjectName_FieldApiName_PickListValue=new  Map<String,List<String>>();
        List<String> pickListValuesList= new List<String>();
        
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(FieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());  
        }
        ObjectName_FieldApiName_PickListValue.put(FieldApiName,pickListValuesList);
        return ObjectName_FieldApiName_PickListValue;
    }
    
    @AuraEnabled
    Public Static String updateOppProdList(List<OpportunityLineItem> oppLineList, String prodList){
        System.debug('prodList--->'+prodList);
        map<Id,Boolean> boolMap = new map<Id,Boolean>();
        
        // Parse the JSON list and extract "prodId" values
        List<WrapperData> prodListMap = (List<WrapperData>)JSON.deserialize(prodList, List<WrapperData>.class);
        system.debug('prodListMap---->'+prodListMap);
        
        Map<Id, Boolean> mapOfProductIdByBool = new Map<Id, Boolean>();
        for(WrapperData wd: prodListMap){
            mapOfProductIdByBool.put(wd.prodId, wd.bool);
        }
        system.debug('mapOfProductIdByBool---->'+mapOfProductIdByBool);
                      
        List<Product2> prodRecList = [SELECT Id, Allergen_Status_Required__c FROM Product2 WHERE Id IN: mapOfProductIdByBool.keySet()];
        for(Product2 prod : prodRecList){
            system.debug('prod.Id--->' + prod.Id);
            if(mapOfProductIdByBool.containsKey(prod.Id)){
                prod.Allergen_Status_Required__c = mapOfProductIdByBool.get(prod.Id); 
            }
        }
        String result;
        try{
            update prodRecList;
            update oppLineList;
         //   result = GetFERTCodeController.sendFERTCodeReqEmailNotificaiton(oppLineList[0].OpportunityId);
            //result = 'SUCCESS';
        }
        catch(Exception e){
            System.debug('Exception Line Number-->'+e.getLineNumber());
            System.debug('Exception Message-->'+e.getMessage());
            result = e.getMessage();
        }    
        return result;
    }
    
    public class WrapperData{
        @AuraEnabled
        public  Id prodId ; // { get; set; }
        @AuraEnabled
        public Boolean bool ; //{ get; set; }
    }


    private static List<String> getOppRelatedAccountDetails(String accId){
        List<String> missingFieldsList = new List<String>();
        try{
            /*if(String.isNotBlank(oppId))
                opp = [SELECT Id, AccountId, Name FROM Opportunity WHERE Id=:oppId];
            if(string.isNotBlank(opp.AccountId)){

                string accValidationsResp = Utility.checkForInitialSubmission(opp.AccountId);
                if(accValidationsResp.equalsIgnoreCase('Success')){
                    return false;
                }
                else{
                    return true;
                }
            }*/

            Account accRec = [Select Id,Name, Customer_Type__c,CurrencyIsoCode,BillingCity,BillingCountry,BillingStreet,BillingPostalCode,BillingState,Delivery_Plant__c,Account_Segment__c,Transportation_Terms__c,PAN_Number__c,GST_number__c From Account Where Id =: accId];
            
            if((accRec.Name == null) || (accRec.Name == '')){
                missingFieldsList.add('Name');
            }
            
            if((accRec.BillingCity == null) || (accRec.BillingCity == '')){
                missingFieldsList.add('BillingCity');
            }
            
            if((accRec.BillingState == null) || (accRec.BillingState == '')){
                          missingFieldsList.add('BillingState');

            }               
            
            if((accRec.BillingStreet == null) || (accRec.BillingStreet == '')){
                missingFieldsList.add('BillingStreet');
            }
            
            if((accRec.BillingCountry == null) || (accRec.BillingCountry == '')){
                missingFieldsList.add('BillingCountry');
            }

            if((accRec.BillingPostalCode == null) || (accRec.BillingPostalCode == '')){
                missingFieldsList.add('BillingPostalCode');
            }

            if((accRec.Customer_Type__c == null) || (accRec.Customer_Type__c == '')){
                missingFieldsList.add('Customer_Type__c');
            }

            if((accRec.Account_Segment__c == null) || (accRec.Account_Segment__c == '')){
                missingFieldsList.add('Account_Segment__c');
            }

            if((accRec.CurrencyIsoCode == null) || (accRec.CurrencyIsoCode == '')){
                missingFieldsList.add('CurrencyIsoCode');
            }

            
            if((accRec.Delivery_Plant__c == null) || (accRec.Delivery_Plant__c == '')){
                missingFieldsList.add('CurrencyIsoCode');
            }
    
            System.debug('missingFieldsList---->'+missingFieldsList);  
            
            return missingFieldsList;
        }
        catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return missingFieldsList;
    }
    
    
}