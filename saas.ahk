#Requires AutoHotkey v2.0

; ============================================================================
; SCRIPT OVERVIEW
; ============================================================================
; This script provides advanced key customization for AutoHotkey v2.
; Key features:
; 1. Center Modifiers (MKey): Allows keys like Space, Enter, and Noconvert
;    to act as normal keys on a short press (tap) and as modifier keys
;    (layers) when held down.
; 2. Key Remapping (RKey): Remaps keys, with different behaviors for
;    Shift-pressed, IME-on, and IME-off states.
; 3. Long Press Keys (LKey): Extends RKey to add functionality for long-pressing
;    a key (e.g., tap ';' for ';', hold for ':').S
; 4. Key Layers (#HotIf): Uses the MKey modifiers to create multiple
;    keyboard layers (e.g., a navigation layer, a numpad layer, a symbol layer).
; 5. Layout Switching: Functions to dynamically change the keyboard layout
;    (e.g., to Colemak, FMIX, Oonishi).
; 6. IME Control: Functions to get, set, and toggle the Input Method Editor (IME) state.
; 7. Mouse Speed Control: Uses a class to adjust system mouse speed via hotkeys.
; ============================================================================

; ============================================================================
; MODIFIER SYMBOLS & CONSTANTS
; ============================================================================
; Modifier Symbols:
; Win: #
; Ctrl: ^
; Shift: +
; Alt: !

; Keys that can be used directly in Send:
; - ^ ¥ @ [ ] . /
; Keys that require {}:
; Space Tab Enter BS Del Ins Left Right Up Down Home End PgUp PgDn Esc Pause PrintScreen

; ============================================================================
; MODIFIER SYMBOLS & CONSTANTS
; ============================================================================
; --- Variable Naming Convention ---
; R_... : Raw string (e.g., "sc07B") for hotkey definitions.
; C_... : Send-compatible string (e.g., "{sc07B}").
; B_... : Blind-mode Send string (e.g., "{Blind}{sc07B}").

; --- Noconvert key ---
R_NOCONV := "sc07B"
C_NOCONV := "{sc07B}"

; --- Convert key ---
R_CONV := "sc079"
C_CONV := "{sc079}"

; --- Backslash/Yen key (\) ---
;R_BACKSLASH := "sc07D"
C_BACKSLASH := "{sc07D}"
B_BACKSLASH := "{Blind}{sc07D}"

; --- Underscore key (\) ---
;R_BACKSLASH2 := "sc073"
C_BACKSLASH2 := "{sc073}"

; --- Hat/Caret key (^) ---
;R_HAT := "sc00D"
C_HAT := "{sc00D}"

; --- Semicolon (;) ---
;R_SEMICOLON := "sc027"
C_SEMICOLON := "{sc027}"
B_SEMICOLON := "{Blind}{sc027}"
C_PLUS := "+{sc027}"

; --- Colon (:) ---
;R_COLON := "sc028"
C_COLON := "{sc028}"
B_COLON := "{Blind}{sc028}"
C_ASTERISK := "+{sc028}"

; --- Comma (,) ---
;R_COMMA := "sc033"
C_COMMA := "{sc033}"

; --- Eisu (Capslock) ---
R_EISU := "sc03A"
C_EISU := "{sc03A}"

; --- Hiragana/Katakana ---
R_HIRAGANA := "sc070"
C_HIRAGANA := "{sc070}"

; --- Zenkaku/Hankaku (IME) ---
R_ZENKAKU := "sc029"
C_ZENKAKU := "{sc029}"
B_ZENKAKU := "{Blind}{sc029}"

; --- Slash (/) ---
;R_SLASH := "sc035"
C_SLASH := "{sc035}"
B_SLASH := "{Blind}{sc035}"

; --- Enter ---
R_ENTER := "ENTER"
C_ENTER := "{Enter}"
B_ENTER := "{Blind}{Enter}"

; --- Numpad Constants ---
C_N0 := "{Numpad0}"
C_N1 := "{Numpad1}"
C_N2 := "{Numpad2}"
C_N3 := "{Numpad3}"
C_N4 := "{Numpad4}"
C_N5 := "{Numpad5}"
C_N6 := "{Numpad6}"
C_N7 := "{Numpad7}"
C_N8 := "{Numpad8}"
C_N9 := "{Numpad9}"
C_NDOT := "{NumpadDot}"

; --- Numpad Operators (Blind only) ---
B_NADD := "{Blind}{NumpadAdd}"
B_NMUL := "{Blind}{NumpadMult}"
B_NSUB := "{Blind}{NumpadSub}"
B_NDIV := "{Blind}{NumpadDiv}"

; --- Functional Keys ---
C_DEL := "{Delete}"
B_DEL := "{Blind}{Delete}"

C_BS := "{Backspace}"
B_BS := "{Blind}{Backspace}"

C_ESC := "{Esc}"
B_ESC := "{Blind}{Esc}"

R_TAB := "Tab"
B_TAB := "{Blind}{Tab}"

R_SPACE := "Space"
;C_SPACE := "{Space}"
B_SPACE := "{Blind}{Space}"

; --- Edit/Navi Shortcuts ---
R_REDO := "^y"
B_UNDO := "{Blind}^{z}"
B_CUT := "{Blind}^{x}"
B_COPY := "{Blind}^{c}"
B_PASTE := "{Blind}^{v}"

; --- Navigation ---
B_HOME := "{Blind}{Home}"
B_END := "{Blind}{End}"
B_PGUP := "{Blind}{PgUp}"
B_PGDN := "{Blind}{PgDn}"

B_CHOME := "{Blind}^{Home}"
B_CEND := "{Blind}^{End}"
C_CSHOME := "^+{Home}"
C_CSEND := "^+{End}"
B_CPGUP := "{Blind}^{PgUp}"
B_CPGDN := "{Blind}^{PgDn}"

C_LEFT := "{Left}"
B_LEFT := "{Blind}{Left}"
C_RIGHT := "{Right}"
B_RIGHT := "{Blind}{Right}"
C_UP := "{Up}"
B_UP := "{Blind}{Up}"
C_DOWN := "{Down}"
B_DOWN := "{Blind}{Down}"

B_CLEFT := "{Blind}^{Left}"
B_CRIGHT := "{Blind}^{Right}"
C_CSLEFT := "^+{Left}"
C_CSRIGHT := "^+{Right}"

; --- Function Keys (Blind only) ---
B_F1 := "{Blind}{F1}"
B_F2 := "{Blind}{F2}"
B_F3 := "{Blind}{F3}"
B_F4 := "{Blind}{F4}"
B_F5 := "{Blind}{F5}"
B_F6 := "{Blind}{F6}"
B_F7 := "{Blind}{F7}"
B_F8 := "{Blind}{F8}"
B_F9 := "{Blind}{F9}"
B_F10 := "{Blind}{F10}"
B_F11 := "{Blind}{F11}"
B_F12 := "{Blind}{F12}"

; ============================================================================
; SCRIPT SETTINGS
; ============================================================================
;SingleInstkance Force ; (Commented out) Allow multiple instances
ProcessSetPriority "Realtime" ; Set high priority for max responsiveness
SendMode "Input" ; Use "Input" mode for speed and reliability

InstallKeybdHook true ; Always install the keyboard hook
InstallMouseHook true ; Always install the mouse hook (for MouseSpeed class)
#UseHook true ; Force hotkeys to use the hook
#MaxThreadsBuffer True ; Buffer hotkeys if interrupted
;#MaxThreadsPerHotkey 3 ; (Commented out) Limit threads per hotkey
SetKeyDelay 0 ; No delay after keystrokes

ShowOSD(text, duration := 3000) {
    MyGui := Gui("+AlwaysOnTop +ToolWindow -Caption +Disabled")
    MyGui.BackColor := "333333"
    MyGui.SetFont("s12 cWhite w700", "Segoe UI")

    ; 【修正点】テキスト周囲の余白はここで設定します
    MyGui.MarginX := 20
    MyGui.MarginY := 15

    ; 第2引数の "Padding10" を削除しました
    MyGui.Add("Text", "Center", text)

    MyGui.Show("NoActivate xCenter y900") ; 画面下部中央に表示
    SetTimer(() => MyGui.Destroy(), -duration)
}
; ============================================================================
; GLOBAL FUNCTIONS
; ============================================================================

shift_lambda := () => GetKeyState("Shift", "P")

/**
 * Gets the physical state of the Shift key.
 * @returns {Boolean} True if Shift is pressed, false otherwise.
 */
GetShiftState() {
    global shift_lambda
    return shift_lambda()
}

/**
 * Gets the handle (HWND) of the active window or focused control,
 * which is necessary for accurate IME state detection.
 * @returns {Ptr} The window handle (HWND).
 */
GetActiveWindowHandle() {
    hwnd := WinExist("A")
    if WinActive("A") {
        ptrSize := A_PtrSize
        cbSize := 4 + 4 + (ptrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("UInt", cbSize, stGTI, 0)
        if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", stGTI) {
            hwnd := NumGet(stGTI, 8 + ptrSize, "UInt")
        }
    }
    return hwnd
}

/**
 * Sets the IME (Input Method Editor) state for a specific window.
 * @param {Ptr} hwnd - The target window handle.
 * @param {Integer} state - The desired state (1 for ON, 0 for OFF).
 * @returns {LParam} The result of the DllCall.
 */
SetImeState(hwnd, state) {
    return DllCall("SendMessage"
        , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
        , "UInt", 0x0283  ; WM_IME_CONTROL
        , "Ptr", 0x006    ; IMC_SETOPENSTATUS (Set open status)
        , "Ptr", state)  ; 1 = ON, 0 = OFF
}

class ImeState {
    static force_ime_on := false

    /**
     * Checks if the IME is currently ON for the active window.
     * Also respects the `force_ime_on` global flag.
     * @returns {Boolean} True if IME is (or is forced to be) ON.
     */
    static IsOn() {
        static last_active_hwnd := 0
        hwnd := GetActiveWindowHandle()

        ; If window is the same, check the force flag
        if last_active_hwnd = hwnd {
            if ImeState.force_ime_on {
                return true
            }
        }
        else {
            ; Window changed, reset the force flag
            ImeState.force_ime_on := false
        }

        last_active_hwnd := hwnd

        ; Check the actual IME state
        return DllCall("SendMessage"
            , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
            , "UInt", 0x0283  ; WM_IME_CONTROL
            , "Ptr", 0x0005   ; IMC_GETOPENSTATUS (Get open status)
            , "Ptr", 0)      ; Returns 1 if ON, 0 if OFF
    }

    static ToggleForce() {
        ImeState.force_ime_on := !ImeState.force_ime_on
    }
    static MakeForceStateWord() {
        return ImeState.force_ime_on ? "On" : "Off"
    }
}

/**
 * Helper to check if a key string already contains modifiers.
 * @param {String} text - The key string (e.g., "^c", "{Blind}a").
 * @returns {Boolean} True if modifiers are present.
 */
IsModified(text) {
    list := ["{Blind}", "+", "#", "^", "!"]
    for index, item in list {
        if InStr(text, item, 'Off') > 0 {
            return true
        }
    }
    return false
}

/**
 * Toggles the `force_ime_on` flag for the current window.
 */
ToggleForceImeOn() {
    ImeState.ToggleForce()
    ShowOSD("Force IME: " . ImeState.MakeForceStateWord())
}

/**
 * Toggles the IME state by sending the Zenkaku/Hankaku key.
 */
ToggleImeState() {
    Send(B_ZENKAKU)	; Send {Blind}{sc029}
}

/**
 * Sends a specific key based on the current IME state.
 * @param {String} key_ime_off - The key string to send if IME is OFF.
 * @param {String} [key_ime_on=""] - The key string to send if IME is ON.
 * If omitted, `key_ime_off` is used.
 */
SendAccImeState(key_ime_off, key_ime_on := "") {
    if ImeState.IsOn() && key_ime_on != "" {
        Send(key_ime_on)
    } else {
        Send(key_ime_off)
    }
}

; --- 設定 ---
ColorJapanese := "Red"
DotSize := 8
; ------------

; キャレット表示用のGUI作成
; 描画用のウィンドウ（GUI）作成
MGui := Gui("+AlwaysOnTop -Caption +ToolWindow +LastFound -DPIScale")
MGui.BackColor := ColorJapanese
WinSetRegion("0-0 w" DotSize " h" DotSize " Ellipse", MGui)

SetTimer(ShowIMEState, 100) ;
;DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr") ; DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2

ShowIMEState() {
    static LastX := -2, LastY := 0, LastStatus := -1

    mx := -1, my := 0
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    if (mx = LastX && my = LastY) {
        ime_on := ImeState.IsOn()
        if ime_on {
            if ime_on != LastStatus {
                MGui.Show("x" (mx + 36) " y" (my + 36) " w" DotSize " h" DotSize " NoActivate")
            }
        } else {
            MGui.Hide()
        }
        LastStatus := ime_on
    } else {
        MGui.Hide()
        LastX := mx
        LastY := my
        LastStatus := -1
    }
}

/*============================================================================
 [Class] MouseSpeed
 A static class to control the system mouse speed.
============================================================================*/
class MouseSpeed {
    static SPI_GETMOUSESPEED := 0x70 ; API constant
    static SPI_SETMOUSESPEED := 0x71 ; API constant
    static DefMouseSpeed := 10

    /*============================================================================
    	Gets the current system mouse speed (value 1-20).
    ============================================================================*/
    static GetSpeed() {
        val := 0
        DllCall("SystemParametersInfo", "UInt", MouseSpeed.SPI_GETMOUSESPEED, "UInt", 0, "Ptr*", &val, "UInt", 0)
        return val
    }

    /*============================================================================
    	Sets the system mouse speed (value 1-20).
    ============================================================================*/
    static SetSpeed(val) {
        ; Clamp value between 1 and 20
        if val < 1 {
            val := 1
        } else if val > 20 {
            val := 20
        }
        DllCall("SystemParametersInfo", "UInt", MouseSpeed.SPI_SETMOUSESPEED, "UInt", 0, "Ptr", val, "UInt", 0)
        ToolTip("MouseSpeed: " . val)
        SetTimer(ToolTip, 3000) ; Show ToolTip for 3 seconds
        return val
    }

    /*============================================================================
    	Increases the mouse speed by 1.
    ============================================================================*/
    static IncSpeed() {
        v := MouseSpeed.GetSpeed()
        if v = 0 { ; Failed to get speed
            ToolTip("MouseSpeed: " . v)
            return
        }
        MouseSpeed.SetSpeed(v + 1)
    }
    /*============================================================================
    	Decreases the mouse speed by 1.
    ============================================================================*/
    static DecSpeed() {
        v := MouseSpeed.GetSpeed()
        if v = 0 { ; Failed to get speed
            return
        }
        MouseSpeed.SetSpeed(v - 1)
    }
}	 ;class MouseSpeed

/*============================================================================
 [Class] MKey (Modifier Key)
 Implements "SpaceCadet" or "Dual-Role" key functionality.
 - If pressed and released within `timeout` (short press), it sends the original key.
 - If held longer than `timeout`, it acts as a modifier (layer) key.
============================================================================*/
class MKey {
    /*============================================================================
    	Constructor
    	@param {String} key - The key to monitor (e.g., "SPACE", "sc07B").
    	                     Can be in "{...}" format or plain.
    	@param {Integer} [timeout=200] - The time (ms) to differentiate a short press.
    ============================================================================*/
    __New(key, timeout := 180) {
        if key = "" { ; For "virtual" modifiers like F13
            this.key_str := ""
            this.key := key ; registerd key
        } else {
            if SubStr(key, 1, 1) = "{" {
                this.key := SubStr(key, 2, StrLen(key) - 2)
                this.key_str := key
            } else {
                this.key := key
                this.key_str := "{" . key . "}"
            }
        }
        this.pressed_time := 0 ; 0 = not pressed, >0 = press start time
        this.mod_str := ""     ; Stores other modifiers held at press time (e.g., "+^")
        this.type := 0         ; (Unused)
        this.timeout := timeout
    }
    /*============================================================================
    	Checks if the key is currently in a "held down" state (Down() called).
    	@returns {Boolean} 1 (true) if pressed, 0 (false) if not.
    ============================================================================*/
    IsPressed() {
        if this.pressed_time != 0 {
            return 1
        }
        ;		if GetKeyState(this.key,"P"){ ; (Commented out) Use internal state, not physical
        ;			return 1
        ;		}
        return 0
    }

    /**
     * Stores the state of other modifiers (Shift, Ctrl, Alt, Win)
     * at the moment this key was pressed.
     */
    SetModStr() {
        this.mod_str := ""
        if GetKeyState("Shift", "P") {
            this.mod_str := "+"
        }
        if GetKeyState("Ctrl", "P") {
            this.mod_str := "^" . this.mod_str
        }
        if GetKeyState("Alt", "P") {
            this.mod_str := "!" . this.mod_str
        }
        if GetKeyState("LWin", "P") || GetKeyState("RWin", "P") {
            this.mod_str := "#" . this.mod_str
        }
    }

    /*============================================================================
    	Call this on the key-down hotkey (e.g., `*Space::space.Down()`).
    	@returns {Boolean} False if already pressed (prevents key-repeat), true otherwise.
    ============================================================================*/
    Down() {
        if this.pressed_time != 0 { ; Already processing a press, ignore
            return false
        }
        this.pressed_time := A_TickCount ; Record press time
        this.SetModStr()                 ; Record other modifiers
        return true
    }

    /*============================================================================
    	Call this on the key-up hotkey (e.g., `*Space up::space.Up()`).
    	If it was a short press, sends the original key (with modifiers).
    ============================================================================*/
    Up() {
        if (A_TickCount - this.pressed_time < this.timeout) {
            ; Short press: send the original key, preserving other modifiers
            SendInput("{Blind}" . this.mod_str . this.key_str)
        }
        ; Long press: do nothing (the key was used as a layer)
        this.pressed_time := 0 ; Reset state
    }

    /**
     * Force-resets the key's pressed state.
     */
    Reset() {
        this.pressed_time := 0
    }
} ;class MKey

/*============================================================================
 [Class] RKey (Remap Key)
 Manages key remapping, handling different outputs for Shift,
 IME-on, and IME-off states.
============================================================================*/
class RKey {
    static use_registered_key_for_ctrl := false ; (Unused?) for ctrl or alt

    /*============================================================================
    	Constructor
    	@param {String} key - The base key to send (e.g., "a", "{sc027}").
    	@param {String} [shift_key=""] - Key to send when Shift is held.
    	                                 "" = auto-generate (e.g., "+a")
    	                                 "none" = do nothing on Shift.
    ============================================================================*/
    __New(key, shift_key := "") {
        this.shift_key_str := ""     ; (IME OFF) Shifted key
        this.shift_ime_key_str := "" ; (IME ON) Shifted key
        this.SetKey(key, shift_key)   ; Set keys for IME OFF
        this.SetImeKey(key, shift_key) ; Set keys for IME ON (defaults to OFF)
    }

    /*============================================================================
    	Sets the key mapping for when IME is OFF.
    	@param {String} key - The base key to send.
    	@param {String} [shift_key=""] - Key for Shift. ""=auto, "none"=disable.
    ============================================================================*/
    SetKey(key, shift_key := "") {
        this.key := key ; Store original key
        if IsModified(key) {
            ; Key already has modifiers (e.g., "^c")
            this.short_key_str := key
            if shift_key = "none" {
                this.shift_key_str := "" ; Do nothing
            } else {
                if shift_key = "" {
                    this.shift_key_str := "" ; Default: do nothing if base is modified
                } else {
                    this.shift_key_str := shift_key ; User-defined
                }
            }
        } else {
            ; Key is simple (e.g., "a")
            this.short_key_str := "{Blind}" . key
            if shift_key = "none" {
                this.shift_key_str := "" ; Do nothing
            } else {
                if shift_key = "" {
                    ; Auto-generate shift key
                    this.shift_key_str := "{Blind}+" . key
                } else {
                    this.shift_key_str := shift_key ; User-defined
                }
            }
        }
    }

    /*============================================================================
    	Sets the key mapping for when IME is ON.
    	@param {String} [key=""] - Base key for IME ON. If blank, uses IME OFF key.
    	@param {String} [shift_key=""] - Shift key for IME ON.
    	                                ""=auto/default, "none"=disable.
    ============================================================================*/
    SetImeKey(key := "", shift_key := "") {
        if key = "" {
            key := this.short_key_str ; Default to IME OFF key
        }
        if IsModified(key) {
            ; Key already has modifiers
            this.short_ime_key_str := key
            if shift_key = "none" {
                this.shift_ime_key_str := ""
            } else {
                if shift_key = "" {
                    ; Default to IME OFF shifted key
                    this.shift_ime_key_str := this.shift_key_str
                } else {
                    this.shift_ime_key_str := shift_key
                }
            }
        } else {
            ; Key is simple
            this.short_ime_key_str := "{Blind}" . key
            if shift_key = "none" {
                this.shift_ime_key_str := ""
            } else {
                if shift_key = "" {
                    ; Auto-generate shift key
                    this.shift_ime_key_str := "{Blind}+" . key
                } else {
                    this.shift_ime_key_str := shift_key
                }
            }
        }
    }

    /**
     * Internal helper: Sends the correct key based on IME state.
     * @param {String} ime_key - Key to send if IME is ON.
     * @param {String} normal_key - Key to send if IME is OFF.
     */
    _SendKey(ime_key, normal_key) {
        if ime_key = normal_key {
            Send(normal_key) ; No difference, just send
        } else {
            if ime_key != "" && ImeState.IsOn() {
                Send(ime_key) ; Send IME ON key
            } else {
                Send(normal_key) ; Send IME OFF key
            }
        }
    }

    /**
     * Sends the remapped key, choosing between short or shifted version.
     * Also accounts for IME state via `_SendKey`.
     * @param {Boolean} [shift=true] - If true, send shifted key. If false, send base key.
     * @returns {Boolean} The value of the `shift` parameter.
     */
    SendShiftedKey(shift := true) {
        if shift {
            ; Send the shifted key (IME-aware)
            this._SendKey(this.shift_ime_key_str, this.shift_key_str)
            return true
        } else {
            ; Send the base key (IME-aware)
            this._SendKey(this.short_ime_key_str, this.short_key_str)
            return false
        }
    }

    /**
     * Handles Ctrl, Alt, Win (CAW) passthrough.
     * If any of these modifiers are held, bypass remapping and send
     * the original physical key.
     * @param {String} pressed_key - The physical key pressed (e.g., "x", "sc027").
     * @returns {Boolean} True if CAW was pressed (passthrough happened), false otherwise.
     */
    _SendCAWKey(pressed_key) {
        caw := GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") ||
        GetKeyState("LWin", "P") || GetKeyState("RWin", "P")
        if caw {
            ; Passthrough: send the original key
            Send("{Blind}" . "{" . pressed_key . "}")
            ;ToolTip pressed_key
            return true
        }
        return false
    }

    /**
     * Main key-sending logic.
     * 1. Checks for Ctrl/Alt/Win (passthrough).
     * 2. If no CAW, checks for Shift and sends the correct remapped key (base or shifted).
     * @param {String} pressed_key - The physical key pressed.
     * @returns {Boolean} True if CAW passthrough occurred.
     */
    _SendSCAWKey(pressed_key) {
        if this._SendCAWKey(pressed_key) {
            return true ; CAW was pressed, logic is done.
        }
        ; No CAW, so check Shift state
        shift := GetShiftState()
        this.SendShiftedKey(shift) ; Send the remapped key (base or shifted)
        return false
    }

    /*============================================================================
    	Call this on the key-down hotkey (e.g., `*x::x.Down("x")`).
    ============================================================================*/
    Down(pressed_key := "") {
        if RKey.use_registered_key_for_ctrl || pressed_key = "" {
            pressed_key := this.key
        }
        this._SendSCAWKey(pressed_key)
    }

    /*============================================================================
    	Call this on the key-up hotkey (e.g., `*x up::x.Up()`).
    	(Unused by RKey, but required by LKey inheritance).
    ============================================================================*/
    Up() {
    }
} ;class RKey

/*============================================================================
 [Class] LKey (Long-press Key)
 Extends RKey to add a "long press" action.
 - Short Press: Acts like RKey (sends base or shifted key).
 - Long Press: Sends a different, specified key.
============================================================================*/
class LKey extends RKey {
    ;static use_registered_key_for_ctrl  := false ; (Inherited)
    static long_press_th := 300 ; Threshold (ms) for a long press
    static last_key := ""       ; Tracks last key to prevent repeats
    static long_press_enabled := true ; Global toggle for this feature

    long_key_str := ""  ; The key to send on a long press
    pressing := False   ; Is this key currently held down?

    /*============================================================================
    	Constructor
    	@param {String} key - The base key to send (short press).
    	@param {String} [shift_key=""] - Key for Shift (short press).
    	@param {String} [long_key=""] - Key for long press.
    	                                "" = defaults to `shift_key`
    	                                "none" = disable long press for this key.
    ============================================================================*/
    __New(key, shift_key := "", long_key := "") {
        super.__New(key, shift_key) ; Init RKey (base/shift keys)
        this.SetLongKey(long_key)  ; Init long_key
        this.send_time := 0        ; Time long_key was last sent
        this.pressed_time := 0     ; Time key was pressed down
    }

    /*============================================================================
    	Globally enables, disables, or toggles the long-press feature.
    	@param {Integer} [m=2] - Mode: 0=disable, 1=enable, 2=toggle.
    	@param {Boolean} [show_info=False] - Show a TrayTip notification.
    ============================================================================*/
    static EnableLongPress(m := 2, show_info := False) {
        if m == 0 {
            LKey.long_press_enabled := False
        } else if m == 1 {
            LKey.long_press_enabled := True
        } else {
            LKey.long_press_enabled := !LKey.long_press_enabled ; Toggle
        }
        if show_info {
            if LKey.long_press_enabled {
                ShowOSD("LKey is enabled")
            } else {
                ShowOSD("LKey is disabled")
            }
        }
    }

    /*============================================================================
    	(Override) Sets the key mapping for when IME is OFF.
    	@param {String} key - The base key to send.
    	@param {String} [shift_key=""] - Key for Shift.
    ============================================================================*/
    SetKey(key, shift_key := "") {
        super.SetKey(key, shift_key)
    }

    /**
     * Sets the long-press key string.
     * @param {String} [long_key=""]
     */
    SetLongKey(long_key := "") {
        if long_key = "" {
            this.long_key_str := this.shift_key_str ; Default to the shifted key
        } else if long_key = "none" {
            this.long_key_str := "none" ; Disable long press
        } else {
            this.long_key_str := long_key ; Use specified key
        }
    }

    /*============================================================================
    (Override) Checks if the key is currently held down.
    ============================================================================*/
    IsPressed() {
        return this.pressing
    }

    /**
     * Internal key-down logic for LKey.
     * @param {String} pressed_key - The physical key pressed.
     */
    _Down(pressed_key) {
        if this.long_key_str = "none" {
            ; --- Long press is disabled ("none") for this key ---
            if super._SendCAWKey(pressed_key) { ; Check for Ctrl/Alt/Win passthrough
                this.pressed_time := 0 ; Not a long-press candidate
                return
            }
            if this.pressing { ; Prevent key-repeat
                return
            }
            this.pressing := True
            LKey.last_key := this.key
            ; This key *doesn't* send on Down. It sends on Up (if short press).
            this.pressed_time := A_TickCount ; Start timer for Up()
            ;tooltip	this.pressed_time
        } else {
            ; --- Long press is enabled for this key ---
            this.pressing := True
            if LKey.long_press_enabled { ; Check global toggle
                ; (Key repeat handling?)
                if LKey.last_key = this.key && this.send_time > 0 {
                    if A_TickCount - this.send_time < LKey.long_press_th {
                        return
                    }
                }
                LKey.last_key := this.key

                ; (Refactored: Fixed bug, was `_SendModKey`)
                ; Call RKey's main send logic. This sends the SHORT key immediately.
                ; If it was a passthrough (Ctrl/Alt/Win), it returns true.
                if !super._SendSCAWKey(pressed_key) {
                    ; Not a passthrough, so start the long-press timer.
                    this.pressed_time := A_TickCount
                }
            } else {
                ; Long press feature is globally disabled
                ; (Refactored: Fixed bug, was `SendModKey`)
                super._SendSCAWKey(pressed_key) ; Act as a normal RKey
            }
        }
    }

    /*============================================================================
    	(Override) Call this on the key-down hotkey (e.g., `*x::x.Down("x")`).
    ============================================================================*/
    Down(pressed_key := "") {
        ;LayerKey.ChangeLayer(0)
        if LKey.use_registered_key_for_ctrl || pressed_key = "" {
            pressed_key := this.key
        }
        this._Down(pressed_key)
    }

    /*============================================================================
    (Override) Call this on the key-up hotkey (e.g., `*x up::x.Up()`).
    Handles the short-press vs long-press logic.
    @returns {Boolean} True if a long press was actioned, false if short press.
    ============================================================================*/
    Up() {
        if this.pressed_time > 0 && this.long_key_str != "" {
            time := A_TickCount
            if this.long_key_str = "none" {
                ; --- Long press "none" (sends on Up) ---
                if time - this.pressed_time >= LKey.long_press_th {
                    ; Held for a long time, but "none" means do nothing.
                } else {
                    ; Short press: send the key now.
                    if this.pressing {
                        if LKey.last_key = this.key {
                            shift := GetShiftState()
                            this.SendShiftedKey(shift) ; Send base/shifted key
                        }
                    }
                }
                this.pressed_time := 0
            } else {
                ; --- Long press enabled ---
                if time - this.pressed_time >= LKey.long_press_th {
                    ; Long press detected!
                    if LKey.last_key = this.key {
                        this.send_time := time
                        ; Backspace the short-press key (sent on Down) and send the long-press key.
                        Send("{Backspace}" . this.long_key_str)
                        this.pressed_time := 0
                        this.pressing := false
                        return true ; Long press actioned
                    }
                }
            }
        }
        ; This was a short press (or timer not set), and Down() already sent the key.
        this.pressing := false
        this.send_time := 0
        this.pressed_time := 0
        return false ; Short press
    }
} ;class LKey

; ============================================================================
; KEY OBJECT INSTANTIATION
; ============================================================================

; --- Modifier Keys (MKey) ---
f13 := MKey("")
space := MKey(R_SPACE)
;shift_lambda := () => (GetKeyState("Shift","P") || space.IsPressed())
tab := MKey(R_TAB)
noconv := MKey(R_NOCONV)
conv := MKey(R_ENTER)
f14 := MKey(R_ENTER)
colon := LKey(C_COLON, "", "none")

; --- Remap Keys (RKey) ---
; (Number Row)
k1 := RKey("1")
k2 := RKey("2")
k3 := RKey("3")
k4 := RKey("4")
k5 := RKey("5")
k6 := RKey("6")
k7 := RKey("7")
k8 := RKey("8")
k9 := RKey("9")
k0 := RKey("0", "none") ; '0' has no shifted key
minus := RKey("-")
hat := RKey(C_HAT) ; ^
backslash := RKey("\") ; ¥
;
; (QWERTY Row)
q := RKey("q")
w := RKey("w")
e := RKey("e")
r := RKey("r")
t := RKey("t")
;
y := RKey("y")
u := RKey("u")
i := RKey("i")
o := RKey("o")
p := RKey("p")
at := RKey("@")
openbracket := RKey("[")
;
; (ASDF Row)
a := RKey("a")
s := RKey("s")
d := RKey("d")
f := RKey("f")
g := RKey("g")
;
h := RKey("h")
j := RKey("j")
k := RKey("k")
l := RKey("l")
semicolon := RKey(C_SEMICOLON) ; ;
;colon := RKey(C_COLON) ; (Defined as LKey above)
closebracket := RKey("]")
;
; (ZXCV Row)
z := RKey("z")
x := RKey("x")
c := RKey("c")
v := RKey("v")
b := RKey("b")
;
n := RKey("n")
m := RKey("m")
comma := RKey(C_COMMA) ; ,
period := RKey(".") ; .
slash := RKey("/") ; /
backslash2 := RKey(C_BACKSLASH2) ; _
;
; (Arrow Keys - for remapping)
up := RKey(C_UP)
down := RKey(C_DOWN)
left := RKey(C_LEFT)
right := RKey(C_RIGHT)

; ============================================================================
; LAYER STATE FUNCTIONS
; ============================================================================

L_NAVL_CTRL := 1
L_SYMBOL_NUM := 2
L_SYMBOL1 := 7
L_SYMBOL2 := 6
L_SELECT := 3
L_NUMPAD := 4
L_SHIFT := 5
L_FUNC := 6

/**
 * Checks if a specific modifier layer (M1-M6) is active,
 * ensuring no other layers are active simultaneously.
 * @param {Integer} layer - Modifier layer number to check:
 * @returns {Boolean} True if only the specified layer is active.
 */
LayerState(layer) {
    ; Check the specified layer
    if layer = L_NAVL_CTRL {
        return f13.IsPressed() && !(GetKeyState("Alt", "P") || GetKeyState(R_NOCONV, "P"))
    }
    if layer = L_SYMBOL1 {
        return conv.IsPressed()
    }
    if layer = L_SYMBOL2 {
        return colon.IsPressed() || f14.IsPressed()
    }
    if layer = L_SYMBOL_NUM {
        return noconv.IsPressed() && !(GetKeyState("F13", "P") || GetKeyState("Alt", "P"))
    }
    if layer = L_NUMPAD {
        return tab.IsPressed()
    }
    if layer = L_SELECT {
        return f13.IsPressed() && (GetKeyState("Alt", "P") || GetKeyState(R_NOCONV, "P"))
    }
    if layer = L_SHIFT {
        return space.IsPressed()
    }
    ; if layer = L_FUNC {
    ;     return f14.IsPressed()
    ; }
    return false
}

; ============================================================================
; KEY LAYOUT SWITCHING FUNCTIONS
; ============================================================================

/**
 * Resets all IME-ON key definitions (SetImeKey)
 * back to their IME-OFF (SetKey) defaults.
 */
ResetIME() {
    global k1, k2, k3, k4, k5, k6, k7, k8, k9, k0
    global minus
    global q, w, e, r, t, y, u, i, o, p
    global a, s, d, f, g, h, j, k, l, semicolon
    global b, n, m, comma, period, slash

    k1.SetIMEKey()
    k2.SetIMEKey()
    k3.SetIMEKey()
    k4.SetIMEKey()
    k5.SetIMEKey()
    k6.SetIMEKey()
    k7.SetIMEKey()
    k8.SetIMEKey()
    k9.SetIMEKey()
    k0.SetIMEKey()
    minus.SetIMEKey()

    q.SetImeKey()
    w.SetImeKey()
    e.SetImeKey()
    r.SetImeKey()
    t.SetImeKey()
    y.SetImeKey()
    u.SetImeKey()
    i.SetImeKey()
    o.SetImeKey()
    p.SetImeKey()

    a.SetImeKey()
    s.SetImeKey()
    d.SetImeKey()
    f.SetImeKey()
    g.SetImeKey()
    h.SetImeKey()
    j.SetImeKey()
    k.SetImeKey()
    l.SetImeKey()
    semicolon.SetImeKey()

    z.SetImeKey()
    x.SetImeKey()
    c.SetImeKey()
    v.SetImeKey()
    b.SetImeKey()
    n.SetImeKey()
    m.SetImeKey()
    comma.SetImeKey()
    period.SetImeKey()
    slash.SetImeKey()
}

ExtractChar(text, idx) {
    return SubStr(text, idx, 1)
}

/**
 * Stores a new IME-ON key layout (SetImeKey)
 * @param {String} layout - New IME-ON key layout
 * @param {String} num_layout - New IME-ON number key layout
 */
StoreIMELayout(layout := "qwertyuiopasdfghjkl;zxcvbnm,./", num_layout := "1234567890-") {
    global k1, k2, k3, k4, k5, k6, k7, k8, k9, k0
    global minus
    global q, w, e, r, t, y, u, i, o, p
    global a, s, d, f, g, h, j, k, l, semicolon
    global b, n, m, comma, period, slash

    k1.SetIMEKey(ExtractChar(num_layout, 1))
    k2.SetIMEKey(ExtractChar(num_layout, 2))
    k3.SetIMEKey(ExtractChar(num_layout, 3))
    k4.SetIMEKey(ExtractChar(num_layout, 4))
    k5.SetIMEKey(ExtractChar(num_layout, 5))
    k6.SetIMEKey(ExtractChar(num_layout, 6))
    k7.SetIMEKey(ExtractChar(num_layout, 7))
    k8.SetIMEKey(ExtractChar(num_layout, 8))
    k9.SetIMEKey(ExtractChar(num_layout, 9))
    k0.SetIMEKey(ExtractChar(num_layout, 10))
    minus.SetIMEKey(ExtractChar(num_layout, 11))

    q.SetIMEKey(ExtractChar(layout, 1))
    w.SetIMEKey(ExtractChar(layout, 2))
    e.SetIMEKey(ExtractChar(layout, 3))
    r.SetIMEKey(ExtractChar(layout, 4))
    t.SetIMEKey(ExtractChar(layout, 5))
    y.SetIMEKey(ExtractChar(layout, 6))
    u.SetIMEKey(ExtractChar(layout, 7))
    i.SetIMEKey(ExtractChar(layout, 8))
    o.SetIMEKey(ExtractChar(layout, 9))
    p.SetIMEKey(ExtractChar(layout, 10))

    a.SetIMEKey(ExtractChar(layout, 11))
    s.SetIMEKey(ExtractChar(layout, 12))
    d.SetIMEKey(ExtractChar(layout, 13))
    f.SetIMEKey(ExtractChar(layout, 14))
    g.SetIMEKey(ExtractChar(layout, 15))
    h.SetIMEKey(ExtractChar(layout, 16))
    j.SetIMEKey(ExtractChar(layout, 17))
    k.SetIMEKey(ExtractChar(layout, 18))
    l.SetIMEKey(ExtractChar(layout, 19))
    semicolon.SetIMEKey(ExtractChar(layout, 20))

    z.SetIMEKey(ExtractChar(layout, 21))
    x.SetIMEKey(ExtractChar(layout, 22))
    c.SetIMEKey(ExtractChar(layout, 23))
    v.SetIMEKey(ExtractChar(layout, 24))
    b.SetIMEKey(ExtractChar(layout, 25))
    n.SetIMEKey(ExtractChar(layout, 26))
    m.SetIMEKey(ExtractChar(layout, 27))
    comma.SetIMEKey(ExtractChar(layout, 28))
    period.SetIMEKey(ExtractChar(layout, 29))
    slash.SetIMEKey(ExtractChar(layout, 30))
}

/**
 * Stores the current key layout to the specified layout.
 * @param {String} layout - The layout to store the current key layout to.
 * @param {String} num_layout - The layout to store the current number row layout to.
 */
StoreLayout(layout, num_layout := "1234567890-") {
    global k1, k2, k3, k4, k5, k6, k7, k8, k9, k0
    global minus
    global q, w, e, r, t, y, u, i, o, p
    global a, s, d, f, g, h, j, k, l, semicolon
    global b, n, m, comma, period, slash

    k1.SetKey(ExtractChar(num_layout, 1))
    k2.SetKey(ExtractChar(num_layout, 2))
    k3.SetKey(ExtractChar(num_layout, 3))
    k4.SetKey(ExtractChar(num_layout, 4))
    k5.SetKey(ExtractChar(num_layout, 5))
    k6.SetKey(ExtractChar(num_layout, 6))
    k7.SetKey(ExtractChar(num_layout, 7))
    k8.SetKey(ExtractChar(num_layout, 8))
    k9.SetKey(ExtractChar(num_layout, 9))
    k0.SetKey(ExtractChar(num_layout, 10))
    minus.SetKey(ExtractChar(num_layout, 11))

    q.SetKey(ExtractChar(layout, 1))
    w.SetKey(ExtractChar(layout, 2))
    e.SetKey(ExtractChar(layout, 3))
    r.SetKey(ExtractChar(layout, 4))
    t.SetKey(ExtractChar(layout, 5))
    y.SetKey(ExtractChar(layout, 6))
    u.SetKey(ExtractChar(layout, 7))
    i.SetKey(ExtractChar(layout, 8))
    o.SetKey(ExtractChar(layout, 9))
    p.SetKey(ExtractChar(layout, 10))

    a.SetKey(ExtractChar(layout, 11))
    s.SetKey(ExtractChar(layout, 12))
    d.SetKey(ExtractChar(layout, 13))
    f.SetKey(ExtractChar(layout, 14))
    g.SetKey(ExtractChar(layout, 15))
    h.SetKey(ExtractChar(layout, 16))
    j.SetKey(ExtractChar(layout, 17))
    k.SetKey(ExtractChar(layout, 18))
    l.SetKey(ExtractChar(layout, 19))
    semicolon.SetKey(ExtractChar(layout, 20))

    z.SetKey(ExtractChar(layout, 21))
    x.SetKey(ExtractChar(layout, 22))
    c.SetKey(ExtractChar(layout, 23))
    v.SetKey(ExtractChar(layout, 24))
    b.SetKey(ExtractChar(layout, 25))
    n.SetKey(ExtractChar(layout, 26))
    m.SetKey(ExtractChar(layout, 27))
    comma.SetKey(ExtractChar(layout, 28))
    period.SetKey(ExtractChar(layout, 29))
    slash.SetKey(ExtractChar(layout, 30))
}

/**
 * Changes the current key layout to "Oonishi Layout".
 */
ChangeOonishiLayout() {
    StoreLayout("qlu,.fwrypeiao-ktnshzxcv;gdmjb", "1234567890/")
    ResetIME()
    ShowOSD("Oonish layout")
}

/**
 * Changes the current key layout to "Colemak Layout".
 */
ChangeColemakLayout() {
    StoreLayout("qwfpgjluy;arstdhneiozxcvbkm,./")
    ResetIME()
    ShowOSD("Colemak layout")
}

/**
 * Changes layout to "FMIX12f".
 */
ChangeFMIX12f_Layout() {
    StoreLayout("qwfrkylup;asdtghneiozxcvbjm,./")
    ResetIME()
    ShowOSD("FMIX12f layout")
}

/**
 * Changes layout to "FMIX12f-FMIX13fR".
 */
ChangeFMIX12f_FMIX13fR_Layout() {
    StoreLayout("qwfrkylup;asdtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; Diffs for IME ON
    e.SetImeKey("d")
    t.SetImeKey("f")
    d.SetImeKey("k")

    ShowOSD("FMIX12f-FMIX13fR layout")
}

/**
 * Changes layout to "FMIX13f-FMIX14R".
 */
ChangeFMIX13f_FMIX14R_Layout() {
    StoreLayout("qwrfkylup;asdtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; Diffs for IME ON
    e.SetImeKey("r")
    r.SetImeKey("d")
    t.SetImeKey("l")
    d.SetImeKey("k")
    u.SetImeKey("f")

    ShowOSD("FMIX13f-FMIX14R layout")
}

/**
 * Changes layout to "FMIX14-FMIX14R".
 */
ChangeFMIX14_FMIX14R_Layout() {
    StoreLayout("qwldkylup;asrtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; Diffs for IME ON
    e.SetImeKey("r")
    t.SetImeKey("l")
    d.SetImeKey("k")

    ShowOSD("FMIX14-FMIX14R layout")
}

/**
 * Changes layout to "FMIX13f-FMIX14fR".
 */
ChangeFMIX13f_FMIX14fR_Layout() {
    StoreLayout("qwrfkylup;asdtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; Diffs for IME ON
    r.SetImeKey("d")
    t.SetImeKey("f")
    d.SetImeKey("k")

    ShowOSD("FMIX13f-FMIX14fR layout")
}

/**
 * Changes layout to "FMIX13-FMIX14R".
 */
ChangeFMIX13_FMIX14R_Layout() {
    StoreLayout("qwrlkyfup;asdtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; Diffs for IME ON
    r.SetImeKey("d")
    t.SetImeKey("l")
    d.SetImeKey("k")

    ShowOSD("FMIX13-FMIX14R layout")
}

/**
 * Changes layout to "FMIX13-FMIX14R".
 */
ChangeFMIX13_FMIX14Rfep_Layout() {
    StoreLayout("qwrlkyfup;asdtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; Diffs for IME ON
    r.SetImeKey("d")
    t.SetImeKey("l")
    d.SetImeKey("k")
    i.SetImeKey("e")
    k.SetImeKey("u")

    ShowOSD("FMIX13-FMIX14Rfep layout")
}

/**
 * Changes layout to "FMIX12-FMIX14R".
 */
ChangeFMIX12_FMIX14R_Layout() {
    StoreLayout("qwlrkyfup;asdtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; Diffs for IME ON
    e.SetImeKey("r")
    r.SetImeKey("d")
    t.SetImeKey("l")
    d.SetImeKey("k")

    ShowOSD("FMIX12-FMIX14R layout")
}

/**
 * Changes layout to "FMIX12-FMIX14R".
 */
ChangeFMIX12_FMIX13R_Layout() {
    StoreLayout("qwlrkyfup;asdtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; Diffs for IME ON
    e.SetImeKey("d")
    r.SetImeKey("r")
    t.SetImeKey("l")
    d.SetImeKey("k")

    ShowOSD("FMIX12-FMIX13R layout")
}

; ============================================================================
; HOTKEY DEFINITIONS (LAYERS)
; ============================================================================

;*** LAYER (Shifted Editing) ***
#HotIf LayerState(L_SELECT)

; --- Editing (with Shift) ---
*1:: Send("^z") ; Undo
*2:: Send("^x") ; Cut
*3:: Send("^c") ; Copy
*4:: Send("^v") ; Paste
*z:: Send("^z") ; Undo
*x:: Send("^x") ; Cut
*c:: Send("^c") ; Copy
*v:: Send("^v") ; Paste
*b:: Send("^z") ; Undo

; --- Navigation (with Shift) ---
*y:: Send(R_REDO) ; Redo (^y)
*u:: Send(C_BS)   ; Backspace
*i:: Send("+{Up}")   ; Shift+Up
*o:: Send("+{PgUp}") ; Shift+PgUp
*p:: Send("+{PgDn}") ; Shift+PgDn
*@:: Send(C_CSHOME) ; Ctrl+Shift+Home
*[:: Send(C_CSEND)  ; Ctrl+Shift+End

*h:: Send("+{Home}")  ; Shift+Home
*j:: Send("+{Left}")  ; Shift+Left
*k:: Send("+{Down}")  ; Shift+Down
*l:: Send("+{Right}") ; Shift+Right
*sc027:: Send("+{Enter}") ; Semicolon (;) -> Shift+Enter
*Enter:: Send(B_ENTER)
*n:: Send("+{End}")   ; Shift+End
*m:: Send(C_DEL)    ; Delete
*sc033:: Send("^+{Left}") ; Comma (,) -> Ctrl+Shift+Left
*.:: Send("^+{Right}") ; Period (.)

*space:: Send(C_BS) ; Space -> Backspace

*up:: Send("+{Up}")
*left:: Send("+{Left}")
*down:: Send("+{Down}")
*right:: Send("+{Right}")
#HotIf

;*** LAYER (System/App Control) ***
#HotIf LayerState(L_NAVL_CTRL)

*1:: Send(B_F1)
*2:: Send(B_F2)
*3:: Send(B_F3)
*4:: Send(B_F4)
*5:: Send(B_F5)
*6:: Send(B_F6)
*7:: Send(B_F7)
*8:: Send(B_F8)
*9:: Send(B_F9)
*0:: Send(B_F10)
*-:: Send(B_F11)
*sc00D:: Send(B_F12) ; ^ -> F12

sc07D:: Send("^+{sc07D}") ; \ -> |

*z:: Send(B_UNDO)  ; Undo
*x:: Send(B_CUT)   ; Cut
*c:: Send(B_COPY)  ; Copy
*v:: Send(B_PASTE) ; Paste
*b:: Send(B_UNDO)  ; Undo

; --- Editing & Navigation (no Shift) ---
*y:: Send(B_UNDO)  ; Undo (^z)
*u:: Send(B_BS)    ; Backspace
*i:: Send(B_UP)    ; Up
*o:: Send(B_PGUP)  ; PgUp
*p:: Send(B_PGDN)  ; PgDn
*@:: Send(B_CHOME) ; Ctrl+Home
*[:: Send(B_CEND)  ; Ctrl+End

*h:: Send(B_HOME)  ; Home
*j:: Send(B_LEFT)  ; Left
*k:: Send(B_DOWN)  ; Down
*l:: Send(B_RIGHT) ; Right
*sc027:: Send(B_ENTER) ; Semicolon (;) -> Enter
;sc028::Return ; Colon (:) -> Disabled
*]:: Send("+^\")

*n:: Send(B_END)   ; End
*m:: Send(B_DEL)   ; Delete
*sc033:: Send(B_CLEFT) ; Comma (,) -> Ctrl+Left
*.:: Send(B_CRIGHT) ; Period (.) -> Ctrl+Right
sc035:: Send("^+{sc07D}") ; / -> |

*Enter:: Send("{Blind}^{Enter}") ; Enter -> Ctrl+Enter

*a:: Send("{Blind}^a") ; Select All
sc029:: Send(C_EISU) ; Zen/Han -> Eisu
+sc029:: ToggleForceImeOn() ; Shift+Zen/Han -> Toggle Force IME ON
Esc:: Reload ; Esc -> Reload Script

q::#!space ; Win+Alt+Space
*e:: Send(B_ESC) ; Esc
r::+F3 ; Shift+F3
*s:: Send("{Blind}^s") ; Save
*d:: Send("{Blind}^{Space}") ; Ctrl+Space (IME toggle, etc.)
*f:: Send(B_TAB) ; Tab
g:: Send("^f") ; Find

; --- IME Toggles while M1 is held ---
F14:: ToggleImeState() ; F14/Enter
sc079:: ToggleImeState() ; Convert
space:: ToggleImeState() ;Send(C_BS)

; --- Layout Switching ---
#r:: ChangeFMIX14_FMIX14R_Layout()
#f:: ChangeFMIX12f_FMIX13fR_Layout()
#d:: ChangeFMIX12f_Layout()
#s:: ChangeFMIX13_FMIX14R_Layout()
#e:: ChangeFMIX13_FMIX14Rfep_Layout()
#v:: ChangeFMIX13f_FMIX14R_Layout()
#z:: ChangeFMIX12_FMIX14R_Layout()
#x:: ChangeFMIX12_FMIX13R_Layout()

#o:: ChangeOonishiLayout()
#c:: ChangeColemakLayout()

; --- Mouse Speed ---
#up:: MouseSpeed.IncSpeed() ; Win+Up
#down:: MouseSpeed.DecSpeed() ; Win+Down
#HotIf

;*** LAYER2 (Symbols and Num ) ***
#HotIf LayerState(L_SYMBOL_NUM)
*1:: Send(B_F1)
*2:: Send(B_F2)
*3:: Send(B_F3)
*4:: Send(B_F4)
*5:: Send(B_F5)
*6:: Send(B_F6)
*7:: Send(B_F7)
*8:: Send(B_F8)
*9:: Send(B_F9)
*0:: Send(B_F10)
*-:: Send(B_F11)
*sc00D:: Send(B_F12) ; ^ -> F12

q:: Send("?")
*w:: Send("{Blind}/")
*e:: Send(B_NMUL) ; Numpad *
*r:: Send(B_NADD) ; Numpad +
t::+F3

*a:: Send("(")
*s:: Send(")")
*d:: Send("_")
*f:: Send("{Blind}-")
g:: Send("=")

y:: Send(B_BS)
u:: Send(C_N7)
i:: Send(C_N8)
o:: Send(C_N9)
p:: Send("+^p")

h:: Send("=")
j:: Send(C_N0)
k:: Send(C_N1)
l:: Send(C_N2)
sc027:: Send(B_ENTER)

n:: Send("+3")
m:: Send(C_N3)
sc033:: Send(C_N4)
.:: Send(C_N5)
sc035:: Send(C_N6)

z:: Send("+[")
x:: Send("+]")
c:: Send("[")
v:: Send("]")
b:: Send(C_BACKSLASH)  ; Undo

*space:: Send(B_BS)

#HotIf

;*** LAYER (Symbols) ***
#HotIf LayerState(L_SYMBOL1)
*1:: Send(B_F1)
*2:: Send(B_F2)
*3:: Send(B_F3)
*4:: Send(B_F4)
*5:: Send(B_F5)
*6:: Send(B_F6)
*7:: Send(B_F7)
*8:: Send(B_F8)
*9:: Send(B_F9)
*0:: Send(B_F10)
*-:: Send(B_F11)
*sc00D:: Send(B_F12) ; ^ -> F12

q:: Send("?")
*w:: Send("{Blind}/")
*e:: Send(B_NMUL) ; Numpad *
*r:: Send(B_NADD) ; Numpad +
t::+F3

*a:: Send("(")
*s:: Send(")")
*d:: Send("_")
*f:: Send("{Blind}-")
g:: Send("=")

y:: Send(B_BS)
u:: Send(C_N7)
i:: Send(C_N8)
o:: Send(C_N9)
p:: Send("+^p")

h:: Send("=")
j:: Send(C_N0)
k:: Send(C_N1)
l:: Send(C_N2)
sc027:: Send(B_ENTER)

n:: Send("+3")
m:: Send(C_N3)
sc033:: Send(C_N4)
.:: Send(C_N5)
sc035:: Send(C_N6)

z:: Send("+[")
x:: Send("+]")
c:: Send("[")
v:: Send("]")
b:: Send(C_BACKSLASH)  ; Undo

space:: Send(C_BS)
#HotIf

;*** LAYER  (Numpad Layer) ***
#HotIf LayerState(L_NUMPAD)
; --- Left Hand ---
6:: Send("{Escape}")
t:: Send(B_NADD) ; Numpad +
a:: Send("(")
s:: Send(")")
f:: Send("-")
g:: Send("=")

; --- Right Hand (Numpad) ---
7:: Send(C_N7)
8:: Send(C_N8)
9:: Send(C_N9)
0:: Send(B_NMUL) ; Numpad *
-:: Send(B_NSUB) ; Numpad -
sc00D:: Send(C_HAT) ; ^
sc07D:: Send("\") ; \

y:: Send(C_BS) ; Backspace
u:: Send(C_N4)
i:: Send(C_N5)
o:: Send(C_N6)
p:: Send(B_NADD) ; Numpad +
@:: Send(B_UP)   ; Up

h:: Send("=")
j:: Send(C_N1)
k:: Send(C_N2)
l:: Send(C_N3)
sc027:: Send(B_LEFT)  ; ; -> Left
sc028:: Send(B_DOWN)  ; : -> Down
]:: Send(B_RIGHT) ; ] -> Right

n:: Send(C_DEL) ; Delete
m:: Send(C_N0)
sc033:: Send(C_COMMA) ; ,
.:: Send(C_NDOT)  ; . -> Numpad .
sc035:: Send(B_NDIV) ; / -> Numpad /
sc073:: Send("\") ; _

space:: Send(C_BS)
#HotIf

#HotIf LayerState(L_SYMBOL2)
q:: Send("+1")
w:: Send("+2")
e:: Send("+3")
r:: Send("+4")
t:: Send("~")

a:: Send("+5") ;
s:: Send("+6") ;
d:: Send("+7") ;
f:: Send(C_HAT) ; ^
g:: Send("+@") ;

x:: Send("@")
c:: Send(":")
v:: Send("|") ; |
b:: Send("\") ; \
#HotIf

#HotIf LayerState(L_FUNC)
q:: Send(B_F1)
w:: Send(B_F2)
e:: Send(B_F3)
r:: Send(B_F4)

a:: Send(B_F5)
s:: Send(B_F6)
d:: Send(B_F7)
f:: Send(B_F8)

z:: Send(B_F9)
x:: Send(B_F10)
c:: Send(B_F11)
v:: Send(B_F12)
#HotIf

#HotIf LayerState(L_SHIFT)
; 1::k1.SendShiftedKey()
; 2::k2.SendShiftedKey()
; 3::k3.SendShiftedKey()
; 4::k4.SendShiftedKey()
; 5::k5.SendShiftedKey()

*1:: Send(B_F1)
*2:: Send(B_F2)
*3:: Send(B_F3)
*4:: Send(B_F4)
*5:: Send(B_F5)

q:: q.SendShiftedKey()
w:: w.SendShiftedKey()
e:: e.SendShiftedKey()
r:: r.SendShiftedKey()
t:: t.SendShiftedKey()

a:: a.SendShiftedKey()
s:: s.SendShiftedKey()
d:: d.SendShiftedKey()
f:: f.SendShiftedKey()
g:: g.SendShiftedKey()

z:: z.SendShiftedKey()
x:: x.SendShiftedKey()
c:: c.SendShiftedKey()
v:: v.SendShiftedKey()
b:: b.SendShiftedKey()

; 6::k6.SendShiftedKey()
; 7::k7.SendShiftedKey()
; 8::k8.SendShiftedKey()
; 9::k9.SendShiftedKey()
; -::minus.SendShiftedKey()
; sc00D::hat.SendShiftedKey()
sc07D:: backslash.SendShiftedKey()

*6:: Send(B_F6)
*7:: Send(B_F7)
*8:: Send(B_F8)
*9:: Send(B_F9)
*0:: Send(B_F10)
*-:: Send(B_F11)
*sc00D:: Send(B_F12) ; ^ -> F12

y:: y.SendShiftedKey()
u:: u.SendShiftedKey()
i:: i.SendShiftedKey()
o:: o.SendShiftedKey()
p:: p.SendShiftedKey()
@:: at.SendShiftedKey()
[:: openbracket.SendShiftedKey()

h:: h.SendShiftedKey()
j:: j.SendShiftedKey()
k:: k.SendShiftedKey()
l:: l.SendShiftedKey()
sc027:: semicolon.SendShiftedKey()
sc028::+sc028 ; : -> * (Not using RKey object)
]::+]         ; ] -> } (Not using RKey object)

n:: n.SendShiftedKey()
m:: m.SendShiftedKey()
sc033:: comma.SendShiftedKey()
.:: period.SendShiftedKey()
sc035:: slash.SendShiftedKey()
sc073:: backslash2.SendShiftedKey()
Up:: up.SendShiftedKey()
Down:: down.SendShiftedKey()
Left:: left.SendShiftedKey()
Right:: right.SendShiftedKey()

#HotIf

; ============================================================================
; GLOBAL HOTKEYS (RKey / LKey Bindings)
; ============================================================================
; These hotkeys are active when no layers are pressed.
; They call the Down() and Up() methods of their respective RKey/LKey objects
; to handle remapping, modifier passthrough, and long-press logic.

*1:: k1.Down("1")
*1 up:: k1.Up()
*2:: k2.Down("2")
*2 up:: k2.Up()
*3:: k3.Down("3")
*3 up:: k3.Up()
*4:: k4.Down("4")
*4 up:: k4.Up()
*5:: k5.Down("5")
*5 up:: k5.Up()

*6:: k6.Down("6")
*6 up:: k6.Up()
*7:: k7.Down("7")
*7 up:: k7.Up()
*8:: k8.Down("8")
*8 up:: k8.Up()
*9:: k9.Down("9")
*9 up:: k9.Up()
*0:: k0.Down("0")
*0 up:: k0.Up()
*-:: minus.Down("-")
*- up:: minus.Up()
*sc00D:: hat.Down("{sc00D}") ; ^
*sc00D up:: hat.Up()
*sc07D:: backslash.Down("{sc07D}") ; ¥
*sc07D up:: backslash.Up()

*q:: q.Down("q")
*q up:: q.Up()
*w:: w.Down("w")
*w up:: w.Up()
*e:: e.Down("e")
*e up:: e.Up()
*r:: r.Down("r")
*r up:: r.Up()
*t:: t.Down("t")
*t up:: t.Up()

*y:: y.Down("y")
*y up:: y.Up()
*u:: u.Down("u")
*u up:: u.Up()
*i:: i.Down("i")
*i up:: i.Up()
*o:: o.Down("o")
*o up:: o.Up()
*p:: p.Down("p")
*p up:: p.Up()
*@:: at.Down("@")
*@ up:: at.Up()
*[:: openbracket.Down("[")
*[ up:: openbracket.Up()

*a:: a.Down("a")
*a up:: a.Up()
*s:: s.Down("s")
*s up:: s.Up()
*d:: d.Down("d")
*d up:: d.Up()
*f:: f.Down("f")
*f up:: f.Up()
*g:: g.Down("g")
*g up:: g.Up()

*h:: h.Down("h")
*h up:: h.Up()
*j:: j.Down("j")
*j up:: j.Up()
*k:: k.Down("k")
*k up:: k.Up()
*l:: l.Down("l")
*l up:: l.Up()

*sc027:: semicolon.Down("sc027")
*sc027 up:: semicolon.Up()
*sc028:: colon.Down("sc028")
*sc028 up:: colon.Up()
*]:: closebracket.Down("]")
*] up:: closebracket.Up()

*z:: z.Down("z")
*z up:: z.Up()
*x:: x.Down("x")
*x up:: x.Up()
*c:: c.Down("c")
*c up:: c.Up()
*v:: v.Down("v")
*v up:: v.Up()
*b:: b.Down("b")
*b up:: b.Up()
*n:: n.Down("n")
*n up:: n.Up()
*m:: m.Down("m")
*m up:: m.Up()
*sc033:: comma.Down("sc033") ; ,
*sc033 up:: comma.Up()
*.:: period.Down(".")        ; .
*. up:: period.Up()

*sc035:: slash.Down("sc035") ; /
*sc035 up:: slash.Up()
*sc073:: backslash2.Down("sc073") ; _
*sc073 up:: backslash2.Up()

; (Refactored: Added bindings for arrow RKey objects)
*Down:: down.Down("Down")
*Down up:: down.Up()
*Up:: up.Down("Up")
*Up up:: up.Up()
*Left:: left.Down("Left")
*Left up:: left.Up()
*Right:: right.Down("Right")
*Right up:: right.Up()

#Hotif ; End context-sensitive hotkeys

; ============================================================================
; GLOBAL HOTKEYS (MKey Bindings)
; ============================================================================
; These hotkeys are always active and bind the physical keys
; to their MKey (modifier) objects.

*Space:: space.Down()
*Space up:: space.Up()

*tab:: tab.Down()
*tab up:: tab.Up()

*F13:: f13.Down()
*F13 up:: f13.Up()

*F14:: f14.Down()
*F14 up:: f14.Up()

*sc079:: conv.Down() ; Convert key
*sc079 up:: conv.Up()

*sc07B:: noconv.Down() ; Noconvert key
*sc07B up:: noconv.Up()

; ============================================================================
; MISCELLANEOUS GLOBAL HOTKEYS
; ============================================================================

;NumLock::Return ; Disable NumLock key
+F15:: Send("{NumLock}") ; Shift+F15 sends NumLock
;*F15::Send("{NumLock}")

>+Up::_ ; RShift+Up -> _

; Fix for CapsLock state
^+F13:: Send("+{CapsLock}")

; Standard IME Toggles (Zenkaku/Hankaku key)
+sc029:: Send(C_EISU) ; Shift + Zen/Han -> Eisu
sc029:: ToggleImeState() ; Zen/Han -> Toggle IME

; --- Suspend Hotkey ---
#SuspendExempt ; Allow suspend hotkey to work even if suspended
#!Enter:: Suspend ; Win+Alt+Enter toggles script suspend
#SuspendExempt False

#MaxThreadsBuffer False