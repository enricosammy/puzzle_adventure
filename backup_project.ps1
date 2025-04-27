# Path to your project folder
$projectFolder = "C:\FlutterApps\puzzle_adventure - working_flavors_logo_background - Copy"

# Path where you want to save the backup
$backupFolder = "C:\FlutterApps\Backups"

# Name of the backup file (with timestamp)
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupFileName = "puzzle_adventure_full_backup_$timestamp.7z"

# Path to 7-Zip executable
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Create the backup folder if it doesn't exist
if (!(Test-Path -Path $backupFolder)) {
    New-Item -ItemType Directory -Path $backupFolder | Out-Null
}

# List of paths to include in the backup
$includePaths = @(
    "$projectFolder\lib\*",               # All files in lib folder
    "$projectFolder\main.dart",           # main.dart in the root
    "$projectFolder\styles.dart",         # styles.dart in the root
    "$projectFolder\android\**\*.gradle", # All .gradle files in android and subfolders
    "$projectFolder\android\**\*.kts",    # All .gradle.kts files in android and subfolders
    "$projectFolder\gradle.properties",   # gradle.properties
    "$projectFolder\pubspec.yaml",        # pubspec.yaml for dependencies
    "$projectFolder\pubspec.lock",        # pubspec.lock for locked dependencies
    "$projectFolder\.env",                # .env file for configuration
    "$projectFolder\README.md",           # README.md for documentation
    "$projectFolder\build.gradle",        # root build.gradle
    "$projectFolder\temp_run_cartoons.ps1" # Include temp scripts
)

# Run 7-Zip to compress the specified paths
& "$sevenZipPath" a -t7z "$backupFolder\$backupFileName" $includePaths

# Verify if the backup file was created successfully
if (Test-Path -Path "$backupFolder\$backupFileName") {
    Write-Host "Full backup completed successfully! File saved at $backupFolder\$backupFileName"
} else {
    Write-Host "Backup failed. Please check the script and try again."
}
