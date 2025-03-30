param(
    [Parameter(Mandatory=$false)]
    [string]$BackupName = (Get-Date -Format "yyyyMMdd_HHmmss")
)

# Get parent directory of puzzle_adventure
$projectRoot = Split-Path -Parent $PSScriptRoot
$backupRoot = Join-Path $projectRoot "config_backups"
$backupDir = Join-Path $backupRoot $BackupName

# Create backup directory structure
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

Write-Host "Creating backup in: $backupDir" -ForegroundColor Cyan

# Files to backup
$filesToBackup = @(
    "lib\main.dart",
    "lib\config\flavor_config.dart",
    "lib\utils\copy_assets.dart",
    "lib\widgets\puzzle_widget_state.dart",
    "android\app\build.gradle",
    ".vscode\launch.json",
    "pubspec.yaml"
)

foreach ($file in $filesToBackup) {
    $sourcePath = Join-Path $PSScriptRoot $file
    $targetPath = Join-Path $backupDir $file
    $targetDir = Split-Path $targetPath -Parent
    
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    
    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath $targetPath -Force
        Write-Host "√ Backed up: $file" -ForegroundColor Green
    } else {
        Write-Host "× Missing file: $file" -ForegroundColor Red
    }
}

Write-Host "`nBackup structure:" -ForegroundColor Yellow
Get-ChildItem $backupDir -Recurse -Directory | 
    Select-Object FullName | 
    ForEach-Object { Write-Host "  $($_.FullName.Replace($backupDir, ''))" }

Write-Host "`nBackup completed!" -ForegroundColor Cyan