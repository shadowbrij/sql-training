--setup extented events for file read completed event
-- filter on session id
-- create the table
-- run the demo with fragmentation and record the number
-- and do the same without fragmentation
-- need to do this multiple times to ascertain asynch IO


-- Read Ahead Scan
---------------------------------------------------------------------

SET NOCOUNT ON;
USE AdventureWorks2012;
GO

-- drop table t1

-- Create table T1
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  cl_col UNIQUEIDENTIFIER NOT NULL DEFAULT(NEWID()),
  filler CHAR(200) NOT NULL DEFAULT('a')
);
GO
CREATE UNIQUE CLUSTERED INDEX idx_cl_col ON dbo.T1(cl_col);
GO

-- Insert rows
SET NOCOUNT ON;

TRUNCATE TABLE dbo.T1;

declare @cnt bigint = 0
WHILE 1=1
begin
  INSERT INTO dbo.T1 DEFAULT VALUES;
  set @cnt = @cnt +1
  if @cnt = 100000
  BREAK
 end
GO

-- select count (*) from dbo.T1

-- Observe level of fragmentation
SELECT avg_fragmentation_in_percent FROM sys.dm_db_index_physical_stats
( 
  DB_ID('adventureworks2012'),
  OBJECT_ID('dbo.T1'),
  1,
  NULL,
  NULL
);

SET STATISTICS IO ON


DBCC DROPCLEANBUFFERS
GO

select * from dbo.T1
order by  cl_col

-- get a guid and replace below
select * from dbo.T1
where cl_col > '260A30B9-CACC-4B7C-8719-85069CD60CB5'


alter index idx_cl_col ON dbo.T1 rebuild
with (fillfactor = 70)