({
    searchHelper : function(component,event,getInputkeyWord) {
        
        //debugger;
        //alert('Im inside Search Helper');
        
        var searchCode = component.get("v.searchKeyword");
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        console.log('component.get("v.sampleId") -- ', component.get("v.sampleId"));
        // set param to method  
        action.setParams({
            'searchKeyWord' : searchCode,
            'recId'         : component.get("v.sampleId")
        });
        
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
})