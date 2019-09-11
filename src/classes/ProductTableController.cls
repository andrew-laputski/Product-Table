/**
 * Created by alaputsky on 9/9/2019.
 */

public with sharing class ProductTableController {

    public List <Product_Table__c> productsList { get; set; }
    public List <Product_Table__c> productInfo { get; set; }
    public String productId { get;set; }

    public ProductTableController() {
        productId = ApexPages.currentPage().getParameters().get('Id');
        productsList = [
                SELECT Id, Name, Image_Url__c, Product_Description__c, Unit_Price__c
                FROM Product_Table__c
                ORDER BY Name ASC
                LIMIT 100
        ];
        productInfo = [
                SELECT Id, Name, Image_Url__c, Product_Description__c, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
                WHERE Id = :productId
        ];
    }

    public PageReference buy() {
        PageReference pageRef = Page.OrderTableVF;
        pageRef.getParameters().put('Id', productId);
        pageRef.setRedirect(true);

        return pageRef;
    }

    public PageReference redirectBack() {
        PageReference pageRef = Page.ProductTableVF;
        pageRef.setRedirect(true);

        return pageRef;
    }

}