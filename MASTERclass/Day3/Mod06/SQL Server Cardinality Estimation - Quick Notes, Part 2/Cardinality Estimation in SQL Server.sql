use AdventureWorks2012
go

-- Turn On Actual Execution Plan
select * from sales.SalesOrderHeader
where TotalDue + TotalDue > 2000
go

select * from sales.SalesOrderHeader
where TaxAmt > 2000
go

-- Turn On Actual Execution Plan
select * from sales.SalesOrderHeader
where TaxAmt + TotalDue > 472.3108
go



select count(*) from sales.SalesOrderHeader

select cast((1.*30/100)as decimal(18,17))*count(totaldue)
from sales.SalesOrderHeader
