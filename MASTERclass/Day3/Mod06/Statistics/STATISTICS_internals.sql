-- create statistics example

USE tempdb
GO
-- Clean up objects from any previous runs.
IF object_id(N'Business.Contact','U') IS NOT NULL
       DROP TABLE Business.Contact
GO
IF EXISTS (SELECT * FROM sys.schemas WHERE name = N'Business')
       DROP SCHEMA Business
GO
-- Create a sample schema and table.
CREATE SCHEMA Business
GO
CREATE TABLE Business.Contact(
       FirstName nvarchar(80),
       LastName nvarchar(80),
       Phone nvarchar(20),
       Title nvarchar(20)
)
GO
-- Populate the table with a few rows.
INSERT INTO Business.Contact
   VALUES(N'Amit',N'Bansal',N'917234852342',N'Mr')
INSERT INTO Business.Contact
   VALUES(N'SarabPreet',N'Singh',N'759832758475',N'Mr')
INSERT INTO Business.Contact
   VALUES(N'Amit',N'Karkhanis',N'729347283423',N'Mr')
INSERT INTO Business.Contact
   VALUES(N'Sachin',N'Nandanwar',N'659837598345',N'Dr')
INSERT INTO Business.Contact
   VALUES(N'Rahul',N'Gupta',N'72348729834234',N'Mr')
GO
-- Observer that there are no statistics yet on the Business.Contact table
sp_helpstats N'Business.Contact', 'ALL'
GO
-- Implicitly create statistics on LastName when you run the below query
SELECT * FROM Business.Contact WHERE LastName = N'Bansal'
GO
-- Observe that statistics were automatically created on LastName.
sp_helpstats N'Business.Contact', 'ALL'
GO



-- Now Create an index, which also creates statistics for the index
CREATE NONCLUSTERED INDEX IDXNCPhone on Business.Contact(Phone)
GO
-- Observe that creating the index created an associated statistics object for the index
sp_helpstats N'Business.Contact', 'ALL'
GO


-- Create a multicolumn statistics object on first and last name.
CREATE STATISTICS FirstLast ON Business.Contact(FirstName,LastName)
GO
-- Show that there are now three statistics objects on the table.
sp_helpstats N'Business.Contact', 'ALL'
GO



-- observing statitics internals

-- Display the statistics for LastName.
DBCC SHOW_STATISTICS (N'Business.Contact', LastName)
GO


-- If you take the name of the statistics object displayed by
-- the command above and subsitute it in as the second argument of
-- DBCC SHOW_STATISTICS, you can form a command like the following one
--

DBCC SHOW_STATISTICS (N'Business.Contact', _WA_Sys_00000002_182C9B23)

-- Executing the above command illustrates that you can show statistics by
-- column name or statistics object name.

--RANGE_HI_KEY
-- A key value showing the upper boundary of a histogram step.
 
--RANGE_ROWS
-- Specifies how many rows are inside the range (they are smaller than this RANGE_HI_KEY, but bigger than the previous smaller RANGE_HI_KEY).
 
--EQ_ROWS
-- Specifies how many rows are exactly equal to RANGE_HI_KEY.
 
--AVG_RANGE_ROWS
-- Average number of rows per distinct value inside the range.
 
--DISTINCT_RANGE_ROWS
-- Specifies how many distinct key values are inside this range (not including the previous key before RANGE_HI_KEY and RANGE_HI_KEY itself);
 




GO
-- The following displays multicolumn statistics. Notice the two
-- different density groups for the second rowset in the output.
DBCC SHOW_STATISTICS (N'Business.Contact', FirstLast)


-- see a larger histogram

USE AdventureWorks2008
-- Clean up objects from previous runs.
IF EXISTS (SELECT * FROM sys.stats
           WHERE object_id = object_id('Sales.SalesOrderHeader')
           AND name = 'TotalDue')
       DROP STATISTICS Sales.SalesOrderHeader.TotalDue
GO

-- first observe the rows
select * from Sales.SalesOrderHeader

--
CREATE STATISTICS TotalDue ON Sales.SalesOrderHeader(TotalDue)
GO
DBCC SHOW_STATISTICS(N'Sales.SalesOrderHeader', TotalDue)
GO

-- verification queries

select COUNT(*) from sales.SalesOrderHeader
where TotalDue>2.5305 and TotalDue<4.409

select COUNT(*) from sales.SalesOrderHeader
where TotalDue between 2.5305 and 4.409

select COUNT(*) from sales.SalesOrderHeader
where TotalDue=2.5305


select DISTINCT TotalDue from sales.SalesOrderHeader
where TotalDue>2.5305 and TotalDue<4.409

select TotalDue from sales.SalesOrderHeader
where TotalDue>2.5305 and TotalDue<4.409

-----------------------------------




--drop statistics

drop statistics Sales.SalesOrderHeader.TotalDue

drop statistics Sales.SalesOrderHeader._WA_Sys_00000017_3C34F16F

-- turn off autocreate statistics

ALTER DATABASE adventureworks2008 SET AUTO_CREATE_STATISTICS OFF

ALTER DATABASE adventureworks2008 SET AUTO_CREATE_STATISTICS ON

-- create an index

create index IX_NC_TotalDue on Sales.SalesOrderHeader (TotalDue)

Drop index IX_NC_TotalDue on Sales.SalesOrderHeader




-----------------------------------------------------------
--STATS_DATE example
-----------------------------------------------------------

USE tempdb
GO


CREATE TABLE Contact(
       FirstName nvarchar(100),
       LastName nvarchar(100),
       Phone nvarchar(30),
       Title nvarchar(20)
)
GO
-- Populate the table with a few rows.
INSERT INTO Contact
   VALUES(N'Amit',N'Bansal',N'917234852342',N'Mr')
INSERT INTO Contact
   VALUES(N'SarabPreet',N'Singh',N'759832758475',N'Mr')
INSERT INTO Contact
   VALUES(N'Amit',N'Karkhanis',N'729347283423',N'Mr')
INSERT INTO Contact
   VALUES(N'Rakesh',N'Mishra',N'659837598345',N'Dr')
INSERT INTO Contact
   VALUES(N'Piyush',N'Bajaj',N'72348729834234',N'Mr')
GO
-- Observer that there are no statistics yet on the Business.Contact table
sp_helpstats N'dbo.Contact', 'ALL'
GO
-- Implicitly create statistics on LastName when you run the below query
SELECT * FROM Contact WHERE LastName = N'Bansal'
GO
-- Observe that statistics were automatically created on LastName.
sp_helpstats N'dbo.Contact', 'ALL'
GO


select STATS_DATE (421576540,2)

select * from sys.stats
where name = '_WA_Sys_00000002_1920BF5C'


UPDATE STATISTICS dbo.Contact;








-- sample code

USE AdventureWorks2008;
GO
SELECT name AS stats_name, 
    STATS_DATE(object_id, stats_id) AS statistics_update_date
FROM sys.stats 
WHERE object_id = OBJECT_ID('Person.Address');
GO