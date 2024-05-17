import { LightningElement, track } from 'lwc';
import fetchInventoryData from '@salesforce/apex/InventoryController.fetchInventoryData';

export default class InventoryDashboard extends LightningElement {
    @track totalBookCount;
    @track availableStock;
    @track salesPerformance;

    connectedCallback() {
        this.fetchData();
    }

    fetchData() {
        fetchInventoryData()
            .then(result => {
                // Process the fetched data and update component state
                this.totalBookCount = result.totalBookCount;
                this.availableStock = result.availableStock;
                this.salesPerformance = result.salesPerformance;
            })
            .catch(error => {
                console.error('Error fetching inventory data:', error);
            });
    }
}
