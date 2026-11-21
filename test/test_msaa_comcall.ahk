#Requires AutoHotkey v2.0
#SingleInstance Force

log_file := A_ScriptDir . "\msaa_comcall.txt"
try FileDelete(log_file)
Log(msg) => FileAppend(msg . "`n", log_file, "UTF-8")

tGui := Gui("+AlwaysOnTop")
editCtrl := tGui.Add("Edit", "w300 -Wrap", "MSAA Testing Text")
tGui.Show("x300 y300")
editCtrl.Focus()
Sleep(200)

IID := Buffer(16)
NumPut("int64", 0x11CF3C3D618736E0, "int64", 0x719B3800AA000C81, IID)

pAcc := 0
OBJID_CARET := 0xFFFFFFF8
hr := DllCall("oleacc\AccessibleObjectFromWindow",
    "Ptr", editCtrl.Hwnd,
    "UInt", OBJID_CARET,
    "Ptr", IID.Ptr,
    "Ptr*", &pAcc,
    "Int"
)
Log(Format("AccessibleObjectFromWindow: hr={:x}, pAcc={}", hr, pAcc))

if hr == 0 && pAcc {
    rx := 0, ry := 0, rw := 0, rh := 0

    ; In x64 Windows ABI, a 16/24-byte VARIANT passed by value is passed by address (pointer)
    ; In x86, it is passed by value (two int64s / four DWORDs)
    varChild := Buffer(A_PtrSize == 8 ? 24 : 16, 0)
    NumPut("UShort", 3, varChild, 0) ; VT_I4
    NumPut("Int", 0, varChild, 8)    ; CHILDID_SELF = 0

    Log("Calling ComCall index 22")
    if A_PtrSize == 8 {
        hrLoc := ComCall(22, pAcc, "Int*", &rx, "Int*", &ry, "Int*", &rw, "Int*", &rh, "Ptr", varChild.Ptr)
    } else {
        hrLoc := ComCall(22, pAcc, "Int*", &rx, "Int*", &ry, "Int*", &rw, "Int*", &rh, "Int64", NumGet(varChild, 0, "Int64"), "Int64", NumGet(varChild, 8, "Int64"))
    }
    Log(Format("ComCall: hrLoc={:x}, rx={}, ry={}, rw={}, rh={}", hrLoc, rx, ry, rw, rh))
    ObjRelease(pAcc)
}

tGui.Destroy()
Log("Done")
