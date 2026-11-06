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
 * FMIX13を英語入力用、湊配列を日本語入力用として変更する。
 */
ChangeFMIX13_Minato_Layout() {
    StoreLayout("FMIX13-Minato[Built-in]", "qwrlkyfup;asdtghneiozxcvbjm,./")
    ChangeMinatoLayoutImpl()
    InitModLayer()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * FMIX15を英語入力用、FMIX15Rを日本語入力用として変更する。
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
 * FMIX13f配列を英語入力用、湊配列を日本語入力用として変更する。
 */
ChangeFMIX13f_Minato_Layout() {
    StoreLayout("FMIX13f-Minato[Built-in]", "qwrfkylup;asdtghneiozxcvbjm,./")
    ChangeMinatoLayoutImpl()
    InitModLayer()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * TF配列を英語入力用、湊配列を日本語入力用として変更する。
 */
ChangeTF_Minato_Layout() {
    StoreLayout("TF-Minato[Built-in]", "qwerfylupjasdtghneiozxcvbkm,./")
    ChangeMinatoLayoutImpl()
    InitModLayer()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}
/**
 * TF配列1を英語入力用、湊配列を日本語入力用として変更する。
 */
ChangeTF1_Minato_Layout() {
    StoreLayout("TF1-Minato[Built-in]", "qwerfylupjasdtgnheiozxcvbkm,./")
    ChangeMinatoLayoutImpl()
    InitModLayer()
    ShowOSD(TypeAnalyzer.current_layout . " layout")
}

/**
 * TF配列2を英語入力用、湊配列を日本語入力用として変更する。
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

SetLayerKeys(layout, mode, layer_id, keys) {
    global q, w, e, r, t, y, u, i, o, p, at, openbracket
    global a, s, d, f, g, h, j, k, l, semicolon, colon, closebracket
    global z, x, c, v, b, n, m, comma, period, slash, backslash

    for i, key in keys {
        if key != "" {
            layout[i].SetLayerKey(mode, layer_id, key)
        }
    }
}

/**
 * 各レイヤー（ナビゲーション、記号、テンキー、選択、Shiftなど）に対する、物理キーから送信キーへの具体的なマッピングを初期設定します。
 */
InitModLayer() {
    start_qpc := HighPrecisionTimer()

    global LAYOUT_30_KEYS
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

    SetLayerKeys(LAYOUT_30_KEYS, mode, L_SELECT, [
        "", "", "", "", "", R_REDO, C_BS, "+{Up}", "+{PgUp}", "+{PgDn}",
        "", "", "", "", "", "+{Home}", "+{Left}", "+{Down}", "+{Right}", "+{Enter}",
        "^z", "^x", "^c", "^v", "^z", "+{End}", C_DEL, "^+{Left}", "^+{Left}", ""])

    semicolon.SetLayerKey(mode, L_SELECT, "+{Enter}")
    at.SetLayerKey(mode, L_SELECT, C_CSHOME)
    openbracket.SetLayerKey(mode, L_SELECT, C_CSEND)
    enter.SetLayerKey(mode, L_SELECT, B_ENTER)
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

    SetLayerKeys(LAYOUT_30_KEYS, mode, L_NAVI_CTRL, [
        "", "", "", "", "", B_UNDO, B_BS, B_UP, B_PGUP, B_PGDN,
        "{Blind}^a", "", "", "", "", B_HOME, B_LEFT, B_DOWN, B_RIGHT, "+{Enter}",
        B_UNDO, B_CUT, B_COPY, B_PASTE, B_UNDO, B_END, B_DEL, B_CLEFT, B_CRIGHT, "^+{sc07D}"])

    at.SetLayerKey(mode, L_NAVI_CTRL, B_CHOME)
    openbracket.SetLayerKey(mode, L_NAVI_CTRL, B_CEND)
    colon.SetLayerKey(mode, L_NAVI_CTRL, "^{Enter}")
    closebracket.SetLayerKey(mode, L_NAVI_CTRL, "^+{sc07D}")
    enter.SetLayerKey(mode, L_NAVI_CTRL, "{Blind}^{Enter}")
    space.SetLayerKey(mode, L_NAVI_CTRL, "{Blind}{Enter}")

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

    SetLayerKeys(LAYOUT_30_KEYS, mode, L_SYMBOL_NUM, [
        "?", "{Blind}/", B_NMUL, B_NADD, ":=", C_YEN, C_N7, C_N8, C_N9, "+^p",
        "(", ")", "_", "{Blind}-", "=", "=", C_N0, C_N1, C_N2, C_N3,
        "+[", "+]", "[", "]", C_BACKSLASH, "+3", C_N4, C_N5, C_N6, ""])

    space.SetLayerKey(mode, L_SYMBOL_NUM, B_BS)

    global LAYOUT_KEYS
    copyLayer(LAYOUT_KEYS, L_SYMBOL_NUM, L_SYMBOL1)

    ; L_NUMPAD
    k7.SetLayerKey(mode, L_NUMPAD, C_N7)
    k8.SetLayerKey(mode, L_NUMPAD, C_N8)
    k9.SetLayerKey(mode, L_NUMPAD, C_N9)
    k0.SetLayerKey(mode, L_NUMPAD, B_NMUL)
    minus.SetLayerKey(mode, L_NUMPAD, B_NSUB)
    hat.SetLayerKey(mode, L_NUMPAD, C_HAT)
    yen.SetLayerKey(mode, L_NUMPAD, "\")

    SetLayerKeys(LAYOUT_30_KEYS, mode, L_NUMPAD, [
        "", "", "", "", "", C_BS, C_N4, C_N5, C_N6, B_NADD,
        "(", ")", "", "-", "=", "=", C_N1, C_N2, C_N3, "",
        "", "", "", "", "", C_DEL, C_N0, "", "", ""])

    at.SetLayerKey(mode, L_NUMPAD, B_UP)
    semicolon.SetLayerKey(mode, L_NUMPAD, B_LEFT)
    colon.SetLayerKey(mode, L_NUMPAD, B_DOWN)
    closebracket.SetLayerKey(mode, L_NUMPAD, B_RIGHT)

    ; L_SYMBOL2
    SetLayerKeys(LAYOUT_30_KEYS, mode, L_SYMBOL2, [
        "!", "@", "+3", "$", "%", "", "", "", "", "",              ;Exclamation, At, Number Sign, Dollar, Percent
        "&", "+7", "+2", ";", "+@", "=", "", "", "", "",           ;Ampersand, single/double quotation, Semicolon, Grave Accent
        "~", C_HAT, ":", "|", "\", "", "", "<=", ">=", ""])        ;Tilde, Circumflex, Colon, Vertical Line, Backslash

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
