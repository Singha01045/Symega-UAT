import { LightningElement,api,wire,track} from 'lwc';
import getAllAddresses from "@salesforce/apex/ProjectHanlder.getAllCustomerAddress";
import getAccountDetails from '@salesforce/apex/ProjectHanlder.getAccRecord';
import getRecordTypeId from '@salesforce/apex/ProjectHanlder.getOppRecordTypeId';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateOpportunityOnAccount extends NavigationMixin(LightningElement) {
    @api recordId;
    @track recordTypeSelected;
    selectedAddressIndex = -1;
    @track ship_addresses = [];
    error;
    @track checkedShipAdd;
    @track accRecord;
    @track nextBtn = true;

     
    connectedCallback(){
        debugger;
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        debugger;
        getAllAddresses({custId : this.recordId}).then(data => {
            if(data){
                debugger;
                let clonedData = JSON.parse(JSON.stringify(data));
                this.accRecord = clonedData.account;
                this.ship_addresses = clonedData.customer_ship_addresses;
                this.selectedAddressIndex = clonedData.ship_selected_index != undefined ? clonedData.ship_selected_index : -1;
                this.selectedBilAddressIndex = clonedData.bill_selected_index != undefined ? clonedData.bill_selected_index : -1;
                console.log('RecordId', this.recordId);
                console.log('Data',clonedData);
            }
            // if(error){
            //     this.error = error;
            //     console.log("Errorsss",error);
            // }
       })
    }

    onAddressSelect(event) {
        debugger;
       // let addressId = event.currentTarget.dataset.id;
       // let selectedIndex = event.currentTarget.dataset.index;
        this.checkedShipAdd = event.target.checked;
         if(this.checkedShipAdd ){
                this.nextBtn = false;
        }else{
              this.nextBtn = true;
        }
    }

    handleNavigate() {
        debugger;
        // let index = this.ship_addresses.findIndex((item) => {
        //     return item.checked === true;
        // });
        // if(index === -1) {
        //     const evt = new ShowToastEvent({
        //         title: "No Selection",
        //         message: "Please select Shipping address in-order to proceed.",
        //         variant: "Warning",
        //     });
        //     this.dispatchEvent(evt);
        //     return;
        // }
            // 73 -75 commented
        // let selectedAddress = this.ship_addresses[index];
        // console.log('selectedAddress--->',selectedAddress);
        // let addressId = selectedAddress.id;
        let accShipAddress = false;
        
        addressId = undefined;
        accShipAddress = true;
        
        this.openCreateRecordForm(accShipAddress);
    }        

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

   
    openCreateRecordForm(accShipAddress){
        debugger;
        getRecordTypeId({recordTypeName: 'Parent'}).then(result=>{
            console.log("RecordTypeRECEIVED-----",result);
            let recordTypeId = result;
            let defaultValues = encodeDefaultFieldValues({
                AccountId:this.accRecord.Id,
                Name:`${this.accRecord.Name}-Opportunity`,
                StageName:'New',
                CurrencyIsoCode : this.accRecord.CurrencyIsoCode,
                LeadSource : this.accRecord.AccountSource,
                City__c : accShipAddress.city,
                State__c : accShipAddress.state,
                Street__c : accShipAddress.street,
                Postal_Code__c : accShipAddress.postalCode,
                Country__c : accShipAddress.country
            });

            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Opportunity',
                    actionName: 'new'
                },state: {
                defaultFieldValues: defaultValues,
                recordTypeId: recordTypeId
                }
            });
        }).catch(error=>{
            console.log("Error-----",error);
        })
    }
}