@isTest
public class BookTriggerHandlerTest {
    
    @isTest
    static void testBeforeInsert_PublishedDateAutoSet() {
        // Test that Published_Date__c is automatically set to today when null
        Test.startTest();
        
        Book__c book = new Book__c(
            Name = 'The Great Adventure',
            Author__c = 'John Doe'
            // Published_Date__c is intentionally left null
        );
        
        insert book;
        
        Test.stopTest();
        
        // Verify Published_Date__c was set to today
        Book__c insertedBook = [SELECT Id, Published_Date__c FROM Book__c WHERE Id = :book.Id];
        System.assertEquals(Date.today(), insertedBook.Published_Date__c, 'Published Date should be set to today when null');
    }
    
    @isTest
    static void testBeforeInsert_PublishedDateNotOverridden() {
        // Test that existing Published_Date__c is not overridden
        Date customDate = Date.newInstance(2020, 5, 15);
        
        Test.startTest();
        
        Book__c book = new Book__c(
            Name = 'Classic Novel',
            Author__c = 'Jane Smith',
            Published_Date__c = customDate
        );
        
        insert book;
        
        Test.stopTest();
        
        // Verify Published_Date__c was not changed
        Book__c insertedBook = [SELECT Id, Published_Date__c FROM Book__c WHERE Id = :book.Id];
        System.assertEquals(customDate, insertedBook.Published_Date__c, 'Existing Published Date should not be overridden');
    }
    
    @isTest
    static void testBeforeInsert_BulkInsertMixed() {
        // Test bulk insert with mix of null and non-null Published_Date__c
        Date customDate1 = Date.newInstance(2019, 3, 10);
        Date customDate2 = Date.newInstance(2021, 8, 22);
        
        List<Book__c> books = new List<Book__c>();
        
        // Book with null Published_Date__c
        books.add(new Book__c(
            Name = 'Book 1',
            Author__c = 'Author 1'
        ));
        
        // Book with specific Published_Date__c
        books.add(new Book__c(
            Name = 'Book 2',
            Author__c = 'Author 2',
            Published_Date__c = customDate1
        ));
        
        // Book with null Published_Date__c
        books.add(new Book__c(
            Name = 'Book 3',
            Author__c = 'Author 3'
        ));
        
        // Book with specific Published_Date__c
        books.add(new Book__c(
            Name = 'Book 4',
            Author__c = 'Author 4',
            Published_Date__c = customDate2
        ));
        
        Test.startTest();
        
        insert books;
        
        Test.stopTest();
        
        // Verify results
        List<Book__c> insertedBooks = [SELECT Id, Name, Published_Date__c FROM Book__c ORDER BY Name];
        
        System.assertEquals(4, insertedBooks.size(), 'Should have 4 books');
        System.assertEquals(Date.today(), insertedBooks[0].Published_Date__c, 'Book 1 should have today\'s date');
        System.assertEquals(customDate1, insertedBooks[1].Published_Date__c, 'Book 2 should retain custom date');
        System.assertEquals(Date.today(), insertedBooks[2].Published_Date__c, 'Book 3 should have today\'s date');
        System.assertEquals(customDate2, insertedBooks[3].Published_Date__c, 'Book 4 should retain custom date');
    }
    
    @isTest
    static void testBeforeInsert_NullOrEmptyList() {
        // Test that handler gracefully handles null/empty list
        Test.startTest();
        
        // Call handler directly with null
        BookTriggerHandler.beforeInsert(null);
        
        // Call handler with empty list
        BookTriggerHandler.beforeInsert(new List<Book__c>());
        
        Test.stopTest();
        
        // If we reach here without exceptions, the test passes
        System.assert(true, 'Handler should handle null/empty list without errors');
    }
    
    @isTest
    static void testBeforeInsert_LargeBulkInsert() {
        // Test bulk insert with 200 records
        List<Book__c> books = new List<Book__c>();
        
        for (Integer i = 1; i <= 200; i++) {
            Book__c book = new Book__c(
                Name = 'Bulk Book ' + i,
                Author__c = 'Author ' + i
            );
            
            // Every 3rd book gets a custom date
            if (Math.mod(i, 3) == 0) {
                book.Published_Date__c = Date.today().addDays(-i);
            }
            
            books.add(book);
        }
        
        Test.startTest();
        
        insert books;
        
        Test.stopTest();
        
        // Verify all books were inserted
        List<Book__c> insertedBooks = [SELECT Id, Published_Date__c FROM Book__c];
        System.assertEquals(200, insertedBooks.size(), 'Should have 200 books');
        
        // Verify all have a Published_Date__c
        for (Book__c book : insertedBooks) {
            System.assertNotEquals(null, book.Published_Date__c, 'All books should have a Published Date');
        }
    }
}