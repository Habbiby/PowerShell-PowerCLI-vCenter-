Get-VM | Select-Object Name, ProvisionedSpaceGB, @{N="Datastore";E={[string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select-Object -ExpandProperty Name))}} `
  | export-csv C:\TEMP\vSphereStores.csv
