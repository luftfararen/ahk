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

Tab::vkF0 ; vkF0=EISU

*Space:: {
	Send "{Blind}{Enter}"
	Exit
}

e::MouseClick "left"
r::MouseClick "right"
w::MouseMove 0,-10,0,"R"
s::MouseMove 0,10,0,"R"
a::MouseMove -10,0,0,"R"
d::MouseMove 10,0,0,"R"

#HotIf  
<+F13::Send "{Blind}+{CapsLock}"

#HotIf GetKeyState("Space", "P")
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

s::^s

#HotIf        

;In case of prssing space key alone
pressed := 0 ;  0: Spaced is not pressed 1: Space is pressed
modified := 0 ;  0:  A key is not pressed while space is pressed 1: A key is not pressed while space is pressed
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
