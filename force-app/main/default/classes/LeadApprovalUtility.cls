/**
* Author: Aakash.
*/
public without sharing class LeadApprovalUtility {
    @AuraEnabled
    public static String submitForApprovalToMarketingHead(string leadId){
        try{
            system.debug('leadId>>'+leadId);
            if(String.isBlank(leadId))
                return Constants.PENDING;
            Lead lRec = [SELECT Id, Approver_Name__c, Marketing_Head_Approved__c FROM Lead WHERE Id=:leadId];
            if(!String.isBlank(leadId)) {
                ProcessInstance[] recordUnderApproval = [Select ID, Status,TargetObjectID, TargetObject.Name From ProcessInstance Where Status =: Constants.PENDING AND TargetObjectID =:leadId];
                if(!recordUnderApproval.isEmpty()){
                    return Constants.PENDING;
                }else if(lRec.Marketing_Head_Approved__c){
                    return Constants.PENDING;
                }else{
                    String symegaConfigMHGroupName = '';
                    List<Id> marketingHeadId = new List<Id>();
                    Lead leadRecToBeSubmittedForApproval = new Lead();
                    List<Group_Member__c> marketingHead = new List<Group_Member__c>();
                    leadRecToBeSubmittedForApproval = [Select Id, OwnerId From Lead WHERE Id =: leadId];
                    Symega_Configuration__c orgConfig = Symega_Configuration__c.getValues('Symega Configuration');
                    if(orgConfig != null && !String.isBlank(orgConfig.Lead_Approval_Marketing_Head_Group_Name__c)) {
                        symegaConfigMHGroupName = orgConfig.Lead_Approval_Marketing_Head_Group_Name__c;
                        system.debug('symegaConfigMHGroupName>>'+symegaConfigMHGroupName);
                        if(!String.isBlank(symegaConfigMHGroupName))
                            marketingHead = [Select Assignment_Approval_Group__c,User__c,Lead_Assigned_Approved_On__c,Id From Group_Member__c Where Assignment_Approval_Group__r.Name = :symegaConfigMHGroupName AND Assignment_Approval_Group__r.Type__c =: Constants.LEAD_APPROVAL AND Active__c = TRUE ORDER BY Lead_Assigned_Approved_On__c ASC limit 1];
                        system.debug('marketingHead>>'+marketingHead);
                        
                        if(!marketingHead.isEMpty())
                            marketingHeadId.add(marketingHead[0].User__c);
                        
                        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                        approvalRequest.setComments('Submitting for marketing head approval.');
                        approvalRequest.setObjectId(leadId);
                        approvalRequest.setSubmitterId(UserInfo.getUserId()); 
                        approvalRequest.setProcessDefinitionNameOrId(Constants.LEAD_APPROVAL_PROCESS_MH);
                        approvalRequest.setSkipEntryCriteria(true);
                        if(!marketingHeadId.isEmpty()){
                            system.debug('approval firing');
                            
                            lRec.Approver_Name__c = [SELECT Id, Name FROM User WHERE Id =: marketingHeadId[0]].Name;
                            update lRec;     
                            
                            approvalRequest.setNextApproverIds(marketingHeadId);
                            Approval.ProcessResult result = Approval.process(approvalRequest);                           
                            
                            LeadShare shareLead = new LeadShare(LeadId = leadId, UserOrGroupId = marketingHead[0].User__c, LeadAccessLevel = 'Edit', RowCause = 'Manual');
                            insert shareLead;
                        }
                    }else{
                        throw new LeadApprovalException('Error: PLease configure Org configuration');
                    }
                }
            }
            return 'Success';
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error>>><<'+ex.getLineNumber());
            HandleBusinessException.captureError('LeadApproval', 'submitForApprovalToMarketingHead', ex);
            return 'Error';
        }
    }
    @future
    public static void submitForApprovalToBusinessHead(String leadId){
        system.debug('leadId>>'+leadId);
        
        if(!String.isBlank(leadId)) {
            try{
                List<Lead> leadForApprovalList = [SELECT Id, Approver_Name__c, Business_Head__c, Owner.UserRole.Name, OwnerId FROM Lead WHERE Id =:leadId];
                System.debug('leadForApprovalList ---' + leadForApprovalList);
                if(!leadForApprovalList.isEmpty() && ( (leadForApprovalList[0].Business_Head__c != null) && !leadForApprovalList[0].Owner.UserRole.Name.contains('Business Head') || leadForApprovalList[0].Owner.UserRole.Name.contains('Business Head')) ){ 
                    
                    List<Id> businessHeadIdList = new List<Id>();
                    
                    if(leadForApprovalList[0].Owner.UserRole.Name.contains('Business Head')){
                        businessHeadIdList = new List<Id>{ [SELECT Id, ManagerId FROM User WHERE Id =: leadForApprovalList[0].OwnerId].ManagerId};
                    }
                    else{
                        businessHeadIdList = new List<Id>{leadForApprovalList[0].Business_Head__c};
                    }  
                    
                    leadForApprovalList[0].Approver_Name__c = [SELECT Id, Name FROM User WHERE Id =: businessHeadIdList[0]].Name;
                    update leadForApprovalList[0];
                    
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Submitting for business head approval.');
                    approvalRequest.setObjectId(leadId);
                    approvalRequest.setSubmitterId(UserInfo.getUserId()); 
                    system.debug('businessHeadIdList -- ' + businessHeadIdList);
                    approvalRequest.setProcessDefinitionNameOrId(Constants.LEAD_APPROVAL_PROCESS_BH);
                    approvalRequest.setSkipEntryCriteria(true);
                    if(!businessHeadIdList.isEmpty())
                        approvalRequest.setNextApproverIds(businessHeadIdList);
                    Approval.ProcessResult result = Approval.process(approvalRequest);
                }else {
                    throw new LeadApprovalException('Business head isn\'t configured.');
                }
            }catch(Exception e) {
                system.debug('Error==>'+e.getMessage());
                system.debug('Error>>><<'+e.getLineNumber());
                HandleBusinessException.captureError('LeadApprovalUtility', 'submitForApprovalToBusinessHead', e);
            }
        }
    }
    
     /**
* Added by DeaGle
* Req: Submit Project for business head approval based on role hierarchy. 
*/
    @AuraEnabled
    public static String submitProjectBHApproval(string projectId){
        try{
            system.debug('---'+projectId);
            
            if(!String.isBlank(projectId)) {
                ProcessInstance[] recordUnderApproval = [Select ID, Status,TargetObjectID, TargetObject.Name From ProcessInstance Where Status =: Constants.PENDING AND TargetObjectID =:projectId];
                if(!recordUnderApproval.isEmpty()){
                    return 'Record is currently under approval process.';
                }
                Project__c projRec = [SELECT Id, Approver_Name__c, Owner.UserRoleId, Owner.UserRole.Name, OwnerId FROM Project__c WHERE Id = :projectId];
                Id ownerRoleId = projRec.Owner.UserRoleId;
                system.debug('ownerRoleId -- ' + ownerRoleId);
                Id approverId;
                if(ownerRoleId != null) {
                    
                    if(projRec.Owner.UserRole.Name.contains('Business Head')){
                        approverId = [SELECT Id, ManagerId FROM User WHERE Id =: projRec.OwnerId].ManagerId;
                    }
                    else{
                        approverId = getBusinessHeadApproverId(ownerRoleId);
                    }
                    system.debug('approverId -- ' + approverId);
                    if(approverId != null) {
                        
                        projRec.Approver_Name__c = [SELECT Id, Name FROM User WHERE Id =: approverId].Name;
                        update projRec;
                        
                        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                        approvalRequest.setComments('Submitting project request for an approval.');
                        approvalRequest.setObjectId(projectId);
                        approvalRequest.setSubmitterId(UserInfo.getUserId());
                        approvalRequest.setProcessDefinitionNameOrId(Constants.PROJECT_APPROVAL_PROCESS);
                        approvalRequest.setSkipEntryCriteria(true);
                        system.debug('Initiate Project Approval');
                        approvalRequest.setNextApproverIds(new List<Id>{ approverId }); 
                        Approval.ProcessResult result = Approval.process(approvalRequest);
                        return 'SUCCESS';
                    }
                } 
                
            }
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error>>><<'+ex.getLineNumber());
            HandleBusinessException.captureError('LeadApprovalUtility', 'submitProjectBHApproval', ex);
        }
        return 'Couldn\'t find approver on your role, please contact administrator.';
    }
    
    
    public static void updateApprovedDate(string groupName){
        List<Group_Member__c> groupMember = new List<Group_Member__c>();
        try{
            if(!String.isBlank(groupName)){
                groupMember = [Select Lead_Assigned_Approved_On__c From Group_Member__c Where Assignment_Approval_Group__r.Name =:groupName AND Active__c = TRUE ORDER BY Lead_Assigned_Approved_On__c ASC limit 1];
                if(!groupMember.isEmpty()){
                    groupMember[0].Lead_Assigned_Approved_On__c = DateTime.now();
                    update groupMember;
                }
            }
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error>>><<'+ex.getLineNumber());
        }
    }
    
    static Map<Id,UserRole> allRolesMap;
    public static OpportunityApprovalWrapper getUserBHMap() {
        Map<Id,Id> userRoleToBHRoleMap = new Map<Id,Id>();
        
        allRolesMap = allRolesMap == null ? new Map<Id, UserRole>([SELECT Id, ParentRoleId, Name FROM UserRole]) : allRolesMap;
        for(UserRole ur : allRolesMap.values()) {
            if(!ur.Name.containsIgnoreCase('CEO') && !ur.Name.containsIgnoreCase('Business Head') && !ur.Name.containsIgnoreCase('Managing Director')) {
                userRoleToBHRoleMap.put(ur.Id, getBusinessHeadIdRecursive(allRolesMap, ur));
            }
        }
        
        Map<Id,Id> usrRoleToBhIdMap = new Map<Id,Id>();
        if(!userRoleToBHRoleMap.isEmpty()) {
            List<User> userList = [SELECT Id, UserRoleId FROM User WHERE UserRoleId IN :userRoleToBHRoleMap.values()];
            for(User usr: userList) {
                if(!usrRoleToBhIdMap.containsKey(usr.UserRoleId))
                    usrRoleToBhIdMap.put(usr.UserRoleId, usr.Id);
            }
        } 
        return new OpportunityApprovalWrapper(userRoleToBHRoleMap, usrRoleToBhIdMap);
    }
    
    
    public static OpportunityApprovalWrapper getUserMDMap() {
        Map<Id,Id> userRoleToMDRoleMap = new Map<Id,Id>();
        
        allRolesMap = allRolesMap == null ? new Map<Id, UserRole>([SELECT Id, ParentRoleId, Name FROM UserRole]) : allRolesMap;
        for(UserRole ur : allRolesMap.values()) {
            if(!ur.Name.containsIgnoreCase('CEO') && !ur.Name.containsIgnoreCase('Managing Director')) {
                userRoleToMDRoleMap.put(ur.Id, getMDIdRecursive(allRolesMap, ur));
            }
        }
        
        Map<Id,Id> roleIdToMDIdMap = new Map<Id,Id>();
        if(!userRoleToMDRoleMap.isEmpty()) {
            List<User> userList = [SELECT Id, UserRoleId FROM User WHERE UserRoleId IN :userRoleToMDRoleMap.values()];
            for(User usr: userList) {
                if(!roleIdToMDIdMap.containsKey(usr.UserRoleId))
                    roleIdToMDIdMap.put(usr.UserRoleId, usr.Id);
            }
        }
        return new OpportunityApprovalWrapper(userRoleToMDRoleMap, roleIdToMDIdMap);
    }
   
    
    public static Id getBusinessHeadApproverId(Id currentUserRoleId) {
        if(!String.isBlank(currentUserRoleId)) {
            Map<Id,UserRole> userRoleMap = new Map<Id,UserRole>([SELECT Id, ParentRoleId, Name FROM UserRole]);
            if(userRoleMap.containsKey(currentUserRoleId)) {
                Id bhRoleId;
                bhRoleId = getBusinessHeadIdRecursive(userRoleMap, userRoleMap.get(currentUserRoleId));
                system.debug('ld utility bhRoleId :: ' + bhRoleId);
                if(bhRoleId != null) {
                    List<User> bhUserList = [SELECT Id FROM User WHERE UserRoleId =:bhRoleId];
                    if(!bhUserList.isEmpty()) {
                        return bhUserList[0].Id;
                    }else {
                        Id mdRoleId = getMDIdRecursive(userRoleMap, userRoleMap.get(bhRoleId));
                        if(mdRoleId != null) {
                            List<User> mdUserList = [SELECT Id FROM User WHERE UserRoleId =:mdRoleId];
                            if(!mdUserList.isEmpty()) {
                                return mdUserList[0].Id;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }
    
    Public static Id getBusinessHeadIdRecursive(Map<Id,UserRole> userRoleMap, UserRole currentRole) {
        if(currentRole.ParentRoleId != null && userRoleMap.get(currentRole.ParentRoleId).Name != null && userRoleMap.get(currentRole.ParentRoleId).Name.containsIgnoreCase('Business Head')) {
            return userRoleMap.get(currentRole.ParentRoleId).Id;
        }else if(currentRole.ParentRoleId != null){
            return getBusinessHeadIdRecursive(userRoleMap, userRoleMap.get(currentRole.ParentRoleId));
        }else {
            return null; //TOP Role - CEO.
        }
    }
    
    public static Id getMDIdRecursive(Map<Id,UserRole> userRoleMap, UserRole currentRole) {
        if(currentRole.ParentRoleId != null && userRoleMap.get(currentRole.ParentRoleId).Name != null && userRoleMap.get(currentRole.ParentRoleId).Name.containsIgnoreCase('Managing Director')) {
            return userRoleMap.get(currentRole.ParentRoleId).Id;
        }else if(currentRole.ParentRoleId != null){
            return getMDIdRecursive(userRoleMap, userRoleMap.get(currentRole.ParentRoleId));
        }else {
            return null; //TOP Role - CEO.
        }
    }
    
    public static Id getParentIdRecursive(Map<Id,UserRole> userRoleMap, UserRole currentRole) {
        if(currentRole.ParentRoleId != null && userRoleMap.get(currentRole.ParentRoleId).Name != null) {
            return userRoleMap.get(currentRole.ParentRoleId).Id;
        }else if(currentRole.ParentRoleId != null){
            return getParentIdRecursive(userRoleMap, userRoleMap.get(currentRole.ParentRoleId));
        }else {
            return null; //TOP Role - CEO.
        }
    }
    
    public class OpportunityApprovalWrapper {
        public Map<Id,Id> smToManagerMap;
        public Map<Id,Id> managerRoleToUserIdMap;
        
        public OpportunityApprovalWrapper(Map<Id,Id> smToManagerMap, Map<Id,Id> managerRoleToUserIdMap) {
            this.smToManagerMap = smToManagerMap;
            this.managerRoleToUserIdMap = managerRoleToUserIdMap;
        }
    }
    
    class LeadApprovalException extends Exception {}
}