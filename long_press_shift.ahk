#Requires AutoHotkey v2.0

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

;キーボード/マウスフックが使用されている場合、物理的なキー/ボタンの状態によって判定される。
;#InstallKeybdHookでフックを有効化。
;フックを無効化の場合、論理的な状態で判定される。
;このときSendコマンドで生成された操作にも反応。

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
	static long_press_th := 300 ;if pressing for more this time, long press process runs in Up()
	;static timeout := 1500 ;if pressing for more this time, up process is cancel
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
		this.send_time := 0
	}

	DownImpl(shift :=0, ctrl := 0)
	{
		LongPress.last_key := this.key
		pressed_time := A_TickCount
		if pressed_time - this.send_time < LongPress.long_press_th  {
		 	return
		}
		; Send(String(A_TickCount) . this.short_key_str . "; ") 
		Send(this.short_key_str) 
		KeyWait(this.key)
		if A_TickCount - pressed_time >= LongPress.long_press_th {
			if LongPress.last_key = this.key {
				this.send_time := A_TickCount
				Send("{BackSpace}" . this.long_key_str )
				return
			}else{
				;ToolTip "last key is different"
			}
		}
		this.x:= 0
	}

	Down()
	{
		LayerKey.ChangeLayer(0)
		this.DownImpl()
	}

	Up()
	{
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

;Prssing f14 shortly, sends sc029 
f14   := ModKey("sc029") ;vkF3sc029 = 全角/半角
;conv := ModKey("sc029") ;vkF3sc029 = 全角/半角

k1 := LongPress("1")
k2 := LongPress("2")
k3 := LongPress("3")
k4 := LongPress("4")
k5 := LongPress("5")
k6 := LongPress2("6","","{Escape}")
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
at := LongPress2("@","","+{sc027}")
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
semicolon := LongPress2("sc027","","{Enter}")
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
backslash2 := LongPress("sc073")

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
	return GetKeyState("F14", "P") || GetKeyState("sc079", "P") || GetKeyState("sc07B", "P")
}

SendDirKey(key)
{
	if IsSpaceAndF13Pressed(){
		Send("{Blind}^" . key)
	}else{
		Send("{Blind}" . key)
	}
}
  
;*****************************************************************************
#HotIf IsF14Pressed() ;|| IsSpaceAndF13Pressed()
*i::Send("{Blind}+{Up}")
*j::Send("{Blind}+{Left}")
*k::Send("{Blind}+{Down}")
*l::Send("{Blind}+{Right}")
*o::Send("{Blind}+{Right}")
*p::Send("{Blind}+^{Right}")
*m::Send("{Blind}+^{Left}")
*h::Send("{Blind}+{Home}")
*n::Send("{Blind}+{End}")
sc027::Enter ;vkBBsc027 = ; shift:+

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
]::Send("^+{sc07D}") ;sc07D = \; shift:|
sc073::!Left ;sc073 = \; shift:_

#HotIf WinActive("ahk_exe code.exe")
^]::Send("^+{sc07D}") ;sc07D = \; shift:|\

#HotIf IsSpaceOrF13Pressed() && IsF14Pressed() = 0
*j::SendDirKey("{Left}")
*l::SendDirKey("{Right}")
*o::SendDirKey("{Right}")
*h::SendDirKey("{Home}")
*n::SendDirKey("{End}")
*i::SendDirKey("{Up}")
*k::SendDirKey("{Down}")
*p::Send("{Blind}^{Right}")
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
w::^w
s::^s
a::^a
d::^d

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

;vk1C::Send("{vkF3}") ;vk1Csc079 = 変換 vkF3sc029 = 全角/半角
;sc07B::Send("{sc029}") ;vk1Dsc07B = 無変換 vkF3sc029 = 全角/半角
sc079::Send("{sc029}") ;vvk1Csc079 = 変換 vkF3sc029 = 全角/半角
F14::Send("{sc029}") ;vkF3sc029 = 全角/半角

sc033::LayerKey.ChangeLayer(1) ;sc033 = ","
.::LayerKey.ChangeLayer(2)

;*****************************************************************************
;#HotIf semicolon.IsPressed() 
;Space::Send "{Enter}"
;*k::Send "{Blind}{Right}"

;***F13 Modifier**************************************************************************
#HotIf IsF13Pressed()
Tab::Send("{sc03A}") ;vkF0sc03A = Eisu
sc029::Send("{sc03A}") ; vkF3sc029 = 全角/半角 vkF0sc03A = Eisu
Esc::Reload

;***Long Press**************************************************************************
#HotIf IsSpaceOrF13Pressed() == 0 && IsF14Pressed() == 0 
1::k1.Down()
2::k2.Down()
3::k3.Down()
4::k4.Down()
5::k5.Down()
6::k6.Down()
7::k7.Down()
8::k8.Down()
9::k9.Down()
-::minus.Down()
sc00D::hat.Down()
sc07D::backslash.Down()

q::q.Down()
w::w.Down()
e::e.Down()
r::r.Down()
t::t.Down()
y::y.Down()
u::u.Down()
i::i.Down()
+i::i.Down(1)
^i::i.Down(0,1)
o::o.Down()
p::p.Down()
@::at.Down()
[::openbracket.Down()

a::a.Down()
s::s.Down()
d::d.Down()
f::f.Down()
g::g.Down()
h::h.Down()
j::j.Down()
+j::j.Down(1)
^j::j.Down(0,1)
k::k.Down()
+k::k.Down(1)
^k::k.Down(0,1)
l::l.Down()
+l::l.Down(1,)
^l::l.Down(0,1)
sc027::semicolon.Down()
sc028::colon.Down()
]::closebracket.Down()

z::z.Down()
x::x.Down()
c::c.Down()
v::v.Down()
b::b.Down()
n::n.Down()
m::m.Down()
sc033::comma.Down()
.::perid.Down()

sc035::slash.Down()
sc073::backslash2.Down()

down::down.Down()
up::up.Down()
left::left.Down()
right::right.Down()

;***ohter****************************************************************************
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

;NumLock::Return
+F15::Send("{NumLock}")

>+Up::_
^+F13::Send("+{CapsLock}") ;Change CapsLock off setting to shift on Windows setting

#MaxThreadsBuffer False
