select * into sales2 from sales

--full table scan
select * from sales2

--clustered index scan
select * from sales

--clustered index seek

select * from sales where saleid='F07D8C7B-030F-43A1-8158-0003C73ABF65'


--index scan
select saleid,productid from sales where productid=1 

create nonclustered index ix_productsearch on sales
(productid asc)with (pad_index=off,statistics_norecompute=off,sort_in_tempdb=off)
go

--index seek
select saleid,productid from sales where productid=1 

--index scan
select saleid,productid,employeeid from sales where productid=1 and employeeid=2

--include employeeid to the ix_productsearch index using inclue column tab in properties of the index

--index seek
select saleid,productid,employeeid from sales where productid=1 and employeeid=2


--join(loop)

select saleid,name,price,quantity
from products p join sales s 
on p.productid=s.productid
option(loop join)

--add quantity to the index 

--join(merge)

select saleid,name,price,quantity
from products p join sales s 
on p.productid=s.productid
option(merge join)

--join(haash)

select saleid,name,price,quantity
from products p join sales s 
on p.productid=s.productid
option(hash join)

--to display plan in tabular format
set showplan_all on

--to display plan in gui format
set showplan_all off

--to display all stats
sp_helpstats 'sales','all'

--to display specified index stats
dbcc show_statistics('sales','PK__Sales__1EE3C41FA03EE1F5')