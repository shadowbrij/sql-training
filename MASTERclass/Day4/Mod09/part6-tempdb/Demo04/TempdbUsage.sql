--find tempdb usage
SELECT ssu.session_id,
	ssu.user_objects_alloc_page_count/128 AS user_objs_total_sizeMB,
	(ssu.user_objects_alloc_page_count - ssu.user_objects_dealloc_page_count)/128.0 AS user_objs_active_sizeMB,
	ssu.internal_objects_alloc_page_count/128 AS internal_objs_total_sizeMB,
	(ssu.internal_objects_alloc_page_count - ssu.internal_objects_dealloc_page_count)/128.0 AS internal_objs_active_sizeMB
FROM sys.dm_db_session_space_usage ssu
ORDER BY user_objects_alloc_page_count DESC
GO

--Find query
DBCC INPUTBUFFER(55) -- replace the session_id with the top session_id using highest tempdb space
GO