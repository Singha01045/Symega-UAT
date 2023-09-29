Global class BatchClassForOpportunityOwner implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select Id,CloseDate,StageName FROM Opportunity Where CloseDate != null and CloseDate = Today and (StageName != 'Closed Won' or StageName != 'Closed Lost') ]); 
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> OppList){   
        System.debug('OppList---->'+OppList);
        Map<Id,List<Opportunity>> oppMapList = new Map<ID,List<Opportunity>>();
        List<opportunity> updateOppList = new List<Opportunity>(); 
        for(Opportunity oppRec: OppList){
            oppRec.Remainder_Sent_Date__c = System.today();
            if(!oppMapList.containsKey(oppRec.OwnerId)){
                oppMapList.put(oppRec.OwnerId,new List<Opportunity>{oppRec});
                }
                else{
                    oppMapList.get(oppRec.OwnerId).add(oppRec);
                }
                updateOppList.add(oppRec);
            }
            Update updateOppList;
            sendEmailToOwnersAccount(oppMapList);
    }
    global void finish(Database.BatchableContext bc){
        System.debug('Sending Email Message to opportunity Owner');   
    } 
    
    public static void  sendEmailToOwnersAccount(Map<Id,List<Opportunity>> oppMapList){
            
             Map<ID, User> userMap = new Map<ID, User>([SELECT ID,LastName,FirstName,Email FROM User]);
             List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>(); 
          
             for(ID keyS: oppMapList.keySet()){
                    String result;
                 List<String> oppNames = new  List<String>(); // accMapList.get(keyS);
                 
                  for(Opportunity oppRec:  oppMapList.get(keyS)){
                       oppNames.add(oppRec.Name);
                       result +='\n'+ oppRec.Name +'\n';  
                  }

                Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                mymail.setToAddresses(new string[]  {userMap.get(keyS).Email} );  
                mymail.setSenderDisplayName('Excelr');
                mymail.setSubject('Opportunity  Remainder Sent Date');
                mymail.setSaveAsActivity(false);
                mymail.setPlainTextBody('Hello '+userMap.get(keyS).LastName +',' +'\n'+'\n' + 'The Following  Opportunities Remainder Sent Date is Today.'+oppNames+'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
               //   mymail.setHtmlBody('Hello'+userMap.get(keyS).LastName +''+' <a href='+URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.id;">'+acc.Name+'</a> ');
                 semList.add(mymail);
            }
               
           //  }
                     Messaging.sendEmail(semList);

  } 


}