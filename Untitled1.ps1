#hash
#$hash = @{}
#$hash.Add("name","erkan")
#$hash.Add("job","developer")
#$hash["name"] = "Pelin"
#
#$hash["name"]
#$hash.GetType()
#$hash.Count


$machine = $env:COMPUTERNAME + "\SQL14"
#DESKTOP10\SQL14
$dbname = "web"

#(Get-Item sqlserver:\sql\$machine\databases\$dbname\tables).Collection |
#    Select-Object Schema, Name, Rowcount |
#    Sort-Object Scema, Name |
#    Format-Table -AutoSize

$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
$database = $Server.Databases[$dbname]

$tbl = $database.Tables |  where {$_.Name -eq "Employees"} 



foreach($col in $tbl.Columns)
{
    #$col.GetType()       
    Write-Host "Name: $($col.Name) DataType: $($col.DataType) ID: $($col.ID)"
        
}



#foreach($table in $database.Tables)
#{
#    Write-Host `r`n
#    Write-Host $table.Name
#    Write-Host `r`n
#
#    foreach($col in $table.Columns)
#    {
#        #$col.GetType()       
#        Write-Host "Name: $($col.Name) DataType: $($col.DataType) ID: $($col.ID)"
#        
#    }
#}

