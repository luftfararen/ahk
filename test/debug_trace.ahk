#Requires AutoHotkey v2.0
#SingleInstance Force

trace_log := A_ScriptDir . "\trace.log"
try FileDelete(trace_log)

Trace(msg) {
    global trace_log
    FileAppend(msg . "`n", trace_log)
}

Trace("START TRACE")

; Init の各ステップをテストしてみる
try {
    Trace("1. QueryFrequency")
    g_freq := QueryFrequency()
    start_qpc := HighPrecisionTimer()

    Trace("2. timeBeginPeriod")
    DllCall("winmm\timeBeginPeriod", "UInt", 1, "UInt")

    Trace("3. InitMaps")
    InitMaps()

    Trace("4. InitGlobalKeys")
    InitGlobalKeys()

    Trace("5. Mod key list & Layer map")
    global mod_key_list
    mod_key_list := [f13, noconv, conv, f14, f13, f13, tab, space, conv, f13, noconv, tab, tab, tab]
    global layer_id_to_mod_key_id
    layer_id_to_mod_key_id := [M1, M2, M3, M4, ["Alt+M1", M6], M7, M8, M9]

    Trace("6. InitModLayer")
    InitModLayer()

    Trace("7. InitGUI")
    InitGUI()

    Trace("8. LoadLayoutConfig")
    LoadLayoutConfig()

    Trace("9. TypeAnalyzer.Load")
    TypeAnalyzer.Load()

    Trace("10. SetTimer")
    SetTimer(TimerEvent, 100)

    Trace("11. SUCCESS INIT")
} catch as err {
    Trace("EXCEPTION: " . err.Message . " at line " . err.Line . " in " . err.File)
}

#Include "..\src\PlayGroundsExp.ahk"
