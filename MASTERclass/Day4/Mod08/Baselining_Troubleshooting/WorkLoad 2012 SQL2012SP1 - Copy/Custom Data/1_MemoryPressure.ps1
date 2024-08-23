# Load the SMO assembly 
[void][reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo"); 

# Set the server to run the workload against 
$ServerName = "win2012r2\sql2014"; 

# Split the input on the delimeter 
$Queries = Get-Content -Delimiter "------" -Path "MemoryPressure.sql" 

WHILE(1 -eq 1) 
{ 
    # Pick a Random Query from the input object 
    $Query = Get-Random -InputObject $Queries; 

    #Get a server object which corresponds to the default instance 
    $srv = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Server $ServerName

    $srv.ConnectionContext.LoginSecure=$true


    # Use the AdventureWorks2008R2 database 
    $srv.ConnectionContext.set_DatabaseName("AdventureWorks2008R2")

    # Execute the query with ExecuteNonQuery 
    $srv.ConnectionContext.ExecuteNonQuery($Query); 
    

    # Disconnect from the server 
    $srv.ConnectionContext.Disconnect(); 
    
    # Sleep for 100 miliseconds between loops 
    Start-Sleep -Milliseconds 100 
} 

