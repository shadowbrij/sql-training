create database test
go

use test
go

-- basic catalog information 

CREATE TABLE dbo.employee( 
               emp_lname  varchar(15)   NOT NULL, 
               emp_fname  varchar(10)   NOT NULL, 
               address    varchar(30)   NOT NULL, 
               phone      char(12)      NOT NULL, 
               job_level  smallint      NOT NULL 
);


-- Retrieving some metadata

SELECT  * from sys.tables 
WHERE object_id=object_id('dbo.employee');

SELECT  * from sys.columns
WHERE object_id=object_id('dbo.employee');

SELECT  object_id, name, index_id, type_desc 
FROM sys.indexes 
WHERE object_id=object_id('dbo.employee');
 
SELECT * 
FROM sys.partitions 
WHERE object_id=object_id('dbo.employee');




-- Each row also has a value in the column called container_id that can be joined with partition_id 
-- in sys.partitions, as shown in this query:

select * from sys.allocation_units

SELECT object_name(object_id) AS name,  
    partition_id, partition_number AS pnum,  rows,  
    allocation_unit_id AS au_id, type_desc as page_type_desc, 
    total_pages AS pages 
FROM sys.partitions p JOIN sys.allocation_units a 
   ON p.partition_id = a.container_id 
WHERE object_id=object_id('dbo.employee');


-- alter the table to add row-overflow data and LOB data

ALTER TABLE dbo.employee ADD resume_short varchar(8000); 
ALTER TABLE dbo.employee ADD resume_long text;

-- run the join again

SELECT object_name(object_id) AS name,  
    partition_id, partition_number AS pnum,  rows,  
    allocation_unit_id AS au_id, type_desc as page_type_desc, 
    total_pages AS pages 
FROM sys.partitions p JOIN sys.allocation_units a 
   ON p.partition_id = a.container_id 
WHERE object_id=object_id('dbo.employee');


-- will this work??

CREATE TABLE dbo.bigrows
(a char(3000),
    b char(3000),
    c char(2000),
    d char(60) )




-- what if you add an index??
-- first add a clustered index and run the allocation query, then add a non clustered index... and the run the allocation query


CREATE CLUSTERED INDEX cl_idx_lname
ON dbo.employee (emp_lname)

CREATE INDEX cl_idx_fname
ON dbo.employee (emp_fname)



-- The following query joins all three views —sys.indexes, sys.partitions, and sys.allocation_units—
-- to show you the table name, index name and type, page type, and space usage information for 
-- the dbo.employee table:

SELECT  convert(char(8),object_name(i.object_id)) AS table_name, 
    i.name AS index_name, i.index_id, i.type_desc as index_type,
    partition_id, partition_number AS pnum,  rows, 
    allocation_unit_id AS au_id, a.type_desc as page_type_desc, 
    total_pages AS pages
FROM sys.indexes i JOIN sys.partitions p  
        ON i.object_id = p.object_id AND i.index_id = p.index_id
    JOIN sys.allocation_units a
        ON p.partition_id = a.container_id
WHERE i.object_id=object_id('dbo.employee');




--try this (optional)
SELECT a.*, object_name(object_id) AS name,  
    partition_id, partition_number AS pnum,  rows,  
    allocation_unit_id AS au_id, type_desc as page_type_desc, 
    total_pages AS pages 
FROM sys.partitions p JOIN sys.system_internals_allocation_units a 
   ON p.partition_id = a.container_id 
WHERE object_id=object_id('dbo.employee');


--drop the index and continue,...
DROP INDEX cl_idx_lname ON dbo.employee
GO
DROP INDEX cl_idx_fname ON dbo.employee
GO



--DBCC PAGE
--examining a page

DBCC TRACEON(3604);
GO 
DBCC PAGE (pubs, 1, 157, 1); 
GO 

--get the complete memory dump of the page
DBCC PAGE (pubs, 1, 157, 2); 
GO 



--finding a physical page
--option 1, play with hexa decial value yourself..

USE tempdb;
CREATE TABLE Fixed  
( 
Col1 char(5)     NOT NULL, 
Col2 int         NOT NULL, 
Col3 char(3)     NULL, 
Col4 char(6)     NOT NULL  
);
INSERT Fixed VALUES ('ABCDE', 123, NULL, 'CCCC');



-- The following query gives the value for first_page in the Fixed table:

select * from sys.system_internals_allocation_units
select * from sys.allocation_units


SELECT a.*, object_name(object_id) AS name,  
    rows, type_desc as page_type_desc, 
    total_pages AS pages, first_page 
FROM sys.partitions p  JOIN sys.system_internals_allocation_units a 
   ON p.partition_id = a.container_id 
WHERE object_id=object_id('dbo.Fixed'); 



-- Lets convert the hexadecimal value(such as 0xCF0400000100) to a file_number:page_number format: 

CREATE FUNCTION convert_page_nums (@page_num binary(6)) 
   RETURNS varchar(11)  
AS  
  BEGIN 
   RETURN(convert(varchar(2), (convert(int, substring(@page_num, 6, 1))  
          * power(2, 8)) +  
             (convert(int, substring(@page_num, 5, 1)))) + ':' +  
               convert(varchar(11),  
   (convert(int, substring(@page_num, 4, 1)) * power(2, 24)) +  
   (convert(int, substring(@page_num, 3, 1)) * power(2, 16)) +  
   (convert(int, substring(@page_num, 2, 1)) * power(2, 8)) +  
   (convert(int, substring(@page_num, 1, 1)))) ) 
  END;
  
  -- now call the function with the hexaD value  
  SELECT dbo.convert_page_nums(0xBB0000000100);
  
  
  -- option 2
  -- DBCC IND commanad
  
  DBCC IND(tempdb, Fixed, -1);