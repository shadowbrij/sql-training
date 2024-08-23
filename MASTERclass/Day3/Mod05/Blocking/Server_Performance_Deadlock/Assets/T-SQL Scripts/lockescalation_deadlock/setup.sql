-- setup.sql

CREATE PARTITION FUNCTION pfn_Customer (INT) AS RANGE RIGHT FOR VALUES (2000, 8000);
GO

CREATE PARTITION SCHEME psc_Customer AS PARTITION pfn_Customer
ALL TO ([PRIMARY]);

-- drop partition function  pfn_Individual
-- drop partition SCHEME  psc_Individual


SELECT lock_escalation_desc FROM sys.tables WHERE name = 'Customer';

SELECT * FROM sys.partition_functions
SELECT * FROM SYS.PARTITION_RANGE_VALUES
select $PARTITION.pfn_Customer(8000)

SELECT $PARTITION.pfn_Customer(CustomerID) AS Partition, 
COUNT(*) AS [COUNT] FROM Sales.Customer 
GROUP BY $PARTITION.pfn_Customer(CustomerID)
ORDER BY Partition 
