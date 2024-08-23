use AdventureWorks2012
go

dbcc freeproccache
go


select * from Person.Person
go
-- to viewe the cached plans
SELECT usecounts, cacheobjtype, objtype, [text], P.*
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text(plan_handle)

create proc PlanTest
as
select * from Person.Person

select * from Production.Product

select * from HumanResources.Department
go

-- drop procedure PlanTest

dbcc freeproccache
go

exec PlanTest
go
-- to viewe the cached plans
SELECT usecounts, cacheobjtype, objtype, [text], P.*
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text(plan_handle)

select * from sys.dm_exec_query_plan(0x050008004666B938B0C9D9750800000001000000000000000000000000000000000000000000000000000000)

-- to viewe the cached plans
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';


-- blocking scenario with SPs

-- connection 1

use AdventureWorks2012
go

begin tran
update Production.Product
set ListPrice = 10
where ProductID = 1
-- rollback

-- connection 2

use AdventureWorks2012
go

exec PlanTest
go

-- this connection

select * from sys.dm_os_waiting_tasks
where session_id > 50

dbcc inputbuffer(56)

select * from sys.dm_exec_requests
where session_id = 56

select * from sys.dm_exec_sql_text
(0x030008004666B938566F6D01C4A3000001000000000000000000000000000000000000000000000000000000)

select * from sys.dm_exec_query_plan
(0x050008004666B938B0C9D9750800000001000000000000000000000000000000000000000000000000000000)

SELECT er.session_id ,
host_name , program_name , original_login_name , er.reads ,
er.writes ,er.cpu_time , wait_type , wait_time , wait_resource ,
blocking_session_id , st.text
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er
ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE blocking_session_id > 0
UNION
SELECT es.session_id , host_name , program_name , original_login_name ,
es.reads , es.writes , es.cpu_time , wait_type , wait_time ,
wait_resource , blocking_session_id , st.text
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er
ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE es.session_id IN ( SELECT blocking_session_id
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0 )

select * from sys.dm_tran_locks

KEY: 8:72057594045857792 (8194443284a0)

select * from sys.databases

select * from sys.partitions
where partition_id = 72057594045857792

select * from sys.objects
where object_id = 1973582069

select * from sys.partitions
where hobt_id = 72057594045857792

SELECT %%lockres%%
,*
FROM Production.Product
WHERE %%LockRes%% = '(8194443284a0)'

SELECT sys.fn_PhysLocFormatter(%%physloc%%) AS FilePageSlot, %%lockres%% AS LockResource, *
FROM Production.Product



select * from sys.dm_exec_query_stats
order by total_worker_time DESC

select * from sys.dm_exec_sql_text
(0x020000004E91CB387EB8B37F596FF1114DDEA79FD5A295E20000000000000000000000000000000000000000)

select * from sys.dm_exec_procedure_stats

select * from sys.dm_exec_sql_text
(0x030008004666B938566F6D01C4A3000001000000000000000000000000000000000000000000000000000000)

-- clean up

use AdventureWorks2012
go
drop proc PlanTest
