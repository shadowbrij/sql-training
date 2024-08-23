-- drop database baseline

use baseline
go

truncate table [dbo].[AlwaysOnData]
go

truncate table [dbo].[Analyzing_Tasks]
go

truncate table [dbo].[database_files]
go

truncate table [dbo].[DMVcount]
go

truncate table [dbo].[file_stats]
go

truncate table [dbo].[PerfMonData]
go

truncate table [dbo].[top10waits]
go

truncate table [dbo].[waitingtasks]
go

truncate table [dbo].[waits]
go

