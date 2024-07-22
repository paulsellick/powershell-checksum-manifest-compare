$hashfile = "c:\temp\extract\sha256sums.txt"
$sourcepath = "c:\temp\extract\source"
Get-ChildItem -Path $sourcepath -Recurse -Exclude $hashfile | Get-FileHash | Out-File $hashfile
