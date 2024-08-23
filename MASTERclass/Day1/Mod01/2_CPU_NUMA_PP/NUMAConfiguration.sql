-- View NUMA configuration
select * from sys.dm_os_nodes

-- View CPU and NUMA correlation
select scheduler_id, [status], parent_node_id from sys.dm_os_schedulers OSS
inner join sys.dm_os_nodes OSN
ON OSS.parent_node_id = OSN.node_id
where OSS.status like 'visible online%'

