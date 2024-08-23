USE [AdventureWorksDW2014]
GO
CREATE NONCLUSTERED INDEX [idx_fpi_productkey2]
ON [dbo].[FactProductInventory2] ([ProductKey])
INCLUDE (MovementDate, UnitCost, UnitsOut)
GO

-- drop the old index 
DROP INDEX [idx_fpi_productkey1]
ON [dbo].[FactProductInventory2]