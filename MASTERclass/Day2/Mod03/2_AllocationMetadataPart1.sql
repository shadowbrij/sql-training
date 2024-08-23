-- Part 1: allocation metadata
USE [master];
GO

IF DATABASEPROPERTYEX (N'MetaData1', N'Version') > 0
BEGIN
	ALTER DATABASE [MetaData1] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [MetaData1];
END
GO

CREATE DATABASE [MetaData1];
GO

USE [MetaData1];
GO

-- Create a new table that will use disk
-- space quickly and extend the data file
CREATE TABLE [QuickTest] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'RandomValue');
GO

SET NOCOUNT ON;
GO

INSERT INTO [QuickTest] DEFAULT VALUES;
GO 100

-- Remember we need the trace flag
DBCC TRACEON (3604);
GO

-- PFS page
DBCC PAGE (N'MetaData1', 1, 1, 3);
GO

-- GAM page
DBCC PAGE (N'MetaData1', 1, 2, 3);
GO

-- SGAM page
DBCC PAGE (N'MetaData1', 1, 3, 3);
GO

-- Look at the DIFF map
DBCC PAGE (N'MetaData1', 1, 6, 3);
GO

-- Insert rows to use up some extents
INSERT INTO [QuickTest] DEFAULT VALUES;
GO 100

-- Look at the DIFF map again to see
-- some more extents marked as used
DBCC PAGE (N'MetaData1', 1, 6, 3);
GO

-- Clear it with a full backup
ALTER DATABASE [MetaData1]
	SET RECOVERY FULL;

BACKUP DATABASE [MetaData1] TO
	DISK = N'C:\Data\DBMaint.bck'
	WITH INIT;
GO

-- And look again. Everything cleared?
DBCC PAGE (N'MetaData1', 1, 6, 3);
GO

-- Look at the ML map
DBCC PAGE (N'MetaData1', 1, 7, 3);
GO

-- Let's do a minimally-logged operation
-- Create an index, go into BULK_LOGGED
-- recovery mode and rebuild it
CREATE CLUSTERED INDEX [QT_CL]
	ON [QuickTest] ([c1]);
GO
ALTER DATABASE [MetaData1] SET
	RECOVERY BULK_LOGGED;
GO
ALTER INDEX [QT_CL] ON [QuickTest] REBUILD;
GO

-- Now how does it look?
DBCC PAGE (N'MetaData1', 1, 7, 3);
GO

-- Clear it using a log backup
ALTER DATABASE [MetaData1]
	SET RECOVERY FULL;
GO
BACKUP LOG [MetaData1]
	TO DISK = N'C:\SQLskills\DBMaint.bck'
	WITH INIT;
GO

-- And look again
DBCC PAGE (N'MetaData1', 1, 7, 3);
GO

-- Part 2: IAM pages