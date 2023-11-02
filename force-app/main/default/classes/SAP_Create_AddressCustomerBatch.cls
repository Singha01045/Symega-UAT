public with sharing class SAP_Create_AddressCustomerBatch Implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    Set<Id> setOfCustomer;
    public SAP_Create_AddressCustomerBatch(Set<Id> setOfCustomer){
        this.setOfCustomer = setOfCustomer;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator([Select Id from Contact limit 1]); 
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){ 

        set<Id> successfulAccIdSet = new set<Id>();
        for(String id : setOfCustomer){
            String response = SAP_CreateAddressCustomerCallout.createCustomer(id, true);
            if(response.equalsIgnoreCase('Success')){
                successfulAccIdSet.add(id);
            }
        }
        if(successfulAccIdSet.size()>0){
            List<Dispatch_Address__c> addrRecListToUpdate = new List<Dispatch_Address__c>();
            List<Dispatch_Address__c> addrRecList = [SELECT Id, Submitted_to_SAP__c FROM Dispatch_Address__c WHERE Id IN: successfulAccIdSet];
            for(Dispatch_Address__c addrRec : addrRecList){
                if(addrRec.Submitted_to_SAP__c != true){
                    addrRec.Submitted_to_SAP__c = true;
                    addrRecListToUpdate.add(addrRec);
                }
            }
            update addrRecListToUpdate;
        }
         
    } 
    
    public void finish(Database.BatchableContext BC){ 
        System.debug('finishing SMS Batch');
    }
}