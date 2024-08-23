use AdventureWorks
go

CREATE FUNCTION ufnFormatCurrency(@Amount Money)
RETURNS varchar(100)
as
	BEGIN
		RETURN '$' + Convert(varchar,Convert(Money,@Amount),1)
	END

select	[dbo].[ufnFormatCurrency](700)

select 700

--usage 

SELECT
	p.Name,
	soh.OrderDate,
	dbo.ufnFormatCurrency(soh.SubTotal) as SubTotal,
	dbo.ufnFormatCurrency(soh.TaxAmt) as TaxAmount, 
	dbo.ufnFormatCurrency(soh.Freight) as Freight,
	dbo.ufnFormatCurrency(soh.TotalDue) as TotalDue
FROM
	Sales.SalesOrderheader soh
	join
	Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderId
	join
	Production.Product p on sod.productid=p.productid
	where year(soh.orderdate)=2004


--Data Access Scalar Function

	create function ufnGetProductStock(@productid int)returns int
as
	begin
		declare @ret int
		select @ret=sum(ppi.quantity)
		from 
		Production.ProductInventory ppi
		where 
			ppi.productid=@productid
	if(@ret is null)
		set @ret=0
	
	return @ret
	end

select name,dbo.ufnGetProductStock(ProductID) as Supply
from Production.Product

--creating inline table-valued functions

create function Sales.ufnStoreYTDSales(@StoreID int) returns table
as
 return
(
	select
		p.name,sum(sod.linetotal) as YTDSales
	from
		Production.Product As p
		inner join
		Sales.SalesOrderDetail as sod on sod.productid=p.productid
		inner join
		Sales.SalesOrderHeader as soh on
soh.SalesOrderID=sod.SalesOrderID
	where
		soh.CustomerId=@StoreID	
	group by
		p.productid,p.name
)

select * into temp from Sales.ufnStoreYTDSales(1)

select * from temp

--creating a parameterized view from an inline table-valued function

create FUNCTION Sales.ufnStoreWithDemographics(@storeid int) returns table
as
	return	
	(
		select * from sales.vStoreWithDemographics
		where customerid=@storeid
	)

--usage

select * from Sales.ufnStoreWithDemographics(2)

--creating a Table-valued function

CREATE FUNCTION ufnGetContactInfo(@ContactID int)
returns @retContactInformation Table
(
	ContactID int primary key,
	FirstName nvarchar(50),
	LastName nvarchar(50),
	Email nvarchar(50),
	Phone nvarchar(25),
	ContactType nvarchar(50)
)
as
 begin
	declare @FirstName nvarchar(50),
	@LastName nvarchar(50),
	@Email nvarchar(50),
	@Phone nvarchar(25),
	@ContactType nvarchar(50)
	select
		@ContactID=ContactID,
		@FirstName=FirstName,
		@LastName=LastName,
		@Email=EmailAddress,
		@phone=phone
	from 
		Person.Contact
	where Contactid=@contactid
	set @ContactType=
	CASE
	--check for employee
	WHEN EXISTS(SELECT * FROM HumanResources.Employee hre
		WHERE hre.ContactID=@ContactID)
		THEN 'Employee'
	
	--check for Vendor
	When Exists(select * from Purchasing.VendorContact pvc
		inner join Person.ContactType pct
		on pvc.ContactTypeID=pct.ContactTypeID
		where pvc.ContactID=@ContactID)
		Then 'Vendor Contact'

	--check for store
	When Exists(select * from Sales.StoreContact ssc
		inner join Person.ContactType pct
		on ssc.ContactTypeId=pct.ContactTypeID
		where ssc.ContactID=@ContactID)
		Then 'Store Contact'

	--check for individual customer
	When exists(select * from sales.Individual si
		where si.ContactID=@ContactID)
		Then 'Consumer'
END
IF @ContactID is not null
begin
	insert @retContactInformation
	select @ContactID,@FirstName,@LastName,@Email,@phone,@ContactType;
end
return
end

select * from ufnGetContactInfo(1)
select * from ufnGetContactInfo(1209)
select * from ufnGetContactInfo(678)
select * from ufnGetContactInfo(6190)

