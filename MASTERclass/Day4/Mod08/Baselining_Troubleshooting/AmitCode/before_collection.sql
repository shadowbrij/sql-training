-- run before tests

use baseline
GO

create table DiskSpaceUsage_beforeTests
(
    name nvarchar(128),
    [rows] char(11),
    reserved varchar(18),
    data varchar(18),
    index_size varchar(18),
    unused varchar(18)
)

use AdventureWorks2012
GO


insert into baseline.dbo.DiskSpaceUsage_beforeTests
    exec sp_msforeachtable 'sp_spaceused ''?'''

--select * from baseline.dbo.DiskSpaceUsage_beforeTests order by cast(replace(reserved,' kb','') as int) desc



use AdventureWorks2012
go

SELECT OBJECT_NAME (id) tablename
     , COUNT (1)        nr_columns
     , SUM (length)     maxrowlength
into baseline.dbo.TableRowLengths
FROM   syscolumns
GROUP BY OBJECT_NAME (id)
ORDER BY OBJECT_NAME (id)

-- select * from baseline.dbo.TableRowLengths