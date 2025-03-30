Write-Host "Cleaning project..." -ForegroundColor Yellow
flutter clean
flutter pub get

Write-Host "Building and installing debug APKs..." -ForegroundColor Yellow
foreach ($flavor in @('cartoons', 'pets', 'women')) {
    Write-Host "Processing $flavor..." -ForegroundColor Cyan
    flutter build apk --flavor $flavor --debug
    if (Test-Path "build\app\outputs\flutter-apk\app-$flavor-debug.apk") {
        flutter install --flavor $flavor --debug
    }
}
