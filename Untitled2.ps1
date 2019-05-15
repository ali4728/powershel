Clear-Host
#hash
$hash = @{}
$hash.Add("name","erkan")

$hash.Add("job","developer")
$hash.Add("Age",45)

# update value at certain key
#$hash["name"] = "Pelin"

Write-Output ""
Write-Output ""

#get value for certain keys
#$hash["name"]
#$hash.GetType()

#$hash.Count
Write-Output ""
Write-Output "Hash Values are filtered"
$hash.Values | where {$_ -match "e"}
Write-Output ""
Write-Output ""
$hash.Keys

$ary = @(1,2,3,4,5,6,7,8,9) 
$bb = $ary.GetEnumerator() | where {$_ -gt 5}
Write-Output "will print bb"
$bb
$bb.GetType()


