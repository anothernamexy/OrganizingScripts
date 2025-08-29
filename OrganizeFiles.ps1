# Get the path of the directory where the script is located
$scriptDirectory = $PSScriptRoot

# Get all files in the directory with the naming scheme {str}{int}.{ext}
Get-ChildItem -Path $scriptDirectory -File | Where-Object {
    $_.Name -match '^(.*?)(\d+)\.(.*)$'
} | ForEach-Object {
    # Extract the string, integer, and extension from the filename
    $str = $matches[1]
    $int = $matches[2]
    $ext = $matches[3]

    # Create the subfolder if it doesn't exist
    $subfolderPath = Join-Path -Path $scriptDirectory -ChildPath $str
    if (-not (Test-Path -Path $subfolderPath)) {
        New-Item -ItemType Directory -Path $subfolderPath | Out-Null
    }

    # Move the file to the subfolder
    Move-Item -Path $_.FullName -Destination $subfolderPath
}

Write-Output "Files have been organized into subfolders."
