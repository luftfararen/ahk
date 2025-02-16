#Requires AutoHotkey v2.0

;Modifier symbol
;win #   ctrl ^   shift +   alt !

;used directly
;- ^ ¥ @ [ ] . /

;used with {}
;Space Tab Enter BS Del Ins Left  Right Up Down Home End PgUp PgDn Esc Pause PrintScreen

;vk1Dsc07B = NoConvert 無変換
S_NOCONV := "sc07B" 
C_NOCONV := "{sc07B}" 

;vk1Csc079 = Convert 変換
S_CONV := "sc079" 
C_CONV := "{sc079}" 

;sc07D = \; shift:|
;S_BACKSLASH := "sc07D" 
C_BACKSLASH := "{sc07D}"
B_BACKSLASH := "{Blind}{sc07D}"

;vkE2sc073 = \ shift:_
;S_BACKSLASH2 := "sc073"
C_BACKSLASH2 := "{sc073}" 

;sc00D =^
;S_HAT := "sc00D"
C_HAT := "{sc00D}"

;vkBBsc027 = ; shift:+
;S_SEMICOLON := "sc027" 
C_SEMICOLON := "{sc027}" 
B_SEMICOLON := "{Blind}{sc027}" 
C_PLUS := "+{sc027}" 

;vkBAsc028 = : shift:*
;S_COLON := "sc028"
C_COLON := "{sc028}"
B_COLON := "{Blind}{sc028}"
C_ASTERISK := "+{sc028}"

;vkBCsc033 = ,
;S_COMMA := "sc033"
C_COMMA := "{sc033}"

;vkF0sc03A = Eisu
S_EISU := "sc03A"
C_EISU := "{sc03A}"

;vkF2sc070 = Hiragana(ひらがな/カタカナ) It is unstable to assign other key to this key.
S_HIRAGANA := "sc070"
C_HIRAGANA := "{sc070}"

;vkF3sc029 = 全角/半角 must be sent. Replace does not work.
;vkF4sc029 = 全角/半角 must be sent
S_ZENKAKU := "sc029" 
C_ZENKAKU := "{sc029}" 
B_ZENKAKU := "{Blind}{sc029}"

;S_SLASH := "sc035"
C_SLASH := "{sc035}"
B_SLASH := "{Blind}{sc035}"

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

B_NADD := "{Blind}{NumpadAdd}"
B_NMUL := "{Blind}{NumpadMult}"
B_NSUB := "{Blind}{NumpadSub}"
B_NDIV := "{Blind}{NumpadDiv}"

C_DEL   := "{Delete}"
B_DEL   := "{Blind}{Delete}"

C_BS    := "{Backspace}"
B_BS    := "{Blind}{Backspace}"

C_REDO := "^y"

B_SPACE   := "{Blind}{Space}"
B_ESC   := "{Blind}{Esc}"
B_TAB   := "{Blind}{Tab}"
B_UNDO  := "{Blind}^{z}"
B_CUT   := "{Blind}^{x}"
B_COPY  := "{Blind}^{c}"
B_PASTE := "{Blind}^{v}"
B_ENTER := "{Blind}{Enter}"
B_HOME  := "{Blind}{Home}"
B_END   := "{Blind}{End}"
B_PGUP  := "{Blind}{PgUp}"
B_PGDN  := "{Blind}{PgDn}"
B_CHOME := "{Blind}^{Home}"
B_CEND  := "{Blind}^{End}"
B_CPGUP := "{Blind}^{PgUp}"
B_CPGDN := "{Blind}^{PgDn}"

B_LEFT := "{Blind}{Left}"
B_RIGHT := "{Blind}{Right}"
B_UP := "{Blind}{Up}"
B_DOWN := "{Blind}{Down}"
B_CLEFT := "{Blind}^{Left}"
B_CRIGHT := "{Blind}^{Right}"

;SingleInstkance Force
ProcessSetPriority "Realtime"
SendMode "Input"

InstallKeybdHook true
InstallMouseHook true
#UseHook true
#MaxThreadsBuffer True
;#MaxThreadsPerHotkey 3 ;If enabled, it's unstable.
SetKeyDelay 0

last_ime_hwnd := 0
last_active_hwnd := 0
SearchWindowsToGetImeState(root,parent) 
{
	global last_ime_hwnd,last_active_hwnd
	hwnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Uint",parent)
	if DllCall("SendMessage", "UInt", hwnd,
	   	"UInt", 0x0283,  "Int", 0x0005,  "Int", 0) {
			last_active_hwnd := root
			last_ime_hwnd := hwnd
	 		return true
	}
    for child in WinGetControlsHwnd(parent) {
        if SearchWindowsToGetImeState(root,child){
			return true
		}
    }
	return false
}

IsImeOn()
{
	global last_ime_hwnd,last_active_hwnd
	hwnd := WinActive("A")
	if hwnd = last_active_hwnd {
		return DllCall("SendMessage", "UInt", last_ime_hwnd,
		"UInt", 0x0283,  "Int", 0x0005,  "Int", 0) 
	}else{
		last_active_hwnd := 0
		return SearchWindowsToGetImeState(hwnd,hwnd)
	}
}

SendAccImeState(key_ime_off,key_ime_on:="")
{
	if IsImeOn() && key_ime_on != ""{
		Send(key_ime_on)
	}else{
		Send(key_ime_off)
	}
}

; Not inspected yet
; IsDisplayCode(key)
; {
; 	code := 0
; 	sc_pos := InStr(key,"sc")
; 	if sc_pos > 0 {
; 		num := "0x" . SubStr(key,sc_pos+2,3)
; 		;ToolTip key . IsNumber(num)
; 		code := Integer(num)

; 		if code = 0x0e{ ;Backspace
; 			return false
; 		}
; 		if code = 0x0f{ ;Tab
; 			return false
; 		}
; 		if code = 0x1c{ ;Enter
; 			return false
; 		}
; 		if code = 0x1d{ ; Left Ctrl
; 			return false
; 		}
; 		;1234567890-^ QWERTYUIOP@[ ASDFGHJKL;:
; 		if 0x02 <= code and code <= 0x28{
; 			return true 
; 		}
; 		;],z-/
; 		if 0x2b <= code and code <= 0x35{
; 			return true
; 		}
; 		;\(|) \(_) 
; 		if code = 0x7d or code = 0x73{
; 			return true
; 		}
; 		return false
; 	}else{
; 		code := Ord(key)
; 		if 0x21 <= code and code <= 0x7e{
; 			return true 
; 		}
; 		return false
; 	}
; }

/*============================================================================
Class to ctrl mouse speed.
============================================================================*/
class MouseSpeed
{
	static SPI_GETMOUSESPEED := 0x70e
	static SPI_SETMOUSESPEED := 0x71
	static DefMouseSpeed := 10
/*============================================================================
	Gets system mouse speed.
============================================================================*/
	static	GetSpeed()
	{
		val:=0
		DllCall("SystemParametersInfo", "UInt", MouseSpeed.SPI_GETMOUSESPEED, "UInt", 0, "Ptr*", &val, "UInt", 0)
		return val
	}

/*============================================================================
	Sets system mouse speed.
============================================================================*/
	static SetSpeed(val)
	{
		if val < 1{
			val := 1
		}else if val > 20{
			val := 20
		}
		DllCall("SystemParametersInfo", "UInt", MouseSpeed.SPI_SETMOUSESPEED, "UInt", 0, "Ptr", val, "UInt", 0)
		ToolTip("MouseSpeed: " . val)
		SetTimer(ToolTip,3000)
		return val
	}

/*============================================================================
	Increase mouse speed value.
============================================================================*/
	static IncSpeed()
	{
		v := MouseSpeed.GetSpeed()
		if v = 0{
			return
		}
		MouseSpeed.SetSpeed(v+1)
	}
/*============================================================================
	Decrease mouse speed value.
============================================================================*/
	static DecSpeed()
	{
		v := MouseSpeed.GetSpeed()
		if v = 0{
			return
		}
		MouseSpeed.SetSpeed(v-1)
	}

/*============================================================================
	Use it if chaing mouse speed temporally.
	Stores system mouse speed to default value then makes system mouse speed slow.
============================================================================*/
	static MakeSlow()
	{
		val:=0
		DllCall("SystemParametersInfo", "UInt", MouseSpeed.SPI_GETMOUSESPEED, "UInt", 0, "Ptr*", &val, "UInt", 0)
		if val > 1{
			MouseSpeed.DefMouseSpeed := val
		}
		DllCall("SystemParametersInfo", "UInt", MouseSpeed.SPI_SETMOUSESPEED, "UInt", 0, "Ptr", 1, "UInt", 0)
	}

/*============================================================================
	Resets system mouse speed to default value.
============================================================================*/
	static Reset()
	{
		DllCall("SystemParametersInfo", "UInt", MouseSpeed.SPI_SETMOUSESPEED, "UInt", 0, "Ptr", MouseSpeed.DefMouseSpeed , "UInt", 0)
	}

/*============================================================================
	Increase default mouse speed value, this value is reflected after calling Reset().
============================================================================*/
	static IncDefSpeed()
	{
		temp := MouseSpeed.DefMouseSpeed + 1
		if temp > 20 {
			temp := 20
		}
		MouseSpeed.DefMouseSpeed := temp *2
		ToolTip("MouseSpeed: " . MouseSpeed.DefMouseSpeed)
		SetTimer(ToolTip,3000)
	}

/*============================================================================
	Decrease default mouse speed value, this value is reflected after calling Reset().
============================================================================*/
	static DecDefSpeed()
	{
		temp := MouseSpeed.DefMouseSpeed - 1
		if temp < 1 {
			temp := 1
		}
		MouseSpeed.DefMouseSpeed := temp
		ToolTip("MouseSpeed: " . MouseSpeed.DefMouseSpeed)
		SetTimer(ToolTip,3000)
	}
	
}
/*============================================================================
	Moves mouse position supporting for second screen.
============================================================================*/
MoveMousePos(rx, ry)
{
  size := 4
  point := Buffer(size * 2)
  DllCall("GetCursorPos", "Ptr", point)
  x := NumGet(point, 0, "Int")
  y := NumGet(point, size, "Int")
  DllCall("SetCursorPos", "Int", x+rx, "Int", y+ry)
} 

/*============================================================================
	Parses mouse command string and sends command
	cmd: command stinrg
	shift: 1 or 0 if this value is 1, mouse move is fast
	ctrl: 1 or 0 if this value is 1, mouse move is slow
============================================================================*/
OperateMouse(cmd)
{
	static mouse_move := A_ScreenWidth/160
	static mouse_move_short := A_ScreenWidth/320
	static mouse_move_long := A_ScreenWidth/8
	if cmd = ""{
		return false
	} else if cmd ="MouseLClick" {
		MouseClick("left")
		return true
	} else if cmd = "MouseRClick"{
		MouseClick("right")
		return true
	} else if cmd = "MouseWheelUp"{
		Send("{WheelUp}")
		return true
	} else if cmd = "MouseWheelDown"{
		Send("{WheelDown}") 
		return true
	} else if cmd = "MouseBack"{
		Send("!{Left}")
		return true
	} else if cmd = "MouseNext"{
		Send("!{Right}")
		return true
	}else{
		shift := GetKeyState("Shift","P")
		ctrl := GetKeyState("Ctrl","P")
;		alt := GetKeyState("Alt","P")
;		win := GetKeyState("LWin","P") || GetKeyState("RWin","P")
		if shift != 0 {
			m := mouse_move_short
		} else if ctrl != 0{
			m := mouse_move_long
		}else{
			m := mouse_move
		}
		if cmd = "MouseUp"{
			MoveMousePos(0,-m)
			return true
		} else if cmd = "MouseLeft"{
			MoveMousePos(-m,0)
			return true
		} else if cmd = "MouseDown"{
			MoveMousePos(0,m) 
			return true
		} else if cmd = "MouseRight"{
			MoveMousePos(m,0) 
			return true
		}
		return false
	}
}

/*============================================================================
Class to change layer.
============================================================================*/
class LayerKey
{
	static NUM_MODE 	:= 1
	static MOUSE_MODE 	:= 2
	static CUR_MODE 	:= 3
	static SEL_MODE 	:= 4
	static CTRL_MODE 	:= 5
	static ALT_MODE 	:= 6
	static SHIFT_MODE 	:= 7
	static WIN_MODE 	:= 8
	static TWO_STROKE0 	:= 9
	static TWO_STROKE1 	:= 10
	static TWO_STROKE2 	:= 11
	static FUNC_MODE 	:= 12

	static idx := 0

/*============================================================================
	Changes layer(mode)
	num: mode number	
============================================================================*/
	static ChangeLayer(num)
	{
		if LayerKey.idx != num{
			LayerKey.idx := num
			if LayerKey.idx = 0{
				;ToolTip("Normal Mode",A_ScreenWidth,A_ScreenHeight)
				;SetTimer(ToolTip,3000)
				ToolTip
			}else if LayerKey.idx = LayerKey.NUM_MODE{
				ToolTip("10 key Mode",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = LayerKey.MOUSE_MODE{
				ToolTip("Mouse Mode",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = LayerKey.CUR_MODE{
				ToolTip("Cursor Mode",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = LayerKey.SEL_MODE{
				ToolTip("Select Mode",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = LayerKey.CTRL_MODE {
				ToolTip("Ctrl Lock",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = LayerKey.ALT_MODE {
				ToolTip("Alt Lock",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = LayerKey.SHIFT_MODE {
				ToolTip("Shift Lock",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = LayerKey.WIN_MODE {
				ToolTip("Win Lock",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = LayerKey.FUNC_MODE {
				ToolTip("Func Mode",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = LayerKey.TWO_STROKE0 {
				ToolTip("Two Stroke Mode",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = LayerKey.TWO_STROKE1 {
				ToolTip("Two Stroke Mode(Press 2 keys)",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = LayerKey.TWO_STROKE2 {
			;	ToolTip("Two Stroke(2/2)",A_ScreenWidth,A_ScreenHeight)
			}
		}
	}

/*============================================================================
	Is command string for changing layer or not 
============================================================================*/
	static IsCmd(str)
	{
		if InStr(str,"ChangeLayer:") = 1{
			return true
		}
		if InStr(str,"Toggle") = 1{
			return true
		}
		return false
	}

/*============================================================================
	Parses command string and chages layer
	str: 		command string
	return: 	true: str is command and changes layer.
===========================================================================*/
	static ParseAndChange(str)
	{
		if InStr(str,"ChangeLayer:") = 1{
			i := Integer(SubStr(str,13,1))
			LayerKey.ChangeLayer(i)
			return true
		}
		if InStr(str,"Toggle") = 1{
			if LayerKey.idx = LayerKey.SEL_MODE {
				LayerKey.ChangeLayer(LayerKey.CUR_MODE)
			}else{
				LayerKey.ChangeLayer(LayerKey.SEL_MODE)
			}
			return true
		}
		if InStr(str,"RotateLockMode") = 1{
			LayerKey.RotateLockMode()
			return true
		}
		return false
	}

	static RotateLockMode()
	{
		if LayerKey.idx = LayerKey.CTRL_MODE {
			LayerKey.ChangeLayer(LayerKey.WIN_MODE)
		}else if LayerKey.idx = LayerKey.WIN_MODE {
			LayerKey.ChangeLayer(LayerKey.ALT_MODE)
		}else if LayerKey.idx = LayerKey.ALT_MODE {
			LayerKey.ChangeLayer(LayerKey.SHIFT_MODE)
		}else if LayerKey.idx = LayerKey.SHIFT_MODE {
			LayerKey.ChangeLayer(LayerKey.CTRL_MODE)
		}else{
			LayerKey.ChangeLayer(LayerKey.CTRL_MODE)
		}
	}

/*============================================================================
	Sends key code with modifier in each lock mode.
	key: 		base key.
	return: 	true: modifed key is sent
===========================================================================*/
	static SendModifiedKey(key,shift_key_str)
	{
		if LayerKey.idx = LayerKey.CTRL_MODE {
			Send("{Blind}^{" . key . "}")
			LayerKey.ChangeLayer(0)
			return true
		}
		if LayerKey.idx = LayerKey.ALT_MODE {
			Send("{Blind}!{" . key . "}")
			LayerKey.ChangeLayer(0)
			return true
		}
		if LayerKey.idx = LayerKey.SHIFT_MODE {
			Send(shift_key_str)
			LayerKey.ChangeLayer(0)
			return true
		}
		if LayerKey.idx = LayerKey.WIN_MODE {
			Send("{Blind}#{" . key . "}")
			LayerKey.ChangeLayer(0)
			return true
		}
		if LayerKey.idx = LayerKey.TWO_STROKE1 {
			Send("^{" . key . "}")
			LayerKey.ChangeLayer(LayerKey.TWO_STROKE2)
			ToolTip("Stroke Mode(Ctrl + " . key . ")" ,A_ScreenWidth,A_ScreenHeight)
			return true
		}
		if LayerKey.idx = LayerKey.TWO_STROKE2 {
			Send("^{" . key . "}")
			LayerKey.ChangeLayer(0)
			return true
		}
		return false
	}

	static StrokeMode()
	{
		if LayerKey.idx = LayerKey.TWO_STROKE0{
			LayerKey.ChangeLayer(LayerKey.TWO_STROKE1)
		}else if LayerKey.idx != LayerKey.TWO_STROKE1{
			LayerKey.ChangeLayer(LayerKey.TWO_STROKE0)
		}
	}

} ;class LayerKey


/*============================================================================
Class to assign different key for long press.
============================================================================*/
class RKey
{
	static use_registered_key_for_ctrl  := false ;for ctrl or alt

/*============================================================================
	key: 		base key, if it is speial key, "{}" is needed.
	long_key: 	long pressed key, which inclueds "{}". 
				If blank, shifted key is generated automatically. If "none", does nothing.  
============================================================================*/
	__New(key, shift_key:="")
	{
		this.SetKey(key,shift_key)
		this.short_ime_key_str := "" 
		this.shift_ime_key_str := ""
	}

/*============================================================================
	key: 		base key.
	shift_key: 	shift key, which inclueds "{}". 
				If blank, shifted key is generated automatically.
============================================================================*/
	SetKey(key, shift_key:="")
	{
		this.key := key
		len := Strlen(key)
		if SubStr(key,1,1) = "{" ||  len = 1 {
			this.short_key_str := "{Blind}" .  key 
			if shift_key = ""{
				this.shift_key_str :=  "+" . key
			}else{
				this.shift_key_str :=  shift_key 
			}
		}else{
			this.short_key_str := key 
			this.shift_key_str :=  "" 
		}
	}
	
/*============================================================================
	key: 		base key when ime is on.
	shift_key: 	shift key, which inclueds "{}". 
				If blank, shifted key is generated automatically.
============================================================================*/
	SetImeKey(key := "", shift_key:="")
	{
		len := Strlen(key)
		if SubStr(key,1,1) = "{" ||  len = 1 {
			this.short_ime_key_str := "{Blind}" .  key 
			if shift_key = ""{
				this.shift_ime_key_str :=  "+" . key
			}else{
				this.shift_ime_key_str :=  shift_key 
			}
		}else{
			this.short_ime_key_str := key 
			this.shift_ime_key_str :=  "" 
		}
	}

	
	SendShiftedKey(shift := true)
	{
		if  shift  {
			if IsImeOn() && this.shift_ime_key_str != "" {
				Send(this.shift_ime_key_str )
			}else{
				Send(this.shift_key_str )
			}
			return true
		}else{ 
			if IsImeOn() && this.short_ime_key_str != ""{
				Send(this.short_ime_key_str)
			}else{
				Send(this.short_key_str) ;Sends key in blind mode
			}
			return false
		}
	}

	;Sends registered shift key when pressing only shift key.
	SendModKey(pressed_key)
	{
		shift := GetKeyState("Shift","P")
		;ctrl := GetKeyState("Ctrl","P")
		;alt := GetKeyState("Alt","P")
		;win := GetKeyState("LWin","P") || GetKeyState("RWin","P")
		caw := GetKeyState("Ctrl","P") || GetKeyState("Alt","P") ||
			GetKeyState("LWin","P") || GetKeyState("RWin","P")
		; if !(shift || caw) {
		; } ;else this.pressed_time  := 0 ;skip up method()
		
		if caw {
			Send("{Blind}" . pressed_key . "}")
			;ToolTip pressed_key
			return true
		}
		this.SendShiftedKey(shift) ;Sends key in blind mode
	}

/*============================================================================
	Assign this method to the hotkey as same as registered.  
	ex)
	x := LongPressKey("x")
	x::x.Down("x")
	x::x.Up()
============================================================================*/
	Down(pressed_key := "")
	{
		if RKey.use_registered_key_for_ctrl ||  pressed_key = ""{
			pressed_key := this.key
		}
		this.SendModKey(pressed_key)
	}

/*============================================================================
	Assign this method to the hotkey as same as registered.  
============================================================================*/
	Up()
	{
	}
} ;class RKey


/*============================================================================
Class to assign different key for long press.
============================================================================*/
class LongPressKey extends RKey
{
	static long_press_th := 300 ;if pressing for more this time, long press process runs in Up()
	static last_key := ""
	static long_press_enabled  := true

/*============================================================================
	key: 		base key, if it is speial key, "{}" is needed.
	long_key: 	long pressed key, which inclueds "{}". 
				If blank, shifted key is generated automatically. If "none", does nothing.  
============================================================================*/
	__New(key, shift_key:="", long_key:="")
	{
		super.__New(key,shift_key)
		this.SetLongKey(long_key)
		this.send_time := 0
		this.pressed_time := 0
	}

/*============================================================================
	m: 		0:disable 1:enable 2:toggle
============================================================================*/
	static EnableLongPress(m := 2, show_info := False)
	{
		if m == 0{
			LongPressKey.long_press_enabled := False
		} else if m == 1{
			LongPressKey.long_press_enabled := True
		}else{
			LongPressKey.long_press_enabled := !LongPressKey.long_press_enabled
		}
		if show_info {
			if LongPressKey.long_press_enabled {
				TrayTip("LongPressKey is enabled","",0x11)
			} else {
				TrayTip("LongPressKey is disabled","",0x11)
			}
		}
}

/*============================================================================
	key: 		base key.
	shift_key: 	shift key, which inclueds "{}". 
				If blank, shifted key is generated automatically.
	long_key: 	long pressed key, which inclueds "{}". 
				If blank, shifted key is generated automatically. If "none", does nothing.  
============================================================================*/
	SetKey(key, shift_key:="", long_key:="")
	{
		super.SetKey(key, shift_key)

		if long_key = ""{
			this.long_key_str :=  this.shift_key_str
		}else if long_key = "none"{
			this.long_key_str := ""
		}else{	
			this.long_key_str := long_key
		}
	}

	SetLongKey(long_key:="")
	{
		if long_key = ""{
			this.long_key_str :=  this.shift_key_str
		}else if long_key = "none"{
			this.long_key_str := ""
		}else{	
			this.long_key_str := long_key
		}
	}

	;Sends registered shift key when pressing only shift key.
	DownImpl(pressed_key)
	{
		if LongPressKey.long_press_enabled {
			if LongPressKey.last_key = this.key && this.send_time > 0{
				if A_TickCount - this.send_time < LongPressKey.long_press_th{
					return
				}
			}
			LongPressKey.last_key := this.key
			;if LayerKey.ParseAndChange(this.key){
			;	return
			;}
			if ! super.SendModKey(pressed_key){
				this.pressed_time  := A_TickCount
			}
		}else{
			super.SendModKey(pressed_key)
		}
	}

/*============================================================================
	Assign this method to the hotkey as same as registered.  
	ex)
	x := LongPressKey("x")
	x::x.Down("x")
	x::x.Up()
============================================================================*/
	Down(pressed_key := "")
	{
		;LayerKey.ChangeLayer(0)
		if LongPressKey.use_registered_key ||  pressed_key = ""{
			pressed_key := this.key
		}
		this.DownImpl(pressed_key)
	}

/*============================================================================
	Assign this method to the hotkey as same as registered.  
	See Down() method for the detail.
	return value short:true  long:false
============================================================================*/
	Up()
	{
		if this.pressed_time >0 && this.long_key_str != ""{
			time := A_TickCount
			if time - this.pressed_time  >= LongPressKey.long_press_th {
				if LongPressKey.last_key = this.key {
					this.send_time := time
					Send("{Backspace}" . this.long_key_str )
					this.pressed_time  := 0
					return true
				}
			}
		}
		this.send_time := 0
		this.pressed_time  := 0
		return false
	}
} ;class LongPressKey

/*============================================================================
Class to assign different key for long press with layer change.
LongPressKeyC is complicated and not versatile due to mouse operation with shift or/and ctrl key.
============================================================================*/
class LongPressKeyC extends LongPressKey  
{

/*============================================================================
	key: 		base key, if it is speial key, "{}" is needed.
	long_key: 	long pressed key, which inclueds "{}". 
				If blank, shifted key is generated automatically. If "none", does nothing.  
===========================================================================*/
	__New(key, shift_key:="", long_key:="")
	{
		super.__New(key, shift_key,long_key)
	}

/*===========================================================================
	Assign this method to the hotkey as same as registered.  
	Defines shift/ctrl combination if they are used
	Shift and Ctrl is used only for mouse operation 
	ex1)
	x := LongPressKeyC("x","","","MouseDown")
	x::x.Down("x")
	x up ::x.Down()
===========================================================================*/
	Down(pressed_key := "")
	{
		if !RKey.use_registered_key_for_ctrl ||  pressed_key = ""{
			pressed_key := this.key
		}
		if LayerKey.SendModifiedKey(pressed_key,this.shift_key_str){
			return
		}
		if LayerKey.idx = LayerKey.TWO_STROKE0{
			LayerKey.ChangeLayer(0)
		}
		;LayerKey.ChangeLayer(0)
		;base key down 
		super.DownImpl(pressed_key)
	}
} ;class LongPressKeyC

/*============================================================================
Class to skip long press for modifier.
============================================================================*/
class MKey
{
/*============================================================================
	key: base key, not inclueds "{}".
============================================================================*/
	__New(key,timeout:=200)
	{
		if key = ""{
			this.key_str := ""
			this.key := key
		}else{
			if SubStr(key,1,1) = "{"{
				this.key := SubStr(key,2,StrLen(key)-2)
				this.key_str := key
			}else{
				this.key := key
				this.key_str := "{" . key . "}"
			}
		}
		this.pressed_time := 0
		this.mod_str := ""
		this.type := 0
		this.timeout := timeout
		if LayerKey.IsCmd(key) {
			this.type := 1
		}
	}
/*============================================================================
	Is registerd key presed or not.
============================================================================*/
	IsPressed()
	{
		if this.pressed_time != 0{
			return 1
		}
;		if GetKeyState(this.key,"P"){
;			return 1
;		}
		return 0
	}

	SetModStr( )
	{
		this.mod_str  := ""
		if GetKeyState("Shift","P"){
			this.mod_str  := "+"
		}
		if GetKeyState("Ctrl","P"){
			this.mod_str  := "^" . this.mod_str 
		}
		if GetKeyState("Alt","P"){
			this.mod_str  := "!" . this.mod_str 
		}
		if GetKeyState("LWin","P") || GetKeyState("LWin","P"){
			this.mod_str  := "#" . this.mod_str 
		}
	}

/*============================================================================
	Assign this method to the hotkey as same as registered.  
============================================================================*/
	Down()
	{
		if this.pressed_time != 0 {
			return false
		}
		this.pressed_time := A_TickCount
		this.SetModStr()
		return true
	}

/*============================================================================
	Assign this method to the hotkey as same as registered.  
	Code is sent in this method if short press.  
============================================================================*/
	Up()
	{
		if (A_TickCount - this.pressed_time < this.timeout) {
			if this.type = 1{
				LayerKey.ParseAndChange(this.key)
			}else{
				if this.key_str != "" {
					SendInput("{Blind}" . this.mod_str . this.key_str)
				}
			}
		}
		this.pressed_time := 0
	}

	Reset()
	{
		this.pressed_time := 0
	}
} ;class MKey

;f13 := ModKey(S_ZENKAKU,200) ;m1
f13 := MKey("",200) ;m1
space := MKey("SPACE") ;m2
tab := MKey("TAB") ;m3
noconv := MKey(S_ZENKAKU) ;m4
f14 := MKey("ENTER") ;m5

/*============================================================================
	Returns true if modifier key is pressed. 
	m: modifier num
	alt: if value is true and alt key is pressed, returns false.  
	ctrl: if value is true and ctrl key is pressed, returns false.
	shift: if value is true and shift key is pressed, returns false.
============================================================================*/
ModifiedState(m, alt:=false, ctrl:=false,shift:=false)
{
	if ctrl {
		if GetKeyState("Ctll","P") {
			return false
		}
	} 
	if alt {
		if GetKeyState("Alt","P") {
			return false
		}
	} 
	if shift {
		if GetKeyState("Shift","P") {
			return false
		}
	} 
	if m = 1{
		return GetKeyState("F13","P")
	} if m = 2{
		return space.IsPressed() 
	} if m = 3{
		return tab.IsPressed()
	} if m = 4{
		return GetKeyState(S_NOCONV, "P") 
	} if m = 5{
		;b5 := GetKeyState(S_CONV, "P") | F14.IsPressed()
		return F14.IsPressed()
	}
	return false
}

k1 := LongPressKeyC("1")
k2 := LongPressKeyC("2")
k3 := LongPressKeyC("3")
k4 := LongPressKeyC("4")
k5 := LongPressKeyC("5")
k6 := LongPressKeyC("6")
k7 := LongPressKeyC("7")
k8 := LongPressKeyC("8")
k9 := LongPressKeyC("9")
k0 := LongPressKeyC("0","none")
minus := LongPressKeyC("-")
hat := LongPressKeyC(C_HAT)
backslash := LongPressKeyC("\")
;
q := LongPressKeyC("q")
w := LongPressKeyC("w")
e := LongPressKeyC("e")
r := LongPressKeyC("r")
t := LongPressKeyC("t")
;
y := LongPressKeyC("y")
u := LongPressKeyC("u")
i := LongPressKeyC("i")
o := LongPressKeyC("o")
p := LongPressKeyC("p")
at := LongPressKeyC("@")
openbracket := LongPressKeyC("[")
;
a := LongPressKeyC("a")
s := LongPressKeyC("s")
d := LongPressKeyC("d")
f := LongPressKeyC("f")
g := LongPressKeyC("g")
;
h := LongPressKeyC("h")
j := LongPressKeyC("j")
k := LongPressKeyC("k")
l := LongPressKeyC("l")
semicolon := LongPressKeyC(C_SEMICOLON)
colon := LongPressKeyC(C_COLON)
closebracket := LongPressKeyC("]")
;
z := LongPressKeyC("z")
x := LongPressKeyC("x")
c := LongPressKeyC("c")
v := LongPressKeyC("v")
b := LongPressKeyC("b")
;
n := LongPressKeyC("n")
m := LongPressKeyC("m")
comma := LongPressKeyC(C_COMMA)
period := LongPressKeyC(".")
slash := LongPressKeyC("/")
backslash2 := LongPressKeyC(C_BACKSLASH2)
;
up    := LongPressKeyC(B_UP,"none")
down  := LongPressKeyC(B_DOWN,"none")
left  := LongPressKeyC(B_LEFT,"none")
right := LongPressKeyC(B_RIGHT,"none")

;===10 Key Mode===
#hotif LayerKey.idx = LayerKey.NUM_MODE
1::Send("+1")
3::Send("+3")
4::Send("+4")
5::Send("+5")
6::Send("{Escape}")
7::Send("7")
8::Send("8")
9::Send("9")
-::Send("-")
sc00D::Send(C_HAT)
sc07D::Send("\")

q::Send("!{space}")
w::Send("pow+8")
e::Send("exp+8")
r::Send("sqrt+8")
t::Send("tan+8")
y::Send("{Delete}")
u::Send("4")
i::Send("5")
o::Send("6")
p::Send("pi")
@::Send(C_PLUS)
[::Send("+8")

a::Send("atan+8")
s::Send("sin+8")
d::Send("+:180/pi")
f::Send("floor+8")
g::Send("log+8")
h::Send("{Backspace}")
j::Send("1")
k::Send("2")
l::Send("3")
*sc027::Send(B_ENTER) ;;
*sc028::Send(C_ASTERISK) ;:

z::Send("abs+8")
x::Send("/180+:pi")
c::Send("cos+8")
b::Send("ln+8")
n::Send("+-")
m::Send("0")
sc033::Send(C_COMMA) ;.
.::Send(".")
*sc035::Send("/")
*sc073::Send("\")

up::Send(B_UP)
down::Send(B_DOWN)
left::Send(B_LEFT)
right::Send(B_RIGHT)

;===Mouse Mode===
#hotif LayerKey.idx = LayerKey.MOUSE_MODE
w::OperateMouse("MouseWheelUp")
u::OperateMouse("MouseLClick")
*i::OperateMouse("MouseUp")
o::OperateMouse("MouseRClick")
a::OperateMouse("MouseBack")
s::OperateMouse("MouseWheelDown")
d::OperateMouse("MouseNext")
h::OperateMouse("MouseWheelUp")
*j::OperateMouse("MouseLeft")
*k::OperateMouse("MouseDown")
*l::OperateMouse("MouseRight")
n::OperateMouse("MouseWheelDown")
m::OperateMouse("MouseBack")

up::OperateMouse("MouseWheelUp")
down::OperateMouse("MouseWheelDown")
left::OperateMouse("MouseBack")
right::OperateMouse("MouseNext")

;===Cursor Mode===
#hotif LayerKey.idx = LayerKey.CTRL_MODE
sc07D::Send("^+" . C_BACKSLASH)
*e::Send(B_ESC)
r::LayerKey.ChangeLayer(LayerKey.SEL_MODE)
y::Send("^y")
*u::Send(B_BS)
*i::Send(B_UP)
*o::Send(B_PGUP)
*p::Send(B_PGDN)
*@::Send(B_CHOME)
*[::Send(B_CEND)

*h::Send(B_HOME)
*j::Send(B_LEFT)
*k::Send(B_DOWN)
*l::Send(B_RIGHT)
]::Send("^]")

*z::Send(B_UNDO)
*x::Send(B_CUT)
*c::Send(B_COPY)
*v::Send(B_PASTE)
*b::Send(B_UNDO)
*n::Send(B_END)
*m::Send(B_DEL)
*sc033::Send(B_CLEFT)
*.::Send(B_CRIGHT)

*up::Send(B_UP)
*down::Send(B_DOWN)
*left::Send(B_LEFT)
*right::Send(B_RIGHT)

;===Select Mode===
#hotif LayerKey.idx = LayerKey.SEL_MODE  
*e::Send(B_ESC)
r::LayerKey.ChangeLayer(LayerKey.CUR_MODE)
*::Send("^y")
*u::Send(B_BS)
*i::Send("{Blind}+{Up}")
*o::Send("{Blind}+{PgUp}")
*p::Send("{Blind}+{PgDn}")
*h::Send("{Blind}+{Home}")
*j::Send("{Blind}+{Left}")
*k::Send("{Blind}+{Down}")
*l::Send("{Blind}+{Right}")
*sc027::Send(B_ENTER) ;;

*z::Send(B_UNDO)
*x::Send(B_CUT)
*c::Send(B_COPY)
*v::Send(B_PASTE)
*b::Send(B_UNDO)
*n::Send("{Blind}+{End}")
*m::Send(B_DEL)
*sc033::Send("{Blind}^+{Left}") ;<
*.::Send("{Blind}^+{Left}") ;>

*up::Send(B_UP)
*down::Send(B_DOWN)
*left::Send(B_LEFT)
*right::Send(B_RIGHT)

#hotif
;===Function Mode===
#hotif LayerKey.idx = LayerKey.FUNC_MODE
*1::Send("{Blined}+{F1}")
*2::Send("{Blined}+{F2}")
*3::Send("{Blined}+{F3}")
*4::Send("{Blined}+{F4}")
*5::Send("{Blined}+{F5}")
*6::Send("{Blined}+{F6}")
*7::Send("{Blined}+{F7}")
*8::Send("{Blined}+{F8}")
*9::Send("{Blined}+{F9}")
*0::Send("{Blined}+{F10}")
*-::Send("{Blined}+{F11}")
*sc00D::Send("{Blined}+{F12}") ;^
*sc07D::Send("{Blined}#{F12}") ;\|

*q::Send("{Blined}^{F1}")
*w::Send("{Blined}^{F2}")
*e::Send("{Blined}^{F3}")
*r::Send("{Blined}^{F4}")
*t::Send("{Blined}^{F5}")
*y::Send("{Blined}^{F6}")
*u::Send("{Blined}^{F7}")
*i::Send("{Blined}^{F8}")
*o::Send("{Blined}^{F9}")
*p::Send("{Blined}^{F10}")
*@::Send("{Blined}^{F11}")
*[::Send("{Blined}^{F12}")

*a::Send("{Blined}!{F1}")
*s::Send("{Blined}!{F2}")
*d::Send("{Blined}!{F3}")
*f::Send("{Blined}!{F4}")
*g::Send("{Blined}!{F5}")
*h::Send("{Blined}!{F6}")
*j::Send("{Blined}!{F7}")
*k::Send("{Blined}!{F8}")
*l::Send("{Blined}!{F9}")
*sc027::Send("{Blined}!{F10}")
*sc028::Send("{Blined}!{F11}")
*]::Send("{Blined}!{F12}")

*z::Send("{Blined}#{F1}")
*x::Send("{Blined}#{F2}")
*c::Send("{Blined}#{F3}")
*v::Send("{Blined}#{F4}")
*b::Send("{Blined}#{F5}")
*n::Send("{Blined}#{F6}")
*m::Send("{Blined}#{F7}")
*sc033::Send("{Blined}#{F8}") ;,
*.::Send("{Blined}#{F9}")
*sc035::Send("{Blined}#{F10}") ;/
*sc073::Send("{Blined}#{F11}") ;\_
;======================

;sc00D = "^"
;sc07D \(|)
; sc027 ;
; sc028 :
; sc033 ,
; *sc035::Send("/")
; *sc073::Send("\")

#hotif


Reset()
{   
	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon
	global b,n,m,comma,period,slash

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


ChangeASRTLayout()
{
	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon
	global b,n,m,comma,period,slash

	Reset()

	minus.SetKey("-")
	q.SetKey("q")
	w.SetKey("w")
	e.SetKey("l")
	r.SetKey("d")
	t.SetKey("p")
	y.SetKey("j")
	u.SetKey("f")
	i.SetKey("u")
	o.SetKey("y")
	p.SetKey(C_SEMICOLON)

	a.SetKey("a")
	s.SetKey("s")
	d.SetKey("r")
	f.SetKey("t")
	g.SetKey("g")
	h.SetKey("h")
	j.SetKey("n")
	k.SetKey("e")
	l.SetKey("i")
	semicolon.SetKey("o")
	
	b.SetKey("b")
	n.SetKey("k")
	m.SetKey("m")
	comma.SetKey(C_COMMA)
	period.SetKey(".")
	slash.SetKey("/")

	TrayTip("ASRT layout","",0x11)
}

ChangeFMIX15Layout()
{
	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon
	global b,n,m,comma,period,slash

	Reset()

	minus.SetKey("-")
	q.SetKey("q")
	w.SetKey("w")
	e.SetKey("l")
	r.SetKey("d")
	t.SetKey("k")
	y.SetKey(C_SEMICOLON)
	u.SetKey("f")
	i.SetKey("u")
	o.SetKey("y")
	p.SetKey("j")

	a.SetKey("a")
	s.SetKey("s")
	d.SetKey("r")
	f.SetKey("t")
	g.SetKey("g")
	h.SetKey("h")
	j.SetKey("n")
	k.SetKey("e")
	l.SetKey("i")
	semicolon.SetKey("o")
	
	b.SetKey("b")
	n.SetKey("p")
	m.SetKey("m")
	comma.SetKey(C_COMMA)
	period.SetKey(".")
	slash.SetKey("/")
	
	TrayTip("FMIX15 layout","",0x11)
}

ChangeFMIX15RLayout()
{
	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon
	global b,n,m,comma,period,slash

	Reset()

	minus.SetKey("-")
	q.SetKey("q")
	w.SetKey("w")
	e.SetKey("l")
	r.SetKey("d")
	t.SetKey("k")
	y.SetKey(C_SEMICOLON)
	u.SetKey("f")
	i.SetKey("u")
	o.SetKey("y")
	p.SetKey("j")

	a.SetKey("a")
	s.SetKey("s")
	d.SetKey("r")
	f.SetKey("t")
	g.SetKey("g")
	h.SetKey("h")
	j.SetKey("n")
	k.SetKey("e")
	l.SetKey("i")
	semicolon.SetKey("o")
	
	b.SetKey("b")
	n.SetKey("p")
	m.SetKey("m")
	comma.SetKey(C_COMMA)
	period.SetKey(".")
	slash.SetKey("/")

	e.SetImeKey("r","da")
	d.SetImeKey("k","de")
	t.SetImeKey("l")
	f.SetImeKey("t","-")
	;g.SetImeKey("g","ga")
	j.SetImeKey("n","j")
	q.SetImeKey("q","?")
	o.SetImeKey("j")
	p.SetImeKey("y")

	
	; a.SetImeKey("a","ka")
	; i.SetImeKey("u","ku")
	; k.SetImeKey("e","ke")
	; l.SetImeKey("i","ki")
	; semicolon.SetImeKey("o","ko")

	TrayTip("FMIX15R layout","",0x11)
}

ChangeKSTNHLayout()
{
	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon
	global b,n,m,comma,period,slash

	Reset()

	minus.SetKey(C_SLASH)
	q.SetKey("q")
	w.SetKey("l")
	e.SetKey("u")
	r.SetKey(C_COMMA)
	t.SetKey(".")
	y.SetKey("f")
	u.SetKey("w")
	i.SetKey("y")
	o.SetKey("r")
	p.SetKey("p")

	a.SetKey("a")
	s.SetKey("i")
	d.SetKey("e")
	f.SetKey("o")
	g.SetKey("-")
	h.SetKey("k")
	j.SetKey("s")
	k.SetKey("t")
	l.SetKey("n")
	semicolon.SetKey("h")
	
	b.SetKey(C_SEMICOLON)
	n.SetKey("g")
	m.SetKey("j")
	comma.SetKey("d")
	period.SetKey("m")
	slash.SetKey("b")

	TrayTip("kstnh layout","",0x11)
}


; ModifiedState2(m1:=False,m2:=False,m3:=False,m4:=False,m5:=False)
; {
; 	b1 := GetKeyState("F13","P")
; 	b2 := space.IsPressed() 
; 	b3 := tab.IsPressed()
; 	b4 := GetKeyState(S_NOCONV, "P") 
; 	;b5 := GetKeyState(S_CONV, "P") | F14.IsPressed()
; 	b5 := F14.IsPressed()
; 	return b1 = m1 && b2 = m2 && b3 = m3 && b4 = m4 && b5 = m5  
; }

;***M3**************************************************************************
;#HotIf ModifiedState(3) 
;#HotIf (ModifiedState(1) && GetKeyState("Alt","P")) 

#HotIf ModifiedState(3) || (ModifiedState(1) && GetKeyState("Alt","P")) 
*1::Send("^z")
*2::Send("^x")
*3::Send("^c")
*4::Send("^v")
*z::Send("^z")
*x::Send("^x")
*c::Send("^c")
*v::Send("^v")
*b::Send("^z")

*y::Send(C_REDO)
*u::Send(C_BS)
*i::Send("+{Up}")
*o::Send("+{PgUp}")
*p::Send("+{PgDn}")
*h::Send("+{Home}")
*j::Send("+{Left}")
*k::Send("+{Down}")
*l::Send("+{Right}")
*sc027::Send("+{Enter}") ;vkBBsc027 = ; shift:+
*Enter::Send("{Enter}")
*n::Send("+{End}")
*m::Send(C_DEL)
*space::Send(C_BS)

;***M1 or M2 *******************************************************************
#HotIf ModifiedState(1) || ModifiedState(2)

PgUp::MouseSpeed.IncSpeed()
PgDn::MouseSpeed.DecSpeed()
*1::Send("{Blind}{F1}")
*2::Send("{Blind}{F2}")
*3::Send("{Blind}{F3}")
*4::Send("{Blind}{F4}")
*5::Send("{Blind}{F5}")
*6::Send("{Blind}{F6}")
*7::Send("{Blind}{F7}")
*8::Send("{Blind}{F8}")
*9::Send("{Blind}{F9}")
*0::Send("{Blind}{F10}")
*-::Send("{Blind}{F11}")
*sc00D::Send("{Blind}{F12}") ; sc00D = "^"
sc07D::Send("^+{sc07D}") ;\(|)

*y::Send(B_UNDO)
*u::Send(B_BS)
*i::Send(B_UP)
*o::Send(B_PGUP)
*p::Send(B_PGDN)
*@::Send(B_CHOME)
*[::Send(B_CEND)

*h::Send(B_HOME)
*j::Send(B_LEFT)
*k::Send(B_DOWN)
*l::Send(B_RIGHT)
*sc027::Send(B_ENTER) ;vkBBsc027 = ; shift:+
sc028::LayerKey.ChangeLayer(LayerKey.FUNC_MODE) ;vkBAsc028 = ":" shift:*
*]::Send("^]")

*z::Send(B_UNDO) ;undo
*x::Send(B_CUT) ;cut
*c::Send(B_COPY) ;copy
*v::Send(B_PASTE) ;paste
*b::Send(B_UNDO) ;undo
*n::Send(B_END)
*m::Send(B_DEL)
*sc033::Send("{Blind}^{Left}") ;vkBCsc033 = ,
.::Send("{Blind}^{Right}")
;sc035::LayerKey.ChangeLayer(LayerKey.NUM_MODE) ;/ 
;sc073::LayerKey.ChangeLayer(LayerKey.MOUSE_MODE) ; \(_) 

*Enter::Send("{Blind}^{Enter}")

#HotIf
;***M1**************************************************************************
#HotIf ModifiedState(1)
;Tab::Send(C_EISU) ;vkF0sc03A = Eisu
sc029::Send(C_EISU) ; vkF3sc029 = 全角/半角 vkF0sc03A = Eisu
Esc::{		
	MouseSpeed.Reset()
	Reload
}

q::!space
*e::Send(B_ESC)
r::+F3
*a::Send("{Blind}^a")
*s::Send("{Blind}^s")
*d::Send("{Blind}^{Space}") 
*f::Send(B_TAB)
g::Send("^f")

F14::Send(C_ZENKAKU) 
sc079::Send(C_ZENKAKU) ;conv
space::Send(C_ZENKAKU)

;*space::Send(B_BS)
#k::ChangeKSTNHLayout()
#a::ChangeASRTLayout()
#f::ChangeFMIX15Layout()
#r::ChangeFMIX15RLayout()
#x::LongPressKey.EnableLongPress(2,true)
#HotIf

;***M2**************************************************************************
#HotIf ModifiedState(2)
q::Send("?")
w::+F3
*e::Send(B_SLASH)
*r::Send(B_NMUL) 
*t::Send(B_NADD)

*a::Send("{Blind}^a")
s::Send("()")
d::Send("_")
*f::Send("{Blind}-")
g::Send("=")

sc035::LayerKey.ChangeLayer(LayerKey.MOUSE_MODE) ;/ 

F14::Send(B_ZENKAKU) 
sc079::Send(B_ZENKAKU) ;conv
#HotIf

;***M4**************************************************************************
#HotIf ModifiedState(4)

q::Send("''{Left}")
w::Send('""{Left}')
e::Send("<")
r::Send(">")
t::Send("+1")

a::Send("<>{Left}")
s::Send("(){Left}")
d::Send("[]{Left}")
f::Send("-")
g::Send("=")

x::Send("+[+]{Left}")
c::Send(":")
v::Send(";")
b::Send(":=")

;-----------------------------------------------
6::Send("{Escape}")
7::Send(C_N7)
8::Send(C_N8)
9::Send(C_N9)
0::Send(B_NMUL)
;-::Send("-")
sc00D::Send(C_HAT)
sc07D::Send("\")

u::Send(C_N4)
i::Send(C_N5)
o::Send(C_N6)
p::Send(B_NADD)
@::Send(B_UP)

j::Send(C_N1)
k::Send(C_N2)
l::Send(C_N3)
*sc027::Send(B_LEFT) ;; 
*sc028::Send(B_DOWN) ;:
]::Send(B_RIGHT)
;-----------------------------------------------
; u::Send(C_N6)
; i::Send(C_N7)
; o::Send(C_N8)
; p::Send(C_N9)
; j::Send(C_N1)
; k::Send(C_N2)
; l::Send(C_N3)
; *sc027::Send(C_N4) ;; 
; *sc028::Send(C_N5) ;:
;-----------------------------------------------

y::Send(C_BS)
h::Send("-")

n::Send(C_DEL)
m::Send(C_N0)
sc033::Send(C_COMMA) ;.
.::Send(C_NDOT)
+sc033::Send("<=") ;.
+.::Send(">=")
*sc035::Send(B_NDIV)
*sc073::Send("\")

space::Send(B_ENTER)

up::Send(B_UP)
down::Send(B_DOWN)
left::Send(B_LEFT)
right::Send(B_RIGHT)

#HotIf ;needed to enable m5
;***M5**************************************************************************
#HotIf ModifiedState(5)
1::+1
2::+2
3::+3
4::+4
5::+5

q::Send("+7")
w::Send("+2")
e::Send("+3")
r::Send("+4")
t::Send("+5")

a::Send("@")
s::Send(C_HAT)
g::Send("+6")

;z::Send('"')
;x::Send("'")
c::Send(B_COLON)
v::Send(B_SEMICOLON)
b::Send("\")


6::+6
7::+7
8::+8
9::+9

u::Send("+{@}") ;`
i::Send("+[")
o::Send("+]")

h::Send("~")
j::Send("+1") ;!
k::Send("[")
l::Send("]")

n::Send("-") ;%
m::Send("=")
sc033::Send("<") ;.
.::Send(">")

;***Long Press**************************************************************************
#HotIf
*1::k1.Down("1")
*1 up::k1.Up()
*2::k2.Down("2")
*2 up::k2.Up()
*3::k3.Down("3")
*3 up::k3.Up()
*4::k4.Down("4")
*4 up::k4.Up()
*5::k5.Down("5")
*5 up::k5.Up()
*6::k6.Down("6")
*6 up::k6.Up()
*7::k7.Down("7")
*7 up::k7.Up()
*8::k8.Down("8")
*8 up::k8.Up()
*9::k9.Down("9")
*9 up::k9.Up()
*0::k0.Down("0")
*0 up::k0.Up()
*-::minus.Down("-")
*- up::minus.Up()
*sc00D::hat.Down("sc00D")
*sc00D up::hat.Up()
*sc07D::backslash.Down("sc07D")
*sc07D up::backslash.Up()

*q::q.Down("q")
*q up::q.Up()
*w::w.Down("w")
*w up::w.Up()
*e::e.Down("e")
*e up::e.Up()
*r::r.Down("r")
*r up::r.Up()
*t::t.Down("t")
*t up::t.Up()
*y::y.Down("y")
*y up::y.Up()
*u::u.Down("u")
*u up::u.Up()
*i::i.Down("i")
*i up::i.Up()
*o::o.Down("o")
*o up::o.Up()
*p::p.Down("p")
*p up::p.Up()
*@::at.Down("@")
*@ up::at.Up()
*[::openbracket.Down("[")
*[ up::openbracket.Up()
;

*a::a.Down("a")
*a up::a.Up()
*s::s.Down("s")
*s up::s.Up()
*d::d.Down("d")
*d up::d.Up()
*f::f.Down("f")
*f up::f.Up()
*g::g.Down("g")
*g up::g.Up()
*h::h.Down("h")
*h up::h.Up()

*j::j.Down("j")
*j up::j.Up()

*k::k.Down("k")
*k up::k.Up()

*l::l.Down("l")
*l up::l.Up()

*sc027::semicolon.Down("sc027")
*sc027 up::semicolon.Up()
*sc028::colon.Down("sc028")
*sc028 up::colon.Up()
*]::closebracket.Down("]")
*] up::closebracket.Up()
;

*z::z.Down("z")
*z up::z.Up()
*x::{
	x.Down("x")
	if LayerKey.idx = LayerKey.SEL_MODE {
		LayerKey.ChangeLayer(LayerKey.CUR_MODE)
	}
}
*x up::x.Up()
*c::{
	c.Down("c")
	if LayerKey.idx = LayerKey.SEL_MODE {
		LayerKey.ChangeLayer(LayerKey.CUR_MODE)
	}
}

*c up::c.Up()
*v::v.Down("v")
*v up::v.Up()
*b::b.Down("b")
*b up::b.Up()
*n::n.Down("n")
*n up::n.Up()
*m::m.Down("m")
*m up::m.Up()
*sc033::comma.Down("sc033")
*sc033 up::comma.Up()
*.::period.Down(".")
*. up::period.Up()

*sc035::slash.Down("sc035")
*sc035 up::slash.Up()

*sc073::backslash2.Down("sc073")
*sc073 up::backslash2.Up()
;

down::down.Down()
up::up.Down()
left::left.Down()
right::right.Down()

#Hotif
Esc::{
	;MouseSpeed.Reset()
	LayerKey.ChangeLayer(0)
;	MouseSpeed.Reset()
	Send("{Escape}")
	;Reload
}

*Space::{
	if space.Down(){
;		MouseSpeed.MakeSlow()
		LayerKey.ChangeLayer(0)
	}
}

*Space up::{
;	MouseSpeed.Reset()
	space.Up()
}

*tab::{
	if tab.Down(){
;		MouseSpeed.MakeSlow()
		LayerKey.ChangeLayer(0)
	}
}

*tab up::{
;	MouseSpeed.Reset()
	tab.Up()
}

*F13::{
	if f13.Down(){
;		MouseSpeed.MakeSlow()
		LayerKey.ChangeLayer(0)
	}
}

*F13 up::{
;	MouseSpeed.Reset()
	f13.Up()
}

*F14:: f14.Down()
*F14 up::f14.Up() 

*sc079:: f14.Down() ;conv
*sc079 up::f14.Up() ;conv
	
sc07B::noconv.Down() ;vk1Dsc07B = 無変換
sc07B up::noconv.Up() 


;NumLock::Return
+F15::Send("{NumLock}")

>+Up::_
^+F13::Send("+{CapsLock}") ;Change CapsLock off setting to shift on Windows setting
+sc029::Send(C_EISU) ;vkF3sc029 = 全角/半角 

; rbutton_locked := 0
; ~RButton::{
; 	ToolTip "locked"
; 	rbutton_locked := 1
; }
; ~RButton up::{
; 	ToolTip "unlocked"
; 	rbutton_locked := 0
; }

; RButton & WheelUp::{
; 	rbutton_locked := 1
; 	Send("^{WheelUp}")
; }

; RButton & WheelDown::{
; 	rbutton_locked := 1
; 	Send("^{WheelDown} ")
; }

#SuspendExempt
#!Enter::Suspend
#SuspendExempt False

#MaxThreadsBuffer False
