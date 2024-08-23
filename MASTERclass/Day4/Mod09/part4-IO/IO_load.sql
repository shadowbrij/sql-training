DBCC DROPCLEANBUFFERS
GO

------

USE TUNING
GO
select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderdate='20030101'
--order by tblCustomers.custid, tblEmployees.empid, tblOrders.orderdate
GO

------

USE TUNING
GO
select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderdate='20030101'
--order by tblCustomers.custid, tblEmployees.empid, tblOrders.orderdate
GO

------

USE TUNING
GO
select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderdate='20030101'
--order by tblCustomers.custid, tblEmployees.empid, tblOrders.orderdate
GO


USE TUNING
GO
select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderdate='20030101'
--order by tblCustomers.custid, tblEmployees.empid, tblOrders.orderdate
GO

------

USE TUNING
GO
select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderdate='20030101'
--order by tblCustomers.custid, tblEmployees.empid, tblOrders.orderdate
GO

------

USE TUNING
GO
select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderdate='20030101'
--order by tblCustomers.custid, tblEmployees.empid, tblOrders.orderdate
GO