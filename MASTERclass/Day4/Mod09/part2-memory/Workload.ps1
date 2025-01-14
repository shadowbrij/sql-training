﻿# Load the SMO assembly 
[void][reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo"); 

# Set the server to run the workload against 
$ServerName = "win2k8r2\sql2012sp1"; 

# Split the input on the delimeter 
$Queries = Get-Content -Delimiter "------" -Path "memory_pressure.sql" 

WHILE(1 -eq 1) 
{ 
    # Pick a Random Query from the input object 
    $Query = Get-Random -InputObject $Queries; 

    #Get a server object which corresponds to the default instance 
    $srv = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Server $ServerName

    $srv.ConnectionContext.LoginSecure=$false

    $srv.ConnectionContext.set_Login("sa")
    $srv.ConnectionContext.set_Password("di123!")


    # Use the AdventureWorks2008R2 database 
    $srv.ConnectionContext.set_DatabaseName("Tuning32")

    # Execute the query with ExecuteNonQuery 
    $srv.ConnectionContext.ExecuteNonQuery($Query); 
    

    # Disconnect from the server 
    $srv.ConnectionContext.Disconnect(); 
    
    # Sleep for 100 miliseconds between loops 
    Start-Sleep -Milliseconds 100 
} 

