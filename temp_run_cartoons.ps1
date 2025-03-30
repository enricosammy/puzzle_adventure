flutter run --flavor cartoons --debug 2>&1 | ForEach-Object {
    if ($_ -match '(FlavorConfig|Main)') {
        Write-Host $_ -ForegroundColor Yellow
    }
}
