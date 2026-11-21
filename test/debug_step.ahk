#Requires AutoHotkey v2.0
#SingleInstance Force

trace_file := A_ScriptDir . "\trace.txt"
try FileDelete(trace_file)

FileAppend("Starting test`n", trace_file)

; Step by step
#Include "..\src\Utils.ahk"
FileAppend("Included Utils.ahk`n", trace_file)

#Include "..\src\Preset.ahk"
FileAppend("Included Preset.ahk`n", trace_file)
