set statistics IO ON
set statistics time on

-- turn on actual execution plan

use tuning
go


select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where orderdate = '2005-01-12 00:00:00.000'
--order by tblCustomers.custid, tblEmployees.empid, tblOrders.orderdate