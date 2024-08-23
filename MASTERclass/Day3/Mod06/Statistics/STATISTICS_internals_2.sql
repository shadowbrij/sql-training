use AdventureWorks2012
go

-- drop table person.person2

select * into person.person2
from Person.Person

select * from Person.Person2
where FirstName = 'Terri'
and MiddleName = 'Lee'
and LastName = 'Duffy'

sp_helpstats N'person.person2', 'ALL'
GO

SELECT
OBJECT_NAME([sp].[object_id]) AS "Table",
[sp].[stats_id] AS "Statistic ID",
[s].[name] AS "Statistic",
[sp].[last_updated] AS "Last Updated",
[sp].[rows],
[sp].[rows_sampled],
[sp].[unfiltered_rows],
[sp].[modification_counter] AS "Modifications"
FROM [sys].[stats] AS [s]
OUTER APPLY sys.dm_db_stats_properties ([s].[object_id],[s].[stats_id]) AS [sp]
WHERE [s].[object_id] = OBJECT_ID(N'Person.Person2');


create index idx_F_M_L on person.person2 (FirstName, MiddleName, LastName)
GO

select * from Person.Person2
where FirstName = 'Terri'
--and MiddleName = 'Lee'
--and LastName = 'Duffy'

select * from Person.Person2
where
--FirstName = 'Terri'
--and
MiddleName = 'Lee'
--and LastName = 'Duffy'

select * from Person.Person2
where
--FirstName = 'Terri'
--and
--MiddleName = 'Lee'
--and
LastName = 'Duffy'

DBCC TRACEON (3604,-1)

select * from Person.Person2
where FirstName = 'Terri'
and MiddleName = 'Lee'
and LastName = 'Duffy'
option (querytraceon 9204, querytraceon 9292,querytraceon 2388, querytraceon 3604, RECOMPILE)


select * from Person.Person2
where FirstName = 'Terri'
--and MiddleName = 'Lee'
--and LastName = 'Duffy'
option (querytraceon 9204, querytraceon 9292,querytraceon 2388, querytraceon 3604, RECOMPILE)

select * from Person.Person2
where
--FirstName = 'Terri'
--and
--MiddleName = 'Lee'
--and
LastName = 'Duffy'
option (querytraceon 9204, querytraceon 9292,querytraceon 2388, querytraceon 3604, RECOMPILE)


select * from Person.Person2
where
--FirstName = 'Terri'
--and
MiddleName = 'Lee'
--and
--LastName = 'Duffy'
option (querytraceon 9204, querytraceon 9292,querytraceon 2388, querytraceon 3604, RECOMPILE)



DROP STATISTICS person.person2._WA_Sys_00000005_38B96646