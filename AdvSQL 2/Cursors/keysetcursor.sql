use AdventureWorks
go
SELECT SalesOrderID, CustomerID
INTO CursorTable
FROM Sales.SalesOrderHeader
WHERE SalesOrderID BETWEEN 43661 AND 43665;
-- Now create a unique index on it in the form of a primary key
ALTER TABLE CursorTable
ADD CONSTRAINT PKCursor
PRIMARY KEY (SalesOrderID);
/* The IDENTITY property was automatically brought over when
** we did our SELECT INTO, but I want to use my own SalesOrderID
** value, so I’m going to turn IDENTITY_INSERT on so that I
** can override the identity value.
*/
SET IDENTITY_INSERT CursorTable ON;
-- Declare our cursor
DECLARE CursorTest CURSOR
GLOBAL -- So we can manipulate it outside the batch
SCROLL -- So we can scroll back and see the changes
keyset -- This is what we’re testing this time
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
-- Make a change. We’ll see that does affect the cursor this time.
UPDATE CursorTable
SET CustomerID = -111
WHERE SalesOrderID = 43663;
-- Now we’ll delete a record so we can see how to deal with that
DELETE CursorTable
WHERE SalesOrderID = 43664;
-- Now Insert a record. We’ll see that the cursor is oblivious to it.
INSERT INTO CursorTable
(SalesOrderID, CustomerID)
VALUES
(-99999, -99999);
-- Now look at the table to show that the changes are really there.
SELECT SalesOrderID, CustomerID
FROM CursorTable;
-- Now go back to the top. We can do this since we have a scrollable cursor
FETCH FIRST FROM CursorTest INTO @SalesOrderID, @CustomerID;
/* And loop through again.
** This time, notice that we changed what we’re testing for.
** Since we have the possibility of rows being missing (deleted)
** before we get to the end of the actual cursor, we need to do
** a little bit more refined testing of the status of the cursor.
*/
WHILE @@FETCH_STATUS != -1
BEGIN
IF @@FETCH_STATUS = -2
BEGIN
PRINT ' MISSING! It probably was deleted.';
END
ELSE
BEGIN
PRINT CAST(@SalesOrderID AS varchar) +' '+ CAST(@CustomerID AS varchar);
END
FETCH NEXT FROM CursorTest INTO @SalesOrderID, @CustomerID;
END
-- Now it’s time to clean up after ourselves
CLOSE CursorTest;
DEALLOCATE CursorTest;
DROP TABLE CursorTable;