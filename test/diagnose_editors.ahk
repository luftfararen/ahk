#Requires AutoHotkey v2.0
#SingleInstance Force

log_file := A_ScriptDir . "\diag_editors.txt"
try FileDelete(log_file)

Log(msg) {
    global log_file
    FileAppend(msg . "`n", log_file, "UTF-8")
}

Log("=== DIAGNOSE EDITORS ===")

code_pids := ProcessExist("Code.exe")
antigravity_pids := ProcessExist("Antigravity IDE.exe")

Log(Format("Code.exe PID: {}, Antigravity IDE PID: {}", code_pids, antigravity_pids))

CLSID_CUIAutomation := Buffer(16)
DllCall("ole32\CLSIDFromString", "Str", "{ff48dba4-60ef-4201-aa87-54103eef594e}", "Ptr", CLSID_CUIAutomation)
IID_IUIAutomation := Buffer(16)
DllCall("ole32\CLSIDFromString", "Str", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}", "Ptr", IID_IUIAutomation)
IID_IUIAutomationTextPattern2 := Buffer(16)
DllCall("ole32\CLSIDFromString", "Str", "{506A921A-FCC9-409F-B23B-37EB74106872}", "Ptr", IID_IUIAutomationTextPattern2)
IID_IUIAutomationTextPattern := Buffer(16)
DllCall("ole32\CLSIDFromString", "Str", "{32EBA289-3583-42C9-9C59-3B6D9A1E9B6A}", "Ptr", IID_IUIAutomationTextPattern)

pUIA := 0
DllCall("ole32\CoCreateInstance", "Ptr", CLSID_CUIAutomation, "Ptr", 0, "UInt", 1, "Ptr", IID_IUIAutomation, "Ptr*", &pUIA, "Int")

CheckApp(appName, exeName) {
    global pUIA, IID_IUIAutomationTextPattern2, IID_IUIAutomationTextPattern
    Log(Format("--- Checking {} ({}) ---", appName, exeName))
    hwndList := WinGetList("ahk_exe " . exeName)
    Log(Format("Found {} windows", hwndList.Length))

    for h in hwndList {
        title := WinGetTitle("ahk_id " . h)
        if !title
            continue
        Log(Format("Window HWND {:x}: '{}'", h, title))

        ; 1. GetGUIThreadInfo
        tid := DllCall("GetWindowThreadProcessId", "Ptr", h, "Ptr", 0, "UInt")
        guiSize := (A_PtrSize = 8) ? 72 : 48
        guiInfo := Buffer(guiSize, 0)
        NumPut("UInt", guiSize, guiInfo, 0)

        ok := DllCall("GetGUIThreadInfo", "UInt", tid, "Ptr", guiInfo.Ptr, "Int")
        hwndCaret := NumGet(guiInfo, 8 + 5 * A_PtrSize, "Ptr")
        rectOffset := 8 + 6 * A_PtrSize
        l := NumGet(guiInfo, rectOffset, "Int")
        t := NumGet(guiInfo, rectOffset + 4, "Int")
        r := NumGet(guiInfo, rectOffset + 8, "Int")
        b := NumGet(guiInfo, rectOffset + 12, "Int")
        Log(Format("  GetGUIThreadInfo: ok={}, tid={}, hwndCaret={:x}, rect=[{},{},{},{}]", ok, tid, hwndCaret, l, t, r, b))
        if hwndCaret {
            pt := Buffer(8, 0)
            NumPut("Int", r, pt, 0)
            NumPut("Int", b, pt, 4)
            c2s := DllCall("ClientToScreen", "Ptr", hwndCaret, "Ptr", pt.Ptr, "Int")
            Log(Format("  ClientToScreen: c2s={}, pt=[{},{}]", c2s, NumGet(pt, 0, "Int"), NumGet(pt, 4, "Int")))
        }

        ; 2. UIA from ElementFromHandle
        if pUIA {
            pElem := 0
            ; 6: ElementFromHandle
            hrElem := ComCall(6, pUIA, "Ptr", h, "Ptr*", &pElem)
            Log(Format("  UIA ElementFromHandle: hr={:x}, pElem={}", hrElem, pElem))
            if pElem {
                ObjRelease(pElem)
            }
        }
    }
}

CheckApp("VS Code", "Code.exe")
CheckApp("Antigravity IDE", "Antigravity IDE.exe")

; Also check GetFocusedElement currently
if pUIA {
    pFocused := 0
    hrFocus := ComCall(8, pUIA, "Ptr*", &pFocused)
    Log(Format("Current Focused Element: hr={:x}, ptr={}", hrFocus, pFocused))
    if pFocused {
        ; Check element name and class
        name := 0
        ; 23: get_CurrentName
        ComCall(23, pFocused, "Ptr*", &name)
        if name {
            Log(Format("  Focused Name: '{}'", StrGet(name)))
            DllCall("oleaut32\SysFreeString", "Ptr", name)
        }
        className := 0
        ; 24: get_CurrentClassName
        ComCall(24, pFocused, "Ptr*", &className)
        if className {
            Log(Format("  Focused ClassName: '{}'", StrGet(className)))
            DllCall("oleaut32\SysFreeString", "Ptr", className)
        }

        ; Try TextPattern2
        pPat2 := 0
        hr2 := ComCall(14, pFocused, "Int", 10024, "Ptr", IID_IUIAutomationTextPattern2, "Ptr*", &pPat2)
        Log(Format("  Focused TextPattern2: hr={:x}, ptr={}", hr2, pPat2))
        if pPat2 {
            isActive := 0
            pRange := 0
            hrRange := ComCall(10, pPat2, "Int*", &isActive, "Ptr*", &pRange)
            Log(Format("    GetCaretRange: hr={:x}, active={}, pRange={}", hrRange, isActive, pRange))
            if pRange {
                psa := 0
                hrRect := ComCall(10, pRange, "Ptr*", &psa)
                Log(Format("    GetBoundingRectangles: hr={:x}, psa={}", hrRect, psa))
                if psa {
                    pData := 0
                    if DllCall("oleaut32\SafeArrayAccessData", "Ptr", psa, "Ptr*", &pData, "Int") == 0 {
                        cElements := NumGet(psa, 16 + (A_PtrSize - 8), "UInt")
                        Log(Format("    SafeArray cElements={}", cElements))
                        if cElements >= 4 {
                            rl := NumGet(pData, 0, "Double")
                            rt := NumGet(pData, 8, "Double")
                            rw := NumGet(pData, 16, "Double")
                            rh := NumGet(pData, 24, "Double")
                            Log(Format("    Rect: [{}, {}, {}, {}] -> bottom-right: [{}, {}]", rl, rt, rw, rh, Round(rl + rw), Round(rt + rh)))
                        }
                        DllCall("oleaut32\SafeArrayUnaccessData", "Ptr", psa, "Int")
                    }
                    DllCall("oleaut32\SafeArrayDestroy", "Ptr", psa, "Int")
                }
                ObjRelease(pRange)
            }
            ObjRelease(pPat2)
        }

        ; Try TextPattern
        pPat := 0
        hr1 := ComCall(14, pFocused, "Int", 10014, "Ptr", IID_IUIAutomationTextPattern, "Ptr*", &pPat)
        Log(Format("  Focused TextPattern: hr={:x}, ptr={}", hr1, pPat))
        if pPat {
            pRanges := 0
            hrSel := ComCall(5, pPat, "Ptr*", &pRanges)
            Log(Format("    GetSelection: hr={:x}, pRanges={}", hrSel, pRanges))
            if pRanges {
                len := 0
                ComCall(3, pRanges, "Int*", &len)
                Log(Format("    GetSelection len={}", len))
                if len > 0 {
                    pRange0 := 0
                    ComCall(4, pRanges, "Int", 0, "Ptr*", &pRange0)
                    if pRange0 {
                        psa := 0
                        hrRect := ComCall(10, pRange0, "Ptr*", &psa)
                        Log(Format("    Selection[0] GetBoundingRectangles: hr={:x}, psa={}", hrRect, psa))
                        if psa {
                            pData := 0
                            if DllCall("oleaut32\SafeArrayAccessData", "Ptr", psa, "Ptr*", &pData, "Int") == 0 {
                                cElements := NumGet(psa, 16 + (A_PtrSize - 8), "UInt")
                                Log(Format("    Selection SafeArray cElements={}", cElements))
                                if cElements >= 4 {
                                    rl := NumGet(pData, 0, "Double")
                                    rt := NumGet(pData, 8, "Double")
                                    rw := NumGet(pData, 16, "Double")
                                    rh := NumGet(pData, 24, "Double")
                                    Log(Format("    Selection Rect: [{}, {}, {}, {}]", rl, rt, rw, rh))
                                }
                                DllCall("oleaut32\SafeArrayUnaccessData", "Ptr", psa, "Int")
                            }
                            DllCall("oleaut32\SafeArrayDestroy", "Ptr", psa, "Int")
                        }
                        ObjRelease(pRange0)
                    }
                }
                ObjRelease(pRanges)
            }
            ObjRelease(pPat)
        }

        ObjRelease(pFocused)
    }
    ObjRelease(pUIA)
}
