/**
 * Created by alaputsky on 9/11/2019.
 */
@isTest
public with sharing class OrderTableControllerTest {
    @testSetup static void setup() {
        Configuration__c config = new Configuration__c(
                Period_Term__c = 10
        );
        insert config;
        config = [
                SELECT Id, Period_Term__c
                FROM Configuration__c
        ];
        Integer periodTerm = Integer.valueOf(config.Period_Term__c);

        Warehouse__c warehouse = new Warehouse__c(Name = 'test');
        insert warehouse;

        List<Product_Table__c> products = new List<Product_Table__c>();
        Product_Table__c product1 = new Product_Table__c(
                Name = 'Iphone',
                Product_Description__c = 'Lorem Ipsum Dolor Sit Amet.',
                Unit_Price__c = 1000,
                Units_Available__c = 10,
                Warehouse__c = warehouse.Id
        );
        products.add(product1);

        Product_Table__c product2 = new Product_Table__c(
                Name = 'Xiaomi',
                Product_Description__c = 'Lorem Ipsum Dolor Sit Amet.',
                Unit_Price__c = 500,
                Units_Available__c = 5,
                Warehouse__c = warehouse.Id
        );
        products.add(product2);
        insert products;

//        List<Contact> contacts = new List<Contact>();
//        Contact newContact = new Contact(
//                FirstName = 'Test',
//                LastName = 'TestP',
//                Email = 'test@test.com');
//        contacts.add(newContact);
        List<Contact> contacts = new List<Contact> {
                new Contact(
                        FirstName = 'Test',
                        LastName = 'TestP',
                        Email = 'test@test.com'
                )
        };
        insert contacts;
    }

    @isTest static void OrderTableControllerTest() {
        List<Product_Table__c> allProducts = new List<Product_Table__c>();
        allProducts = [
                SELECT Id, Name, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
        ];

        Test.startTest();
        PageReference pageReference = Page.OrderTableVF;
        pageReference.getParameters().put('Id', String.valueOf(allProducts[0].Id));
        Test.setCurrentPage(pageReference);

        OrderTableController orderTable = new OrderTableController();
        System.debug('orderTable.productId=== '+orderTable.productId);

        List<Product_Table__c> product = [
                SELECT Id, Name, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
                WHERE Id = :allProducts[0].Id
        ];
        Test.stopTest();

        System.assertEquals(product, orderTable.products);
        System.assertEquals(1, orderTable.products.size());
    }

    @isTest static void redirectBack_Test() {
        List<Product_Table__c> allProducts = new List<Product_Table__c>();
        allProducts = [
                SELECT Id, Name, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
        ];

        Test.startTest();
        OrderTableController orderTable = new OrderTableController();
        orderTable.productId = allProducts[0].Id;

        PageReference pageReference = Page.OrderTableVF;
        pageReference.getParameters().put('Id', String.valueOf(orderTable.productId));
        Test.setCurrentPage(pageReference);
        pageReference = orderTable.redirectBack();

        PageReference pageRefProductTableVF = Page.ProductTableVF;
        Test.stopTest();

        System.assertEquals(pageRefProductTableVF.getUrl(), pageReference.getUrl());
    }

    @isTest static void checkoutWithExistingContactTest() {
        List<Product_Table__c> allProducts = new List<Product_Table__c>();
        allProducts = [
                SELECT Id, Name, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
        ];

        List<Contact> allContacts = new List<Contact>();
        allContacts = [
                SELECT Id, FirstName, LastName, Email
                FROM Contact
        ];

        Test.startTest();
        PageReference pageReference = Page.OrderTableVF;
        pageReference.getParameters().put('Id', String.valueOf(allProducts[0].Id));
        Test.setCurrentPage(pageReference);

        OrderTableController orderTable = new OrderTableController();

        orderTable.FirstName = allContacts[0].FirstName;
        orderTable.LastName = allContacts[0].LastName;
        orderTable.Email = allContacts[0].Email;
        orderTable.quantity = 2;
        orderTable.checkOut();

        Order_Table__c order = [
                SELECT Name, Contact__c, Product__c
                FROM Order_Table__c
                WHERE Product__c = :allProducts[0].Id
        ];
        Test.stopTest();

        System.assertEquals(allContacts[0].Id, order.Contact__c);
    }

    @isTest static void checkoutWithExistingWrongContactTest() {
        List<Product_Table__c> allProducts = new List<Product_Table__c>();
        allProducts = [
                SELECT Id, Name, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
        ];

        List<Contact> allContacts = new List<Contact>();
        allContacts = [
                SELECT Id, FirstName, LastName, Email
                FROM Contact
        ];

        Test.startTest();
        PageReference pageReference = Page.OrderTableVF;
        pageReference.getParameters().put('Id', String.valueOf(allProducts[0].Id));
        Test.setCurrentPage(pageReference);

        OrderTableController orderTable = new OrderTableController();

        orderTable.FirstName = allContacts[0].FirstName;
        orderTable.LastName = '';
        orderTable.Email = allContacts[0].Email;
        orderTable.quantity = 2;
        orderTable.checkOut();

        System.DmlException e = new System.DmlException();
        String message = e.getMessage();
        Test.stopTest();

        System.assertEquals('Script-thrown exception', message);
    }

    @isTest static void checkoutWithNewContactTest() {
        List<Product_Table__c> allProducts = new List<Product_Table__c>();
        allProducts = [
                SELECT Id, Name, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
        ];

        Test.startTest();
        PageReference pageReference = Page.OrderTableVF;
        pageReference.getParameters().put('Id', String.valueOf(allProducts[0].Id));
        Test.setCurrentPage(pageReference);

        OrderTableController orderTable = new OrderTableController();

        orderTable.FirstName = 'New';
        orderTable.LastName = 'Contact';
        orderTable.Email = 'newcontact@test.com';
        orderTable.quantity = 2;
        orderTable.checkOut();

        Contact contact = [
                SELECT Id, Name, Email
                FROM Contact
                WHERE Email = 'newcontact@test.com'
        ];

        Order_Table__c order = [
                SELECT Name, Contact__c, Product__c
                FROM Order_Table__c
                WHERE Product__c = :allProducts[0].Id
        ];
        Test.stopTest();

        System.assertEquals(contact.Id, order.Contact__c);
    }

    @isTest static void checkoutWithWrongContact() {
        List<Product_Table__c> allProducts = new List<Product_Table__c>();
        allProducts = [
                SELECT Id, Name, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
        ];

        Test.startTest();
        PageReference pageReference = Page.OrderTableVF;
        pageReference.getParameters().put('Id', String.valueOf(allProducts[0].Id));
        Test.setCurrentPage(pageReference);

        OrderTableController orderTable = new OrderTableController();

        orderTable.FirstName = 'New';
        orderTable.LastName = '';
        orderTable.Email = 'newcontact@test.com';
        orderTable.quantity = 2;
        orderTable.checkOut();

        System.DmlException e = new System.DmlException();
        String message = e.getMessage();
        Test.stopTest();

        System.assertEquals('Script-thrown exception', message);
    }

    @isTest static void checkoutWithBigQuantityTest() {
        List<Product_Table__c> allProducts = new List<Product_Table__c>();
        allProducts = [
                SELECT Id, Name, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
        ];

        List<Contact> allContacts = new List<Contact>();
        allContacts = [
                SELECT Id, FirstName, LastName, Email
                FROM Contact
        ];

        Test.startTest();
        PageReference pageReference = Page.OrderTableVF;
        pageReference.getParameters().put('Id', String.valueOf(allProducts[0].Id));
        Test.setCurrentPage(pageReference);

        OrderTableController orderTable = new OrderTableController();

        orderTable.FirstName = allContacts[0].FirstName;
        orderTable.LastName = allContacts[0].LastName;
        orderTable.Email = allContacts[0].Email;
        orderTable.quantity = 12;
        orderTable.checkOut();

        String message = ApexPages.getMessages()[0].getDetail();
        Test.stopTest();

        System.assertEquals('Недостаточно товара!', message);
    }

    @isTest static void checkoutWithNegativeQuantityTest() {
        List<Product_Table__c> allProducts = new List<Product_Table__c>();
        allProducts = [
                SELECT Id, Name, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
        ];

        List<Contact> allContacts = new List<Contact>();
        allContacts = [
                SELECT Id, FirstName, LastName, Email
                FROM Contact
        ];

        Test.startTest();
        PageReference pageReference = Page.OrderTableVF;
        pageReference.getParameters().put('Id', String.valueOf(allProducts[0].Id));
        Test.setCurrentPage(pageReference);

        OrderTableController orderTable = new OrderTableController();

        orderTable.FirstName = allContacts[0].FirstName;
        orderTable.LastName = allContacts[0].LastName;
        orderTable.Email = allContacts[0].Email;
        orderTable.quantity = -1;
        orderTable.checkOut();

        String message = ApexPages.getMessages()[0].getDetail();
        Test.stopTest();

        System.assertEquals('ВВедите положительное количество товара!', message);
    }
}