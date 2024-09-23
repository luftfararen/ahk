#Requires AutoHotkey v2.0

;win #   ctrl ^   shift +   alt !

;used directly
;- ^ ¥ @ [ ] . /

;used with {}
;Space Tab Enter BS Del Ins Left  Right Up Down Home End PgUp PgDn Esc Pause

;vk1Dsc07B = NoConvert 無変換
S_NOCONV := "sc07B" 
C_NOCONV := "{sc07B}" 

;vk1Csc079 = Convert 変換
S_CONV := "sc079" 
C_CONV := "{sc079}" 

;sc07D = \; shift:|
S_BACKSLASH := "sc07D" 
C_BACKSLASH := "{sc07D}" 

;vkE2sc073 = \ shift:_
S_BACKSLASH2 := "sc073" 
C_BACKSLASH2 := "{sc073}" 

;sc00D =^
S_HAT := "sc00D"
C_HAT := "{sc00D}"

;vkBBsc027 = ; shift:+
S_SEMICOLON := "sc027" 
C_SEMICOLON := "{sc027}" 
C_PLUS := "+{sc027}" 

;vkBAsc028 = : shift:*
S_COLON := "sc028"
C_COLON := "{sc028}"
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
C_SLASH:="{sc035}"

;SingleInstkance Force
ProcessSetPriority "Realtime"
SendMode "Input"

InstallKeybdHook true
InstallMouseHook true
#UseHook true
#MaxThreadsBuffer True
;#MaxThreadsPerHotkey 3 ;If enabled, it's unstable.
SetKeyDelay 0


IsDisplayCode(key)
{
	code := 0
	sc_pos := InStr(key,"sc")
	if sc_pos > 0 {
		num := "0x" . SubStr(key,sc_pos+2,3)
		;ToolTip key . IsNumber(num)
		code := Integer(num)

		if code = 0x0e{ ;Backspace
			return false
		}
		if code = 0x0f{ ;Tab
			return false
		}
		if code = 0x1c{ ;Enter
			return false
		}
		if code = 0x1d{ ; Left Ctrl
			return false
		}
	
		;1234567890-^ QWERTYUIOP@[ ASDFGHJKL;:
		if 0x02 <= code and code <= 0x28{
			return true 
		}
		;],z-/
		if 0x2b <= code and code <= 0x35{
			return true
		}
		;\(|) \(_) 
		if code = 0x7d or code = 0x73{
			return true
		}
		
		return false
	}else{
		code := Ord(key)
		if 0x21 <= code and code <= 0x7e{
			return true 
		}
		return false


	}
}

class SlowMouse
{
	static SPI_GETMOUSESPEED := 0x70e
	static SPI_SETMOUSESPEED := 0x71
	static OrigMouseSpeed := 10

	static MakeSlow()
	{
		temp:=0
		DllCall("SystemParametersInfo", "UInt", SlowMouse.SPI_GETMOUSESPEED, "UInt", 0, "Ptr*", &temp, "UInt", 0)
		;tooltip String(temp)
		if temp > 1{
			SlowMouse.OrigMouseSpeed := temp
		}
		DllCall("SystemParametersInfo", "UInt", SlowMouse.SPI_SETMOUSESPEED, "UInt", 0, "Ptr", 1, "UInt", 0)
	}

	static Reset()
	{
		DllCall("SystemParametersInfo", "UInt", SlowMouse.SPI_SETMOUSESPEED, "UInt", 0, "Ptr", SlowMouse.OrigMouseSpeed , "UInt", 0)
	}
}

MoveMousePos(rx, ry)
{
  size := 4
  point := Buffer(size * 2)
  DllCall("GetCursorPos", "Ptr", point)
  x := NumGet(point, 0, "Int")
  y := NumGet(point, size, "Int")
  DllCall("SetCursorPos", "Int", x+rx, "Int", y+ry)
} 

OperateMouse(cmd,shift,ctrl)
{
	static mouse_move := A_ScreenWidth/160
	static mouse_move_short := A_ScreenWidth/320
	static mouse_move_long := A_ScreenWidth/8
	if cmd = ""{
		return
	} else if cmd ="MouseLClick" {
		MouseClick("left")
	} else if cmd = "MouseRClick"{
		MouseClick("right")
	} else if cmd = "MouseWheelUp"{
		Send("{WheelUp}")
	} else if cmd = "MouseWheelDown"{
		Send("{WheelDown}") 
	} else if cmd = "MouseBack"{
		Send("!{Left}")
	} else if cmd = "MouseNext"{
		Send("!{Right}")
	}else{
		if shift != 0 {
			m := mouse_move_short
		} else if ctrl != 0{
			m := mouse_move_long
		}else{
			m := mouse_move
		}
		if cmd = "MouseUp"{
			MoveMousePos(0,-m)
		} else if cmd = "MouseLeft"{
			MoveMousePos(-m,0)
		} else if cmd = "MouseDown"{
			MoveMousePos(0,m) 
		} else if cmd = "MouseRight"{
			MoveMousePos(m,0) 
		}
	}
}

/*============================================================================
Class to change layer
============================================================================*/
class LayerKey
{
	static idx := 0
	static ChangeLayer(num)
	{
		if LayerKey.idx != num{
			LayerKey.idx := num
			if LayerKey.idx = 0{
				ToolTip ;hides ToolTip
			}else if LayerKey.idx = 1{
				ToolTip("10 key mode",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = 2{
				ToolTip("Mouse mode",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = 3{
				ToolTip("Cursor mode",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = 4{
				ToolTip("Select mode",A_ScreenWidth,A_ScreenHeight)
			}
		}
	}

/*============================================================================
	key: 		base key, not inclueds "{}"
	key1: 		key for mode1 
	key2: 		key for mode2
===========================================================================*/
	__New(key,  key1 := "", key2 := "")
	{
		this.key := key
		this.key1 := key1
		this.key2 := key2
	}

	Down(shift :=0, ctrl := 0)
	{	
		if LayerKey.idx = 1 && this.key1 != "" {
			SendEvent(this.key1)
			return
		}else if LayerKey.idx = 2 && this.key2 != "" {
			;SendEvent this.key2
			OperateMouse(this.key2,shift,ctrl)
			return
		}else{
			SendInput("{Blind}{" . this.key . "}")
		}
	}
}

/*============================================================================
Class to assign different key for long press
============================================================================*/
class LongPress
{
	static long_press_th := 300 ;if pressing for more this time, long press process runs in Up()
	static last_key := ""

/*============================================================================
	key: 		base key, not inclueds "{}"
	long_key: 	long pressed key, which inclueds "{}". If blank, shifted key is generated automatically.
============================================================================*/
	__New(key, long_key:="")
	{
		this.key := key
		;this.shiftable := IsDisplayCode(this.key)
	
		if SubStr(key,1,1) != "{" {
			key := "{" . key . "}"
		}
		this.short_key_str := "{Blind}" .  key 
		if long_key = ""{
			this.long_key_str :=  "+" . key
		}else{
			this.long_key_str := long_key
		}
		this.send_time := 0
		this.pressed_time := 0
	}

	
	;DownImpl(shift :=0, ctrl := 0, alt := 0, win := 0)
	DownImpl()
	{
		if LongPress.last_key = this.key && this.send_time > 0{
			if A_TickCount - this.send_time < LongPress.long_press_th{
			 	return
			}
		}
		LongPress.last_key := this.key

		shift := GetKeyState("Shift","P")
		ctrl := GetKeyState("Ctrl","P")
		alt := GetKeyState("Alt","P")
		win := GetKeyState("LWin","P") || GetKeyState("RWin","P")
		if !(ctrl || shift || alt || win) {
			this.pressed_time  := A_TickCount
		} ;else this.pressed_time  := 0 ;skip up method()
		Send(this.short_key_str) ;Send key in blind mode
	}

/*============================================================================
	Assign this method to hotkey. 
	ex)
	x := LongPress("x")
	x::x.Down()
	x::x.Up()
============================================================================*/
	Down()
	{
		LayerKey.ChangeLayer(0)
		this.DownImpl()
	}

/*============================================================================
	Assign key up to the key as same as registered.  
	See Down() method for the detail.
============================================================================*/
	Up()
	{
		if this.pressed_time >0 {
			time := A_TickCount
			if time - this.pressed_time  >= LongPress.long_press_th {
				if LongPress.last_key = this.key {
					this.send_time := time
					Send("{BackSpace}" . this.long_key_str )
					this.pressed_time  := 0
					return
				}
			}
		}
		this.send_time := 0
		this.pressed_time  := 0
	}
}

/*============================================================================
Class to assign different key for long press with layer change.
LongPressL is complicated and not versatile due to mouse operation with shift or/and ctrl key.
============================================================================*/
class LongPressL extends LongPress 
{

/*============================================================================
	key: 		base key, not inclueds "{}"
	long_key: 	long pressed key, inclueds "{}"
	key1: 		key for mode1 
	key2: 		key for mode2, currently only for mouse operation
	key3: 		key for mode3
	key4: 		key for mode3
===========================================================================*/
	__New(key, long_key:="", key1 := "", key2 := "", key3 := "", key4 := "")
	{
		super.__New(key, long_key)
		this.key1 := key1
		this.key2 := key2
		this.key3 := key3
		this.key4 := key4
	}
	
/*===========================================================================
	Assign this method to hot key.
	Defines shift/ctrl combination if they are used
	Shift and Ctrl is used only for mouse operation 
	ex1)
	x := LongPressL("x","","","MouseDown")
	x::x.Down()
	x up ::x.Down()
===========================================================================*/
	Down()
	{	
		if LayerKey.idx = 1 && this.key1 != "" {
			Send(this.key1)
			return
		}
		if LayerKey.idx = 3 && this.key3 != "" {
			Send(this.key3)
			return
		}
		if LayerKey.idx = 4 && this.key4 != "" {
			Send(this.key4)
			return
		}
		if LayerKey.idx = 2 && this.key2 != "" {
			;Send(this.key2)
			shift := GetKeyState("Shift","P")
			ctrl := GetKeyState("Ctrl","P")
			OperateMouse(this.key2,shift,ctrl)
			return
		}
		;base key down 
		super.DownImpl()
	}

	; Proc(key)
	; {
	; 	if key == this.key {
	; 		this.Down()
	; 	}else if InStr(key,"up") > 0 {
	; 		this.Up() ;currently Up() method is sharead when shirt or ctrl is pressed
	; 	}else{
	; 		shift := InStr(key,"+") > 0 ? 1 : 0
	; 		ctrl  := InStr(key,"^") > 0 ? 1 : 0
	; 		this.Down(shift,ctrl)
	; 	}
	; }
}

/*============================================================================
Class to skip long press for modifier
============================================================================*/
class ModKey
{
	static timeout := 300

/*============================================================================
	key: base key, not inclueds "{}"
============================================================================*/
	__New(key)
	{
		this.key := key
		this.key_str := "{" . key . "}"
		this.pressed_time := 0
		this.mod_str := ""
	}

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
	Assign key down to the key  
============================================================================*/
	Down()
	{
		if this.pressed_time != 0 {
			return
		}
		this.pressed_time := A_TickCount
		this.SetModStr()
	}

/*============================================================================
	Assign key up to the key. Code is send in this method if short press.  
============================================================================*/
	Up()
	{
		if (A_TickCount - this.pressed_time < ModKey.timeout) {
			SendInput("{Blind}" . this.mod_str . this.key_str)
		}
		this.pressed_time := 0
	}


	Reset()
	{
		this.pressed_time := 0
	}
}

space := ModKey("Space")
f14   := ModKey("Enter")
noconv := ModKey(S_ZENKAKU)

k1 := LongPress("1")
k2 := LongPress("2")
k3 := LongPress("3")
k4 := LongPress("4")
k5 := LongPress("5")
k6 := LongPressL("6","","{Escape}")
k7 := LongPressL("7","","7")
k8 := LongPressL("8","","8")
k9 := LongPressL("9","","9")
minus := LongPressL("-","","-")
hat := LongPress(S_HAT)
backslash := LongPressL("\")
;
q := LongPress("q")
w := LongPressL("w","","","MouseWheelUp")
e := LongPress("e")
r := LongPress("r")
t := LongPress("t")
;
y := LongPressL("y","","{Delete}","","{Delete}")
u := LongPressL("u","","4","MouseLClick","{BackSpace}")
i := LongPressL("i","","5","MouseUp","{Blind}{Up}","{Blind}+{Up}")
o := LongPressL("o","","6","MouseRClick")
p := LongPressL("p","","{Backspace}")
at := LongPressL("@","",C_PLUS)
openbracket := LongPressL("[","","+8")
;
a := LongPressL("a","","","MouseBack")
s := LongPressL("s","","","MouseWheelDown")
d := LongPressL("d","","","MouseNext")
f := LongPress("f")
g := LongPress("g")
;
h := LongPressL("h","","{Backspace}","MouseWheelUp","{Blind}{Home}","{Blind}+{Home}")
j := LongPressL("j","","1","MouseLeft","{Blind}{Left}","{Blind}+{Left}")
k := LongPressL("k","","2","MouseDown","{Blind}{Down}","{Blind}+{Down}")
l := LongPressL("l","","3","MouseRight","{Blind}{Right}","{Blind}+{Right}")
semicolon := LongPressL(S_SEMICOLON,"","{Enter}","","{Enter}")
colon := LongPressL(S_COLON,"",C_ASTERISK)
closebracket := LongPressL("]","","+9")
;
z := LongPressL("z","","","","^z","^z")
x := LongPressL("x","","","","^x","^x")
c := LongPressL("c","","","","^x","^x")
v := LongPressL("v","","","","^v","^v")
b := LongPressL("b","","","","^z","^z")
;
n := LongPressL("n","","","MouseWheelDown","{Blind}{End}","{Blind}+{End}")
m := LongPressL("m","","0","MouseBack","^{Left}","^+{Left}")
comma := LongPressL(S_COMMA,"",C_COMMA,"","^{Right}","^+{Right}")
perid := LongPressL(".","","")
slash := LongPressL("/","","/")
backslash2 := LongPress(S_BACKSLASH2)
;
up    := LayerKey("up","","MouseWheelUp")
down  := LayerKey("down","","MouseWheelDown")
left  := LayerKey("left","","MouseBack")
right := LayerKey("right","","MouseNext")

IsF13Pressed()
{
	return GetKeyState("F13","P")
}

IsSpaceOrF13Pressed()
{
	return space.IsPressed() || GetKeyState("F13","P")
}

IsSpaceAndF13Pressed()
{
	f13_pressed := GetKeyState("F13","P") 
	if space.IsPressed() && f13_pressed{
		return 1
	}
	/*
	if semicolon.IsPressed() && f13_pressed{
		return 1
	}
	if semicolon.IsPressed() != 0 && space.IsPressed() {
		return 1
	}
	*/
	return 0 
}

IsF14Pressed()
{
	;vk1Dsc07B = NoConvert 無変換
	return GetKeyState("F14", "P") || GetKeyState(S_CONV, "P") || GetKeyState(S_NOCONV, "P")
}

SendDirKey(key)
{
	; if IsSpaceAndF13Pressed(){
	; 	Send("{Blind}^" . key)
	; }else{
		Send("{Blind}" . key)
	; }
}
  
;*****************************************************************************
#HotIf IsF14Pressed() || IsSpaceAndF13Pressed()
*i::Send("{Blind}+{Up}")
*j::Send("{Blind}+{Left}")
*k::Send("{Blind}+{Down}")
*l::Send("{Blind}+{Right}")
*o::Send("{Blind}+{Right}")
*p::Send("{Blind}+^{Right}")
*sc033::Send("{Blind}+^{Right}") ;vkBCsc033 = ,
*m::Send("{Blind}+^{Left}")
*h::Send("{Blind}+{Home}")
*n::Send("{Blind}+{End}")
sc027::Enter ;vkBBsc027 = ; shift:+

@::Send("^{Home}")
[::Send("^{End}")

u::Backspace
y::Delete

q::^a
a::^z
s::^x
d::^c
f::^v
g::^y

z::^z
x::^x
c::^c
v::^v
b::^z

#HotIf WinActive("ahk_exe code.exe") && IsSpaceOrF13Pressed() && IsF14Pressed() = 0
]::Send("^+" . C_BACKSLASH) ;sc07D = \; shift:|
sc073::!Left ;sc073 = \; shift:_

#HotIf WinActive("ahk_exe code.exe")
^]::Send("^+" . C_BACKSLASH) ;sc07D = \; shift:|\

#HotIf IsSpaceOrF13Pressed() && IsF14Pressed() = 0 && IsSpaceAndF13Pressed() = 0
*j::SendDirKey("{Left}")
*l::SendDirKey("{Right}")
*o::SendDirKey("{Right}")
*h::SendDirKey("{Home}")
*n::SendDirKey("{End}")
*i::SendDirKey("{Up}")
*k::SendDirKey("{Down}")
*p::Send("{Blind}^{Right}")
*sc033::Send("{Blind}^{Right}") ;vkBCsc033 = ,
*m::Send("{Blind}^{Left}")

*@::Send("{Blind}{PgUp}")
*[::Send("{Blind}{PgDn}")
]::Send("^]")

*y::Send("{Blind}{Delete}")
*u::Send("{Blind}{BackSpace}")

sc027::Send("{Enter}") ;semicolon
sc028::^g ;vkBAsc028 = ":" shift:*

q::Esc
e::+F3
w::LayerKey.ChangeLayer(4)
s::^s
a::^a
d::LayerKey.ChangeLayer(3)

r::^h ;replace
t::^f ;find

g::^y ;redo
b::^z ;undo

f::Tab

z::^z ;undo
+z::^y ;redo
x::^x ;cut
c::^c ;copy
v::^v ;paste
sc073::^- ;vkE2sc073 = \ shift:_

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

sc079::Send(C_ZENKAKU) ;vvk1Csc079 = 変換 
F14::Send(C_ZENKAKU) 

.::LayerKey.ChangeLayer(2) ; mouse
sc035::LayerKey.ChangeLayer(1) ;/ 10key
sc073::LayerKey.ChangeLayer(3) ;vkE2sc073 = \ shift:_ cursor


;*****************************************************************************
;#HotIf semicolon.IsPressed() 
;Space::Send "{Enter}"
;*k::Send "{Blind}{Right}"

;***F13 Modifier**************************************************************************
#HotIf IsF13Pressed()
Tab::Send(C_EISU) ;vkF0sc03A = Eisu
sc029::Send(C_EISU) ; vkF3sc029 = 全角/半角 vkF0sc03A = Eisu
Esc::{
	SlowMouse.Reset()
	Reload
}

F14::Send(C_ZENKAKU) 
sc079::Send(C_ZENKAKU) ;conv

#HotIf space.IsPressed()
F14::Send(C_ZENKAKU) 
sc079::Send(C_ZENKAKU) ;conv

;***Long Press**************************************************************************
#HotIf IsSpaceOrF13Pressed() == 0 && IsF14Pressed() == 0 
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
*-::minus.Down()
*- up::minus.Up()
*sc00D::hat.Down()
*sc00D up::hat.Up()
*sc07D::backslash.Down()
*sc07D up::backslash.Up()
;
*q::q.Down()
*q up::q.Up()
*w::{
	if LayerKey.idx = 4 {
		LayerKey.ChangeLayer(3)
		return
	}
	if LayerKey.idx = 3 {
		LayerKey.ChangeLayer(4)
		return
	}
	w.Down()
}
*w up::w.Up()
*e::e.Down()
*e up::e.Up()
*r::r.Down()
*r up::r.Up()
*t::t.Down()
*t up::t.Up()
*y::y.Down()
*y up::y.Up()
*u::u.Down()
*u up::u.Up()
*i::i.Down()
*i up::i.Up()
*o::o.Down()
*o up::o.Up()
*p::p.Down()
*p up::p.Up()
*@::at.Down()
*@ up::at.Up()
*[::openbracket.Down()
*[ up::openbracket.Up()
;

*a::a.Down()
*a up::a.Up()
*s::s.Down()
*s up::s.Up()
*d::d.Down()
*d up::d.Up()
*f::f.Down()
*f up::f.Up()
*g::g.Down()
*g up::g.Up()
*h::h.Down()
*h up::h.Up()

*j::j.Down()
*j up::j.Up()

*k::k.Down()
*k up::k.Up()

*l::l.Down()
*l up::l.Up()

*sc027::semicolon.Down()
*sc027 up::semicolon.Up()
*sc028::colon.Down()
*sc028 up::colon.Up()
*]::closebracket.Down()
*] up::closebracket.Up()
;

*z::z.Down()
*z up::z.Up()
*x::{
	x.Down()
	if LayerKey.idx = 4 {
		LayerKey.ChangeLayer(3)
	}
}
*x up::x.Up()
*c::{
	c.Down()
	if LayerKey.idx = 4 {
		LayerKey.ChangeLayer(3)
	}
}
*c up::c.Up()
*v::v.Down()
*v up::v.Up()
*b::b.Down()
*b up::b.Up()
*n::n.Down()
*n up::n.Up()
*m::m.Down()
*m up::m.Up()
*sc033::comma.Down()
*sc033 up::comma.Up()
*.::perid.Down()
*. up::perid.Up()

*sc035::slash.Down()
*sc035 up::slash.Up()

*sc073::backslash2.Down()
*sc073 up::backslash2.Up()
;

down::down.Down()
up::up.Down()
left::left.Down()
right::right.Down()

;***ohter****************************************************************************
#HotIf 


*Space::{
	SlowMouse.MakeSlow()
	LayerKey.ChangeLayer(0)
	space.Down()
}

*Space up::{
	SlowMouse.Reset()
	if IsF13Pressed(){
		space.Reset()
		Send("{BackSpace}")
	}else{
		space.Up()
	}
}

Esc::{
	SlowMouse.Reset()
	LayerKey.ChangeLayer(0)
	Send("{Escape}")
}

F13::{
	SlowMouse.MakeSlow()
	LayerKey.ChangeLayer(0)
	;Send("{F13}")
}

F13 up::{
	SlowMouse.Reset()
}

*F14:: f14.Down()
*sc079:: f14.Down() ;conv

*F14 up::f14.Up() 
*sc079 up::f14.Up() ;conv
	
sc07B::noconv.Down() ;vk1Dsc07B = 無変換
sc07B up::noconv.Up() 


;NumLock::Return
+F15::Send("{NumLock}")

>+Up::_
^+F13::Send("+{CapsLock}") ;Change CapsLock off setting to shift on Windows setting


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
#MaxThreadsBuffer False
