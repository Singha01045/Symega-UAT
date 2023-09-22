import { LightningElement,api,wire,track} from 'lwc';
import getRecordDetails from '@salesforce/apex/ProjectHanlder.getAccRecord';
import getRecordTypeId from '@salesforce/apex/ProjectHanlder.getProjectRecordTypeId';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateSampleAccount extends NavigationMixin(LightningElement){
    @api recordId;
    @track recordTypeSelected;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getRecordDetails({ accId : this.recordId}).then(data=>{
            if(data){
                this.accRecord = data;
                console.log('RecordId', this.recordId);
                console.log('Data',data);
                this.openCreateRecordForm();
            }
        })
    }


    // @wire(getRecordDetails,{ accId : '$recordId'})
    // recordDetails({data,error}){
    //     if(data){
    //         this.accRecord = data;
    //         console.log('RecordId', this.recordId);
    //         console.log('Data',data);
    //         this.openCreateRecordForm();
    //     }
    //     if(error){
    //         console.log("Errorsss",error);
    //     }
    // }
    
    openCreateRecordForm(){
        debugger;
        getRecordTypeId({recordTypeName: 'Sample'}).then(result=>{
            console.log("RecordTypeRECEIVED-----",result);
            let recordTypeId = result;
            let defaultValues = encodeDefaultFieldValues({
            Account__c:this.recordId,
            Customer_Name__c :this.accRecord.Name,
            Sample_Name__c	:`${this.accRecord.Name}-Sample`,
            Customers_Contact__c:this.accRecord.Customer_Contact__c,
            City__c:this.accRecord.ShippingCity?this.accRecord.ShippingCity:"",
            Country__c:this.accRecord.ShippingCountry?this.accRecord.ShippingCountry:"",
            Postal_Code__c	:this.accRecord.ShippingPostalCode?this.accRecord.ShippingPostalCode:"",
            State__c:this.accRecord.ShippingState?this.accRecord.ShippingState:"",
            Street__c:this.accRecord.ShippingStreet?this.accRecord.ShippingStreet:"",
            CurrencyIsoCode : this.accRecord.CurrencyIsoCode,
            Customer_Contact__c : this.accRecord.Customer_Contact__c ? this.accRecord.Customer_Contact__c : null
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Project__c',
                actionName: 'new'
            },state: {
               defaultFieldValues: defaultValues,
               recordTypeId: this.recordTypeSelected
            }
        });
    }).catch(error=>{
        console.log("Error-----",error);
    })
    }

}