# Syncs Google Sign-In URL scheme into Info.plist from GoogleService-Info.plist.
# Run AFTER enabling Google Sign-In in Firebase Console and re-downloading
# GoogleService-Info.plist (must contain CLIENT_ID + REVERSED_CLIENT_ID).

param(
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$plistPath = Join-Path $Root "ios\Runner\GoogleService-Info.plist"
$infoPath = Join-Path $Root "ios\Runner\Info.plist"

if (-not (Test-Path $plistPath)) {
  Write-Error "Missing $plistPath"
  exit 1
}

$content = Get-Content $plistPath -Raw
function Get-PlistValue([string]$key, [string]$xml) {
  if ($xml -match "(?s)<key>$key</key>\s*<string>([^<]+)</string>") {
    return $Matches[1]
  }
  return $null
}

$clientId = Get-PlistValue "CLIENT_ID" $content
$reversed = Get-PlistValue "REVERSED_CLIENT_ID" $content
$bundleId = Get-PlistValue "BUNDLE_ID" $content

if (-not $clientId -or -not $reversed) {
  Write-Host @"
GoogleService-Info.plist henuz CLIENT_ID / REVERSED_CLIENT_ID icermiyor.

1) Firebase Console → Authentication → Sign-in method → Google (Enable)
2) Project settings → iOS app (com.taxigo.app) → Download GoogleService-Info.plist
3) Dosyayi ios/Runner/GoogleService-Info.plist olarak degistir
4) Bu scripti tekrar calistir

"@
  exit 2
}

$info = Get-Content $infoPath -Raw
# Ensure GIDClientID
if ($info -notmatch "<key>GIDClientID</key>") {
  $info = $info -replace "(?s)(</dict>\s*</plist>\s*)$", @"
	<key>GIDClientID</key>
	<string>$clientId</string>
`$1
"@
} else {
  $info = [regex]::Replace($info, "(?s)(<key>GIDClientID</key>\s*<string>)[^<]*(</string>)", "`${1}$clientId`${2}")
}

# Ensure URL scheme includes REVERSED_CLIENT_ID
if ($info -notmatch [regex]::Escape($reversed)) {
  $info = $info -replace "(?s)(<key>CFBundleURLSchemes</key>\s*<array>\s*)", "`${1}`n`t`t`t`t<string>$reversed</string>`n`t`t`t`t"
}

Set-Content -Path $infoPath -Value $info -Encoding UTF8
Write-Host "OK: Info.plist updated"
Write-Host "  BUNDLE_ID=$bundleId"
Write-Host "  GIDClientID set"
Write-Host "  URL scheme=$reversed"
