--basic cte
with salesbyyearCTE(employeeid,saleid,salesyear)
as
(	
	select employeeid,saleid,year(saledate) as salesYear
	from sales
)
select employeeid,count(saleid) as totalsales,salesyear
from 
	salesbyyearcte
where 
	salesyear>=year(dateadd(yyyy,-5,getdate()))
group by 
	salesyear,employeeid
order by 
	employeeid,salesyear
go

select employeeid,count(saleid),year(saledate) as salesYear
	from sales
	where 
	year(saledate)>=year(dateadd(yyyy,-5,getdate()))
	group by employeeid,year(saledate)
	order by employeeid,salesyear
go
--------------------------------------

--multiple table CTE

with EmployeeProductSales(Employeeid,productid,totalsales) as
(
	select e.employeeid,p.productid,sum(price*quantity) as TotalSales
	from  employees e
	join
	sales s on e.employeeid=s.employeeid
	join
	products p on s.productid=p.productid
	group by p.productid,e.employeeid
),
productinfo(productid,productname,price) as
(select productid,name,price
	from products
),
employeeinfo(employeeid,employeename) as
(select employeeid,COALESCE(firstname + ' ' + Middlename + ' ' + lastname, firstname + ' ' + lastname,firstname,lastname) as EmployeeName
from employees
)
select 
	[pi].productname,ei.employeename,eps.totalsales
from
	employeeproductsales eps
	join
	productinfo pi on pi.productid=eps.productid
	join
	employeeinfo ei on ei.employeeid=eps.employeeid
order by 
	productname,totalsales desc,employeename
-----------------------------------------------------------------------------
--recursive cte
WITH EmpsCTE AS
(
--anchor set
SELECT employeeid, managerid, firstname, lastname,title, 0 AS distance
FROM Employees
WHERE employeeid = 4
UNION ALL
--recursive set
SELECT M.employeeid, M.managerid, M.firstname, M.lastname,m.title, S.distance + 1 AS distance
FROM EmpsCTE AS S
JOIN Employees AS M
ON S.managerid = M.employeeid
)
SELECT employeeid, managerid, firstname, lastname,title, distance
FROM EmpsCTE;

select * from employees