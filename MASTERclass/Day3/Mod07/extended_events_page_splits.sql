SET NOCOUNT ON;
USE tempdb;
GO


-- sqlserver package has a page_split event

select * from sys.dm_xe_objects
where name = 'page_split'

-- and the event has some default columns that can be trapped

select * from sys.dm_xe_object_columns
where object_name = 'page_split';

-- but we also want the sql query (text) that causes page split
-- additional event data can be gathered using actions
-- so lets create an event first
-- make sure the directory u specify exists in c drive

CREATE EVENT SESSION Page_Splits
ON SERVER
ADD EVENT
  sqlserver.page_split
  (
    ACTION
     (
       sqlserver.database_id,
	   sqlserver.client_app_name,
	   sqlserver.sql_text
     )
   )
ADD TARGET package0.asynchronous_file_target
( SET filename = 'C:\Amit\track_page_splits.xel',
metadatafile = 'C:\Amit\track_page_splits.mta',
max_file_size = 10,
max_rollover_files = 10);

GO

-- start the event
ALTER EVENT SESSION Page_Splits
ON SERVER
STATE = START
GO


-- extract the data
-- replace the filename

DECLARE @xel_filename varchar(256) = 'C:\Amit\track_page_splits_0_129646064157130000.xel'
DECLARE @mta_filename varchar(256) = 'C:\Amit\track_page_splits_0_129646064157130000.mta'

SELECT CONVERT(xml, event_data) as Event_Data
INTO #File_Data
FROM sys.fn_xe_file_target_read_file(@xel_filename, @mta_filename, NULL, NULL)

-- preview the data

select * from #File_Data

-- extract what you need using XQuery
-- you can modify this to suit your requirement
SELECT database_name, sql_text
FROM
(
SELECT
DB_NAME(event_data.value('(event/action[1]/value)[1]', 'VARCHAR(100)'))
AS database_name,
Event_Data.value('(event/action[3]/value)[1]', 'VARCHAR(4000)') AS sql_text
FROM #File_Data
) as table_

-- stop the event
ALTER EVENT SESSION Page_Splits
ON SERVER
STATE = STOP
GO

