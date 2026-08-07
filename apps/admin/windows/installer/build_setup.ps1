#Requires -Version 5.1
<#
.SYNOPSIS
  TaxiGo Admin Windows release + Inno Setup installer.
.EXAMPLE
  .\windows\installer\build_setup.ps1
  .\windows\installer\build_setup.ps1 -SkipFlutterBuild
  .\windows\installer\build_setup.ps1 -ApiBase "https://api.taxigo.app/api/v1"
#>
param(
  [string]$ApiBase = "http://127.0.0.1:8000/api/v1",
  [switch]$SkipFlutterBuild
)

$ErrorActionPreference = "Stop"
$adminRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $adminRoot

$pubspec = Get-Content (Join-Path $adminRoot "pubspec.yaml") -Raw
if ($pubspec -notmatch 'version:\s*([0-9]+\.[0-9]+\.[0-9]+)') {
  throw "pubspec.yaml version okunamadı."
}
$version = $Matches[1]
Write-Host "TaxiGo Admin $version"
Write-Host "API default: $ApiBase"

$iscc = @(
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $iscc) {
  throw "Inno Setup 6 bulunamadı (ISCC.exe). https://jrsoftware.org/isinfo.php"
}

if (-not $SkipFlutterBuild) {
  Write-Host ">> flutter pub get"
  flutter pub get
  if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed" }

  Write-Host ">> flutter build windows --release"
  flutter build windows --release `
    --dart-define="TAXIGO_ADMIN_API_BASE=$ApiBase"
  if ($LASTEXITCODE -ne 0) { throw "flutter build windows failed" }
}

$releaseDir = Join-Path $adminRoot "build\windows\x64\runner\Release"
$exe = Join-Path $releaseDir "taxigo_admin.exe"
if (-not (Test-Path $exe)) {
  throw "Release exe yok: $exe"
}

$distDir = Join-Path $adminRoot "dist\windows"
New-Item -ItemType Directory -Force -Path $distDir | Out-Null

$iss = Join-Path $PSScriptRoot "taxigo_admin.iss"
Write-Host ">> ISCC $iss"
& $iscc "/DMyAppVersion=$version" $iss
if ($LASTEXITCODE -ne 0) { throw "Inno Setup derlemesi başarısız" }

$setup = Get-ChildItem $distDir -Filter "TaxiGo-Admin-Setup-*.exe" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

Write-Host ""
Write-Host "Setup hazır:"
Write-Host "  $($setup.FullName)"
Write-Host "  Boyut: $([math]::Round($setup.Length / 1MB, 1)) MB"
