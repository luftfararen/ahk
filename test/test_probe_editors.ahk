#Requires AutoHotkey v2.0
#SingleInstance Force

; Probe what GetGUIThreadInfo, UIA, and CaretGetPos return for currently active window or VS Code / Antigravity
log_file := A_ScriptDir . "\diag_output.txt"
try FileDelete(log_file)

Log(msg) {
    global log_file
    FileAppend(msg . "`n", log_file, "UTF-8")
}

; Wait 2 seconds so user or script can inspect active window, or loop through windows
Log("=== WINDOW PROBE ===")

winList := WinGetList()
for hwnd in winList {
    title := WinGetTitle("ahk_id " . hwnd)
    proc := WinGetProcessName("ahk_id " . hwnd)
    if proc ~= "i)(code|antigravity|electron)" {
        Log(Format("HWND: {:x}, Proc: {}, Title: '{}'", hwnd, proc, title))
    }
}
