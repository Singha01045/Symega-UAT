import { LightningElement,api,wire} from 'lwc';
import {CloseActionScreenEvent} from 'lightning/actions';
import sendSONotification from '@salesforce/apex/OpportunityCreateSaleOrderController.sendSONotification'
import getLineItemDet from '@salesforce/apex/OpportunityCreateSaleOrderController.getLineItemDetails'
import updateOpp from '@salesforce/apex/OpportunityCreateSaleOrderController.updateOpp'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class PushSOToSAP extends LightningElement {

    @api recordId;
    initiallySubmitted = false;
    showAccountPage = false;
    showSpinner = true;
    accRecId;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getLineItemDet({recId : this.recordId}).then(data => {
            this.showSpinner = false;
            if(data.fertCodesPresentForAll == false){
                this.showToast('Error','FERT Code missing','error');
                this.closePopup();
            }
            else{
                if(data.accountFieldsMissing == false){
                    this.sendSONotification();
                }
                else{
                    this.accRecId = data.accRecId;
                    this.showAccountPage = true;
                    this.initiallySubmitted = data.initiallySubmitted;
                }
            }
        })
    }

    sendSONotification(){
        sendSONotification({id : this.recordId}).then(data=>{
            if(data=='Success'){
                this.showToast('Success','Notification Sent Successfully','success');
            }else{
                this.showToast('Success',data,'success');
            }

            this.updateOpp();
        })
    }

    // @wire(sendSONotification,{id : '$recordId'})
    // wiredResponse(result){
    //     debugger;
    //     if(result.data){
    //         console.log('DATA----',result.data);
            
    //         if(result.data=='Success'){
    //             this.showToast('Success','Notification Sent Successfully','success');
    //         }else{
    //             this.showToast('Success',result.data,'success');
    //         }

    //         this.updateOpp();
    //         console.log(result);
    //     }
    // }

    updateOpp(){
        updateOpp({soId:this.recordId}).then(result =>{
            console.log('Opp Update Result',result);

            if(result!='Success'){
                this.showToast('Failed',result,'error');
                this.dispatchEvent(new CloseActionScreenEvent());        
            }else{
                this.closePopup();
            }
        }).catch(err =>{
            console.log('Errror-----',err);
        })
    }

    closePopup(){
        this.dispatchEvent(new CloseActionScreenEvent());
        setTimeout(()=>window.location.reload(),1500);
    }

    showToast(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleSuccess(){
        debugger;
        this.showToast('Success', 'Account updated successfully', 'success');
        this.showAccountPage = false;
    }
}