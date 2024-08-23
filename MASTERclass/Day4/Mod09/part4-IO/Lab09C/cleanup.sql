--cleanup
USE AdventureWorksDW2014
GO
IF (OBJECT_ID('FactProductInventory2') IS NOT NULL) 
	DROP TABLE FactProductInventory2