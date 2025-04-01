# Path to your project folder
$projectFolder = "C:\FlutterApps\puzzle_adventure"
# Path where you want to save the backup
$backupFolder = "C:\FlutterApps\Backups"
# Name of the backup file (with timestamp)
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupFileName = "puzzle_adventure_backup_$timestamp.7z"

# Path to 7-Zip executable (if not in PATH, specify the full path to 7z.exe)
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Create the backup folder if it doesn't exist
if (!(Test-Path -Path $backupFolder)) {
    New-Item -ItemType Directory -Path $backupFolder | Out-Null
}

# Run 7-Zip to compress the project folder
& "$sevenZipPath" a -t7z "$backupFolder\$backupFileName" "$projectFolder\*"

# Check if the backup was successful
if (Test-Path -Path "$backupFolder\$backupFileName") {
    Write-Host "Backup completed successfully! File saved at $backupFolder\$backupFileName"
} else {
    Write-Host "Backup failed. Please check the script and try again."
}
