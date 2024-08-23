IF OBJECT_ID('baseline..file_stats') IS NULL
BEGIN

CREATE TABLE [dbo].[file_stats]
(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[name] [sysname] NOT NULL,
	[database_id] [smallint] NOT NULL,
	[file_id] [smallint] NOT NULL,
	[sample_ms] [int] NOT NULL,
	[num_of_reads] [bigint] NOT NULL,
	[num_of_bytes_read] [bigint] NOT NULL,
	[io_stall_read_ms] [bigint] NOT NULL,
	[num_of_writes] [bigint] NOT NULL,
	[num_of_bytes_written] [bigint] NOT NULL,
	[io_stall_write_ms] [bigint] NOT NULL,
	[io_stall] [bigint] NOT NULL,
	[size_on_disk_bytes] [bigint] NOT NULL,
	[file_handle] [varbinary](8) NOT NULL
) ON [PRIMARY]

INSERT file_stats WITH (TABLOCK)
	SELECT
	1,GETDATE(),
		d.name,
		w.*
	FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS w
	INNER JOIN sys.databases AS d ON
		d.database_id = w.database_id
END
ELSE
BEGIN	
	
	INSERT file_stats WITH (TABLOCK)
	SELECT (select max(file_stats.collection_id)+1 from file_stats),GETDATE(),
		d.name,
		w.*
	FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS w
	INNER JOIN sys.databases AS d ON
		d.database_id = w.database_id
END