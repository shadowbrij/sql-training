select
	name,
	count(s.productid) as NumberOfSales,
	ISNULL(SUM(quantity),0) as SalesQuantityTotal,
	ISNULL(SUM(price*quantity),0) as SalesGrossTotal
FROM
	products p
		left join
	sales s on p.productid=s.productid
group by name

go
select
	name,
	NumberOfSales,
	SalesQuantityTotal,
	SalesGrossTotal
FROM
	Products pout
		left join
	(select
		s.productid,
		count(s.productid) as NumberOfSales,
		ISNULL(SUM(quantity),0) as SalesQuantityTotal,
		ISNULL(SUM(price*quantity),0) as SalesGrossTotal
	from
		sales s 
			join
		products p on s.productid=p.productid
	group by
		s.productid) pin on pout.productid=pin.productid