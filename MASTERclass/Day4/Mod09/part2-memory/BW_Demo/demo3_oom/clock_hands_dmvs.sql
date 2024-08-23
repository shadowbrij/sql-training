-- Show the external and interanl clock hands for plan cache stores
--
select name, type, clock_hand,  rounds_count, removed_all_rounds_count from sys.dm_os_memory_cache_clock_hands where type in 
('CACHESTORE_OBJCP', 'CACHESTORE_SQLCP', 'CACHESTORE_PHDR', 'CACHESTORE_XPROC')
go

