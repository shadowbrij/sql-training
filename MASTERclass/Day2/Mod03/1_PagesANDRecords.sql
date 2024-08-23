USE [master];
GO

IF DATABASEPROPERTYEX (N'PagesANDRecords', N'Version') > 0
BEGIN
	ALTER DATABASE [PagesANDRecords] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [PagesANDRecords];
END
GO

CREATE DATABASE [PagesANDRecords];
GO

USE [PagesANDRecords];
GO

-- Create a sample table
CREATE TABLE [SampleTable] (
	[intCol1]		INT IDENTITY,
	[intCol2]		INT,
	[vcharCol]		VARCHAR (8000),
	[vcharCol2]		VARCHAR (8000),
	[lobCol]		VARCHAR (MAX));

INSERT INTO [SampleTable] VALUES (
	1, REPLICATE ('Row1', 600), 'a', REPLICATE ('Row1Lobs', 1000));
INSERT INTO [SampleTable] VALUES (
	2, REPLICATE ('Row2', 600), 'b', REPLICATE ('Row2Lobs', 1000));
INSERT INTO [SampleTable] VALUES (
	3, REPLICATE ('Row3', 600), 'c', REPLICATE ('Row3Lobs', 1000));
INSERT INTO [SampleTable] VALUES (
	4, REPLICATE ('Row4', 600), 'd', REPLICATE ('Row4Lobs', 1000));
GO

-- look at pages
DBCC IND (N'PagesANDRecords', N'SampleTable', -1);
GO

-- look at the first page
DBCC TRACEON (3604);
GO

-- Option 1 is a hex dump of each record
-- plus interpreting the slot array.
DBCC PAGE (N'PagesANDRecords', 1, 285, 1);
GO

-- Data page with data records

-- Option 2 is a hex dump of the page plus
-- interpreting the slot array
DBCC PAGE (N'PagesANDRecords', 1, 285, 2);
GO

-- Option 3 interprets each record fully
DBCC PAGE (N'PagesANDRecords', 1, 285, 3);
GO

-- did you see the LOB link?.
-- see the text page
DBCC PAGE (N'PagesANDRecords', 1, 283, 3);
GO


-- lets create a forwarding record
UPDATE [SampleTable]
	SET [vcharCol] = REPLICATE ('LongRow2', 1000)
	WHERE [intCol2] = 2;
GO

-- Look at the modified page again
DBCC PAGE (N'PagesANDRecords', 1, 285, 3);
GO

--- follow the forwaridng record
-- you may want to check DBCC IND again
DBCC PAGE (N'PagesANDRecords', 1, 299, 3);
GO

-- there is a back link also

-- let us create a clustered index
CREATE CLUSTERED INDEX [Dbcc_CL]
	ON [SampleTable] ([intCol1]);
GO

-- look at all the pages again
DBCC IND (N'PagesANDRecords', N'SampleTable', -1);
GO

-- lets take the index page, type = 2.
DBCC PAGE (N'PagesANDRecords', 1, 312, 1);
GO

-- index records? see in more detail...
-- so how many data pages does DBCC IND show?
-- what is this uniquifier?
DBCC PAGE (N'PagesANDRecords', 1, 312, 3);
GO


-- see the first page again
DBCC IND (N'PagesANDRecords', N'SampleTable', -1);
GO

DBCC PAGE (N'PagesANDRecords', 1, 301, 3);
GO

-- lets do row-overflow
UPDATE [SampleTable]
	SET [vcharCol2] = REPLICATE ('LongRow1', 900)
	WHERE [intCol1] = 1;
GO

-- check the link to the new row-overflow page
-- check DBCC IND again and see the row over flow addition, page and IAM
DBCC PAGE (N'PagesANDRecords', 1, 301, 3);
GO

-- create a non-clustered index
CREATE NONCLUSTERED INDEX [Dbcc_NCL]
	ON [SampleTable] ([intCol2]);
GO

-- check DBCC IND again, NC meta data added
DBCC IND (N'PagesANDRecords', N'SampleTable', -1);
GO

-- let us check NC page now
DBCC PAGE (N'PagesANDRecords', 1, 316, 3);
GO


-- Now drop the clustered index and look
-- again at the nonclustered index
DROP INDEX [Dbcc_CL] ON [SampleTable];
GO

DBCC IND (N'PagesANDRecords', N'SampleTable', -1);
GO

DBCC PAGE (N'PagesANDRecords', 1, 318, 3);
GO

-- coorelate
SELECT
	*,
	%%PHYSLOC%% as phy
FROM
	[SampleTable]
GO

-- physical order of the row vs key order vs slot array order

USE [master];
GO

IF DATABASEPROPERTYEX (N'PagesANDRecords', N'Version') > 0
BEGIN
	ALTER DATABASE [PagesANDRecords] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [PagesANDRecords];
END
GO

CREATE DATABASE [PagesANDRecords];
GO

USE [PagesANDRecords];
GO

-- Create a test table
CREATE TABLE [OrderTest] ([c1] INT, [c2] VARCHAR (10));
CREATE CLUSTERED INDEX [OrderCL] ON [OrderTest] ([c1]);
GO

-- Insert values from 2 to 5, missing c1 = 1
INSERT INTO [OrderTest] VALUES (2, REPLICATE ('b', 10));
INSERT INTO [OrderTest] VALUES (3, REPLICATE ('c', 10));
INSERT INTO [OrderTest] VALUES (4, REPLICATE ('d', 10));
INSERT INTO [OrderTest] VALUES (5, REPLICATE ('e', 10));
GO

-- Look at the page
DBCC IND (N'PagesANDRecords', N'OrderTest', -1);
GO

DBCC PAGE (N'PagesANDRecords', 1, 242, 2);
GO

-- Now insert c1 = 1 and look at the page again
INSERT INTO [OrderTest] VALUES (1, REPLICATE ('a', 10));
GO

DBCC PAGE (N'PagesANDRecords', 1, 242, 2);
GO

-- Check out the record *offset* on the page
-- even though it's slot # 0

-- Find record location
SELECT
	*,
	%%PHYSLOC%%
FROM
	[OrderTest];
GO

-- And now human-readable...
SELECT
	[o].*,
	[p].*
FROM
	[OrderTest] [o]
CROSS APPLY
	fn_PhysLocCracker (%%PHYSLOC%%) [p];
GO