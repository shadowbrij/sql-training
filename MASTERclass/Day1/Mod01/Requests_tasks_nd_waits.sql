-- Difference between requests and tasks
-- by AMit Bansal

-- connection 1
-- run the below code and check the output

select * from sys.dm_os_tasks
where session_id > 50

select * from sys.dm_os_waiting_tasks where session_id > 50

select * from sys.dm_exec_requests
where session_id > 50


-- connection 2
-- run the below query in conenction 2 and include actual execution plan
-- immediately go and run the next pice of code
USE AdventureWorks2008R2
GO

select * from sales.SalesOrderDetail
order by LineTotal DESC
GO


-- connection 1
-- run the below code and check the output

select * from sys.dm_os_tasks
where session_id > 50

select * from sys.dm_os_waiting_tasks where session_id > 50

select * from sys.dm_exec_requests
where session_id > 50