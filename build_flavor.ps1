param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('cartoons', 'pets', 'women')]
    [string]$Flavor
)

Write-Host "Building $Flavor flavor..." -ForegroundColor Cyan

# Clean and get packages
flutter clean
flutter pub get

# Build debug APK
flutter build apk --flavor $Flavor --debug

# Check if build was successful
$debugApk = "build\app\outputs\flutter-apk\app-$Flavor-debug.apk"
if (Test-Path $debugApk) {
    Write-Host "Installing $Flavor debug APK..." -ForegroundColor Green
    & adb install -r $debugApk
} else {
    Write-Host "Build failed: APK not found at $debugApk" -ForegroundColor Red
}