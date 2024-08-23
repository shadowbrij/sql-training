
USE Credit
go

---------------------------------------------------------------------------------------------------
--1) Create a working version of the Member table called Member2. 
---------------------------------------------------------------------------------------------------

IF OBJECTPROPERTY(object_id('Member'), 'IsUserTable') = 1
	DROP TABLE dbo.Member2 
go

SELECT * 
INTO dbo.Member2
FROM dbo.Member
go

sp_help Member2
exec sp_helpindex Member2
go

---------------------------------------------------------------------------------------------------
--2) Create indexes on the Member2 table to simulate a realworld environment.
---------------------------------------------------------------------------------------------------

ALTER TABLE dbo.Member2
ADD CONSTRAINT Member2PK
	PRIMARY KEY CLUSTERED (Member_no)
	-- PRIMARY KEY (Member_no) -- clustered is the default
go

CREATE INDEX Member2NameInd 
ON dbo.Member2(LastName, FirstName, MiddleInitial)
go

CREATE INDEX Member2RegionFK
ON dbo.Member2(region_no)
go

CREATE INDEX Member2CorpFK
ON dbo.Member2(corp_no)
go

SELECT * FROM sys.system_objects
WHERE [name] LIKE 'dm[_]%'
 
---------------------------------------------------------------------------------------------------
--3)  Verify the indexes
---------------------------------------------------------------------------------------------------
EXEC sp_helpindex Member2
go
SELECT object_name(id) AS tablename, indid, name
FROM sysindexes -- compatibility views
WHERE object_id('Member2') = id
go
SELECT * FROM sys.indexes 
where object_id = object_id('member2') -- catalog views
SELECT * FROM sys.stats -- catalog views
go

---------------------------------------------------------------------------------------------------
--4) Verify the fragmentation of the indexes
---------------------------------------------------------------------------------------------------
sp_dbcmptlevel credit, 90;
go

SELECT * 
FROM sys.dm_db_index_physical_stats
--	(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, NULL)  -- 'limited'
	(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, 'SAMPLED')
--	(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, 'detailed')
go

--Index = 1 clustered
--Index = 2-250 = non-clustered
sp_spaceused member2

set statistics io on
select * from member2
---------------------------------------------------------------------------------------------------
-- 5) Simulate Data Modifications/Activity
---------------------------------------------------------------------------------------------------

-- By updating varchar data you will cause the row size to change. Modifications against the 
-- Member2 table will be performed by executing a single update statement that updates 
-- roughly 5% of the table. For completeness, the script takes note of the total time it takes to 
-- execute the modification (this can be helpful to compare).

DECLARE @StartTime	datetime, 
		@EndTime	datetime,
		@NumRowsMod		int,
		@TotalTime			int
SELECT @StartTime = getdate()
UPDATE Member2
	SET street = '1234 Main St.',
		city = 'Anywhere'
WHERE Member_no % 19 = 0
SELECT @NumRowsMod = @@RowCount
SELECT @EndTime = getdate()
SELECT  @TotalTime = datediff (ms, @StartTime, @EndTime) 
SELECT @NumRowsMod AS 'RowsModified', @TotalTime AS 'TOTAL TIME (ms)',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime AS 'Rows per ms',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime*1000 AS 'Estimated Rows per sec'
go
-- Keep track of the time: 53
-- Keep track of the number of rows: 526
-- Keep track of the rows/ms: 9.9

---------------------------------------------------------------------------------------------------
-- 6) Let's look at the effect that this has had on our Member2 table.
---------------------------------------------------------------------------------------------------

-- Use the DMV to review the table's fragmentation
SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, 'sampled')
go

SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id(), OBJECT_ID('Credit.dbo.Member2'), DEFAULT, NULL, 'SAMPLED')




---------------------------------------------------------------------------------------------------
-- 7) How do we fix this fragmentation?
----------------------------------------------------------------------
ALTER INDEX Member2PK ON Member2 REBUILD
	WITH (ONLINE = ON, FILLFACTOR = 90)
go
ALTER INDEX Member2PK ON Member2 REBUILD
	WITH (ONLINE = OFF, FILLFACTOR = 90)
go
ALTER INDEX Member2PK ON Member2 REBUILD
	WITH (FILLFACTOR = 90)
go

---------------------------------------------------------------------------------------------------
-- 9) Recheck the fragmentation
---------------------------------------------------------------------------------------------------
SELECT * 
FROM sys.dm_db_index_physical_stats(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, 'detailed')
go
----------------------------------------------------------------
-- 10) Execute another modification - of more rows with the potential for more fragmentation....
---------------------------------------------------------------------------------------------------

DECLARE @StartTime	datetime, 
		@EndTime	datetime,
		@NumRowsMod		int,
		@TotalTime			int
SELECT @StartTime = getdate()
UPDATE Member2
	SET street = '1234 Main St.',
		city = 'Anywhere'
WHERE Member_no % 17 = 0
SELECT @NumRowsMod = @@RowCount
SELECT @EndTime = getdate()
SELECT  @TotalTime = datediff (ms, @StartTime, @EndTime) 
SELECT @NumRowsMod AS 'RowsModified', @TotalTime AS 'TOTAL TIME (ms)',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime AS 'Rows per ms',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime*1000 AS 'Estimated Rows per sec'
go
-- Keep track of the time: 240
-- Keep track of the number of rows: 588
-- Keep track of the rows/ms: 2.45

---------------------------------------------------------------------------------------------------
-- 11) Again, check the fragmentation....
---------------------------------------------------------------------------------------------------

SELECT * 
FROM sys.dm_db_index_physical_stats(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, 'detailed')
go

-- NOTE: the fragmentation.

---------------------------------------------------------------------------------------------------
-- 12) Execute another modification - of even more rows with the potential for even more fragmentation....
---------------------------------------------------------------------------------------------------

DECLARE @StartTime	datetime, 
		@EndTime	datetime,
		@NumRowsMod		int,
		@TotalTime			int
SELECT @StartTime = getdate()
UPDATE Member2
	SET street = '1234 Main St.',
		city = 'Anywhere'
WHERE Member_no % 11 = 0
SELECT @NumRowsMod = @@RowCount
SELECT @EndTime = getdate()
SELECT  @TotalTime = datediff (ms, @StartTime, @EndTime) 
SELECT @NumRowsMod AS 'RowsModified', @TotalTime AS 'TOTAL TIME (ms)',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime AS 'Rows per ms',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime*1000 AS 'Estimated Rows per sec'
go
-- Keep track of the time: 30
-- Keep track of the number of rows: 909
-- Keep track of the rows/ms: 30.3

---------------------------------------------------------------------------------------------------
-- 13) Again, check the fragmentation....
---------------------------------------------------------------------------------------------------

SELECT * 
FROM sys.dm_db_index_physical_stats(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, 'detailed')
go