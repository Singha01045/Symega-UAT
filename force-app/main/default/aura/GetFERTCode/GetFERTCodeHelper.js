({
    updateOLI : function(component) {
        debugger;
        return new Promise(
            $A.getCallback(function(resolve, reject) {
                var action = component.get("c.OppLineItemUpdate");
                action.setParams({  
                    'OLIRecords': component.get("v.OppLineItemList")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        resolve(response.getReturnValue());
                    }    
                    if(state === "ERROR"){
                        reject(response.getError());
                    }
                });
                $A.enqueueAction(action);
            }));
    },
    
    getSymegaPicklistValues: function(component, event) 
    {
        debugger;
        var action = component.get("c.getPicklistValues");
        action.setParams
        ({ 
            "ObjectApi_name": 'OpportunityLineItem',
            "Field_name": 'Symega_Logo__c'
        });
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var result = response.getReturnValue();
                                   var Options = [];
                                   for(var key in result)
                                   {
                                       Options.push({key: key, value: result[key]});
                                   }
                                   component.set("v.symLogoOptions", Options);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    getMtrlSecPicklistValues: function(component, event) 
    {
        debugger;
        var action = component.get("c.getPicklistValues");
        action.setParams
        ({ 
            "ObjectApi_name": 'OpportunityLineItem',
            "Field_name": 'Material_Sector__c'
        });
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var result = response.getReturnValue();
                                   var Options = [];
                                   for(var key in result)
                                   {
                                       Options.push({key: key, value: result[key]});
                                   }
                                   component.set("v.mtrlSecOptions", Options);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    getPlantPicklistValues: function(component, event) 
    {
        debugger;
        var action = component.get("c.getPicklistValues");
        action.setParams
        ({ 
            "ObjectApi_name": 'OpportunityLineItem',
            "Field_name": 'Plant__c'
        });
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var result = response.getReturnValue();
                                   var Options = [];
                                   for(var key in result)
                                   {
                                       Options.push({key: key, value: result[key]});
                                   }
                                   console.log('Plant Options:: ', Options);
                                   component.set("v.plantOptions", Options);
                               }
                           });
        $A.enqueueAction(action);
    }
    
})