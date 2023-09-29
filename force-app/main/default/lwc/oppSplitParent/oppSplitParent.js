import { LightningElement,api,wire,track } from 'lwc';
import {CloseActionScreenEvent} from 'lightning/actions';
import createOpp from '@salesforce/apex/OppSplitParentController.createOpp'
import getOppRecord from '@salesforce/apex/OppSplitParentController.getRecord'
import getAllAddresses from "@salesforce/apex/OppSplitParentController.getAllCustomerAddress";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class OppSplitParent extends NavigationMixin(LightningElement) {
    @api recordId;
    oppRecord;
    prodListResp = [];
    childSplits = [];
    prodList = [];

    currentOppName = "";

    isLoaded = true;
    showAlert = false;
    hasChildSplits = false;
    hasLoaded = false;
    showDetails = false;
    isSplitLeft = true;
    showNextScreen = false;

    selectedAddressIndex = -1;
    selectedBilAddressIndex = -1;
    @track ship_addresses = [];
    @track bill_addresses = [];
    error;
    @track checkedShipAdd;
    @track checkedBillAdd
    @track accRecord;
    @track nextBtn = true;

    accShipAddress = false;
    accountBillAddress = false;
    addressId;
    billAddressId;

    tableColums = [
        { label: 'Product', fieldName: 'Name'},
        { label: 'Quantity', fieldName: 'Quantity'},
        { label: 'Unit Price', fieldName: 'UnitPrice',type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: "code" }},
        { label: 'Total Price', fieldName: 'TotalPrice',type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: "code" }},
    ]

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getAllAddresses({oppId : this.recordId}).then(data => {
            if(data){
                debugger;
                this.isLoaded = true;
                let clonedData = JSON.parse(JSON.stringify(data));
                this.oppRecord = clonedData.Opportunity;
                if(this.oppRecord.Amount==null || this.oppRecord.TotalOpportunityQuantity==null){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Field not found',
                            message: 'Amount and quantity not found',
                            variant: 'error',
                        }),
                    );
                    this.closePopup();
                }
                
                this.oppRecord.OpportunityLineItems && this.oppRecord.OpportunityLineItems.forEach(prod=>{
                    let obj = {...prod};
                    obj.quantityChoosed = obj.Quantity;
                    obj.amountChoosed = obj.TotalPrice;
                    obj.remainingQuantity = obj.Quantity;
                    obj.remainingAmount = obj.TotalPrice;
                    obj.quantityUnit = obj.Quantity_Unit__c;
                    obj.PackagingType = obj.Packaging_Type__c;
                    obj.FERT_Code = obj.FERT_Code__c;

                    delete obj.Packaging_Type__c;
                    this.prodList.push(obj);
                })

                console.log('prodList',this.prodList);
                this.prodListResp = this.prodList;
    
                this.hasLoaded = true;
                console.log('RecordId',this.recordId);
                console.log('Data',data);     

                this.ship_addresses = clonedData.customer_ship_addresses;
                this.bill_addresses = clonedData.customer_bill_addresses;
                this.selectedAddressIndex = clonedData.ship_selected_index != undefined ? clonedData.ship_selected_index : -1;
                this.selectedBilAddressIndex = clonedData.bill_selected_index != undefined ? clonedData.bill_selected_index : -1;
                console.log('RecordId', this.recordId);
                console.log('Data',clonedData);
                if(this.ship_addresses && this.bill_addresses ){
                    this.nextBtn = false;
                }else{
                    this.nextBtn = true;
                }
            }
       })
    }

    onAddressSelect(event) {
        debugger;
        let addressId = event.currentTarget.dataset.id;
        let selectedIndex = event.currentTarget.dataset.index;
         this.checkedShipAdd = event.target.checked;
         if(this.checkedBillAdd==undefined){
              this.checkedBillAdd=true;
          }   
        if(addressId && selectedIndex ) {
            if(this.selectedAddressIndex !== -1)
                this.ship_addresses[this.selectedAddressIndex].checked = false;
            this.ship_addresses[selectedIndex].checked = true;
            this.selectedAddressIndex = selectedIndex;
        }
         if(this.checkedShipAdd &&  this.checkedBillAdd ){
                this.nextBtn = false;
        }else{
              this.nextBtn = true;
        }
        
    }

    onBillAddressSelect(event) {
        debugger;
        let addressId = event.currentTarget.dataset.id;
        let selectedIndex = event.currentTarget.dataset.index;
         this.checkedBillAdd = event.target.checked;   
          if(this.checkedShipAdd==undefined){
              this.checkedShipAdd=true;
          }
        if(addressId && selectedIndex ) {
            if(this.selectedBilAddressIndex !== -1)
                this.bill_addresses[this.selectedBilAddressIndex].checked = false;
            this.bill_addresses[selectedIndex].checked = true;
            this.selectedBilAddressIndex = selectedIndex;
        }
         if(this.checkedShipAdd &&  this.checkedBillAdd ){
                this.nextBtn = false;
        }else{
              this.nextBtn = true;
        }
    }

    handleNavigate() {
        debugger;
        let index = this.ship_addresses.findIndex((item) => {
            return item.checked === true;
        });

        let billingIndex = this.bill_addresses.findIndex((item) => {
            return item.checked === true;
        });
        if(index === -1 || billingIndex === -1) {
            const evt = new ShowToastEvent({
                title: "No Selection",
                message: "Please select Shipping and Billing address in-order to proceed.",
                variant: "Warning",
            });
            this.dispatchEvent(evt);
            return;
        }

        let selectedAddress = this.ship_addresses[index];
        this.addressId = selectedAddress.id;
        this.accShipAddress = false;

        let selectedBillingAddress = this.bill_addresses[billingIndex];
        this.billAddressId = selectedBillingAddress.id;
        this.accountBillAddress = false;
        
        if(selectedAddress.id === 'Shipping') {
            this.addressId = undefined;
            this.accShipAddress = true;
        }
        
        if(selectedBillingAddress.id === 'Billing') {
            this.billAddressId = undefined;
            this.accountBillAddress = true;
        }
        
        this.showNextScreen = true;
    }    

    addNewSplit(){
        debugger;
        if(this.showDetails){   
            let list = this.template.querySelector('c-opp-split-details').getProductList();
            if(list.products && list.products.length == 1 && list.products[0].quantityChoosed==0){
                this.showToast('Error','Choose quantity more than 0','error')
                return;
            }
            if(list){
                this.addSplits(list);
                this.showDetails = false;
            }
        }else{
            this.currentOppName = this.oppRecord.Name+'-'+(this.childSplits.length+1);
            this.showDetails = this.isSplitLeft;
        }
    }
    closePopup(){
        if(this.showAlert){
            this.dispatchEvent(new CloseActionScreenEvent());
        }else{
            this.showAlert = true;
        }
    }

    addSplits(splits){
        let totalQuantity = 0;
        let totalAmount = 0;

        splits.products.forEach(sProd=>{
            debugger;
            totalQuantity+=sProd.quantityChoosed;
            totalAmount+=sProd.amountChoosed;

            if(this.prodList.findIndex(prod=>prod.Id==sProd.Id)>=0 && sProd.quantityChoosed!=0){
                let index = this.prodList.findIndex(prod=>prod.Id==sProd.Id);
                let obj = {...sProd};
                if(obj.quantityChoosed==obj.remainingQuantity){
                    this.prodList.splice(index,1);
                }else{
                    obj.remainingQuantity = obj.remainingQuantity - obj.quantityChoosed;
                    obj.quantityChoosed = obj.remainingQuantity;
                    obj.amountChoosed = obj.remainingAmount;
                    this.prodList[index] = obj;
                }
            }
        })

        splits.totalQuantity = totalQuantity;
        splits.totalAmount = totalAmount;

        if(splits.totalQuantity==0){
            this.showToast('Error','Choose quantity more than 0','error')
            return;
        }

        this.childSplits.push(splits);
        this.hasChildSplits = this.childSplits.length>0;
        this.isSplitLeft = this.prodList.length>0;
        console.log("ProdList-----",this.prodList);
        console.log("ChildSplits---",JSON.stringify(this.childSplits));
    }

    createOpp(){
        debugger;
        let cSplits = [];
        this.isLoaded = false;

        let billingAddress = this.bill_addresses.find(item=>item.checked);
        let shippingAddress = this.ship_addresses.find(item=>item.checked);

        this.childSplits.forEach(split=>{
            let closeDate = new Date(split.closeDate);
            let nextOrderDate = new Date(split.nextOrderDate);

            split.closeDate = this.formatDate(closeDate);
            split.nextOrderDate = this.formatDate(nextOrderDate);
            
            split.billCity = billingAddress.city;
            split.billState = billingAddress.state;
            split.billStreet = billingAddress.street;
            split.billCountry = billingAddress.postalCode;
            split.billCode = billingAddress.postalCode;

            split.shipCity = shippingAddress.city;
            split.shipState = shippingAddress.state;
            split.shipStreet = shippingAddress.street;
            split.shipCode = shippingAddress.postalCode;
            split.shipCountry = shippingAddress.country;

            split.customShippingAddress = this.addressId;
            split.accountShipAddress = this.accShipAddress;
            split.customBillingAddress = this.billAddressId;
            split.accountBillAddress = this.accountBillAddress;
                
            cSplits.push(split);
        })

        console.log('CSPLISTS---',JSON.stringify(cSplits));
        createOpp({parentOpp:this.oppRecord,oppWrappers:cSplits}).then(result=>{
            console.log('Result----',result);
            if(result && result.length>0){
                this.isLoaded = true;
                this.dispatchEvent(new CloseActionScreenEvent());
                this.showToast('Split Created','Split Created Successfully','success')
                this.refreshPage();
            }else{
                this.isLoaded = true;
                this.showToast('Split Created Failure',result,'error');
            }

        }).catch(err=>{
            this.isLoaded = true;
            console.log(err);
            this.showToast('Split Created Failure',err,'error');
            console.log("Error",err);
        })
    }

    formatDate(date){
        //return date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();
        return (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear();
    }

    showToast(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    refreshPage(){
        this.dispatchEvent(new CloseActionScreenEvent());
        if(window && this.recordId) {
            window.location.href='/lightning/r/Opportunity/'+this.recordId+'/view';
        }
    }

    closeAlert(){
        this.showAlert=false;
    }
}