public without sharing class ProjectQuotientController {

       static ProjectQuotientController handlerInstance;
    public static ProjectQuotientController getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new ProjectQuotientController();
        return handlerInstance;
    }

     public  void afterInsert(List<Project_Quotient__c> projQuoRec){
        
        Map<Id,Integer> projMap = new   Map<Id,Integer>(); 
        
        Set<Id> projectIds = new Set<Id>();
        
        for(Project_Quotient__c projRec : projQuoRec){
            
            if(projRec.Sample_Project_Application__c != null){
                projectIds.add(projRec.Sample_Project_Application__c);
            }
            
        } 
        
        List<Project_Quotient__c> totalProjQuoList = [SELECT ID,Product_Name__c,SSC_Code__c, Sample_Project_Application__c,Name FROM Project_Quotient__c Where Sample_Project_Application__c In:projectIds];
       
        Map<Id,List<Project_Quotient__c>> projQMapList = new  Map<Id,List<Project_Quotient__c>>(); // projMapList();
        Integer  totalcount = totalProjQuoList.size();
        system.debug('totalProjQuoList--->'+totalProjQuoList.size());
        System.debug('totalcount--->'+totalcount);
        
        for(Project_Quotient__c projRec: totalProjQuoList){
            
            projMap.put(projRec.Sample_Project_Application__c,totalcount);
            
            if(!projQMapList.containsKey(projRec.Sample_Project_Application__c)){
                 projQMapList.put(projRec.Sample_Project_Application__c,new List<Project_Quotient__c>{projRec});
            }else{
                projQMapList.get(projRec.Sample_Project_Application__c).add(projRec);
            }
            
        }

        
        if(projMap != null){
            sendEmail(projMap,projQMapList);       
        }
        
    }
    
    public  void sendEmail( Map<Id,Integer> projListmap,  Map<Id,List<Project_Quotient__c>> projQMapList){
        
        try{
            
            //    List<Project__c>  ProjList = [SELECT ID,OwnerId,Owner.Email,Manager_Email__c, Name,Quotient_Mail_Sent__c,Project_Name__c FROM Project__c];


          

           String  adminMail = System.Label.Admin_Mail_Id;
           system.debug('adminMail--->'+adminMail);
            
            Map<Id,Project__c>  ProjList = new    Map<Id,Project__c>([SELECT ID,OwnerId,Owner.Email,Manager_Email__c, Name,Quotient_Mail_Sent__c,Project_Name__c FROM Project__c where Quotient_Mail_Sent__c = false and Id In :projListmap.keyset()]);
            
            Map<ID, User> userMap = new Map<ID, User>([SELECT ID,LastName,FirstName,Email,ManagerId FROM User]);
            
            List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>(); 
            Messaging.SingleEmailMessage mymail;      
            List<Project__c> updateProjList = new List<Project__c>();
            for(Project__c projRec : ProjList.values()){
                mymail = new Messaging.SingleEmailMessage();
                String mailSubject ;
                mailSubject = projRec.Project_Name__c + '-'+ projRec.Name +' ' + projListmap.get(projRec.Id)+ ' - Project Quotients are added';
                if(projListmap.containsKey(projRec.Id) && projRec.Quotient_Mail_Sent__c == false){
                    
                    
                    List<String> emailList = new List<String>();
                    emailList.add(projRec.Owner.Email);
                    if(projRec.Manager_Email__c != null)
                        emailList.add(projRec.Manager_Email__c);
                        if(adminMail != null)
                        emailList.add(adminMail);
                    mymail.setToAddresses(emailList);            //new string[]  {projRec.Owner.Email},{projRec.Manager_Email__c}); // {userMap.get(projRec.OwnerId).Email} );  
                    mymail.setSenderDisplayName('Symega');
                    mymail.setSubject(mailSubject);
                    mymail.setSaveAsActivity(false);   
                    semList.add(mymail);  
                }
                
                String emailBody = '<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ projRec.Id+'">'+ projRec.Name+'</a></html>';
             //   mymail.setHtmlBody('Hi '+userMap.get(projRec.OwnerId).FirstName +',' +'<br/>'+ '<br/>'+' The project'+emailBody  +'is completed by R&D and ' + projListmap.get(projRec.Id) +' number of quotient is added'+'<br/>'+ '<br/>' +'Thanks & Regards'+'<br/>'+'SYMEGA'); 
                

                string htmlBody = 'Hi '+userMap.get(projRec.OwnerId).FirstName +',' +'<br/>'+ '<br/>'+' The project ' +emailBody  +' is completed by R&D and ' + projListmap.get(projRec.Id) +' number of quotient is added.'+'<br/>';
               
               // htmlBody +=  '<br/>'+' The project'+emailBody  +'is completed by R&D and ' + projListmap.get(projRec.Id) +' number of quotient is added';
                htmlBody += '<br><br> <table border="2" style="border-collapse: collapse"><tr><th>Project Quotient Name</th><th>Product Name</th><th>Product Code</th></tr>';

                    for(Project_Quotient__c pqRec: projQMapList.get(projRec.Id)){
                     
                       if(pqRec.SSC_Code__c == null){
                           pqRec.SSC_Code__c = '';
                       }
                      
                       if(pqRec.Product_Name__c == null){
                          pqRec.Product_Name__c = '' ;
                       } 



                           htmlBody += '<tr><td>' + pqRec.Name + '</td><td>' + pqRec.Product_Name__c + '</td><td>' + pqRec.SSC_Code__c + '</td></tr>' ; 
                    }          
                   
                htmlBody += '</table>';
                htmlBody += '<br><br> Thanks & Regards';
                htmlBody += '<br>Symega';
                mymail.setHtmlBody(htmlBody);

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