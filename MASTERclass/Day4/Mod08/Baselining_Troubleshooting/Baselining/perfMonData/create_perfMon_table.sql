

CREATE TABLE [dbo].[PerfMonData] (
	[Counter] NVARCHAR(770),
	[Value] DECIMAL(38,2),
	[CaptureDate] DATETIME,
	) ON [PRIMARY];
GO


CREATE CLUSTERED INDEX CI_PerfMonData ON [dbo].[PerfMonData] ([CaptureDate],[Counter]);
CREATE NONCLUSTERED INDEX IX_PerfMonData ON [dbo].[PerfMonData] ([Counter], [CaptureDate]) INCLUDE ([Value]);
