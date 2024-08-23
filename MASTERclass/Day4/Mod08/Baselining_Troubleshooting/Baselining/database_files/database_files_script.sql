	IF OBJECT_ID('baseline..database_files') IS NULL
BEGIN
	
	CREATE TABLE [dbo].[database_files]
	(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[Database Name] [nvarchar](128) NULL,
	[file_id] [int] NOT NULL,
	[name] [sysname] NOT NULL,
	[physical_name] [nvarchar](400) NOT NULL,
	[type_desc] [nvarchar](100) NULL,
	[state_desc] [nvarchar](100) NULL,
	[Total Size in MB] [bigint] NULL
) ON [PRIMARY]

	INSERT [database_files] WITH (TABLOCK)
	SELECT 1,GETDATE(),
		DB_NAME([database_id])AS [Database Name], 
       [file_id], name, physical_name, type_desc, state_desc, 
	          CONVERT( bigint, size/128.0) AS [Total Size in MB]
			  FROM sys.master_files WHERE [database_id] > 4 
			  AND [database_id] <> 32767
			  OR [database_id] = 2
			  ORDER BY DB_NAME([database_id]);
END
ELSE
BEGIN
	INSERT [database_files] WITH (TABLOCK)
	SELECT (select max([database_files].collection_id)+1 from [database_files]),GETDATE(),
				DB_NAME([database_id])AS [Database Name], 
       [file_id], name, physical_name, type_desc, state_desc, 
	          CONVERT( bigint, size/128.0) AS [Total Size in MB]
			  FROM sys.master_files WHERE [database_id] > 4 
			  AND [database_id] <> 32767
			  OR [database_id] = 2
			  ORDER BY DB_NAME([database_id]);

END
