#adapted from https://blog.netnerds.net/2015/01/powershell-high-performance-techniques-for-importing-csv-to-sql-server/

$sqlserver = "sqlserver"
$database = "database"
$table = "table"
 
$csvfile = "C:\tmp\afile.csv"

$csvdelimiter = ","
$firstRowColumnNames = $true
$fieldsEnclosedInQuotes = $true


$batchsize = 5000
 
Write-Host "CSV Parser Started"
$elapsed = [System.Diagnostics.Stopwatch]::StartNew() 
[void][Reflection.Assembly]::LoadWithPartialName("System.Data")
[void][Reflection.Assembly]::LoadWithPartialName("System.Data.SqlClient")


[void][Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
  

$connectionstring = "Data Source=$sqlserver;Integrated Security=true;Initial Catalog=$database;"
$bulkcopy = New-Object Data.SqlClient.SqlBulkCopy($connectionstring, [System.Data.SqlClient.SqlBulkCopyOptions]::TableLock)
$bulkcopy.DestinationTableName = $table
$bulkcopy.bulkcopyTimeout = 0
$bulkcopy.batchsize = $batchsize
 

$datatable = New-Object System.Data.DataTable 




# Open text parser for the column names
$columnparser = New-Object Microsoft.VisualBasic.FileIO.TextFieldParser($csvfile)
$columnparser.TextFieldType = "Delimited"
$columnparser.HasFieldsEnclosedInQuotes = $fieldsEnclosedInQuotes
$columnparser.SetDelimiters($csvdelimiter)
 
#add two columns, one for Id, another for BatchId
[void]$datatable.Columns.Add()
[void]$datatable.Columns.Add()

foreach ($column in $columnparser.ReadFields()) {
    [void]$datatable.Columns.Add()
} 

$columnparser.Close(); $columnparser.Dispose()

 
# Open text parser again from start (there's no reset)
$parser = New-Object Microsoft.VisualBasic.FileIO.TextFieldParser($csvfile)
$parser.TextFieldType = "Delimited"
$parser.HasFieldsEnclosedInQuotes = $fieldsEnclosedInQuotes
$parser.SetDelimiters($csvdelimiter)

if ($firstRowColumnNames -eq $true) {$null = $parser.ReadFields()}
 
Write-Warning "Parsing CSV"
  $i = 0
while (!$parser.EndOfData) 
{
     try 
     { 
        $ary= New-Object System.Collections.ArrayList
        [void]$ary.Add($null);[void]$ary.Add(111); foreach($it in $parser.ReadFields()) {[void]$ary.Add($it)}
        $null = $datatable.Rows.Add($ary.ToArray()) 
     }
     catch 
     {
        Write-Warning $_.Exception.Message
        Write-Warning "Row $i could not be parsed. Skipped." 
     }
 
     $i++; if (($i % $batchsize) -eq 0) 
     { 
        $bulkcopy.WriteToServer($datatable) 
        Write-Host "$i rows have been inserted in $($elapsed.Elapsed.ToString())."
        $datatable.Clear() 
     }
} 
 
# Add in all the remaining rows since the last clear
if($datatable.Rows.Count -gt 0) 
{
    $bulkcopy.WriteToServer($datatable)
    $datatable.Clear()
}
 
Write-Host "Script complete. $i rows have been inserted into the database."
Write-Host "Total Elapsed Time: $($elapsed.Elapsed.ToString())"
 
# Clean Up
$parser.Dispose(); $bulkcopy.Dispose(); $datatable.Dispose(); 
 
$totaltime = [math]::Round($elapsed.Elapsed.TotalSeconds,2)
Write-Host "Total Elapsed Time: $totaltime seconds. $i rows added." -ForegroundColor Green
# Sometimes the Garbage Collector takes too long to clear the huge datatable.
[System.GC]::Collect()

