CREATE PROCEDURE GetAlwaysOnData 

@AGName nvarchar(4000)

AS

BEGIN

	exec sp_executesql N'

		  select * into #tmpag_availability_groups from master.sys.availability_groups

		  select group_id, replica_id,replica_server_name,availability_mode into #tmpdbr_availability_replicas from master.sys.availability_replicas

		  select replica_id,group_database_id,database_name,is_database_joined,is_failover_ready into #tmpdbr_database_replica_cluster_states from master.sys.dm_hadr_database_replica_cluster_states

		  select * into #tmpdbr_database_replica_states from master.sys.dm_hadr_database_replica_states

		  select replica_id,role,is_local into #tmpdbr_availability_replica_states from master.sys.dm_hadr_availability_replica_states

		  select ars.role, drs.database_id, drs.replica_id, drs.last_commit_time into #tmpdbr_database_replica_states_primary_LCT from  #tmpdbr_database_replica_states as drs left join #tmpdbr_availability_replica_states ars on drs.replica_id = ars.replica_id 

		  where ars.role = 1

	INSERT INTO AlwaysOnData

	SELECT

	GetDate() AS SnapshotTime,

	AR.replica_server_name AS [AvailabilityReplicaServerName],

	dbcs.database_name AS [AvailabilityDatabaseName],

	dbcs.group_database_id AS [AvailabilityDateabaseId],

	AR.group_id AS [AvailabilityGroupId],

	AG.name AS [AvailabilityGroupName],

	AR.replica_id AS [AvailabilityReplicaId],

	ISNULL(dbr.database_id, 0) AS [DatabaseId],

	ISNULL(dbr.end_of_log_lsn, 0) AS [EndOfLogLSN],

	CASE dbcs.is_failover_ready WHEN 1 THEN 0 ELSE ISNULL(DATEDIFF(ss, dbr.last_commit_time, dbrp.last_commit_time), 0) END  AS [EstimatedDataLoss],

	ISNULL(CASE dbr.redo_rate WHEN 0 THEN -1 ELSE CAST(dbr.redo_queue_size AS float) / dbr.redo_rate END, -1) AS [EstimatedRecoveryTime],

	ISNULL(dbr.filestream_send_rate, -1) AS [FileStreamSendRate],

	ISNULL(dbcs.is_failover_ready, 0) AS [IsFailoverReady],

	ISNULL(dbcs.is_database_joined, 0) AS [IsJoined],

	arstates.is_local AS [IsLocal],

	ISNULL(dbr.is_suspended, 0) AS [IsSuspended],

	ISNULL(dbr.last_commit_lsn, 0) AS [LastCommitLSN],

	ISNULL(dbr.last_commit_time, 0) AS [LastCommitTime],

	ISNULL(dbr.last_hardened_lsn, 0) AS [LastHardenedLSN],

	ISNULL(dbr.last_hardened_time, 0) AS [LastHardenedTime],

	ISNULL(dbr.last_received_lsn, 0) AS [LastReceivedLSN],

	ISNULL(dbr.last_received_time, 0) AS [LastReceivedTime],

	ISNULL(dbr.last_redone_lsn, 0) AS [LastRedoneLSN],

	ISNULL(dbr.last_redone_time, 0) AS [LastRedoneTime],

	ISNULL(dbr.last_sent_lsn, 0) AS [LastSentLSN],

	ISNULL(dbr.last_sent_time, 0) AS [LastSentTime],

	ISNULL(dbr.log_send_queue_size, -1) AS [LogSendQueueSize],

	ISNULL(dbr.log_send_rate, -1) AS [LogSendRate],

	ISNULL(dbr.recovery_lsn, 0) AS [RecoveryLSN],

	ISNULL(dbr.redo_queue_size, -1) AS [RedoQueueSize],

	ISNULL(dbr.redo_rate, -1) AS [RedoRate],

	ISNULL(AR.availability_mode, 2) AS [ReplicaAvailabilityMode],

	ISNULL(arstates.role, 3) AS [ReplicaRole],

	ISNULL(dbr.suspend_reason, 7) AS [SuspendReason],

	ISNULL(CASE dbr.log_send_rate WHEN 0 THEN -1 ELSE CAST(dbr.log_send_queue_size AS float) / dbr.log_send_rate END, -1) AS [SynchronizationPerformance],

	ISNULL(dbr.synchronization_state, 0) AS [SynchronizationState],

	ISNULL(dbr.truncation_lsn, 0) AS [TruncationLSN]

	FROM

	#tmpag_availability_groups AS AG

	INNER JOIN #tmpdbr_availability_replicas AS AR ON AR.group_id=AG.group_id

	INNER JOIN #tmpdbr_database_replica_cluster_states AS dbcs ON dbcs.replica_id = AR.replica_id

	LEFT OUTER JOIN #tmpdbr_database_replica_states AS dbr ON dbcs.replica_id = dbr.replica_id AND dbcs.group_database_id = dbr.group_database_id

	LEFT OUTER JOIN #tmpdbr_database_replica_states_primary_LCT AS dbrp ON dbr.database_id = dbrp.database_id

	INNER JOIN #tmpdbr_availability_replica_states AS arstates ON arstates.replica_id = AR.replica_id

	WHERE

	(AG.name=@_msparam_0)

	ORDER BY

	[AvailabilityReplicaServerName] ASC,[AvailabilityDatabaseName] ASC



	DROP TABLE #tmpdbr_availability_replicas

	DROP TABLE #tmpdbr_database_replica_cluster_states

	DROP TABLE #tmpdbr_database_replica_states

	DROP TABLE #tmpdbr_database_replica_states_primary_LCT

	DROP TABLE #tmpdbr_availability_replica_states

	drop table #tmpag_availability_groups



	',N'@_msparam_0 nvarchar(4000)',@_msparam_0=@AGName







END