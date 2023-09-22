public with sharing class OpportunityHanlder {
    public OpportunityHanlder() {}

    @AuraEnabled
    public static List<Opportunity> getRecord(String oppId){
        try {
            System.debug('OppId'+oppId);
            return [Select Id, Name, AccountId,TotalOpportunityQuantity, Amount, CurrencyIsoCode from opportunity where Id=:oppId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createOpp(OppWrapper wrapper){
        List<OpportunityLineItem> parentOppProductList = [Select Id, OpportunityId,UnitPrice,Quantity From OpportunityLineItem Where OpportunityId=:wrapper.record.Id];
        
        List<Opportunity> oppList = new List<Opportunity>();
        List<OpportunityLineItem> newOppLineItem = new List<OpportunityLineItem>();

        List<OpportunityWrapper> opWrapperList = wrapper.oppList;
        for(OpportunityWrapper opportunityWrap: opWrapperList){
            Opportunity opp = new Opportunity();
            opp.Name = opportunityWrap.Name;
            opp.RecordTypeId = opportunityWrap.RecordTypeId;
            opp.Amount = opportunityWrap.Amount;
            opp.AccountId = opportunityWrap.AccountId;
            opp.Parent_Opportunity__c = opportunityWrap.ParenOpp;
            opp.StageName = opportunityWrap.StageName;
            opp.CloseDate = opportunityWrap.CloseDate;
            opp.Next_Order_Date__c = opportunityWrap.nextOrderDate;
            opp.TotalOpportunityQuantity = opportunityWrap.TotalOpportunityQuantity;
            oppList.add(opp);
        }
        insert oppList;

        for(OpportunityLineItem oppLineItem: parentOppProductList){
            OpportunityLineItem oppItem = oppLineItem;
            // opp.
        }





        
        //List<Opportunity> oppList = wrapper.oppList;
        // insert oppList;

        
        
        // for(Opportunity opp: oppList){

        // }
        // Parent_Opportunity__c
        


        return JSON.serialize(wrapper);
    }

    public class OppWrapper{
        @AuraEnabled public Opportunity record{get;set;}
        @AuraEnabled public List<OpportunityWrapper> oppList{get;set;}  
    }

    public class OpportunityWrapper {
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String RecordTypeId{get;set;}
        @AuraEnabled public Decimal Amount{get;set;}
        @AuraEnabled public String AccountId{get;set;}
        @AuraEnabled public String ParenOpp{get;set;}
        @AuraEnabled public String StageName{get;set;}
        @AuraEnabled public Date CloseDate{get;set;}
        @AuraEnabled public Date nextOrderDate{get;set;}
        @AuraEnabled public Decimal TotalOpportunityQuantity{get;set;}
        @AuraEnabled public Decimal percent{get;set;}
    }
    
}