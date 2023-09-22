public without sharing class OppSplitParentController {

    @AuraEnabled
     public static List<Opportunity> getRecord(String oppId){
       try {
            System.debug('OppId'+oppId);
            return [Select Id, Name,AccountId,CurrencyIsoCode,TotalOpportunityQuantity,Distributer_Customer__c,Pricebook2Id,End_Use_Application__c,	End_Use_Category__c,(SELECT Id,Name,Quantity,Product2Id,PricebookEntryId,UnitPrice,CurrencyIsoCode,TotalPrice,Packaging_Type__c,FERT_Code__c From OpportunityLineItems), Amount from opportunity where Id=:oppId];
        } catch (Exception e) {
            //HandleBusinessException.captureError('OppSplitParentController', 'getRecord', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Opportunity> createOpp(Opportunity parentOpp,List<OppWrapper> oppWrappers){
        try {

            System.debug('ParentOPPPPP'+parentOpp);
            System.debug('OOPPWRAPPER----'+oppWrappers);
            List<Opportunity> oppList = new List<Opportunity>();
            for(OppWrapper opWrapper:oppWrappers){
                Opportunity opp = new Opportunity();
                opp.Name = opWrapper.oppName;
                opp.AccountId = parentOpp.AccountId;
                opp.TotalOpportunityQuantity = opWrapper.totalQuantity;
                //opp.Amount = opWrapper.totalAmount;
                opp.CurrencyIsoCode = parentOpp.CurrencyIsoCode;
                opp.Pricebook2Id = parentOpp.Pricebook2Id;
                opp.Parent_Opportunity__c = parentOpp.Id;
                opp.StageName = 'New';
                opp.CloseDate = Date.parse(opWrapper.closeDate);
                opp.Next_Order_Date__c = Date.parse(opWrapper.nextOrderDate);
                opp.End_Use_Category__c = parentOpp.End_Use_Category__c;
                opp.End_Use_Application__c = parentOpp.End_Use_Application__c;
                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('One Time').getRecordTypeId();

                if(!String.isEmpty(parentOpp.Distributer_Customer__c)){
                    opp.Distributer_Customer__c = parentOpp.Distributer_Customer__c;
                }
                oppList.add(opp);
            }

            if(!oppList.isEmpty()){
                try{
                    insert oppList;
                }catch(Exception e){
                    HandleBusinessException.captureError('OppSplitParentController', 'createOpp', e);
                }
            }

            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            List<Sales_Order__c> salesList = new List<Sales_Order__c>();

            List<String> oppIdList = new List<String>();

            for(Integer i=0;i<oppList.size();i++){
                Opportunity opp = oppList[i];
                String oppId = opp.Id;

                oppIdList.add(oppId);

                // Sales_Order__c salesOrder = new Sales_Order__c();
                // salesOrder.Name = 'Sales_'+opp.Name+'_'+(i+1);
                // salesOrder.Opportunity__c = oppId;
                // salesOrder.Amount__c = oppWrappers[i].totalAmount;
                // salesOrder.Initiated_By__c = UserInfo.getUserId();
                // salesOrder.Account__c = opp.AccountId;
                // salesOrder.Order_quantity__c = oppWrappers[i].totalQuantity;

                List<LineItemWrapper> products = oppWrappers[i].products;

                for(LineItemWrapper lineWrapper:products){
                    if(lineWrapper.quantityChoosed!=0){
                        OpportunityLineItem oppLineItem = new OpportunityLineItem();
                        oppLineItem.OpportunityId = oppId;
                        oppLineItem.PricebookEntryId = lineWrapper.PricebookEntryId;
                        oppLineItem.Product2Id = lineWrapper.Product2Id;
                        oppLineItem.UnitPrice = lineWrapper.UnitPrice;
                        oppLineItem.Quantity = lineWrapper.quantityChoosed;
                        oppLineItem.Packaging_Type__c = lineWrapper.PackagingType;
                        oppLineItem.FERT_Code__c = lineWrapper.FERT_Code;
                        oppLineItems.add(oppLineItem);
                    }
                }
               // salesList.add(salesOrder);
            }
            try{
                System.debug('OPPLINEITEMS----'+oppLineItems);
                insert oppLineItems;
               // insert salesList;
            }catch (Exception e) {
                HandleBusinessException.captureError('OppSplitParentController', 'createOpp', e);
            }

            Opportunity parOpp = new Opportunity(Id=parentOpp.Id,StageName='In-Progress');
            update parOpp;
            
            return [SELECT Id,Account.Name,Name,StageName,RecordType.Name,Type,Amount,TotalOpportunityQuantity,CloseDate,Parent_Opportunity__c,Parent_Opportunity__r.Name FROM Opportunity WHERE RecordType.Name='One Time' AND Id IN:oppIdList];
        } catch (Exception e) {
            HandleBusinessException.captureError('OppSplitParentController', 'createOpp', e);
            System.debug('LineNumber ---'+e.getLineNumber());
            System.debug('get-message ---'+e.getMessage());
            throw new AuraHandledException(e.getMessage()+e.getLineNumber());
        }
    }

    public class OppWrapper{
        @AuraEnabled public String oppName{get;set;}
        @AuraEnabled public String nextOrderDate{get;set;}
        @AuraEnabled public String closeDate{get;set;}
        @AuraEnabled public Integer totalQuantity{get;set;}
        @AuraEnabled public Decimal totalAmount{get;set;}
        @AuraEnabled public List<LineItemWrapper> products{get;set;}  
    }

    public class LineItemWrapper {
        @AuraEnabled public String OpportunityId{get;set;}
        @AuraEnabled public String Id{get;set;}
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String Product2Id{get;set;}
        @AuraEnabled public String PackagingType{get;set;}
        @AuraEnabled public String PricebookEntryId{get;set;}
        @AuraEnabled public Integer Quantity{get;set;}
        @AuraEnabled public Decimal UnitPrice{get;set;}
        @AuraEnabled public Decimal TotalPrice{get;set;}
        @AuraEnabled public Integer quantityChoosed{get;set;}
        @AuraEnabled public String quantityUnit{get;set;}
        @AuraEnabled public Decimal amountChoosed{get;set;}
        @AuraEnabled public Integer remainingQuantity{get;set;}
        @AuraEnabled public Decimal remainingAmount{get;set;}
        @AuraEnabled public String FERT_Code{get;set;}
        
    }
}