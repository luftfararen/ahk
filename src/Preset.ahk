#Requires AutoHotkey v2.0

/**
 * キーレイアウトを「Qwerty配列」に変更する
 */
ChangeQwertyLayout() {
    StoreLayout("Qwerty[Built-in]", "qwertyuiopasdfghjkl;zxcvbnm,./")
    ResetIME()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * キーレイアウトを「大西配列」に変更する
 */
ChangeOonishiLayout() {
    StoreLayout("Oonishi[Built-in]", "qlu,.fwrypeiao-ktnshzxcv;gdmjb", "1234567890/")
    ResetIME()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * キーレイアウトを「Colemak配列」に変更する
 */
ChangeColemakLayout() {
    StoreLayout("Colemak[Built-in]", "qwfpgjluy;arstdhneiozxcvbkm,./")
    ResetIME()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * Changes layout to "FMIX12f".
 */
ChangeFMIX12f_Layout() {
    StoreLayout("FMIX12f[Built-in]", "qwfrkylup;asdtghneiozxcvbjm,./")
    ResetIME()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * Changes layout to "FMIX12f-FMIX13fR".
 */
ChangeFMIX12f_FMIX13fR_Layout() {
    StoreLayout("FMIX12f-13fR[Built-in]", "qwfrkylup;asdtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; IME ON 時の差分設定
    e.SetImeKey("d")
    t.SetImeKey("f")
    d.SetImeKey("k")

    ShowOSD(TypeAnalyzer.current_layout . " layout")
}
/**
 * Changes layout to "FMIX14-FMIX14R".
 */
ChangeFMIX14_FMIX14R_Layout() {
    StoreLayout("FMIX14-14R[Built-in]", "qwldkylup;asrtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; IME ON 時の差分設定
    e.SetImeKey("r")
    t.SetImeKey("l")
    d.SetImeKey("k")

    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * 湊（みなと）配列に特有な IME ON 時の差分マッピング（複合母音キーの割り当てなど）を設定する共通ヘルパーです。
 */
ChangeMinatoLayoutImpl(ei := True) {
    global q, w, e, r, t, a, s, d, f, z, x, c, v, b, y, u, i, o, p, h, j, k, l, semicolon, n, m
    ResetIME()

    ; IME ON 時の差分設定
    q.SetImeKey("j", "?")
    w.SetImeKey("w")
    e.SetImeKey("r", "l")
    r.SetImeKey("d")
    t.SetImeKey("f")
    a.SetImeKey("n", "(")
    s.SetImeKey("s", "sil")
    d.SetImeKey("k")
    f.SetImeKey("t")
    g.SetImeKey("g")
    z.SetImeKey("z", "[")
    x.SetImeKey("p", "]")
    c.SetImeKey("m", "c")
    v.SetImeKey("h", "v")
    b.SetImeKey("b", "v")
    y.SetImeKey("ye", "y")
    u.SetImeKey("yu", "{BS}")
    i.SetImeKey("u", "unn")
    o.SetImeKey("yo")
    p.SetImeKey("ou")
    h.SetImeKey(";", "yann")
    j.SetImeKey("a", "ann")
    if ei {
        k.SetImeKey("e", "enn")
        l.SetImeKey("i", "inn")
    } else {
        k.SetImeKey("i", "inn")
        l.SetImeKey("e", "enn")
    }
    semicolon.SetImeKey("o", "onn")
    n.SetImeKey("-", "a-")
    m.SetImeKey("ya", "y-")

    rm := CreateKeyMap()
    global LAYOUT_KEYS
    SetLKeyMode(LAYOUT_KEYS, -1, 6)

    target_layers := [j, k, i, l, semicolon, o, u, m] ; あいうえおやゆよ
    for layer_key in target_layers {
        RegistIMECombination(8, layer_key, d, "nn") ; ん
        RegistIMECombination(8, layer_key, f, "-") ;ー
        RegistIMECombination(8, layer_key, v, "ltu", "ta", "{BS}te") ;
        RegistIMECombination(8, layer_key, e, "ru", "{BS}rareru") ;
    }

    RegistIMECombination(7, rm["k"], rm["t"], "oto") ;こと
    RegistIMECombination(7, rm["k"], r, "ara") ;から
    RegistIMECombination(7, rm["o"], j, "u") ;
    RegistIMECombination(7, rm["s"], rm["t"], "ite", "{BS}ta") ;して
    RegistIMECombination(7, rm["s"], rm["r"], "uru", "{BS}{BS}sareru") ;する、される
    RegistIMECombination(7, rm["s"], r, "uru", "{BS}{BS}sareru") ;する、される
    RegistIMECombination(7, rm["r"], r, "eru", "{BS}{BS}rareru") ;られる
    RegistIMECombination(7, z, v, "youhou") ;
    RegistIMECombination(7, rm["u"], j, "{BS}{BS}", "{BS}") ;
    RegistIMECombination(7, rm["u"], u, "{BS}{BS}", "{BS}") ;
    RegistIMECombination(7, k, j, "{BS}{BS}", "{BS}") ;
    RegistIMECombination(7, rm["m"], v, "ono") ;
    RegistIMECombination(7, rm["n"], r, "ode") ;
}

/**
 * キーレイアウトを「FMIX13-Minato配列」に変更し、湊配列用の日本語入力差分を適用します。
 */
ChangeFMIX13_Minato_Layout() {
    StoreLayout("FMIX13-Minato[Built-in]", "qwrlkyfup;asdtghneiozxcvbjm,./")
    ChangeMinatoLayoutImpl()
    InitModLayer()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * キーレイアウトを「FMIX15-FMIX15R配列」に変更し、IME ON時の差分およびレイヤーを初期化します。
 */
ChangeFMIX15_FMIX15R_Layout() {
    StoreLayout("FMIX15-FMIX15R[Built-in]", "qwldkjfuy;asrtghneiozxcvbpm,./")

    global e, t, d

    ; IME ON 時の差分設定
    e.SetImeKey("r")
    t.SetImeKey("l")
    d.SetImeKey("k")

    InitModLayer()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * キーレイアウトを「FMIX13f-Minato配列」に変更し、湊配列用の日本語入力差分を適用します。
 */
ChangeFMIX13f_Minato_Layout() {
    StoreLayout("FMIX13f-Minato[Built-in]", "qwrfkylup;asdtghneiozxcvbjm,./")
    ChangeMinatoLayoutImpl()
    InitModLayer()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * キーレイアウトを「TF2_2-Minato配列」に変更し、湊配列用の日本語入力差分を適用します。
 */
ChangeTF2_2_Minato_Layout() {
    StoreLayout("TF2_2-Minato[Built-in]", "qwerfjluykasdtghneiozxcvbpm,./")
    ChangeMinatoLayoutImpl()
    InitModLayer()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * キーレイアウトを「STREAM1.5配列」に変更し、レイヤーを初期化します。
 */
ChangeSTREAM1_5_Layout() {
    StoreLayout("STREAM1.5[Built-in]", "qwrpkvcuy;asntgfheiozxldbjf,./", "1234567890-", "", "", true)

    InitModLayer()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * 各レイヤー（ナビゲーション、記号、テンキー、選択、Shiftなど）に対する、物理キーから送信キーへの具体的なマッピングを初期設定します。
 */
InitModLayer() {
    start_qpc := HighPrecisionTimer()

    global k1, k2, k3, k4, k5, k6, k7, k8, k9, k0, minus, hat, yen
    global q, w, e, r, t, y, u, i, o, p, at, openbracket
    global a, s, d, f, g, h, j, k, l, semicolon, colon, closebracket
    global z, x, c, v, b, n, m, comma, period, slash, backslash

    global L_NAVI_CTRL, L_SYMBOL_NUM, L_SYMBOL1, L_SYMBOL2, L_SELECT, L_NUMPAD, L_SHIFT, L_FUNC

    ;SetLKeyMode(3)
    mode := 3
    ; L_SELECT
    k1.SetLayerKey(mode, L_SELECT, "^z")
    k2.SetLayerKey(mode, L_SELECT, "^x")
    k3.SetLayerKey(mode, L_SELECT, "^c")
    k4.SetLayerKey(mode, L_SELECT, "^v")
    z.SetLayerKey(mode, L_SELECT, "^z")
    x.SetLayerKey(mode, L_SELECT, "^x")
    c.SetLayerKey(mode, L_SELECT, "^c")
    v.SetLayerKey(mode, L_SELECT, "^v")
    b.SetLayerKey(mode, L_SELECT, "^z")
    y.SetLayerKey(mode, L_SELECT, R_REDO)
    u.SetLayerKey(mode, L_SELECT, C_BS)
    i.SetLayerKey(mode, L_SELECT, "+{Up}")
    o.SetLayerKey(mode, L_SELECT, "+{PgUp}")
    p.SetLayerKey(mode, L_SELECT, "+{PgDn}")
    at.SetLayerKey(mode, L_SELECT, C_CSHOME)
    openbracket.SetLayerKey(mode, L_SELECT, C_CSEND)
    h.SetLayerKey(mode, L_SELECT, "+{Home}")
    j.SetLayerKey(mode, L_SELECT, "+{Left}")
    k.SetLayerKey(mode, L_SELECT, "+{Down}")
    l.SetLayerKey(mode, L_SELECT, "+{Right}")
    semicolon.SetLayerKey(mode, L_SELECT, "+{Enter}")
    enter.SetLayerKey(mode, L_SELECT, B_ENTER)
    n.SetLayerKey(mode, L_SELECT, "+{End}")
    m.SetLayerKey(mode, L_SELECT, C_DEL)
    comma.SetLayerKey(mode, L_SELECT, "^+{Left}")
    period.SetLayerKey(mode, L_SELECT, "^+{Right}")
    space.SetLayerKey(mode, L_SELECT, C_BS)
    up.SetLayerKey(mode, L_SELECT, "+{Up}")
    left.SetLayerKey(mode, L_SELECT, "+{Left}")
    down.SetLayerKey(mode, L_SELECT, "+{Down}")
    right.SetLayerKey(mode, L_SELECT, "+{Right}")

    ; L_NAVI_CTRL
    k1.SetLayerKey(mode, L_NAVI_CTRL, B_F1)
    k2.SetLayerKey(mode, L_NAVI_CTRL, B_F2)
    k3.SetLayerKey(mode, L_NAVI_CTRL, B_F3)
    k4.SetLayerKey(mode, L_NAVI_CTRL, B_F4)
    k5.SetLayerKey(mode, L_NAVI_CTRL, B_F5)
    k6.SetLayerKey(mode, L_NAVI_CTRL, B_F6)
    k7.SetLayerKey(mode, L_NAVI_CTRL, B_F7)
    k8.SetLayerKey(mode, L_NAVI_CTRL, B_F8)
    k9.SetLayerKey(mode, L_NAVI_CTRL, B_F9)
    k0.SetLayerKey(mode, L_NAVI_CTRL, B_F10)
    minus.SetLayerKey(mode, L_NAVI_CTRL, B_F11)
    hat.SetLayerKey(mode, L_NAVI_CTRL, B_F12)
    yen.SetLayerKey(mode, L_NAVI_CTRL, "^+{sc07D}")
    z.SetLayerKey(mode, L_NAVI_CTRL, B_UNDO)
    x.SetLayerKey(mode, L_NAVI_CTRL, B_CUT)
    c.SetLayerKey(mode, L_NAVI_CTRL, B_COPY)
    v.SetLayerKey(mode, L_NAVI_CTRL, B_PASTE)
    b.SetLayerKey(mode, L_NAVI_CTRL, B_UNDO)
    y.SetLayerKey(mode, L_NAVI_CTRL, B_UNDO)
    u.SetLayerKey(mode, L_NAVI_CTRL, B_BS)
    i.SetLayerKey(mode, L_NAVI_CTRL, B_UP)
    o.SetLayerKey(mode, L_NAVI_CTRL, B_PGUP)
    p.SetLayerKey(mode, L_NAVI_CTRL, B_PGDN)
    at.SetLayerKey(mode, L_NAVI_CTRL, B_CHOME)
    openbracket.SetLayerKey(mode, L_NAVI_CTRL, B_CEND)
    h.SetLayerKey(mode, L_NAVI_CTRL, B_HOME)
    j.SetLayerKey(mode, L_NAVI_CTRL, B_LEFT)
    k.SetLayerKey(mode, L_NAVI_CTRL, B_DOWN)
    l.SetLayerKey(mode, L_NAVI_CTRL, B_RIGHT)
    semicolon.SetLayerKey(mode, L_NAVI_CTRL, "+{Enter}")
    colon.SetLayerKey(mode, L_NAVI_CTRL, "^{Enter}")
    closebracket.SetLayerKey(mode, L_NAVI_CTRL, "^+{sc07D}")
    n.SetLayerKey(mode, L_NAVI_CTRL, B_END)
    m.SetLayerKey(mode, L_NAVI_CTRL, B_DEL)
    comma.SetLayerKey(mode, L_NAVI_CTRL, B_CLEFT)
    period.SetLayerKey(mode, L_NAVI_CTRL, B_CRIGHT)
    slash.SetLayerKey(mode, L_NAVI_CTRL, "^+{sc07D}")
    enter.SetLayerKey(mode, L_NAVI_CTRL, "{Blind}^{Enter}")
    a.SetLayerKey(mode, L_NAVI_CTRL, "{Blind}^a")

    ; L_SYMBOL_NUM
    k1.SetLayerKey(mode, L_SYMBOL_NUM, B_F1)
    k2.SetLayerKey(mode, L_SYMBOL_NUM, B_F2)
    k3.SetLayerKey(mode, L_SYMBOL_NUM, B_F3)
    k4.SetLayerKey(mode, L_SYMBOL_NUM, B_F4)
    k5.SetLayerKey(mode, L_SYMBOL_NUM, B_F5)
    k6.SetLayerKey(mode, L_SYMBOL_NUM, B_F6)
    k7.SetLayerKey(mode, L_SYMBOL_NUM, B_F7)
    k8.SetLayerKey(mode, L_SYMBOL_NUM, B_F8)
    k9.SetLayerKey(mode, L_SYMBOL_NUM, B_F9)
    k0.SetLayerKey(mode, L_SYMBOL_NUM, B_F10)
    minus.SetLayerKey(mode, L_SYMBOL_NUM, B_F11)
    hat.SetLayerKey(mode, L_SYMBOL_NUM, B_F12)
    q.SetLayerKey(mode, L_SYMBOL_NUM, "?")
    w.SetLayerKey(mode, L_SYMBOL_NUM, "{Blind}/")
    e.SetLayerKey(mode, L_SYMBOL_NUM, B_NMUL)
    r.SetLayerKey(mode, L_SYMBOL_NUM, B_NADD)
    t.SetLayerKey(mode, L_SYMBOL_NUM, ":=")
    a.SetLayerKey(mode, L_SYMBOL_NUM, "(")
    s.SetLayerKey(mode, L_SYMBOL_NUM, ")")
    d.SetLayerKey(mode, L_SYMBOL_NUM, "_")
    f.SetLayerKey(mode, L_SYMBOL_NUM, "{Blind}-")
    g.SetLayerKey(mode, L_SYMBOL_NUM, "=")
    y.SetLayerKey(mode, L_SYMBOL_NUM, C_YEN)
    u.SetLayerKey(mode, L_SYMBOL_NUM, C_N7)
    i.SetLayerKey(mode, L_SYMBOL_NUM, C_N8)
    o.SetLayerKey(mode, L_SYMBOL_NUM, C_N9)
    p.SetLayerKey(mode, L_SYMBOL_NUM, "+^p")
    h.SetLayerKey(mode, L_SYMBOL_NUM, "=")
    j.SetLayerKey(mode, L_SYMBOL_NUM, C_N0)
    k.SetLayerKey(mode, L_SYMBOL_NUM, C_N1)
    l.SetLayerKey(mode, L_SYMBOL_NUM, C_N2)
    semicolon.SetLayerKey(mode, L_SYMBOL_NUM, C_N3)
    n.SetLayerKey(mode, L_SYMBOL_NUM, "+3")
    m.SetLayerKey(mode, L_SYMBOL_NUM, C_N4)
    comma.SetLayerKey(mode, L_SYMBOL_NUM, C_N5)
    period.SetLayerKey(mode, L_SYMBOL_NUM, C_N6)
    z.SetLayerKey(mode, L_SYMBOL_NUM, "+[")
    x.SetLayerKey(mode, L_SYMBOL_NUM, "+]")
    c.SetLayerKey(mode, L_SYMBOL_NUM, "[")
    v.SetLayerKey(mode, L_SYMBOL_NUM, "]")
    b.SetLayerKey(mode, L_SYMBOL_NUM, C_BACKSLASH)
    space.SetLayerKey(mode, L_SYMBOL_NUM, B_BS)

    global LAYOUT_KEYS
    copyLayer(LAYOUT_KEYS, L_SYMBOL_NUM, L_SYMBOL1)

    a.SetLayerKey(mode, L_NUMPAD, "(")
    s.SetLayerKey(mode, L_NUMPAD, ")")
    f.SetLayerKey(mode, L_NUMPAD, "-")
    g.SetLayerKey(mode, L_NUMPAD, "=")
    k7.SetLayerKey(mode, L_NUMPAD, C_N7)
    k8.SetLayerKey(mode, L_NUMPAD, C_N8)
    k9.SetLayerKey(mode, L_NUMPAD, C_N9)
    k0.SetLayerKey(mode, L_NUMPAD, B_NMUL)
    minus.SetLayerKey(mode, L_NUMPAD, B_NSUB)
    hat.SetLayerKey(mode, L_NUMPAD, C_HAT)
    yen.SetLayerKey(mode, L_NUMPAD, "\")
    y.SetLayerKey(mode, L_NUMPAD, C_BS)
    u.SetLayerKey(mode, L_NUMPAD, C_N4)
    i.SetLayerKey(mode, L_NUMPAD, C_N5)
    o.SetLayerKey(mode, L_NUMPAD, C_N6)
    p.SetLayerKey(mode, L_NUMPAD, B_NADD)
    at.SetLayerKey(mode, L_NUMPAD, B_UP)
    h.SetLayerKey(mode, L_NUMPAD, "=")
    j.SetLayerKey(mode, L_NUMPAD, C_N1)
    k.SetLayerKey(mode, L_NUMPAD, C_N2)
    l.SetLayerKey(mode, L_NUMPAD, C_N3)
    semicolon.SetLayerKey(mode, L_NUMPAD, B_LEFT)
    colon.SetLayerKey(mode, L_NUMPAD, B_DOWN)
    closebracket.SetLayerKey(mode, L_NUMPAD, B_RIGHT)
    n.SetLayerKey(mode, L_NUMPAD, C_DEL)

    ; L_SYMBOL2
    q.SetLayerKey(mode, L_SYMBOL2, "!") ;Exclamation Mark
    w.SetLayerKey(mode, L_SYMBOL2, "@") ;Commercial At
    e.SetLayerKey(mode, L_SYMBOL2, "+3") ;Number Sign
    r.SetLayerKey(mode, L_SYMBOL2, "$") ;Dollar Sign
    t.SetLayerKey(mode, L_SYMBOL2, "%") ;Percent Sign
    a.SetLayerKey(mode, L_SYMBOL2, "&") ;Ampersand
    s.SetLayerKey(mode, L_SYMBOL2, "+7") ;' single quotation
    d.SetLayerKey(mode, L_SYMBOL2, "+2") ;' double quotation
    f.SetLayerKey(mode, L_SYMBOL2, ";") ;Semicolon
    g.SetLayerKey(mode, L_SYMBOL2, "+@") ;Grace Accent
    z.SetLayerKey(mode, L_SYMBOL2, "~") ;Tilde
    x.SetLayerKey(mode, L_SYMBOL2, C_HAT) ;Accent Circumflex
    c.SetLayerKey(mode, L_SYMBOL2, ":") ;Colon
    v.SetLayerKey(mode, L_SYMBOL2, "|") ;Vertical Line
    b.SetLayerKey(mode, L_SYMBOL2, "\") ;Backward Slash
    h.SetLayerKey(mode, L_SYMBOL2, "=")
    comma.SetLayerKey(mode, L_SYMBOL2, "<=")
    period.SetLayerKey(mode, L_SYMBOL2, ">=")

    ; L_SHIFT
    k1.SetLayerKey(mode, L_SHIFT, B_F1)
    k2.SetLayerKey(mode, L_SHIFT, B_F2)
    k3.SetLayerKey(mode, L_SHIFT, B_F3)
    k4.SetLayerKey(mode, L_SHIFT, B_F4)
    k5.SetLayerKey(mode, L_SHIFT, B_F5)
    k6.SetLayerKey(mode, L_SHIFT, B_F6)
    k7.SetLayerKey(mode, L_SHIFT, B_F7)
    k8.SetLayerKey(mode, L_SHIFT, B_F8)
    k9.SetLayerKey(mode, L_SHIFT, B_F9)
    k0.SetLayerKey(mode, L_SHIFT, B_F10)
    minus.SetLayerKey(mode, L_SHIFT, B_F11)
    hat.SetLayerKey(mode, L_SHIFT, B_F12)
    colon.SetLayerKey(mode, L_SHIFT, "+{Enter}")
    closebracket.SetLayerKey(mode, L_SHIFT, "+]")

    ; L_FUNC (conv + f14 同時押し)
    k1.SetLayerKey(mode, L_FUNC, B_F1)
    k2.SetLayerKey(mode, L_FUNC, B_F2)
    k3.SetLayerKey(mode, L_FUNC, B_F3)
    k4.SetLayerKey(mode, L_FUNC, B_F4)
    k5.SetLayerKey(mode, L_FUNC, B_F5)
    k6.SetLayerKey(mode, L_FUNC, B_F6)
    k7.SetLayerKey(mode, L_FUNC, B_F7)
    k8.SetLayerKey(mode, L_FUNC, B_F8)
    k9.SetLayerKey(mode, L_FUNC, B_F9)
    k0.SetLayerKey(mode, L_FUNC, B_F10)
    minus.SetLayerKey(mode, L_FUNC, B_F11)
    hat.SetLayerKey(mode, L_FUNC, B_F12)
}
