public class TestClass {
    
    @AuraEnabled
    public static string updateOpp(String soId){
        try {
            Sales_Order__c so = [Select Id,Account__c,Opportunity__r.Account.Customer_Code_SAP__c,Opportunity__r.AccountId, Opportunity__r.Customer_Billing_Address__r.SAP_Update_Customer__c,
                                 Opportunity__r.Account_Billing_Address__c,Opportunity__r.Customer_Billing_Address__c,
                                 Opportunity__r.Customer_Billing_Address__r.Customer_Code_SAP__c, Opportunity__r.Account.SAP_Update_Customer__c, Opportunity__r.Account.Submitted_to_SAP__c,
                                 Opportunity__r.Customer_Billing_Address__r.Submitted_to_SAP__c,
                                 
                                 Opportunity__r.Account.Shipping_SAP_Update_Customer__c,
                                 
                                 Opportunity__r.Selected_Billing_Customer_Code__c, Opportunity__r.Selected_Shipping_Customer_Code__c,
                                 
                                 Opportunity__r.Customer_Shipping_Address__r.SAP_Update_Customer__c, 
                                 
                                 Opportunity__r.Account.Shipping_Customer_Code_SAP__c, Opportunity__r.Account_Shipping_Address__c, Opportunity__r.Customer_Shipping_Address__c, 
                                 Opportunity__r.Customer_Shipping_Address__r.Customer_Code_SAP__c, Opportunity__r.Account.Shipping_Submitted_to_SAP__c, Opportunity__r.Customer_Shipping_Address__r.Submitted_to_SAP__c
                                 
                                 From Sales_Order__c Where Id=:soId
                                ];
            
            String customerCode = '';
            
            Boolean isAccount = false;
            Id custId;
            Boolean sapUpdateAcc = false;
            Boolean sapUpdateAddress = false;
            
            if(so.Opportunity__r.Account_Billing_Address__c){
                customerCode = so.Opportunity__r.Account.Customer_Code_SAP__c;
                isAccount = true;
                custId = so.Opportunity__r.AccountId;
                sapUpdateAcc = so.Opportunity__r.Account.SAP_Update_Customer__c;
            }
            else if(so.Opportunity__r.Customer_Billing_Address__c != null){
                customerCode = so.Opportunity__r.Customer_Billing_Address__r.Customer_Code_SAP__c;
                isAccount = false;
                custId = so.Opportunity__r.Customer_Billing_Address__c;
                sapUpdateAddress = so.Opportunity__r.Customer_Billing_Address__r.SAP_Update_Customer__c;
            }
            
            
            Boolean isBillingAccount;
            if(so.Opportunity__r.Account_Billing_Address__c){
                isBillingAccount = true;
            }
            else if(so.Opportunity__r.Customer_Billing_Address__c != null){
                isBillingAccount = false;
            }
            
            Boolean isShippingAccount;
            if(so.Opportunity__r.Account_Shipping_Address__c){
                isShippingAccount = true;
            }
            else if(so.Opportunity__r.Customer_Shipping_Address__c != null){
                isShippingAccount = false;
            }
            
            string respNEW = '';
            
            if(!so.Opportunity__r.Selected_Billing_Customer_Code__c || !so.Opportunity__r.Selected_Shipping_Customer_Code__c){
                System.debug('1st Cust Code NULL----');
                
                if(!so.Opportunity__r.Selected_Billing_Customer_Code__c){
                    if(so.Opportunity__r.Account_Billing_Address__c && !so.Opportunity__r.Account.Submitted_to_SAP__c){
                        callFutureForAccountCreation(so.Opportunity__r.AccountId);
                        if(!so.Opportunity__r.Selected_Shipping_Customer_Code__c){
                            system.debug('Hiii... Inside Empty Shipping Customer Code Part... Test 1232uoi2');
                            if(isShippingAccount){
                                system.debug('Hiii... Inside Shipping Acount Part... 2eu83ui');
                                callFutureForShippingAccountCreation(so.Opportunity__r.AccountId); 
                                respNEW = 'shipping account create';
                            }
                            else{
                                system.debug('Hiii... Inside Shipping Address Part... 3872ujr');
                                callFutureForAddressCreation(so.Opportunity__r.AccountId);
                                respNEW = 'shipping address create';
                            }
                        }
                        else{
                            system.debug('Hiii... Inside Empty Shipping Customer Code Part... Test 1232uoi2');
                            if(isShippingAccount && !so.Opportunity__r.Account.Shipping_SAP_Update_Customer__c){
                                system.debug('Hiii... Inside Shipping Acount Part... 2eu83ui');
                                callFutureForShippingAccountUpdation(so.Opportunity__r.AccountId);  
                                respNEW = 'shipping account update';
                            }
                            else if(!isShippingAccount && !so.Opportunity__r.Customer_Shipping_Address__r.SAP_Update_Customer__c){
                                system.debug('Hiii... Inside Shipping Address Part... 3872ujr');
                                callFutureForAddressUpdation(so.Opportunity__r.Customer_Shipping_Address__c);
                                respNEW = 'shipping address update';
                            }
                        }
                    }                    
                    else if(!so.Opportunity__r.Account_Billing_Address__c && !so.Opportunity__r.Customer_Billing_Address__r.Submitted_to_SAP__c){
                        callFutureForAddressCreation(so.Opportunity__r.Customer_Billing_Address__c);
                        if(!so.Opportunity__r.Selected_Shipping_Customer_Code__c){
                            system.debug('Hiii... Inside Empty Shipping Customer Code Part... Test 1232uoi2');
                            if(isShippingAccount){
                                system.debug('Hiii... Inside Shipping Acount Part... 2eu83ui');
                                callFutureForShippingAccountCreation(so.Opportunity__r.AccountId);     
                                respNEW = 'shipping account create';
                            }
                        }
                        else{
                            system.debug('Hiii... Inside Empty Shipping Customer Code Part... Test 1232uoi2');
                            if(isShippingAccount && !so.Opportunity__r.Account.Shipping_SAP_Update_Customer__c){
                                system.debug('Hiii... Inside Shipping Acount Part... 2eu83ui');
                                callFutureForShippingAccountUpdation(so.Opportunity__r.AccountId); 
                                respNEW = 'shipping account update';
                            }
                            else if(!isShippingAccount && !so.Opportunity__r.Customer_Shipping_Address__r.SAP_Update_Customer__c){
                                system.debug('Hiii... Inside Shipping Address Part... 3872ujr');
                                callFutureForAddressUpdation(so.Opportunity__r.Customer_Shipping_Address__c);
                                respNEW = 'shipping address update';
                            }
                        }
                    }
                    
                }
                else if(!so.Opportunity__r.Selected_Shipping_Customer_Code__c){
                    
                    if(isShippingAccount){ 
                        system.debug('Hiii... Inside Shipping Account Part... Test 123hgj278');
                        callFutureForShippingAccountCreation(so.Opportunity__r.AccountId);
                        respNEW = 'shipping account create';
                    }
                    else{
                        system.debug('Hiii... Inside Shipping Address Part... 398ijkdsdnfjs');
                        callFutureForAddressCreation(so.Opportunity__r.AccountId);
                        respNEW = 'shipping address create';
                    }
                }
            }
            
            String oppId = [Select Opportunity__c from Sales_Order__c Where Id =:soId].Opportunity__c;
            if(!String.isEmpty(oppId)){
                Opportunity op2p = new Opportunity(Id=oppId, StageName='Closed Won');
                update op2p;
            }
            
            Sales_Order__c sOrder = new Sales_Order__c(Id=soId, Submission_Date__c=Date.Today());
            update sOrder;
            return 'Success';
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @future(callout=true)
    public static void callFutureForAddressUpdation(Id caId){
        Dispatch_Address__c addrRec = [SELECT Id, Submitted_to_SAP__c, SAP_Update_Customer__c FROM Dispatch_Address__c WHERE Id =: caId];
        String resp = SAP_CreateAddressCustomerCallout.createCustomer(caId, true);
        if(resp.equalsIgnoreCase('Success')){
            if(addrRec.Submitted_to_SAP__c != true){
                addrRec.Submitted_to_SAP__c = true;
                update addrRec;
            }
        }
        if(addrRec.SAP_Update_Customer__c != true){
            addrRec.SAP_Update_Customer__c = true;
            update addrRec;
        }
    }
    
    @future(callout=true)
    public static void callFutureForAddressCreation(Id caId){
        Dispatch_Address__c addrRec = [SELECT Id, Submitted_to_SAP__c, SAP_Update_Customer__c FROM Dispatch_Address__c WHERE Id =: caId];
        String resp = SAP_CreateAddressCustomerCallout.createCustomer(caId, true);
        if(resp.equalsIgnoreCase('Success')){
            if(addrRec.Submitted_to_SAP__c != true){
                addrRec.Submitted_to_SAP__c = true;
                update addrRec;
            }
        }
        if(addrRec.SAP_Update_Customer__c != true){
            addrRec.SAP_Update_Customer__c = true;
            update addrRec;
        }
    }
    
    @future(callout=true)
    public static void callFutureForAccountUpdation(Id accId){
        Account accRec = [SELECT Id, SAP_Update_Customer__c FROM Account WHERE Id =: accId];
        String resp = SAP_CUSTOMER_UPDATE_CALLOUT.syncCustomersWithSAP(accId);
        if(resp.equalsIgnoreCase('Success')){
            if(accRec.SAP_Update_Customer__c != true){
                accRec.SAP_Update_Customer__c = true;
                update accRec;
            } 
        }        
    }
    
    @future(callout=true)
    public static void callFutureForAccountCreation(Id accId){
        Account accRec = [SELECT Id, Submitted_to_SAP__c, SAP_Update_Customer__c FROM Account WHERE Id =: accId];
        String resp = SAP_CreateCustomerCallout.createCustomer(accId, true);
        if(resp.equalsIgnoreCase('Success')){
            if(accRec.Submitted_to_SAP__c != true){
                accRec.Submitted_to_SAP__c = true;
                update accRec;
            }
        }
        
        if(accRec.SAP_Update_Customer__c != true){
            accRec.SAP_Update_Customer__c = true;
            update accRec;
        } 
    }
    
    @future(callout=true)
    public static void callFutureForShippingAccountUpdation(Id accId){
        Account accRec = [SELECT Id, Shipping_SAP_Update_Customer__c FROM Account WHERE Id =: accId];
        String resp = SAP_CUSTOMER_UPDATE_CALLOUT_shipping.syncCustomersWithSAP(accId);
        if(resp.equalsIgnoreCase('Success')){
            if(accRec.Shipping_SAP_Update_Customer__c != true){
                accRec.Shipping_SAP_Update_Customer__c = true;
                update accRec;
            } 
        } 
    }
    
    @future(callout=true)
    public static void callFutureForShippingAccountCreation(Id accId){
        Account accRec = [SELECT Id, Shipping_Submitted_to_SAP__c, Shipping_SAP_Update_Customer__c FROM Account WHERE Id =: accId];
        String resp = SAP_CreateShippingCustomerCallout_NEW.createCustomer(accId, true);
        if(resp.equalsIgnoreCase('Success')){
            if(accRec.Shipping_Submitted_to_SAP__c != true){
                accRec.Shipping_Submitted_to_SAP__c = true;
                update accRec;
            }
        }
        
        if(accRec.Shipping_SAP_Update_Customer__c != true){
            accRec.Shipping_SAP_Update_Customer__c = true;
            update accRec;
        }
    }
    
    
    
}