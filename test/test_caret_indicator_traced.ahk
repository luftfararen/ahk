FileAppend("LINE 1`n", A_ScriptDir . "/run_debug.log", "UTF-8")
#Requires AutoHotkey v2.0
FileAppend("LINE 2`n", A_ScriptDir . "/run_debug.log", "UTF-8")
#SingleInstance Force
FileAppend("LINE 3`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 4`n", A_ScriptDir . "/run_debug.log", "UTF-8")
#Include "test_framework.ahk"
FileAppend("LINE 5`n", A_ScriptDir . "/run_debug.log", "UTF-8")
#Include "..\src\PlayGroundsExp.ahk"
FileAppend("LINE 6`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 7`n", A_ScriptDir . "/run_debug.log", "UTF-8")
Test_Caret_Indicator() {
FileAppend("LINE 8`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    LogMsg("`n--- Test Group: Caret Indicator ---`n")
FileAppend("LINE 9`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 10`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Ensure GUI and globals are initialized
FileAppend("LINE 11`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    global color_japanese
FileAppend("LINE 12`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    global dot_size
FileAppend("LINE 13`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    global m_gui
FileAppend("LINE 14`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 15`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    if HasMethod(IMEIndicator, "Init") {
FileAppend("LINE 16`n", A_ScriptDir . "/run_debug.log", "UTF-8")
        IMEIndicator.Init()
FileAppend("LINE 17`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    } else if (!IsSet(m_gui) || !m_gui) && IsSet(InitGUI) {
FileAppend("LINE 18`n", A_ScriptDir . "/run_debug.log", "UTF-8")
        InitGUI()
FileAppend("LINE 19`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    }
FileAppend("LINE 20`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 21`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    target_gui := (IsSet(IMEIndicator) && IMEIndicator.caret_gui is Gui) ? IMEIndicator.caret_gui : m_gui
FileAppend("LINE 22`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 23`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Save original states to restore later
FileAppend("LINE 24`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    indicator_class := IsSet(IMEIndicator) ? IMEIndicator : TypeAnalyzer
FileAppend("LINE 25`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    orig_showing := indicator_class.is_showing_ime_indicator
FileAppend("LINE 26`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    orig_force_ime := ImeState.force_ime_on
FileAppend("LINE 27`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 28`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Create Test Window
FileAppend("LINE 29`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    tGui := Gui("+AlwaysOnTop")
FileAppend("LINE 30`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    editCtrl := tGui.Add("Edit", "w300 -Wrap", "Initial Test Text")
FileAppend("LINE 31`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    btnCtrl := tGui.Add("Button", "w100 h30", "Click")
FileAppend("LINE 32`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    tGui.Show("x200 y200")
FileAppend("LINE 33`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    editCtrl.Focus()
FileAppend("LINE 34`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Sleep(200)
FileAppend("LINE 35`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 36`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Test 1: Caret position retrieved on focused Edit
FileAppend("LINE 37`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    pos1 := GetCaretPosition(tGui.Hwnd)
FileAppend("LINE 38`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(pos1 != false, "GetCaretPosition returns object for focused Edit")
FileAppend("LINE 39`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    if pos1 {
FileAppend("LINE 40`n", A_ScriptDir . "/run_debug.log", "UTF-8")
        Assert(pos1.x >= 200 && pos1.y >= 200, Format("pos1 in valid window bounds: x={}, y={}", pos1.x, pos1.y))
FileAppend("LINE 41`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    }
FileAppend("LINE 42`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 43`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Test 2: Moving caret updates position
FileAppend("LINE 44`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    EM_SETSEL := 0x00B1
FileAppend("LINE 45`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    editCtrl.Value := "Some long line of text for testing caret position movement"
FileAppend("LINE 46`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    DllCall("SendMessage", "Ptr", editCtrl.Hwnd, "UInt", EM_SETSEL, "Ptr", 0, "Ptr", 0)
FileAppend("LINE 47`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Sleep(100)
FileAppend("LINE 48`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    posStart := GetCaretPosition(tGui.Hwnd)
FileAppend("LINE 49`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 50`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    textLen := StrLen(editCtrl.Value)
FileAppend("LINE 51`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    DllCall("SendMessage", "Ptr", editCtrl.Hwnd, "UInt", EM_SETSEL, "Ptr", textLen, "Ptr", textLen)
FileAppend("LINE 52`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Sleep(100)
FileAppend("LINE 53`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    posEnd := GetCaretPosition(tGui.Hwnd)
FileAppend("LINE 54`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 55`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(posStart != false && posEnd != false, "Caret positions retrieved at start and end")
FileAppend("LINE 56`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    if posStart && posEnd {
FileAppend("LINE 57`n", A_ScriptDir . "/run_debug.log", "UTF-8")
        Assert(posEnd.x > posStart.x, Format("posEnd.x ({}) > posStart.x ({}) after moving to end", posEnd.x, posStart.x))
FileAppend("LINE 58`n", A_ScriptDir . "/run_debug.log", "UTF-8")
        Assert(posEnd.y == posStart.y, Format("posEnd.y ({}) == posStart.y ({}) on single-line Edit", posEnd.y, posStart.y))
FileAppend("LINE 59`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    }
FileAppend("LINE 60`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 61`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Test 3: Focusing a button (no caret) returns false cleanly
FileAppend("LINE 62`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    btnCtrl.Focus()
FileAppend("LINE 63`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Sleep(100)
FileAppend("LINE 64`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    posBtn := GetCaretPosition(tGui.Hwnd)
FileAppend("LINE 65`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(posBtn == false, "GetCaretPosition returns false when button is focused")
FileAppend("LINE 66`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 67`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Test 4: Disabling indicator setting hides GUI
FileAppend("LINE 68`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    indicator_class.is_showing_ime_indicator := false
FileAppend("LINE 69`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    if HasMethod(IMEIndicator, "UpdateCaret") {
FileAppend("LINE 70`n", A_ScriptDir . "/run_debug.log", "UTF-8")
        IMEIndicator.UpdateCaret(1, tGui.Hwnd)
FileAppend("LINE 71`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    } else {
FileAppend("LINE 72`n", A_ScriptDir . "/run_debug.log", "UTF-8")
        UpdateImeIndicator(false, tGui.Hwnd)
FileAppend("LINE 73`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    }
FileAppend("LINE 74`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(!DllCall("IsWindowVisible", "Ptr", target_gui.Hwnd), "Indicator GUI is hidden when is_showing_ime_indicator is false")
FileAppend("LINE 75`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 76`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Test 5: Indicator setting enabled
FileAppend("LINE 77`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    indicator_class.is_showing_ime_indicator := true
FileAppend("LINE 78`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 79`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Test 6: Focusing button with indicator enabled hides GUI (no caret)
FileAppend("LINE 80`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    btnCtrl.Focus()
FileAppend("LINE 81`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Sleep(100)
FileAppend("LINE 82`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    if HasMethod(IMEIndicator, "UpdateCaret") {
FileAppend("LINE 83`n", A_ScriptDir . "/run_debug.log", "UTF-8")
        IMEIndicator.UpdateCaret(1, tGui.Hwnd)
FileAppend("LINE 84`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    } else {
FileAppend("LINE 85`n", A_ScriptDir . "/run_debug.log", "UTF-8")
        UpdateImeIndicator(false, tGui.Hwnd)
FileAppend("LINE 86`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    }
FileAppend("LINE 87`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(!DllCall("IsWindowVisible", "Ptr", target_gui.Hwnd), "Indicator GUI is hidden when caret is unavailable")
FileAppend("LINE 88`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 89`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Test 7: 4-stage mode cycling
FileAppend("LINE 90`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    indicator_class.ime_indicator_mode := 0
FileAppend("LINE 91`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(indicator_class.is_showing_ime_indicator == false, "Mode 0: is_showing_ime_indicator is false")
FileAppend("LINE 92`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    indicator_class.CycleImeIndicatorMode()
FileAppend("LINE 93`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(indicator_class.ime_indicator_mode == 1, "Mode cycled 0 -> 1 (Caret only)")
FileAppend("LINE 94`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(indicator_class.is_showing_ime_indicator == true, "Mode 1: is_showing_ime_indicator is true")
FileAppend("LINE 95`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    indicator_class.CycleImeIndicatorMode()
FileAppend("LINE 96`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(indicator_class.ime_indicator_mode == 2, "Mode cycled 1 -> 2 (Mouse only)")
FileAppend("LINE 97`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(indicator_class.is_showing_ime_indicator == true, "Mode 2: is_showing_ime_indicator is true")
FileAppend("LINE 98`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    indicator_class.CycleImeIndicatorMode()
FileAppend("LINE 99`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(indicator_class.ime_indicator_mode == 3, "Mode cycled 2 -> 3 (Both)")
FileAppend("LINE 100`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(indicator_class.is_showing_ime_indicator == true, "Mode 3: is_showing_ime_indicator is true")
FileAppend("LINE 101`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    indicator_class.CycleImeIndicatorMode()
FileAppend("LINE 102`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(indicator_class.ime_indicator_mode == 0, "Mode cycled 3 -> 0 (Hidden)")
FileAppend("LINE 103`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Assert(indicator_class.is_showing_ime_indicator == false, "Mode 0: is_showing_ime_indicator is false")
FileAppend("LINE 104`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 105`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Cleanup test window
FileAppend("LINE 106`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    tGui.Destroy()
FileAppend("LINE 107`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 108`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ; Restore original states
FileAppend("LINE 109`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    indicator_class.is_showing_ime_indicator := orig_showing
FileAppend("LINE 110`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    ImeState.force_ime_on := orig_force_ime
FileAppend("LINE 111`n", A_ScriptDir . "/run_debug.log", "UTF-8")
}
FileAppend("LINE 112`n", A_ScriptDir . "/run_debug.log", "UTF-8")

FileAppend("LINE 113`n", A_ScriptDir . "/run_debug.log", "UTF-8")
if (A_ScriptName == "test_caret_indicator.ahk") {
FileAppend("LINE 114`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    InitTestSuite("CARET INDICATOR UNIT TESTS")
FileAppend("LINE 115`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    Test_Caret_Indicator()
FileAppend("LINE 116`n", A_ScriptDir . "/run_debug.log", "UTF-8")
    FinishTestSuite()
FileAppend("LINE 117`n", A_ScriptDir . "/run_debug.log", "UTF-8")
}
