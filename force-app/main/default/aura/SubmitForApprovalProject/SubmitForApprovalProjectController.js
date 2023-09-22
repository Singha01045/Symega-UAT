({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.submitProjectBHApproval");
        action.setParams({
            "projectId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var serverResponse = response.getReturnValue();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");    
            if (response.getState() === "SUCCESS" && serverResponse === "SUCCESS") {
            } else {
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
})