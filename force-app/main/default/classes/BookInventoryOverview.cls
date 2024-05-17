public with sharing class BookInventoryOverview {
    @AuraEnabled(cacheable=true)
    public static List<BookInventoryData> fetchData() {
        List<BookInventoryData> result = new List<BookInventoryData>();
        try {
            List<Book_Inventory__c> records = [SELECT Id, Title__c, Author__c, Genre__c, Price__c, Status__c, Availability__c, Total_Sales__c FROM Book_Inventory__c WHERE Title__c != null];
            for (Book_Inventory__c record : records) {
                result.add(new BookInventoryData(
                    record.Id,
                    record.Title__c,
                    record.Author__c,
                    record.Genre__c,
                    record.Price__c,
                    record.Status__c,
                    record.Availability__c,
                    record.Total_Sales__c
                ));
            }
        } catch (Exception ex) {
            system.debug('Exception while fetching data: ' + ex.getMessage());
        }
        return result;
    }

    public class BookInventoryData {
        @AuraEnabled public Id recordId { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String author { get; set; }
        @AuraEnabled public String genre { get; set; }
        @AuraEnabled public Decimal price { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Decimal availability { get; set; }
        @AuraEnabled public Decimal totalSales { get; set; }

        public BookInventoryData(Id recordId, String title, String author, String genre, Decimal price, String status, Decimal availability, Decimal totalSales) {
            this.recordId = recordId;
            this.title = title;
            this.author = author;
            this.genre = genre;
            this.price = price;
            this.status = status;
            this.availability = availability;
            this.totalSales = totalSales;
        }
    }
}
