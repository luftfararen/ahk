#Requires AutoHotkey v2.0
#SingleInstance Force

DetectHiddenWindows(true)
log_file := A_ScriptDir . "\diag_windows.txt"
try FileDelete(log_file)
FileAppend("=== START ENUM ===`n", log_file, "UTF-8")

list := WinGetList(,,,)
FileAppend("Count: " . list.Length . "`n", log_file, "UTF-8")
for h in list {
    try {
        title := WinGetTitle(h)
        proc := WinGetProcessName(h)
        cls := WinGetClass(h)
        if proc ~= "i)(code|antigravity)" {
            FileAppend(Format("HWND: {:x}, Class: '{}', Exe: '{}', Title: '{}'`n", h, cls, proc, title), log_file, "UTF-8")
        }
    }
}
FileAppend("=== END ENUM ===`n", log_file, "UTF-8")
