# Stop Flutter and Dart processes
Write-Host "Stopping Flutter and Dart processes..." -ForegroundColor Yellow
Get-Process | Where-Object { 
    $_.ProcessName -like "*dart*" -or 
    $_.ProcessName -like "*flutter*" -or 
    $_.ProcessName -like "*java*"
} | ForEach-Object {
    try {
        $_ | Stop-Process -Force
        Write-Host "Stopped process: $($_.ProcessName)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to stop process: $($_.ProcessName)" -ForegroundColor Red
    }
}

# Wait for processes to fully stop
Start-Sleep -Seconds 2

# Clean Flutter build files
try {
    Write-Host "Cleaning build directories..." -ForegroundColor Yellow
    
    $directories = @(
        "build",
        ".dart_tool",
        "android\.gradle",
        "android\app\build",
        ".idea",
        ".gradle"
    )

    foreach ($dir in $directories) {
        $fullPath = Join-Path $PSScriptRoot $dir
        if (Test-Path $fullPath) {
            Write-Host "Removing $dir..." -ForegroundColor Cyan
            Remove-Item -Path $fullPath -Recurse -Force -ErrorAction Stop
        }
    }

    Write-Host "Running flutter clean..." -ForegroundColor Yellow
    flutter clean

    Write-Host "Getting packages..." -ForegroundColor Yellow
    flutter pub get

    Write-Host "Project cleaned successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error cleaning project: $_" -ForegroundColor Red
    exit 1
}