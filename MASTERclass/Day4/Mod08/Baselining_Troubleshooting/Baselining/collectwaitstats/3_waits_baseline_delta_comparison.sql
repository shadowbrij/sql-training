-- supply a value for collection id

DECLARE @coll_id_1 bigint=1
IF OBJECT_ID('baseline..waits_snapshot1') IS NULL
BEGIN
	SELECT
		*
	INTO waits_snapshot1
	FROM dbo.waits
	where collection_id=@coll_id_1
END
ELSE
BEGIN
TRUNCATE TABLE waits_snapshot1
INSERT waits_snapshot1 WITH (TABLOCK)
	SELECT
		*
	FROM dbo.waits
	where collection_id=@coll_id_1
END

-- SELECT * from waits_snapshot1


-- supply a value for collection id

DECLARE @coll_id_2 bigint=5
IF OBJECT_ID('baseline..waits_snapshot2') IS NULL
BEGIN
	SELECT
		*
	INTO waits_snapshot2
	FROM dbo.waits
	where collection_id=@coll_id_2
END
ELSE
BEGIN
TRUNCATE TABLE waits_snapshot2
INSERT waits_snapshot2 WITH (TABLOCK)
	SELECT
		*
	FROM dbo.waits
	where collection_id=@coll_id_2
END

-- SELECT * from waits_snapshot2



-- main query
  SELECT
    *
  FROM
  (
	  SELECT
		  CASE n.m
			  WHEN 1 THEN 
				  p.wait_type + ' (wait time)'
			  WHEN 2 THEN
				  p.wait_type + ' (wait count)'
			  WHEN 3 THEN
				  p.wait_type + ' (maximum)'
			  ELSE 
				  'SIGNAL_WAIT_TIME'
		  END AS wait_type,
		  CASE n.m
			  WHEN 1 THEN
				  (c.wait_time_ms - c.signal_wait_time_ms) - (p.wait_time_ms - p.signal_wait_time_ms) 
			  WHEN 2 THEN
				  c.waiting_tasks_count - p.waiting_tasks_count
			  WHEN 3 THEN
				  p.max_wait_time_ms
			  ELSE
				  SUM(CASE WHEN n.m = 1 AND c.wait_type <> 'SLEEP_TASK' THEN c.signal_wait_time_ms ELSE 0 END) OVER () - 
					  SUM(CASE WHEN n.m = 1 AND p.wait_type <> 'SLEEP_TASK' THEN p.signal_wait_time_ms ELSE 0 END) OVER ()
		  END AS wait_delta
	  FROM waits_snapshot1 AS p
	  INNER JOIN waits_snapshot2 AS c ON
		  c.wait_type = p.wait_type
		  AND c.signal_wait_time_ms >= p.signal_wait_time_ms
	  CROSS APPLY
	  (
		  SELECT 1
		  UNION ALL
		  SELECT 2
		  UNION ALL
		  SELECT 3
		  WHERE
			  p.max_wait_time_ms > c.max_wait_time_ms
		  UNION ALL
		  SELECT 4
		  WHERE
			  p.wait_type = 'SOS_SCHEDULER_YIELD'
	  ) AS n (m)
	  WHERE
		  p.wait_type NOT IN ('MISCELLANEOUS', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT')
  ) AS x
  WHERE
    x.wait_delta >= 0
	order by wait_delta DESC