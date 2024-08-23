-- demo 1: mistake number 1: missing index feature

USE LOB
GO

-- check if indexes or stats exist

sp_helpindex 'tblOrders';
GO
sp_helpstats 'tblOrders';
GO

-- query to be tuned
-- turn on actual execution plan

select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderid > 1 AND tblorders.orderid < 1000

--DBCC FREEPROCCACHE
 drop index [1_idx_tblorders_orderid] on tblorders
 drop index [2_idx_tblorders_empid_orderid] on tblorders


 -- did we create an unused index?

SELECT DB_NAME(database_id) as database_name, OBJECT_NAME(s.object_id) as object_name, i.name, s.* FROM sys.dm_db_index_usage_stats s join sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id and s.object_id = object_id('dbo.tblorders')
where DB_NAME(database_id) = 'LOB'


-- compare performances

select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
with (index(0))
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderid > 100 AND tblorders.orderid < 10000
GO

select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderid > 100 AND tblorders.orderid < 10000
GO

select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
with (index([2_idx_tblOrders_empid_orderid]))
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderid > 100 AND tblorders.orderid < 10000
GO


-- but really, then why did the optimizer recommend the other index???

select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
--where tblorders.orderid > 100 AND tblorders.orderid < 10000
GO

select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderid > 1 AND tblorders.orderid < 1000000
GO