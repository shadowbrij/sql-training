[void][reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo"); 

$ServerName = "localhost\SQL2014"; 

$Queries = Get-Content -Delimiter "------" -Path "IO_load.sql" 

WHILE($error.Count -eq 0) 
{ 
    $Query = Get-Random -InputObject $Queries; 

    $srv = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Server $ServerName

    $srv.ConnectionContext.LoginSecure=$true

    $srv.ConnectionContext.set_DatabaseName("AdventureWorks2014")

    $srv.ConnectionContext.ExecuteNonQuery($Query); 
    
    $srv.ConnectionContext.Disconnect(); 
}