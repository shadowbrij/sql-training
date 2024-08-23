--Basic StoredProcedure

create procedure sales.spGetYearlyBikeSales
as
begin
	select  
		pr.Name,
		year(soh.OrderDate) as SalesYear,
		Sum(sod.OrderQty) as TotalQuantity,
		Sum(soh.SubTotal) as TotalSales
	From
		Production.Product pr
		inner join
		Sales.SalesOrderDetail sod on pr.Productid=sod.Productid
		inner join 
		sales.SalesOrderHeader soh on sod.SalesOrderID=soh.SalesOrderID
	where pr.ProductSubcategoryID =1
	group by pr.name,year(soh.orderdate)
	order by pr.name,year(soh.orderdate)
end

exec sales.spGetYearlyBikeSales

--SP with input parameter

create procedure sales.spGetYearlyProductSalesByID
	@ProductCategoryID int
as
begin
	select  
		pr.Name,
		year(soh.OrderDate) as SalesYear,
		Sum(sod.OrderQty) as TotalQuantity,
		Sum(soh.SubTotal) as TotalSales
	From
		Production.Product pr
		inner join
		Sales.SalesOrderDetail sod on pr.Productid=sod.Productid
		inner join 
		sales.SalesOrderHeader soh on sod.SalesOrderID=soh.SalesOrderID
	where pr.ProductSubcategoryID =@ProductCategoryID 
	group by pr.name,year(soh.orderdate)
	order by pr.name,year(soh.orderdate)
end

exec sales.spGetYearlyProductSalesByID 

--sp handling no value for the parameter

alter procedure sales.spGetYearlyProductSalesByID
	@ProductCategoryID int=null
as
begin
	select  
		pr.Name,
		year(soh.OrderDate) as SalesYear,
		Sum(sod.OrderQty) as TotalQuantity,
		Sum(soh.SubTotal) as TotalSales
	From
		Production.Product pr
		inner join
		Sales.SalesOrderDetail sod on pr.Productid=sod.Productid
		inner join 
		sales.SalesOrderHeader soh on sod.SalesOrderID=soh.SalesOrderID
	--where pr.ProductSubcategoryID =@ProductCategoryID
	where pr.ProductSubcategoryID =isnull(@ProductCategoryID,pr.ProductSubcategoryID)
	group by pr.name,year(soh.orderdate)
	order by pr.name,year(soh.orderdate)
end

--SP with default values

create procedure HumanResources.spGetEmployeesByName
	@FirstName nvarchar(50)='%',
	@LastName nvarchar(50)='%'
as
begin
	select
		pc.title,pc.FirstName,pc.LastName,pc.EmailAddress,pc.Phone,
		hre.BirthDate,hre.HireDate		
	from HumanResources.Employee hre
	inner join
	Person.Contact pc on hre.ContactID=pc.ContactID
	where pc.FirstName like @firstname + '%'
	and pc.LastName like @LastName + '%'
end

exec HumanResources.spGetEmployeesByName 'm'
exec HumanResources.spGetEmployeesByName 'm','s'
exec HumanResources.spGetEmployeesByName 'm',default
exec HumanResources.spGetEmployeesByName 's'
exec HumanResources.spGetEmployeesByName default,'s'
exec HumanResources.spGetEmployeesByName @lastname='s'

--sp with output parameters

create procedure Sales.spGetEmployeeYTDSales
	@EmployeeID int,
	@YTD money output
as
begin
	select @YTD=SalesYTD
	from sales.SalesPerson sp
	inner join 
	HumanResources.Employee hre on sp.SalesPersonID=hre.EmployeeID
	where hre.EmployeeID=@EmployeeID
end

DECLARE @EmployeeYTDSales money
EXEC Sales.spGetEmployeeYTDSales 268,@EmployeeYTDSales output
print 'YTD sales for this employee is : ' + Convert(char(10),@EmployeeYTDSales)

--sp with raise error

alter procedure sales.spGetYearlyProductSalesByID
	@ProductCategoryID int=null
as
begin
	if @ProductCategoryID is null
		begin
			raiserror('Error : You must enter ProductCategory ID value.',10,1)
			return
		end
	select  
		pr.Name,
		year(soh.OrderDate) as SalesYear,
		Sum(sod.OrderQty) as TotalQuantity,
		Sum(soh.SubTotal) as TotalSales
	From
		Production.Product pr
		inner join
		Sales.SalesOrderDetail sod on pr.Productid=sod.Productid
		inner join 
		sales.SalesOrderHeader soh on sod.SalesOrderID=soh.SalesOrderID
	where pr.ProductSubcategoryID =isnull(@ProductCategoryID,pr.ProductSubcategoryID)
	group by pr.name,year(soh.orderdate)
	order by pr.name,year(soh.orderdate)
end

exec sales.spGetYearlyProductSalesByID 
-------------
BEGIN TRY
	EXECUTE spDoSomething
END TRY
BEGIN CATCH
  select
	ERROR_LINE() as ErrorLine,
	ERROR_NUMBER() as ErrorNumber,
	ERROR_MESSAGE() as ErrorMessage,
	ERROR_SEVERITY() as ErrorSeverity,
	ERROR_STATE() as ErrorState
END CATCH

--Return codes demo
/*
The following example shows the usp_GetSalesYTD procedure with error handling 
that sets special return code values for various errors. 
The following table shows the integer value that is assigned by the procedure to each possible error, 
and the corresponding meaning for each value.
Return code value	Meaning	
-----------------	--------
0					Successful execution
1					Required parameter value is not specified.			
2					Specified parameter value is not valid.
3					Error has occurred getting sales value.
4					NULL sales value found for the salesperson.*/

USE AdventureWorks;
GO
IF OBJECT_ID('Sales.usp_GetSalesYTD', 'P') IS NOT NULL
    DROP PROCEDURE Sales.usp_GetSalesYTD;
GO
CREATE PROCEDURE Sales.usp_GetSalesYTD
@SalesPerson nvarchar(50) = NULL,  -- NULL default value
@SalesYTD money = NULL OUTPUT
AS  

-- Validate the @SalesPerson parameter.
IF @SalesPerson IS NULL
   BEGIN
       PRINT 'ERROR: You must specify a last name for the sales person.'
       RETURN(1)
   END
ELSE
   BEGIN
   -- Make sure the value is valid.
   IF (SELECT COUNT(*) FROM HumanResources.vEmployee
          WHERE LastName = @SalesPerson) = 0
      RETURN(2)
   END
-- Get the sales for the specified name and 
-- assign it to the output parameter.
SELECT @SalesYTD = SalesYTD 
FROM Sales.SalesPerson AS sp
JOIN HumanResources.vEmployee AS e ON e.EmployeeID = sp.SalesPersonID
WHERE LastName = @SalesPerson;
-- Check for SQL Server errors.
IF @@ERROR <> 0 
   BEGIN
      RETURN(3)
   END
ELSE
   BEGIN
   -- Check to see if the ytd_sales value is NULL.
     IF @SalesYTD IS NULL
       RETURN(4) 
     ELSE
      -- SUCCESS!!
        RETURN(0)
   END
-- Run the stored procedure without specifying an input value.
EXEC Sales.usp_GetSalesYTD;
GO
-- Run the stored procedure with an input value.
DECLARE @SalesYTDForSalesPerson money, @ret_code int;
-- Execute the procedure specifying a last name for the input parameter
-- and saving the output value in the variable @SalesYTD
EXECUTE Sales.usp_GetSalesYTD
    N'Blythe', @SalesYTD = @SalesYTDForSalesPerson OUTPUT;
PRINT N'Year-to-date sales for this employee is ' +
    CONVERT(varchar(10), @SalesYTDForSalesPerson);

--using retrun codes
-- Declare the variables to receive the output value and return code 
-- of the procedure.
DECLARE @SalesYTDForSalesPerson money, @ret_code int;

-- Execute the procedure with a title_id value
-- and save the output value and return code in variables.	--Gilbert
EXECUTE @ret_code = Sales.usp_GetSalesYTD
    N'Gilbert', @SalesYTD = @SalesYTDForSalesPerson OUTPUT;	
--  Check the return codes.
IF @ret_code = 0
BEGIN
   PRINT 'Procedure executed successfully'
   -- Display the value returned by the procedure.
   PRINT 'Year-to-date sales for this employee is ' + CONVERT(varchar(10),@SalesYTDForSalesPerson)
END
ELSE IF @ret_code = 1
   PRINT 'ERROR: You must specify a last name for the sales person.'
ELSE IF @ret_code = 2 
   PRINT 'EERROR: You must enter a valid last name for the sales person.'
ELSE IF @ret_code = 3
   PRINT 'ERROR: An error occurred getting sales value.'
ELSE IF @ret_code = 4
   PRINT 'ERROR: No sales recorded for this employee.'   
GO

select * from sales.SalesPerson
select * from HumanResources.vEmployee

xp_cmdshell 'dir "e:\venkat" '