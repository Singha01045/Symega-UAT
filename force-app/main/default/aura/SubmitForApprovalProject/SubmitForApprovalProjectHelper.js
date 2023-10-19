({
    /*getMissingAccountData : function(component, event) {
        debugger;
        var action = component.get("c.getMissingAccountDetails");
        action.setParams({
            projId : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue() !=null){
                    var tempArray = [];
                    var data = response.getReturnValue();
                    if(data != null){
                        if(data.length>0){
                            component.set("v.ShowUpdateAccountPage",true);
                            component.set("v.MissingFieldList",data);   
                            component.set("v.accountId","0015j00000ryYzZAAU");
                        }else{
                            component.set("v.ShowUpdateAccountPage",false);
                        }
                    }
                }
            }else if(response.getState() === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }*/
    
    getMissingAccountData : function(component, event) {
        debugger;
        return new Promise(
            $A.getCallback(function(resolve, reject) {
                var action = component.get("c.getMissingAccountDetails");
                action.setParams({
                    projId : component.get("v.recordId")
                });
                action.setCallback(this,function(response){
                    if(response.getState() === "SUCCESS"){
                        if(response.getReturnValue() !=null){
                            return response.getReturnValue();
                        }
                    }
                });
                $A.enqueueAction(action);
            }));
    }
})