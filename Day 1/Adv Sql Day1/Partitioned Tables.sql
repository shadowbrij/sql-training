sp_helpdb adventureworks

create partition function pf_hiredate(datetime)
as range right
for values('1/1/1996','1/1/1998','1/1/2000')
go

alter database adventureworks add filegroup fg1
alter database adventureworks add filegroup fg2
alter database adventureworks add filegroup fg3
alter database adventureworks add filegroup fg4

alter database adventureworks
add file
(name='data1',filename='C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\awData1.ndf',
size=5) to filegroup fg1
go

alter database adventureworks
add file
(name='data2',filename='C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\awData2.ndf',
size=5) to filegroup fg2
go

alter database adventureworks
add file
(name='data3',filename='C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\awData3.ndf',
size=5) to filegroup fg3
go

alter database adventureworks
add file
(name='data4',filename='C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\awData4.ndf',
size=5) to filegroup fg4
go

create partition scheme ps_hiredate
as partition pf_hiredate
to (fg1,fg2,fg3,fg4)
go

CREATE TABLE [Employees](
	[EmployeeID] [int] IDENTITY(1,1) not null,
	[NationalIDNumber] [nvarchar](15) NOT NULL,
	[ContactID] [int] NOT NULL,
	[ManagerID] [int] NULL,
	[Title] [nvarchar](50) NOT NULL,
	[BirthDate] [datetime] NOT NULL,
	[MaritalStatus] [nchar](1) NOT NULL,
	[Gender] [nchar](1) NOT NULL,
	[HireDate] [datetime] NOT NULL) on ps_hiredate(hiredate)
go


insert into Employees
select NationalIDNumber,ContactID,ManagerID,Title,
BirthDate,MaritalStatus,Gender,HireDate from HumanResources.Employee
go

select * from Employees

select * from sys.partitions where [object_id]=object_id('employees')