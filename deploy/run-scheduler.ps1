# Windows Task Scheduler — run every minute
# Register:
#   schtasks /Create /TN "TaxiGoScheduler" /SC MINUTE /MO 1 /TR "powershell -ExecutionPolicy Bypass -File C:\Users\excalibur\Desktop\TaxiGo\deploy\run-scheduler.ps1"

$ErrorActionPreference = "Stop"
$backend = Join-Path $PSScriptRoot "..\backend"
Set-Location $backend
php artisan schedule:run
