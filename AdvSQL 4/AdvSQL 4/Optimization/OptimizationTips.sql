--don't( * is not performance friendly)
select * from sales

--do (rewrite using only what you need)

select employeeid,quantity,saledate from sales

---------------------
--inequality operators force table scans
--don't
select * from sales where quantity!=0

--do
select * from sales where quantity>0

-----------------
--don't(having filters rows after they are returned

select productid,sum(quantity) as totalQty
from sales 
group by productid
having sum(quantity)>0
go

--do(where filters row out before they are return ed
select productid,sum(quantity) as totalQty
from sales 
where quantity>0
group by productid

go

--IN is the best when filter criteria is in subquery

select saleid,productid,saledate
from sales 
where productid in(select productid from products where discontinuedflag=0)

--Exists is best when filter crietria in in main query

select saleid,productid,saledate
from sales
where datepart(yyyy,saledate)=year(getdate())
and exists(select * from products where productid=sales.productid)

--use DMVs to find poor or long running queries
--return top 10 longest running queries
select top 10  qs.total_elapsed_time/qs.execution_count/1000000.0 as AverageSeconds,
 qs.total_elapsed_time/1000000.0 as TotalSeconds,
 qt.text as Query,
 db_name(qt.dbid) as DatabaseName
from 
	sys.dm_exec_query_stats qs
	cross apply
	sys.dm_exec_sql_text(qs.sql_handle) as qt
	left outer join
	sys.objects o on qt.objectid=o.object_id
order by
	averageseconds desc

--Return Top 10 most expensive queries

select top 10   
(total_logical_reads + total_logical_writes)/qs.execution_count as AverageIO,
 (total_logical_reads + total_logical_writes) As TotalIO,
 qt.text as Query,
 db_name(qt.dbid) as DatabaseName
from 
	sys.dm_exec_query_stats qs
	cross apply
	sys.dm_exec_sql_text(qs.sql_handle) as qt
	left outer join
	sys.objects o on qt.objectid=o.object_id
order by
	averageio desc