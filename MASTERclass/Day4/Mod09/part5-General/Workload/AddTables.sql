/*============================================================================
	SQL Server 2008 Using Performance Data Collection Hands-on Labs
	AddTables.sql
	
	Script created/modified for SQL Server 2008 Hands-on Labs
	SQL Server 2008 February CTP 
------------------------------------------------------------------------------
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/

--BACKUP DATABASE AdventureWorks 
--TO DISK = N'C:\Manageability Labs\AdventureWorksOriginal.bak'
--go

USE AdventureWorks
GO

IF OBJECTPROPERTY(object_id('NewCustomer'), 'IsUserTable') = 1
   DROP TABLE NewCustomer
SELECT * INTO NewCustomer
   FROM Sales.Customer
GO

IF OBJECTPROPERTY(object_id('NewContacts'), 'IsUserTable') = 1
   DROP TABLE NewContacts
SELECT * INTO NewContacts
   FROM Person.Contact
GO

IF OBJECTPROPERTY(object_id('NewCustomerAddress'), 'IsUserTable') = 1
   DROP TABLE NewCustomerAddress
SELECT * INTO NewCustomerAddress 
   FROM Sales.CustomerAddress
GO

IF OBJECTPROPERTY(object_id('NewVendor'), 'IsUserTable') = 1
   DROP TABLE NewVendor
SELECT * INTO NewVendor
     FROM Purchasing.Vendor
GO

IF OBJECTPROPERTY(object_id('NewVendorContact'), 'IsUserTable') = 1
   DROP TABLE NewVendorContact
SELECT * INTO NewVendorContact
     FROM Purchasing.VendorContact
GO


IF OBJECTPROPERTY(object_id('NewIndividual'), 'IsUserTable') = 1
   DROP TABLE NewIndividual
SELECT * INTO NewIndividual
   FROM Sales.Individual
GO

CREATE INDEX [IDX_NewIndividual_CustID]
ON [dbo].[NewIndividual] ([CustomerID])


IF OBJECTPROPERTY(object_id('NewEmployee'), 'IsUserTable') = 1
   DROP TABLE NewEmployee
SELECT * INTO NewEmployee
   FROM HumanResources.Employee
GO

IF OBJECTPROPERTY(object_id('NewSalesOrderHeader'), 'IsUserTable') = 1
   DROP TABLE NewSalesOrderHeader
SELECT * INTO NewSalesOrderHeader
   FROM Sales.SalesOrderHeader
GO

IF OBJECTPROPERTY(object_id('NewSalesOrderDetail'), 'IsUserTable') = 1
   DROP TABLE NewSalesOrderDetail
SELECT * INTO NewSalesOrderDetail
   FROM Sales.SalesOrderDetail
GO


IF OBJECTPROPERTY(object_id('NewProduct'), 'IsUserTable') = 1
   DROP TABLE NewProduct
SELECT * INTO NewProduct
   FROM Production.Product
GO