use baseline
go

select count (*) from [dbo].[AlwaysOnData]
select count (*) from [dbo].[Analyzing_Tasks]
select count (*) from [dbo].[database_files]
select count (*) from [dbo].[DMVcount]
select count (*) from [dbo].[file_stats]
select count (*) from [dbo].[PerfMonData]
select count (*) from [dbo].[top10waits]
select count (*) from [dbo].[waitingtasks]
select count (*) from [dbo].[waits]

use baseline
go


select * from [dbo].[AlwaysOnData] 
select * from [dbo].[Analyzing_Tasks] order by collection_id
select * from [dbo].[database_files] order by collection_id
select * from [dbo].[DMVcount] order by collection_id
select * from [dbo].[file_stats] order by collection_id
select * from [dbo].[PerfMonData] 
select * from [dbo].[top10waits] order by collection_id
select * from [dbo].[waitingtasks] order by collection_id
select * from [dbo].[waits] order by collection_id
