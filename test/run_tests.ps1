# PowerShell Test Runner for Playgrounds
# Usage:
#   powershell -ExecutionPolicy Bypass -File test/run_tests.ps1
#   powershell -ExecutionPolicy Bypass -File test/run_tests.ps1 -TestScript test_hold_mode.ahk

param (
    [string]$TestScript = "test_runner.ahk"
)

$ErrorActionPreference = "Stop"

$AhkCandidates = @(
    "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe",
    "C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe",
    (Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source),
    (Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
)

$AhkPath = $null
foreach ($path in $AhkCandidates) {
    if ($path -and (Test-Path $path)) {
        $AhkPath = $path
        break
    }
}

if (-not $AhkPath) {
    Write-Error "AutoHotkey v2 executable not found. Please install AutoHotkey v2."
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetScriptPath = Join-Path $ScriptDir $TestScript

if (-not (Test-Path $TargetScriptPath)) {
    Write-Error "Test script not found: $TargetScriptPath"
    exit 1
}

$LogPath = Join-Path $ScriptDir "test_result.log"
if (Test-Path $LogPath) {
    Remove-Item $LogPath -Force
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Running Playgrounds Regression Tests" -ForegroundColor Cyan
Write-Host " Script: $TestScript" -ForegroundColor Cyan
Write-Host " AHK:    $AhkPath" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Run test process and wait for completion
$process = Start-Process -FilePath $AhkPath -ArgumentList "`"$TargetScriptPath`"" -WorkingDirectory $ScriptDir -PassThru -Wait -NoNewWindow
$exitCode = $process.ExitCode

if (Test-Path $LogPath) {
    Get-Content $LogPath -Encoding UTF8 | Write-Host
} else {
    Write-Warning "Log file not generated."
}

if ($exitCode -eq 0) {
    Write-Host "`n>>> [SUCCESS] All regression tests passed! (ExitCode: 0)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n>>> [FAILURE] Regression tests failed with exit code: $exitCode" -ForegroundColor Red
    exit $exitCode
}
