>+Up::_
<+F13::Send "{Blind}+{CapsLock}"
^Up::Home ; 
^Down::End ;
^Space::Send "{vkF3}"
RWin::Send "{RCtrl}"
;F13 & vk1D::vkF0  
;
F13 & i::Send "{Blind}{Up}"
F13 & k::Send "{Blind}{Down}"
F13 & j::Send "{Blind}{Left}"
F13 & l::Send "{Blind}{Right}"
F13 & o::Send "{Blind}{Down}"
F13 & p::Send "{Blind}{Right}"
F13 & vkBB::Send "{Blind}{Right}" ;vkBBsc027 = ; +
F13 & vkBA::^Right                ;vkBAsc027 = : *
F13 & m::^Left
F13 & vkBC::^Right                ;vkBCsc033 = , <
F13 & [::Send "{Bli;;nd}{PgUp}"
F13 & ]::Send "{Blind}{PgDn}"
F13 & h::Send "{Blind}{Home}"
F13 & n::Send "{Blind}{End}"
F13 & y::Send "{Blind}{Delete}"
F13 & u::Send "{Blind}{BackSpace}"
F13 & .::Return
F13 & t::^Home ;Top
F13 & g::^Home 
F13 & b::^End  ;Bottom
F13 & z::^z
F13 & x::^x
F13 & c::^c 
F13 & v::^v
F13 & @::Return
F13 & Space::Enter                
F13 & q::Send "{Blind}{Esc}" ;vkF0sc03A= Eisu 
F13 & Tab::vkF0 ; 

F13 & w::Send "{Blind}{Up}"
F13 & s::Send "{Blind}{Down}"
F13 & a::Send "{Blind}{Left}"
F13 & d::Send "{Blind}{Right}"
F13 & Up::PgUp
F13 & Down::PgDn

F13 & f::^f
F13 & e::+F3
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


;vk1Dsc07B	無変換
vk1D & i::Send "{Blind}{Up}"
vk1D & k::Send "{Blind}{Down}"
vk1D & j::Send "{Blind}{Left}"
vk1D & l::Send "{Blind}{Right}"
vk1D & o::Send "{Blind}{Down}"
vk1D & p::Send "{Blind}{Right}"      
vk1D & vkBB::Send "{Blind}{Right}" ;vkBBsc027 = ;
vk1D & vkBA::^Right                ;vkBAsc028 = :
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

;vkF2sc070 = ひらがな/カタカナ
vkF2 & i::Up
vkF2 & k::Down
vkF2 & j::^Left
vkF2 & l::^Right
vkF2 & o::Down
vkF2 & p::^Right      
vkF2 & vkBB::^Right                ;vkBBsc027 = ; +
vkF2 & vkBA::^Right                ;vkBAsc028 = : *
vkF2 & h::^Home
vkF2 & n::^End

;vk1Csc079 = 変換
;vkE2sc073 = \
;vkBBsc027 = ; +
;vkBAsc028 = : *
;vkBCsc033 = ,
;vkF0sc03A = Eisu
;vkF2sc070 = ひらがな/カタカナ
;vkF3sc029 = 全角/半角 sendでおくらなければいけない
;vkF4sc029 = 全角/半角 sendでおくらなければいけない
;- ^ ¥ @ [ ] . /
;Space Tab Enter BS Del Ins Left  Right Up Down Home End PgUp PgDn
;# win
;ctrl ^
;shift +
;alt !


