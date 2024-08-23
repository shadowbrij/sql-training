-- TSQL Worst practices

-- example 1
USE AdventureWorks
GO

select top 10 * from Sales.SalesOrderHeader



SELECT OrderDate, SubTotal FROM Sales.SalesOrderHeader 
WHERE MONTH(OrderDate) = 2 AND YEAR(OrderDate) = 2002



CREATE NONCLUSTERED INDEX idx_date ON Sales.SalesOrderHeader(orderdate)
INCLUDE (SubTotal)


SELECT OrderDate, SubTotal FROM Sales.SalesOrderHeader 
WHERE MONTH(OrderDate) = 2 AND YEAR(OrderDate) = 2002


SELECT OrderDate, SubTotal FROM Sales.SalesOrderHeader 
WHERE OrderDate >= '2002-02-01' AND OrderDate <= '2002-02-28' 


SELECT COUNT(*) 
FROM Sales.SalesOrderHeader  
WHERE MONTH(OrderDate) = 2 AND YEAR(OrderDate) = 2002

SELECT COUNT(*)
FROM Sales.SalesOrderHeader  
WHERE OrderDate >= '2002-02-01' AND OrderDate <= '2002-02-28' 



SELECT COUNT(*)
FROM Sales.SalesOrderHeader  
WHERE OrderDate >= '2002-02-01' AND OrderDate <= '2002-02-28 23:59:59' 


SELECT COUNT(*)
FROM Sales.SalesOrderHeader 
WHERE CONVERT(VARCHAR, OrderDate, 112) between '20020201' AND '20020228' 







SELECT COUNT(*)
FROM orders 
WHERE cast(OrderDate as date) between '20100201' AND '20100228' 






--example 2
--sargablity

select EmailAddress from Person.Contact
where EmailAddress like 'aaron%'

select EmailAddress from Person.Contact
where EmailAddress like '%aron%'


select EmailAddress from Person.Contact
where EmailAddress like 'a%'


select EmailAddress from Person.Contact
where LEFT(EmailAddress,1) = 'a' ;



-- example 3
-- IN vs OR

select * from Person.Contact
where ContactID IN (1,2,3,4,5)

select * from Person.Contact
where ContactID = 1
OR  ContactID = 2
OR  ContactID = 3
OR  ContactID = 4
OR  ContactID = 5
