sqlcmd -E -Q"sp_configure 'max server memory',512;reconfigure" -S.\sql2014