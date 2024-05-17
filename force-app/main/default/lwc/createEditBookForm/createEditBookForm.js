import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createBook from '@salesforce/apex/bookController.createBook';
import updateBook from '@salesforce/apex/bookController.updateBook';
import getGenrePicklistValues from '@salesforce/apex/bookController.getGenrePicklistValues';
import saveImage from '@salesforce/apex/bookController.saveImage';
import updateImage from '@salesforce/apex/bookController.updateImage';

export default class CreateEditBookForm extends LightningElement {
    // Input properties
    @api recordId;
    @api recordData;
    @api createOperation;
    @api attachmentId;

    // Form fields
    @track title;
    @track author;
    @track genre;
    @track price;
    @track stockQuantity;
    @track soldQuantity;
    @track thumbnail;
    @track Id;
    @track genreOptions;
    @track isEditMode;

    imageUrl;
    showModal = false;
    uploadedFileName;
    // imageId;
    newBookId;
    file;
    imageData;
    
    get saveButtonLabel() {
        return this.createOperation ? 'Save' : 'Update';
    }
    get cardTitle() {
        return this.createOperation ? ' Create New Book Inventory' : 'Edit Book Inventory';
    }

    // Fetch genre picklist values
    @wire(getGenrePicklistValues)
    wiredGenreOptions({ error, data }) {
        if (data) {
            this.genreOptions = data.map(option => ({
                label: option,
                value: option
            }));
        } else if (error) {
            console.error('Error fetching genre picklist values:', error);
        }
    }

    connectedCallback() {       
        if (this.recordData) {           
            if(this.recordData.ImageUrl){
                this.imageUrl =this.recordData.ImageUrl;
                this.uploadedFileName = this.recordData.Book_thumbnail__c ;
                this.thumbnail = this.recordData.ImageUrl || '';
                // this.imageData = btoa(this.imageUrl);               
            }
            // Set field values if editing existing record
            this.Id = this.recordData.Id || null;
            this.title = this.recordData.Title__c || '';
            this.author = this.recordData.Author__c || '';
            this.genre = this.recordData.Genre__c || '';
            this.price = this.recordData.Price__c || 0;
            this.stockQuantity = this.recordData.Availability__c || 0;
            this.soldQuantity = this.recordData.Total_Sales__c || 0;
            // this.thumbnail = this.recordData.ImageUrl || '';
            this.isEditMode = true;
        }
    }     

    // Handle input field change
    handleInputChange(event) {
        const { name, value } = event.target;
        this[name] = value;
    }    

    handleFileInputChange(event) {       
        this.file = event.target.files[0];
        if (this.file) {
            this.uploadedFileName =  this.file.name;
            const reader = new FileReader();
            reader.onload = (event) => {
                this.imageUrl = event.target.result;
                this.imageData = reader.result.split(',')[1]; // Get the Base64 encoded image data              
               
            };
            reader.readAsDataURL(this.file);
        }
    }
    saveAttachment() {    
        // const fileName = this.file.name;    
        saveImage({ parentId: this.newBookId, fileName: this.uploadedFileName, base64Data: this.imageData })
            .then(result => {
                console.log('New book created with Id: ' + result);
                 this.showToast('Success', 'Book created successfully', 'success');
                this.dispatchEvent(new CustomEvent('recordcreated'));
            })
            .catch(error => {
                console.error('Error creating book:', error);
                this.showToast('Error', error.body.message, 'error');
            });
    
    }

    updateAttachment() {
        updateImage({ parentId: this.recordId, attachmentId: this.attachmentId, fileName: this.uploadedFileName, base64Data:this.imageData })
            .then(result => {
                this.dispatchEvent(new CustomEvent('recordupdated'));
                console.log('New book updated with Id: ' + result);
                this.showToast('Success', 'Book updated successfully', 'success');
            })
            .catch(error => {
                console.error('Error updating book:', error);
            });
    }

    openModal() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }
   
  
    // Save or update book
    saveBook() {
        if (this.recordId) {
            // Update existing book
            updateBook({ 
                Id: this.recordId,
                title: this.title,
                author: this.author,
                genre: this.genre,
                price: this.price,
                stockQuantity: this.stockQuantity,
                soldQuantity: this.soldQuantity,
                thumbnail: this.uploadedFileName
            })
            .then(() => {
                console.log('updated book UI ');
                this.updateAttachment();
                
            })
            .catch(error => {
                console.error('Error updating book:', error);
                this.showToast('Error', error.body.message, 'error');
            });
        } else if(this.createOperation){            
            createBook({ 
                title: this.title,
                author: this.author,
                genre: this.genre,
                price: this.price,
                stockQuantity: this.stockQuantity,
                soldQuantity: this.soldQuantity,
                thumbnail: this.uploadedFileName
            })
            .then(newBookId  => {
                console.log('New book created with Id: ' + newBookId);
                this.newBookId = newBookId;
                this.saveAttachment();
            })
            .catch(error => {
                console.error('Error creating book:', error);
                this.showToast('Error', error.body.message, 'error');
            });
        }
    }

    // Cancel operation
    cancel() {
        // Fire event to notify parent component
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    // Show toast message
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }   


}
