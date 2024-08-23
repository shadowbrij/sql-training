/*============================================================================
	SQL Server 2008 Using Performance Data Collection Hands-on Labs
	BlockingTransaction.sql
	
	Script created/modified for SQL Server 2008 Hands-on Labs
	SQL Server 2008 February CTP 
------------------------------------------------------------------------------
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/

USE AdventureWorks;
go

WHILE 1=1
BEGIN
	BEGIN TRAN
	UPDATE dbo.NewContacts
		SET FirstName = N'Update: ' + convert(nvarchar, getdate()) 
		WHERE ContactID = 3
		WAITFOR DELAY '00:00:55'
	SELECT getdate() AS 'Contact Updated'
	COMMIT TRAN
	WAITFOR DELAY '00:00:03'
END
GO