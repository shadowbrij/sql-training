-- Listing 2: Query to Identify Poorly Designed Indexes

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
WITH XMLNAMESPACES   
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')  
SELECT  
     query_plan AS CompleteQueryPlan, 
     n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') AS StatementSubTreeCost, 
     dm_ecp.usecounts
FROM sys.dm_exec_cached_plans AS dm_ecp 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS dm_eqp 
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qp(n) 
ORDER BY n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') DESC
GO 
