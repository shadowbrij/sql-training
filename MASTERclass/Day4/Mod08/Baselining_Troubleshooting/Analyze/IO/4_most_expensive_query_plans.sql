with XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' as sql)
SELECT qst.text
		,qst.sql_text
		,qst.creation_time
		,qst.last_execution_time
		,qst.execution_count
		,qst.total_worker_time
		,qst.last_worker_time
		,qst.min_worker_time
		,qst.max_worker_time
		,qst.total_physical_reads
		,qst.last_physical_reads
		,qst.min_physical_reads
		,qst.max_physical_reads
		,qst.total_logical_writes
		,qst.last_logical_writes
		,qst.min_logical_writes
		,qst.max_logical_writes
		,qst.total_logical_reads
		,qst.last_logical_reads
		,qst.min_logical_reads
		,qst.max_logical_reads
		,qst.total_elapsed_time
		,qst.last_elapsed_time
		,qst.min_elapsed_time
		,qst.max_elapsed_time
		,qst.total_clr_time
		,qst.min_clr_time
		,qst.max_clr_time
		,qp2.statement_optimization_level
		,qp2.statement_optimization_early_abort_reason
		,qp2.statement_sub_tree_cost
		,qp2.statement_est_rows
  FROM (SELECT st.text
		,SUBSTRING(st.text, qs.statement_start_offset/2,
			(CASE
				WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max), st.text)) * 2
				ELSE qs.statement_end_offset
				END - qs.statement_start_offset)/2) AS sql_text
		,qs.creation_time
		,qs.last_execution_time
		,qs.execution_count
		,qs.total_worker_time
		,qs.last_worker_time
		,qs.min_worker_time
		,qs.max_worker_time
		,qs.total_physical_reads
		,qs.last_physical_reads
		,qs.min_physical_reads
		,qs.max_physical_reads
		,qs.total_logical_writes
		,qs.last_logical_writes
		,qs.min_logical_writes
		,qs.max_logical_writes
		,qs.total_logical_reads
		,qs.last_logical_reads
		,qs.min_logical_reads
		,qs.max_logical_reads
		,qs.total_elapsed_time
		,qs.last_elapsed_time
		,qs.min_elapsed_time
		,qs.max_elapsed_time
		,qs.total_clr_time
		,qs.min_clr_time
		,qs.max_clr_time
		,qs.plan_handle
		,ROW_NUMBER() OVER(PARTITION BY qs.plan_handle
        ORDER BY qs.statement_start_offset) as statement_id
		FROM sys.dm_exec_query_stats qs
		CROSS APPLY sys.dm_exec_sql_text (qs.plan_handle) st
     ) AS qst
CROSS APPLY sys.dm_exec_query_plan (qst.plan_handle) AS qp
CROSS APPLY (SELECT ROW_NUMBER() OVER(ORDER BY qp1.statement_id) as rel_statement_id
					 ,qp1.statement_optimization_level
					 ,qp1.statement_sub_tree_cost
					 ,qp1.statement_optimization_early_abort_reason
					 ,qp1.statement_est_rows
					FROM (SELECT sel.StmtSimple.value('@StatementId', 'int')
                     ,sel.StmtSimple.value('@StatementSubTreeCost', 'float')
                     ,sel.StmtSimple.value('@StatementOptmLevel' , 'varchar(30)')
                     ,sel.StmtSimple.value('@StatementOptmEarlyAbortReason', 'varchar(30)')
                     ,sel.StmtSimple.value('@StatementEstRows', 'float')
                  FROM qp.query_plan.nodes(
                       N'//sql:Batch/sql:Statements/sql:StmtSimple[@StatementType = "SELECT"]'
                     ) AS sel(StmtSimple)
             ) AS qp1(statement_id
						,statement_sub_tree_cost
						,statement_optimization_level
						,statement_optimization_early_abort_reason
						,statement_est_rows)
     ) AS qp2
WHERE qp2.rel_statement_id = qst.statement_id

 