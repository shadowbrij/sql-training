if OBJECT_ID('sales') is not null
	drop table sales

if OBJECT_ID('employees') is not null
	drop table employees

CREATE TABLE [dbo].[employees](
	[EmployeeID] [int] NOT NULL IDENTITY(1,1) primary key,
	[managerid] int null,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[title] [nvarchar](100) NULL DEFAULT('New Hire'),
	[hiredate] [datetime] NOT NULL DEFAULT(GETDATE()) check(datediff(d,getdate(),hiredate)<=0),
	[vacationhours] [smallint] NOT NULL DEFAULT(0),
	[salary] [decimal](19, 4) NOT NULL,
	unique nonclustered(firstname,middlename,lastname)
) ON [PRIMARY]

GO

if OBJECT_ID('products') is not null
	drop table products
CREATE TABLE [dbo].[products](
	[productid] [int] NOT NULL identity(1,1) primary key,
	[name] [nvarchar](255) NOT NULL unique nonclustered,
	[price] [decimal](19, 4) NOT NULL check(price>0),
	[DiscontinuedFlag][bit] not null default(0)
) ON [PRIMARY]

GO



CREATE TABLE [dbo].[Sales](
	[SaleID] [uniqueidentifier] NOT NULL default newid(),
	[productid] [int] NOT NULL,
	[employeeid] [int] NOT NULL,
	[quantity] [smallint] NOT NULL,
	[saledate][datetime] not null default(getdate()),
	check(quantity>0 and datediff(dd,getdate(),saledate)<=0),
	primary key clustered(saleid asc)
		with(IGNORE_DUP_KEY=OFF),
	foreign key(productid) references products(productid),
	foreign key(employeeid) references employees(employeeid)

) ON [PRIMARY]

GO

if object_id('uRecalculateVacationHours') is not null
	drop trigger uRecalculateVacationHours
go
create trigger uRecalculateVacationHours ON Employees
	FOR UPDATE
AS
	IF UPDATE(hiredate)
		BEGIN
			DECLARE @RecalcFlag bit
			SELECT @RecalcFlag=IIF(YEAR(Hiredate)=2012,1,0) from inserted
			if(@RecalcFlag=1)
				UPDATE Employees SET VacationHours +=40 FROM Employees e Join Inserted i
				on e.Employeeid=i.employeeid
		END

go



insert into employees values
(8,'Luke',null,'Skywalker','Sales Person','1/10/2005',10,50000),
(8,'Darth',null,'Maul','Sales Person','4/27/2005',20,50000),
(8,'Han',null,'Solo','Sales Person','6/19/2005',30,80000),
(5,'Emperor',null,'Palpatine','Human Resources','5/11/2005',30,80000),
(6,'Count',null,'Dooku','CFO','3/22/2005',22,90000),
(null,'Obi-Wan',null,'Kenobi','CEO','2/14/2005',15,10000),
(null,'Yoda',null,'p','Sales Manager','7/24/2015',10,85000)
go
delete from employees where employeeid=7;
go
insert into employees values(null,'Yoda',null,'p','Sales Manager','7/24/2015',10,85000)
go

insert into products(name,price)
values('Lightsaber',49.99),('Blaster',79.99),('Droid',99.99),
('Speeder',250.00),('Spaceship',300.00)
go

declare @counter int
set @counter=1

while @counter<=10000
 begin
  insert sales
   select 
    newid(),
    (abs(checksum(newid()))%5)+1,
    (abs(checksum(newid()))%3)+1,
    (abs(checksum(newid()))%10)+1,
    dateadd(day,abs(checksum(newid())%3650),'2002-04-10')
  set @counter +=1
end


--alter table sales
--drop constraint CK__Sales__45F365D3

--DBCC CHECKIDENT('employees', RESEED, 7)

--insert into employees values(null,'Yoda',null,'p','Sales Manager',getdate(),20,85000)

select * from employees