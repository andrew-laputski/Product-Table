/**
 * Created by alaputsky on 9/4/2019.
 */

public class AssignProductToWarehouseTriggerHandler {

    public static List<Product_Table__c> productAssignment(List<Product_Table__c> createdAndUpdatedProducts) {

        List<Warehouse__c> warehouses = new List<Warehouse__c>();
        List<Warehouse__c> newWarehouses = new List<Warehouse__c>();

        warehouses = [
                SELECT Id, Name, Period_Start__c, Period_End__c
                FROM Warehouse__c
        ];

        for (Product_Table__c product : createdAndUpdatedProducts) {
            if(product.Added_Date__c == null) {
                product.Added_Date__c = Date.today();
            }
        }

        for (Product_Table__c product : createdAndUpdatedProducts) {
            if(product.Warehouse__c == null) {
                if (warehouses.isEmpty()) {
                    newWarehouses.add(createWarehouse(product));
                }
                for (Warehouse__c warehouse : warehouses) {
                    if (warehouse.Period_Start__c <= product.Added_Date__c && warehouse.Period_End__c >= product.Added_Date__c) {
                        product.Warehouse__c = warehouse.Id;
                        break;
                    } else {
                        newWarehouses.add(createWarehouse(product));
                    }
                }
            }
        }

        if(newWarehouses != null) {
            insert newWarehouses;
            for (Product_Table__c product : createdAndUpdatedProducts) {
                for (Warehouse__c warehouse : newWarehouses) {
                    if (warehouse.Period_Start__c <= product.Added_Date__c && warehouse.Period_End__c >= product.Added_Date__c) {
                        product.Warehouse__c = warehouse.Id;
                    }
                }
            }
        }

        return createdAndUpdatedProducts;
    }

    private static Warehouse__c createWarehouse(Product_Table__c product) {
        Integer periodTerm = 0;
        Configuration__c config = [
                SELECT Id, Period_Term__c
                FROM Configuration__c
        ];

        if(config != null) {
            periodTerm = Integer.valueOf(config.Period_Term__c);
        }

        Warehouse__c newWarehouse = new Warehouse__c(
                Name = 'Warehouse' + product.Added_Date__c + ' ' + product.Added_Date__c.addDays(periodTerm),
                Period_Start__c = product.Added_Date__c,
                Period_End__c = product.Added_Date__c.addDays(periodTerm)
        );

        return newWarehouse;
    }

}