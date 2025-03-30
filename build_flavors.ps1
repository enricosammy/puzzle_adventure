# Clean the project
Write-Host "Cleaning project..." -ForegroundColor Green
flutter clean

# Get packages
Write-Host "Getting packages..." -ForegroundColor Green
flutter pub get

# Build all flavors
$flavors = @("cartoons", "pets", "women")

foreach ($flavor in $flavors) {
    Write-Host "Building $flavor flavor..." -ForegroundColor Green
    flutter build apk --flavor $flavor
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Installing $flavor flavor..." -ForegroundColor Green
        flutter install --flavor $flavor
    } else {
        Write-Host "Failed to build $flavor flavor" -ForegroundColor Red
    }
}