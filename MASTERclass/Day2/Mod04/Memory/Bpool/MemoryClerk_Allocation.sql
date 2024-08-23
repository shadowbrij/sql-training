-- prior to 2012

select b.type as clerk,a.type as object,* from sys.dm_os_memory_objects a,sys.dm_os_memory_clerks b
where a.page_allocator_address=b.page_allocator_address order by  b.single_pages_kb,a.max_pages_allocated_count

-- 2012

select b.type as clerk,a.type as object,* from sys.dm_os_memory_objects a,sys.dm_os_memory_clerks b
where a.page_allocator_address=b.page_allocator_address order by
b.pages_kb DESC, -- a.max_pages_allocated_count