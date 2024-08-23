
SET NOCOUNT ON;
USE tempdb;
GO

-- Create table T1

CREATE TABLE dbo.T1
(
  cl_c1 UNIQUEIDENTIFIER NOT NULL DEFAULT(NEWID()),
  cl_testData CHAR(2000) NOT NULL DEFAULT('sqlservergeeks.com')
);
GO
CREATE UNIQUE CLUSTERED INDEX idx_cl_c1 ON dbo.T1(cl_c1);
GO

-- Insert rows (run for a few seconds then stop)
SET NOCOUNT ON;
USE tempdb;

TRUNCATE TABLE dbo.T1;

DECLARE @count AS INT
SET @count = 0;

WHILE @count <=100
BEGIN
  INSERT INTO dbo.T1 DEFAULT VALUES;
  SET @count = @count + 1;
END

-- check the data
select * from T1

-- Observe level of fragmentation
SELECT avg_fragmentation_in_percent FROM sys.dm_db_index_physical_stats
( 
  DB_ID('tempdb'),
  OBJECT_ID('dbo.T1'),
  1,
  NULL,
  NULL
);