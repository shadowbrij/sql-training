/*============================================================================
	SQL Server 2008 Using Performance Data Collection Hands-on Labs
	ExecuteQueries.sql
	
	Script created/modified for SQL Server 2008 Hands-on Labs
	SQL Server 2008 February CTP 
------------------------------------------------------------------------------
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/

SELECT DB_Name();

SELECT /* 1 */ City, count(*) AS NumberOfOrders
FROM NewIndividual i  JOIN NewCustomer c  ON i.CustomerID = c.CustomerID AND c.CustomerType = 'I'
  JOIN NewCustomerAddress ca  ON ca.CustomerID = c.CustomerID
  JOIN NewAddress a ON a.AddressID = ca.AddressID
  JOIN NewSalesOrderHeader sh ON c.CustomerID = sh.CustomerID
  JOIN NewSalesOrderDetail sd ON sd.SalesOrderID = sh.SalesOrderID
  JOIN NewProduct p ON p.ProductID = sd.ProductID
WHERE StateProvinceID = (SELECT StateProvinceID FROM Person.StateProvince WHERE StateProvinceCode = 'CA')
GROUP BY City
ORDER BY NumberOfOrders DESC;

SELECT /* 5 */ x.total_price, a.AddressLine1, a.AddressLine2, a.City
FROM
	(SELECT sum(d.UnitPrice) total_price, d.SalesOrderID
	FROM NewSalesOrderDetail d,
		(SELECT SalesOrderID
		FROM dbo.NewSalesOrderHeader
		WHERE OnlineOrderFlag = 'True') s
	WHERE d.SalesOrderId = s.SalesOrderId
	GROUP BY d.SalesOrderID ) x,
	dbo.NewSalesOrderHeader h,
	dbo.NewCustomer c,
	dbo.NewAddress a
WHERE x.SalesOrderID = h.SalesOrderID
AND h.CustomerID = c.CustomerID
AND c.TerritoryID = a.AddressID;

SELECT /* 2 */ i.CustomerID, c.ModifiedDate, City
FROM NewIndividual i  JOIN NewCustomer c  ON i.CustomerID = c.CustomerID AND c.CustomerType = 'I'
  JOIN NewCustomerAddress ca  ON ca.CustomerID = c.CustomerID
  JOIN NewAddress a ON a.AddressID = ca.AddressID
WHERE i.CustomerID > 13000
AND i.CustomerID < 22000;

SELECT /* 5 */ x.total_price, a.AddressLine1, a.AddressLine2, a.City
FROM
	(SELECT sum(d.UnitPrice) total_price, d.SalesOrderID
	FROM NewSalesOrderDetail d,
		(SELECT SalesOrderID
		FROM dbo.NewSalesOrderHeader
		WHERE OnlineOrderFlag = 'True') s
	WHERE d.SalesOrderId = s.SalesOrderId
	GROUP BY d.SalesOrderID ) x,
	dbo.NewSalesOrderHeader h,
	dbo.NewCustomer c,
	dbo.NewAddress a
WHERE x.SalesOrderID = h.SalesOrderID
AND h.CustomerID = c.CustomerID
AND c.TerritoryID = a.AddressID;

SELECT /* 3 */ i.CustomerID, c.ModifiedDate, City
FROM NewIndividual i  JOIN NewCustomer c  ON i.CustomerID = c.CustomerID AND c.CustomerType = 'I'
  JOIN NewCustomerAddress ca  ON ca.CustomerID = c.CustomerID
  JOIN NewAddress a ON a.AddressID = ca.AddressID
WHERE i.CustomerID = 16701;

SELECT /* 5 */ x.total_price, a.AddressLine1, a.AddressLine2, a.City
FROM
	(SELECT sum(d.UnitPrice) total_price, d.SalesOrderID
	FROM NewSalesOrderDetail d,
		(SELECT SalesOrderID
		FROM dbo.NewSalesOrderHeader
		WHERE OnlineOrderFlag = 'True') s
	WHERE d.SalesOrderId = s.SalesOrderId
	GROUP BY d.SalesOrderID ) x,
	dbo.NewSalesOrderHeader h,
	dbo.NewCustomer c,
	dbo.NewAddress a
WHERE x.SalesOrderID = h.SalesOrderID
AND h.CustomerID = c.CustomerID
AND c.TerritoryID = a.AddressID;

SELECT /* 4 */ i.CustomerID, c.TerritoryID, City
FROM NewIndividual i  JOIN NewCustomer c  ON i.CustomerID = c.CustomerID AND c.CustomerType = 'I'
  JOIN NewCustomerAddress ca  ON ca.CustomerID = c.CustomerID
  JOIN NewAddress a ON a.AddressID = ca.AddressID
WHERE StateProvinceID = (SELECT StateProvinceID FROM Person.StateProvince WHERE StateProvinceCode = 'CA')
--AND c.SalesPersonID <> null
ORDER BY i.CustomerID, City;

SELECT /* 5 */ x.total_price, a.AddressLine1, a.AddressLine2, a.City
FROM
	(SELECT sum(d.UnitPrice) total_price, d.SalesOrderID
	FROM NewSalesOrderDetail d,
		(SELECT SalesOrderID
		FROM dbo.NewSalesOrderHeader
		WHERE OnlineOrderFlag = 'True') s
	WHERE d.SalesOrderId = s.SalesOrderId
	GROUP BY d.SalesOrderID ) x,
	dbo.NewSalesOrderHeader h,
	dbo.NewCustomer c,
	dbo.NewAddress a
WHERE x.SalesOrderID = h.SalesOrderID
AND h.CustomerID = c.CustomerID
AND c.TerritoryID = a.AddressID;

SELECT /* 6 */ AddressLine1, AddressLine2, City
FROM NewAddress
WHERE
((StateProvinceID > 0 AND StateProvinceID < 12)
OR
(StateProvinceID > 49 AND StateProvinceID < 76))
AND City LIKE '%x%';
		
SELECT /* 5 */ x.total_price, a.AddressLine1, a.AddressLine2, a.City
FROM
	(SELECT sum(d.UnitPrice) total_price, d.SalesOrderID
	FROM NewSalesOrderDetail d,
		(SELECT SalesOrderID
		FROM dbo.NewSalesOrderHeader
		WHERE OnlineOrderFlag = 'True') s
	WHERE d.SalesOrderId = s.SalesOrderId
	GROUP BY d.SalesOrderID ) x,
	dbo.NewSalesOrderHeader h,
	dbo.NewCustomer c,
	dbo.NewAddress a
WHERE x.SalesOrderID = h.SalesOrderID
AND h.CustomerID = c.CustomerID
AND c.TerritoryID = a.AddressID;