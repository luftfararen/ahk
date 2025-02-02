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
S_BACKSLASH := "sc07D" 
C_BACKSLASH := "{sc07D}"
B_BACKSLASH := "{Blind}{sc07D}"

;vkE2sc073 = \ shift:_
S_BACKSLASH2 := "sc073" 
C_BACKSLASH2 := "{sc073}" 

;sc00D =^
S_HAT := "sc00D"
C_HAT := "{sc00D}"

;vkBBsc027 = ; shift:+
S_SEMICOLON := "sc027" 
C_SEMICOLON := "{sc027}" 
B_SEMICOLON := "{Blind}{sc027}" 
C_PLUS := "+{sc027}" 

;vkBAsc028 = : shift:*
S_COLON := "sc028"
C_COLON := "{sc028}"
B_COLON := "{Blind}{sc028}"
C_ASTERISK := "+{sc028}"

;vkBCsc033 = ,
S_COMMA := "sc033"
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

S_SLASH := "sc035"
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

IsImeOn()
{
	hwnd := WinActive("A")
	return DllCall("SendMessage", "UInt", DllCall("imm32\ImmGetDefaultIMEWnd", "Uint",hwnd),
		"UInt", 0x0283,  "Int", 0x0005,  "Int", 0) 
}

SendDepOn(key_ime_off,key_ime_on:="")
{
	if IsImeOn && key_ime_on != ""{
		Send(key_ime_on)
	}else{
		Send(key_ime_off)
	}
}
/*============================================================================
Class to assign different key for long press.
============================================================================*/
class SwapKey
{
	static use_registered_key_for_ctrl  := true ;for ctrl or alt

/*============================================================================
	key: 		base key.
	long_key: 	long pressed key, which inclueds "{}". 
				If blank, shifted key is generated automatically. If "none", does nothing.  
============================================================================*/
	__New(key, shift_key:="")
	{
		this.SetKey(key,shift_key)
		this.short_ime_key_str := "" 
		this.shift_ime_key_str := ""
	}

	SetIMEKey(key, shift_key:="")
	{
		;this.ime_key := key
		if SubStr(key,1,1) != "{" {
			key := "{" . key . "}"
		}
		this.short_ime_key_str := "{Blind}" .  key 

		if shift_key = ""{
			this.shift_ime_key_str :=  "+" . key
		}else{
			this.shift_ime_key_str :=  shift_key 
		}
	}
	
	SendShiftedKey(shift)
	{
		if  shift  {
			if IsImeOn && this.shift_ime_key_str != "" {
				Send(this.shift_ime_key_str )
			}else{
				Send(this.shift_key_str )
			}
			return true
		}else{ 
			if IsImeOn && this.short_ime_key_str != ""{
				Send(this.short_ime_key_str)
			}else{
				Send(this.short_key_str) ;Sends key in blind mode
			}
			return false
		}
	}

/*============================================================================
	key: 		base key.
	shift_key: 	shift key, which inclueds "{}". 
				If blank, shifted key is generated automatically.
============================================================================*/
	SetKey(key, shift_key:="")
	{
		this.key := key
		if SubStr(key,1,1) != "{" {
			key := "{" . key . "}"
		}
		this.short_key_str := "{Blind}" .  key 

		if shift_key = ""{
			this.shift_key_str :=  "+" . key
		}else{
			this.shift_key_str :=  shift_key 
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
		if SwapKey.use_registered_key_for_ctrl ||  pressed_key = ""{
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
} ;class SwapKey



/*============================================================================
Class to skip long press for modifier.
============================================================================*/
class ModKey
{
/*============================================================================
	key: base key, not inclueds "{}".
============================================================================*/
	__New(key,timeout:=200)
	{
		this.key := key
		this.key_str := "{" . key . "}"
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
} ;class ModKey

f13 := ModKey(S_ZENKAKU,200) ;m1
space := ModKey("Space") ;m2
tab := ModKey("Tab") ;m3
noconv := ModKey(B_ENTER) ;m4
;conv := ModKey(B_ENTER) ;m1
f14 := ModKey(B_ENTER) ;m5

k1 := SwapKey("1")
k2 := SwapKey("2")
k3 := SwapKey("3")
k4 := SwapKey("4")
k5 := SwapKey("5")
k6 := SwapKey("6")
k7 := SwapKey("7")
k8 := SwapKey("8")
k9 := SwapKey("9")
k0 := SwapKey("0","none")
minus := SwapKey("-")
hat := SwapKey(S_HAT)
backslash := SwapKey("\")
;
q := SwapKey("q")
w := SwapKey("w")
e := SwapKey("e")
r := SwapKey("r")
t := SwapKey("t")
;
y := SwapKey("y")
u := SwapKey("u")
i := SwapKey("i")
o := SwapKey("o")
p := SwapKey("p")
at := SwapKey("@")
openbracket := SwapKey("[")
;
a := SwapKey("a")
s := SwapKey("s")
d := SwapKey("d")
f := SwapKey("f")
g := SwapKey("g")
;
h := SwapKey("h")
j := SwapKey("j")
k := SwapKey("k")
l := SwapKey("l")
semicolon := SwapKey(S_SEMICOLON)
colon := SwapKey(S_COLON)
closebracket := SwapKey("]")
;
z := SwapKey("z")
x := SwapKey("x")
c := SwapKey("c")
v := SwapKey("v")
b := SwapKey("b")
;
n := SwapKey("n")
m := SwapKey("m")
comma := SwapKey(S_COMMA)
period := SwapKey(".")
slash := SwapKey("/")
backslash2 := SwapKey("_")
;
up    := SwapKey("up","none")
down  := SwapKey("down","none")
left  := SwapKey("left","none")
right := SwapKey("right","none")


ChangeASRTLayout()
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


ChangeKSTNHLayout()
{
	global minus
	global q,w,e,r,t,y,u,i,o,p
	global a,s,d,f,g,h,j,k,l,semicolon
	global b,n,m,comma,period,slash

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

ModifiedState(m)
{
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
;r::Return
*a::Send("{Blind}^a")
*s::Send("{Blind}^s")
*d::Send("{Blind}^{Space}") 
*f::Send(B_TAB)
g::Send("^f")

F14::Send(C_ZENKAKU) 
sc079::Send(C_ZENKAKU) ;conv
*space::Send("{Blind}{Backspace}")
#k::ChangeKSTNHLayout()
#a::ChangeASRTLayout()
#f::ChangeFMIX15Layout()
#HotIf

;***M2**************************************************************************
#HotIf ModifiedState(2)
q::Send("?")
w::+F3
*e::Send(B_SLASH)
*r::Send(B_NADD) 
*t::Send(B_NMUL)
*a::Send("{Blind}^a")
s::Send("()")
d::Send("_")
*f::Send("{Blind}-")
g::Send("=")


F14::Send(C_ZENKAKU) 
sc079::Send(C_ZENKAKU) ;conv
#HotIf

;***M3**************************************************************************
#HotIf ModifiedState(3) 
1::Send("^z")
2::Send("^x")
3::Send("^c")
4::Send("^v")
q::Send("^z")
w::Send("^x")
e::Send("^c")
r::Send("^v")

y::Send(C_REDO)
u::Send(C_BS)
i::Send("+{Up}")
o::Send("+{PgUp}")
p::Send("+{PgDn}")
h::Send("+{Home}")
j::Send("+{Left}")
k::Send("+{Down}")
l::Send("+{Right}")
sc027::Send("{Enter}") ;vkBBsc027 = ; shift:+
Enter::Send("{Enter}")
n::Send("+{End}")
m::Send(C_DEL)
space::Send(C_BS)

;***M4**************************************************************************
#HotIf ModifiedState(4)
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

w::Send('""{Left}')
e::Send("''{Left}")
a::Send("<>{Left}")
s::Send("(){Left}")
d::Send("[]{Left}")
f::Send("+[+]{Left}")
;g::Send(B_BACKSLASH)

h::Send("=")
j::Send(C_N1)
k::Send(C_N2)
l::Send(C_N3)
*sc027::Send(B_LEFT) ;; 
*sc028::Send(B_DOWN) ;:
]::Send(B_RIGHT)

n::Send("{Delete}")
m::Send(C_N0)
sc033::Send(C_COMMA) ;.
.::Send(C_NDOT)
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
6::+6
7::+7
8::+8
9::+9

q::Send("?")
w::Send("&")
e::Send("|")
r::Send(C_HAT)
;t::Send("~")
u::Send("+{@}")
i::Send("+[")
o::Send("+]")

a::Send("@")
s::Send("$")
g::Send("#")

h::Send("~")
k::Send("[")
l::Send("]")

z::Send('"')
x::Send("'")
c::Send(B_COLON)
v::Send(B_SEMICOLON)
b::Send("\")
n::Send("%")

;***Long Press**************************************************************************
#HotIf ;ModifiedState(false,false,false,false) 
*1::k1.Down()
*1 up::k1.Up()
*2::k2.Down()
*2 up::k2.Up()
*3::k3.Down()
*3 up::k3.Up()
*4::k4.Down()
*4 up::k4.Up()
*5::k5.Down()
*5 up::k5.Up()
*6::k6.Down()
*6 up::k6.Up()
*7::k7.Down()
*7 up::k7.Up()
*8::k8.Down()
*8 up::k8.Up()
*9::k9.Down()
*9 up::k9.Up()
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
