
---------------------------------------------------------------------
-- OVER Clause
---------------------------------------------------------------------
--code snippet 6.1
SET NOCOUNT ON;
USE pubs;
GO

-- remembering subqueries....
--the orginal problem:calculate two aggregates for each sales row: the percentage the row contributed to the total sales quantity and the difference between the row's sales quantity and the average quantity over all sales.

SELECT stor_id, ord_num, title_id, 
  CONVERT(VARCHAR(10), ord_date, 120) AS ord_date, qty,
  CAST(1.*qty / (SELECT SUM(qty) FROM dbo.sales) * 100
       AS DECIMAL(5, 2)) AS per,
  qty - (SELECT AVG(qty) FROM dbo.sales) AS diff
FROM dbo.sales;

--code snippet 6.2
-- Obtaining Aggregates with Cross Join
--optimized
SELECT stor_id, ord_num, title_id, 
  CONVERT(VARCHAR(10), ord_date, 120) AS ord_date, qty,
  CAST(1.*qty / sumqty * 100 AS DECIMAL(5, 2)) AS per,
  CAST(qty - avgqty AS DECIMAL(9, 2)) as diff
FROM dbo.sales,
  (SELECT SUM(qty) AS sumqty, AVG(1.*qty) AS avgqty
   FROM dbo.sales) AS AGG;


--code snippet 6.3
-- Obtaining Aggregates with OVER Clause, without Partitioning
-- calculate multiple aggregates using the same OVER clause
-- SQL Server will scan the required source data only once for all

--The purpose of using the OVER clause with scalar aggregates is to calculate, for each row, an aggregate based on a window of values that extends beyond the scope of the rowand to do all this without using a GROUP BY clause in the query. In other words, the OVER clause allows you to add aggregate calculations to the results of an ungrouped query. This capability provides an alternative to requesting aggregates with subqueries, in case you need to include both base row attributes and aggregates in your results.

SELECT stor_id, ord_num, title_id, 
  CONVERT(VARCHAR(10), ord_date, 120) AS ord_date, qty,
  CAST(1.*qty / SUM(qty) OVER() * 100 AS DECIMAL(5, 2)) AS per,
  CAST(qty - AVG(1.*qty) OVER() AS DECIMAL(9, 2)) AS diff
FROM dbo.sales;


--code snippet 6.4
-- Comparing Single and Multiple Aggregates using OVER Clause
SELECT stor_id, ord_num, title_id,
  SUM(qty) OVER() AS sumqty
FROM dbo.sales;


--code snippet 6.5
SELECT stor_id, ord_num, title_id, 
  SUM(qty)   OVER() AS sumqty,
  COUNT(qty) OVER() AS cntqty,
  AVG(qty)   OVER() AS avgqty,
  MIN(qty)   OVER() AS minqty,
  MAX(qty)   OVER() AS maxqty
FROM dbo.sales;


--code snippet 6.6
-- Comparing Single and Multiple Aggregates using Subqueries

SELECT stor_id, ord_num, title_id,
  (SELECT SUM(qty) FROM dbo.sales) AS sumqty
FROM dbo.sales;

--code snippet 6.7
--this one rescans the source data for each aggregate
SELECT stor_id, ord_num, title_id, 
  (SELECT SUM(qty)   FROM dbo.sales) AS sumqty,
  (SELECT COUNT(qty) FROM dbo.sales) AS cntqty,
  (SELECT AVG(qty)   FROM dbo.sales) AS avgqty,
  (SELECT MIN(qty)   FROM dbo.sales) AS minqty,
  (SELECT MAX(qty)   FROM dbo.sales) AS maxqty
FROM dbo.sales;



--code snippet 6.8
-- Obtaining Aggregates with OVER Clause, with Partitioning -- allows for simpler and shorter code (or else u write correlated subequeires wihihc wud be long and complex)
SELECT stor_id, ord_num, title_id, 
  CONVERT(VARCHAR(10), ord_date, 120) AS ord_date, qty,
  CAST(1.*qty / SUM(qty) OVER(PARTITION BY stor_id) * 100
    AS DECIMAL(5, 2)) AS per,
  CAST(qty - AVG(1.*qty) OVER(PARTITION BY stor_id)
    AS DECIMAL(9, 2)) AS diff
FROM dbo.sales
ORDER BY stor_id;
GO
