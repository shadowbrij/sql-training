	IF OBJECT_ID('baseline..Analyzing_Plans') IS NULL
BEGIN
	
CREATE TABLE [dbo].[Analyzing_Plans]
(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[size_in_bytes] [int] NOT NULL,
	[plan_handle] [varbinary](64) NOT NULL,
	[query_plan] [xml] NULL,
	[text] [nvarchar](max) NULL
) ON [PRIMARY]
	
	--DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR); 

INSERT Analyzing_Plans WITH (TABLOCK)
	SELECT 1,GETDATE(),
CP.size_in_bytes, CP.plan_handle, QP.query_plan, ST.text
from 
sys.dm_exec_query_stats QS
INNER JOIN
sys.dm_exec_cached_plans CP
on QS.plan_handle = CP.plan_handle
CROSS APPLY
sys.dm_exec_query_plan (CP.plan_handle) QP
CROSS APPLY
sys.dm_exec_sql_text (QS.sql_handle) ST

END
ELSE
BEGIN
	
	INSERT Analyzing_Plans WITH (TABLOCK)
	SELECT (select max(Analyzing_Plans.collection_id)+1 from Analyzing_Plans),GETDATE(),
CP.size_in_bytes, CP.plan_handle, QP.query_plan, ST.text
from 
sys.dm_exec_query_stats QS
INNER JOIN
sys.dm_exec_cached_plans CP
on QS.plan_handle = CP.plan_handle
CROSS APPLY
sys.dm_exec_query_plan (CP.plan_handle) QP
CROSS APPLY
sys.dm_exec_sql_text (QS.sql_handle) ST
END
