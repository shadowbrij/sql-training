sp_configure 'show advanced options',1
reconfigure

sp_configure 'max worker threads', 150
reconfigure

select count (*) from sys.dm_os_threads

-- restart if required

--enable DAC

sp_configure 'remote admin connections',1
reconfigure