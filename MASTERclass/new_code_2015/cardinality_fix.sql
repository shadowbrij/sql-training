select * from sales.SalesOrderHeader

select SalesPersonID, count(SalesPersonID) from Sales.SalesOrderHeader
group by SalesPersonID
order by count(SalesPersonID)


USE [AdventureWorks2012]
GO

DECLARE @SPID int;
SET @SPID = 285;
select * from Sales.SalesOrderHeader
where SalesPersonID = @SPID

-- check execution plan
-- we get a scan plan
-- hover the curson over the arrow between select and filder iterator
-- there is a cardinality issue here. actual number of rows 16 vs 223 estimated

-- fix
DECLARE @SPID int;
SET @SPID = 285;
select * from Sales.SalesOrderHeader
where SalesPersonID = @SPID
option (optimize for(@SPID= 285))


-- check now.
-- we get a seek plan
-- and take the cursor over the arrow between compute scalar and nested loop. cardinality is much better,