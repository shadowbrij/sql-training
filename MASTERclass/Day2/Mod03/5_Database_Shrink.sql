USE MASTER;
GO

IF DATABASEPROPERTYEX ('dbshrink', 'Version') > 0
      DROP DATABASE dbshrink;
 
CREATE DATABASE dbshrink;
GO
USE dbshrink;
GO
 

SET NOCOUNT ON;
GO
 

-- Create and fill the filler table
CREATE TABLE filler (c1 INT IDENTITY, c2 VARCHAR(8000))
GO
DECLARE @a INT;
SELECT @a = 1;
WHILE (@a < 12800) -- insert 10MB
BEGIN
      INSERT INTO filler VALUES (REPLICATE ('a', 5000));
      SELECT @a = @a + 1;
END;
GO

-- Create and fill the production table

CREATE TABLE production (c1 INT IDENTITY, c2 VARCHAR (8000));
CREATE CLUSTERED INDEX prod_cl ON production (c1);
GO
DECLARE @a INT;
SELECT @a = 1;
WHILE (@a < 12800) -- insert 10MB
BEGIN
      INSERT INTO production VALUES (REPLICATE ('a', 5000));
      SELECT @a = @a + 1;
END;
GO 

select top 10 * from production
select count(*) from production

-- check the fragmentation of the production table

SELECT page_count, avg_fragmentation_in_percent, fragment_count FROM sys.dm_db_index_physical_stats (
      DB_ID ('dbshrink'), OBJECT_ID ('production'), 1, NULL, 'LIMITED');
GO

-- record select performance

DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE

-- select query

DECLARE @Start_Time	datetime2, 
		@End_Time	datetime2,
		@Total_Time int,
		@Num_Rows int
SELECT @Start_Time = sysdatetime()
select * from production
	where c1 > 5000
SELECT @Num_Rows = @@ROWCOUNT
SELECT @End_Time = sysdatetime()
SELECT  @Total_Time = datediff (MILLISECOND, @Start_Time, @End_Time) 
SELECT @Num_Rows AS 'Rows_Modified', @Total_Time AS 'TOTAL_TIME (ms)'
go

-- Time taken before shrink				: 500 ms
-- Time taken after shrink				:


select top 100 * from production



-- check the fragmentation of the production table

SELECT page_count, avg_fragmentation_in_percent, fragment_count FROM sys.dm_db_index_physical_stats (
      DB_ID ('dbshrink'), OBJECT_ID ('production'), 1, NULL, 'LIMITED');
GO

sp_helpdb @dbname='dbshrink'


-- drop the filler table and shrink the database
DROP TABLE filler;
GO
 

sp_helpdb @dbname='dbshrink'

-- shrink the database
DBCC SHRINKDATABASE (dbshrink);
GO
 

-- check the index fragmentation again
	SELECT page_count, avg_fragmentation_in_percent, fragment_count FROM sys.dm_db_index_physical_stats (
		  DB_ID ('dbshrink'), OBJECT_ID ('production'), 1, NULL, 'LIMITED');
	GO

-- record select performance

DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE

-- select query

DECLARE @Start_Time	datetime2, 
		@End_Time	datetime2,
		@Total_Time int,
		@Num_Rows int
SELECT @Start_Time = sysdatetime()
select * from production
	where c1 > 5000
SELECT @Num_Rows = @@ROWCOUNT
SELECT @End_Time = sysdatetime()
SELECT  @Total_Time = datediff (MILLISECOND, @Start_Time, @End_Time) 
SELECT @Num_Rows AS 'Rows_Modified', @Total_Time AS 'TOTAL_TIME (ms)'
go


-- Time taken before shrink				: 500 ms
-- Time taken after shrink				: 1000 ms



-- rebuild the index

alter index prod_cl on production rebuild

-- check the fragmentation of the production table

SELECT page_count, avg_fragmentation_in_percent, fragment_count FROM sys.dm_db_index_physical_stats (
      DB_ID ('dbshrink'), OBJECT_ID ('production'), 1, NULL, 'LIMITED');
GO


-- record select performance

DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE

-- select query

DECLARE @Start_Time	datetime2, 
		@End_Time	datetime2,
		@Total_Time int,
		@Num_Rows int
SELECT @Start_Time = sysdatetime()
select * from production
	where c1 > 5000
SELECT @Num_Rows = @@ROWCOUNT
SELECT @End_Time = sysdatetime()
SELECT  @Total_Time = datediff (MILLISECOND, @Start_Time, @End_Time) 
SELECT @Num_Rows AS 'Rows_Modified', @Total_Time AS 'TOTAL_TIME (ms)'
go

-- Time taken before shrink				: 500 ms
-- Time taken after shrink				: 1000 ms
-- time taken after rebuild				: 2500 ms
