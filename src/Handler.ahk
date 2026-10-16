#Requires AutoHotkey v2.0

; クリップボード履歴 (TextInputHost.exe) や PowerToys Advanced Paste などの
; 外部アプリからの貼り付け (Ctrl+V 等) がスクリプトのリマップ (*v) に横取りされないようパススルー
#HotIf !WinActive("ahk_group RemoteDesktops")
~^v:: {
}
#HotIf

; ============================================================================
; ホットキー定義（レイヤー）
; ============================================================================
;*** レイヤー（システム/アプリ制御） ***
#HotIf Layers.State(L_NAVI_CTRL)

sc029:: Send(C_EISU) ; Zen/Han -> Eisu
*Enter:: enter.SendLayerKey(L_NAVI_CTRL) ; Enter -> Ctrl+Enter

Esc:: {
    TypeAnalyzer.Save(true)
    TypeAnalyzer.SaveConfig()
    Reload()
}

q::#!space ; Win+Alt+Space
*e:: Send(B_ESC) ; Esc
r::+F3 ; Shift+F3
*s:: Send("{Blind}^s") ;
*d:: Send("{Blind}^{Space}") ; Ctrl+Space (IME toggle, etc.)
*f:: Send(B_TAB) ; Tab
g:: Send("^f") ; Find
; --- M1 保持中の IME 切り替え ---
F14:: ToggleImeState() ; F14/Enter
sc079:: ToggleImeState() ; Convert
space:: ToggleImeState() ;Send(C_BS)
#f:: ToggleForceImeModeOn() ;Toggle Force IME Mode ON
#p:: OpenConfigEditor()
; --- レイアウト切り替え ---
#r:: ChangeFMIX14_FMIX14R_Layout()
#t:: ChangeFMIX15_FMIX15R_Layout()
#x:: ChangeTF2_2_Minato_Layout()
#s:: ChangeSTREAM1_5_Layout()
#m:: ChangeFMIX13f_Minato_Layout()
#q:: ChangeQwertyLayout()
#o:: ChangeOonishiLayout()
#c:: ChangeColemakLayout()
#1:: LoadLayoutFromIni(1)
#2:: LoadLayoutFromIni(2)
#3:: LoadLayoutFromIni(3)
#4:: LoadLayoutFromIni(4)
#5:: LoadLayoutFromIni(5)
#6:: LoadLayoutFromIni(6)
#7:: LoadLayoutFromIni(7)
#8:: LoadLayoutFromIni(8)
#9:: LoadLayoutFromIni(9)
#0:: LoadLayoutFromIni(0)
#sc033:: TypeAnalyzer.ToggleImeIndicator()
#.:: TypeAnalyzer.ToggleLogging()
#h:: ShowHelp()

; --- マウス速度 ---
#up:: MouseSpeed.IncSpeed() ; Win+Up
#down:: MouseSpeed.DecSpeed() ; Win+Down
#HotIf
; ============================================================================
; グローバルホットキー (RKey / LKey バインド)
; ============================================================================
; これらのホットキーはレイヤーが押されていない時にアクティブになります。
; それぞれの RKey/LKey オブジェクトの Down() と Up() メソッドを呼び出し、
; リマップ、モディファイアのパススルー、および長押しのロジックを処理します。
#HotIf !WinActive("ahk_group IgnoreWindows")
*1:: k1.Down()
*1 up:: k1.Up()
*2:: k2.Down()
*2 up:: k2.Up()
*3:: k3.Down()
*3 up:: k3.Up()
*4:: k4.Down()
*4 up:: k4.Up()
*5:: k5.Down()
*5 up:: k5.Up()
*6:: k6.Down()
*6 up:: k6.Up()
*7:: k7.Down()
*7 up:: k7.Up()
*8:: k8.Down()
*8 up:: k8.Up()
*9:: k9.Down()
*9 up:: k9.Up()
*0:: k0.Down()
*0 up:: k0.Up()
*-:: minus.Down()
*- up:: minus.Up()
*sc00D:: hat.Down() ; ^
*sc00D up:: hat.Up()
*sc07D:: yen.Down() ; ¥
*sc07D up:: yen.Up()
*q:: q.Down()
*q up:: q.Up()
*w:: w.Down()
*w up:: w.Up()
*e:: e.Down()
*e up:: e.Up()
*r:: r.Down()
*r up:: r.Up()
*t:: t.Down()
*t up:: t.Up()
*y:: y.Down()
*y up:: y.Up()
*u:: u.Down()
*u up:: u.Up()
*i:: i.Down()
*i up:: i.Up()
*o:: o.Down()
*o up:: o.Up()
*p:: p.Down()
*p up:: p.Up()
*@:: at.Down()
*@ up:: at.Up()
*[:: openbracket.Down()
*[ up:: openbracket.Up()
*a:: a.Down()
*a up:: a.Up()
*s:: s.Down()
*s up:: s.Up()
*d:: d.Down()
*d up:: d.Up()
*f:: f.Down()
*f up:: f.Up()
*g:: g.Down()
*g up:: g.Up()
*h:: h.Down()
*h up:: h.Up()
*j:: j.Down()
*j up:: j.Up()
*k:: k.Down()
*k up:: k.Up()
*l:: l.Down()
*l up:: l.Up()
*sc027:: semicolon.Down()
*sc027 up:: semicolon.Up()
*sc028:: colon.Down()
*sc028 up:: colon.Up()
*]:: closebracket.Down()
*] up:: closebracket.Up()
*z:: z.Down()
*z up:: z.Up()
*x:: x.Down()
*x up:: x.Up()
*c:: c.Down()
*c up:: c.Up()
*v:: v.Down()
*v up:: v.Up()
*b:: b.Down()
*b up:: b.Up()
*n:: n.Down()
*n up:: n.Up()
*m:: m.Down()
*m up:: m.Up()
*sc033:: comma.Down() ; ,
*sc033 up:: comma.Up()
*.:: period.Down()        ; .
*. up:: period.Up()
*sc035:: slash.Down() ; /
*sc035 up:: slash.Up()
*sc073:: backslash.Down() ; _
*sc073 up:: backslash.Up()
*Enter:: enter.Down()
*Enter up:: enter.Up()
*Down:: down.Down()
*Down up:: down.Up()
*Up:: up.Down()
*Up up:: up.Up()
*Left:: left.Down()
*Left up:: left.Up()
*Right:: right.Down()
*Right up:: right.Up()
;#Hotif ; コンテキスト依存ホットキーの終了
; ============================================================================
; グローバルホットキー (モディファイアキー バインド)
; ============================================================================
; これらのホットキーは常にアクティブで、物理キーを
; LKey（モディファイアモード）オブジェクトにバインドします。
*Space:: space.Down()
*Space up:: space.Up()
*tab:: tab.Down()
*tab up:: tab.Up()
*F13:: f13.Down()
*F13 up:: f13.Up()
*F14:: f14.Down()
*F14 up:: f14.Up()
*sc079:: conv.Down() ; 変換キー
*sc079 up:: conv.Up()
*sc07B:: noconv.Down() ; 無変換キー
*sc07B up:: noconv.Up()
; ============================================================================
; その他のグローバルホットキー
; ============================================================================
;NumLock::Return ; NumLock キーを無効化
+F15:: Send("{NumLock}") ; Shift+F15 で NumLock を送信
;*F15::Send("{NumLock}")
>+Up::_ ; RShift+Up -> _
; CapsLock 状態の修正
^+F13:: Send("+{CapsLock}")
; 標準 IME 切り替え (全角/半角キー)
+sc029:: Send(C_EISU) ; Shift + 全角/半角 -> 英数
sc029:: ToggleImeState() ; 全角/半角 -> IME 切り替え
#HotIf