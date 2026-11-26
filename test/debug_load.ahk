#Requires AutoHotkey v2.0
FileAppend("1: Start`n", "test\debug.log")
#Include "test_framework.ahk"
FileAppend("2: Included test_framework`n", "test\debug.log")
#Include "..\src\PlayGroundsExp.ahk"
FileAppend("3: Included PlayGroundsExp`n", "test\debug.log")
ExitApp(0)
