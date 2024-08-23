USE AdventureWorksDW2008_4M
GO

SELECT OrderDateKey, DueDateKey, ShipDateKey, 
  (SELECT SUM(SalesAmount)   FROM dbo.FactResellerSalesPart) AS sumqty,
    (SELECT COUNT(SalesAmount) FROM dbo.FactResellerSalesPart) AS cntqty,
      (SELECT AVG(SalesAmount)   FROM dbo.FactResellerSalesPart) AS avgqty,
        (SELECT MIN(SalesAmount)   FROM dbo.FactResellerSalesPart) AS minqty,
          (SELECT MAX(SalesAmount)   FROM dbo.FactResellerSalesPart) AS maxqty
          FROM dbo.FactResellerSalesPart;
GO