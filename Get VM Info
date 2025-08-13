 <#==========================================================================
    DESCRIPTION
    This script was created to collect information on vCenter VMs
    Functions:
        1. Tests connection to the respective servers
            1.1. Prompts for login if the server is not in the $global:DefaultVIServers list (connected + authenticated)
        2. Collects information for each VM on that server
            2.1 NumCpu,CoresPerSocket,MemoryGB,PowerState,ProvisionedSpaceGB,UsedSpaceGB,CreateDate,Notes
        3. Exports to C:\Temp\vSphere-Export-DD-MM-YYYY.csv
        4. Requests from the user if the connection is to be closed for each server at the end of the script
    ==========================================================================
    PREREQUISITES
        1. Install the required module for PowerShell to run the script
            1.1 >Install-Module VMware.PowerCLI

        2. (Optional) Automatically accepts the certificate from the server (Already done as part of script)
            2.2 >Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false 

        3. (Optional) Allows the user to be connected to multiple servers at once (This option will come up the first time you run the script with a prompt)
            3.3 >Set-PowerCLIConfiguration -DefaultVIServerMode multiple -Confirm:$false 

        4. (Optional) Disables additional PowerShell warning / messages 
            4.4 >Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
    ========================================================================== 
    OTHER
        1. Get-VirtualNetwork
    
    
    ========================================================================== #>

#Automatically accepts the certificate from the server
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

#vCenter Server List
$vCenterList = "", ""

#Setting variables for the file name export
$Date = Get-Date -Format dd-MM-yyyy
$Export = "C:\TEMP\vSphere-Export-$Date.csv"

#Exports required information from vCenter - use "get-vm | fl" to get a list of variables
$GetVMInfo = {
Get-VM | Select Name, @{N="Guest OS";E={$_.ExtensionData.Config.GuestFullName}}, @{N="vCentre Host";E={(($_).Uid.Split(":")[0].Split("@")[1])}},`
NumCpu,CoresPerSocket,MemoryGB,ProvisionedSpaceGB,UsedSpaceGB,PowerState,CreateDate,Notes}

#Prompts for credentials if PSCredential is empty (Saves from doing multiple credential inputs per script)
if ($Credentials -isnot [PSCredential]) {
    write-host 'Include "Lotterywest\" in the User Name field.' -ForegroundColor Yellow
    $Credentials = Get-Credential
}


FOREACH ($vCenter in $vCenterList){

    #Checks if vCenter server name returns as true or false in the local machine VIServers list (active connections)
    IF($global:DefaultVIServers.Name -contains $vCenter){
        write-host "Connected to $vCenter as" $global:DefaultVIServer.User -ForegroundColor Green
        write-host "Collecting information from $vCenter..."
        & $GetVMInfo | Export-Csv "$Export" -NoTypeInformation -UseCulture | Sort-Object "vCentre Host"
        write-host "Exported to $Export"
        write-host '==============================================================='
    }

    #Tries to connect to the vCenter server with the previously given credentials
    ELSE{
        write-host "Trying to connect to $vCenter with your credentials..." -ForegroundColor Red
        Connect-VIServer -Server $vCenter -Credential $Credentials | Out-Null

        #Checks if vCenter server name returns as true or false in the local machine VIServers list (active connections)
        IF($global:DefaultVIServers.Name -contains $vCenter){
            write-host "Connected to $vCenter as" $global:DefaultVIServer.User -ForegroundColor Green
            write-host "Collecting information from $vCenter..."
            & $GetVMInfo | Export-Csv "$Export" -NoTypeInformation -UseCulture | Sort-Object "vCentre Host"
            write-host "Exported to $Export"
            write-host '==============================================================='
            }
        ELSE{
        write-host "Incorrect login credentials or unknown error"
        }  
    }
}

#Prompts the user if they would like to remain connected to the vCenter servers,  will either disconnect from each server, or do nothing
$Disconnect = $(Write-Host "Would you like to disconnect from $vCenterList ? Y/N " -ForegroundColor Yellow -NoNewLine;Read-Host)
FOREACH ($vCenter in $vCenterList){
    IF($Disconnect -eq "Y"){
        Disconnect-VIServer $vCenter -force -Confirm:$false -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Connection with $vCenter closed"
        }
    ELSE{
        Write-Host "Connection with $vCenter still open"
    }
 }
