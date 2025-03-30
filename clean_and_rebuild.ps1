Write-Host "Cleaning project..." -ForegroundColor Yellow
flutter clean
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Getting packages..." -ForegroundColor Yellow
flutter pub get

$flavors = @("cartoons", "pets", "women")
foreach ($flavor in $flavors) {
    Write-Host "`nBuilding and installing $flavor..." -ForegroundColor Cyan
    
    # Build debug APK
    flutter build apk --flavor $flavor --debug
    
    if ($LASTEXITCODE -eq 0) {
        $debugApk = "build\app\outputs\flutter-apk\app-$flavor-debug.apk"
        if (Test-Path $debugApk) {
            Write-Host "Installing debug APK for $flavor..." -ForegroundColor Green
            flutter install --debug --flavor $flavor
        } else {
            Write-Host "Debug APK not found at: $debugApk" -ForegroundColor Red
        }
    } else {
        Write-Host "Failed to build $flavor" -ForegroundColor Red
    }
}