$hashfile = "sha256sums.txt"
$sourcepath = "c:\temp\extract\source"
Get-ChildItem -Path $sourcepath -Recurse -Exclude $hashfile | Get-FileHash | Out-File (Join-Path -Path $sourcepath -ChildPath $hashfile)
