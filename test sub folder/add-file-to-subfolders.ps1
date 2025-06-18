# Define the source file name
$SourceFileName = ".forcegallery"

# Use the directory where the script is executed as the target directory
$TargetDirectory = Get-Location

# Define the full path to the source file
$SourceFile = Join-Path -Path $TargetDirectory -ChildPath $SourceFileName

# Check if the source file exists; if not, create it
if (-Not (Test-Path $SourceFile)) {
    New-Item -Path $SourceFile -ItemType File -Force | Out-Null
    Write-Host "Created source file: $SourceFile" -ForegroundColor Yellow
}

# Get only the first-level subdirectories in the target directory
$Subfolders = Get-ChildItem -Path $TargetDirectory -Directory

# Loop through each first-level subfolder and copy the file
foreach ($Subfolder in $Subfolders) {
    $DestinationPath = Join-Path -Path $Subfolder.FullName -ChildPath $SourceFileName
    Copy-Item -Path $SourceFile -Destination $DestinationPath -Force
    Write-Host "Copied file to: $DestinationPath" -ForegroundColor Green
}

Write-Host "File added to first-level subfolders only!" -ForegroundColor Cyan

# Delete the top-level source file
Remove-Item -Path $SourceFile -Force
Write-Host "Deleted source file: $SourceFile" -ForegroundColor Red

# Delete the script itself
$ScriptPath = $MyInvocation.MyCommand.Path
Remove-Item -Path $ScriptPath -Force
Write-Host "Deleted script file: $ScriptPath" -ForegroundColor Red