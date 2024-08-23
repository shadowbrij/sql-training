use AdventureWorks
go
create PROCEDURE spCursorScope
AS
DECLARE @Counter int,
@OrderID int,
@CustomerID int
DECLARE CursorTest CURSOR
local
FOR
SELECT SalesOrderID, CustomerID
FROM Sales.SalesOrderHeader;
SELECT @Counter = 1;
OPEN CursorTest;
FETCH NEXT FROM CursorTest INTO @OrderID, @CustomerID;
PRINT 'Row ' + CAST(@Counter AS varchar) + ' has a SalesOrderID of ' +
CONVERT(varchar,@OrderID) + ' and a CustomerID of ' + CAST(@CustomerID AS
varchar);
WHILE (@Counter<=5) AND (@@FETCH_STATUS=0)
BEGIN
SELECT @Counter = @Counter + 1;
FETCH NEXT FROM CursorTest INTO @OrderID, @CustomerID;
PRINT 'Row ' + CAST(@Counter AS varchar) + ' has a SalesOrderID of ' +
CONVERT(varchar,@OrderID) + ' and a CustomerID of ' + CAST(@CustomerID
AS varchar);
END

EXEC spCursorScope;


DECLARE @Counter int,@OrderID int,@CustomerID int;
SET @Counter=6;
WHILE (@Counter<=10) AND (@@FETCH_STATUS=0)
BEGIN
PRINT 'Row ' + CAST(@Counter AS varchar) + ' has a SalesOrderID of ' +
CAST(@OrderID AS varchar) + ' and a CustomerID of ' +
CAST(@CustomerID AS varchar);
SELECT @Counter = @Counter + 1;
FETCH NEXT FROM CursorTest INTO @OrderID, @CustomerID;
END
CLOSE CursorTest;
DEALLOCATE CursorTest;