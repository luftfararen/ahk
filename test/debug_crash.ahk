#Requires AutoHotkey v2.0
#SingleInstance Force

log_file := A_ScriptDir . "\debug.log"
try FileDelete(log_file)

FileAppend("Step 1: Before Include`n", log_file)
#Include "..\src\PlayGroundsExp.ahk"
FileAppend("Step 2: After Include`n", log_file)
