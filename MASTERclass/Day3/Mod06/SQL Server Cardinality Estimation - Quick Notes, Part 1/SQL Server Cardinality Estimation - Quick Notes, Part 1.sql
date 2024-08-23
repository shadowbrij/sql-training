use AdventureWorks2012
go

-- Turn On Actual Execution Plan
select * from sales.SalesOrderHeader
where TotalDue = 1457.3288
go

select * from sales.SalesOrderHeader
where TotalDue = 472.3108
go

declare @td float
set @td = 1457.3288
select * from sales.SalesOrderHeader
where TotalDue = @td

declare @td float
set @td = 53623
select * from sales.SalesOrderHeader
where TotalDue = @td

-- Total Rows * Density (where Density is 1/number of distinct values)

select count(*) from sales.SalesOrderHeader
select count(distinct totaldue) from sales.SalesOrderHeader

select count(*)*cast((1.*1/count(distinct totaldue))as decimal(18,17))
from sales.SalesOrderHeader