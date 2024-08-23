USE AdventureWorks2012;

UPDATE Sales.SalesPerson
SET Bonus = 6000, CommissionPct = .10, SalesQuota = NULL
where SalesPerson.BusinessEntityID % 11 = 0 ;
