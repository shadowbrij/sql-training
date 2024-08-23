----------------------------------------------------------
-- Demo: SERIALIZABLE
-- File: L4_Serializable.sql
-- Summary: In this example, all products from Production.Product table are being updated in connection 1 where the reorder point is 600. The transaction is running under SERIALIZABLE isolation level. Thus, SQL Server acquires key-range locks (resource_mode) on all the 25 rows that qualify the criteria. The lock is being held for the entire duration of the transaction and will avoid phantoms (another transaction cannot insert or update a record in this table with reorder point value of 600). The query in connection 2 is forced to wait.
--If you run the second sys.dm_tran_locks SELECT statement where request_mode is filtered on RangeS-U lock, you will observe that remaining rows in the table are locked with RangeS-U lock mode. RangeS-U locks are implemented so that another transaction can read these rows but not modify them
----------------------------------------------------------

USE AdventureWorks2008R2
GO

-- step 1
-- Connection 1
-- all products from Production.Product table are being updated in connection 1 where the reorder point is 600. The transaction is running under SERIALIZABLE isolation level. Thus, SQL Server acquires key-range locks (resource_mode) on all the 25 rows that qualify the criteria. The lock is being held for the entire duration of the transaction.

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
GO

BEGIN TRAN
UPDATE Production.Product
SET ReorderPoint = 1000
WHERE ReorderPoint = 600
GO

-- verify the key-range locks

SELECT resource_type, resource_description, request_mode, request_status, *
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
AND request_mode = 'RangeX-X'
GO


-- observe that remaining rows in the table are locked with RangeS-U lock mode. RangeS-U locks are implemented so that another transaction can read these rows but not modify them

SELECT resource_type, resource_description, request_mode, request_status, *
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
AND request_mode = 'RangeS-U'
GO

-- step2
-- connection 2
-- This transaction cannot insert or update a record in this table with reorder point value of 600. The query is forced to wait
UPDATE Production.Product
SET ReorderPoint = 600
WHERE ProductID = 1
GO

-- step3
-- cancel the query in connection 2

-- step4
-- try reading a row where the ReorderPoint is not 600

SELECT * FROM Production.Product
WHERE ProductID = 1

-- step5
-- try inserting a new record (and then cancel the query)

SET IDENTITY_INSERT [Production].[Product] ON

INSERT [Production].[Product] ([ProductID], [Name], [ProductNumber], [MakeFlag], [FinishedGoodsFlag], [Color], [SafetyStockLevel], [ReorderPoint], [StandardCost], [ListPrice], [Size], [SizeUnitMeasureCode], [WeightUnitMeasureCode], [Weight], [DaysToManufacture], [ProductLine], [Class], [Style], [ProductSubcategoryID], [ProductModelID], [SellStartDate], [SellEndDate], [DiscontinuedDate], [rowguid], [ModifiedDate]) VALUES (1000, N'Test Product', N'Test Product', 1, 1, N'Black', 100, 700, 343.6496, 539.9900, N'52', N'CM ', N'LB ', CAST(20.42 AS Decimal(8, 2)), 4, N'R ', N'L ', N'U ', 2, 31, CAST(0x0000995E00000000 AS DateTime), NULL, NULL, NEWID(), CAST(0x00009A5C00A53CF8 AS DateTime))
GO

SET IDENTITY_INSERT [Production].[Product] OFF

-- step6
-- connection 1

ROLLBACK TRAN
GO