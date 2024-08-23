use AdventureWorks2012
GO



CREATE PROCEDURE user_GetCustomerShipDates
	(
	@ShipDateStart DATETIME ,
	@ShipDateEnd DATETIME
	)
AS
	SELECT CustomerID,
	SalesOrderNumber
	FROM Sales.SalesOrderHeader
	WHERE ShipDate BETWEEN @ShipDateStart AND @ShipDateEnd
GO



CREATE NONCLUSTERED INDEX IDX_ShipDate_ASC
ON Sales.SalesOrderHeader (ShipDate)
GO



DBCC FREEPROCCACHE
EXEC user_GetCustomerShipDates '2005/07/08', '2008/01/01'
EXEC user_GetCustomerShipDates '2005/07/10', '2005/07/20'

DBCC FREEPROCCACHE
EXEC user_GetCustomerShipDates '2005/07/10', '2005/07/20'
EXEC user_GetCustomerShipDates '2005/07/08', '2008/01/01'


-- option 1
-- RECOMPILE

DROP PROCEDURE user_GetCustomerShipDates
GO

CREATE PROCEDURE user_GetCustomerShipDates

	@ShipDateStart DATETIME ,
	@ShipDateEnd DATETIME
WITH RECOMPILE
AS
	SELECT CustomerID,
	SalesOrderNumber
	FROM Sales.SalesOrderHeader
	WHERE ShipDate BETWEEN @ShipDateStart AND @ShipDateEnd
GO

-- option 2
-- statement level recompile

DROP PROCEDURE user_GetCustomerShipDates
GO

CREATE PROCEDURE user_GetCustomerShipDates

	@ShipDateStart DATETIME ,
	@ShipDateEnd DATETIME
AS
	SELECT CustomerID,
	SalesOrderNumber
	FROM Sales.SalesOrderHeader
	WHERE ShipDate BETWEEN @ShipDateStart AND @ShipDateEnd
	OPTION (RECOMPILE)
GO


-- option 3
-- Optimize for hint

DROP PROCEDURE user_GetCustomerShipDates
GO

CREATE PROCEDURE user_GetCustomerShipDates

	@ShipDateStart DATETIME ,
	@ShipDateEnd DATETIME
AS
	SELECT CustomerID,
	SalesOrderNumber
	FROM Sales.SalesOrderHeader
	WHERE ShipDate BETWEEN @ShipDateStart AND @ShipDateEnd
	OPTION (OPTIMIZE FOR (@ShipDateStart='2005/07/08',@ShipDateEnd='2008/01/01'))
GO

-- there are other options too not covered here