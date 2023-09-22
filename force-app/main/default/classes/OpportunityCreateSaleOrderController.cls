public without sharing class OpportunityCreateSaleOrderController {
    
    @AuraEnabled
    public static Boolean getLineItemDetails(String recId){
        List<OpportunityLineItem> lineItems = [SELECT Id FROM OpportunityLineItem WHERE Sales_Order__c =: recId];
        List<OpportunityLineItem> withFERTcodeItems = [SELECT Id, FERT_Code__c FROM OpportunityLineItem WHERE Sales_Order__c =: recId AND FERT_Code__c != NULL];
        system.debug('withFERTcodeItems.size() -- ' + withFERTcodeItems.size());
        system.debug('lineItems.size() -- ' + lineItems.size());

        if(lineItems.size() == withFERTcodeItems.size()){
            return true;
        }
        else{
            return false;
        }
    }

    @AuraEnabled
    public static string sendSONotification(String id){
        try {
            Sales_Order__c so = [Select Id,Account__c,Account__r.Customer_Code_SAP__c From Sales_Order__c Where Id=:id];
            if(String.isEmpty(so.Account__r.Customer_Code_SAP__c)){
                return 'Customer Creation Initiated';    
            }
            Utility.sendSONotification(id);
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateSO(Sales_Order__c so){
        try {
            so.Send_Sales_Ops_Email__c = true;
            update so;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateOpp(String soId){
        try {
            Sales_Order__c so = [Select Id,Account__c,Account__r.Customer_Code_SAP__c From Sales_Order__c Where Id=:soId];

            if(String.isEmpty(so.Account__r.Customer_Code_SAP__c)){
                String accValidationsResp = Utility.checkSAPCustomerReqField(so.Account__c);

                if(accValidationsResp.equalsIgnoreCase('success')) {
                    String response  = SAP_CreateCustomerCallout.createCustomer(so.Account__c);
                    System.debug('ResponseXXX----'+response);
                    if(response!='Success')
                        return response;
                    return updateSO(so);
                }else {
                    return 'Customer key fields missing: '+accValidationsResp;
                }
            }

            String oppId = [Select Opportunity__c from Sales_Order__c Where Id =:soId].Opportunity__c;
            if(!String.isEmpty(oppId)){
                Opportunity opp = new Opportunity(Id=oppId,StageName='Closed Won');
                update opp;
            }

            Sales_Order__c sOrder = new Sales_Order__c(Id=soId,Submission_Date__c=Date.Today());
            update sOrder;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void updateOppInBulk(List<Id> accIds){
        try {
            List<Utility.SOWRAPPER> SOWRAPPERS = new List<Utility.SOWRAPPER>();
            Map<Id,Sales_Order__c> soMap = new Map<Id,Sales_Order__c>([Select Id,Name,Opportunity__c, OwnerId, Owner.Email, Submission_Date__c From Sales_Order__c Where Account__c IN : accIds AND Send_Sales_Ops_Email__c = true]);
            
            if(!soMap.isEmpty()){
                Map<Id,Opportunity> oppToUpdate = new Map<Id,Opportunity>();

                Map<Id,OpportunityLineItem> oppLineItems = new Map<Id,OpportunityLineItem>([SELECT Id, Product2.Family,Sales_Order__c FROM OpportunityLineItem WHERE Sales_Order__c IN : soMap.keySet()]);

                Map<Id,List<OpportunityLineItem>> saleOrderLineItemsMap = new Map<Id,List<OpportunityLineItem>>();

                for(OpportunityLineItem oppItem : oppLineItems.values()){
                    if(saleOrderLineItemsMap.containsKey(oppItem.Sales_Order__c)){
                        saleOrderLineItemsMap.get(oppItem.Sales_Order__c).add(oppItem);
                    }else{
                        saleOrderLineItemsMap.put(oppItem.Sales_Order__c,new List<OpportunityLineItem>{oppItem});
                    }
                }

                for(Id key : saleOrderLineItemsMap.keySet()){
                    Utility.SOWRAPPER sWrapper = new Utility.SOWRAPPER();
                    sWrapper.soId = key;
                    sWrapper.oppProdsList = saleOrderLineItemsMap.get(key);
                    sWrapper.replyToEmail = soMap.containsKey(key) ? soMap.get(key).Owner.Email : UserInfo.getUserEmail();
                    sWrapper.senderID = soMap.containsKey(key) ? soMap.get(key).OwnerId : UserInfo.getUserId();
                    SOWRAPPERS.add(sWrapper);                
                }
                
                System.debug('calling utility');
                Utility.sendBulkSONotification(SOWRAPPERS);

                for(Sales_Order__c so : soMap.values()){
                    so.Send_Sales_Ops_Email__c = false;
                    so.Submission_Date__c = Date.Today();
                    oppToUpdate.put(so.Opportunity__c,new Opportunity(Id=so.Opportunity__c,StageName='Closed Won'));
                }

                update soMap.values();
                update oppToUpdate.values();
            }
        } catch (Exception e) {
            
        }
    }




}