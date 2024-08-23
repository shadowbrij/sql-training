USE AdventureWorks2012;

DECLARE @prodnum int = (select RAND() *10)
UPDATE Production.Product
SET Color = N'Metallic Red'
WHERE product.ProductID % @prodnum =0