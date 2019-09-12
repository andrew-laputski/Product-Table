/**
 * Created by alaputsky on 9/9/2019.
 */

public with sharing class OrderTableController {

    public List <Product_Table__c> products { get; set; }
    public List <Contact> contacts { get; set; }
    public String productId { get; set; }
    public String FirstName { get; set; }
    public String LastName { get; set; }
    public String Email { get; set; }
    public Integer quantity { get; set; }

    public OrderTableController() {
        productId = ApexPages.currentPage().getParameters().get('Id');
        products = [
                SELECT Id, Name, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
                WHERE Id = :productId
        ];
    }

    public PageReference redirectBack() {
        PageReference pageRef = Page.ProductTableVF;
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void checkOut() {
        contacts = [
                SELECT Email, FirstName, LastName
                FROM Contact
                WHERE Email = :Email
        ];

        if(contacts.isEmpty()) {
            Contact newContact = new Contact(
                    FirstName = FirstName,
                    LastName = LastName,
                    Email = Email);
            contacts.add(newContact);
        } else {
            for (Integer i = 0; i < contacts.size(); i++) {
                contacts[i].FirstName = FirstName;
                contacts[i].LastName = LastName;
            }
        }
        try {
            upsert contacts;
        } catch (DmlException ex) {
            return;
        }

        insertOrder();
    }

    public void insertOrder() {
        Decimal Order_Amount = (quantity * products[0].Unit_Price__c);
        Order_Table__c  order = new Order_Table__c (
                Contact__c = contacts[0].Id,
                Product__c = productId,
                Units__c = quantity,
                Order_Amount__c = Order_Amount);

        products[0].Units_Available__c = products[0].Units_Available__c - Decimal.valueOf(quantity);

        Savepoint sp = Database.setSavepoint();
        try {
            insert order;
        } catch (DmlException ex) {
            return;
        }

        if(quantity > 0) {
            if (products[0].Units_Available__c >= 0) {
                update products;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Заказ принят!'));
            } else {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Недостаточно товара!'));
            }
        } else {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'ВВедите положительное количество товара!'));
        }
    }
}