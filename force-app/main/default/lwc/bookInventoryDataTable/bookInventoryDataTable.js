import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import fetchDataWithAttachments from '@salesforce/apex/bookController.fetchDataWithAttachments';
import CustomImage from 'c/customImage';

const PAGE_SIZE = 10;
// data = [];
const columns = [
    { label: 'S.No', type: 'text', fieldName: 'rowNumber' },
    { label: 'Title', fieldName: 'Title__c', type: 'text' },
        { label: 'Author', fieldName: 'Author__c', type: 'text'},
        { label: 'Genre', fieldName: 'Genre__c' },
        { label: 'Price', fieldName: 'Price__c', type: 'currency' },
        { label: 'Availabe Quantity', fieldName: 'Availability__c', type: 'number' },
        { label: 'Sold Out Quantity', fieldName: 'Total_Sales__c', type: 'number' },        
        { label: 'Image', fieldName: 'ImageUrl', type: 'image'},
        { label: 'Action', type: 'button', initialWidth: 100, typeAttributes: { label: 'Edit', variant: 'brand',name: 'edit' },actions: [{ name: 'edit' }] }
];
// iconName: 'utility:edit',
export default class BookInventoryDataTable extends LightningElement {
    @track bookInventoryData = [];
    @track currentPage = 1;
    @track totalRecords = 0;
    @track refreshDataFlag = false;
    @track isEditModalOpen = false;
    @track showCreateModal = false;
    @track recordData = {};
    @track selectedRecordId;
    @track createOperation;
    @track attachmentId;
    @track refreshrecords
    get columns() {
        return columns;
    }
    // connectedCallback(){
    //     this.pageload();
    // }
    // , refreshDataFlag: '$refreshDataFlag'
    // pageload(){
        @wire(fetchDataWithAttachments, { pageNumber: '$currentPage', pageSize: PAGE_SIZE, refreshDataFlag: '$refreshDataFlag'})
        wiredDataWithAttachments({ error, data }) {
            if (data) {    
                this.refreshrecords = data;
                console.log('One');
                const startIndex = (this.currentPage - 1) * PAGE_SIZE + 1;
                this.bookInventoryData = data.map((record, index) => {
                    this.totalRecords = record.totalRecords;
                    const attachmentsArray = JSON.parse(JSON.stringify(record.attachments));
                    this.attachmentId = attachmentsArray[0]?.Id;
                    const imageUrl = record.attachments && record.attachments.length > 0 ? 
                         `${window.location.origin}/servlet/servlet.FileDownload?file=${record.attachments[0].Id}` : 
                         null;    
                         console.log('Two');          
                    return { ...record.customObjectRecord, rowNumber: startIndex + index, 
                        ImageUrl: imageUrl,
                     };
                   
                });
            } else if (error) {
                console.error('Error fetching data:', error);
            }
        }
    // }
   

       
    get isPrevDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage * PAGE_SIZE >= this.totalRecords;
    }

    handlePrev() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    handleNext() {
        if (!this.isNextDisabled) {
            this.currentPage++;
        }
    }

    openCreateBookModal() {
        this.showCreateModal = true;
        this.createOperation = true;
        this.recordData = [];
    }

    closeCreateBookModal() {
        this.showCreateModal = false;
    }   

    handleBookCreated() {
        this.closeCreateBookModal();
        this.handleRefresh() ;
       this.refreshData();
       console.log('this.refreshDataFlag');
       console.log(this.refreshDataFlag);
        
    }

    refreshData() {
        // this.refreshDataFlag = true; 
        this.refreshDataFlag = !this.refreshDataFlag;
    }
    
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'edit') {    
            this.selectedRecordId = row.Id;
            this.recordData  = row;
            // Open the modal
            this.showCreateModal = true;           
            this.createOperation = false;
        } else {
            console.error('Invalid row data:', row);
        }
    }
   
    handleRecordUpdated() {
        this.handleRefresh() ;
        this.closeCreateBookModal();
        this.refreshData();
        console.log('update parent method');
    }

    handleRefresh() {
        // return refreshApex(this.bookInventoryData);
        // this.currentPage = 1; // Reset current page
        // refreshApex(this.wiredDataWithAttachments);
    }

    
}
