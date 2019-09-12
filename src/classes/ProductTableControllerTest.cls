/**
 * Created by alaputsky on 9/10/2019.
 */
@isTest
public with sharing class ProductTableControllerTest {
    @testSetup static void setup() {
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
    }

    @isTest static void ProductTableController() {
        List<Product_Table__c> allProducts = new List<Product_Table__c>();
        allProducts = [
                SELECT Id, Name, Image_Url__c, Product_Description__c, Unit_Price__c
                FROM Product_Table__c
                ORDER BY Name ASC
                LIMIT 100
        ];

        Test.startTest();
        ProductTableController productTable = new ProductTableController();
        Test.stopTest();

        System.assertEquals(allProducts, productTable.productsList);
        System.assertEquals(allProducts.size(), productTable.productsList.size());
    }

    @isTest static void buyTest() {
        List<Product_Table__c> allProducts = new List<Product_Table__c>();
        allProducts = [
                SELECT Id, Name, Image_Url__c, Product_Description__c, Unit_Price__c
                FROM Product_Table__c
        ];

        Test.startTest();
        ProductTableController productTable = new ProductTableController();
        productTable.productId = allProducts[0].Id;

        PageReference pageRef = productTable.buy();
        Test.stopTest();

        System.assertEquals(allProducts[0].Id, pageRef.getParameters().get('Id'));
    }

    @isTest static void redirectBack_Test() {
        List<Product_Table__c> allProducts = new List<Product_Table__c>();
        allProducts = [
                SELECT Id, Name, Image_Url__c, Product_Description__c, Unit_Price__c
                FROM Product_Table__c
        ];

        Test.startTest();
        ProductTableController productTable = new ProductTableController();
        productTable.productId = allProducts[0].Id;

        PageReference pageReference = Page.OrderTableVF;
        pageReference.getParameters().put('Id', String.valueOf(productTable.productId));
        Test.setCurrentPage(pageReference);
        pageReference = productTable.redirectBack();

        PageReference pageRefProductTableVF = Page.ProductTableVF;
        Test.stopTest();

        System.assertEquals(pageRefProductTableVF.getUrl(), pageReference.getUrl());
    }
}