use AdventureWorks2012
go

-- Turn On Actual Execution Plan
select * from Production.Product
where Color = 'Black'
go

-- Turn On Actual Execution Plan
select * from Production.Product
where SafetyStockLevel = 800
go


-- Turn On Actual Execution Plan
select * from Production.Product
where Color = 'Black'
AND SafetyStockLevel = 800
go

--((Estimated Number of Rows for Color =50) * (Estimated Number of Rows for SafteyStockLevel=800))/Total Number of Rows in the table
--which is:
--(93 * 25)/504 = 4.6131

select (93 * 25)/504.0