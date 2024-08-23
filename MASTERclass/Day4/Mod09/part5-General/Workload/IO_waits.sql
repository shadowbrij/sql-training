USE AdventureWorks
GO


--Create some IO waits
DBCC DROPCLEANBUFFERS
SELECT
	COUNT(*) 
FROM Sales.SalesOrderHeader sh
FULL OUTER JOIN Sales.SalesOrderDetail sd ON
	sh.rowguid = sd.rowguid
FULL OUTER JOIN Production.Product p ON
	p.rowguid = sd.rowguid
FULL OUTER JOIN Sales.Customer AS c ON
	c.rowguid = p.rowguid
FULL OUTER JOIN Person.Address AS a ON
	a.rowguid = c.rowguid
FULL OUTER JOIN Person.Contact AS pc ON
	pc.rowguid = a.rowguid
FULL OUTER JOIN Sales.ContactCreditCard AS ccc ON
	ccc.CreditCardId = pc.ContactId
FULL OUTER JOIN Production.TransactionHistoryArchive AS ta ON
	ta.transactionid = c.customerid
GO 500
