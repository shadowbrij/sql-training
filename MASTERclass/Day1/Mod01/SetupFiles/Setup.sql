USE master
GO

-- Drop and restore required databases from backups in the local folder
-- Move the database files to the folder where this script is stored

-- Drop and restore AdventureWorks2014
IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'AdventureWorks2014')
BEGIN
	DROP DATABASE AdventureWorks2014
END
GO
RESTORE DATABASE AdventureWorks2014 FROM  DISK = N'$(SUBDIR)SetupFiles\AdventureWorks2014.bak' WITH  REPLACE,
MOVE N'AdventureWorks2014_Data' TO N'$(SUBDIR)SetupFiles\AdventureWorks2014.mdf', 
MOVE N'AdventureWorks2014_Log' TO N'$(SUBDIR)SetupFiles\AdventureWorks2014.ldf'
GO
ALTER AUTHORIZATION ON DATABASE::AdventureWorks2014 TO [ADVENTUREWORKS\Student];
GO

-- Perform any other data modification tasks to prepare data for the demos