({
    doInit : function(component, event, helper) {
        debugger;
        
        helper.getSymegaPicklistValues(component, event);
        helper.getMtrlSecPicklistValues(component, event);
        helper.getPlantPicklistValues(component, event);
        
        var action = component.get("c.getProductList");
        action.setParams({
            "oppId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {                
                component.set("v.OppLineItemList", response.getReturnValue());
            }
            else{
                console.log("Failed with state: " , state);
            } 
        });
        $A.enqueueAction(action);        
    },
    
    handleSubmit: function(component, event, helper) {
        debugger;
        var EmptyProdcount = 0;
        var recordList = component.get("v.OppLineItemList");  
        for(var i=0; i<recordList.length; i++){
            let obj = recordList[i];
            if(obj.Primary__c == '' || obj.Secondary__c == '' || obj.Tertiary__c == ''|| obj.Customized_Label__c == '' || obj.Symega_Logo__c == '' || obj.Material_Sector__c == '' || obj.If_Organised_set_Micro_as_Long_Term__c == '' ){
                EmptyProdcount++;
            }
            debugger;
        }
        
        if(EmptyProdcount == 0){
            helper.updateOLI(component) 
            .then($A.getCallback(function(res){
                var action = component.get("c.sendFERTCodeReqEmailNotificaiton");
                action.setParams
                ({ 
                    "oppId": component.get("v.recordId")
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === 'SUCCESS') {
                        var storeResponse = response.getReturnValue();
                        console.log("SUCCESS RESULT: ", storeResponse);
                        if(storeResponse === 'Success'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Success',
                                message: 'Notification sent successfully',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                        else if(storeResponse === 'create'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Success',
                                message: 'Customer Creation in Progress!',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                            else{
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Warning',
                                    message: storeResponse,
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'warning',
                                    mode: 'pester'
                                });
                                toastEvent.fire();
                            }                       
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                    }
                    else if(state ==='ERROR') {
                        var errors= response.getError();
                        console.log("Email ERROR: ", errors);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Email Error',
                            message: errors[0].message,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'sticky'
                        });
                        toastEvent.fire();
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                    }
                }, 'ALL' );
                $A.enqueueAction(action);
            }))
            .catch($A.getCallback(function(error){
                console.log("Updation ERROR: ", error);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Updation Error',
                    message: error,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'sticky'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }));
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Please fill all the details!!',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'sticky'
            });
            toastEvent.fire();
        }
        $A.get('e.force:refreshView').fire();
        
    }, 
    
    handleCancel: function(component, event, helper) {
        debugger;
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
    
})