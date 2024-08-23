-- first give permissions to everyone on C drive then run the below script
-- restore adventureworks database
----------------
--ABPSPR database setup
----------------
USE [master];
GO

IF DATABASEPROPERTYEX (N'PWISample', N'Version') > 0
BEGIN
	ALTER DATABASE [PWISample] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [PWISample];
END
GO

CREATE DATABASE [PWISample] ON PRIMARY (
    NAME = N'PWISample_data',
    FILENAME = N'C:\Data\PWISample_data.mdf')
LOG ON (
    NAME = N'PWISample_log',
    FILENAME = N'C:\Data\PWISample_log.ldf',
    SIZE = 250MB,
    FILEGROWTH = 25MB);
GO

ALTER DATABASE [PWISample] SET RECOVERY SIMPLE;
GO

USE [PWISample];
GO

CREATE TABLE [PWISampleTable] (
	[c1] INT IDENTITY);
CREATE CLUSTERED INDEX [PWISampleTable_CL] ON
	[PWISampleTable] ([c1]);
GO


---------------------------
--ABIBG tuning database setup
---------------------------

SET NOCOUNT ON;
USE master;
GO
IF DB_ID('Tuning') IS NULL
  CREATE DATABASE Tuning;
GO
USE Tuning;
GO

-- Creating and Populating the Numbers Auxiliary Table
IF OBJECT_ID('dbo.Numbers') IS NOT NULL
  DROP TABLE dbo.Numbers;
GO
CREATE TABLE dbo.Numbers(n INT NOT NULL PRIMARY KEY);



DECLARE @max AS INT, @rc AS INT;
SET @max = 1000000;
SET @rc = 1;

INSERT INTO Numbers VALUES(1);
WHILE @rc * 2 <= @max
BEGIN
  INSERT INTO dbo.Numbers SELECT n + @rc FROM dbo.Numbers;
  SET @rc = @rc * 2;
END

INSERT INTO dbo.Numbers 
  SELECT n + @rc FROM dbo.Numbers WHERE n + @rc <= @max;
GO


-- Drop Data Tables if Exist
IF OBJECT_ID('dbo.vwEmptblOrders') IS NOT NULL
  DROP VIEW dbo.vwEmptblOrders;
GO
IF OBJECT_ID('dbo.tblOrders') IS NOT NULL
  DROP TABLE dbo.tblOrders;
GO
IF OBJECT_ID('dbo.tblCustomers') IS NOT NULL
  DROP TABLE dbo.tblCustomers;
GO
IF OBJECT_ID('dbo.tblEmployees') IS NOT NULL
  DROP TABLE dbo.tblEmployees;
GO
IF OBJECT_ID('dbo.tblShippers') IS NOT NULL
  DROP TABLE dbo.tblShippers;
GO

-- Data Distribution Settings
DECLARE
  @numtblOrders   AS INT,
  @numcusts    AS INT,
  @numemps     AS INT,
  @NumbertblShippers AS INT,
  @numyears    AS INT,
  @startdate   AS DATETIME;

SELECT
  @numtblOrders   =   1000000,
  @numcusts    =     20000,
  @numemps     =       500,
  @NumbertblShippers =         5,
  @numyears    =         4,
  @startdate   = '20030101';

-- Creating and Populating the tblCustomers Table
CREATE TABLE dbo.tblCustomers
(
  custid   CHAR(11)     NOT NULL,
  custname NVARCHAR(50) NOT NULL
);

INSERT INTO dbo.tblCustomers(custid, custname)
  SELECT
    'C' + RIGHT('000000000' + CAST(n AS VARCHAR(10)), 10) AS custid,
    N'Cust_' + CAST(n AS VARCHAR(10)) AS custname
  FROM dbo.Numbers
  WHERE n <= @numcusts;

ALTER TABLE dbo.tblCustomers ADD
  CONSTRAINT PK_tblCustomers PRIMARY KEY(custid);


-- Creating and Populating the tblEmployees Table
CREATE TABLE dbo.tblEmployees
(
  empid     INT          NOT NULL,
  firstname NVARCHAR(25) NOT NULL,
  lastname  NVARCHAR(25) NOT NULL
);

INSERT INTO dbo.tblEmployees(empid, firstname, lastname)
  SELECT n AS empid,
    N'Fname_' + CAST(n AS NVARCHAR(10)) AS firstname,
    N'Lname_' + CAST(n AS NVARCHAR(10)) AS lastname
  FROM dbo.Numbers
  WHERE n <= @numemps;

ALTER TABLE dbo.tblEmployees ADD
  CONSTRAINT PK_tblEmployees PRIMARY KEY(empid);

-- Creating and Populating the tblShippers Table
CREATE TABLE dbo.tblShippers
(
  shipperid   VARCHAR(5)   NOT NULL,
  shippername NVARCHAR(50) NOT NULL
);

INSERT INTO dbo.tblShippers(shipperid, shippername)
  SELECT shipperid, N'Shipper_' + shipperid AS shippername
  FROM (SELECT CHAR(ASCII('A') - 2 + 2 * n) AS shipperid
        FROM dbo.Numbers
        WHERE n <= @NumbertblShippers) AS D;

ALTER TABLE dbo.tblShippers ADD
  CONSTRAINT PK_tblShippers PRIMARY KEY(shipperid);

-- Creating and Populating the tblOrders Table
CREATE TABLE dbo.tblOrders
(
  orderid   INT        NOT NULL,
  custid    CHAR(11)   NOT NULL,
  empid     INT        NOT NULL,
  shipperid VARCHAR(5) NOT NULL,
  orderdate DATETIME   NOT NULL,
  filler    CHAR(155)  NOT NULL DEFAULT('a')
);

INSERT INTO dbo.tblOrders(orderid, custid, empid, shipperid, orderdate)
  SELECT n AS orderid,
    'C' + RIGHT('000000000'
            + CAST(
                1 + ABS(CHECKSUM(NEWID())) % @numcusts
                AS VARCHAR(10)), 10) AS custid,
    1 + ABS(CHECKSUM(NEWID())) % @numemps AS empid,
    CHAR(ASCII('A') - 2
           + 2 * (1 + ABS(CHECKSUM(NEWID())) % @NumbertblShippers)) AS shipperid,
      DATEADD(day, n / (@numtblOrders / (@numyears * 365.25)), @startdate)
        -- late arrival with earlier date
        - CASE WHEN n % 10 = 0
            THEN 1 + ABS(CHECKSUM(NEWID())) % 30
            ELSE 0 
          END AS orderdate
  FROM dbo.Numbers
  WHERE n <= @numtblOrders
  ORDER BY CHECKSUM(NEWID());

--CREATE CLUSTERED INDEX idx_cl_od ON dbo.tblOrders(orderdate);

--CREATE NONCLUSTERED INDEX idx_nc_sid_od_cid
--  ON dbo.tblOrders(shipperid, orderdate, custid);

--CREATE UNIQUE INDEX idx_unc_od_oid_i_cid_eid
--  ON dbo.tblOrders(orderdate, orderid)
--  INCLUDE(custid, empid);

--ALTER TABLE dbo.tblOrders ADD
--  CONSTRAINT PK_tblOrders PRIMARY KEY NONCLUSTERED(orderid),
--  CONSTRAINT FK_tblOrders_tblCustomers
--    FOREIGN KEY(custid)    REFERENCES dbo.tblCustomers(custid),
--  CONSTRAINT FK_tblOrders_tblEmployees
--    FOREIGN KEY(empid)     REFERENCES dbo.tblEmployees(empid),
--  CONSTRAINT FK_tblOrders_tblShippers
--    FOREIGN KEY(shipperid) REFERENCES dbo.tblShippers(shipperid);
--GO


-- view the populated data

--select * from dbo.numbers
--select * from dbo.tblCustomers
--select * from dbo.tblEmployees
--select * from dbo.tblOrders
--select * from dbo.tblShippers











-- Clearing data from cache
--DBCC DROPCLEANBUFFERS;

-- Clearing execution plans from cache
--DBCC FREEPROCCACHE;
--GO



--------------------
--RG setup
--------------------

USE [AdventureWorks]
GO

/****** Object:  View [dbo].[vw_intensive]    Script Date: 11/23/2007 07:42:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_intensive]
AS
SELECT     SUM(Sales.SalesOrderHeader.TotalDue) AS SumSales, Production.Product.Name, Sales.CreditCard.CardType, Person.Contact.LastName
FROM         Sales.SalesOrderHeader INNER JOIN
                      Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID INNER JOIN
                      Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID INNER JOIN
                      Sales.CreditCard ON Sales.SalesOrderHeader.CreditCardID = Sales.CreditCard.CreditCardID AND 
                      Sales.SalesOrderHeader.CreditCardID = Sales.CreditCard.CreditCardID INNER JOIN
                      Person.Contact ON Sales.SalesOrderHeader.ContactID = Person.Contact.ContactID AND Sales.SalesOrderHeader.ContactID = Person.Contact.ContactID 
GROUP BY Production.Product.Name, Sales.CreditCard.CardType, Person.Contact.LastName
GO

CREATE PROCEDURE dbo.IntensiveProc
AS
DECLARE @i int
SET @i = 0
WHILE @i < (SELECT COUNT(*) FROM dbo.vw_intensive) / 5000
BEGIN
	SET @i = (SELECT @i + 1)
	DECLARE @c int
	SET @c = (SELECT MAX(SumSales) FROM dbo.vw_intensive) + (SELECT MIN(SumSales) FROM dbo.vw_intensive) + (SELECT AVG(SumSales) FROM dbo.vw_intensive)
END
SELECT * FROM dbo.vw_intensive
GO


------------------
--Generate Acitity - ADW
------------------

USE AdventureWorks
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


