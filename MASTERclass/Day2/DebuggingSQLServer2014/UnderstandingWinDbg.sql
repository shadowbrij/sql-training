/*============================================================================================
  Copyright (C) 2014 SQLMaestros.com | eDominer Systems P Ltd.
  All rights reserved.
    
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
  
  For bugs, feedback & suggestions, email feedback@SQLMaestros.com
  For SQL Server health check, consulting & support services, visit http://www.SQLMaestros.com
=============================================================================================*/

select @@VERSION
GO

SELECT DMOthreads.os_thread_id FROM sys.dm_os_threads DMOthreads
INNER JOIN sys.dm_os_workers DMOworkers
ON DMOthreads.worker_address = DMOworkers.worker_address
INNER JOIN sys.dm_os_tasks DMOtasks
ON DMOworkers.task_address = DMOtasks.task_address
WHERE DMOtasks.session_id = @@SPID
GO

select * from sys.sysprocesses
where cmd = 'lazy writer'
or cmd = 'select'
GO

/*===================================================================================================
For public classes on SQL Server & other Microsoft Technologies, visit http://www.PeoplewareIndia.com
Want to hire a trainer/consultant from us? email enquiry@peoplewareindia.com
====================================================================================================*/
