#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "test_framework.ahk"

InitTestSuite("MSAA CARET TEST")

GetCaretPositionMSAA(hwnd) {
    if !hwnd
        return false

    static IID_IAccessible := Buffer(16)
    static init_iid := false
    if !init_iid {
        init_iid := true
        DllCall("ole32\CLSIDFromString", "Str", "{618736E0-3C3D-11CF-810C-00AA00389B71}", "Ptr", IID_IAccessible)
    }

    OBJID_CARET := 0xFFFFFFF8

    pAcc := 0
    hr := DllCall("oleacc\AccessibleObjectFromWindow",
        "Ptr", hwnd,
        "UInt", OBJID_CARET,
        "Ptr", IID_IAccessible.Ptr,
        "Ptr*", &pAcc,
        "Int"
    )

    if (hr != 0 || !pAcc)
        return false

    rx := 0, ry := 0, rw := 0, rh := 0
    success := false

    try {
        oAcc := ComValue(9, pAcc, 1)
        oAcc.accLocation(&rx, &ry, &rw, &rh, 0)
        success := true
    } catch as e {
        LogMsg(Format("ComValue accLocation error: {}`n", e.Message))
        try {
            varChild := Buffer(A_PtrSize == 8 ? 24 : 16, 0)
            NumPut("UShort", 3, varChild, 0)
            NumPut("Int", 0, varChild, 8)
            hrLoc := ComCall(22, pAcc, "Int*", &rx, "Int*", &ry, "Int*", &rw, "Int*", &rh, "Ptr", varChild.Ptr)
            if hrLoc == 0
                success := true
        }
        ObjRelease(pAcc)
    }

    if !success || (rx == 0 && ry == 0 && rw == 0 && rh == 0)
        return false

    return {x: rx + rw, y: ry + rh, rx: rx, ry: ry, rw: rw, rh: rh}
}

tGui := Gui("+AlwaysOnTop")
editCtrl := tGui.Add("Edit", "w300 -Wrap", "MSAA Testing Text")
tGui.Show("x300 y300")
editCtrl.Focus()
Sleep(200)

resMSAA := GetCaretPositionMSAA(editCtrl.Hwnd)
LogMsg(Format("Edit HWND: {:x}, MSAA result: {}`n", editCtrl.Hwnd, resMSAA ? Format("rx={}, ry={}, rw={}, rh={}, x={}, y={}", resMSAA.rx, resMSAA.ry, resMSAA.rw, resMSAA.rh, resMSAA.x, resMSAA.y) : "false"))

tGui.Destroy()

Assert(resMSAA != false, "MSAA successfully retrieved caret position from Edit control")
if resMSAA {
    Assert(resMSAA.x >= 300 && resMSAA.y >= 300, "MSAA caret coordinates in valid range")
}

FinishTestSuite()
