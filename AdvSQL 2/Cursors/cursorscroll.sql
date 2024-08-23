use AdventureWorks
go
create PROCEDURE spCursorScroll
AS
DECLARE @Counter int,
@OrderID int,
@CustomerID int
DECLARE CursorTest CURSOR
LOCAL
forward_only
for
SELECT SalesOrderID, CustomerID
FROM Sales.SalesOrderHeader;
SELECT @Counter = 1;
OPEN CursorTest;
FETCH NEXT FROM CursorTest INTO @OrderID, @CustomerID;
PRINT 'Row ' + CAST(@Counter AS varchar) + ' has a SalesOrderID of ' +
CAST(@OrderID AS varchar) + ' and a CustomerID of ' + CAST(@CustomerID AS
varchar);
WHILE (@Counter<=5) AND (@@FETCH_STATUS=0)
BEGIN
SELECT @Counter = @Counter + 1;
FETCH NEXT FROM CursorTest INTO @OrderID, @CustomerID;
PRINT 'Row ' + CAST(@Counter AS varchar) + ' has a SalesOrderID of ' +
CAST(@OrderID AS varchar) + ' and a CustomerID of ' + CAST(@CustomerID
AS varchar);
END
WHILE (@Counter > 1) AND (@@FETCH_STATUS = 0)
BEGIN
SELECT @Counter = @Counter - 1;
FETCH PRIOR FROM CursorTest INTO @OrderID, @CustomerID;
PRINT 'Row ' + CONVERT(varchar,@Counter) + ' has an SalesOrderID of ' +
CAST(@OrderID AS varchar) + ' and a CustomerID of ' + CAST(@CustomerID
AS varchar);
END
CLOSE CursorTest;
DEALLOCATE CursorTest;

exec spCursorScroll