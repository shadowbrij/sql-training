-- Few queries that cab be used to troubleshoot SQL Server memory issues.
-- KPK
 
--Bpool stats
select (bpool_committed * 8192)/ (1024*1024) as bpool_committed_mb
, (cast(bpool_commit_target as bigint) * 8192) / (1024*1024) as bpool_target_mb,
(bpool_visible * 8192) / (1024*1024) as bpool_visible_mb
from sys.dm_os_sys_info
go
 
 
-- Get me physical RAM installed
-- and size of user VAS
select physical_memory_in_bytes/(1024*1024) as phys_mem_mb, 
virtual_memory_in_bytes/(1024*1024) as user_virtual_address_space_size
from sys.dm_os_sys_info
go
--
-- Get me other information about system memory
--
select total_physical_memory_kb/(1024) as phys_mem_mb,
available_physical_memory_kb/(1024) as avail_phys_mem_mb,
system_cache_kb/(1024) as sys_cache_mb,
(kernel_paged_pool_kb+kernel_nonpaged_pool_kb)/(1024) as kernel_pool_mb,
total_page_file_kb/(1024) as total_virtual_memory_mb,
available_page_file_kb/(1024) as available_virtual_memory_mb,
system_memory_state_desc
from sys.dm_os_sys_memory
go
-- Get me memory information about SQLSERVR.EXE process
-- GetMemoryProcessInfo() API used for this
-- physical_memory_in_use_kb
select physical_memory_in_use_kb/(1024) as sql_physmem_inuse_mb,
locked_page_allocations_kb/(1024) as awe_memory_mb,
total_virtual_address_space_kb/(1024) as max_vas_mb,
virtual_address_space_committed_kb/(1024) as sql_committed_mb,
memory_utilization_percentage as working_set_percentage,
virtual_address_space_available_kb/(1024) as vas_available_mb,
process_physical_memory_low as is_there_external_pressure,
process_virtual_memory_low as is_there_vas_pressure
from sys.dm_os_process_memory
go
select * from sys.dm_os_ring_buffers 
where ring_buffer_type like 'RING_BUFFER_RESOURCE%'
go
select memory_node_id as node, virtual_address_space_reserved_kb/(1024) as VAS_reserved_mb,
virtual_address_space_committed_kb/(1024) as virtual_committed_mb,
locked_page_allocations_kb/(1024) as locked_pages_mb,
single_pages_kb/(1024) as single_pages_mb,
multi_pages_kb/(1024) as multi_pages_mb,
shared_memory_committed_kb/(1024) as shared_memory_mb
from sys.dm_os_memory_nodes
where memory_node_id != 64
go
 
 
with vasummary(Size,reserved,free) as ( select size = vadump.size,
reserved = SUM(case(convert(int, vadump.base) ^ 0)  when 0 then 0 else 1 end),
free = SUM(case(convert(int, vadump.base) ^ 0x0) when 0 then 1 else 0 end)
from
(select CONVERT(varbinary, sum(region_size_in_bytes)) as size,
region_allocation_base_address as base
from sys.dm_os_virtual_address_dump
where region_allocation_base_address <> 0x0
group by region_allocation_base_address
UNION(
select CONVERT(varbinary, region_size_in_bytes),
region_allocation_base_address
from sys.dm_os_virtual_address_dump
where region_allocation_base_address = 0x0)
)
as vadump
group by size)
 
 
select * from vasummary
go
 
-- Get me all clerks that take some memory
--
select * from sys.dm_os_memory_clerks
where (single_pages_kb > 0) or (multi_pages_kb > 0)
or (virtual_memory_committed_kb > 0)
go
-- Get me stolen pages
--
select (SUM(single_pages_kb)*1024)/8192 as total_stolen_pages
from sys.dm_os_memory_clerks
go
-- Breakdown clerks with stolen pages
select type, name, sum((single_pages_kb*1024)/8192) as stolen_pages
from sys.dm_os_memory_clerks
where single_pages_kb > 0
group by type, name
order by stolen_pages desc
go
-- Get me the total amount of memory consumed by multi_page consumers
--
select SUM(multi_pages_kb)/1024 as total_multi_pages_mb
from sys.dm_os_memory_clerks
go
-- What about multi_page consumers
--
select type, name, sum(multi_pages_kb)/1024 as multi_pages_mb
from sys.dm_os_memory_clerks
where multi_pages_kb > 0
group by type, name
order by multi_pages_mb desc
go
-- Let's now get the total consumption of virtual allocator
--
select SUM(virtual_memory_committed_kb)/1024 as total_virtual_mem_mb
from sys.dm_os_memory_clerks
go
-- Breakdown the clerks who use virtual allocator
--
select type, name, sum(virtual_memory_committed_kb)/1024 as virtual_mem_mb
from sys.dm_os_memory_clerks
where virtual_memory_committed_kb > 0
group by type, name
order by virtual_mem_mb desc
go
-- Is anyone using AWE allocator?
--
select SUM(awe_allocated_kb)/1024 as total_awe_allocated_mb
from sys.dm_os_memory_clerks
go
-- Who is the AWE user?
--
select type, name, sum(awe_allocated_kb)/1024 as awe_allocated_mb
from sys.dm_os_memory_clerks
where awe_allocated_kb > 0
group by type, name
order by awe_allocated_mb desc
go
-- What is the total memory used by the clerks?
--
select (sum(multi_pages_kb)+
SUM(virtual_memory_committed_kb)+
SUM(awe_allocated_kb))/1024
from sys.dm_os_memory_clerks
go
--
-- Does this sync up with what the node thinks?
--
select SUM(virtual_address_space_committed_kb)/1024 as total_node_virtual_memory_mb,
SUM(locked_page_allocations_kb)/1024 as total_awe_memory_mb,
SUM(single_pages_kb)/1024 as total_single_pages_mb,
SUM(multi_pages_kb)/1024 as total_multi_pages_mb
from sys.dm_os_memory_nodes
where memory_node_id != 64
go
--
-- Total memory used by SQL Server through SQLOS memory nodes
-- including DAC node
-- What takes up the rest of the space?
select (SUM(virtual_address_space_committed_kb)+
SUM(locked_page_allocations_kb)+
SUM(multi_pages_kb))/1024 as total_sql_memusage_mb
from sys.dm_os_memory_nodes
go
-- 
-- Who are the biggest cache stores?
select name, type, (SUM(single_pages_kb)+SUM(multi_pages_kb))/1024 
as cache_size_mb
from sys.dm_os_memory_cache_counters
where type like 'CACHESTORE%'
group by name, type
order by cache_size_mb desc
go
--
-- Who are the biggest user stores?
select name, type, (SUM(single_pages_kb)+SUM(multi_pages_kb))/1024 
as cache_size_mb
from sys.dm_os_memory_cache_counters
where type like 'USERSTORE%'
group by name, type
order by cache_size_mb desc
go
--
-- Who are the biggest object stores?
select name, type, (SUM(single_pages_kb)+SUM(multi_pages_kb))/1024 
as cache_size_mb
from sys.dm_os_memory_clerks
where type like 'OBJECTSTORE%'
group by name, type
order by cache_size_mb desc
go
select mc.type, mo.type from sys.dm_os_memory_clerks mc
join sys.dm_os_memory_objects mo
on mc.page_allocator_address = mo.page_allocator_address
group by mc.type, mo.type
order by mc.type, mo.type
go
 

