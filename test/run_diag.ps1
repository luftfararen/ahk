$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
$psi.Arguments = '/ErrorStdOut src\PlayGrounds.ahk'
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$p = [System.Diagnostics.Process]::Start($psi)
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()
$p.WaitForExit()
Write-Output "ExitCode: $($p.ExitCode)"
Write-Output "Stdout: $stdout"
Write-Output "Stderr: $stderr"
