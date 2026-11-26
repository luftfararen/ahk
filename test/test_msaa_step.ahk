#Requires AutoHotkey v2.0
#SingleInstance Force

log_file := A_ScriptDir . "\msaa_step.txt"
try FileDelete(log_file)
Log(msg) => FileAppend(msg . "`n", log_file, "UTF-8")

Log("Step 1: creating GUI")
tGui := Gui("+AlwaysOnTop")
editCtrl := tGui.Add("Edit", "w300 -Wrap", "MSAA Testing Text")
tGui.Show("x300 y300")
editCtrl.Focus()
Sleep(200)

Log("Step 2: preparing IID")
IID := Buffer(16)
NumPut("int64", 0x11CF3C3D618736E0, "int64", 0x719B3800AA000C81, IID)

Log("Step 3: calling AccessibleObjectFromWindow")
pAcc := 0
OBJID_CARET := 0xFFFFFFF8
hr := DllCall("oleacc\AccessibleObjectFromWindow",
    "Ptr", editCtrl.Hwnd,
    "UInt", OBJID_CARET,
    "Ptr", IID.Ptr,
    "Ptr*", &pAcc,
    "Int"
)
Log(Format("Step 4: hr={:x}, pAcc={}", hr, pAcc))

if hr == 0 && pAcc {
    Log("Step 5: wrapping ComValue")
    oAcc := ComValue(9, pAcc)
    rx := 0, ry := 0, rw := 0, rh := 0
    Log("Step 6: calling accLocation")
    oAcc.accLocation(&rx, &ry, &rw, &rh, 0)
    Log(Format("Step 7: rx={}, ry={}, rw={}, rh={}", rx, ry, rw, rh))
}

Log("Step 8: destroying GUI")
tGui.Destroy()
Log("Step 9: finished")
