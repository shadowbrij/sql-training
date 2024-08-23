CREATE EVENT SESSION [Test2] ON SERVER 
ADD EVENT sqlos.wait_info(
    ACTION(package0.callstack,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([duration]>(5000) AND [package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))),
ADD EVENT sqlserver.error_reported(
    ACTION(package0.callstack,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(package0.callstack,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))),
ADD EVENT sqlserver.sp_statement_starting(
    ACTION(package0.callstack,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(package0.callstack,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION(package0.callstack,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))) 
ADD TARGET package0.ring_buffer(SET max_memory=(10240))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO


