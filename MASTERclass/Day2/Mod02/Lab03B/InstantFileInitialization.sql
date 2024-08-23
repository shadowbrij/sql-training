--Recycle errorlog
EXEC sp_cycle_errorlog
GO

--Check zeroing of data and files
DBCC TRACEON(3004,3605,-1)
GO
CREATE DATABASE IFITestDB
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'IFITestDB', FILENAME = 'c:\SQLMaestros\IFITestDB.mdf', SIZE = 10240MB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024MB )
GO
EXEC xp_readerrorlog 0,1,"zeroing", "0x0"
GO
DROP DATABASE IFITestDB
GO

--Check zeroing of log files only
-- do the aboev again after giving PVMT permissions