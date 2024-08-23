@Echo Off
ECHO Preparing the demo environment...

REM - Get current directory
SET SUBDIR=%~dp0
SQLCMD -S.\SQL2014 -E -i %SUBDIR%CreateProc.sql 
exit