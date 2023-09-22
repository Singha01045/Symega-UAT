public class GetFERTCodeController {
    
    @AuraEnabled
    public static List<String> getPicklistValues(String ObjectApi_name, String Field_name){ 
        
        List<String> lstPickvals                        = new List<String>();
        Schema.SObjectType targetType                   = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name                             = targetType.newSObject();
        Schema.sObjectType sobject_type                 = Object_name.getSObjectType(); 
        Schema.DescribeSObjectResult sobject_describe   = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map      = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values     = field_map.get(Field_name).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : pick_list_values) {
            
            lstPickvals.add(String.ValueOf(a.getLabel()).trim());  
        }
        system.debug('lstPickvals'+lstPickvals);
        return lstPickvals;
    }
    
    static EmailTemplate FERTCodeTemplate;
    
    @AuraEnabled
    public static String sendFERTCodeReqEmailNotificaiton(string oppId) {
        
        //TODO: Anjali use this method to send notification, this method should be called from button on parent opportunity.
        String response = '';
        Opportunity opp = [Select Id,Name, OwnerId, Owner.Email, Send_Fert_Notification_Email__c,AccountId,Account.Customer_Code_SAP__c From Opportunity Where Id=:oppId];
        if(!String.isEmpty(opp.Account.Customer_Code_SAP__c)){
            sendFertCodeReqHelper(oppId, opp.OwnerId, opp.Owner.Email);
                Task taskRec = new Task();
                taskRec.Subject = 'Update once the FERT is ready by OPS team';
                taskRec.OwnerId =  opp.OwnerId;
                taskRec.ActivityDate = System.today(); 
                taskRec.Status = 'Open';
                taskRec.WhatId = oppId;
                insert taskRec;
            response = 'Success';
        }
        else{
            String customerValidationRes = Utility.checkSAPCustomerReqField(opp.AccountId);
            if(customerValidationRes == 'Success'){
                SAP_CreateCustomerCallout.createCustomer(opp.AccountId);
                opp.Send_Fert_Notification_Email__c = true;
                update opp;
                response = 'create';
            }
            else{
                response = customerValidationRes;
            }
            
        } 
         
        return response;
    }
    
    public static void sendFertCodeEmailBulk(List<Id> accId){
        List<Opportunity> oppList = [Select Id, Name, OwnerId, Owner.Email, Send_Fert_Notification_Email__c From Opportunity Where AccountId IN : accId AND Send_Fert_Notification_Email__c=true];
        for(Opportunity opp : oppList){
            sendFertCodeReqHelper(opp.Id, opp.OwnerId, opp.Owner.Email);
            opp.Send_Fert_Notification_Email__c = false;
        }
        update oppList;
    }
    
    public static void sendFertCodeReqHelper(String oppId, Id senderUserId, String senderUserEmail){
        try{
            
            List<Sale_Order_Notification__mdt> mdtList = Sale_Order_Notification__mdt.getAll().Values();
            Map<String, Sale_Order_Notification__mdt> getMDTByProdFmlyMap = new Map<String, Sale_Order_Notification__mdt>();
            
            for(Sale_Order_Notification__mdt mdt : mdtList){
                getMDTByProdFmlyMap.put(mdt.Label, mdt);
            }
            
            if(mdtList==null){return;}
            List<OpportunityLineItem> oppLineItemList = [SELECT Id, Product2.Family FROM OpportunityLineItem WHERE OpportunityId =: oppId];
            Map <string, List<OpportunityLineItem>> prodFamilyByOppProdsMap = new Map <string, List<OpportunityLineItem>>();
            if(oppLineItemList.size()>0){
                for (OpportunityLineItem prod : oppLineItemList) {
                    if(prod.Product2.Family != null){
                        if(prodFamilyByOppProdsMap.containsKey(prod.Product2.Family)) {
                            prodFamilyByOppProdsMap.get(prod.Product2.Family).add(prod); 
                        }
                        else{
                            prodFamilyByOppProdsMap.put(prod.Product2.Family, new List<OpportunityLineItem> {prod});
                        }    
                    }
                }   
                
                if(prodFamilyByOppProdsMap.size()>0){
                    for(String prodFamily : prodFamilyByOppProdsMap.keyset()){
                        
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        system.debug('UserInfo.getUserId() -- ' + UserInfo.getUserId());
                        message.setTargetObjectId(senderUserId);
                        //message.setTreatTargetObjectAsRecipient(false);
                        message.setSenderDisplayName('Symega Foods');
                        message.setReplyTo(senderUserEmail);
                        message.setUseSignature(false);
                        message.setBccSender(false);
                        message.setSaveAsActivity(false);
                        
                        if(FERTCodeTemplate==null){
                            FERTCodeTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE name = 'Request for Fert Code'];
                        }
                        
                        if(FERTCodeTemplate == null){return;}
                        message.setTemplateID(FERTCodeTemplate.Id);
                        message.setWhatId(oppId);
                        
                        String emails = getMDTByProdFmlyMap.get(prodFamily).User_Emails__c;
                        List <String> emailRecipients = emails.split(',');
                        if(emailRecipients == null){return;}
                        message.setToAddresses(emailRecipients);
                        
                        List <String> cC_EmailRecipients = new List <String>();
                        if(getMDTByProdFmlyMap.get(prodFamily).cC_Email_Ids__c != null){
                            String cC_Emails = getMDTByProdFmlyMap.get(prodFamily).cC_Email_Ids__c;
                            cC_EmailRecipients = cC_Emails.split(',');
                            if(!cC_EmailRecipients.isEmpty()){
                                message.setCcAddresses(cC_EmailRecipients);
                            }
                        }
                        
                        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                            Messaging.SendEmailResult[] results =  Messaging.sendEmail(messages);
                        
                        if (results[0].success){
                            System.debug('The email was sent successfully.');
                        }
                        else{
                            System.debug('The email failed to send: ' + results[0].errors[0].message);
                        }
                    }               
                }
            }
        }
        catch(Exception e){
            HandleBusinessException.captureError('GetFERTCodeController', 'sendFertCodeReqHelper', e);
            system.debug('Email Error : ' + e.getMessage() + ' At Line No : ' + e.getLineNumber()); 
        }
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> getProductList(string oppId){
        system.debug('oppId ====>' + oppId);
        List<OpportunityLineItem> productList = [SELECT Id, Name, Quantity, UnitPrice, TotalPrice, Primary__c, Secondary__c, Tertiary__c, Customized_Label__c, Symega_Logo__c, Material_Sector__c, Plant__c,
                                                 If_Organised_set_Micro_as_Long_Term__c FROM OpportunityLineItem WHERE OpportunityId =: oppId];
        return productList;
    }
    
    @AuraEnabled
    public static string OppLineItemUpdate (List<OpportunityLineItem> OLIRecords){        
        try{
            system.debug('OLIRecords Records ====>' + OLIRecords);
            update OLIRecords;
            return 'Success';
        } 
        catch(Exception e){
            HandleBusinessException.captureError('GetFERTCodeController', 'OppLineItemUpdate', e);
            system.debug('Email Error : ' + e.getMessage() + ' At Line No : ' + e.getLineNumber()); 
            return e.getMessage();
        }
    }
}