$ahk = "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
$expLines = Get-Content "src\PlayGroundsExp.ahk"
$origLines = Get-Content "src\PlayGrounds.ahk"

Write-Output "Exp lines: $($expLines.Length), Orig lines: $($origLines.Length)"

# Let's test binary search between orig and exp
# First verify orig is 0 and exp is -1073741819
Set-Content -Path "src\test_play.ahk" -Value $origLines
$p0 = (Start-Process -FilePath $ahk -ArgumentList "/validate src\test_play.ahk" -PassThru -Wait).ExitCode
Write-Output "Orig validate: $p0"

Set-Content -Path "src\test_play.ahk" -Value $expLines
$p1 = (Start-Process -FilePath $ahk -ArgumentList "/validate src\test_play.ahk" -PassThru -Wait).ExitCode
Write-Output "Exp validate: $p1"
