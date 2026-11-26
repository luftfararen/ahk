#Requires AutoHotkey v2.0
#SingleInstance Force

log_file := A_ScriptDir . "\enum_windows_debug.txt"
try FileDelete(log_file)

Log(msg) {
    global log_file
    FileAppend(msg . "`n", log_file, "UTF-8")
}

Log("=== ENUM WINDOWS DEBUG ===")

EnumWindowsProc(hwnd, lParam) {
    proc := ""
    try proc := WinGetProcessName("ahk_id " . hwnd)
    title := ""
    try title := WinGetTitle("ahk_id " . hwnd)
    cls := ""
    try cls := WinGetClass("ahk_id " . hwnd)

    if proc ~= "i)(code|antigravity)" {
        Log(Format("HWND: {:x}, Exe: '{}', Class: '{}', Title: '{}'", hwnd, proc, cls, title))
    }
    return true
}

cb := CallbackCreate(EnumWindowsProc, "F", 2)
DllCall("EnumWindows", "Ptr", cb, "Ptr", 0)
CallbackFree(cb)

Log("=== DONE ===")
