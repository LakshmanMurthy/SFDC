public with sharing class bookController {
    @AuraEnabled(cacheable=true)
    public static BookInventoryWrapper fetchData(Integer pageNumber, Integer pageSize) {
        try{
                BookInventoryWrapper result = new BookInventoryWrapper();

                // Query records based on pageNumber and pageSize
                Integer offset = (pageNumber - 1) * pageSize;
                List<Book_Inventory__c> records = [SELECT Title__c, Author__c, Genre__c, Price__c, Availability__c, Total_Sales__c,Book_thumbnail__c,Image__c FROM Book_Inventory__c where Title__c!= null  order by createddate DESC LIMIT:pageSize OFFSET :offset ];

                result.records = records;
                result.totalRecords = [SELECT COUNT() FROM Book_Inventory__c];

                return result;
            }catch (exception ex){
                system.debug('exception while fetchData  =>>'+ ex.getMessage());
                return null;            
            }
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getGenrePicklistValues() {
        try{
            List<String> picklistValues = new List<String>();
            Schema.DescribeFieldResult fieldResult = Book_Inventory__c.Genre__c.getDescribe();
            for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                picklistValues.add(entry.getLabel());
            }
            return picklistValues;
        }catch (exception ex){
            system.debug('exception while getGenrePicklistValues =>>'+ ex.getMessage());
            return null;       
        }
    }


    @AuraEnabled
    public static Id  createBook(String title, String author, String genre, Decimal price, Integer stockQuantity, Integer soldQuantity, String thumbnail) {
        Id newBookId;
        system.debug('createBook');
        // system.debug(imageId);
        try{
                Book_Inventory__c newBook = new Book_Inventory__c(
                    Title__c = title,
                    Author__c = author,
                    Genre__c = genre,
                    Price__c = price,
                    Availability__c = stockQuantity,
                    Total_Sales__c = soldQuantity,
                    Book_thumbnail__c = thumbnail
                );
                insert newBook;
                system.debug('createBook');
                system.debug(newBook);
                newBookId = newBook.Id;
            }catch (exception ex){
                system.debug('exception while create book =>>'+ ex.getMessage());
            }
            return newBookId;
    }
    @AuraEnabled
    public static void updateBook(String Id, String title, String author, String genre, Decimal price, Integer stockQuantity, Integer soldQuantity, String thumbnail) {
        try{
            system.debug('updateBook 1');
                Book_Inventory__c bookToUpdate = new Book_Inventory__c(
                    Id = Id,
                    Title__c = title,
                    Author__c = author,
                    Genre__c = genre,
                    Price__c = price,
                    Availability__c = stockQuantity,
                    Total_Sales__c = soldQuantity,
                    Book_thumbnail__c = thumbnail
                );
                system.debug('updateBook 2');
                update bookToUpdate;
            }catch (exception ex){
                system.debug('exception while update book =>>'+ ex.getMessage());
            }
    }

    @AuraEnabled
    public static void saveImage(Id parentId, String fileName, String base64Data) {
        system.debug('createBook image');
        system.debug(base64Data);
        Attachment attachment = new Attachment();
        attachment.ParentId = parentId; // ParentId should be the Id of the custom object record
        attachment.Name = fileName;
        attachment.Body = EncodingUtil.base64Decode(base64Data);
        attachment.ContentType = 'image/jpeg'; // Adjust content type if needed
        insert attachment;
        system.debug('createBook image');
        system.debug(attachment);
    }
    
    @AuraEnabled
    public static void updateImage(Id parentId, Id attachmentId, String fileName, String base64Data) {
        // Query the Attachment record
        system.debug('createBupdateImageook image');
        system.debug(attachmentId);
        system.debug(parentId);
        system.debug(fileName);
        system.debug(base64Data);
        Attachment attachment = [SELECT Id, ParentId, Name, Body, ContentType FROM Attachment WHERE ParentId = :parentId LIMIT 1];
        
        // Id = :attachmentId and
        // Update the fields
        attachment.Name = fileName;
        attachment.Body = EncodingUtil.base64Decode(base64Data);
        // If needed, you can also update other fields like ContentType
        
        // Update the Attachment record
        system.debug('updateImage image');
        update attachment;
    }
   
    @AuraEnabled(cacheable=true)
    public static List<CustomObjectWithAttachments> fetchDataWithAttachments(Integer pageNumber, Integer pageSize) {
        try {
            system.debug('results');
            List<CustomObjectWithAttachments> results = new List<CustomObjectWithAttachments>();

            // Query records based on pageNumber and pageSize
            Integer offset = (pageNumber - 1) * pageSize;
            List<Book_Inventory__c> records = [SELECT Id, Title__c, Author__c, Genre__c, Price__c, Availability__c, Total_Sales__c, Book_thumbnail__c, Image__c 
                                                FROM Book_Inventory__c 
                                                WHERE Title__c != null and Status__c ='Approved'
                                                ORDER BY CreatedDate DESC 
                                                LIMIT :pageSize 
                                                OFFSET :offset];
            
            for (Book_Inventory__c record : records) {
                CustomObjectWithAttachments result = new CustomObjectWithAttachments();
                result.customObjectRecord = record;
                result.totalRecords = [SELECT COUNT() FROM Book_Inventory__c];
                // Fetch attachments related to the custom object record
                List<Attachment> attachments = [SELECT Id, Name, ContentType, BodyLength FROM Attachment WHERE ParentId = :record.Id];
                // Attachment attachment = [SELECT Id, Name, ContentType, BodyLength FROM Attachment WHERE ParentId = :record.Id];
                // result.attachment = attachment;
                result.attachments = attachments;
                results.add(result);
            }
            system.debug('results');
            system.debug(results);
            return results;
        } catch (Exception ex) {
            system.debug('Exception while fetchDataWithAttachments => ' + ex.getMessage());
            return null;
        }
    }
    
    // Wrapper class to hold both custom object record and its related attachments
    public class CustomObjectWithAttachments {
        @AuraEnabled
        public Book_Inventory__c customObjectRecord { get; set; }        
        @AuraEnabled
        public List<Attachment> attachments { get; set; }
        @AuraEnabled 
        public Integer totalRecords { get; set; }
    }

    public class BookInventoryWrapper {
        @AuraEnabled public List<Book_Inventory__c> records { get; set; }
        @AuraEnabled public Integer totalRecords { get; set; }
    }
}
