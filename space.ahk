#Requires AutoHotkey v2.0

;win #
;ctrl ^
;shift +
;alt !
;vk1Dsc07B	無変換
;vk1Csc079 = 変換
;vkE2sc073 = \
;vkBBsc027 = ; +
;vkBAsc028 = : *
;vkBCsc03 = ,
;vkF0sc03A = Eisu
;vkF2sc070 = ひらがな/カタカナ  入れ替え元の場合、うまく動かない
;ivkF3sci029 = 全角/半角 sendでおくらなければいけない 入れ替え元の場合、うまく動かない
;vkF4sc029 = 全角/半角 sendでおくらなければいけない
;- ^ ¥i @ [ ] . /
;Space Tab Enter BS Del Ins Left  Right Up Down Home End PgUp PgDn Esc Pause

;SingleInstkance Force
ProcessSetPriority "Realtime"
SendMode "Input"

mouse_move := A_ScreenWidth/160
mouse_move_short := A_ScreenWidth/320
mouse_move_long := A_ScreenWidth/8

timeout := 200 ;

#MaxThreadsBuffer True

class ModKey
{
	__New(key)
	{
		this.key := key
		this.pressed_time := 0
		this.mod_str := ""
	}

	isPressed()
	{
		if this.pressed_time != 0{
			return 1
		}
		if GetKeyState(this.key,"P"){
			return 1
		}
		return 0
	}
	set_mod_str()
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
		;if GetKeyState("Win","P"){ ;not work
		;	this.mod_str  := "#" . this.mod_str 
		;}
	}
	down()
	{
		if this.pressed_time != 0 {
			return
		}
		this.pressed_time := A_TickCount
		this.set_mod_str()
	}

	up()
	{
		global timeout
		if (A_TickCount - this.pressed_time < timeout) {
			SendInput "{Blind}" . this.mod_str . "{" . this.key . "}"
		}
		this.pressed_time := 0
	}
}

space := ModKey("Space")
semicolon := ModKey("vkBB")
colon := ModKey("vkBA")
slash := ModKey("/")

m1_modified()
{
	global
	f13_pressed := GetKeyState("F13","P") 
	if space.isPressed() && f13_pressed{
		return 1
	}
	if semicolon.isPressed() && f13_pressed{
		return 1
	}
	/*
	if semicolon.isPressed() != 0 && space.isPressed() {
		return 1
	}
	*/
	return 0 
}


>+Up::_
^+F13::Send "+{CapsLock}" ;Change CapsLock off setting to shift on Windows setting

#HotIf slash.isPressed()
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
#HotIf

#HotIf colon.isPressed()
u::MouseClick "left"
o::MouseClick "right"
;space::MouseClick "left"
;vk1D::MouseClick "right"
n::WheelUp
m::WheelDown ;vkBCsc033 = ,

b::!Left
i::MouseMove 0,-mouse_move,0,"R"
k::MouseMove 0,mouse_move,0,"R" ;vkBBsc027 = ;
j::MouseMove -mouse_move,0,0,"R"
l::MouseMove mouse_move,0,0,"R" ;vkBAsc028 = :

;shift
+i::MouseMove 0,mouse_move_short,0,"R"
+k::MouseMove 0,mouse_move_short,0,"R" ;vkBBsc027 = ;
+j::MouseMove -mouse_move_short,0,0,"R"
+l::MouseMove mouse_move_short,0,0,"R" ;vkBAsc028 = :

;ctrl
^i::MouseMove 0,mouse_move_long,0,"R"
^k::MouseMove 0,mouse_move_long,0,"R" ;vkBBsc027 = ;
^j::MouseMove -mouse_move_long,0,0,"R"
^l::MouseMove mouse_move_long,0,0,"R" ;vkBAsc028 = :

8::MouseMove 0,-mouse_move_long,0,"R"
9::MouseMove 0,-mouse_move_long,0,"R"
vkBC::MouseMove 0,mouse_move_long,0,"R" ;vkBCsc03 = ,
h::MouseMove -mouse_move_long,0,0,"R"
vkBB::MouseMove mouse_move_long,0,0,"R" ;vkBBsc027 = ; +

;u::MouseMove 24,24,0
;o::MouseMove A_ScreenWidth-24,24,0
;m::MouseMove 24,A_ScreenHeight-24,24 ;vkBCsc03 = ,
;.::MouseMove A_ScreenWidth-24,A_ScreenHeight-24,0 ;vkBCsc03 = ,
;vkBB::MouseMove A_ScreenWidth-16,0,0 ;vkBBsc027 = ; +
#HotIf

;vk1Dsc07B	無変換
;vk1Csc079 = 変換
#HotIf GetKeyState("F14", "P") || GetKeyState("vk1C", "P") || GetKeyState("vk1D", "P")
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
*^::Send "{Blind}{F12}"

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

;ctrl
*a::Send "{Blind}^{F1}"
*s::Send "{Blind}^{F2}"
*d::Send "{Blind}^{F3}"
*f::Send "{Blind}^{F4}"
*g::Send "{Blind}^{F5}"
*h::Send "{Blind}^{F6}"
*j::Send "{Blind}^{F7}"
*k::Send "{Blind}^{F8}"
*l::Send "{Blind}^{F9}"
*vkBB::Send "{Blind}^{F10}"
*vkBA::Send "{Blind}^{F11}"
*]::Send "{Blind}^{F12}"

;alt
*z::Send "{Blind}!{F1}"
*x::Send "{Blind}!{F2}"
*c::Send "{Blind}!{F3}"
*v::Send "{Blind}!{F4}"
*b::Send "{Blind}!{F5}"
*n::Send "{Blind}!{F6}"
*m::Send "{Blind}!{F7}"
*vkBC::Send "{Blind}!{F8}" ;vkBC = ,
*.::Send "{Blind}!{F9}"
*/::Send "{Blind}!{F10}"
*vkE2::Send "{Blind}!{F11}"
#HotIf 

#HotIf space.isPressed() || GetKeyState("F13", "P") || semicolon.isPressed()  
*j::{
  if m1_modified(){
	Send "{Blind}^{Left}"
  }else{
	Send "{Blind}{Left}"
  }
}
*l::{
 If m1_modified(){
  Send "{Blind}^{Right}"
 }else{
  Send "{Blind}{Right}"
 }
}

*h::{
  if m1_modified(){
	Send "{Blind}^{Home}"
  }else{
	Send "{Blind}{Home}"
  }
}
*n::{
 If m1_modified(){
  Send "{Blind}^{End}"
 }else{
  Send "{Blind}{End}"
 }
}

*i::Send "{Blind}{Up}"
*k::Send "{Blind}{Down}"
*o::Send "{Blind}{PgUp}"
*p::Send "{Blind}{PgDn}"
*y::Send "{Blind}{Delete}"
*u::Send "{Blind}{BackSpace}"

q::Esc
e::^e
r::^r
w::^w
s::^s
a::^a
d::^d
t::Tab
g::^g
f::^f
z::^z
+z::^y
x::^x
c::^c
v::^v
b::^z
m::-
+m::=
@::=
vkBC::+[
.::+]
vkE2::_

2::F2
3::F3
4::+F3
5::F5
6::F6
;vkBB::Send "{Enter}"

;vk1C::Send "{vkF3}" ;vk1Dsc07B	無変換 vkF3sc029 = 全角/半角
vk1D::Send "{vkF3}" ;vk1Csc079 = 変換 vkF3sc029 = 全角/半角
F14::Send "{vkF3}" ;vkF3sc029 = 全角/半角

#HotIf 

#HotIf space.isPressed() || GetKeyState("F13", "P")
vkBB::Send "{Enter}"
#HotIf

#HotIf semicolon.isPressed() 
Space::Send "{Enter}"
#HotIf 

#HotIf GetKeyState("F13", "P")
Tab::Send "{vkF0}" ; vkF0=EISU
vkF3::Send "{vkF0}" ; vkF3sc029 = 全角/半角 vkF0=EISU
Space::Send "{vkF3}" ; vkF3sc029 = 全角/半角
Esc::Reload
#HotIf

*Space:: space.down()
*Space up:: space.up()

*vkBB:: semicolon.down()
*vkBB up:: semicolon.up()

*vkBA:: colon.down()
*vkBA up:: colon.up()

*/:: slash.down()
*/ up:: slash.up()

vk1C::Return
vk1D::Return

#MaxThreadsBuffer False
