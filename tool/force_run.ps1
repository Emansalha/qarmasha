# Qarmasha - force run (Windows PowerShell)
# Usage:  double-click force_run.bat   OR   powershell -ExecutionPolicy Bypass -File tool\force_run.ps1 [-Device <id>]
param([string]$Device = "")
$ErrorActionPreference = "Continue"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
Write-Host "== Qarmasha force run ==" -ForegroundColor Yellow
Write-Host "Project: $root"

# 1) Gradle home on E: (avoids the locked download in C:\Users\...\.gradle)
if (Test-Path "E:\gradle-home") { $env:GRADLE_USER_HOME = "E:\gradle-home" }
Write-Host "GRADLE_USER_HOME = $env:GRADLE_USER_HOME"

# 2) Stop stuck Gradle / Java / adb processes
Write-Host "[1/6] Stopping stuck Gradle/Java/adb processes..." -ForegroundColor Cyan
if (Test-Path "android\gradlew.bat") { & "android\gradlew.bat" -p android --stop 2>$null | Out-Null }
Get-Process java, javaw, adb -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 3) Remove stale lock files
Write-Host "[2/6] Removing stale lock files..." -ForegroundColor Cyan
Remove-Item -Recurse -Force "android\.gradle\noVersion" -ErrorAction SilentlyContinue
# only the places Gradle actually locks (fast, no full scan of caches)
foreach ($h in @($env:GRADLE_USER_HOME, "$env:USERPROFILE\.gradle")) {
  if ($h -and (Test-Path $h)) {
    foreach ($sub in @("wrapper\dists", "caches", "daemon")) {
      $p = Join-Path $h $sub
      if (Test-Path $p) {
        Get-ChildItem $p -Recurse -Depth 3 -Include *.lck, *.lock -ErrorAction SilentlyContinue |
          Remove-Item -Force -ErrorAction SilentlyContinue
      }
    }
  }
}

# 4) Latest code + packages
Write-Host "[3/6] git pull..." -ForegroundColor Cyan
git pull
Write-Host "[4/6] flutter pub get..." -ForegroundColor Cyan
flutter pub get

# 5) Pick device (first real Android phone, otherwise first Android device/emulator)
Write-Host "[5/6] Looking for a device..." -ForegroundColor Cyan
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
if (Test-Path $adb) { & $adb start-server | Out-Null }
if (-not $Device) {
  $json = flutter devices --machine 2>$null | Out-String
  try {
    $list = $json | ConvertFrom-Json
    $android = @($list | Where-Object { $_.targetPlatform -like "android*" })
    $phone = $android | Where-Object { -not $_.emulator } | Select-Object -First 1
    if (-not $phone) { $phone = $android | Select-Object -First 1 }
    if ($phone) { $Device = $phone.id; Write-Host "Device: $($phone.name) ($Device)" -ForegroundColor Green }
  } catch {}
}
if (-not $Device) {
  Write-Host "No Android device found. Connect the phone with USB, enable USB debugging, press 'Allow' on the phone, then run again." -ForegroundColor Red
  exit 1
}

# 6) Run
Write-Host "[6/6] flutter run (first build can take 10-20 minutes, do not close this window)..." -ForegroundColor Cyan
flutter run -d $Device
