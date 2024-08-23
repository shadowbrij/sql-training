-- Cause CXPACKET
-- Execute the below code and IMMEDIATELY go back to the MonitorCXPACKET.sql query window and execute the code there once
USE [AdventureWorks2014];
GO

DECLARE @cnt int = 0
while @cnt<10
begin
DBCC DROPCLEANBUFFERS
select * from sales.SalesOrderDetail
order by LineTotal DESC
set @cnt = @cnt+1
end
GO