import { LightningElement, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import Chart from '@salesforce/resourceUrl/chart';

import fetchData from '@salesforce/apex/BookInventoryOverview.fetchData';

export default class BarChart extends LightningElement {
    chart;

    renderedCallback() {
        if (this.chart) {
            return;
        }

        loadScript(this, Chart)
            .then(() => {
                const ctx = this.template.querySelector('canvas.bar-chart').getContext('2d');
                this.chart = new window.Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: [],
                        datasets: [{
                            label: 'Total Sales',
                            backgroundColor: 'blue',
                            borderColor: 'blue',
                            borderWidth: 1,
                            data: []
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            yAxes: [{
                                ticks: {
                                    beginAtZero: true
                                }
                            }]
                        }
                    }
                });

                this.loadData();
            })
            .catch(error => {
                console.error('Error loading Chart.js:', error);
            });
    }

    @wire(fetchData)
    wiredData({ error, data }) {
        if (data) {
            const labels = [];
            const salesData = [];

            data.forEach(item => {
                labels.push(item.title);
                salesData.push(item.totalSales);
            });

            this.chart.data.labels = labels;
            this.chart.data.datasets[0].data = salesData;
            this.chart.update();
        } else if (error) {
            console.error('Error fetching data:', error);
        }
    }

    loadData() {
        fetchData()
            .then(result => {
                this.wiredData({ data: result });
            })
            .catch(error => {
                console.error('Error fetching data:', error);
            });
    }
}
