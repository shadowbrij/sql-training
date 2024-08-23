/******************************************************************************
Find plans performing table scans, clustered index scans, hash joins
*****************************************************************************/
with XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' as sql)
SELECT  st.text
,qp.query_plan
,qp2.query_plan_physical_op
,qp2.query_plan_logical_op
,qp2.query_plan_estimated_tsc
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY (SELECT qp1.query_plan_physical_op
					 ,qp1.query_plan_logical_op
					 ,qp1.query_plan_estimated_tsc
					FROM (SELECT sel.QueryPlan.value('@PhysicalOp', 'VARCHAR(50)')
                     ,sel.QueryPlan.value('@LogicalOp', 'VARCHAR(50)')
                     ,sel.QueryPlan.value('@EstimatedTotalSubtreeCost' , 'FLOAT')
                  FROM qp.query_plan.nodes(
                       N'//sql:RelOp'
                     ) AS sel(QueryPlan)
             ) AS qp1(query_plan_physical_op
						,query_plan_logical_op
						,query_plan_estimated_tsc
						)
     ) AS qp2
WHERE query_plan_physical_op = 'Table Scan'
OR
query_plan_physical_op = 'Clustered Index Scan'
OR
query_plan_physical_op = 'Hash Match'
OR
query_plan_physical_op = 'Index Scan'
OR
query_plan_physical_op = 'Sort'
OR
(query_plan_physical_op = 'Table Spool' AND query_plan_logical_op = 'Lazy Spool')
ORDER BY qp2.query_plan_estimated_tsc DESC