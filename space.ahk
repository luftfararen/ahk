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
;vkBCsc033 = ,
;vkF0sc03A = Eisu
;vkF2sc070 = ひらがな/カタカナ  入れ替え元の場合、うまく動かない
;vkF3sc029 = 全角/半角 sendでおくらなければいけない 入れ替え元の場合、うまく動かない
;vkF4sc029 = 全角/半角 sendでおくらなければいけない 
;- ^ ¥ @ [ ] . /
;Space Tab Enter BS Del Ins Left  Right Up Down Home End PgUp PgDn Esc Pause

mouse_move := A_ScreenWidth/80
mouse_move_long := A_ScreenWidth/8

#SingleInstance Force
ProcessSetPriority "Realtime"

>+Up::_
;F14::Send "{vkF3}"	;全角(vkF3)
F13 & F14::vkF0 ; vkF0=EISU

#HotIf GetKeyState("vk1D", "P")
1::F1
2::F2
3::F3
4::F4
5::F5
6::F6
7::F7
8::F8
9::F9
0::F10
-::F11
^::F12
q::+F1
w::+F2
e::+F3
r::+F4
t::+F5
y::+F6
u::+F7
i::+F8
o::+F9
p::+F10
@::+F11
[::+F12
a::^F1
s::^F2
d::^F3
f::^F4
g::^F5
h::^F6
j::^F7
k::^F8
l::^F9
vkBB::^F10
vkBA::^F11
]::^F12
z::!F1
x::!F2
c::!F3
v::!F4
b::!F5
n::!F6
m::!F7
vkBC::!F8
.::!F9
vkBB::!F10
/::!F11
vkE2::!F12


#HotIf ;GetKeyState("vk1D", "P")
vk1D::Return

#HotIf GetKeyState("F13", "P")
*i::Send "{Blind}{Up}"
*k::Send "{Blind}{Down}"
*j::Send "{Blind}{Left}"
*l::Send "{Blind}{Right}"
*o::Send "{Blind}{PgUp}"
*p::Send "{Blind}{PgDn}"
*h::Send "{Blind}{Home}"
*n::Send "{Blind}{End}"
*y::Send "{Blind}{Delete}"
*u::Send "{Blind}{BackSpace}" 
*vkBB::Send "{Blind}{Enter}" ; vkBB=";"
b::_
m::-
+m::=
@::=
vkBC::+[
.::+]

Tab::vkF0 ; vkF0=EISU

;*Space:: {
;	Send "{Blind}{Enter}"
;k	Exit
;}
Space::Send "{vkF3}"

q::Esc
e::MouseClick "left"
r::MouseClick "right"
w::MouseMove 0,-mouse_move,0,"R"
s::MouseMove 0,mouse_move,0,"R"
a::MouseMove -mouse_move,0,0,"R"
d::MouseMove mouse_move,0,0,"R"
^w::MouseMove 0,-mouse_move_long,0,"R"
^s::MouseMove 0,mouse_move_long,0,"R"
^a::MouseMove -mouse_move_long,0,0,"R"
^d::MouseMove mouse_move_long,0,0,"R"
+w::MouseMove 0,-mouse_move_long,0,"R"
+s::MouseMove 0,mouse_move_long,0,"R"
+a::MouseMove -mouse_move_long,0,0,"R"
+d::MouseMove mouse_move_long,0,0,"R"
t::WheelUp
g::WheelDown
f::Tab

a::^a
s::^s
g::^g
z::^z
x::^x
c::^c 
v::^v
Esc::Reload
#HotIf  ;#HotIf GetKeyState("F13", "P")
<+F13::Send "{Blind}+{CapsLock}"
F13::Return

#HotIf GetKeyState("F14", "P") || GetKeyState("vk1C", "P")
o::MouseClick "left"
@::MouseClick "right"
vkBC::WheelUp ;vkBCsc033 = ,
.::WheelDown

p::MouseMove 0,-mouse_move,0,"R"
vkBB::MouseMove 0,mouse_move,0,"R" ;vkBBsc027 = ;
l::MouseMove -mouse_move,0,0,"R"
vkBA::MouseMove mouse_move,0,0,"R" ;vkBAsc028 = :

+p::MouseMove 0,-mouse_move/2,0,"R"
+vkBB::MouseMove 0,mouse_move/2,0,"R" ;vkBBsc027 = ;
+l::MouseMove -mouse_move/2,0,0,"R"
+vkBA::MouseMove mouse_move/2,0,0,"R" ;vkBAsc028 = :

0::MouseMove 0,-mouse_move_long,0,"R"
-::MouseMove 0,-mouse_move_long,0,"R"
/::MouseMove 0,mouse_move_long,0,"R"
k::MouseMove -mouse_move_long,0,0,"R"
]::MouseMove mouse_move_long,0,0,"R" 

#HotIf ;GetKeyState("F14", "P") || GetKeyState("vk1C", "P")
vk1C::Return

#HotIf GetKeyState("Space", "P")
*i::Send "{Blind}{Up}"
*k::Send "{Blind}{Down}"
;*j::Send "{Blind}{Left}"
;*l::Send "{Blind}{Right}"
*o::Send "{Blind}{PgUp}"
*p::Send "{Blind}{PgDn}"
*y::Send "{Blind}{Delete}"
*u::Send "{Blind}{BackSpace}" 
*vkBB::Send "{Blind}{Enter}" ; vkBB=";"
*h::Send "{Blind}{Home}"
*n::Send "{Blind}{End}"

j::{
  if GetKeyState("F13", "P"){
	Send "^{Left}"
  }else{
	Send "{Blind}{Left}"
  }
}
l::{
 If GetKeyState("F13", "P"){
  Send "^{Right}"
 }else{
  Send "{Blind}{Right}"
 }
}

h::{
  if GetKeyState("F13", "P"){
	Send "^{Home}"
  }else{
	Send "{Blind}{Home}"
  }
}
n::{
 If GetKeyState("F13", "P"){
  Send "^{End}"
 }else{
  Send "{Blind}{End}"
 }
}


b::_
m::-
+m::=
@::=
vkBC::+[
.::+]
+vkBC::[
+.::]

;F13::Send "{vkF0}" ; vkF0=EISU	

q::Esc
a::^a
s::^s
f::^f
g::^g
z::^z
x::^x
c::^c 
v::^v


1::Send "{Blind}{F1}"
2::Send "{Blind}{F2}"
3::Send "{Blind}{F3}"
4::Send "{Blind}{F4}"
5::Send "{Blind}{F5}"
6::Send "{Blind}{F6}"
7::Send "{Blind}{F7}"
8::Send "{Blind}{F8}"
9::Send "{Blind}{F9}"
0::Send "{Blind}{F10}"    
-::Send "{Blind}{F11}"
^::Send "{Blind}{F12}"
#HotIf ;#HotIf GetKeyState("Space", "P")

;In case of prssing space key alone
pressed := 0 ;  0: Spaced is not pressed 1: Space is pressed
modified := 0 ;  0:  A key is not pressed while space is pressed 1: A key is pressed while space is pressed
pressed_time := 0 ; Space pressed time
timeout := 300 ; 
hook := InputHook() ;  
       
*Space:: {
	global
	if (pressed = 1) {
		return
	}
	modified := 0
	pressed := 1
	pressed_time := A_TickCount

	hook := InputHook("L1 V")

	hook.Start()
	if (hook.Wait() != "Stopped") {
		modified := 1
	}
}

*Space up:: {
	global
	pressed := 0

	hook.Stop()

	if (A_TickCount - pressed_time > timeout) {
		return
	}
     
	if (modified == 0) {
		SendInput "{Blind}{Space}"
	}
}


