---------------------------------------------------------------------
-- Deadlocks, all about them. @A_Bansal
-- SQL Special Event by @SQLMaestros
---------------------------------------------------------------------

--Creating and Populating Tables T1 and T2
SET NOCOUNT ON;
IF DB_ID('testdb') IS NULL
  CREATE DATABASE testdb;
GO
USE testdb;
GO
IF OBJECT_ID('dbo.T1') IS NOT NULL
  DROP TABLE dbo.T1;
IF OBJECT_ID('dbo.T2') IS NOT NULL
  DROP TABLE dbo.T2;
GO

CREATE TABLE dbo.T1
(
  keycol INT         NOT NULL PRIMARY KEY,
  col1   INT         NOT NULL,
  col2   VARCHAR(50) NOT NULL
);

INSERT INTO dbo.T1(keycol, col1, col2) VALUES(1, 101, 'A');
INSERT INTO dbo.T1(keycol, col1, col2) VALUES(2, 102, 'B');
INSERT INTO dbo.T1(keycol, col1, col2) VALUES(3, 103, 'C');

CREATE TABLE dbo.T2
(
  keycol INT         NOT NULL PRIMARY KEY,
  col1   INT         NOT NULL,
  col2   VARCHAR(50) NOT NULL
);

INSERT INTO dbo.T2(keycol, col1, col2) VALUES(1, 201, 'X');
INSERT INTO dbo.T2(keycol, col1, col2) VALUES(2, 202, 'Y');
INSERT INTO dbo.T2(keycol, col1, col2) VALUES(3, 203, 'Z');
GO

---------
---------------------------------------------------------------------
-- Simple Deadlock Example
---------------------------------------------------------------------

-- Connection 1
SET NOCOUNT ON;
USE testdb;
GO
BEGIN TRAN
  UPDATE dbo.T1 SET col1 = col1 + 1 WHERE keycol = 2;
GO

-- Connection 2
SET NOCOUNT ON;
USE testdb;
GO
BEGIN TRAN
  UPDATE dbo.T2 SET col1 = col1 + 1 WHERE keycol = 2;
GO

-- Connection 1
  SELECT col1 FROM dbo.T2 WHERE keycol = 2;
COMMIT TRAN
GO

-- Connection 2
  SELECT col1 FROM dbo.T1 WHERE keycol = 2;
COMMIT TRAN
GO

---------------------------------------------------------------------
-- Deadlock becuase of Mission Impossible
---------------------------------------------------------------------

-- Connection 1
BEGIN TRAN
  UPDATE dbo.T1 SET col2 = col2 + 'A' WHERE col1 = 101;
GO

-- Connection 2
BEGIN TRAN
  UPDATE dbo.T2 SET col2 = col2 + 'B' WHERE col1 = 203;
GO

-- Connection 1
  SELECT col2 FROM dbo.T2 WHERE col1 = 201;
COMMIT TRAN
GO

-- Connection 2
  SELECT col2 FROM dbo.T1 WHERE col1 = 103;
COMMIT TRAN
GO













-- Create an index on col1 and rerun the activities
CREATE INDEX idx_col1 ON dbo.T1(col1);
CREATE INDEX idx_col1 ON dbo.T2(col1);
GO

-- Connection 1
BEGIN TRAN
  UPDATE dbo.T1 SET col2 = col2 + 'A' WHERE col1 = 101;
GO

-- Connection 2
BEGIN TRAN
  UPDATE dbo.T2 SET col2 = col2 + 'B' WHERE col1 = 203;
GO

-- Connection 1
  SELECT col2 FROM dbo.T2 WITH (index = idx_col1) WHERE col1 = 201;
COMMIT TRAN
GO

-- Connection 2
  SELECT col2 FROM dbo.T1 WITH (index = idx_col1) WHERE col1 = 103;
COMMIT TRAN
GO







---------------------------------------------------------------------
-- Deadlock with a Single table
---------------------------------------------------------------------

-- First make sure row with keycol = 2 has col = 102
UPDATE dbo.T1 SET col1 = 102, col2 = 'B' WHERE keycol = 2;
GO

-- Connection 1
SET NOCOUNT ON;
USE testdb;
GO
WHILE 1 = 1
  UPDATE dbo.T1 SET col1 = 203 - col1 WHERE keycol = 2;
GO

-- Connection 2
SET NOCOUNT ON;
USE testdb;
GO
DECLARE @i AS VARCHAR(10);
WHILE 1 = 1
  SET @i = (SELECT col2 FROM dbo.T1 WITH (index = idx_col1)
            WHERE col1 = 102);
GO

-- Cleanup
USE testdb;
GO
IF OBJECT_ID('dbo.T1') IS NOT NULL
  DROP TABLE dbo.T1;
IF OBJECT_ID('dbo.T2') IS NOT NULL
  DROP TABLE dbo.T2;
GO