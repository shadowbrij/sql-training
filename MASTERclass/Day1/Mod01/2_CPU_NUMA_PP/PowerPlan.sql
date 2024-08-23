-- View Power Plan Configuration
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE
GO
EXEC master.dbo.xp_cmdshell 'powercfg /list';
GO
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE
GO
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE
GO

-- Sample Output
--NULL
--Existing Power Schemes (* Active)
-------------------------------------
--Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced) *
--Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance)
--Power Scheme GUID: a1841308-3541-4fab-bc81-f71556f20b4a  (Power saver)
--NULL

-- Check BIOS settings too...