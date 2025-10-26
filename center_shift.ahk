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
C_CSHOME  := "^+{Home}"
C_CSEND   := "^+{End}"
B_CPGUP := "{Blind}^{PgUp}"
B_CPGDN := "{Blind}^{PgDn}"

B_LEFT := "{Blind}{Left}"
B_RIGHT := "{Blind}{Right}"
B_CLEFT := "{Blind}^{Left}"
B_CRIGHT := "{Blind}^{Right}"
C_CSLEFT := "^+{Left}"
C_CSRIGHT := "^+{Right}"

B_UP := "{Blind}{Up}"
B_DOWN := "{Blind}{Down}"
B_CLEFT := "{Blind}^{Left}"
B_CRIGHT := "{Blind}^{Right}"

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


;SingleInstkance Force
ProcessSetPriority "Realtime"
SendMode "Input"

InstallKeybdHook true
InstallMouseHook true
#UseHook true
#MaxThreadsBuffer True
;#MaxThreadsPerHotkey 3 ;If enabled, it's unstable.
SetKeyDelay 0

GetShiftState()
{
	return GetKeyState("Shift","P")
}

GetActiveWindowHandle() 
{
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

SetImeState(hwnd,state) 
{
	return DllCall("SendMessage"
        , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
        , "UInt", 0x0283  ; WM_IME_CONTROL
        , "Ptr", 0x006    ; IMC_SETOPENSTATUS
        , "Ptr", state)  ; 1でON、0でOFF
}


force_ime_on := false ;If true, force to turn on IME.
last_active_hwnd := 0 ;Last active window handle to check IME state.

IsImeOn()
{
	;return ImeState.IsOn()
	;return GetImeState(GetActiveWindowHandle())
	global last_active_hwnd,force_ime_on
	hwnd := GetActiveWindowHandle()
	if last_active_hwnd = hwnd { 
		if force_ime_on {
			return true
		}
	}else{
		force_ime_on := false
	}

	last_active_hwnd := hwnd 
    return DllCall("SendMessage"
        , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
        , "UInt", 0x0283  ; WM_IME_CONTROL
        , "Ptr", 0x0005   ; IMC_GETOPENSTATUS
        , "Ptr", 0)
}

;Toggle force IME-on on the current window.
ToggleForceImeOn()
{
	global force_ime_on
	force_ime_on := !force_ime_on
}

ToggleImeState()
{
	Send(B_ZENKAKU)	
}

;Send key according to IME state.
SendAccImeState(key_ime_off,key_ime_on:="")
{
	if IsImeOn() && key_ime_on != ""{
		Send(key_ime_on)
	}else{
		Send(key_ime_off)
	}
}

/*============================================================================
Class to ctrl mouse speed.
============================================================================*/
class MouseSpeed
{
	static SPI_GETMOUSESPEED := 0x70
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
		ToolTip("MouseSpeed: " . v)
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
}	 ;class MouseSpeed

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
			this.key := key ;registerd key
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
		if GetShiftState(){
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
			SendInput("{Blind}" . this.mod_str . this.key_str)
		}
		this.pressed_time := 0
	}

	Reset()
	{
		this.pressed_time := 0
	}
} ;class MKey

/*============================================================================
Class to assign different key.
============================================================================*/
class RKey
{
	static use_registered_key_for_ctrl  := false ;for ctrl or alt

/*============================================================================
	key: 		base key, if it is a speial key, "{}" is needed.
	shift_key: 	shift key.	If blank, shifted key is generated automatically. If "none", does nothing.  
============================================================================*/
	__New(key, shift_key:="")
	{
		this.SetKey(key,shift_key)
		this.SetImeKey(key, shift_key)
	}

	isModified(text)
	{
		list := ["{Blind}","+","#","^","!"]
		for index, item in list{
			if InStr(text, item,'Off') > 0{
				return true
			}
		}
		return false
	}
/*============================================================================
	key: 		base key, if it is a speial key, "{}" is needed.
	shift_key: 	shift key.	If blank, shifted key is generated automatically.
							If "none", does nothing.	
============================================================================*/
	SetKey(key, shift_key:="")
	{
		this.key := key
		if this.isModified(key) {
			this.short_key_str := key
			if shift_key = "none"{
				this.shift_key_str := ""
			}else{
				if shift_key = ""{
					this.shift_key_str :=  ""
				}else{
					this.shift_key_str :=  shift_key 
				}
			}
		}else{
			this.short_key_str := "{Blind}" .  key 
			if shift_key = "none"{
				this.shift_key_str := ""
			}else{
				if shift_key = ""{
					this.shift_key_str :=  "{Blind}+" . key
				}else{
					this.shift_key_str :=  shift_key 
				}
			}
		}
	}
	
/*============================================================================
	key: 		base key when ime is on.
	shift_key: 	shift key. If blank, shifted key is generated automatically.
						   If "none", does nothing.
============================================================================*/
	SetImeKey(key := "", shift_key:="")
	{
		if key = "" {
		 	key  := this.short_key_str
		} 
		if this.isModified(key) {
			this.short_ime_key_str := key 
			if shift_key = "none"{
				this.shift_key_str := ""
			}else{
				if shift_key = ""{
					this.shift_ime_key_str :=  this.shift_key_str 
				}else{
					this.shift_ime_key_str :=  shift_key 
				}
			}
		}else{
			this.short_ime_key_str := "{Blind}" .  key 
			if shift_key = "none"{
				this.shift_key_str := ""
			}else{
				if shift_key = ""{
					this.shift_ime_key_str :=  "{Blind}+" . key
				}else{
					this.shift_ime_key_str :=  shift_key 
				}
			}
		}
	}

	_SendKey(ime_key,normal_key)
	{
		if ime_key = normal_key{
			Send(normal_key) ;Sends key in blind mode
		}else{
			if ime_key != "" && IsImeOn() {
				Send(ime_key)
			}else{
				Send(normal_key) ;Sends key in blind mode
			}
		}
	}

	SendShiftedKey(shift := true)
	{
		if  shift  {
			this._SendKey(this.shift_ime_key_str,this.shift_key_str)
			return true
		}else{ 
			this._SendKey(this.short_ime_key_str,this.short_key_str)
			return false
		}
	}

	;@param pressed_key: key to be sent, not includes "{}". 
	_SendCAWKey(pressed_key)
	{
		caw := GetKeyState("Ctrl","P") || GetKeyState("Alt","P") ||
			GetKeyState("LWin","P") || GetKeyState("RWin","P")
		if caw {
			Send("{Blind}" . "{" . pressed_key . "}")
			;ToolTip pressed_key
			return true
		}
		return false
	}

	;Sends registered shift key when pressing only shift key.
	;returns true if Ctrl is pressed
	_SendSCAWKey(pressed_key)
	{
		if this._SendCAWKey(pressed_key) {
			return true
		}
		shift := GetShiftState()
		this.SendShiftedKey(shift) ;Sends key in blind mode
		return false
	}

/*============================================================================
	Assign this method to the hotkey as same as registered.  
	ex)
	x := LKey("x")
	x::x.Down("x")
	x::x.Up()
============================================================================*/
	Down(pressed_key := "")
	{
		if RKey.use_registered_key_for_ctrl ||  pressed_key = ""{
			pressed_key := this.key
		}
		this._SendSCAWKey(pressed_key)
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
class LKey extends RKey
{
	;static use_registered_key_for_ctrl  := false ;for ctrl or alt
	static long_press_th := 300 ;if pressing for more this time, long press process runs in Up()
	static last_key := ""
	static long_press_enabled  := true
	long_key_str := ""
	pressing := False
/*============================================================================
	key: 		base key, if it is a speial key, "{}" is needed.
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
			LKey.long_press_enabled := False
		} else if m == 1{
			LKey.long_press_enabled := True
		}else{
			LKey.long_press_enabled := !LKey.long_press_enabled
		}
		if show_info {
			if LKey.long_press_enabled {
				TrayTip("LKey is enabled","",0x11)
			} else {
				TrayTip("LKey is disabled","",0x11)
			}
		}
	}

/*============================================================================
	key: 		base key, if it is a speial key, "{}" is needed.
	shift_key: 	shift key, which inclueds "{}". 
				If blank, shifted key is generated automatically.
	long_key: 	long pressed key, which inclueds "{}". 
				If blank, shifted key is generated automatically. If "none", does nothing.  
============================================================================*/
	SetKey(key, shift_key:="")
	{
		super.SetKey(key, shift_key)
	}

	SetLongKey(long_key:="")
	{
		if long_key = ""{
			this.long_key_str :=  this.shift_key_str
		}else if long_key = "none"{
			this.long_key_str := "none"
		}else{	
			this.long_key_str := long_key
		}
	}

	/*============================================================================
	Is registerd key presed or not.
	============================================================================*/
	IsPressed()
	{
		return this.pressing
	}


	;Sends registered shift key when pressing only shift key.
	_Down(pressed_key)
	{
		if this.long_key_str = "none" {
			if super._SendCAWKey(pressed_key){
				this.pressed_time  := 0
				return
			}
			if this.pressing {
				return
			}
			this.pressing := True
			LKey.last_key := this.key
			this.pressed_time  := A_TickCount
			;tooltip	this.pressed_time
		}else{
			this.pressing := True
			if LKey.long_press_enabled {
				if LKey.last_key = this.key && this.send_time > 0{
					if A_TickCount - this.send_time < LKey.long_press_th{
						return
					}
				}
				LKey.last_key := this.key
				if ! super._SendModKey(pressed_key){
					this.pressed_time  := A_TickCount
				}
			}else{
				super.SendModKey(pressed_key)
			}
		}
	}



/*============================================================================
	Assign this method to the hotkey as same as registered.  
	ex)
	x := LKey("x")
	x::x.Down("x")
	x::x.Up()
============================================================================*/
	Down(pressed_key := "")
	{
		;LayerKey.ChangeLayer(0)
		if LKey.use_registered_key_for_ctrl ||  pressed_key = ""{
			pressed_key := this.key
		}
		this._Down(pressed_key)
	}

	/*============================================================================
	Assign this method to the hotkey as same as registered.  
	See Down() method for the detail.
	return value short:true  long:falsem
	============================================================================*/
	Up()
	{
		if this.pressed_time >0 && this.long_key_str != ""{
			time := A_TickCount
			if this.long_key_str = "none"{
				if time - this.pressed_time  >= LKey.long_press_th {
				}else{
					if this.pressing {
						if LKey.last_key = this.key {
							shift := GetShiftState()
							this.SendShiftedKey(shift) ;Sends key in blind mode
						}
					}
				}
				this.pressed_time  := 0
			}else{
				if time - this.pressed_time  >= LKey.long_press_th {
					if LKey.last_key = this.key {
						this.send_time := time
						Send("{Backspace}" . this.long_key_str )
						this.pressed_time  := 0
						this.pressing := false 
						return true
					}
				}
			}
		}
		this.pressing := false 
		this.send_time := 0
		this.pressed_time  := 0
		return false
	}
} ;class LKey

;f13 := ModKey(S_ZENKAKU,200) ;m1
f13 := MKey("",200) ;m1
space := MKey("SPACE") ;m2
tab := MKey("TAB") ;m3
noconv := MKey(S_ZENKAKU) ;m4
f14 := MKey("ENTER") ;m5

colon := LKey(C_COLON,"","none")

/*============================================================================
	Returns true if modifier key is pressed. 
	m: modifier num
	alt: if value is true and alt key is pressed, returns false.  
	ctrl: if value is true and ctrl key is pressed, returns false.
	shift: if value is true and shift key is pressed, returns false.
============================================================================*/
k1 := RKey("1")
k2 := RKey("2")
k3 := RKey("3")
k4 := RKey("4")
k5 := RKey("5")
k6 := RKey("6")
k7 := RKey("7")
k8 := RKey("8")
k9 := RKey("9")
k0 := RKey("0","none")
minus := RKey("-")
hat := RKey(C_HAT)
backslash := RKey("\")
;
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
semicolon := RKey(C_SEMICOLON)
;colon := RKey(C_COLON)
closebracket := RKey("]")
;
z := RKey("z")
x := RKey("x")
c := RKey("c")
v := RKey("v")
b := RKey("b")
;
n := RKey("n")
m := RKey("m")
comma := RKey(C_COMMA)
period := RKey(".")
slash := RKey("/")
backslash2 := RKey(C_BACKSLASH2)
;
up    := RKey(B_UP,"none")
down  := RKey(B_DOWN,"none")
left  := RKey(B_LEFT,"none")
right := RKey(B_RIGHT,"none")


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
		if GetShiftState(){
			return false
		}
	} 
	if m = 1{
		return GetKeyState("F13","P") 
	} if m = 2{
		return space.IsPressed() 
	} if m = 3{
		;return tab.IsPressed() 
		return false	
	} if m = 4{
		return tab.IsPressed()  || GetKeyState(S_NOCONV, "P") 
	} if m = 5{
		return F14.IsPressed()
	} if m = 6{
		return colon.IsPressed()
	}
	return false
}

;exclusive state
; ModifiedStateX(list)
; {
; 	b := false
; 	s := ""

; 	Loop 6 {
; 		s := s . A_Index
; 		bb := false
; 		for k,v in list{
; 			s := s . "["  . v . "," . k . "]"
; 			if v = A_Index {
; 				bb := true
; 				break
; 			}
; 		}
; 		if bb {
; 			b |=  ModifiedState(A_Index)
; 			s := s . "a:"
; 		}else {
; 			b &= !ModifiedState(A_Index)
; 			s := s . "b:"
; 		}	
; 	}
; 	  if b {
; 	 	ToolTip "ModifiedState: " . s . b
; 	 	;SetTimer(ToolTip,3000)
; 	 }
; 	return b
; }

ResetIME()
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


	; global q_ime := ""
	; global w_ime := ""
	; global e_ime := ""
	; global r_ime := ""
	; global t_ime := ""
	
	; global a_ime := ""
	; global s_ime := ""
	; global d_ime := ""
	; global f_ime := ""
	; global g_ime := ""
	
	; global z_ime := ""
	; global x_ime := ""
	; global c_ime := ""
	; global v_ime := ""
	; global b_ime := ""
	
	; global y_ime := ""
	; global u_ime := ""
	; global i_ime := ""
	; global o_ime := ""
	; global p_ime := ""
	
	; global h_ime := ""
	; global j_ime := ""
	; global k_ime := ""
	; global l_ime := ""
	; global sc_ime := ""
	
	; global n_ime := ""
	; global m_ime := ""
	; global comma_ime := ""
	; global period_ime := ""
	; global slash_ime := ""
}


ChangeOonishiLayout()
{
	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon
	global b,n,m,comma,period,slash

	minus.SetKey("/")
	q.SetKey("q")
	w.SetKey("l")
	e.SetKey("u")
	r.SetKey(",","<")
	t.SetKey(".",">")
	y.SetKey("f")
	u.SetKey("w")
	i.SetKey("r")
	o.SetKey("y")
	p.SetKey("p")

	a.SetKey("e")
	s.SetKey("i")
	d.SetKey("a")
	f.SetKey("o")
	g.SetKey("-")
	h.SetKey("k")
	j.SetKey("t")
	k.SetKey("n")
	l.SetKey("s")
	semicolon.SetKey("h")

	b.SetKey(";")
	n.SetKey("g")
	m.SetKey("d")
	comma.SetKey("m")
	period.SetKey("j")
	slash.SetKey("b")

	ResetIME()

	TrayTip("Oonish layout","",0x11)
}

ChangeColemakLayout()
{
	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon
	global b,n,m,comma,period,slash

	minus.SetKey("-")
	q.SetKey("q")
	w.SetKey("w")
	e.SetKey("f")
	r.SetKey("p")
	t.SetKey("g")
	y.SetKey("j")
	u.SetKey("l")
	i.SetKey("u")
	o.SetKey("y")
	p.SetKey(C_SEMICOLON)

	a.SetKey("a")
	s.SetKey("r")
	d.SetKey("s")
	f.SetKey("t")
	g.SetKey("d")
	h.SetKey("h")
	j.SetKey("n")
	k.SetKey("e")
	l.SetKey("i")
	semicolon.SetKey("o")
	
	z.SetKey("z")
	x.SetKey("x")
	c.SetKey("c")
	v.SetKey("v")
	b.SetKey("b")
	n.SetKey("k")
	m.SetKey("m")
	comma.SetKey(C_COMMA)
	period.SetKey(".")
	slash.SetKey("/")

	TrayTip("Colemak layout","",0x11)
}


ChangeFMIXVBJ_LayoutImpl()
{
	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon
	global b,n,m,comma,period,slash

	minus.SetKey("-")
	q.SetKey("q")
	w.SetKey("w")
	e.SetKey("l")
	r.SetKey("d")
	t.SetKey("k")
	y.SetKey("y")
	u.SetKey("f")
	i.SetKey("u")
	o.SetKey("p")
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
	
	z.SetKey("z")
	x.SetKey("x")
	c.SetKey("c")
	v.SetKey("v")
	b.SetKey("b")
	n.SetKey("j")
	m.SetKey("m")
	comma.SetKey(C_COMMA)
	period.SetKey(".")
	slash.SetKey("/")
}

ChangeFMIX12f_Layout()
{
	ChangeFMIXVBJ_LayoutImpl()

	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon,colon
	global b,n,m,comma,period,slash

	ResetIME()

	e.SetKey("f")
	d.SetKey("d")
	r.SetKey("r")
	t.SetKey("k")
	u.SetKey("l")

	TrayTip("FMIX12f layout","",0x11)
}

ChangeFMIX12f_FMIX13fR_Layout()
{
	ChangeFMIXVBJ_LayoutImpl()

	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon,colon
	global b,n,m,comma,period,slash

	ResetIME()

	e.SetKey("f")
	d.SetKey("d")
	r.SetKey("r")
	t.SetKey("k")
	u.SetKey("l")

	e.SetImeKey("d","F")
	t.SetImeKey("f","K")
	d.SetImeKey("k","D")

	TrayTip("FMIX12f-FMIX13fR layout","",0x11)
}

ChangeFMIX13f_FMIX14R_Layout()
{
	ChangeFMIXVBJ_LayoutImpl()

	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon,colon
	global b,n,m,comma,period,slash

	ResetIME()

	e.SetKey("r")
	d.SetKey("d")
	r.SetKey("f")
	t.SetKey("k")
	u.SetKey("l")

	e.SetImeKey("r")
	r.SetImeKey("d","F")
	t.SetImeKey("l","K")
	d.SetImeKey("k","D")
	u.SetImeKey("f")

	TrayTip("FMIX13f-FMIX14R layout","",0x11)
}


ChangeFMIX14_FMIX14R_Layout()
{
	ChangeFMIXVBJ_LayoutImpl()

	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon,colon
	global b,n,m,comma,period,slash

	ResetIME()

	r.SetKey("d")
	t.SetKey("k")

	e.SetImeKey("r","L")
	t.SetImeKey("l","K")
	d.SetImeKey("k","R")

	TrayTip("FMIX14-FMIX14R layout","",0x11)
}

ChangeFMIX13f_FMIX14fR_Layout()
{
	ChangeFMIXVBJ_LayoutImpl()

	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon,colon
	global b,n,m,comma,period,slash

	ResetIME()

	e.SetKey("r")
	u.SetKey("l")

	r.SetKey("f")
	t.SetKey("k")
	d.SetKey("d")

	;e.SetImeKey("r","L")
	r.SetImeKey("d","F")
	t.SetImeKey("f","K")
	d.SetImeKey("k","D")

	TrayTip("FMIX13f-FMIX14fR layout","",0x11)
}

ChangeFMIX13_FMIX14R_Layout()
{
	ChangeFMIXVBJ_LayoutImpl()

	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon,colon
	global b,n,m,comma,period,slash

	ResetIME()

	e.SetKey("r")
	u.SetKey("f")
	r.SetKey("l")
	t.SetKey("k")
	d.SetKey("d")

	e.SetImeKey("r","R")
	r.SetImeKey("d","L")
	t.SetImeKey("l","K")
	d.SetImeKey("k","D")

	TrayTip("FMIX13-FMIX14R layout","",0x11)
}

; ChangeFMIX13vbp_FMIX14R_Layout()
; {
; 	ChangeFMIXVBJ_LayoutImpl()

; 	global minus
; 	global q,w,e,r,t,y,u,i,o,p
; 	global a,s,d,f,g,h,j,k,l,semicolon,colon
; 	global b,n,m,comma,period,slash

; 	ResetIME()

; 	e.SetKey("r")
; 	u.SetKey("f")
; 	o.SetKey("j")
; 	n.SetKey("p")

; 	r.SetKey("l")
; 	t.SetKey("k")
; 	d.SetKey("d")

; 	;e.SetImeKey("r","L")
; 	r.SetImeKey("d","L")
; 	t.SetImeKey("l","K")
; 	d.SetImeKey("k","D")

; 	TrayTip("FMIX13vbp-FMIX14R layout","",0x11)
; }


;***M3**************************************************************************
#HotIf ModifiedState(1) && (GetKeyState("Alt","P") || GetKeyState(S_NOCONV, "P")) 
;#HotIf ModifiedState(3) 
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
*@::Send(C_CSHOME)
*[::Send(C_CSEND)

*h::Send("+{Home}")
*j::Send("+{Left}")
*k::Send("+{Down}")
*l::Send("+{Right}")
*sc027::Send("+{Enter}") ;vkBBsc027 = ; shift:+
*Enter::Send("{Enter}")
*n::Send("+{End}")
*m::Send(C_DEL)
*sc033::Send("^+{Left}") ;vkBCsc033 = ,
*.::Send("^+{Right}")

*space::Send(C_BS)

*up::Send("+{Up}")
*left::Send("+{Left}")
*down::Send("+{Down}")
*right::Send("+{Right}")

#HotIf

;***M1 or M2 *******************************************************************
#HotIf (ModifiedState(1) || ModifiedState(2)) && !ModifiedState(3) && !ModifiedState(4) && !ModifiedState(5) 
*1::Send(B_F1)
*2::Send(B_F2)
*3::Send(B_F3)
*4::Send(B_F4)
*5::Send(B_F5)
*6::Send(B_F6)
*7::Send(B_F7)
*8::Send(B_F8)
*9::Send(B_F9)
*0::Send(B_F10)
*-::Send(B_F11)
*sc00D::Send(B_F12) ; sc00D = "^"
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
;sc028::Return ;vkBAsc028 = ":" shift:*
*]::Send("{Blind}^]")

*z::Send(B_UNDO) ;undo
*x::Send(B_CUT) ;cut
*c::Send(B_COPY) ;copy
*v::Send(B_PASTE) ;paste
*b::Send(B_UNDO) ;undo
*n::Send(B_END)
*m::Send(B_DEL)
*sc033::Send(B_CLEFT) ;vkBCsc033 = ,
*.::Send(B_CRIGHT)
sc035::Send("^+{sc07D}") ;sc035 = "/" sc07D = \(|)

*Enter::Send("{Blind}^{Enter}")

#HotIf

;***M1**************************************************************************
#HotIf ModifiedState(1) && !ModifiedState(3) && !ModifiedState(4) && !ModifiedState(5) 
*a::Send("{Blind}^a")
sc029::Send(C_EISU) ; vkF3sc029 = 全角/半角 vkF0sc03A = Eisu
+sc029::ToggleForceImeOn() ; vkF3sc029 = 全角/半角 vkF0sc03A = Eisu
Esc::Reload

q::#!space
*e::Send(B_ESC)
r::+F3
*s::Send("{Blind}^s")
*d::Send("{Blind}^{Space}") 
*f::Send(B_TAB)
g::Send("^f")

F14::ToggleImeState()
sc079::ToggleImeState() ;conv
space::ToggleImeState()


;*space::Send(B_BS)
#r::ChangeFMIX14_FMIX14R_Layout()
#f::ChangeFMIX12f_FMIX13fR_Layout()
#d::ChangeFMIX12f_Layout()
#s::ChangeFMIX13_FMIX14R_Layout()
#x::ChangeFMIX13f_FMIX14R_Layout()

#o::ChangeOonishiLayout()
#c::ChangeColemakLayout()

#up::MouseSpeed.IncSpeed()
#down::MouseSpeed.DecSpeed()


#HotIf

;***M2**************************************************************************
#HotIf ModifiedState(2)
q::Send("?")
w::+F3
*e::Send("{Blind}/")
*r::Send(B_NMUL) 
*t::Send(B_NADD)

*a::Send("(")
*s::Send(")")
*d::Send("_")
*f::Send("{Blind}-")
g::Send("=")

 
F14::ToggleImeState()
sc079::ToggleImeState() ;conv
#HotIf
 
;***M4**************************************************************************
#HotIf !ModifiedState(1) && ModifiedState(4) 

6::Send("{Escape}")
7::Send(C_N7)
8::Send(C_N8)
9::Send(C_N9)
0::Send(B_NMUL)
-::Send(B_NSUB)
sc00D::Send(C_HAT)
sc07D::Send("\")

t::Send(B_NADD)

a::Send("(")
s::Send(")")
f::Send("-")
g::Send("=")

y::Send(C_BS)
u::Send(C_N4)
i::Send(C_N5)
o::Send(C_N6)
p::Send(B_NADD)
@::Send(B_UP)

h::Send("=")
j::Send(C_N1)
k::Send(C_N2)
l::Send(C_N3)
sc027::Send(B_LEFT) ;; 
sc028::Send(B_DOWN) ;:
]::Send(B_RIGHT)

n::Send(C_DEL)
m::Send(C_N0)
sc033::Send(C_COMMA) ;.
.::Send(C_NDOT)
sc035::Send(B_NDIV)
sc073::Send("\")
space::Send(B_ENTER)

; up::Send(B_UP)
; down::Send(B_DOWN)
; left::Send(B_LEFT)
; right::Send(B_RIGHT)
#HotIf

;***Symbol**************************************************************************
#HotIf ModifiedState(6) && !ModifiedState(1) && !ModifiedState(2) && !ModifiedState(3) && !ModifiedState(4) && !ModifiedState(5)
;#HotIf ModifiedStateX([6])
q::Send("[")
w::Send("]")
e::Send("+1") ;'
r::Send("+5") ;'
t::Send("~") ;

a::Send("+6") ;&
s::Send("+7") ;''
d::Send("+2") ;"
*f::Send("{Blind}k") ;"
*g::Send("{Blind}y") ;"

z::Send("+[") ;{}
x::Send("+]") ;}
c::Send(":") ;:
v::Send("|") ;| vertical bar
b::Send("\") ;\

u::send("{Backspace}")
h::Send(C_HAT) ;^
i::Send("+4") ;$
o::Send("+k")
p::Send("+y")

j::Send("=") ;
k::Send("0") ;"
l::Send("->") ;"
sc027::Send(C_SEMICOLON) ;; 

n::Send("+3") ;# Numbed Sign
m::Send("{Delete}") ;
sc033::Send("<=") ; sc033 = ,
.::Send(">=")

space::Send("{Enter}") ; Enter
#HotIf

;***shift**************************************************************************
#HotIf (ModifiedState(5) || ModifiedState(4) ) && !ModifiedState(1) && !ModifiedState(2) && !ModifiedState(3)
1::k1.SendShiftedKey()
2::k2.SendShiftedKey()
3::k3.SendShiftedKey()
4::k4.SendShiftedKey()
5::k5.SendShiftedKey()

q::q.SendShiftedKey()
w::w.SendShiftedKey()
e::e.SendShiftedKey()
r::r.SendShiftedKey()
t::t.SendShiftedKey()

a::a.SendShiftedKey()
s::s.SendShiftedKey()
d::d.SendShiftedKey()
f::f.SendShiftedKey()
g::g.SendShiftedKey()

z::z.SendShiftedKey()
x::x.SendShiftedKey()
c::c.SendShiftedKey()
v::v.SendShiftedKey()
b::b.SendShiftedKey()

6::k6.SendShiftedKey()
7::k7.SendShiftedKey()
8::k8.SendShiftedKey()
9::k9.SendShiftedKey()
-::minus.SendShiftedKey()
sc00D::hat.SendShiftedKey()
sc07D::backslash.SendShiftedKey()

y::y.SendShiftedKey()
u::u.SendShiftedKey()
i::i.SendShiftedKey()
o::o.SendShiftedKey()
p::p.SendShiftedKey()
@::at.SendShiftedKey()
[::openbracket.SendShiftedKey()

h::h.SendShiftedKey()
j::j.SendShiftedKey()
k::k.SendShiftedKey()
l::l.SendShiftedKey()
sc027::semicolon.SendShiftedKey()
sc028::+sc028
]::+]

n::n.SendShiftedKey()
m::m.SendShiftedKey()
sc033::comma.SendShiftedKey()
.::period.SendShiftedKey()
sc035::slash.SendShiftedKey()
sc073::backslash2.SendShiftedKey()
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
*sc00D::hat.Down("{sc00D}")
*sc00D up::hat.Up()
*sc07D::backslash.Down("{sc07D}")
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


*z::z.Down("z")
*z up::z.Up()
*x::x.Down("x")
*x up::x.Up()
*c::c.Down("c")
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
*Space::space.Down()

*Space up::space.Up()
*tab::tab.Down()
*tab up::tab.Up()

*F13::f13.Down()
*F13 up::f13.Up()

*F14:: f14.Down()
*F14 up::f14.Up() 

*sc079:: f14.Down() ;conv
*sc079 up::f14.Up() ;conv
	
sc07B::noconv.Down() ;vk1Dsc07B = 無変換
sc07B up::noconv.Up() 


;NumLock::Return
+F15::Send("{NumLock}")
;*F15::Send("{NumLock}") ;NumLock

>+Up::_
^+F13::Send("+{CapsLock}") ;Change CapsLock off setting to shift on Windows setting
+sc029::Send(C_EISU) ;vkF3sc029 = 全角/半角 
sc029::ToggleImeState() ;vkF3sc029 = 全角/半角

#SuspendExempt
#!Enter::Suspend
#SuspendExempt False

#MaxThreadsBuffer False
