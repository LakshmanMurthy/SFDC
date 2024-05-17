@isTest
private class BookInventoryOverviewTest {
    @isTest static void testFetchData() {
        // Create test data
        Book_Inventory__c book1 = new Book_Inventory__c(
            Title__c = 'Test Book 1',
            Author__c = 'Test Author 1',
            Genre__c = 'Fiction',
            Price__c = 10.00,
            Status__c = 'Pending',
            Availability__c = 10,
            Total_Sales__c = 0
        );
        Book_Inventory__c book2 = new Book_Inventory__c(
            Title__c = 'Test Book 2',
            Author__c = 'Test Author 2',
            Genre__c = 'Fiction',
            Price__c = 20.00,
            Status__c = 'Pending',
            Availability__c = 5,
            Total_Sales__c = 2
        );
        insert new List<Book_Inventory__c>{book1, book2};

        Test.startTest();
        // Call the fetchData method
        List<BookInventoryOverview.BookInventoryData> result = BookInventoryOverview.fetchData();
        Test.stopTest();

        // Assert that the result is not null
        System.assertNotEquals(null, result);

        // Assert that the correct number of records is returned
        System.assertEquals(2, result.size());

        // Assert the values of the first record
        System.assertEquals(book1.Id, result[0].recordId);
        System.assertEquals('Test Book 1', result[0].title);
        System.assertEquals('Test Author 1', result[0].author);
        System.assertEquals('Fiction', result[0].genre);
        System.assertEquals(10.00, result[0].price);
        System.assertEquals(10, result[0].availability);
        System.assertEquals(0, result[0].totalSales);

        // Assert the values of the second record
        System.assertEquals(book2.Id, result[1].recordId);
        System.assertEquals('Test Book 2', result[1].title);
        System.assertEquals('Test Author 2', result[1].author);
        System.assertEquals('Fiction', result[1].genre);
        System.assertEquals(20.00, result[1].price);
        System.assertEquals(5, result[1].availability);
        System.assertEquals(2, result[1].totalSales);
    }
}
