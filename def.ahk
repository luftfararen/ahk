>+Up::_
<+F13::Send "{Blind}+{CapsLock}"
<^Up::Home ; 
<^Down::End ;
>^Up::PgUp ; 
>^Down::PgDn ;
;^Space::Send "{vkF3}" ;全角
RWin::Send "{RCtrl}"
;F13 & vk1D::vkF0  

F13 & vk1C::Send "{vkF3}"	;F13+変換 → 全角
F13 & F14::Send "{vkF3}"	;
;vkF2sc070 = ひらがな
;vkF3 全角/半角

F13 & Up::PgUp
F13 & Down::PgDn

F13 & i::Send "{Blind}{Up}"
F13 & k::Send "{Blind}{Down}"
F13 & j::Send "{Blind}{Left}"
F13 & l::Send "{Blind}{Right}"
;F13 & o::Send "{Blind}{Down}"
;F13 & p::Send "{Blind}{Right}"
F13 & o::Send "{Blind}{PgUp}"
F13 & p::Send "{Blind}{PgDn}"
F13 & vkBB::^Right ;vkBBsc027 = ; +
F13 & m::^Left
F13 & vkBC::^Right                ;vkBCsc033 = , <
F13 & [::Send "{Blind}{PgUp}"
F13 & ]::Send "{Blind}{PgDn}"
F13 & @::^Home
F13 & vkBA::^End  ;vkBAsc027 = : *
F13 & h::Send "{Blind}{Home}"
F13 & n::Send "{Blind}{End}"
F13 & y::Send "{Blind}{Delete}"
F13 & u::Send "{Blind}{BackSpace}"
F13 & .::Return
F13 & z::^z
F13 & x::^x
F13 & c::^c 
F13 & v::^v
F13 & Space::Enter                
F13 & Tab::vkF0 ; EISU
F13 & q::Send "{Blind}{Esc}"
F13 & vk1D::Esc ;F13+無変換 → Esc

;F13 & t::^Home ;Top
;F13 & g::^Home 
;F13 & b::^End  ;Bottom

F13 & t::WheelUp ;Send "{Blind}{PgUp}"
F13 & g::WheelDown ; "{Blind}{PgDn}"

F13 & w::MouseClick "left"
F13 & r::MouseClick "right"
F13 & e::MouseMove 0,-10,0,"R"
F13 & d::MouseMove 0,10,0,"R"
F13 & s::MouseMove -10,0,0,"R"
F13 & f::MouseMove 10,0,0,"R"

F13 & 1::F1
F13 & 2::F2
F13 & 3::F3
F13 & 4::F4
F13 & 5::F5
F13 & 6::F6
F13 & 7::F7
F13 & 8::F8
F13 & 9::F9
F13 & 0::F10
F13 & -::F11
F13 & ^::F12
;F13 & -::^-
;F13 & -::^+-

;vk1Dsc07B	無変換
vk1D & i::Send "{Blind}{Up}"
vk1D & k::Send "{Blind}{Down}"
vk1D & j::Send "{Blind}{Left}"
vk1D & l::Send "{Blind}{Right}"
vk1D & o::Send "{Blind}{Down}"
vk1D & p::Send "{Blind}{Right}"      
vk1D & vkBB::Send "{Blind}{Right}" ;vkBBsc027 = ;
vk1D & vkBA::Send "^{Right}"       ;vkBAsc028 = :
vk1D & m::^Left
vk1D & vkBC::^Right                ;vkBCsc033 = , <
vk1D & [::Send "{Blind}{PgUp}"
vk1D & ]::Send "{Blind}{PgDn}"
vk1D & h::Send "{Blind}{Home}"
vk1D & n::Send "{Blind}{End}"
vk1D & y::Send "{Blind}{Delete}"
vk1D & u::Send "{Blind}{BackSpace}"
vk1D & g::^Home
vk1D & .::Return
vk1D & b::^End
vk1D & z::^z
vk1D & x::^x
vk1D & c::^c
vk1D & v::^v
vk1D & f::^f
vk1D & 3::F3
vk1D & 2::+F3
vk1D & @::Return
vk1D & Space::Enter                ;vkF0sc03A= Eisu
vk1D & q::Send "{Blind}{Esc}" ; 
vk1D & Up::PgUp
vk1D & Down::PgDn
vk1D::Return

;F14　ひらlがな
F14 & l::Send "{Blind}{Left}"
F14 & p::Send "{Blind}{Up}"
;F14 & @::Send "{Blind}{Down}"
;F14 & [::Send "{Blind}{Right}"
F14 & [::Send "{Blind}{PgDn}"
F14 & @::Send "{Blind}{PgUp}"

F14 & vkBB::Send "{Blind}{Down}" ; vkBB=+ 
F14 & vkBA::Send "{Blind}{Right}" ; vkBA=*
F14 & ]::^Right
F14 & o::Send "{Blind}{BackSpace}"
F14 & i::Send "{Blind}{Delete}"
F14 & .::^Left
F14 & /::^Right

F14 & k::Send "{Blind}{Home}" 
F14 & vkBC::Send "{Blind}{End}" ; vkBC=,

F14 & j::^Home ;Top
F14 & m::^End  ;Bottom


F14 & t::^Home ;Top
F14 & g::^Home 
F14 & b::^End  ;Bottom

F14 & Space::Enter                

F14 & z::Send "{Blind}^{z}"
F14 & x::Send "{Blind}^{x}"
F14 & c::Send "{Blind}^{c}"
F14 & v::Send "{Blind}^{v}"

F14 & 1::F1
F14 & 2::F2
F14 & 3::F3
F14 & 4::F4
F14 & 5::F5
F14 & 6::F6
F14 & 7::F7
F14 & 8::F8
F14 & 9::F9
F14 & 0::F10
F14 & -::F11
F14 & ^::F12

/*
;vk1C 変換
vk1C & k::Send "{Blind}{Left}"
vk1C & o::Send "{Blind}{Up}"
vk1C & p::Send "{Blind}{Down}"
vk1C & @::Send "{Blind}{Right}"
vk1C & l::Send "{Blind}{Down}" 
vk1C & vkBB::Send "{Blind}{Right}" ; vkBB = "+"
vk1C & vkBA::Send "{Blind}{Right}" ; vkBA = "*"
vk1C & j::Send "{Blind}{Home}"
vk1C & m::Send "{Blind}{End}"
vk1C & i::Send "{Blind}{BackSpace}"
vk1C & u::Send "{Blind}{Delete}"
vk1C & vkBC::^Left ;vkBC = ","
vk1C & ]::^Right
vk1C & .::^Right
vk1C & -::^-
vk1C & -::^+-

vk1C & t::^Home ;Top
vk1C & g::^Home 
vk1C & b::^End  ;Bottom
vk1C & Space::Enter                

vk1C & z::Send "{Blind}^{z}"
vk1C & x::Send "{Blind}^{x}"
vk1C & c::Send "{Blind}^{c}"
vk1C & v::Send "{Blind}^{v}"

vk1C & 1::F1
vk1C & 2::F2
vk1C & 3::F3
vk1C & 4::F4
vk1C & 5::F5
vk1C & 6::F6
vk1C & 7::F7
vk1C & 8::F8
vk1C & 9::F9
vk1C & 0::F10
vk1C & -::F11
vk1C & ^::F12
*/
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
;Space Tab Enter BS Del Ins Left  Right Up Down Home End PgUp PgDn Esc
;win # 
;ctrl ^
;shift +
;alt !