USE [master]
GO
ALTER DATABASE [AdventureWorks2012]
ADD FILE ( NAME = N'AdventureWorks2012_Data_2', FILENAME = N'M:\Data\AdventureWorks2012_Data_2.ndf' , SIZE = 20GB , FILEGROWTH = 10%)
GO

USE [master]
GO
ALTER DATABASE [AdventureWorks2012]
ADD FILE ( NAME = N'AdventureWorks2012_Data_3', FILENAME = N'M:\Data\AdventureWorks2012_Data_3.ndf' , SIZE = 20GB , FILEGROWTH = 10%)
GO

USE [master]
GO
ALTER DATABASE [AdventureWorks2012]
ADD FILE ( NAME = N'AdventureWorks2012_Data_4', FILENAME = N'M:\Data\AdventureWorks2012_Data_4.ndf' , SIZE = 20GB , FILEGROWTH = 10%)
GO


use AdventureWorks2012
GO

EXEC sp_msforeachtable "ALTER TABLE ? DISABLE TRIGGER ALL"



select 'ALTER TABLE ' + table_schema + '.' + table_name + ' DROP CONSTRAINT ' + CONSTRAINT_NAME + CHAR(10) + 'GO' from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE in ('unique','FOREIGN KEY', 'CHECK')

select 'ALTER TABLE ' + table_schema + '.' + table_name + ' DROP CONSTRAINT ' + CONSTRAINT_NAME + CHAR(10) + 'GO' from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE in ('primary key')



--select * from 
--INFORMATION_SCHEMA

select * from sys.indexes
where is_unique = 1


DECLARE @ownername SYSNAME 
DECLARE @tablename SYSNAME 
DECLARE @indexname SYSNAME 
DECLARE @sql NVARCHAR(4000) 
DECLARE dropindexes CURSOR FOR 

SELECT indexes.name, objects.name, schemas.name 
FROM sys.indexes 
JOIN sys.objects ON indexes.OBJECT_ID = objects.OBJECT_ID 
JOIN sys.schemas ON objects.schema_id = schemas.schema_id 
WHERE indexes.index_id > 0 
  AND indexes.index_id < 255 
  AND objects.is_ms_shipped = 0
  AND indexes.is_unique = 1 
  AND NOT EXISTS (SELECT 1 FROM sys.objects WHERE objects.name = indexes.name) 
ORDER BY objects.OBJECT_ID, indexes.index_id DESC 


SELECT * FROM sys.stats 
OPEN dropindexes 
FETCH NEXT FROM dropindexes INTO @indexname, @tablename, @ownername 
WHILE @@fetch_status = 0 
BEGIN 
  SET @sql = N'DROP INDEX '+QUOTENAME(@ownername)+'.'+QUOTENAME(@tablename)+'.'+QUOTENAME(@indexname) 
  PRINT @sql 
  EXEC sp_executesql @sql   
  FETCH NEXT FROM dropindexes INTO @indexname, @tablename, @ownername 
END 
CLOSE dropindexes 
DEALLOCATE dropindexes 


--SET IDENTITY_INSERT [ database. [ owner. ] ] { table } { ON | OFF } 

-- check the current record count & szie of the table

select count(*) from [HumanResources].[Employee]
GO
sp_spaceused '[HumanResources].[Employee]'
GO



INSERT INTO [HumanResources].[Employee]
           ([BusinessEntityID]
           ,[NationalIDNumber]
           ,[LoginID]
           ,[OrganizationNode]
		 --  ,[OrganizationLevel]
           ,[JobTitle]
           ,[BirthDate]
           ,[MaritalStatus]
           ,[Gender]
           ,[HireDate]
           ,[SalariedFlag]
           ,[VacationHours]
           ,[SickLeaveHours]
           ,[CurrentFlag]
		   ,[rowguid]
           ,[ModifiedDate])
SELECT [BusinessEntityID]
      ,[NationalIDNumber]
      ,[LoginID]
      ,[OrganizationNode]
     -- ,[OrganizationLevel]
      ,[JobTitle]
      ,[BirthDate]
      ,[MaritalStatus]
      ,[Gender]
      ,[HireDate]
      ,[SalariedFlag]
      ,[VacationHours]
      ,[SickLeaveHours]
      ,[CurrentFlag]
	  ,[rowguid]
      ,[ModifiedDate]
  FROM [HumanResources].[Employee]
GO 5

-- check the current record count & szie of the table

select count(*) from [HumanResources].[Employee]
GO
sp_spaceused '[HumanResources].[Employee]'
GO




select count(*) from [Sales].[SalesOrderHeader]
GO
sp_spaceused '[Sales].[SalesOrderHeader]'
GO




INSERT INTO [Sales].[SalesOrderHeader]
           ([RevisionNumber]
           ,[OrderDate]
           ,[DueDate]
           ,[ShipDate]
           ,[Status]
           ,[OnlineOrderFlag]
           ,[PurchaseOrderNumber]
           ,[AccountNumber]
           ,[CustomerID]
           ,[SalesPersonID]
           ,[TerritoryID]
           ,[BillToAddressID]
           ,[ShipToAddressID]
           ,[ShipMethodID]
           ,[CreditCardID]
           ,[CreditCardApprovalCode]
           ,[CurrencyRateID]
           ,[SubTotal]
           ,[TaxAmt]
           ,[Freight]
           ,[Comment]
           ,[rowguid]
           ,[ModifiedDate])
SELECT --[SalesOrderID]
      [RevisionNumber]
      ,[OrderDate]
      ,[DueDate]
      ,[ShipDate]
      ,[Status]
      ,[OnlineOrderFlag]
      --,[SalesOrderNumber]
      ,[PurchaseOrderNumber]
      ,[AccountNumber]
      ,[CustomerID]
      ,[SalesPersonID]
      ,[TerritoryID]
      ,[BillToAddressID]hhhhhhhhhhh
      ,[ShipToAddressID]
      ,[ShipMethodID]
      ,[CreditCardID]
      ,[CreditCardApprovalCode]
      ,[CurrencyRateID]
      ,[SubTotal]
      ,[TaxAmt]
      ,[Freight]
      --,[TotalDue]
      ,[Comment]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [Sales].[SalesOrderHeader]
GO 5


select count(*) from [Sales].[SalesOrderHeader]
GO
sp_spaceused '[Sales].[SalesOrderHeader]'
GO






select count(*) from [Sales].[SalesOrderDetail]
GO
sp_spaceused '[Sales].[SalesOrderDetail]'
GO



INSERT INTO [Sales].[SalesOrderDetail]
           ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [SalesOrderID]
      --,[SalesOrderDetailID]
      ,[CarrierTrackingNumber]
      ,[OrderQty]
      ,[ProductID]
      ,[SpecialOfferID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
      --,[LineTotal]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [Sales].[SalesOrderDetail]
GO 4

select count(*) from [Sales].[SalesOrderDetail]
GO
sp_spaceused '[Sales].[SalesOrderDetail]'
GO




select count(*) from [Person].[Person]
GO
sp_spaceused '[Person].[Person]'
GO

DROP INDEX [PXML_Person_AddContact] ON [Person].[Person]
GO

DROP INDEX [PXML_Person_Demographics] ON [Person].[Person]
GO

ALTER TABLE Person.Person DROP CONSTRAINT PK_Person_BusinessEntityID
GO


INSERT INTO [Person].[Person]
           ([BusinessEntityID]
           ,[PersonType]
           ,[NameStyle]
           ,[Title]
           ,[FirstName]
           ,[MiddleName]
           ,[LastName]
           ,[Suffix]
           ,[EmailPromotion]
           ,[AdditionalContactInfo]
           ,[Demographics]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [BusinessEntityID]
      ,[PersonType]
      ,[NameStyle]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[Suffix]
      ,[EmailPromotion]
      ,[AdditionalContactInfo]
      ,[Demographics]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [Person].[Person]
GO 2


select count(*) from [Person].[Person]
GO
sp_spaceused '[Person].[Person]'
GO




select count(*) from [production].[Product]
GO
sp_spaceused '[Production].[Product]'
GO



INSERT INTO [Production].[Product]
           ([Name]
           ,[ProductNumber]
           ,[MakeFlag]
           ,[FinishedGoodsFlag]
           ,[Color]
           ,[SafetyStockLevel]
           ,[ReorderPoint]
           ,[StandardCost]
           ,[ListPrice]
           ,[Size]
           ,[SizeUnitMeasureCode]
           ,[WeightUnitMeasureCode]
           ,[Weight]
           ,[DaysToManufacture]
           ,[ProductLine]
           ,[Class]
           ,[Style]
           ,[ProductSubcategoryID]
           ,[ProductModelID]
           ,[SellStartDate]
           ,[SellEndDate]
           ,[DiscontinuedDate]
           ,[rowguid]
           ,[ModifiedDate])
SELECT --[ProductID]
       [Name]
      ,[ProductNumber]
      ,[MakeFlag]
      ,[FinishedGoodsFlag]
      ,[Color]
      ,[SafetyStockLevel]
      ,[ReorderPoint]
      ,[StandardCost]
      ,[ListPrice]
      ,[Size]
      ,[SizeUnitMeasureCode]
      ,[WeightUnitMeasureCode]
      ,[Weight]
      ,[DaysToManufacture]
      ,[ProductLine]
      ,[Class]
      ,[Style]
      ,[ProductSubcategoryID]
      ,[ProductModelID]
      ,[SellStartDate]
      ,[SellEndDate]
      ,[DiscontinuedDate]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [Production].[Product]
GO 10


select count(*) from [production].[Product]
GO
sp_spaceused '[Production].[Product]'
GO





