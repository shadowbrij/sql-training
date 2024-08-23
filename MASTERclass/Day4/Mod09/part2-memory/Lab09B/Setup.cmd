@Echo Off
ECHO Preparing the demo environment...

REM - Get current directory
SET SUBDIR=%~dp0


REM - Restart SQL Server Service to force closure of any open connections
NET STOP SQLSERVERAGENT
NET STOP MSSQLSERVER
NET START MSSQLSERVER
NET START SQLSERVERAGENT

REM - Run SQL Script to prepare the database environment
ECHO Preparing databases...
SQLCMD -E -i %SUBDIR%SetupFiles\Setup.sql > NUL

REM - Do anything else that's required to reset the demo environment for this module
REM - e.g. delete files created during the demos
