/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
private class bookControllerTest {

    @isTest
    static void testFetchData() {
        // Test data setup
        List<Book_Inventory__c> testBooks = new List<Book_Inventory__c>();
        for(Integer i = 0; i < 5; i++) {
            testBooks.add(new Book_Inventory__c(
                Title__c = 'Test Book ' + i,
                Author__c = 'Test Author',
                Genre__c = 'Fiction',
                Price__c = 20.00,
                Availability__c = 10,
                Total_Sales__c = 5,
                Book_thumbnail__c = 'Test Thumbnail'
            ));
        }
        insert testBooks;

        // Call the fetchData method
        Test.startTest();
        bookController.BookInventoryWrapper result = bookController.fetchData(1, 5);
        Test.stopTest();

        // Assertions
        System.assertEquals(5, result.records.size(), 'Number of records should match the pageSize');
        System.assertNotEquals(null, result.totalRecords, 'Total records should not be null');
    }

    @isTest
    static void testGetGenrePicklistValues() {
        Test.startTest();
        List<String> picklistValues = bookController.getGenrePicklistValues();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, picklistValues, 'Picklist values should not be null');
    }

    @isTest
    static void testCreateBook() {
        Test.startTest();
        bookController.createBook('Test Book', 'Test Author', 'Fiction', 20.00, 10, 5, 'Test Thumbnail');
        Test.stopTest();

        Book_Inventory__c createdBook = [SELECT Id FROM Book_Inventory__c WHERE Title__c = 'Test Book' LIMIT 1];
        System.assertNotEquals(null, createdBook, 'Created book should not be null');
    }

    @isTest
    static void testUpdateBook() {
        Book_Inventory__c testBook = new Book_Inventory__c(
            Title__c = 'Test Book',
            Author__c = 'Test Author',
            Genre__c = 'Fiction',
            Price__c = 20.00,
            Availability__c = 10,
            Total_Sales__c = 5,
            Book_thumbnail__c = 'Test Thumbnail'
        );
        insert testBook;

        Test.startTest();
        bookController.updateBook(testBook.Id, 'Updated Test Book', 'Updated Test Author', 'Non-Fiction', 25.00, 15, 10, 'Updated Test Thumbnail');
        Test.stopTest();

        Book_Inventory__c updatedBook = [SELECT Id, Title__c, Author__c, Genre__c, Price__c, Availability__c, Total_Sales__c, Book_thumbnail__c FROM Book_Inventory__c WHERE Id = :testBook.Id LIMIT 1];
        System.assertEquals('Updated Test Book', updatedBook.Title__c, 'Title should be updated');
        System.assertEquals('Updated Test Author', updatedBook.Author__c, 'Author should be updated');
        System.assertEquals('Non-Fiction', updatedBook.Genre__c, 'Genre should be updated');
        System.assertEquals(25.00, updatedBook.Price__c, 'Price should be updated');
        System.assertEquals(15, updatedBook.Availability__c, 'Availability should be updated');
        System.assertEquals(10, updatedBook.Total_Sales__c, 'Total Sales should be updated');
        System.assertEquals('Updated Test Thumbnail', updatedBook.Book_thumbnail__c, 'Thumbnail should be updated');
    }

     @isTest
    static void testFetchDataException() {
        Test.startTest();
        bookController.BookInventoryWrapper result = bookController.fetchData(-1, 5); // Invalid pageNumber
        Test.stopTest();

        // Assertions
        System.assertEquals(null, result, 'Result should be null as an exception is expected');
    }

    @isTest
    static void testGetGenrePicklistValuesException() {
        Test.startTest();
        List<String> picklistValues = bookController.getGenrePicklistValues(); 
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, picklistValues, 'Picklist values should not be null under normal operation');
    }

    @isTest
    static void testCreateBookException() {
        Test.startTest();
        try {
            bookController.createBook(null, 'Test Author', 'Fiction', 20.00, 10, 5, 'Test Thumbnail'); // Null title
        } catch(Exception e) {
            System.assertEquals('Title is required', e.getMessage(), 'Exception message should indicate missing title');
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateBookException() {
        Test.startTest();
        try {
            bookController.updateBook('invalidId', 'Updated Test Book', 'Updated Test Author', 'Non-fiction', 25.00, 15, 10, 'Updated Test Thumbnail'); // Invalid Id
        } catch(Exception e) {
            System.assertEquals('Invalid book Id', e.getMessage(), 'Exception message should indicate invalid book Id');
        }
        Test.stopTest();
    }

    @isTest 
    static void testFetchDataWithAttachments() {
        // Create test data
        List<Book_Inventory__c> bookInventoryList = new List<Book_Inventory__c>();
        for(Integer i = 0; i < 5; i++) {
            Book_Inventory__c book = new Book_Inventory__c(
                Title__c = 'Book ' + i,
                Author__c = 'Author ' + i,
                Genre__c = 'Mystery',
                Price__c = 10.00,
                Availability__c = 10,
                Total_Sales__c = 0,
                Book_thumbnail__c = 'Thumbnail ' + i,
                Status__c = 'Approved'
            );
            bookInventoryList.add(book);
        }
        insert bookInventoryList;
        
        // Create attachments for each book record
        List<Attachment> attachments = new List<Attachment>();
        for(Book_Inventory__c book : bookInventoryList) {
            Attachment attachment = new Attachment(
                ParentId = book.Id,
                Name = 'Test Attachment',
                Body = Blob.valueOf('Test attachment body'),
                ContentType = 'text/plain'
            );
            attachments.add(attachment);
        }
        insert attachments;
        
        Test.startTest();
        // Call the fetchDataWithAttachments method
        List<bookController.CustomObjectWithAttachments> results = bookController.fetchDataWithAttachments(1, 5);
        
        // Assert that the results are not null
        System.assertNotEquals(null, results);
        
        // Assert that the number of records returned matches the expected number
        System.assertEquals(5, results.size());
        
        // Assert that each result contains the expected number of attachments
        for(bookController.CustomObjectWithAttachments result : results) {
            System.assertEquals(1, result.attachments.size());
        }
        
        Test.stopTest();
    
    }
    @isTest
    static void testSaveImage() {
        // Create test data
        Book_Inventory__c book = new Book_Inventory__c(
            Title__c = 'Test Book',
            Author__c = 'Test Author',
            Genre__c = 'Mystery',
            Price__c = 10.00,
            Availability__c = 10,
            Total_Sales__c = 0,
            Book_thumbnail__c = 'Test Thumbnail'
        );
        insert book;
        
        // Call the saveImage method with test data
        Test.startTest();
        bookController.saveImage(book.Id, 'Test Image', 'base64encodedstring');
        Test.stopTest();
        
        // Retrieve the attachment created by saveImage method
        Attachment[] attachments = [SELECT Id, ParentId, Name, Body FROM Attachment WHERE ParentId = :book.Id];
        
        // Assert that the attachment is created
        System.assertEquals(1, attachments.size());
        // Assert attachment name
        System.assertEquals('Test Image', attachments[0].Name);
    }
    
    @isTest static void testUpdateImage() {
        // Create test data
        Book_Inventory__c book = new Book_Inventory__c(
            Title__c = 'Test Book',
            Author__c = 'Test Author',
            Genre__c = 'Mystery',
            Price__c = 10.00,
            Availability__c = 10,
            Total_Sales__c = 0,
            Book_thumbnail__c = 'Test Thumbnail'
        );
        insert book;
        
        // Create attachment for the book
        Attachment attachment = new Attachment(
            ParentId = book.Id,
            Name = 'Old Image',
            Body = Blob.valueOf('Old Image Body'),
            ContentType = 'image/jpeg'
        );
        insert attachment;
        
        // Call the updateImage method with test data
        Test.startTest();
        bookController.updateImage(book.Id, attachment.Id, 'New Image', 'newbase64encodedstring');
        Test.stopTest();
        
        // Retrieve the updated attachment
        Attachment updatedAttachment = [SELECT Id, ParentId, Name, Body FROM Attachment WHERE ParentId = :book.Id];
        
        // Assert that the attachment is updated
        System.assertEquals('New Image', updatedAttachment.Name);
    }
}




