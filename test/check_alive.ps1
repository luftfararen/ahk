param([string]$target, [string]$workdir = "")
if ($workdir -ne "") {
    $proc = Start-Process -FilePath "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" -ArgumentList $target -WorkingDirectory $workdir -PassThru
} else {
    $proc = Start-Process -FilePath "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" -ArgumentList $target -PassThru
}
Start-Sleep -Seconds 3
$alive = (Get-Process -Id $proc.Id -ErrorAction SilentlyContinue) -ne $null
if ($alive) {
    Stop-Process -Id $proc.Id -Force
    Write-Output "ALIVE: TRUE"
} else {
    Write-Output "ALIVE: FALSE (CRASHED, ExitCode: $($proc.ExitCode))"
}
