# Start the timer
$startTime = Get-Date

# Define file paths
$SourcePath = "C:\temp\extract\source"
$hashReportPath = "C:\temp\extract\sha256sums.txt"
$newPath = "C:\temp\extract\destination"

# Read the hash report and skip the first two lines
$hashReport = Get-Content -Path $hashReportPath | Select-Object -Skip 3

# Filter out empty or whitespace-only lines
$hashReport = $hashReport | Where-Object { $_.Trim() -ne "" }

# Initialize arrays for results
$hashArray = @()
$results = @()
$missingFiles = @()
$badFiles = @()
$okFiles = @()

# Parse the hash report
foreach ($line in $hashReport) {
    $columns = ($line -replace ' {2,}', ',').Split(',')
    $hashObject = [PSCustomObject]@{
        Algorithm = $columns[0].Trim()
        Hash = $columns[1].Trim()
        Path = $columns[2].Trim()
    }
    $hashArray += $hashObject
}

# Compute hashes of files in the new directory and compare
foreach ($hashEntry in $hashArray) {
    $relativePath = $hashEntry.Path -replace [regex]::Escape($SourcePath), ""
    $newFilePath = Join-Path -Path $newPath -ChildPath $relativePath

    if (Test-Path -Path $newFilePath) {
        $fileHash = Get-FileHash -Path $newFilePath -Algorithm $hashEntry.Algorithm
        if ($fileHash.Hash -eq $hashEntry.Hash) {
            $okFiles += "." + $relativePath
        } else {
            $badFiles += "." + $relativePath
        }
    } else {
        $missingFiles += "." + $relativePath
    }
}

# Create summary
$endTime = Get-Date
$timeSpent = $endTime - $startTime

$summary = @{
    "Total Time Spent" = $timeSpent
    "Total Files" = $hashArray.Count
    "OK Files" = $okFiles.Count
    "Missing Files" = $missingFiles.Count
    "Bad Files" = $badFiles.Count
}

# Output results
Write-Output "HASHFILE CHECK REPORT"
Write-Output "---------------------------"
Write-Output $startTime
Write-Output ""
Write-Output "OK Files:"
$okFiles | ForEach-Object { Write-Output $_ }
Write-Output ""
Write-Output "Missing Files:"
$missingFiles | ForEach-Object { Write-Output $_ }
Write-Output ""
Write-Output "Bad Files:"
$badFiles | ForEach-Object { Write-Output $_ }
Write-Output ""
Write-Output "Summary:"
Write-Output "----------------"
$summary.GetEnumerator() | Sort Name | ForEach-Object { Write-Output "$($_.Key): $($_.Value)" }
