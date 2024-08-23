use AdventureWorks
go

if OBJECT_ID('cursortable') is not null
	drop table cursortable
go

SELECT SalesOrderID, CustomerID
INTO CursorTable
FROM Sales.SalesOrderHeader
WHERE SalesOrderID BETWEEN 43661 AND 43665;
-- Declare our cursor
go

DECLARE CursorTest CURSOR
GLOBAL -- So we can manipulate it outside the batch
SCROLL -- So we can scroll back and see the changes
STATIC -- This is what we’re testing this time
FOR
	SELECT SalesOrderID, CustomerID
	FROM CursorTable;
-- Declare our two holding variables
DECLARE @SalesOrderID int;
DECLARE @CustomerID varchar(5);
-- Get the cursor open and the first record fetched
OPEN CursorTest;
FETCH NEXT FROM CursorTest INTO @SalesOrderID, @CustomerID;
-- Now loop through them all
WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT CAST(@SalesOrderID AS varchar) + ' '+ @CustomerID;
		FETCH NEXT FROM CursorTest INTO @SalesOrderID, @CustomerID;
	END
-- Make a change. We’ll see in a bit that this won’t affect the cursor.
UPDATE CursorTable
SET CustomerID = -111
WHERE SalesOrderID = 43663;
-- Now look at the table to show that the update is really there.
SELECT SalesOrderID, CustomerID
FROM CursorTable;
-- Now go back to the top. We can do this since we have a scrollable cursor
FETCH FIRST FROM CursorTest INTO @SalesOrderID, @CustomerID;
-- And loop through again.
WHILE @@FETCH_STATUS=0
BEGIN
PRINT CONVERT(varchar(5),@SalesOrderID) + ' ' + @CustomerID;
FETCH NEXT FROM CursorTest INTO @SalesOrderID, @CustomerID;
END
-- Now it’s time to clean up after ourselves
CLOSE CursorTest;
DEALLOCATE CursorTest;
DROP TABLE CursorTable;