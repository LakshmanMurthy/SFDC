public with sharing class InventoryController {
    
    // Method to fetch inventory data
    @AuraEnabled(cacheable=true)
    public static InventoryDataWrapper fetchInventoryData() {
        InventoryDataWrapper result = new InventoryDataWrapper();
        
        // Query to fetch total book count
        result.totalBookCount = [SELECT COUNT() FROM Book_Inventory__c];
        
        // Query to fetch available stock count
        AggregateResult availableStockResult = [SELECT SUM(Availability__c) FROM Book_Inventory__c];
        if (availableStockResult != null && availableStockResult.get('expr0') != null) {
            result.availableStock = (Decimal)availableStockResult.get('expr0');
        }
        
        // Query to fetch sales performance data
        AggregateResult salesPerformanceResult = [SELECT SUM(Total_Sales__c) FROM Book_Inventory__c];
        if (salesPerformanceResult != null && salesPerformanceResult.get('expr0') != null) {
            result.salesPerformance = (Decimal)salesPerformanceResult.get('expr0');
        }
        
        return result;
    }
    
    // Wrapper class to hold inventory data
    public class InventoryDataWrapper {
        @AuraEnabled public Integer totalBookCount { get; set; }
        @AuraEnabled public Decimal availableStock { get; set; }
        @AuraEnabled public Decimal salesPerformance { get; set; }
    }
}
