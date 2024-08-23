---------------------------------------------------------------------
-- Transactions
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

-- turn on

-- Allow SNAPSHOT isolation in the database
ALTER DATABASE testdb SET ALLOW_SNAPSHOT_ISOLATION ON;
GO


-- Turn on READ_COMMITTED_SNAPSHOT
ALTER DATABASE testdb SET READ_COMMITTED_SNAPSHOT ON;
GO
