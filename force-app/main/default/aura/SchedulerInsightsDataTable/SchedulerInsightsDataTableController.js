({
	doInit : function(component, event, helper) {
        debugger;
        var action = component.get('c.getAllDateOfSchdeularSight');
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                var data = response.getReturnValue();
                if(data.visitRecList !=null && data.visitRecList.length >0){
                    component.set("v.visitList",data.visitRecList);
                }
                if(data.LeadRecList !=null && data.LeadRecList.length >0){
                    component.set("v.LeadList",data.LeadRecList);
                }
                if(data.eventList !=null && data.eventList.length >0){
                    component.set("v.EventList",data.eventList);
                }
                if(data.emailList !=null && data.emailList.length >0){
                    component.set("v.EmailList",data.emailList);
                }
                if(data.oppList !=null && data.oppList.length >0){
                    component.set("v.OppList",data.oppList);
                }
                if(data.oppNegoList !=null && data.oppNegoList.length >0){
                    component.set("v.OppNegoList",data.oppNegoList);
                }
                if(data.quoteList !=null && data.quoteList.length >0){
                    component.set("v.QuotList",data.quoteList);
                }
                if(data.purOrdList !=null && data.purOrdList.length >0){
                    component.set("v.PurchaseOrderList",data.purOrdList);
                }
                if(data.invoList !=null && data.invoList.length >0){
                    component.set("v.InvoiceList",data.invoList);
                }
                if(data.caseList !=null && data.caseList.length >0){
                    component.set("v.TicketList",data.caseList);
                }
                if(data.feedbackList !=null && data.feedbackList.length >0){
                    component.set("v.FeedbackList",data.feedbackList);
                }
            }
        });
        $A.enqueueAction(action);
    },
})