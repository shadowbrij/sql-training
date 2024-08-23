--Cleanup
USE AdventureWorks2014
GO
IF OBJECT_ID('usp_getSalesCustomer') IS NOT NULL
	DROP PROCEDURE dbo.usp_getSalesCustomer;
GO

--Create Proc
USE AdventureWorks2014
GO
CREATE PROCEDURE dbo.usp_getSalesCustomer
AS
BEGIN
CREATE TABLE tempdb.dbo.customer (CustomerID int, 
								  PersonID int, 
								  storeID int, 
								  TerritoryID int, 
								  AccountNumber VARCHAR(10), 
								  rowguid uniqueidentifier, 
								  ModifiedDate datetime)

INSERT INTO tempdb.dbo.customer
SELECT * FROM sales.customer

DROP TABLE tempdb.dbo.customer
END