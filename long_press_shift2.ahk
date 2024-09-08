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

;vkF2sc070 = Hiragana(ひらがな/カタカナ) , it is unstable to assign other key to this key.
S_HIRAGANA := "sc070"
C_HIRAGANA := "{sc070}"

;vkF3sc029 = 全角/半角 sendでおくらなければいけない 入れ替え元の場合、うまく動かない
;vkF4sc029 = 全角/半角 sendでおくらなければいけない
S_ZENKAKU := "sc029" 
C_ZENKAKU := "{sc029}" 

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
Class to assign key for short and long press
============================================================================*/
class KeyReplacer
{
	static long_press_th := 300 ;if pressing for more this time, long press process runs in Up()
	static last_key := ""

/*============================================================================
	org_key:	org key, not inclueds "{}"
	key: 		replaced key, not inclueds "{}", if ommitted, org_key is assigned
	long_key: 	long pressed key, if ommitted, key whith shift is assigned.
============================================================================*/
	__New(org_key, key:="", long_key:="")
	{
		this.org_key := org_key
		if key = ""  {
			key := org_key
		}
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
		KeyReplacer.last_key := this.org_key
		pressed_time := A_TickCount
		if pressed_time - this.send_time < KeyReplacer.long_press_th  {
		 	return
		}
		; Send(String(A_TickCount) . this.short_key_str . "; ") 
		Send(this.short_key_str) 
		KeyWait(this.org_key)
		if A_TickCount - pressed_time >= KeyReplacer.long_press_th {
			if KeyReplacer.last_key = this.org_key {
				this.send_time := A_TickCount
				Send("{BackSpace}" . this.long_key_str )
				return
			}else{
				;ToolTip "last key is different"
			}
		}
	}
/*============================================================================
	Assign key down to the key as same as registered.  
============================================================================*/
	Down()
	{
		LayerKey.ChangeLayer(0)
		this.DownImpl()
	}

	;Up(){}
}

/*============================================================================
Class to assign key for shirt and long press with layer change
============================================================================*/
class KeyReplacerL extends KeyReplacer 
{

/*============================================================================
	org_key:	org key, not inclueds "{}"
	key: 		replaced key, not inclueds "{}", if ommitted, org_key is assigned
	long_key: 	long pressed key, if ommitted, key whith shift is assigned.
	key1: 		key for mode1 
	key2: 		key for mode2
===========================================================================*/
	__New(org_key,key:="", long_key:="", key1 := "", key2 := "")
	{
		super.__New(org_key,key, long_key)
		this.key1 := key1
		this.key2 := key2
	}
	
/*============================================================================
	Defines shift/ctrl combination if they are used
	ex)
	x := KeyReplacerL("x")
	x::x.Down()
	x up ::x.Down()
	+x::x.Down()
	^x::x.Down(0,1)
	+^x::x.Down(1,1)
===========================================================================*/
	Down()
	{	
		shift := GetKeyState("shift","P")
		ctrl := GetKeyState("ctrl","P")

		;Critical
		if LayerKey.idx = 1 && this.key1 != "" {
			SendEvent(this.key1)
			return
		}else if LayerKey.idx = 2 && this.key2 != "" {
			;SendEvent this.key2
			OperateMouse(this.key2,shift,ctrl)
			return
		}
		super.DownImpl(shift,ctrl)
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

;Pressing f14 shortly, sends sc029 
f14   := ModKey("Space") ;vkF3sc029 = 全角/半角
conv := ModKey("Space") ;vkF3sc029 = 全角/半角

k1 := KeyReplacer("1")
k2 := KeyReplacer("2")
k3 := KeyReplacer("3")
k4 := KeyReplacer("4")
k5 := KeyReplacer("5")
k6 := KeyReplacerL("6","","","{Escape}")
k7 := KeyReplacerL("7","","","7")
k8 := KeyReplacerL("8","","","8")
k9 := KeyReplacerL("9","","","9")
minus := KeyReplacerL("-","","","-")							
hat := KeyReplacerL(S_HAT)
backslash := KeyReplacerL("\")
;
q := KeyReplacer("q")
w := KeyReplacer("w")
e := KeyReplacer("e")
r := KeyReplacer("r")
t := KeyReplacer("t")
;
y := KeyReplacerL("y","@","","{Delete}")
u := KeyReplacerL("u","[","","4")
i := KeyReplacerL("i","y","","5")
o := KeyReplacerL("o","u","","6","MouseLClick")
p := KeyReplacerL("p","i","","{Backspace}","MouseUp")
at := KeyReplacerL("@","o","", C_PLUS,"MouseRClick")  
openbracket := KeyReplacerL("[","p","","+8")
;
a := KeyReplacer("a")
s := KeyReplacer("s")
d := KeyReplacer("d")
f := KeyReplacer("f")
g := KeyReplacer("g")
;
h := KeyReplacerL("h",":","","{Backspace}")
j := KeyReplacerL("j","]","","1")
k := KeyReplacerL("k","h","","2","MouseWheelUp")
l := KeyReplacerL("l","j","","3","MouseLeft")
semicolon := KeyReplacerL(S_SEMICOLON,"k","","{Enter}","MouseDown")	
colon := KeyReplacerL(S_COLON,"l","",C_ASTERISK,"MouseRight")
closebracket := KeyReplacerL("]",S_SEMICOLON,"","+9") ;sc027 = ;
;
z := KeyReplacer("z")
x := KeyReplacer("x")
c := KeyReplacer("c")
v := KeyReplacer("v")
b := KeyReplacer("b")
;
n := KeyReplacer("n","/","")
m := KeyReplacerL("m",S_BACKSLASH2,"","0","MouseBack") ;vkE2sc073 = \ shift:_
comma := KeyReplacerL(S_COMMA,"n","",C_COMMA,"MouseWheelDown") 
perid := KeyReplacerL(".","m","","")
slash := KeyReplacerL("/",S_COMMA,"","/") 
backslash2 := KeyReplacer(S_BACKSLASH2,".")
;
up    := LayerKey("up","","MouseWheelUp")
down  := LayerKey("down","","MouseWheelDown")
left  := LayerKey("left","","MouseBack")
right := LayerKey("right","","MouseNext")


IsSpacePressed()
{
;vk1Csc079 = Convert 変換
;vkF2sc070 = Hiragana(ひらがな/カタカナ) F14
	return space.IsPressed() || conv.IsPressed() || f14.IsPressed()
}

IsF13Pressed()
{
	return GetKeyState("F13","P")
}

IsSpaceOrF13Pressed()
{
	return IsSpacePressed() || GetKeyState("F13","P")
}

IsSpaceAndF13Pressed()
{
	f13_pressed := GetKeyState("F13","P") 
	if IsSpacePressed() && f13_pressed{
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
	return GetKeyState(S_NOCONV, "P")
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
*l::Send("{Blind}+{Left}")
*sc028::Send("{Blind}+{Right}") ;vkBAsc028 = : shift:*
*@::Send("{Blind}+{Right}")
*k::Send("{Blind}+{Home}")
*sc033::Send("{Blind}+{End}") ;sc033 = ,
*p::Send("{Blind}+{Up}")
*sc027::Send("{Blind}+{Down}") ;vkBBsc027 = ; shift:+
*[::Send("{Blind}^+{Right}")
*.::Send("{Blind}^+{Left}")

;u::Send("{Blind}{PgUp}")
;j::Send("{Blind}{PgDn}")
;;]::Send("^]")

*i::Send("{Blind}{Delete}")
*o::Send("{Blind}{BackSpace}")

]::Send("{Enter}") ;
;sc028::^g ;vkBAsc028 = ":" shift:*

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
;]::Send("^+" . C_BACKSLASH) ;sc07D = \; shihft:|
sc073::!Left ;sc073 = \; shift:_

#HotIf WinActive("ahk_exe code.exe")
;^]::Send("^+" . C_BACKSLASH) ;sc07D = \; shift:|\

#HotIf IsSpaceOrF13Pressed() && IsF14Pressed() = 0 && IsSpaceAndF13Pressed() = 0
*l::SendDirKey("{Left}")
*sc028::SendDirKey("{Right}") ;vkBAsc028 = : shift:*
*@::SendDirKey("{Right}")
*k::SendDirKey("{Home}")
*sc033::SendDirKey("{End}") ;sc033 = ,
*p::SendDirKey("{Up}")
*sc027::SendDirKey("{Down}") ;vkBBsc027 = ; shift:+
*[::Send("{Blind}^{Right}")
*.::Send("{Blind}^{Left}")

u::Send("{Blind}{PgUp}")
j::Send("{Blind}{PgDn}")
;]::Send("^]")

*i::Send("{Blind}{Delete}")
*o::Send("{Blind}{BackSpace}")

]::Send("{Enter}") ;
;sc028::^g ;vkBAsc028 = ":" shift:*

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
;sc073::^- ;vkE2sc073 = \ shift:_

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
sc079::Send(S_ZENKAKU) ;vvk1Csc079 = 変換 vkF3sc029 = 全角/半角
F14::Send(S_ZENKAKU) ;vkF3sc029 = 全角/半角

sc035::LayerKey.ChangeLayer(1) ;sc033 = ","
sc073::LayerKey.ChangeLayer(2) ;sc073 = \; shift:_		

;*****************************************************************************
;#HotIf semicolon.IsPressed() 
;Space::Send "{Enter}"
;*k::Send "{Blind}{Right}"

;***F13 Modifier**************************************************************************
#HotIf IsF13Pressed()
Tab::Send(C_EISU) ;vkF0sc03A = Eisu
sc029::Send(C_EISU) ; vkF3sc029 = 全角/半角 vkF0sc03A = Eisu
Esc::Reload

;***Long Press**************************************************************************
#HotIf IsSpaceOrF13Pressed() == 0 && IsF14Pressed() == 0 
*1::k1.Down()
*2::k2.Down()
*3::k3.Down()
*4::k4.Down()
*5::k5.Down()
*6::k6.Down()
*7::k7.Down()
*8::k8.Down()
*9::k9.Down()
*-::minus.Down()
*sc00D::hat.Down()
*sc07D::backslash.Down()
;
*q::q.Down()
*w::w.Down()
*e::e.Down()
*r::r.Down()
*t::t.Down()
*y::y.Down()
*u::u.Down()
*i::i.Down()
*o::o.Down()
*p::p.Down()
*@::at.Down()
*[::openbracket.Down()
;
*a::a.Down()
*s::s.Down()
*d::d.Down()
*f::f.Down()
*g::g.Down()
*h::h.Down()
*j::j.Down()
*k::k.Down()
*l::l.Down()
*sc027::semicolon.Down()
*sc028::colon.Down()
*]::closebracket.Down()
;
*z::z.Down()
*x::x.Down()
*c::c.Down()
*v::v.Down()
*b::b.Down()
*n::n.Down()
*m::m.Down()
*sc033::comma.Down()
*.::perid.Down()

*sc035::slash.Down()
*sc073::backslash2.Down()
;
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
