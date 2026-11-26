#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "test_framework.ahk"
#Include "..\src\PlayGroundsExp.ahk"

Test_Caret_Indicator() {
    LogMsg("`n--- Test Group: Caret Indicator ---`n")

    ; Ensure GUI and globals are initialized
    global color_japanese
    global dot_size
    global m_gui

    if HasMethod(IMEIndicator, "Init") {
        IMEIndicator.Init()
    } else if (!IsSet(m_gui) || !m_gui) && IsSet(InitGUI) {
        InitGUI()
    }

    target_gui := (IsSet(IMEIndicator) && IMEIndicator.caret_gui is Gui) ? IMEIndicator.caret_gui : m_gui

    ; Save original states to restore later
    indicator_class := IsSet(IMEIndicator) ? IMEIndicator : TypeAnalyzer
    orig_showing := indicator_class.is_showing_ime_indicator
    orig_force_ime := ImeState.force_ime_on

    ; Create Test Window
    tGui := Gui("+AlwaysOnTop")
    editCtrl := tGui.Add("Edit", "w300 -Wrap", "Initial Test Text")
    btnCtrl := tGui.Add("Button", "w100 h30", "Click")
    tGui.Show("x200 y200")
    editCtrl.Focus()
    Sleep(200)

    ; Test 1: Caret position retrieved on focused Edit
    pos1 := GetCaretPosition(tGui.Hwnd)
    Assert(pos1 != false, "GetCaretPosition returns object for focused Edit")
    if pos1 {
        Assert(pos1.x >= 200 && pos1.y >= 200, Format("pos1 in valid window bounds: x={}, y={}", pos1.x, pos1.y))
    }

    ; Test 2: Moving caret updates position
    EM_SETSEL := 0x00B1
    editCtrl.Value := "Some long line of text for testing caret position movement"
    DllCall("SendMessage", "Ptr", editCtrl.Hwnd, "UInt", EM_SETSEL, "Ptr", 0, "Ptr", 0)
    Sleep(100)
    posStart := GetCaretPosition(tGui.Hwnd)

    textLen := StrLen(editCtrl.Value)
    DllCall("SendMessage", "Ptr", editCtrl.Hwnd, "UInt", EM_SETSEL, "Ptr", textLen, "Ptr", textLen)
    Sleep(100)
    posEnd := GetCaretPosition(tGui.Hwnd)

    Assert(posStart != false && posEnd != false, "Caret positions retrieved at start and end")
    if posStart && posEnd {
        Assert(posEnd.x > posStart.x, Format("posEnd.x ({}) > posStart.x ({}) after moving to end", posEnd.x, posStart.x))
        Assert(posEnd.y == posStart.y, Format("posEnd.y ({}) == posStart.y ({}) on single-line Edit", posEnd.y, posStart.y))
    }

    ; Test 3: Focusing a button (no caret) returns false cleanly
    btnCtrl.Focus()
    Sleep(100)
    posBtn := GetCaretPosition(tGui.Hwnd)
    Assert(posBtn == false, "GetCaretPosition returns false when button is focused")

    ; Test 4: Disabling indicator setting hides GUI
    indicator_class.is_showing_ime_indicator := false
    if HasMethod(IMEIndicator, "UpdateCaret") {
        IMEIndicator.UpdateCaret(1, tGui.Hwnd)
    } else {
        UpdateImeIndicator(false, tGui.Hwnd)
    }
    Assert(!DllCall("IsWindowVisible", "Ptr", target_gui.Hwnd), "Indicator GUI is hidden when is_showing_ime_indicator is false")

    ; Test 5: Indicator setting enabled
    indicator_class.is_showing_ime_indicator := true

    ; Test 6: Focusing button with indicator enabled hides GUI (no caret)
    btnCtrl.Focus()
    Sleep(100)
    if HasMethod(IMEIndicator, "UpdateCaret") {
        IMEIndicator.UpdateCaret(1, tGui.Hwnd)
    } else {
        UpdateImeIndicator(false, tGui.Hwnd)
    }
    Assert(!DllCall("IsWindowVisible", "Ptr", target_gui.Hwnd), "Indicator GUI is hidden when caret is unavailable")

    ; Test 7: 4-stage mode cycling
    indicator_class.ime_indicator_mode := 0
    Assert(indicator_class.is_showing_ime_indicator == false, "Mode 0: is_showing_ime_indicator is false")
    indicator_class.CycleImeIndicatorMode()
    Assert(indicator_class.ime_indicator_mode == 1, "Mode cycled 0 -> 1 (Caret only)")
    Assert(indicator_class.is_showing_ime_indicator == true, "Mode 1: is_showing_ime_indicator is true")
    indicator_class.CycleImeIndicatorMode()
    Assert(indicator_class.ime_indicator_mode == 2, "Mode cycled 1 -> 2 (Mouse only)")
    Assert(indicator_class.is_showing_ime_indicator == true, "Mode 2: is_showing_ime_indicator is true")
    indicator_class.CycleImeIndicatorMode()
    Assert(indicator_class.ime_indicator_mode == 3, "Mode cycled 2 -> 3 (Both)")
    Assert(indicator_class.is_showing_ime_indicator == true, "Mode 3: is_showing_ime_indicator is true")
    indicator_class.CycleImeIndicatorMode()
    Assert(indicator_class.ime_indicator_mode == 0, "Mode cycled 3 -> 0 (Hidden)")
    Assert(indicator_class.is_showing_ime_indicator == false, "Mode 0: is_showing_ime_indicator is false")

    ; Cleanup test window
    tGui.Destroy()

    ; Restore original states
    indicator_class.is_showing_ime_indicator := orig_showing
    ImeState.force_ime_on := orig_force_ime
}

if (A_ScriptName == "test_caret_indicator.ahk") {
    InitTestSuite("CARET INDICATOR UNIT TESTS")
    Test_Caret_Indicator()
    FinishTestSuite()
}
