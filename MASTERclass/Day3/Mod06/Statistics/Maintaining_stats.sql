--The Setup

--Start with a copy of the AdventureWorks2012 database


IF (SELECT COUNT(*) FROM [sys].[databases] WHERE [name] = 'AdventureWorks2012' AND [is_auto_create_stats_on] = 0) = 0
BEGIN
ALTER DATABASE [AdventureWorks2012] SET AUTO_UPDATE_STATISTICS ON
END;

--We’re going to use a copy of the Sales.SalesOrderDetail table for the demo. After we create the table, we will check to see when statistics last updated. We can use various methods to check statistics date, such as DBCC SHOW_STATISTICS or STATS_DATE, but since the release of SP1 for SQL Server 2012, we can use sys.dm_db_stats_properties to get this information.

USE [AdventureWorks2012];
GO

SELECT *
INTO [Sales].[TestSalesOrderDetail]
FROM [Sales].[SalesOrderDetail];
GO

CREATE CLUSTERED INDEX [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID] ON [Sales].[TestSalesOrderDetail] ([SalesOrderID], [SalesOrderDetailID]);
GO

CREATE UNIQUE NONCLUSTERED INDEX [AK_TestSalesOrderDetail_rowguid] ON [Sales].[TestSalesOrderDetail] ([rowguid]);
GO

CREATE NONCLUSTERED INDEX [IX_TestSalesOrderDetail_ProductID] ON [Sales].[TestSalesOrderDetail] ([ProductID]);
GO


SELECT
OBJECT_NAME([sp].[object_id]) AS "Table",
[sp].[stats_id] AS "Statistic ID",
[s].[name] AS "Statistic",
[sp].[last_updated] AS "Last Updated",
[sp].[rows],
[sp].[rows_sampled],
[sp].[unfiltered_rows],
[sp].[modification_counter] AS "Modifications"
FROM [sys].[stats] AS [s]
OUTER APPLY sys.dm_db_stats_properties ([s].[object_id],[s].[stats_id]) AS [sp]
WHERE [s].[object_id] = OBJECT_ID(N'Sales.TestSalesOrderDetail');


 
--sys.dm_db_stats_properties after initially creating the table

-- including the date that statistics were last updated and row information, We also get a count of modifications since the last statistic update. We just created the table, so the Last Updated date is current, and we have not made any changes so the modification count is 0.

--Invalidating Statistics

--lets do a  bulk insert enough rows to invalidate the statistics. SQL Server has pre-determined thresholds where it considers statistics to be out-of-date and therefore invalid. 

--The table size has gone from 0 to >0 rows (test 1).

--The number of rows in the table when the statistics were gathered was 500 or less, and the colmodctr of the leading column of the statistics object has changed by more than 500 since then (test 2).

--The table had more than 500 rows when the statistics were gathered, and the colmodctr of the leading column of the statistics object has changed by more than 500 + 20% of the number of rows in the table when the statistics were gathered (test 3).

--The Sales.SalesOrderDetail table has 121317 rows:

--(121317 * 0.20) + 500 = 24764

--The bulk insert below loads 24775 rows, which should be enough to invalidate statistics.


BULK INSERT AdventureWorks2012.Sales.TestSalesOrderDetail
FROM 'C:\Data\sod.txt'
WITH
(
DATAFILETYPE = 'native',
TABLOCK
);


--After the bulk load completes, re-run the query against sys.dm_db_stats_properties and review the output:

 


--The statistics have not updated, but the modification counter has changed, as expected. The statistics are now out of date based on the threshold defined previously, and we would expect that a query or data modification against Sales.TestSalesOrderDetail would trigger an update of statistics. But before we try that, let’s review what causes the automatic update.



--The statistics auto update is triggered by query optimization or by execution of a compiled plan, and it involves only a subset of the columns referred to in the query.

--When a query is first compiled, if the optimizer needs a particular statistics object, and that statistics object exists, the statistics object is updated if it is out of date. When a query is executed and its plan is in the cache, the statistics the plan depends on are checked to see if they are out of date. If so, the plan is removed from the cache, and during recompilation of the query, the statistics are updated. The plan also is removed from the cache if any of the statistics it depends on have changed.

--To be clear, if a query plan exists in cache and that plan uses specific statistics, when the query executes SQL Server checks to see if any of the statistics used in the plan are out of date. If they are, then the automatic update of those statistics occurs.

--If a plan does not exist in cache for a query, then if the optimizer uses a statistics object that is out of date when the plan compiles, SQL Server will automatically update those statistics.

--Invoking the Automatic Update

--We have not run any query against Sales.TestSalesOrderDetail except our bulk insert. At the time that the query compiled for the bulk insert, no statistics for Sales.TestSalesOrderDetail were out of date; therefore no statistics required an automatic update.

--Now let’s issue an update against Sales.TestSalesOrderDetail that will change the ProductID for a specific SalesOrderID, and then query sys.dm_db_stats_properties:


UPDATE Sales.TestSalesOrderDetail SET ProductID = 717 WHERE SalesOrderID = 75123;
GO


--We can see that the PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID statistic object automatically updated. We could simply assume that the optimizer used this object in the plan. However, in SQL Server 2012 we can look at the plan XML and confirm this.

--This information is only available in SQL Server 2012 and higher. 
--This query interrogates the plan cache. The plan cache may be very large for your system, depending on the amount of memory on the server. Before querying the plan, I recommend setting the transaction isolation level to READ UNCOMMITTED, and also recommend using OPTION (MAXDOP 1) to limit CPU utilization. The query may take longer to execute, but it reduces the impact on other queries executing concurrently.


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
DBCC TRACEON (8666);
GO
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' as p)
SELECT qt.text AS SQLCommand,
qp.query_plan,
StatsUsed.XMLCol.value('@FieldValue','NVarChar(500)') AS StatsName
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY sys.dm_exec_sql_text (cp.plan_handle) qt
CROSS APPLY query_plan.nodes('//p:Field[@FieldName="wszStatName"]') StatsUsed(XMLCol)
WHERE qt.text LIKE '%UPDATE%'
AND qt.text LIKE '%ProductID%';
GO
DBCC TRACEOFF(8666);
GO



--The output confirms that the optimizer used the PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID statistic object in the query plan, and because it was out of date, SQL Server automatically updated it.



--One thing: the IX_TestSalesOrderDetail_ProductID statistic, which has ProductID as its key, did not update automatically when the UPDATE query executed. This is expected. Even though the statement modified ProductID for three rows (the modification counter for the statistic increased from 24775 to 24778), the optimizer did not use that statistic in the plan. If the plan does not use a statistic, the statistic will not automatically update, even if the query modifies columns in said statistic key.

--Summary



--A query compiles for the first time, and a statistic used in the plan is out of date 
--A query has an existing query plan, but a statistic in the plan is out of date
--For those that attended my session at Summit, I hope this helps address any questions you might have still had. If not, please leave a comment and I will get back to you!

