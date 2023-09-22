public class NoSplitOpportunityHelper {
    @AuraEnabled
    public static string createOneTimeOppRec(String oppId){
        try{
            if(!String.isBlank(oppId)) {
                List<Opportunity> parentOpportunity = new List<Opportunity>();
                list<Opportunity> childOpprtunitites = new list<Opportunity>();
                list<OpportunityLineItem> productToBeInserted = new list<OpportunityLineItem>();
                
                parentOpportunity = [Select Id, Name, AccountId, CloseDate, Customer_Followup_Date__c, Customer_response__c, Description, SyncedQuoteId,CurrencyIsoCode,
                                     TotalOpportunityQuantity, Probability,LeadSource, Next_Order_Date__c, NextStep, Sample__c,Reason_For_Loss_del__c,Primary_Contact__c,
                                     StageName, Type,Distributer_Customer__c,End_Use_Application__c,	End_Use_Category__c From Opportunity Where Id = :oppId];
                
                productToBeInserted = [SELECT Id, OpportunityId, SortOrder, ServiceDate, Discount, Quantity, PricebookEntryId, Product2Id, Sales_Order__c,
                                       Primary__c, Secondary__c, Tertiary__c, Customized_Label__c, Symega_Logo__c, Material_Sector__c, Pvt_Label_Selling_Price__c,
                                       UnitPrice, Description,Packaging_Type__c, Packaging_Unit__c, Packaging_Quantity__c, FERT_Code__c FROM OpportunityLineItem WHERE OpportunityId = : oppId];
                
                childOpprtunitites = [SELECT Id, Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :oppId ];
                
                if(!childOpprtunitites.isEmpty()){
                    throw new AuraHandledException('');                    
                }
                
                
                if(!productToBeInserted.isEmpty()){
                    if(!parentOpportunity.isEmpty()) {
                        Opportunity oneTimeOppRec = new Opportunity();
                        oneTimeOppRec.Parent_Opportunity__c = parentOpportunity[0].Id;
                        oneTimeOppRec.RecordTypeId = Constants.OpportunityRecordTypeOneTime;
                        oneTimeOppRec.Name = parentOpportunity[0].Name+' - 1' ;
                        oneTimeOppRec.AccountId = parentOpportunity[0].AccountId;
                        oneTimeOppRec.CloseDate = parentOpportunity[0].CloseDate;
                        oneTimeOppRec.TotalOpportunityQuantity = parentOpportunity[0].TotalOpportunityQuantity ;
                        oneTimeOppRec.Customer_Followup_Date__c = parentOpportunity[0].Customer_Followup_Date__c ;
                        oneTimeOppRec.NextStep = parentOpportunity[0].NextStep ;
                        oneTimeOppRec.Customer_response__c = parentOpportunity[0].Customer_response__c ;
                        oneTimeOppRec.LeadSource = parentOpportunity[0].LeadSource ;
                        oneTimeOppRec.Next_Order_Date__c = parentOpportunity[0].Next_Order_Date__c ;
                        oneTimeOppRec.StageName  = 'New';
                        oneTimeOppRec.Probability    = parentOpportunity[0].Probability ;
                        oneTimeOppRec.Description = parentOpportunity[0].Description ;
                        oneTimeOppRec.Sample__c  = parentOpportunity[0].Sample__c ;
                        oneTimeOppRec.SyncedQuoteId  = parentOpportunity[0].SyncedQuoteId ;
                        oneTimeOppRec.Reason_For_Loss_del__c  = parentOpportunity[0].Reason_For_Loss_del__c ;
                        oneTimeOppRec.Customer_response__c  = parentOpportunity[0].Customer_response__c ;
                        oneTimeOppRec.LeadSource  = parentOpportunity[0].LeadSource ;
                        oneTimeOppRec.Type = parentOpportunity[0].Type;
                        oneTimeOppRec.Distributer_Customer__c = parentOpportunity[0].Distributer_Customer__c ;
                        oneTimeOppRec.Primary_Contact__c = parentOpportunity[0].Primary_Contact__c ;
                        oneTimeOppRec.CurrencyIsoCode = parentOpportunity[0].CurrencyIsoCode ;
                        oneTimeOppRec.End_Use_Category__c = parentOpportunity[0].End_Use_Category__c;
                        oneTimeOppRec.End_Use_Application__c = parentOpportunity[0].End_Use_Application__c;
                        insert oneTimeOppRec;
                        
                        
                        list<OpportunityLineItem> productList = new list<OpportunityLineItem>();
                        for(OpportunityLineItem productRec : productToBeInserted){
                            
                            OpportunityLineItem newProductRec = new OpportunityLineItem();
                            newProductRec.OpportunityId = oneTimeOppRec.Id;
                            newProductRec.UnitPrice = productRec.UnitPrice;
                            newProductRec.ServiceDate = productRec.ServiceDate;
                            newProductRec.FERT_Code__c = productRec.FERT_Code__c;
                            newProductRec.Quantity = productRec.Quantity;
                            newProductRec.PricebookEntryId = productRec.PricebookEntryId;
                            newProductRec.Product2Id = productRec.Product2Id;
                            newProductRec.SortOrder = productRec.SortOrder;
                            newProductRec.Description  = productRec.Description;
                            newProductRec.Packaging_Type__c = productRec.Packaging_Type__c;
                            newProductRec.Sales_Order__c = productRec.Sales_Order__c;
                            newProductRec.Pvt_Label_Selling_Price__c = productRec.Pvt_Label_Selling_Price__c;
                            newProductRec.Packaging_Quantity__c = productRec.Packaging_Quantity__c;
                            newProductRec.Packaging_Unit__c = productRec.Packaging_Unit__c;
                            newProductRec.Customized_Label__c = productRec.Customized_Label__c;
                            newProductRec.Symega_Logo__c = productRec.Symega_Logo__c;
                            newProductRec.Material_Sector__c = productRec.Material_Sector__c;
                            newProductRec.Primary__c = productRec.Primary__c;
                            newProductRec.Secondary__c = productRec.Secondary__c;
                            newProductRec.Tertiary__c = productRec.Tertiary__c;

                            productList.add(newProductRec);
                        }
                        system.debug('---'+productList);
                        if(!productList.isEmpty()){
                            insert productList;
                            parentOpportunity[0].StageName = 'In-Progress';
                            update parentOpportunity[0];
                        }                            
                    }
                }       
            } 
            return 'SUCCESS';
        }catch(exception ex){
            AuraHandledException excep = new AuraHandledException('');
            system.debug('error: ' + ex.getMessage()); //I can see the error in the system.debug log.
            excep.setMessage(ex.getMessage());
            throw excep;
            /*system.debug('Error==>'+ex.getMessage());
            system.debug('Error@@==>'+ex.getLineNumber());*/
        }
    }
}