({
    doInit : function(component, event, helper) {
        debugger;
        
        /* helper.getMissingAccountData(component, event).then(missingFields =>{
            console.log('missingFields -- ',missingFields);
            component.set("v.ShowSpinner",false);
           if(missingFields > 0){
                component.set("v.ShowUpdateAccountPage",true);
                component.set("v.MissingFieldList",data);   
                component.set("v.accountId","0015j00000ryYzZAAU");
            }
            else{
                component.set("v.ShowUpdateAccountPage",false);
                var action = component.get('c.callApprovalMethod');
                $A.enqueueAction(action);
            }
        });*/
        
        
        var action = component.get("c.getMissingAccountDetails");
        action.setParams({
            projId : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue() !=null){
                    var data = response.getReturnValue();
                    component.set("v.ShowSpinner",false);
                    if(data != null && data != undefined){
                        if(data.missingFields == true){
                            component.set("v.ShowUpdateAccountPage",true);
                            component.set("v.MissingFieldList",data.missingFieldsList);   
                            component.set("v.accountId",data.projectRec.Opportunity__r.AccountId);
                        }
                        else{
                            component.set("v.ShowUpdateAccountPage",false);
                            var action = component.get('c.callApprovalMethod');
                            $A.enqueueAction(action);
                        }
                    }
                }
            }
            else if(response.getState() === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    callApprovalMethod : function(component, event, helper) {
        debugger;
        var action = component.get("c.submitProjectBHApproval");
        action.setParams({
            "projectId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var serverResponse = response.getReturnValue();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");    
            if (response.getState() === "SUCCESS" && serverResponse === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Submitted for BH Approval',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            } 
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: serverResponse,
                    duration: '5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }    
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
    
    handleUpdate  : function(component, event) {
        debugger;
        
        /*var action = component.get('c.callApprovalMethod');
        $A.enqueueAction(action);*/
        
        var action = component.get("c.submitProjectBHApproval");
        action.setParams({
            "projectId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var serverResponse = response.getReturnValue();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");    
            if (response.getState() === "SUCCESS" && serverResponse === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Account Updated Successfully and submitted for BH Approval...',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            } 
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: serverResponse,
                    duration: '5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }    
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
        component.set('v.ShowUpdateAccountPage', false);
    },
    
    closeModal  : function(component, event) {
        debugger;           
        var dismissActionPanel = $A.get("e.force:closeQuickAction");    
        dismissActionPanel.fire();
    }
    
})