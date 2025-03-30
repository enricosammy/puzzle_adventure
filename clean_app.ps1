param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('cartoons', 'pets', 'women')]
    [string]$Flavor = 'cartoons'
)

Write-Host "Cleaning app for $Flavor flavor..." -ForegroundColor Cyan

# Stop running processes
Get-Process | Where-Object { 
    $_.ProcessName -like "*dart*" -or 
    $_.ProcessName -like "*flutter*" -or
    $_.ProcessName -like "*java*" -or 
    $_.ProcessName -like "*gradle*"
} | Stop-Process -Force -ErrorAction SilentlyContinue

# Wait for processes to stop
Start-Sleep -Seconds 2

# Clean directories
Write-Host "Removing generated directories..." -ForegroundColor Yellow
$dirsToRemove = @(
    "build",
    ".dart_tool",
    ".flutter-plugins",
    ".flutter-plugins-dependencies",
    "android\.gradle",
    "android\app\build",
    "android\build"
)

foreach ($dir in $dirsToRemove) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force
        Write-Host "Removed: $dir" -ForegroundColor Green
    }
}

# Reinitialize Gradle wrapper
Write-Host "Reinitializing Gradle wrapper..." -ForegroundColor Yellow
Push-Location android
Remove-Item -Path "gradle" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "gradlew" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "gradlew.bat" -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".gradle" -Recurse -Force -ErrorAction SilentlyContinue

# Download and extract Gradle wrapper
$gradleVersion = "8.3"
$wrapperUrl = "https://services.gradle.org/distributions/gradle-$gradleVersion-bin.zip"
$wrapperZip = "gradle-wrapper.zip"

Invoke-WebRequest -Uri $wrapperUrl -OutFile $wrapperZip
Expand-Archive -Path $wrapperZip -DestinationPath "gradle/wrapper" -Force
Remove-Item -Path $wrapperZip -Force

# Create wrapper properties
$wrapperProps = @"
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-$gradleVersion-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
"@

New-Item -Path "gradle/wrapper" -Name "gradle-wrapper.properties" -ItemType "file" -Value $wrapperProps -Force
Pop-Location

# Clean Flutter project
Write-Host "Running flutter clean..." -ForegroundColor Yellow
flutter clean

# Get packages
Write-Host "Getting packages..." -ForegroundColor Yellow
flutter pub get

# Initialize Gradle
Write-Host "Initializing Gradle..." -ForegroundColor Yellow
Push-Location android
./gradlew
Pop-Location

# Verify setup
Write-Host "Verifying Flutter setup..." -ForegroundColor Yellow
flutter doctor -v

# Build and run
Write-Host "Building and running $Flavor flavor..." -ForegroundColor Cyan
flutter run --flavor $Flavor