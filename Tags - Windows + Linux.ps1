$Hosts = "", ""
$TagCategories = "Project", "State"

#If no credentials are saved in PowerShell, will have popup to input them, will be used to connet to servers
IF ($Credentials -isnot [PSCredential]) {
    $Credentials = Get-Credential
}
ForEach($VC in $Hosts){
    Connect-VIServer -Server $vc -Credential $Credentials | Out-Null
}


#Selecting vSphere tag categories to search by
Do{
    $TagCategoriesSelection = $(Write-Host -ForeGroundColor Yellow "What tag category to search for? 'Project' or 'State' "  -NoNewLine ) + $(Read-Host) 
        IF($TagCategories -notcontains $TagCategoriesSelection){
         Write-Host -ForegroundColor Red "Incorrect Input. Try again."
    }
}
While ($TagCategories -notcontains $TagCategoriesSelection)



###############################################################################################################################################
Write-Host -ForegroundColor Yellow "Searching Linux VMs"

$LinVMs = Get-VM  | Where-Object  PowerState -EQ 'PoweredOn' `
                  | Where-Object  Guest -notlike "*Windows*" `
                  | Where-Object  Name -NotLike 'vCLS-*'     `
                  | Where-Object  Name -NotLike '*TMPLT*'    `
                  | Select-Object Name, PowerState, Guest, @{N="Tag";E={(Get-TagAssignment -Entity $_ | where-object Tag -Like "$($TagCategoriesSelection)/*").Tag.Name }}

$LinEmpties = $LinVMs | Where-Object Tag -eq $null 
ForEach($LinEmpty in $LinEmpties){
    $LinEmpty.Tag = "NONE"
}

$LinCount = $LinVMs | Group-Object -Property Tag | Sort-Object Name -Unique | Sort-Object Count -Descending

###############################################################################################################################################
Write-Host -ForegroundColor Yellow "Searching Windows VMs"

$WinVMs = Get-VM | Where-Object  PowerState -EQ 'PoweredOn' `
                 | Where-Object  Guest -like "*Windows*"    `
                 | Where-Object  Name -NotLike 'vCLS-*'     `
                 | Where-Object  Name -NotLike '*TMPLT*'    `
                 | Select-Object Name, PowerState, Guest, @{N="Tag";E={(Get-TagAssignment -Entity $_ | where-object Tag -Like "$($TagCategoriesSelection)/*").Tag.Name }}

$WinEmpties = $WinVMs | Where-Object Tag -eq $null
ForEach($WinEmpty in $WinEmpties){
    $WinEmpty.Tag = "NONE"
}

$WinCount = $WinVMs | Group-Object -Property Tag | Sort-Object Name -Unique | Sort-Object Count -Descending

###############################################################################################################################################
Write-Host -ForegroundColor Yellow "Compiling VMs"

$TotVMs = Get-VM | Where-Object  PowerState -EQ 'PoweredOn' `
                 | Where-Object  Name -NotLike 'vCLS-*'     `
                 | Where-Object  Name -NotLike '*TMPLT*'    `
                 | Select-Object Name, PowerState, Guest, @{N="Tag";E={(Get-TagAssignment -Entity $_ | where-object Tag -Like "$($TagCategoriesSelection)/*").Tag.Name }}

$TotEmpties = $TotVMs | Where-Object Tag -eq $null 
ForEach($TotEmpty in $TotEmpties){
    $TotEmpty.Tag = "NONE"
}

$TotCount = $TotVMs | Group-Object -Property Tag | Sort-Object Name -Unique | Sort-Object Count -Descending

###############################################################################################################################################

#Outputs:

Write-Host -ForegroundColor Yellow "Total Linux VMs:" $LinVMs.Count
$LinCount | Select-Object Count, @{N='Tag';E={$_.Name}} | Format-Table -AutoSize

Write-Host -ForegroundColor Yellow "Total Windows VMs:" $WinVMs.Count
$WinCount | Select-Object Count, @{N='Tag';E={$_.Name}} | Format-Table -AutoSize

Write-Host -ForegroundColor Yellow "Total All VMs:" $TotVMs.Count
$TotCount | Select-Object Count, @{N='Tag';E={$_.Name}} | Format-Table -AutoSize

###############################################################################################################################################

#VM List outputs:

#$LinVMs | Select-Object Name, Tag, @{N="OS";E={($_.Guest.OSFullName)}}, @{N="IP";E={($_.Guest.IPAddress -join ', ' -replace , ', .*$', '')}}, PowerState | Sort-Object Name | Sort-Object Tag  | Format-Table -Autosize
#$WinVMs | Select-Object Name, Tag, @{N="OS";E={($_.Guest.OSFullName)}}, @{N="IP";E={($_.Guest.IPAddress -join ', ' -replace , ', .*$', '')}}, PowerState | Sort-Object Name | Sort-Object Tag  | Format-Table -Autosize
#$TotVMs | Select-Object Name, Tag, @{N="OS";E={($_.Guest.OSFullName)}}, @{N="IP";E={($_.Guest.IPAddress -join ', ' -replace , ', .*$', '')}}, PowerState | Sort-Object Name | Sort-Object Tag  | Format-Table -Autosize


#Output Project and State tag categories, to be replaced in relevant sections in script
#Select-Object Name, PowerState, Guest, @{N="Tag";E={(Get-TagAssignment -Entity $_ | where-object Tag -Like 'Project/*').Tag.Name }}}
