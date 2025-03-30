# Set error action preference to continue
$ErrorActionPreference = "Continue"

# Define flavors to test
$flavors = @("cartoons", "pets", "women")

foreach ($flavor in $flavors) {
    Write-Host "`nTesting $flavor flavor..." -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    
    # Stop Flutter and Gradle processes only
    Write-Host "Stopping development processes..." -ForegroundColor Yellow
    Get-Process | Where-Object { 
        $_.ProcessName -like "*dart*" -or 
        $_.ProcessName -like "*flutter*" -or
        $_.ProcessName -like "*gradle*"
    } | Where-Object {
        # Exclude adb process
        $_.ProcessName -notlike "*adb*"
    } | ForEach-Object {
        try {
            $_ | Stop-Process -Force
            Write-Host "Stopped process: $($_.ProcessName)" -ForegroundColor Green
        } catch {
            Write-Host "Failed to stop process: $($_.ProcessName)" -ForegroundColor Red
        }
    }
    
    # Wait for processes to stop
    Start-Sleep -Seconds 2
    
    # Clean build directory
    Write-Host "Cleaning build directory..." -ForegroundColor Yellow
    $directories = @(
        "build",
        ".dart_tool",
        "android\.gradle",
        "android\app\build"
    )

    foreach ($dir in $directories) {
        if (Test-Path $dir) {
            try {
                Remove-Item -Path $dir -Recurse -Force -ErrorAction Stop
                Write-Host "Removed $dir" -ForegroundColor Green
            } catch {
                $errorMessage = $_.Exception.Message
                Write-Host "Failed to remove '$dir': $errorMessage" -ForegroundColor Red
            }
        }
    }
    
    # Verify ADB connection is still active
    Write-Host "Verifying device connection..." -ForegroundColor Yellow
    $adbDevices = & adb devices
    if ($adbDevices -notmatch "device$") {
        Write-Host "Device connection lost! Please reconnect and press Enter to continue..." -ForegroundColor Red
        $null = Read-Host
    }
    
    # Build and install
    Write-Host "Building $flavor debug APK..." -ForegroundColor Yellow
    flutter pub get
    flutter build apk --flavor $flavor --debug
    
    # Check if build was successful and install
    $debugApk = "build\app\outputs\flutter-apk\app-$flavor-debug.apk"
    if (Test-Path $debugApk) {
        Write-Host "Installing $flavor debug APK..." -ForegroundColor Green
        & adb install -r $debugApk
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`nApp installed successfully!" -ForegroundColor Green
        } else {
            Write-Host "`nInstallation failed!" -ForegroundColor Red
        }
        
        Write-Host "Press Enter to continue to next flavor..." -ForegroundColor Yellow
        $null = Read-Host
    } else {
        Write-Host "Failed to build $flavor APK at path: $debugApk" -ForegroundColor Red
    }
}

Write-Host "`nAll flavors tested!" -ForegroundColor Green