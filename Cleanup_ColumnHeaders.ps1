Clear-Host
$fpath = "F:\Shared\Ali\tmp\t1\NPPES_Data_Dissemination_May_2019\npidata_pfile_20050523-20190512_FileHeader.csv"#"F:\Shared\Ali\tmp\t1\NPPES_Data_Dissemination_May_2019\npidata_pfile_20050523-20190512.csv"
#Get-Content "C:\start.csv" | select -First 10 | Out-File "C:\stop.csv"
$outfile = "F:\Shared\Ali\tmp\t1\NPPES_Data_Dissemination_May_2019\zz_out.csv"
#Get-Content $fpath -TotalCount 10000 | Out-File $outfile
$cont = Get-Content $fpath

Write-Output $cont

$pat = '[^",_a-zA-Z0-9]'

$updated = $cont -replace ' ', '`_'
Write-Output `r`n
Write-Output `r`n
Write-Output "Output is"
$updated = $updated -replace $pat, ''
$updated = $updated -replace '"', '' #| Out-File "F:\Shared\Ali\tmp\t1\NPPES_Data_Dissemination_May_2019\zz_db.csv"

$aa = $updated -split ','
$bb = ""
foreach($it in $aa) {
    $bb += "$it VARCHAR(MAX),`r`n"
}

#Write-Output $updated

Set-Content "F:\Shared\Ali\tmp\t1\NPPES_Data_Dissemination_May_2019\zz_db.csv" $bb