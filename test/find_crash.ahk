#Requires AutoHotkey v2.0
f := FileOpen("crash_line.txt", "w")
f.WriteLine("1: Framework")
f.Read(0)
#Include "test_framework.ahk"
f.WriteLine("2: Before PlayGroundsExp")
f.Read(0)
#Include "..\src\PlayGroundsExp.ahk"
f.WriteLine("3: After PlayGroundsExp")
f.Read(0)
ExitApp(0)
