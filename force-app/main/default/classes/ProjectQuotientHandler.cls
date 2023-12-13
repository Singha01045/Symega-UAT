public without sharing class  ProjectQuotientHandler {
    
    public static void afterInsert(List<Project_Quotient__c> projQuoRec){
        
        Map<Id,Integer> projMap = new   Map<Id,Integer>(); 
        
        Set<Id> projectIds = new Set<Id>();
        
        for(Project_Quotient__c projRec : projQuoRec){
            
            if(projRec.Sample_Project_Application__c != null){
                projectIds.add(projRec.Sample_Project_Application__c);
            }
            
        } 
        
        List<Project_Quotient__c> totalProjQuoList = [SELECT ID, Sample_Project_Application__c FROM Project_Quotient__c Where Sample_Project_Application__c In:projectIds];
        
        Integer  totalcount = totalProjQuoList.size();
        system.debug('totalProjQuoList--->'+totalProjQuoList.size());
        System.debug('totalcount--->'+totalcount);
        
        for(Project_Quotient__c projRec: totalProjQuoList){
            
            projMap.put(projRec.Sample_Project_Application__c,totalcount);
            
        }
        
        if(projMap != null){
            sendEmail(projMap);       
        }
        
    }
    
    public Static void sendEmail( Map<Id,Integer> projListmap){
        
        try{
            
            //    List<Project__c>  ProjList = [SELECT ID,OwnerId,Owner.Email,Manager_Email__c, Name,Quotient_Mail_Sent__c,Project_Name__c FROM Project__c];
            
            
            Map<Id,Project__c>  ProjList = new    Map<Id,Project__c>([SELECT ID,OwnerId,Owner.Email,Manager_Email__c, Name,Quotient_Mail_Sent__c,Project_Name__c FROM Project__c where Quotient_Mail_Sent__c = false]);
            
            Map<ID, User> userMap = new Map<ID, User>([SELECT ID,LastName,FirstName,Email,ManagerId FROM User]);
            
            List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>(); 
            Messaging.SingleEmailMessage mymail;      
            List<Project__c> updateProjList = new List<Project__c>();
            for(Project__c projRec : ProjList.values()){
                mymail = new Messaging.SingleEmailMessage();
                String mailSubject ;
                mailSubject = projRec.Project_Name__c + '-'+ projRec.Name +''+projListmap.get(projRec.Id)+ '-Project Quotients are added';
                if(projListmap.containsKey(projRec.Id) && projRec.Quotient_Mail_Sent__c == false){
                    
                    
                    List<String> emailList = new List<String>();
                    emailList.add(projRec.Owner.Email);
                    if(projRec.Manager_Email__c != null)
                        emailList.add(projRec.Manager_Email__c);
                    mymail.setToAddresses(emailList);            //new string[]  {projRec.Owner.Email},{projRec.Manager_Email__c}); // {userMap.get(projRec.OwnerId).Email} );  
                    mymail.setSenderDisplayName('Symega');
                    mymail.setSubject(mailSubject);
                    mymail.setSaveAsActivity(false);   
                    semList.add(mymail);  
                }
                
                
                mymail.setHtmlBody('Hi '+userMap.get(projRec.OwnerId).FirstName +',' +'<br/>'+ '<br/>'+'The project'+ projRec.Name +'is completed by R&D and'+ projListmap.get(projRec.Id) +' number of quotient is added'+'<br/>'+ '<br/>' +'Thanks & Regards'+'<br/>'+'SYMEGA'); 
                projRec.Quotient_Mail_Sent__c = true;
                updateProjList.add(projRec);
            }     
            if(semList != null){
                
                Messaging.sendEmail(semList);
                System.debug('Email Sent');
                 update   updateProjList;
                System.debug('Update List-->'+updateProjList);
                
            }
            
            
        }catch(Exception e){
            System.debug('Exception Line Number--->'+e.getLineNumber());
            System.debug('Exception Message-->'+e.getMessage());
        }
        
    }
    
    
    
    
}