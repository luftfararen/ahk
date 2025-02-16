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
			SendInput("{Blind}" . this.mod_str . this.key_str)
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
colon := RKey(C_COLON)
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
;sc028::Return ;vkBAsc028 = ":" shift:*
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
Esc::Reload

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
#HotIf

;***M5**************************************************************************
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

6::Send("{Escape}")
7::Send(C_N7)
8::Send(C_N8)
9::Send(C_N9)
0::Send(B_NMUL)
;-::Send("-")
sc00D::Send(C_HAT)
sc07D::Send("\")

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
*sc027::Send(B_LEFT) ;; 
*sc028::Send(B_DOWN) ;:
]::Send(B_RIGHT)

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
Esc::{
	;MouseSpeed.Reset()
;	MouseSpeed.Reset()
	Send("{Escape}")
	;Reload
}

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
