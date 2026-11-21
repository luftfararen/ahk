#Requires AutoHotkey v2.0
#SingleInstance Force

log_file := A_ScriptDir . "\msaa_variant_test2.txt"
try FileDelete(log_file)
Log(msg) => FileAppend(msg . "`n", log_file, "UTF-8")

; Create VARIANT in buffer: VT_I4 = 3, lVal = 0
; In x64, sizeof(VARIANT) is 24 bytes
varChild := Buffer(24, 0)
NumPut("UShort", 3, varChild, 0)
NumPut("Int", 0, varChild, 8)

tGui := Gui("+AlwaysOnTop")
editCtrl := tGui.Add("Edit", "w300 -Wrap", "MSAA Testing Text")
tGui.Show("x300 y300")
editCtrl.Focus()
Sleep(200)

IID := Buffer(16)
NumPut("int64", 0x11CF3C3D618736E0, "int64", 0x719B3800AA000C81, IID)

pAcc := 0
hr := DllCall("oleacc\AccessibleObjectFromWindow",
    "Ptr", editCtrl.Hwnd,
    "UInt", 0xFFFFFFF8,
    "Ptr", IID.Ptr,
    "Ptr*", &pAcc,
    "Int"
)
Log(Format("hr={:x}, pAcc={}", hr, pAcc))

if hr == 0 && pAcc {
    rx := 0, ry := 0, rw := 0, rh := 0

    Log("Try 2: Ptr to varChild")
    try {
        hr2 := ComCall(22, pAcc, "Int*", &rx, "Int*", &ry, "Int*", &rw, "Int*", &rh, "Ptr", varChild.Ptr, "Int")
        Log(Format("Try 2 hr={:x}, rx={}, ry={}, rw={}, rh={}", hr2, rx, ry, rw, rh))
    } catch as e {
        Log("Try 2 exception: " . e.Message)
    }

    ObjRelease(pAcc)
}

tGui.Destroy()
Log("Finished successfully")
