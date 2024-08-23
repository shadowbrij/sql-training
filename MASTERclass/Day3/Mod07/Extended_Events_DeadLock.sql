select * from sys.dm_xe_objects
where name = 'lock_deadlock'


select * from sys.dm_xe_object_columns
where object_name = 'lock_deadlock';



CREATE EVENT SESSION DeadLocks
ON SERVER
ADD EVENT
  sqlserver.lock_deadlock
  (
    ACTION
     (
       sqlserver.database_id,
	   sqlserver.client_app_name,
	   sqlserver.sql_text
     )
   )
ADD TARGET package0.asynchronous_file_target
( SET filename = 'C:\Amit\capture_DeadLocks.xel',
metadatafile = 'C:\Amit\capture_DeadLocks.mta',
max_file_size = 10,
max_rollover_files = 10);

GO




ALTER EVENT SESSION DeadLocks
ON SERVER
STATE = START
GO


-- stimlate a deadlock


--stop the event
ALTER EVENT SESSION DeadLocks
ON SERVER
STATE = STOP



DECLARE @xel_filename varchar(256) = 'C:\Amit\capture_DeadLocks_0_129866808965850000.xel'
DECLARE @mta_filename varchar(256) = 'C:\Amit\capture_DeadLocks_0_129866816176710000.mta'

SELECT CONVERT(xml, event_data) as Event_Data
INTO #File_Data
FROM sys.fn_xe_file_target_read_file(@xel_filename, @mta_filename, NULL, NULL)


--Next, you can preview the data.

-- preview the data
select * from #File_Data




-- stimulating a deadlock

-- connection 1

use AdventureWorks2008R2
GO


BEGIN TRAN
update Person.Person
set FirstName = 'Amit'
where BusinessEntityID = 1

-- connection 2

use AdventureWorks2008R2
GO

BEGIN TRAN
update Person.Person
set LastName = 'BAnsal'
where BusinessEntityID = 2




-- connection 1

select * from Person.Person
where BusinessEntityID = 2


-- connection 2

select * from Person.Person
where BusinessEntityID = 1

--ROLLBACK TRAN


--ROLLBACK TRAN