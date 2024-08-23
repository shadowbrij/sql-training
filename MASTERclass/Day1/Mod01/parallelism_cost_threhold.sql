

--Parallelism, in simple words, means that SQL Server can use 2 or more processors to execute your query. Which means, the optimizer produces a parallel plan and you can observe the parallel physical operator (yellow circle with black arrows)


 

--Processors here could be cores or even hyper-threading. You might have one physical processor with 4 cores and SQL Server can use all the cores. Mind you, affinity mask setting and max degree of parallelism should be set correctly so that you can use more than 1 processor.

--The default value of ‘cost threshold of parallelism’ is 5. My audience had a blurred understanding that this value means that if the query takes more than 5 seconds to execute, the optimizer will switch to parallel plans. That is not correct ! And other folks had other ideas !

--SQL Server’s optimizer is a cost based optimizer and it compares the cost of multiple plans before outputting the plan with least cost. And that value of 5 is that cost – there is no Unit of Measurement there (at least, I don’t know of any UOM here).

--So when the optimizer calculates that the cost of a serial plan is more than 5, it switches to a parallel plan. I can demonstrate that with a simple example.

--Here is a query that uses parallel plan.

use AdventureWorks2008R2
GO

select * from sales.SalesOrderDetail
order by LineTotal DESC
GO


 


--If you observe the execution plan and hover your mouse over the SELECT operator, you can see Estimated Subtree Cost is 4.37091. Now, this is a parallel plan and the cost is less than 5. But what is the cost of this plan if it was serial? Let us see that using MAXDOP hint:

use AdventureWorks2008R2
GO

select * from sales.SalesOrderDetail
order by LineTotal DESC
OPTION (MAXDOP 1)
GO

 

--Using the MAXDOP hint, I forced SQL Server to use only one CPU and you can see that the cost is 10.4921. The plan is does not use the parallel physical operator and is a serial plan. This proves that since the cost of serial plan was more than the cost threshold of parallelism value of 5, the optimizer decides to go for a parallel plan.

--Does this mean that if we change the value of 5 to 11 (for example), the optimizer will not output parallel plan? Answer is Yes, the optimizer will not output parallel plan. Let us test it.

--First change the value:

sp_configure 'cost threshold for parallelism', 11
GO
RECONFIGURE
GO


--Run the query again. (Note that there is no hint)


use AdventureWorks2008R2
GO

select * from sales.SalesOrderDetail
order by LineTotal DESC

GO

 

--Does SQL Server produce parallel plan? What is the cost? Is it less than cost threshold of parallelism?

--There’s lot more to this subject and I have just given a simple explanation to clarify the meaning of this server-level property.

--If you liked this post, do like us on FaceBook at http://www.FaceBook.com/SQLServerGeeks

--Regards,

--Amit Bansal

--http://www.twitter.com/A_Bansal
--http://www.twitter.com/SQLServerGeeks
--http://www.amitbansal.net

--Visit my FaceBook page at http://www.facebook.com/AmitRSBansal
--Contribute on SQLServerGeeks.com: visit http://www.sqlservergeeks.com/default-category/write-for-us
