--- what is slot array?
--- is it ordered? logical? physical?
-- ARE RECORDS ALWAYS LOGICALLY ORDERED?
-- WHAT IS THE RELATION BETWEEN SLOT ARRAY AND THE RECORS ON THE PAGE?


USE MASTER;
GO

IF DATABASEPROPERTY (N'PageSplit', 'Version') > 0 DROP DATABASE PageSplit;
GO

CREATE DATABASE PageSplit;
GO

USE PageSplit;
GO

-- DROP TABLE example

CREATE TABLE example (col1 INT, col2 VARCHAR (1000));
CREATE CLUSTERED INDEX examplecol1 ON example (col1);

GO

-- select * from example

--fill up a page in the index, but leave a gap in the col1 values

INSERT INTO example VALUES (1, REPLICATE ('a', 800));

INSERT INTO example VALUES (2, REPLICATE ('b', 800));

INSERT INTO example VALUES (3, REPLICATE ('c', 800));

INSERT INTO example VALUES (4, REPLICATE ('d', 800));

-- leave a gap at 5

INSERT INTO example VALUES (6, REPLICATE ('f', 800));

INSERT INTO example VALUES (7, REPLICATE ('g', 800));

INSERT INTO example VALUES (8, REPLICATE ('h', 800));

INSERT INTO example VALUES (9, REPLICATE ('i', 800));

GO

-- How to find out what the first index page???

DBCC IND ('PageSplit', 'example', 1);
GO

--DBCC IND lists all the pages that are allocated to an index



--PageFID - the file ID of the page
--PagePID - the page number in the file
--IAMFID - the file ID of the IAM page that maps this page (this will be NULL for IAM pages themselves as they're not self-referential)
--IAMPID - the page number in the file of the IAM page that maps this page
--ObjectID - the ID of the object this page is part of
--IndexID - the ID of the index this page is part of
--PartitionNumber - the partition number (as defined by the partitioning scheme for the index) of the partition this page is part of
--PartitionID - the internal ID of the partition this page is part of
--iam_chain_type - see IAM chains and allocation units in SQL Server 2005•PageType - the page type. Some common ones are:
--1 - data page
--2 - index page
--3 and 4 - text pages
--8 - GAM page
--9 - SGAM page
--10 - IAM page
--11 - PFS page
--IndexLevel - what level the page is at in the index (if at all). Remember that index levels go from 0 at the leaf to N at the root page (except in clustered indexes in SQL Server 2000 and 7.0 - where there's a 0 at the leaf level (data pages) and a 0 at the next level up (first level of index pages))
--NextPageFID and NextPagePID - the page ID of the next page in the doubly-linked list of pages at this level of the index
--PrevPageFID and PrevPagePID - the page ID of the previous page in the doubly-linked list of pages at this level of the indexSo you can see we've got a single page clustered index with an IAM page. Note that the page IDs returned may differ on your server. Let's look at the data page:

-- before we proceed further, let us also check index statistics

SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id()
	, object_id('dbo.example')
	, NULL
	, NULL
	, 'DETAILED');
go



DBCC TRACEON (3604);
GO

DBCC PAGE (PageSplit, 1,264, 3);
GO

-- DBCC PAGE syntax
-- dbcc page ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ])
--0 - print just the page header
--1 - page header plus per-row hex dumps and a dump of the page slot array (unless its a page that doesn't have one, like allocation bitmaps) 
--2 - page header plus whole page hex dump
--3 - page header plus detailed per-row interpretation


INSERT INTO example VALUES (5, REPLICATE ('e', 800));
GO

-- check the page structure again and see the order of data and the slot array

DBCC IND ('PageSplit', 'example', 1);
GO

SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id()
	, object_id('dbo.example')
	, NULL
	, NULL
	, 'DETAILED');
go


-- cleanup

use master
GO

DROP database PageSplit
GO
