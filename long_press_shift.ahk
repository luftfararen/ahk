﻿#Requires AutoHotkey v2.0

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

;mouse_move := A_ScreenWidth/160
;mouse_move_short := A_ScreenWidth/320
;mouse_move_long := A_ScreenWidth/8

timeout := 300 ;
timeout_lp := 350 ;For long press

InstallKeybdHook true
#UseHook true
#MaxThreadsBuffer True

lock_num := 0
ChangeLockState(num)
{
	global lock_num
	if lock_num != num{
		lock_num := num
	}else{
		lock_num := 0
	}
}


hook := InputHook("L1 V")
class LongPress
{
	;key: base key, not inclueds "{}"
	;long_key long pressed key, inclueds "{}"
	;kana True: related kana key, False: not related kana key
	;lock_key1: key when locked
	__New(key, long_key:="", kana:=False, lock_key1 := "")
	{
		this.key := key
		this.key1 := lock_key1
		if long_key = ""{
			this.long_key :=  "+{" . this.key . "}"
		}else{
			this.long_key := long_key
		}
		this.pressed_time := 0
		this.pressed_time2 := 0
		this.up_sent := 0
		this.kana := kana
	}

	IsKana()
	{
		return this.kana && IME_GET()	
	}
	
	Down()
	{	
		global lock_num
		if lock_num > 0 && this.key1 != "" {
			SendEvent this.key1
			return
		}
		lock_num := 0
		if this.pressed_time != 0 {
			return
		}
		this.pressed_time :=  A_TickCount
		if this.pressed_time2 != 0 && this.pressed_time - this.pressed_time2 < 70{
			this.up_sent := 0
			this.pressed_time := 0
			this.pressed_time2 := 0
			return 
		}
	
		;SendInput "{Blind}" . "{" . this.key . "}"
		SendEvent "{" . this.key . "}"
		this.pressed_time2 := 0
		if this.IsKana(){
			return
		}
		this.up_sent := 1
		hook.Start()
		if	hook.wait() != "Stopped"  {
			this.up_sent := 0
		}
	}

	Up()
	{
		global lock_num
		if lock_num > 0 && this.key1 != "" {
			return
		}

		global timeout_lp
		time := A_TickCount - this.pressed_time
		hook.Stop()
		Sleep(2)
		if this.up_sent = 1 {
			if time >= timeout_lp {
				this.pressed_time2 := A_TickCount
				;				SendInput "{BackSpace}{Blind}" . this.long_key
				SendEvent "{BackSpace}" ;SendIput does not work
				SendEvent  this.long_key
				Sleep(10)
			}
		}
		this.up_sent := 0
		this.pressed_time := 0
	}
}

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

semicolon := LongPress("sc027","+{sc027}",False,"+{sc027}")
colon := LongPress("sc028","+{sc028}",False,"+{sc028}")
slash := LongPress("/","+/",False,"/")

k1 := LongPress("1","+1")
k2 := LongPress("2","+2")
k3 := LongPress("3","+3")
k4 := LongPress("4","+4")
k5 := LongPress("5","+5")
k6 := LongPress("6","+6")
k7 := LongPress("7","+7",False,"7")
k8 := LongPress("8","+8",False,"8")
k9 := LongPress("9","+9",False,"9")
minus := LongPress("-","+-",False,"-")							
hat := LongPress("^","+{sc00D}",False,"^")
backslash := LongPress("\","+\",False,"\")

q := LongPress("q","+q")
w := LongPress("w","+w",True)
e := LongPress("e","+e",True)
r := LongPress("r","+r",True)
t := LongPress("t","+t",True)
y := LongPress("y","+y",True,"{Delete}")
u := LongPress("u","+u",True,"4")
i := LongPress("i","+i",True,"5")
o := LongPress("o","+o",True,"6")
p := LongPress("p","+p",True,"{Backspace}")
at := LongPress("@","+@",False,"{Enter}")
openbracket := LongPress("[","+[",False,"+8")

a := LongPress("a","+a",True)
s := LongPress("s","+s",True)
d := LongPress("d","+d",True)
f := LongPress("f","+f",True)
g := LongPress("g","+g",True)
h := LongPress("h","+h",True,"{Backspace}")
j := LongPress("j","+j",True,"1")
k := LongPress("k","+k",True,"2")
l := LongPress("l","+l",True,"3")
closebracket := LongPress("]","+]",False,"+9")

z := LongPress("z","+z",True)
x := LongPress("x","+x",True)
c := LongPress("c","+c",True)
v := LongPress("v","+v",True)
b := LongPress("b","+b",True)
n := LongPress("n","+n",True)
m := LongPress("m","+m",True,"0")
comma := LongPress("sc033","+{sc033}",False,"{sc033}")
perid := LongPress(".","+.",False,".")
backslash2 := LongPress("sc073","+{sc073}",False,"+{sc073}")

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
  

MoveMousePos(rx, ry)
{
  size := 4
  point := Buffer(size * 2)
  DllCall("GetCursorPos", "Ptr", point)
  x := NumGet(point, 0, "Int")
  y := NumGet(point, size, "Int")
  DllCall("SetCursorPos", "int", x+rx, "int", y+ry)
} 


;***代用シフト**************************************************************************
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
*p::SendDirKey("{Down}")

*[::Send "{Blind}{PgUp}"
*]::Send "{Blind}{PgDn}"
*y::Send "{Blind}{Delete}"
*u::Send "{Blind}{BackSpace}"

sc027::Send "{Enter}" ;semicolon
sc028::^g ;vkBAsc028 = : shift:*
@::Send "{Enter}"
;@::^g
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

sc033::ChangeLockState(1)

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
j up::j.Up()
k::k.Down()
k up::k.Up()
l::l.Down()
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

;***修飾長押し処理/他****************************************************************************
#HotIf 
*Space:: space.Down()
*Space up:: space.Up()

;*sc027:: semicolon.Down()
;*sc027 up:: semicolon.Up()


sc079::Return ;vk1Csc079 = 変換
sc07B::Return ;vk1Dsc07B = 無変換

NumLock::Return
+F15::Send "{NumLock}"

>+Up::_
^+F13::Send "+{CapsLock}" ;Change CapsLock off setting to shift on Windows setting

#MaxThreadsBuffer False