USE TUNING
GO

select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
GO 100