#$pattern = '*NBBACKUPSTANDARD'

$VMTags = Get-VM | Where-Object  PowerState -EQ 'PoweredOn' `
                 | Where-Object  Name -NotLike 'vCLS-*'     `
                 | Where-Object  Name -NotLike '*TMPLT*'    `
                 | Select-Object Name, @{N="Tag";E={(Get-TagAssignment -Entity $_).Tag.Name -join ';' `
                    -replace 'NB_BACKUP_STANDARD', ''       `
                    -replace 'NB_BACKUP_MSSQL', ''          `
                    -replace 'NB_BACKUP_PABX', ''           `
                    -replace ';', '' 
                    }}


$Empties = $VMTags | Where-Object Tag -eq ''
ForEach($Empty in $Empties){
    $Empty.Tag = "NONE"
}


$VMTags | Sort-Object Tag -Descending | Format-Table -Autosize

$Count = $VMTags + $Empties | Group-Object -Property Tag | Sort-Object Count -Descending
$Count | Select-Object Count, @{N='Tag';E={$_.Name}}
