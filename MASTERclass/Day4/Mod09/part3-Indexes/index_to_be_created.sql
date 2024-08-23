/*
Missing Index Details from ExecutionPlan1.sqlplan
The Query Processor estimates that implementing the following index could improve the query cost by 97.1482%.
*/

/*
USE [Tuning]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [dbo].[tblOrders] ([orderdate])
INCLUDE ([orderid],[custid],[empid],[shipperid],[filler])
GO
*/
