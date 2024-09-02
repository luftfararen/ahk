#Requires AutoHotkey v2.0

;when using long_press mode, it its more stalbe to use "IMEv2.ahk"
;If "IMEv2.ahk" is not used,
;#Include "IMEv2.ahk" is comment out and IME_GET() function is enalbed.
#Include "IMEv2.ahk"
;IME_GET()  { 
;	return 0 
;}

;win #
;ctrl ^
;shift +
;alt !
;vk1Dsc07B = NoConvert 無変換
;vk1Csc079 = Convert 変換
;vkE2sc073 = \ shift:_
;sc07D = \; shift:|
;sc073 = \; shift:_
;sc070 =^
;vkBBsc027 = ; shift:+
;vkBAsc028 = : shift:*
;vkBCsc033 = ,
;vkF0sc03A = Eisu
;vkF2sc070 = Hiragana(ひらがな/カタカナ) , it is unstable to assign other key to this key.
;vkF3sc029 = 全角/半角 sendでおくらなければいけない 入れ替え元の場合、うまく動かない
;vkF4sc029 = 全角/半角 sendでおくらなければいけない
;- ^ ¥ @ [ ] . /
;Space Tab Enter BS Del Ins Left  Right Up Down Home End PgUp PgDn Esc Pause

;SingleInstkance Force
ProcessSetPriority "Realtime"
SendMode "Input"

InstallKeybdHook true
#UseHook true
#MaxThreadsBuffer True


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

class LayerKey
{
	static idx := 0
	static ChangeLayer(num)
	{
		if LayerKey.idx != num{
			LayerKey.idx := num
			if LayerKey.idx = 0{
				;TrayTip("Normal mode","",16)
				ToolTip ;hides ToolTip
			}else if LayerKey.idx = 1{
				;TrayTip("10 key mode","",16)
				ToolTip("10 key mode",A_ScreenWidth,A_ScreenHeight)
			}else if LayerKey.idx = 2{
				;TrayTip("Mouse mode","",16)
				ToolTip("Mouse mode",A_ScreenWidth,A_ScreenHeight)
			}
		}
	}

/*============================================================================
	key: 		base key, not inclueds "{}"
	long_key: 	long pressed key, inclueds "{}"
	kana 		True related kana key, False: not related kana key
	key1: 		key mode1 is locked 
	key2: 		key mode2 is locked
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
	static timeout := 300
	static last_key := ""

/*============================================================================
	key: 		base key, not inclueds "{}"
	long_key: 	long pressed key, inclueds "{}"
	kana 		True: related kana key, False: not related kana key
============================================================================*/
	__New(key, long_key:="")
	{
		this.key := key
		if SubStr(key,1,1) != "{" {
			key := "{" . key . "}"
		}
		this.short_key_str := "{Blind}" .  key 
		if long_key = ""{
			this.long_key_str :=  "+" . key
		}else{
			this.long_key_str := long_key
		}
		this.pressed_time := 0
		;this.pressed_time2 := 0
		this.end_down := False
		this.end_up := True
	}

	DownImpl(shift :=0, ctrl := 0)
	{
		;Critical
 		; if IME_GET() {
		;    	SendInput(this.short_key_str)
		;    	this.pressed_time := 0
		;    	return
		; }
		i := 20
		while this.end_up = False && i>0{
			Sleep(5)
			i := i-1
		}

		if this.end_up == False { ;いらない?
			Tooltip "this.end_up == False"
			return ;key repeat cancel
		}
		this.end_down := False
		;pressed_time := A_TickCount
		;this.pressed_time2 := 0
		LongPress.last_key := this.key
		SendInput(this.short_key_str)
		if shift != 0 && ctrl ==0{
			;this.pressed_time := 0 ; already set if this.pressed_time = 0, does nothin in Up()
			this.end_down := True
			return
		}
		this.pressed_time :=  A_TickCount ;If this.pressed_time is 0, Up() does nothing
		this.end_down := True
	}

	Down()
	{
		;Critical
		LayerKey.ChangeLayer(0)
		this.DownImpl()
	}

	Up()
	{
		this.end_up := False
		i := 20
		while this.end_down = False && i>0 {
			Sleep(5)
			i := i - 1
		}
		if this.pressed_time > 0{
			duration := A_TickCount - this.pressed_time
			if duration >= LongPress.timeout {
				if LongPress.last_key == this.key {
					this.pressed_time2 := A_TickCount
					;SendInput("{BackSpace}{Blind}" . this.long_key)
					SendEvent("{BackSpace}") ;SendIput does not work
					SendEvent( this.long_key_str)
				}else{
					ToolTip "last key is different"
				}
			}
			this.pressed_time := 0
		}
		this.end_up := True
	}
}

/*============================================================================
Class to assign different key for long press with layer change
============================================================================*/
class LongPress2 extends LongPress 
{

/*============================================================================
	key: 		base key, not inclueds "{}"
	long_key: 	long pressed key, inclueds "{}"
	kana 		True related kana key, False: not related kana key
	key1: 		key mode1 is locked 
	key2: 		key mode2 is locked
===========================================================================*/
	__New(key, long_key:="", key1 := "", key2 := "")
	{
		super.__New(key, long_key)
		this.key1 := key1
		this.key2 := key2
	}
	
/*============================================================================
	Defines shift/ctrl combination if they are used
	ex)
	x := LongPress2("x")
	x::x.Down()
	x up ::x.Down()
	+x::x.Down()
	^x::x.Down(0,1)
	+^x::x.Down(1,1)
===========================================================================*/
	Down(shift :=0, ctrl := 0)
	{	
		;Critical
		if LayerKey.idx = 1 && this.key1 != "" {
			SendEvent(this.key1)
			return
		}else if LayerKey.idx = 2 && this.key2 != "" {
			;SendEvent this.key2
			OperateMouse(this.key2,shift,ctrl)
			return
		}
		super.DownImpl()
	}

	Up()
	{
		if LayerKey.idx = 1 && this.key1 != "" {
			return
		}else if LayerKey.idx = 2 && this.key2 != "" {
			return
		}
		super.Up()
	}
}

/*============================================================================
Class to ignore long press for modifier
============================================================================*/
class ModKey
{
	static timeout := 300

/*============================================================================
	key not inclue "{}"
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
	}

	Down()
	{
		if this.pressed_time != 0 {
			return
		}
		this.pressed_time := A_TickCount
		this.SetModStr()
	}

	Up()
	{
		if (A_TickCount - this.pressed_time < ModKey.timeout) {
			SendInput("{Blind}" . this.mod_str . this.key_str)
		}
		this.pressed_time := 0
		return
	} 
}

space := ModKey("Space")
f14 := ModKey("sc029")
;conv := ModKey("sc029")

k1 := LongPress("1")
k2 := LongPress("2")
k3 := LongPress("3")
k4 := LongPress("4")
k5 := LongPress("5")
k6 := LongPress("6")
k7 := LongPress2("7","","7")
k8 := LongPress2("8","","8")
k9 := LongPress2("9","","9")
minus := LongPress2("-","","-")							
hat := LongPress2("{sc00D}","+{sc00D}","^")
backslash := LongPress2("\","","\")

q := LongPress("q")
w := LongPress("w")
e := LongPress("e")
r := LongPress("r")
t := LongPress("t")
y := LongPress2("y","","{Delete}")
u := LongPress2("u","","4","MouseLClick")
i := LongPress2("i","","5","MouseUp")
o := LongPress2("o","","6","MouseRClick")
p := LongPress2("p","","{Backspace}")
at := LongPress2("@","","{Enter}")
openbracket := LongPress2("[","","+8")

a := LongPress("a")
s := LongPress("s")
d := LongPress("d")
f := LongPress("f")
g := LongPress("g")
h := LongPress2("h","","{Backspace}","MouseWheelUp")
j := LongPress2("j","","1","MouseLeft")
k := LongPress2("k","","2","MouseDown")
l := LongPress2("l","","3","MouseRight")
semicolon := LongPress2("sc027","","+{sc027}")
colon := LongPress2("sc028","","+{sc028}")
closebracket := LongPress2("]","","+9")

z := LongPress("z")
x := LongPress("x")
c := LongPress("c")
v := LongPress("v")
b := LongPress("b")
n := LongPress2("n","","","MouseWheelDown")
m := LongPress2("m","","0","MouseBack")
comma := LongPress2("sc033","","{sc033}")
perid := LongPress2(".","","")
slash := LongPress2("/","","/")
backslash2 := LongPress2("sc073","","+{sc073}")

up := LayerKey("up","","MouseWheelUp")
down  := LayerKey("down","","MouseWheelDown")
left := LayerKey("left","","MouseBack")
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
	return GetKeyState("F14", "P") || GetKeyState("sc079", "P") || GetKeyState("sc07B", "P")
}

SendDirKey(key)
{
	if IsSpaceAndF13Pressed(){
		if GetKeyState("sc07B", "P"){
			Send("{Blind}^+" . key)
		}else{
			Send("{Blind}^" . key)
		}
	}else{
		if GetKeyState("sc07B", "P"){
			Send("{Blind}+" . key)
		}else{
			Send("{Blind}" . key)
		}
	}
}
  
;***代用シフト**************************************************************************
#HotIf IsF14Pressed() != 0 && IsSpaceOrF13Pressed() = 0
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
*sc00D::Send("{Blind}{F12}") ;^

;shift
*q::Send("{Blind}+{F1}")
*w::Send("{Blind}+{F2}")
*e::Send("{Blind}+{F3}")
*r::Send("{Blind}+{F4}")
*t::Send("{Blind}+{F5}")
*y::Send("{Blind}+{F6}")
*u::Send("{Blind}+{F7}")
*i::Send("{Blind}+{F8}")
*o::Send("{Blind}+{F9}")
*p::Send("{Blind}+{F10}")
*@::Send("{Blind}+{F11}")
*[::Send("{Blind}+{F12}")

a::+1 ;!
s::+2 ;""
d::+3 ;# 
f::+4 ;$
g::+5 ;%
h::+6 ;&
j::+7 ;
k::+8 ;(
l::+9 ;) 

sc027::Send("+;") ;vkBBsc027 = ; shift:+
sc028::Send("+:") ;vkBAsc028 = : shift:*
]::Send("}")
z::[
x::]
c::Send("+[")
v::Send("+]")
b::Send("=") ;]
n::Send("_")
m::-
sc033::Send("<") ;vkBCsc033 = ,
.::Send(">") ;+. ;>
/::Send("?") ;?
sc073::Send("_") ;vkE2sc073 = \ shift:_
;***F13 or Sace Modifier***************************************************************************
#HotIf IsSpaceOrF13Pressed() 
*j::SendDirKey("{Left}")
*l::SendDirKey("{Right}")
*o::SendDirKey("{Right}")
*h::SendDirKey("{Home}")
*n::SendDirKey("{End}")
*i::SendDirKey("{Up}")
*k::SendDirKey("{Down}")
*p::SendDirKey("{Down}")
*m::Tab

*[::Send("{Blind}{PgUp}")
*]::Send("{Blind}{PgDn}")
*y::Send("{Blind}{Delete}")
*u::Send("{Blind}{BackSpace}")

sc027::Send("{Enter}") ;semicolon
sc028::^g ;vkBAsc028 = ":" shift:*
@::Send("{Enter}")
q::Esc
e::+F3
r::^r
w::^w
s::^s
a::^a
d::^d
*t::Tab
g::^y
f::^f
z::^z
+z::^y
x::^x
c::^c
v::^v
b::^z

; *1::Send("{Blind}^{F1}")
; *2::Send("{Blind}^{F2}")
; *3::Send("{Blind}^{F3}")
; *4::Send("{Blind}^{F4}")
; *5::Send("{Blind}^{F5}")
; *6::Send("{Blind}^{F6}")
; *7::Send("{Blind}^{F7}")
; *8::Send("{Blind}^{F8}")
; *9::Send("{Blind}^{F9}")
; *0::Send("{Blind}^{F10}")
; *-::Send("{Blind}^{F11}")
; *^::Send("{Blind}^{F12}")

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

;vk1C::Send("{vkF3}") ;vk1Csc079 = 変換 vkF3sc029 = 全角/半角
;sc07B::Send("{sc029}") ;vk1Dsc07B = 無変換 vkF3sc029 = 全角/半角
sc079::Send("{sc029}") ;vvk1Csc079 = 変換 vkF3sc029 = 全角/半角
F14::Send("{sc029}") ;vkF3sc029 = 全角/半角

sc033::LayerKey.ChangeLayer(1) ;sc033 = ","
.::LayerKey.ChangeLayer(2)
;/:: Send "{Home}+{End}+{Down}"

;*****************************************************************************
;#HotIf semicolon.IsPressed() 
;Space::Send "{Enter}"
;*k::Send "{Blind}{Right}"

;***F13単独修飾**************************************************************************
#HotIf IsF13Pressed()
Tab::Send("{sc03A}") ;vkF0sc03A = Eisu
sc029::Send("{sc03A}") ; vkF3sc029 = 全角/半角 vkF0sc03A = Eisu
;Space::Send "{sc029}" ; vkF3sc029 = 全角/半角
Esc::Reload

;***長押しシフト**************************************************************************
#HotIf IsSpaceOrF13Pressed() == 0 && IsF14Pressed() == 0 
1::k1.Down()
1 up::k1.Up()
2::k2.Down()
2 up::k2.Up()
3::k3.Down()
3 up::k3.Up()
4::k4.Down()
4 up::k4.Up()
5::k5.Down()
5 up::k5.Up()
6::k6.Down()
6 up::k6.Up()
7::k7.Down()
7 up::k7.Up()
8::k8.Down()
8 up::k8.Up()
9::k9.Down()
9 up::k9.Up()
-::minus.Down()
- up::minus.Up()
sc00D::hat.Down()
sc00D up::hat.Up()
sc07D::backslash.Down()
sc07D up::backslash.Up()

q::q.Down()
q up::q.Up()
w::w.Down()
w up::w.Up()
e::e.Down()
e up::e.Up()
r::r.Down()
r up::r.Up()
t::t.Down()
t up::t.Up()
y::y.Down()
y up::y.Up()
u::u.Down()
u up::u.Up()
i::i.Down()
+i::i.Down(1)
^i::i.Down(0,1)
i up::i.Up()
o::o.Down()
o up::o.Up()
p::p.Down()
p up::p.Up()
@::at.Down()
@ up::at.Up()
[::openbracket.Down()
[ up::openbracket.Up()

a::a.Down()
a up::a.Up()
s::s.Down()
s up::s.Up()
d::d.Down()
d up::d.Up()
f::f.Down()
f up::f.Up()
g::g.Down()
g up::g.Up()
h::h.Down()
h up::h.Up()
j::j.Down()
+j::j.Down(1)
^j::j.Down(0,1)
j up::j.Up()
k::k.Down()
+k::k.Down(1)
^k::k.Down(0,1)
k up::k.Up()
l::l.Down()
+l::l.Down(1,)
^l::l.Down(0,1)
l up::l.Up()
sc027::semicolon.Down()
sc027 up::semicolon.Up()
sc028::colon.Down()
sc028 up::colon.Up()
]::closebracket.Down()
] up::closebracket.Up()

z::z.Down()
z up::z.Up()
x::x.Down()
x up::x.Up()
c::c.Down()
c up::c.Up()
v::v.Down()
v up::v.Up()
b::b.Down()
b up::b.Up()
n::n.Down()
n up::n.Up()
m::m.Down()
m up::m.Up()
sc033::comma.Down()
sc033 up::comma.Up()
.::perid.Down()
. up::perid.Up()

sc035::slash.Down()
sc035 up::slash.Up()

sc073::backslash2.Down()
sc073 up::backslash2.Up()

down::down.Down()
;down up::down.Up()
up::up.Down()
;up up::up.Up()
left::left.Down()
;left up::left.Up()
right::right.Down()
;right up::right.Up()


;***修飾長押し処理/他****************************************************************************
#HotIf 
*Space::{
	LayerKey.ChangeLayer(0)
	space.Down()
}

*Space up:: space.Up()
Esc::{
	LayerKey.ChangeLayer(0)
	Send("{Escape}")
}

F13::{
	LayerKey.ChangeLayer(0)
	Send("{F13}")
}

*F14:: f14.Down()
*F14 up:: f14.Up()

*sc079:: f14.Down()
*sc079 up:: f14.Up()

sc07B::Return ;vk1Dsc07B = 無変換

NumLock::Return
+F15::Send("{NumLock}")

>+Up::_
^+F13::Send("+{CapsLock}") ;Change CapsLock off setting to shift on Windows setting

#MaxThreadsBuffer False
