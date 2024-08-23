USE master
GO

-- Drop and restore required databases from backups in the local folder
-- Move the database files to the folder where this script is stored

-- Drop and restore AdventureWorks2014
--IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'AdventureWorks2014')
--BEGIN
--	DROP DATABASE AdventureWorks2014
--END
--GO
--RESTORE DATABASE AdventureWorks2014 FROM  DISK = N'$(SUBDIR)SetupFiles\AdventureWorks2014.bak' WITH  REPLACE,
--MOVE N'AdventureWorks2014_Data' TO N'$(SUBDIR)SetupFiles\AdventureWorks2014.mdf', 
--MOVE N'AdventureWorks2014_Log' TO N'$(SUBDIR)SetupFiles\AdventureWorks2014.ldf'
--GO
--ALTER AUTHORIZATION ON DATABASE::AdventureWorks2014 TO [ADVENTUREWORKS\Student];
--GO

-- Perform any other data modification tasks to prepare data for the demos


USE AdventureWorks2014;
GO
IF OBJECT_ID('dbo.T1') IS NOT NULL
  DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  keycol INT         NOT NULL PRIMARY KEY,
  col1   INT         NOT NULL,
  col2   VARCHAR(50) NOT NULL
);

INSERT INTO dbo.T1(keycol, col1, col2) VALUES(1, 101, 'A');
INSERT INTO dbo.T1(keycol, col1, col2) VALUES(2, 102, 'B');
INSERT INTO dbo.T1(keycol, col1, col2) VALUES(3, 103, 'C');

-- turn on read committed snapshot isolation

ALTER DATABASE AdventureWorks2014 SET ALLOW_SNAPSHOT_ISOLATION ON;
GO

ALTER DATABASE AdventureWorks2014 SET READ_COMMITTED_SNAPSHOT ON;
GO
