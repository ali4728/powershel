#adapted from https://blog.netnerds.net/2015/01/powershell-high-performance-techniques-for-importing-csv-to-sql-server/

$sqlserver = "DESKTOP10\SQL14"
$database = "web"
$table = "table5"
 
$csvfile = "F:\Shared\Ali\dev\ps_scripts\tmp\zz_out.csv"

$csvdelimiter = ","
$firstRowColumnNames = $true
$fieldsEnclosedInQuotes = $true

$batchid = 112
$batchsize = 1000
 
Write-Host "CSV Parser Started"
$elapsed = [System.Diagnostics.Stopwatch]::StartNew() 
[void][Reflection.Assembly]::LoadWithPartialName("System.Data")
[void][Reflection.Assembly]::LoadWithPartialName("System.Data.SqlClient")


$connectionstring = "Data Source=$sqlserver;Integrated Security=true;Initial Catalog=$database;"
$bulkcopy = New-Object Data.SqlClient.SqlBulkCopy($connectionstring, [System.Data.SqlClient.SqlBulkCopyOptions]::TableLock)
$bulkcopy.DestinationTableName = $table
$bulkcopy.bulkcopyTimeout = 0
$bulkcopy.batchsize = $batchsize

$datatable = New-Object System.Data.DataTable 

function CustomSplit($line, $csvdelimiter)
{
	$csvSplit = "($csvdelimiter)"
	$csvsplit += '(?=(?:[^"]|"[^"]*")*$)'
	$regexOptions = [System.Text.RegularExpressions.RegexOptions]::ExplicitCapture

	$aa = $([regex]::Split($line.Trim(), $csvSplit, $regexOptions)) | Where-Object { $_ -ne "," } | Where-Object {$_ -ne ""}  
	
	$bb = New-Object System.Collections.ArrayList

	foreach($a in $aa) 
	{
		 [void]$bb.add($a.Replace("`"",""))
	} 
	
	return $bb.ToArray()
}

$reader = New-Object System.IO.StreamReader($csvfile)
$columns = (Get-Content $csvfile -First 1).Split($csvdelimiter)

if ($firstRowColumnNames -eq $true) { $null = $reader.readLine() } #eat up first column




#first to columns, Id, batchId
$null = $datatable.Columns.Add()
$null = $datatable.Columns.Add()
	 
foreach ($column in $columns) 
{ 
	$null = $datatable.Columns.Add()
}
 
 $i=0

while (($line = $reader.ReadLine()) -ne $null)  
{
	if($fieldsEnclosedInQuotes) 
	{
        $ary= New-Object System.Collections.ArrayList
        $tmpAry = CustomSplit $line $csvdelimiter
        [void]$ary.Add($null);[void]$ary.Add($batchid); foreach($it in $tmpAry) {[void]$ary.Add($it)}
		$null = $datatable.Rows.Add( $ary.ToArray())
	} 
	else 
	{
        $ary= New-Object System.Collections.ArrayList
        [void]$ary.Add($null);[void]$ary.Add($batchid); foreach($it in $line.Split($csvdelimiter)) {[void]$ary.Add($it)}
		$null = $datatable.Rows.Add($ary.ToArray())
	}

	 
	 $i++
	if (($i % $batchsize) -eq 0) 
	{ 
		$bulkcopy.WriteToServer($datatable) 
		Write-Host "$i rows have been inserted in $($elapsed.Elapsed.ToString())."
		$datatable.Clear() 
	} 
} 
 
# last records
if($datatable.Rows.Count -gt 0) {
	$bulkcopy.WriteToServer($datatable)
	$datatable.Clear()
}
 
# Clean Up
$reader.Close(); $reader.Dispose()
$bulkcopy.Close(); $bulkcopy.Dispose()
$datatable.Dispose()
 
Write-Host "Script complete. $i rows have been inserted into the database."
Write-Host "Total Elapsed Time: $($elapsed.Elapsed.ToString())"
# Sometimes the Garbage Collector takes too long to clear the huge datatable.
[System.GC]::Collect()

