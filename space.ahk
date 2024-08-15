#Requires AutoHotkey v2.0

;long_pressを使う場合、ただし、IMEv2.ahkを使った方が安定する
;IMEv2.ahkを使わない場合、
;#Include "IMEv2.ahk"をコメントアウトして、IME_GET()  {return 0}を有効化する。
;#Include "IMEv2.ahk"
IME_GET()  { 
	return 0 
}

;win #
;ctrl ^
;shift +
;alt !
;vk1Dsc07B = 無変換
;vk1Csc079 = 変換
;vkE2sc073 = \ shift:_
;sc07D = \; shift:|
;sc073 = \; shift:_
;sc070 =^
;vkBBsc027 = ; shift:+
;vkBAsc028 = : shift:*
;vkBCsc033 = ,
;vkF0sc03A = Eisu
;vkF2sc070 = ひらがな/カタカナ  入れ替え元の場合、うまく動かない
;vkF3sc029 = 全角/半角 sendでおくらなければいけない 入れ替え元の場合、うまく動かない
;vkF4sc029 = 全角/半角 sendでおくらなければいけない
;- ^ ¥ @ [ ] . /
;Space Tab Enter BS Del Ins Left  Right Up Down Home End PgUp PgDn Esc Pause

;SingleInstkance Force
ProcessSetPriority "Realtime"
SendMode "Input"

mouse_move := A_ScreenWidth/160
mouse_move_short := A_ScreenWidth/320
mouse_move_long := A_ScreenWidth/8

timeout := 300 ;
timeout_lp := 350 ;For long press

InstallKeybdHook true
#UseHook true
#MaxThreadsBuffer True

class ModKey
{
	__New(key)
	{
		this.key := key
		this.pressed_time := 0
		this.mod_str := ""
	}

	IsPressed()
	{
		if this.pressed_time != 0{
			return 1
		}
		if GetKeyState(this.key,"P"){
			return 1
		}
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
		global timeout
		;t := A_TickCount      
		if (A_TickCount - this.pressed_time < timeout) {
			SendInput "{Blind}" . this.mod_str . "{" . this.key . "}"
		}
		this.pressed_time := 0
		return
	} 
}

space := ModKey("Space")
;semicolon := ModKey("sc027")
colon := ModKey("sc028")
slash := ModKey("/")


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
			Send "{Blind}^+" . key
		}else{
			Send "{Blind}^" . key
		}
	}else{
		if GetKeyState("sc07B", "P"){
;			ToolTip key
			Send "{Blind}+" . key
		}else{
			Send "{Blind}" . key
		}
	}
}

;exe別実行用
SendKeyIf(key,alt_key)
{
	if space.IsPressed() || IsF13Pressed()
	{
		SendInput alt_key
	}else{
		SendInput "{blind}" . key
	}
}
  

MoveMousePos(rx, ry)
{
  size := 4
  point := Buffer(size * 2)
  DllCall("GetCursorPos", "Ptr", point)
  x := NumGet(point, 0, "Int")
  y := NumGet(point, size, "Int")
  DllCall("SetCursorPos", "int", x+rx, "int", y+ry)
} 


;***Ctrl+K処理**************************************************************************
#HotIf slash.IsPressed() && IsF14Pressed() = 0 && IsSpaceOrF13Pressed() = 0
x::Send "^k^x"
c::Send "^k^c"
u::Send "^k^u"
i::Send "^k^i"
p::Send "^k^p"
n::Send "^k^n"
b::Send "^k^b"
f::Send "^k^f"
s::Send "^k^s"
q::Send "^k^q"

;***疑似マウス**************************************************************************
#HotIf colon.IsPressed() && IsF14Pressed() = 0 && IsSpaceOrF13Pressed() = 0
u::MouseClick "left"
o::MouseClick "right"
;space::MouseClick "left"
;vk1D::MouseClick "right"
h::WheelUp
n::WheelDown 

b::!Left ;back
i::MoveMousePos(0,-mouse_move)
m::MoveMousePos(0,mouse_move) 
j::MoveMousePos(-mouse_move,0)
k::MoveMousePos(mouse_move,0) 

;shift
+i::MoveMousePos(0,mouse_move_short)
+m::MoveMousePos(0,mouse_move_short)
+j::MoveMousePos(-mouse_move_short,0)
+k::MoveMousePos(mouse_move_short,0) 

;ctrl
^i::MoveMousePos(0,mouse_move_long)
^m::MoveMousePos(0,mouse_move_long) 
^j::MoveMousePos(-mouse_move_long,0)
^k::MoveMousePos(mouse_move_long,0) 
;***疑似シフト**************************************************************************
#HotIf IsF14Pressed() && IsSpaceOrF13Pressed() = 0
*1::Send "{Blind}{F1}"
*2::Send "{Blind}{F2}"
*3::Send "{Blind}{F3}"
*4::Send "{Blind}{F4}"
*5::Send "{Blind}{F5}"
*6::Send "{Blind}{F6}"
*7::Send "{Blind}{F7}"
*8::Send "{Blind}{F8}"
*9::Send "{Blind}{F9}"
*0::Send "{Blind}{F10}"
*-::Send "{Blind}{F11}"
*sc00D::Send "{Blind}{F12}" ;^

;shift
*q::Send "{Blind}+{F1}"
*w::Send "{Blind}+{F2}"
*e::Send "{Blind}+{F3}"
*r::Send "{Blind}+{F4}"
*t::Send "{Blind}+{F5}"
*y::Send "{Blind}+{F6}"
*u::Send "{Blind}+{F7}"
*i::Send "{Blind}+{F8}"
*o::Send "{Blind}+{F9}"
*p::Send "{Blind}+{F10}"
*@::Send "{Blind}+{F11}"
*[::Send "{Blind}+{F12}"

a::+1 ;!
s::+2 ;""
d::+3 ;# 
f::+4 ;$
g::+5 ;%
h::+6 ;&
j::+7 ;
k::+8 ;(
l::+9 ;) 

sc027::Send "+" ;vkBBsc027 = ; shift:+
sc028::Send "*" ;vkBAsc028 = : shift:*
]::Send "}"
z::[
x::]
c::Send "{"
v::Send "}"
b::Send "=" ;]
n::Send "_"
m::-
sc033::Send "<" ;vkBCsc033 = ,
.::Send ">" ;+. ;>
/::Send "?" ;?
sc073::Send "_" ;vkE2sc073 = \ shift:_

;***F13/Sace修飾****************************************************************************
#HotIf IsSpaceOrF13Pressed() 
*j::SendDirKey("{Left}")
*l::SendDirKey("{Right}")
*o::SendDirKey("{Right}")
*h::SendDirKey("{Home}")
*n::SendDirKey("{End}")
*i::SendDirKey("{Up}")
*k::SendDirKey("{Down}")
*m::SendDirKey("{Down}")

*[::Send "{Blind}{PgUp}"
*]::Send "{Blind}{PgDn}"
*y::Send "{Blind}{Delete}"
*u::Send "{Blind}{BackSpace}"

sc027::Send "{Enter}" ;semicolon
p::Send "{Enter}" ;semicolon

@::^g
q::Esc
e::^e
r::^r
w::^w
s::^s
a::^a
d::^d
t::Tab
g::^y
f::^f
z::^z
+z::^y
x::^x
c::^c
v::^v
b::^z
]::^]

*1::Send "{Blind}^{F1}"
*2::Send "{Blind}^{F2}"
*3::Send "{Blind}^{F3}"
*4::Send "{Blind}^{F4}"
*5::Send "{Blind}^{F5}"
*6::Send "{Blind}^{F6}"
*7::Send "{Blind}^{F7}"
*8::Send "{Blind}^{F8}"
*9::Send "{Blind}^{F9}"
*0::Send "{Blind}^{F10}"
*-::Send "{Blind}^{F11}"
*^::Send "{Blind}^{F12}"

;vk1C::Send "{vkF3}" ;vk1Csc079 = 変換 vkF3sc029 = 全角/半角
;sc07B::Send "{sc029}" ;vk1Dsc07B = 無変換 vkF3sc029 = 全角/半角
sc079::Send "{sc029}" ;vvk1Csc079 = 変換 vkF3sc029 = 全角/半角
F14::Send "{sc029}" ;vkF3sc029 = 全角/半角


;*****************************************************************************
;#HotIf semicolon.IsPressed() 
;Space::Send "{Enter}"
;*k::Send "{Blind}{Right}"

;***F13単独修飾**************************************************************************
#HotIf IsF13Pressed()
Tab::Send "{sc03A}" ;vkF0sc03A = Eisu
sc029::Send "{sc03A}" ; vkF3sc029 = 全角/半角 vkF0sc03A = Eisu
;Space::Send "{sc029}" ; vkF3sc029 = 全角/半角
Esc::Reload

;***exe別処理**************************************************************************
;vkBBsc027 = ; shift:+
;vkBAsc028 = : shift:*
;vkBCsc033 = , shift:<
#HotIf WinActive("ahk_exe code.exe")
sc033::SendKeyIf("{sc033}","^-") ;font- 
.::SendKeyIf(".","^{vkBB}") ;font+

#HotIf WinActive("ahk_exe devenv.exe")
sc033::SendKeyIf("{sc033}","+^{vkBC}") ;font- 
.::SendKeyIf(".","^{vkBC_") ;font+

#HotIf WinActive("ahk_exe chrome.exe")
sc033::SendKeyIf("","^{WheelDown}") ;font- 
.::SendKeyIf("","^{WheelUp}") ;font+

#HotIf WinActive("ahk_exe winword.exe")
sc033::SendKeyIf("","^{WheelDown}") ;font- 
.::SendKeyIf("","^{WheelUp}") ;font+

;***修飾長押し処理/他****************************************************************************
#HotIf 
*Space:: space.Down()
*Space up:: space.Up()

;*sc027:: semicolon.Down()
;*sc027 up:: semicolon.Up()

*sc028::colon.Down()
*sc028 up:: colon.Up()

*sc035:: slash.Down()
*sc035 up:: slash.Up()

sc079::Return ;vk1Csc079 = 変換
sc07B::Return ;vk1Dsc07B = 無変換

;NumLock::Return
;F13 & NumLock::NumLock
>+Up::_
^+F13::Send "+{CapsLock}" ;Change CapsLock off setting to shift on Windows setting

#MaxThreadsBuffer False
