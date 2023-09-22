import { LightningElement,wire,api } from 'lwc';
import getOppRecord from '@salesforce/apex/OpportunityHanlder.getRecord'
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class CreateSalesOrder extends NavigationMixin(LightningElement){
    
    @api recordId;
    oppRecord;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getOppRecord({oppId:this.recordId}).then(data=>{
            if(data){
                this.oppRecord = data[0];
                console.log('RecordId',this.recordId);
                console.log('Data',data);
                this.openCreateRecordForm();
            }
        })
    }

    // @wire(getOppRecord,{oppId:'$recordId'})
    // recordDetails({data,error}){
    //     if(data){
    //         this.oppRecord = data[0];
    //         console.log('RecordId',this.recordId);
    //         console.log('Data',data);
    //         this.openCreateRecordForm();
    //     }
    //     if(error){
    //         console.log("Error",error);
    //     }
    // }

    openCreateRecordForm(){
        let defaultValues = encodeDefaultFieldValues({
            Name: `${this.oppRecord.Name} - SO`,
            Account__c:this.oppRecord.AccountId,
            Opportunity__c: this.oppRecord.Id,
            Amount__c: this.oppRecord.Amount,
            Order_quantity__c:this.oppRecord.TotalOpportunityQuantity,
            Distributer_Customer__c:this.oppRecord.AccountId,
            CurrencyIsoCode: this.oppRecord.CurrencyIsoCode
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Sales_Order__c',
                actionName: 'new'
            },state: {
                defaultFieldValues: defaultValues
            }
        });
    }
}