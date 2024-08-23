-- Tiebreaker concept
/*
suppose you need the most recent order for each Northwind employee. You are supposed to return only one order for each employee, but the attributes EmployeeID and OrderDate do not necessarily identify a unique order. You need to introduce a tiebreaker to be able to identify a unique most recent order for each employee. For example, out of the multiple orders with the maximum OrderDate for an employee you could decide to return the one with the maximum OrderID. In this case, MAX(OrderID) is your tiebreaker. Or you could decide to return the row with the maximum RequiredDate, and if you still have multiple rows, return the one with the maximum OrderID. In this case, your tiebreaker is MAX(RequiredDate), MAX(OrderID). A tiebreaker is not necessarily limited to a single attribute.
*/
----------------------------------------------------------------
--Code snippet 4.7
-- Index for tiebreaker problems
CREATE UNIQUE INDEX idx_eid_od_oid 
  ON dbo.Orders(EmployeeID, OrderDate, OrderID);
CREATE UNIQUE INDEX idx_eid_od_rd_oid 
  ON dbo.Orders(EmployeeID, OrderDate, RequiredDate, OrderID);
GO


use northwind2
go


SELECT OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate 
FROM dbo.Orders AS O1
WHERE OrderDate =
  (SELECT MAX(OrderDate)
   FROM dbo.Orders AS O2
   WHERE O2.EmployeeID = O1.EmployeeID)
  AND OrderID =
  (SELECT MAX(OrderID)
   FROM dbo.Orders AS O2
   WHERE O2.EmployeeID = O1.EmployeeID
     AND O2.OrderDate = O1.OrderDate);

-- write using TOP approach

	 ---- using TOP approach

SELECT OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate
FROM dbo.Orders AS O1
WHERE OrderID =
  (SELECT TOP(1) OrderID
   FROM dbo.Orders AS O2
   WHERE O2.EmployeeID = O1.EmployeeID
   ORDER BY OrderDate DESC, OrderID DESC);


-- the correct TOP approach


SELECT OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate 
FROM dbo.Employees AS E
  CROSS APPLY
    (SELECT TOP(3) OrderID, CustomerID, OrderDate, RequiredDate 
     FROM dbo.Orders AS O
     WHERE O.EmployeeID = E.EmployeeID
     ORDER BY OrderDate DESC, OrderID DESC) AS A;