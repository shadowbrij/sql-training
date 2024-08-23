use master
go

DROP DATABASE IFITestDB
GO


CREATE DATABASE IFITestDB
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'IFITestDB', FILENAME = 'C:\SQLMaestros\IFITestDB.mdf', SIZE = 100MB , MAXSIZE = UNLIMITED)
LOG ON
	( NAME = N'IFITestDB_Log',
	  FILENAME = N'E:\SQLMaestros\IFITestDB.ldf',
          SIZE = 10MB,
          MAXSIZE = 50MB,
          FILEGROWTH = 10%)


use IFITestDB
go


CREATE TABLE LoadData
(
	LoadDataID	int	IDENTITY,
	LoadDataWhen	datetime	CONSTRAINT LoadDataWhenDefault
									DEFAULT getdate(),
	LoadDataWho		sysname		CONSTRAINT LoadDataWhoDefault
									DEFAULT user_name(),
	LoadDataFiller	nchar(200)	CONSTRAINT LoadDataFillerDefault
									DEFAULT 'Junk data to fill the row'
)
go


-- select * from loaddata
-- now log on SSD


use master

go

DROP DATABASE IFITestDB
GO


CREATE DATABASE IFITestDB
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'IFITestDB', FILENAME = 'C:\SQLMaestros\IFITestDB.mdf', SIZE = 100MB , MAXSIZE = UNLIMITED)
LOG ON
	( NAME = N'IFITestDB_Log',
	  FILENAME = N'C:\SQLMaestros\IFITestDB.ldf',
          SIZE = 10MB,
          MAXSIZE = 50MB,
          FILEGROWTH = 10%)


use IFITestDB
go


CREATE TABLE LoadData
(
	LoadDataID	int	IDENTITY,
	LoadDataWhen	datetime	CONSTRAINT LoadDataWhenDefault
									DEFAULT getdate(),
	LoadDataWho		sysname		CONSTRAINT LoadDataWhoDefault
									DEFAULT user_name(),
	LoadDataFiller	nchar(200)	CONSTRAINT LoadDataFillerDefault
									DEFAULT 'Junk data to fill the row'
)
go

