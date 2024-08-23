
/****** Object:  Table [dbo].[AlwaysOnData]    Script Date: 4/4/2013 10:57:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AlwaysOnData](
	[SnapshotTime] [datetime] NOT NULL,
	[AvailabilityReplicaServerName] [nvarchar](256) NULL,
	[AvailabilityDatabaseName] [nvarchar](128) NULL,
	[AvailabilityDateabaseId] [uniqueidentifier] NOT NULL,
	[AvailabilityGroupId] [uniqueidentifier] NULL,
	[AvailabilityGroupName] [sysname] NULL,
	[AvailabilityReplicaId] [uniqueidentifier] NULL,
	[DatabaseId] [int] NOT NULL,
	[EndOfLogLSN] [numeric](25, 0) NOT NULL,
	[EstimatedDataLoss] [int] NOT NULL,
	[EstimatedRecoveryTime] [float] NOT NULL,
	[FileStreamSendRate] [bigint] NOT NULL,
	[IsFailoverReady] [bit] NOT NULL,
	[IsJoined] [bit] NOT NULL,
	[IsLocal] [bit] NOT NULL,
	[IsSuspended] [bit] NOT NULL,
	[LastCommitLSN] [numeric](25, 0) NOT NULL,
	[LastCommitTime] [datetime] NOT NULL,
	[LastHardenedLSN] [numeric](25, 0) NOT NULL,
	[LastHardenedTime] [datetime] NOT NULL,
	[LastReceivedLSN] [numeric](25, 0) NOT NULL,
	[LastReceivedTime] [datetime] NOT NULL,
	[LastRedoneLSN] [numeric](25, 0) NOT NULL,
	[LastRedoneTime] [datetime] NOT NULL,
	[LastSentLSN] [numeric](25, 0) NOT NULL,
	[LastSentTime] [datetime] NOT NULL,
	[LogSendQueueSize] [bigint] NOT NULL,
	[LogSendRate] [bigint] NOT NULL,
	[RecoveryLSN] [numeric](25, 0) NOT NULL,
	[RedoQueueSize] [bigint] NOT NULL,
	[RedoRate] [bigint] NOT NULL,
	[ReplicaAvailabilityMode] [tinyint] NOT NULL,
	[ReplicaRole] [tinyint] NOT NULL,
	[SuspendReason] [tinyint] NOT NULL,
	[SynchronizationPerformance] [float] NOT NULL,
	[SynchronizationState] [tinyint] NOT NULL,
	[TruncationLSN] [numeric](25, 0) NOT NULL
) ON [PRIMARY]

GO


