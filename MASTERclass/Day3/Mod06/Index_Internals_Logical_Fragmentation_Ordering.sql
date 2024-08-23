-- Logical Fragementation of pages
---------------------------------------------------------------------

SET NOCOUNT ON;
USE tempdb;
GO

-- Create table T1
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  cl_col UNIQUEIDENTIFIER NOT NULL DEFAULT(NEWID()),
  filler CHAR(2000) NOT NULL DEFAULT('a')
);
GO
CREATE UNIQUE CLUSTERED INDEX idx_cl_col ON dbo.T1(cl_col);
GO

-- Insert rows (run for a few seconds then stop)
SET NOCOUNT ON;
USE tempdb;

TRUNCATE TABLE dbo.T1;

WHILE 1 = 1
  INSERT INTO dbo.T1 DEFAULT VALUES;
GO

-- Observe level of fragmentation
SELECT avg_fragmentation_in_percent FROM sys.dm_db_index_physical_stats
( 
  DB_ID('tempdb'),
  OBJECT_ID('dbo.T1'),
  1,
  NULL,
  NULL
);

-- Get index linked list info
DBCC IND('tempdb', 'dbo.T1', 0);
GO

CREATE TABLE #DBCCIND
(
  PageFID INT,
  PagePID INT,
  IAMFID INT,
  IAMPID INT,
  ObjectID INT,
  IndexID INT,
  PartitionNumber INT,
  PartitionID BIGINT,
  iam_chain_type VARCHAR(100),
  PageType INT,
  IndexLevel INT,
  NextPageFID INT,
  NextPagePID INT,
  PrevPageFID INT,
  PrevPagePID INT
);

INSERT INTO #DBCCIND
  EXEC ('DBCC IND(''tempdb'', ''dbo.T1'', 0)');

CREATE CLUSTERED INDEX idx_cl_prevpage ON #DBCCIND(PrevPageFID, PrevPagePID);

WITH LinkedList
AS
(
  SELECT 1 AS RowNum, PageFID, PagePID
  FROM #DBCCIND
  WHERE IndexID = 1
    AND IndexLevel = 0
    AND PrevPageFID = 0
    AND PrevPagePID = 0

  UNION ALL

  SELECT PrevLevel.RowNum + 1,
    CurLevel.PageFID, CurLevel.PagePID
  FROM LinkedList AS PrevLevel
    JOIN #DBCCIND AS CurLevel
      ON CurLevel.PrevPageFID = PrevLevel.PageFID
      AND CurLevel.PrevPagePID = PrevLevel.PagePID
)
SELECT
  CAST(PageFID AS VARCHAR(MAX)) + ':'
  + CAST(PagePID AS VARCHAR(MAX)) + ' ' AS [text()]
FROM LinkedList
ORDER BY RowNum
FOR XML PATH('')
OPTION (MAXRECURSION 0);

DROP TABLE #DBCCIND;
GO



-- alter index idx_cl_col ON dbo.T1 rebuild


-- Query T1

-- Index order scan
SELECT SUBSTRING(CAST(cl_col AS BINARY(16)), 11, 6) AS segment1, *
FROM dbo.T1;

-- Allocation order scan
SELECT SUBSTRING(CAST(cl_col AS BINARY(16)), 11, 6) AS segment1, *
FROM dbo.T1 WITH (NOLOCK);

-- Allocation order scan
SELECT SUBSTRING(CAST(cl_col AS BINARY(16)), 11, 6) AS segment1, *
FROM dbo.T1 WITH (TABLOCK);

