select top 10 AP.plan_handle, AP.text, AP.query_plan, QS.sql_handle from analyzing_plans AP
inner join
query_stats QS
on AP.plan_handle = QS.plan_handle
where AP.collection_id=14
order by QS.total_logical_reads DESC




and PLAN_HANDle = '0x06000C00E324A51950F4D8D30100000001000000000000000000000000000000000000000000000000000000'