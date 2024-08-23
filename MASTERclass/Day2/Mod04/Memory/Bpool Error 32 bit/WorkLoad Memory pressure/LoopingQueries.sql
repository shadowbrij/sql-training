/*============================================================================
	SQL Server 2008 Using Performance Data Collection Hands-on Labs
	LoopingQueries.sql
	
	Script created/modified for SQL Server 2008 Hands-on Labs
	SQL Server 2008 February CTP 
------------------------------------------------------------------------------
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/

USE AdventureWorks
go

:ON ERROR IGNORE
go

SET NOCOUNT ON
go

WHILE 1=1
BEGIN
	:r ExecuteQueries.sql  
END
go