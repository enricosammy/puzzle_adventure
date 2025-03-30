Write-Host "Installing debug APKs for all flavors..." -ForegroundColor Yellow

$flavors = @("cartoons", "pets", "women")

foreach ($flavor in $flavors) {
    Write-Host "`nProcessing $flavor flavor..." -ForegroundColor Cyan
    
    # Build debug APK
    Write-Host "Building debug APK for $flavor..." -ForegroundColor Blue
    flutter build apk --flavor $flavor --debug
    
    if ($LASTEXITCODE -eq 0) {
        # Verify debug APK exists
        $debugApk = "build\app\outputs\flutter-apk\app-$flavor-debug.apk"
        if (Test-Path $debugApk) {
            Write-Host "Installing $flavor debug APK..." -ForegroundColor Green
            flutter install --flavor $flavor --debug
        } else {
            Write-Host "Debug APK not found at: $debugApk" -ForegroundColor Red
        }
    } else {
        Write-Host "Failed to build $flavor" -ForegroundColor Red
    }
}

Write-Host "`nInstallation complete!" -ForegroundColor Green