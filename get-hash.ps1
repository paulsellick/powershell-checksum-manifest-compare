$hashfile = "sha56sums.txt"
Get-ChildItem -Path . -Recurse -Exclude $hashfile | Get-FileHash | Out-File $hashfile


