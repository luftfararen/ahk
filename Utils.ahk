#Requires AutoHotkey v2.0

; ============================================================================
; 修飾キー・記号・定数
; ============================================================================
; --- 変数命名規則 ---
; R_... : ホットキー定義用の生文字列 (例: "sc07B")
; C_... : Send互換の文字列 (例: "{sc07B}")
; B_... : Blindモード用のSend文字列 (例: "{Blind}{sc07B}")

; --- 無変換キー ---
R_NOCONV := "sc07B"
C_NOCONV := "{sc07B}"
B_NOCONV := "{Blind}{sc07B}"

; --- 変換キー ---
R_CONV := "sc079"
C_CONV := "{sc079}"
B_CONV := "{Blind}{sc079}"

; --- 円キー (¥) ---
;R_YEN := "sc07D"
C_YEN := "{sc07D}"
B_YEN := "{Blind}{sc07D}"

; --- バックスラッシュキー (\) ---
;R_BACKSLASH := "sc073"
C_BACKSLASH := "{sc073}"

; --- ハット/キャレットキー (^) ---
;R_HAT := "sc00D"
C_HAT := "{sc00D}"

; --- セミコロン (;) ---
;R_SEMICOLON := "sc027"
C_SEMICOLON := "{sc027}"
B_SEMICOLON := "{Blind}{sc027}"
C_PLUS := "+{sc027}"

; --- コロン (:) ---
;R_COLON := "sc028"
C_COLON := "{sc028}"
B_COLON := "{Blind}{sc028}"
C_ASTERISK := "+{sc028}"

; --- カンマ (,) ---
;R_COMMA := "sc033"
C_COMMA := "{sc033}"

; --- 英数 (CapsLock) ---
R_EISU := "sc03A"
C_EISU := "{sc03A}"

; --- ひらがな/カタカナ ---
R_HIRAGANA := "sc070"
C_HIRAGANA := "{sc070}"

; --- 全角/半角 (IME) ---
R_ZENKAKU := "sc029"
C_ZENKAKU := "{sc029}"
B_ZENKAKU := "{Blind}{sc029}"

; --- スラッシュ (/) ---
;R_SLASH := "sc035"
C_SLASH := "{sc035}"
B_SLASH := "{Blind}{sc035}"

; --- Enter ---
R_ENTER := "ENTER"
C_ENTER := "{Enter}"
B_ENTER := "{Blind}{Enter}"
;R_ADAPTIVE_ENTER := "AEnter"

; --- テンキー定数 ---
C_N0 := "{Numpad0}"
C_N1 := "{Numpad1}"
C_N2 := "{Numpad2}"
C_N3 := "{Numpad3}"
C_N4 := "{Numpad4}"
C_N5 := "{Numpad5}"
C_N6 := "{Numpad6}"
C_N7 := "{Numpad7}"
C_N8 := "{Numpad8}"
C_N9 := "{Numpad9}"
C_NDOT := "{NumpadDot}"

; --- テンキー演算子 (Blindモードのみ) ---
B_NADD := "{Blind}{NumpadAdd}"
B_NMUL := "{Blind}{NumpadMult}"
B_NSUB := "{Blind}{NumpadSub}"
B_NDIV := "{Blind}{NumpadDiv}"

; --- 機能キー ---
C_DEL := "{Delete}"
B_DEL := "{Blind}{Delete}"

C_BS := "{Backspace}"
B_BS := "{Blind}{Backspace}"

C_ESC := "{Esc}"
B_ESC := "{Blind}{Esc}"

R_TAB := "Tab"
C_TAB := "{Tab}"
B_TAB := "{Blind}{Tab}"

R_SPACE := "Space"
C_SPACE := "{Space}"
B_SPACE := "{Blind}{Space}"

; --- 編集/ナビゲーション ショートカット ---
R_REDO := "^y"
B_UNDO := "{Blind}^{z}"
B_CUT := "{Blind}^{x}"
B_COPY := "{Blind}^{c}"
B_PASTE := "{Blind}^{v}"

; --- ナビゲーション ---
B_HOME := "{Blind}{Home}"
B_END := "{Blind}{End}"
B_PGUP := "{Blind}{PgUp}"
B_PGDN := "{Blind}{PgDn}"

B_CHOME := "{Blind}^{Home}"
B_CEND := "{Blind}^{End}"
C_CSHOME := "^+{Home}"
C_CSEND := "^+{End}"
B_CPGUP := "{Blind}^{PgUp}"
B_CPGDN := "{Blind}^{PgDn}"

C_LEFT := "{Left}"
B_LEFT := "{Blind}{Left}"
C_RIGHT := "{Right}"
B_RIGHT := "{Blind}{Right}"
C_UP := "{Up}"
B_UP := "{Blind}{Up}"
C_DOWN := "{Down}"
B_DOWN := "{Blind}{Down}"

B_CLEFT := "{Blind}^{Left}"
B_CRIGHT := "{Blind}^{Right}"
C_CSLEFT := "^+{Left}"
C_CSRIGHT := "^+{Right}"

; --- ファンクションキー (Blindモードのみ) ---
B_F1 := "{Blind}{F1}"
B_F2 := "{Blind}{F2}"
B_F3 := "{Blind}{F3}"
B_F4 := "{Blind}{F4}"
B_F5 := "{Blind}{F5}"
B_F6 := "{Blind}{F6}"
B_F7 := "{Blind}{F7}"
B_F8 := "{Blind}{F8}"
B_F9 := "{Blind}{F9}"
B_F10 := "{Blind}{F10}"
B_F11 := "{Blind}{F11}"
B_F12 := "{Blind}{F12}"

; ============================================================================
; GLOBAL FUNCTIONS
; ============================================================================

/**
 * 指定されたセクションとキーから設定を読み込みます。
 * @param {String} section - セクション名
 * @param {String} key - キー名
 * @param {String} defaultValue - デフォルト値
 * @returns {String} 読み込んだ設定値
 */
ReadConfig(section, key, defaultValue) {
    static ConfigPath := A_ScriptDir . "\config.ini"
    val := IniRead(ConfigPath, section, key, defaultValue)
    val := RegExReplace(val, "[\t ]+;.*$") ; インラインコメントを除去
    return StripQuotes(Trim(val))
}

/**
 * 指定されたセクションとキーから設定を整数値として読み込みます。
 * 読み込みに失敗した場合や数値に変換できない場合は defaultValue を返します。
 * @param {String} section - セクション名
 * @param {String} key - キー名
 * @param {Integer} defaultValue - デフォルト値
 * @returns {Integer} 読み込んだ整数設定値
 */
ReadConfigInt(section, key, defaultValue) {
    try {
        return Integer(ReadConfig(section, key, String(defaultValue)))
    } catch {
        return defaultValue
    }
}

/**
 * 文字列の先頭と末尾がダブルクォーテーションで囲まれている場合、それらを除去した文字列を返します。
 * @param {String} val - 対象文字列
 * @returns {String} クォーテーション除去後の文字列
 */
StripQuotes(val) {
    if (SubStr(val, 1, 1) == '"' && SubStr(val, -1) == '"' && StrLen(val) >= 2) {
        return SubStr(val, 2, StrLen(val) - 2)
    }
    return val
}

/**
 * INIファイルから指定されたセクションのすべての行をテキストとして取得します。
 * Windows APIのエンコーディング制限を回避するため、UTF-8で直接ファイルを解析します。
 */
GetIniSection(filename, sectionName) {
    try {
        content := FileRead(filename, "UTF-8")
    } catch {
        return ""
    }

    in_section := false
    section_text := ""

    for line in StrSplit(content, "`n", "`r") {
        line := Trim(line)
        if line == ""
            continue

        ; セクションヘッダーの判定 (例: [Minato])
        if (SubStr(line, 1, 1) == "[" && SubStr(line, -1) == "]") {
            current_sec := SubStr(line, 2, StrLen(line) - 2)
            if (current_sec = sectionName) {
                in_section := true
            } else {
                in_section := false
            }
            continue
        }

        if in_section {
            section_text .= line . "`n"
        }
    }
    return section_text
}

/**
 * 指定されたセクションとキーに設定を書き込みます。
 * @param {String} value - 書き込む値
 * @param {String} section - セクション名
 * @param {String} key - キー名
 */
WriteConfig(value, section, key) {
    static ConfigPath := A_ScriptDir . "\config.ini"
    return IniWrite(value, ConfigPath, section, key)
}

/**
 * 高精度タイマーの周波数を取得します。
 * @returns {Int64} 周波数
 */
QueryFrequency() {
    freq := 0
    DllCall("QueryPerformanceFrequency", "Int64*", &freq, "Int")
    return freq
    ;return 1000
}

/**
 * 高精度タイマーの現在のカウント値を取得します。
 * @returns {Int64} カウント値
 */
QueryCounter() {
    tick := 0
    DllCall("QueryPerformanceCounter", "Int64*", &tick, "Int")
    return tick
    ;return A_TickCount
}

g_freq := QueryFrequency()

/*
* 高分解能タイマー(単位:millisecond)
*/
QPC() {
    ; static freq := 0
    ; if (!freq)
    ;     DllCall("QueryPerformanceFrequency", "Int64*", &freq, "Int")
    ; counter := 0
    ; DllCall("QueryPerformanceCounter", "Int64*", &counter)
    ; return (counter / freq) * 1000 ; ミリ秒単位に変換して返す
    global g_freq
    counter := 0
    DllCall("QueryPerformanceCounter", "Int64*", &counter)
    return (counter / g_freq) * 1000 ; ミリ秒単位に変換して返す
}

/**
 * 高精度な一時待機処理を行います（MsgWaitForMultipleObjectsの呼び出し）。
 * @param {Integer} t - 待機時間 (ms)
 */
Wait(t) {
    ; timeBeginPeriod(1) のおかげで、引数 t 通り（1ms単位）の精度で待てる
    DllCall("MsgWaitForMultipleObjects", "UInt", 0, "Ptr", 0, "Int", 0, "UInt", t, "UInt", 0x04FF, "UInt")
}

/**
 * QPC高精度タイマーを利用した、ミリ秒未満の精度を持つビジーループと待機を組み合わせた高精度Sleep関数。
 * @param {Integer} t - 待機時間 (ms)
 */
SleepQPC(t) {
    start_qpc := QPC()

    ; 【フェーズ1：大きく休む（2ms以上の隙間があるとき）】
    ; ターゲットの2ms手前までは、正確になった Wait() でCPUを完全に寝かせる
    while ((rem := t - (QPC() - start_qpc)) > 2) {
        ; 残り時間に応じた可変ウェイト（最大でも5msに抑えてキー入力を逃さない）
        wait_time := (rem > 5) ? 5 : 1
        Wait(wait_time)
        Sleep(-1)
    }

    ; 【フェーズ2：ミリ秒未満の極小の隙間を埋める】
    ; 残り2ms未満になったら、Waitを使うと行き過ぎる可能性があるので、
    ; Sleep(0) または SwitchToThread で他のプロセスに優しく譲りつつ、QPCで超高精度に時間を合わせる
    while (QPC() - start_qpc < t) {
        ; Sleep(0) または DllCall("SwitchToThread") は、
        ; タイマー解像度に関係なく、1タイムスライス（数マイクロ秒）だけタスクを譲る
        DllCall("SwitchToThread")
        Sleep(-1)
    }
}

/**
 * アクティブなウィンドウまたはフォーカスされているコントロールのハンドル (HWND) を取得する
 * 正確な IME 状態の検出に必要
 * @returns {Ptr} ウィンドウハンドル (HWND)
 */
GetFocusedControlHandle() {
    static ptr_size := A_PtrSize
    static cb_size := 4 + 4 + (ptr_size * 6) + 16
    st_gti := Buffer(cb_size, 0)

    hwnd := WinExist("A")
    if !hwnd
        return 0

    NumPut("UInt", cb_size, st_gti, 0)

    ; 1. アクティブウィンドウのスレッドIDを指定して GUI 情報を取得
    tid := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0, "UInt")
    if (tid && DllCall("GetGUIThreadInfo", "UInt", tid, "Ptr", st_gti)) {
        hwndFocus := NumGet(st_gti, 8 + ptr_size, "Ptr")
        if hwndFocus
            return hwndFocus
    }

    ; 2. フォアグラウンドスレッド全体 (idThread = 0) で再取得
    if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", st_gti) {
        hwndFocus := NumGet(st_gti, 8 + ptr_size, "Ptr")
        if hwndFocus
            return hwndFocus
    }

    ; 3. AHK 組み込み機能によるコントロール取得のフォールバック
    try {
        if (ctrl := ControlGetFocus("A")) {
            if (ctrlHwnd := ControlGetHwnd(ctrl, "A"))
                return ctrlHwnd
        }
    }

    return hwnd
}

/**
 * 特定のウィンドウの IME (Input Method Editor) 状態を設定する
 * @param {Ptr} hwnd - 対象ウィンドウハンドル
 * @param {Integer} state - 設定したい状態 (1: ON, 0: OFF)
 * @returns {LParam} DllCall の結果
 */
SetImeStatus(hwnd, state) {
    default_ime_wnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    ; 0x0002: SMTO_ABORTIFHUNG, timeout 50ms
    return DllCall("user32\SendMessageTimeout"
        , "Ptr", default_ime_wnd
        , "UInt", 0x0283  ; WM_IME_CONTROL
        , "Ptr", 0x006    ; IMC_SETOPENSTATUS (開状態を設定)
        , "Ptr", state
        , "UInt", 0x0002  ; SMTO_ABORTIFHUNG
        , "UInt", 50      ; 50ms timeout
        , "Ptr*", &result
        , "Ptr")
}

/* ============================================================================
    STRING CONVERSION & HELPERS
============================================================================ */

/**
 * マップのキーと値を入れ替えた新しいマップを返します。
 */
FlipMap(originalMap) {
    flipped := Map()
    for key, value in originalMap {
        flipped[value] := key
    }
    return flipped
}

/**
 * 1つの波括弧で囲まれた文字列か判定する (例: "{sc027}", "{Enter}")
 */
IsSingleBraceText(text) => RegExMatch(text, "^\{[^{}]+\}$")

/**
 * 文字列に波括弧を追加 / 除去
 */
AddBraces(key) => IsSingleBraceText(key) ? key : "{" . key . "}"
RemoveBraces(key) => IsSingleBraceText(key) ? SubStr(key, 2, -1) : key

/**
 * パイプ区切りのアクション文字列を分解するヘルパー
 */
ParseSplitActions(action, action2 := "") {
    if (action2 == "" && action != "|" && InStr(action, "|")) {
        parts := StrSplit(action, "|")
        if parts.Length >= 2
            return [parts[1], parts[2]]
    }
    return [action, action2]
}

/**
 * 配列要素を結合する補助関数
 */
StrJoin(sep, arr) {
    res := ""
    for item in arr
        res .= (res == "" ? "" : sep) . item
    return res
}

/**
 * 指定されたキー文字列に修飾記号 (+, ^, !, #, {Blind}) が含まれているか確認。
 */
HasModifierSymbols(text) {
    ; 単体の "{+}" や "{^}" などの場合は修飾記号ありとみなさない
    if IsSingleBraceText(text) {
        inner := SubStr(text, 2, StrLen(text) - 2)
        if (inner == "+" || inner == "^" || inner == "!" || inner == "#") {
            return false
        }
    }
    list := ["{Blind}", "+", "#", "^", "!"]
    for item in list {
        if InStr(text, item, false) > 0 {
            return true
        }
    }
    return false
}

/**
 * スキャンコードと文字、およびキーの日本語文字/文字名の相互変換を行うためのマッピング情報を初期化します。
 */
InitMaps() {
    global sc_from_char_map
    global char_from_sc_map
    global char_from_str_map
    global str_from_char_map

    ; 記号 -> スキャンコード形式 scXXX (波括弧なし)
    sc_from_char_map := Map(
        ";", "sc027", ":", "sc028", ",", "sc033", ".", "sc034", "/", "sc035", "¥", "sc07D",
        "\", "sc073", "^", "sc00D", "@", "sc010", "[", "sc01A", "]", "sc01B"
    )
    sc_from_char_map.Default := ""

    ; スキャンコード形式(波括弧なし) -> 記号文字
    char_from_sc_map := FlipMap(sc_from_char_map)
    char_from_sc_map.Default := ""

    ; 文字列名 -> 文字
    char_from_str_map := Map(
        "semicolon", ";", "colon", ":", "comma", ",", "period", ".", "slash", "/", "yen", "¥",
        "backslash", "\", "hat", "^", "minus", "-", "openbracket", "[", "closebracket", "]",
        "one", "1", "two", "2", "three", "3", "four", "4", "five", "5", "six", "6", "seven", "7", "eight", "8", "nine",
        "9",
        "zero", "0",
        "space", "space", "tab", "tab", "enter", "enter", "esc", "esc"
    )
    char_from_str_map.Default := ""

    ; 文字 -> 文字列名
    str_from_char_map := FlipMap(char_from_str_map)
    str_from_char_map.Default := ""
}

; --- 変換基本関数 ---

/**
 * 文字（例: ";"）をスキャンコード形式（例: "{sc027}"）に変換します。英数字はそのまま返します。
 * @param {String} c - 変換対象の文字
 * @returns {String} スキャンコード形式の文字列
 */
ScFromChar(c) {
    sc := sc_from_char_map[c]
    if (sc == "") {
        return c
    }
    return AddBraces(sc)
}

/**
 * スキャンコード形式（例: "{sc027}"）を文字（例: ";"）に変換します。
 * @param {String} sc - 変換対象のスキャンコード
 * @returns {String} 変換後の文字
 */
CharFromSc(sc) {
    sc_raw := RemoveBraces(sc)
    c := char_from_sc_map[sc_raw]
    return (c == "") ? sc : c
}

/**
 * キーの名前（例: "semicolon"）を対応する文字（例: ";"）に変換します。
 * @param {String} str - キーの名前
 * @returns {String} 対応する文字
 */
CharFromStr(str) {
    c := char_from_str_map[str]
    return (c == "") ? str : c
}

/**
 * 文字（例: ";"）を対応するキーの名前（例: "semicolon"）に変換します。
 * @param {String} c - 変換対象の文字
 * @returns {String} キーの名前
 */
StrFromChar(c) {
    str := str_from_char_map[c]
    return (str == "") ? c : str
}

; --- 統合ロジック関数 (INI入出力用) ---
/**
 * INIファイルのエントリー名を作る: スキャンコードや文字を小文字の名前形式に変換
 * 例: "{sc027}" -> "semicolon", ";" -> "semicolon", "1" -> "one", "a" -> "a", "{Enter}" -> "enter"
 */
EntryName(sc) {
    sc_raw := RemoveBraces(sc)
    c := CharFromSc(StrLower(sc_raw))
    name := StrFromChar(RemoveBraces(c))
    return StrLower(RemoveBraces(name))
}

/**
 * 表示用の文字・文字列に変換
 * 例: "{sc027}" -> ";", ";" -> ";", "one" -> "1", "a" -> "a", "{Enter}" -> "Enter"
 */
DispStr(str, remove_braces := true) {
    c := CharFromStr(str) ; "semicolon" -> ";"
    if (c == str) {         ; 変換されなかった場合（名前ではない場合）
        c := CharFromSc(str) ; "{sc027}" -> ";"
    }
    return remove_braces ? RemoveBraces(c) : c ; "{Esc}" -> "Esc" などの最終調整
}

/**
 * 【キー表記の解決】
 * 人間用の名前や文字を、AHKが送信・管理で利用する標準的な形式に整える。
 * (名前があればスキャンコードへ、そうでなければ元の文字や表記を維持)
 * 例: "semicolon" -> "{sc027}", "one" -> "1", "{Enter}" -> "{Enter}"
 */
ResolveKeyText(str) {
    str := StripQuotes(Trim(str))
    if (str != "|" && InStr(str, "|")) {
        resolved := []
        for part in StrSplit(str, "|")
            resolved.Push(ResolveKeyText_Single(Trim(part)))
        return StrJoin("|", resolved)
    }
    return ResolveKeyText_Single(str)
}

/**
 * 単一のキー記述文字列（例: "semicolon" や "a"）をスキャンコード形式に変換します。
 * @param {String} str - キー記述文字列
 * @returns {String} 解決されたスキャンコード、または元の文字列
 */
ResolveKeyText_Single(str) {
    ; 名前（semicolon等）から文字（;等）を取得
    c := CharFromStr(str)
    ; 文字からスキャンコードを取得（スキャンコード化できない文字はそのまま返る想定）
    return ScFromChar(c)
}

/**
 * 文字列名から対応する LKey/RKey オブジェクトを取得します。
 */
GetKeyObjByName(name) {
    static key_map := Map()
    if key_map.Count == 0 {
        global QWERTY_CHARS, LAYOUT_KEYS, LAYOUT_SPECIAL_NAMES, LAYOUT_SPECIAL_KEYS
        for i, c in QWERTY_CHARS {
            key_map[EntryName(c)] := LAYOUT_KEYS[i]
        }
        for i, c in LAYOUT_SPECIAL_NAMES {
            key_map[c] := LAYOUT_SPECIAL_KEYS[i]
        }
    }
    ; "f", "space", ";" 等を内部のエントリー名 ("semicolon"等) に正規化して取得
    name := EntryName(name)
    return key_map.Get(name, false)
}

/**
 * 論理キー名（レイアウト適用後の文字・記号）から物理キーオブジェクトを取得します。
 * 一致するマッピングがない場合は、QWERTY物理キー名としてフォールバックします。
 */
GetKeyObjByLogicalName(name, is_ime := false) {
    global LAYOUT_KEYS
    norm_name := EntryName(name)
    for keyObj in LAYOUT_KEYS {
        current_text := is_ime ? keyObj.ime_key_text : keyObj.key_text
        if (EntryName(current_text) == norm_name) {
            return keyObj
        }
    }
    return GetKeyObjByName(name)
}

/**
 * LAYOUT_KEYS を走査し、登録された文字（IME-ON / IME-OFF の両方）から
 * LKey オブジェクトへのマッピング（Map）を生成して返します。
 * Mapのキーには、:o,.などの記号もそのまま使用できます。
 */
CreateKeyMap() {
    global LAYOUT_KEYS
    key_map := Map()
    for keyObj in LAYOUT_KEYS {
        ;IME - ON 時のキー登録名をマップに追加
        if keyObj.ime_key_text != "" && keyObj.ime_key_text != "{none}" {
            clean_name := DispStr(keyObj.ime_key_text)
            if clean_name != "" {
                key_map[clean_name] := keyObj
            }
        }
        ;IME - OFF 時のキー登録名もマップに追加（存在しない場合のみ）
        if keyObj.key_text != "" && keyObj.key_text != "{none}" {
            clean_name := DispStr(keyObj.key_text)
            if clean_name != "" && !key_map.Has(clean_name) {
                key_map[clean_name] := keyObj
            }
        }
    }
    return key_map
}

/**
 * INIや定義から読み込んだ値を、AHKのSendで安全に動作する形式にパースします。
 * 1文字の危険な記号のみを波括弧で安全に隔離し、2文字以上のマクロ等はそのまま通します。
 * @param {String} raw_str - 変換対象の文字列 (例: "*", "+", "ctrl")
 * @returns {String} パース済みの文字列 (例: "{*}", "{+}", "ctrl")
 */
ParseIniValue(raw_str) {
    if (raw_str == " ") {
        return "{Space}"
    }
    if (StrLen(raw_str) == 1) {
        if InStr("+^!#{}*?<>=``;:@[]¥\", raw_str) {
            return "{" . raw_str . "}"
        }
    }
    return raw_str
}

/**
 * 【送信コマンドの構築】
 * 解決済みのキー表記に、修飾記号などを付与して「Send関数用」の最終文字列を作る。
 */
BuildSendText(text, prefix := "") {
    if text == ""
        return ""
    if text == "{none}"
        return "{none}"

    ; {Blind} や 意図的な修飾記号付きマクロの場合はそのまま返す
    if InStr(text, "{Blind}", false) || HasModifierSymbols(text)
        return text

    ; 1文字の素の記号のみを安全にエスケープ（ただし単一波括弧の場合はスキップ）
    if !IsSingleBraceText(text) {
        text := ParseIniValue(text)
    }

    if (StrLen(text) == 1 || IsSingleBraceText(text)) {
        return prefix . text
    }
    return text
}

/**
 * レイアウト文字列のパース補助クラス。
 */
class LayoutString {
    arr := []
    /**
     * コンストラクタ
     * @param {String} layout_str - パースするレイアウト文字列
     */
    __New(layout_str) {
        this.layout_str := layout_str
        if this.layout_str = ""
            return
        if InStr(this.layout_str, " ") {
            this.arr := []
            for item in StrSplit(Trim(this.layout_str), " ") {
                if item != ""
                    this.arr.Push(item)
            }
        } else {
            this.arr := StrSplit(this.layout_str)
        }
    }
    /**
     * 指定されたインデックスの要素を取得します。
     * @param {Integer} index - インデックス（1-indexed）
     * @returns {String} 要素文字列
     */
    GetElement(index) => (index <= this.arr.Length) ? this.arr[index] : ""
}

/**
 * フォント管理クラス
 * 起動時に一度だけチェックを行い、結果を保持する
 */
class FontManager {
    static Monospace := this._DetermineMonospace()

    /**
     * システムにインストールされている等幅フォントから最適な候補を決定します。
     * @returns {String} フォント名
     */
    static _DetermineMonospace() {
        ; 優先順位リスト
        candidates := ["PlemolJP", "PlemolJP Console", "MS Gothic", "游ゴシック", "游明朝", "Consolas"]

        for name in candidates {
            if this.IsInstalled(name)
                return name
        }
        return "Consolas" ; 最終バックアップ
    }

    /**
     * システムにフォントが存在するか厳密に判定する
     */
    static IsInstalled(name) {
        ; 1. フォントを作成してデバイスコンテキストに選択
        hFont := DllCall("CreateFont", "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 400
            , "Int", 0, "Int", 0, "Int", 0, "Int", 1, "Int", 0, "Int", 0, "Int", 0, "Int", 0
            , "Str", name, "Ptr")

        if !hFont
            return false

        hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
        oldObj := DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont, "Ptr")

        ; 2. Windowsが実際に割り当てたフォント名を取得
        nameBuf := Buffer(512)
        DllCall("GetTextFace", "Ptr", hdc, "Int", 256, "Ptr", nameBuf, "Int")
        actualName := StrGet(nameBuf)

        ; 3. 後処理
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldObj, "Ptr")
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc, "Int")
        DllCall("DeleteObject", "Ptr", hFont, "Int")

        ; 指定した名前と実際に当たった名前が一致するか（代替フォントでないか）
        return actualName = name
    }
}

/**
 * 画面上に OSD (On-Screen Display) メッセージを表示する
 * @param {String} text - 表示するテキスト
 * @param {Integer} [duration=3000] - 表示時間 (ms)
 * @param {Boolean} [key_close=False] - True の場合、全キーが離されるまで、またはタイムアウトまで表示を維持する
 */
ShowOSD(text, duration := 3000, key_close := False) {
    ; \n を `n に置換して改行を有効にする
    ;text := StrReplace(text, "\n", "`n")

    my_gui := Gui("+AlwaysOnTop +ToolWindow -Caption +Disabled")
    my_gui.BackColor := "333333"
    my_gui.SetFont("s16 cWhite w700", FontManager.Monospace)

    ; テキスト周囲の余白
    my_gui.MarginX := 20
    my_gui.MarginY := 15

    ; 改行を含むテキストを中央寄せで表示
    my_gui.Add("Text", "Center", text)
    my_gui.Show("NoActivate xCenter y900") ; 画面下部中央に表示

    if key_close {
        ; 全てのキーが離された状態（物理的に何も押されていない状態）になったら閉じる
        fn_close(*) {
            SetTimer(CheckNoKeys, 0)
            try my_gui.Destroy()
        }

        /**
         * すべての物理キーが離されている状態であるかチェックし、すべて離されていればOSDを閉じます。
         */
        CheckNoKeys() {
            loop 255 {
                if GetKeyState(Format("vk{:02X}", A_Index), "P")
                    return ; 何か押されているので待機継続
            }
            fn_close()
        }

        SetTimer(CheckNoKeys, 50)
        SetTimer(fn_close, -duration) ; タイムアウトでも閉じる
    } else {
        SetTimer(() => (my_gui.Destroy()), -duration)
    }
}

/**
 * 日本語入力（IME）の状態を表示するためのインジケータGUI（ドットキャレット）を初期化します。
 */
InitGUI() {
    global color_japanese
    global dot_size
    global m_gui

    color_japanese := "Red"
    dot_size := 8
    ; ------------

    ; キャレット表示用のGUI作成
    ; 描画用のウィンドウ（GUI）作成
    m_gui := Gui("+AlwaysOnTop -Caption +ToolWindow +LastFound -DPIScale")
    m_gui.BackColor := color_japanese
    WinSetRegion("0-0 w" dot_size " h" dot_size " Ellipse", m_gui)
}

/*============================================================================
 [Class] MouseSpeed
 システムのマウス速度を制御するためのスタティッククラス
============================================================================*/
class MouseSpeed {
    static SPI_GETMOUSESPEED := 0x70 ; API 定数
    static SPI_SETMOUSESPEED := 0x71 ; API 定数
    static def_mouse_speed := 10

    /**
     * 現在のシステムマウス速度を取得する (値: 1-20)
     * @returns {Integer} 現在の速度
     */
    static GetSpeed() {
        val := 0
        DllCall("SystemParametersInfo", "UInt", MouseSpeed.SPI_GETMOUSESPEED, "UInt", 0, "Ptr*", &val, "UInt", 0, "Int"
        )
        return val
    }

    /**
     * システムのマウス速度を設定する (値: 1-20)
     * @param {Integer} val - 設定する速度
     * @returns {Integer} 設定された速度
     */
    static SetSpeed(val) {
        ; 値を1から20の状態に収める
        if val < 1 {
            val := 1
        } else if val > 20 {
            val := 20
        }
        DllCall("SystemParametersInfo", "UInt", MouseSpeed.SPI_SETMOUSESPEED, "UInt", 0, "Ptr", val, "UInt", 0, "Int")
        ToolTip("MouseSpeed: " . val)
        SetTimer(ToolTip, -3000) ; ツールチップを3秒間表示する
        return val
    }

    /**
     * マウス速度を 1 上げる
     */
    static IncSpeed() {
        v := MouseSpeed.GetSpeed()
        if v = 0 { ; 速度の取得に失敗
            ToolTip("MouseSpeed: " . v)
            return
        }
        MouseSpeed.SetSpeed(v + 1)
    }
    /**
     * マウス速度を 1 下げる
     */
    static DecSpeed() {
        v := MouseSpeed.GetSpeed()
        if v = 0 { ; 速度の取得に失敗
            return
        }
        MouseSpeed.SetSpeed(v - 1)
    }
}    ;class MouseSpeed

/**
 * INIファイルからキー配列設定を動的に読み込み、マップにマッピングするためのヘルパークラスです。
 */
class IniMap {
    /**
     * コンストラクタ
     * @param {Map} map - 保存先マップ
     * @param {String} section - INIのセクション名
     * @param {String} [prefix=""] - キー名のプレフィックス
     * @param {String} [ini_path=""] - INIファイルのパス
     */
    __New(map, section, prefix := "", ini_path := "") {
        this.map := map
        this.inipath := ini_path == "" ? A_ScriptDir . "\config.ini" : ini_path
        this.section := section
        this.prefix := prefix
    }

    /**
     * 指定された文字に対する設定をINIから読み込んでマップにセットします。
     * @param {String} c - 処理対象の文字
     */
    Set(c) {
        key := EntryName(c)
        if key == "" {
            return
        }
        val := IniRead(this.inipath, this.section, this.prefix . key, "")
        val := ResolveKeyText(val)
        if val != "" {
            this.map.Set(key, val)
        }
    }
}

/**
 * INIファイルから読み込んだセクション定義から、指定したプレフィックスを持つレイヤーキー設定をパースし、レイアウトマップに格納します。
 * @param {Map} layout_map - 取得したキー設定を格納するマップ
 * @param {String} section_text - INIファイルから読み出したセクション全体のテキスト
 * @param {String} prefix - 抽出対象 of プレフィックス（例: "m_"）
 * @param {String} ini_path - INIファイルの絶対パス
 */
ReadLayerKey(layout_map, section_text, prefix, ini_path) {
    if section_text != "" {
        prefix_len := StrLen(prefix)
        for line in StrSplit(section_text, "`n", "`r") {
            line := Trim(line)
            if line == ""
                continue
            pos := InStr(line, "=")
            if pos > 0 {
                key_name := Trim(SubStr(line, 1, pos - 1))
                if SubStr(key_name, 1, prefix_len) == prefix {
                    map_key := SubStr(key_name, prefix_len + 1)
                    val := Trim(SubStr(line, pos + 1))
                    val := ResolveKeyText(val)
                    if val != "" {
                        layout_map.Set(map_key, val)
                    }
                }
            }
        }
    }
}

/**
 * タイピングログ（トリグラム頻度、打鍵間隔など）を記録・集計・保存するクラスです。
 */
class TypeAnalyzer {

    /**
     * 各キー配列ログアイテムの統計情報を保持する構造体クラス。
     */
    class TAItem {
        count := 0
        count_d := 0
        duration12 := 0
        duration13 := 0
    }

    static IDLE_TIMEOUT := 3000     ; 3秒以上の打鍵間隔で履歴リセット
    static AUTOSAVE_INTERVAL := 300000 ; 5分ごとに自動保存
    static MAX_DURATION := 1000      ; 1秒以上の打鍵間隔は無効値として扱う

    static log_file := A_ScriptDir . "\log.txt"
    ;static config_file := A_ScriptDir . "\config.ini"
    static is_logging_enabled := false
    static is_showing_ime_indicator := true
    static stats := Map()     ; 段階3: フル辞書 (長期保存用)
    static stats_mid := Map() ; 段階2: 中間辞書 (集計用)
    static stats_short := []  ; 段階1: リスト (事前確保バッファ)
    static stats_short_idx := 0 ; 現在の書き込み位置
    static stats_short_max := 1000 ; バッファの最大容量
    static current_layout := "Qwerty"
    static hist_1 := "", hist_2 := "", hist_3 := ""
    static tick_1 := 0, tick_2 := 0, tick_3 := 0
    static last_key_time := 0
    static max_log := 5000
    static last_save_time := A_TickCount
    static total_log_time := 0
    static total_log_time2 := 0
    static freq := 0

    ; __init() {
    ;     DllCall("QueryPerformanceFrequency", "Int64*", &freq := 0)
    ; }

    /**
     * 打鍵履歴をリセットする
     */
    static ResetHistory() {
        this.hist_1 := "", this.hist_2 := "", this.hist_3 := ""
        this.tick_1 := 0, this.tick_2 := 0, this.tick_3 := 0
    }

    /**
     * キーロギングの有効/無効を切り替えます。
     */
    static ToggleLogging() {
        this.is_logging_enabled := !this.is_logging_enabled
        this.SaveConfig()
        ShowOSD("TypeAnalyzer: " . (this.is_logging_enabled ? "ON" : "OFF"))
    }

    /**
     * IMEインジケータの表示/非表示を切り替える
     */
    static ToggleImeIndicator() {
        this.is_showing_ime_indicator := !this.is_showing_ime_indicator
        this.SaveConfig()
        ShowOSD("IME Indicator: " . (this.is_showing_ime_indicator ? "ON" : "OFF"))
    }

    /**
     * 設定ファイルから設定を読み込む
     */
    static LoadConfig() {
        this.freq := QueryFrequency()
        try {
            val := ReadConfig("Settings", "LogEnabled", "0")
            this.is_logging_enabled := (val == "1")
        } catch {
            this.is_logging_enabled := false
        }
        try {
            val := ReadConfig("Settings", "ImeIndicatorEnabled", "1")
            this.is_showing_ime_indicator := (val == "1")
        } catch {
            this.is_showing_ime_indicator := true
        }
        try {
            this.max_log := Integer(ReadConfig("Settings", "MaxLog", "5000"))
        } catch {
            this.max_log := 2000
        }
    }

    /**
     * 設定をファイルに保存する
     */
    static SaveConfig() {
        try {
            WriteConfig(this.is_logging_enabled ? "1" : "0", "Settings", "LogEnabled")
            WriteConfig(this.is_showing_ime_indicator ? "1" : "0", "Settings", "ImeIndicatorEnabled")
            WriteConfig(String(this.max_log), "Settings", "MaxLog")
            WriteConfig(String(LKey.hold_th), "Settings", "HoldTh")
            WriteConfig(String(LKey.pre_stroke_buf), "Settings", "PreStrokeBuf")
            WriteConfig(String(Layers.b_time), "Settings", "b_time")
            WriteConfig(String(Layers.b_time2), "Settings", "b_time2")
        } catch {
        }
    }

    /**
     * ログファイルを読み込む
     */
    static Load() {
        this.LoadConfig()

        ; ログバッファを事前確保し、オブジェクトを再利用可能にする
        this.stats_short := Array()
        this.stats_short.Capacity := this.stats_short_max
        loop this.stats_short_max {
            this.stats_short.Push({ c: "", t: 0 })
        }
        this.stats_short_idx := 0

        ; --- ウォームアップ ---
        ; 初回呼び出し時のオーバーヘッド（DLLロードや静的変数初期化）を排除する
        this.is_logging_enabled := true ; 一時的に有効化
        this.Log("warmup")
        this.total_log_time := 0
        this.stats_short_idx := 0
        this.LoadConfig() ; 本来の設定に戻す

        if !FileExist(this.log_file)
            return

        try {
            content := FileRead(this.log_file)
            current_sec := ""
            for line in StrSplit(content, "`n", "`r") {
                line := Trim(line)
                if line = ""
                    continue
                if SubStr(line, 1, 1) = "[" && SubStr(line, -1) = "]" {
                    current_sec := SubStr(line, 2, StrLen(line) - 2)
                    if !this.stats.Has(current_sec)
                        this.stats[current_sec] := Map()
                } else if current_sec != "" {
                    pos := InStr(line, " : ", false, -1)
                    if pos {
                        seq := SubStr(line, 1, pos - 1)
                        valStr := SubStr(line, pos + 3)
                        vals := StrSplit(valStr, " ")

                        item := TypeAnalyzer.TAItem()
                        item.count := Integer(vals[1])
                        if vals.Length >= 4 {
                            item.count_d := Integer(vals[2])
                            item.duration12 := Integer(vals[3]) * item.count_d
                            item.duration13 := Integer(vals[4]) * item.count_d
                        } else if vals.Length >= 3 {
                            item.count_d := item.count
                            item.duration12 := Integer(vals[2]) * item.count_d
                            item.duration13 := Integer(vals[3]) * item.count_d
                        }
                        this.stats[current_sec][seq] := item
                    }
                }
            }
        } catch {
        }
    }

    /**
     * ログを圧縮する
     */
    static _Compaction() {
        for layout, stats_map in this.stats {
            total := 0
            for seq, item in stats_map
                total += item.count

            ; マップ全体を舐め終わった後に判定する
            if total > this.max_log {
                keysToDel := []
                for seq, item in stats_map {
                    item.count //= 2
                    if item.count == 0 {
                        keysToDel.Push(seq)
                    }
                }
                for seq in keysToDel
                    stats_map.Delete(seq)
            }
        }
    }

    /**
     * レイアウトの名称を設定します。
     * @param {String} section - 設定するレイアウトセクション名
     */
    static SetLayoutName(section) {
        this.current_layout := section
    }

    /**
     * レイアウトを切り替え、それまでのログの統合・圧縮を行います。
     * @param {String} section - 新しいレイアウトセクション名
     */
    static ChangeLayout(section) {
        this._MergeShortTerm()
        this._Consolidate()
        this._Compaction()
        this.SetLayoutName(section)
    }

    /**
     * 短期バッファ（stats_short）のログデータを解析し、中間辞書（stats_mid）に集計・統合します。
     */
    static _MergeShortTerm() {
        if this.stats_short_idx == 0 {
            return
        }
        ; リスト (stats_short) を 中間辞書 (stats_mid) に集計
        layout := this.current_layout
        if !this.stats_mid.Has(layout)
            this.stats_mid[layout] := Map()
        stats_map := this.stats_mid[layout]
        def_save := char_from_sc_map.Default
        loop this.stats_short_idx {
            entry := this.stats_short[A_Index]
            char := entry.c
            tick := entry.t

            ; {Blind} や {sc033} のような括弧付き文字列のパース
            if InStr(char, "{") {
                if SubStr(char, 1, 7) = "{Blind}"
                    char := SubStr(char, 8) ; {Blind} を除去
                char := DispStr(char, false)
                if InStr(char, "{") { ; さらに括弧が含まれるか ({Enter} 等)
                    char := " "
                }
            }
            if char = ""
                continue

            if (tick - this.last_key_time >= this.IDLE_TIMEOUT) {
                this.ResetHistory()
            }
            this.last_key_time := tick

            this.hist_1 := this.hist_2
            this.hist_2 := this.hist_3
            this.hist_3 := char

            this.tick_1 := this.tick_2
            this.tick_2 := this.tick_3
            this.tick_3 := tick

            ; 履歴が3文字に満たない場合はスキップ
            if this.hist_1 == ""
                continue
            if this.hist_1 == " "
                continue
            if this.hist_2 == " "
                continue

            seq := this.hist_1 . " " . this.hist_2 . " " . this.hist_3
            if !stats_map.Has(seq)
                stats_map[seq] := TypeAnalyzer.TAItem()

            item := stats_map[seq]
            item.count += 1
            t := this.tick_3 - this.tick_1
            if t < this.MAX_DURATION {
                item.count_d += 1
                item.duration12 += (this.tick_2 - this.tick_1)
                item.duration13 += t
            }
        }
        char_from_sc_map.Default := def_save

        this.total_log_time2 := Max(this.total_log_time2, this.total_log_time)
        this.total_log_time := 0
        this.stats_short_idx := 0
    }

    /**
     * 中間辞書からフル辞書へデータを統合（Consolidate）する
     */
    static _Consolidate() {
        if this.stats_mid.Count == 0
            return

        for layout, mid_map in this.stats_mid {
            if !this.stats.Has(layout)
                this.stats[layout] := Map()
            full_map := this.stats[layout]

            for seq, mid_item in mid_map {
                if !full_map.Has(seq)
                    full_map[seq] := TypeAnalyzer.TAItem()
                full_item := full_map[seq]

                full_item.count += mid_item.count
                full_item.count_d += mid_item.count_d
                full_item.duration12 += mid_item.duration12
                full_item.duration13 += mid_item.duration13
            }
        }
        this.stats_mid := Map()
    }

    /**
     * 指定されたアイドル時間に基づき、必要に応じてログデータを自動保存します。
     * @param {Integer} time - アイドル時間 (ms)
     */
    static SaveIfIdle(time) {
        Critical()
        if (time < 20000) {
            Critical("Off")
            return
        }
        if this.stats_short_idx == 0 {
            Critical("Off")
            return
        }

        ; 前回saveから指定時間経っていたら保存
        if (A_TickCount - this.last_save_time >= this.AUTOSAVE_INTERVAL && time >= 60000) {
            Critical("Off")
            this.Save()
            return
        }

        this._MergeShortTerm()
        Critical("Off")
    }

    /**
     * 現在の統計情報をファイルに書き込む
     */
    static Save(sync := false) {
        Critical()
        this._MergeShortTerm()
        this._Consolidate()
        Critical("Off")

        if this.stats.Count == 0
            return

        if sync {
            this._SaveAsync()
        } else {
            SetTimer(ObjBindMethod(this, "_SaveAsync"), -1)
        }
    }

    /**
     * 統計情報を非同期的にファイルに書き込みます。
     */
    static _SaveAsync() {
        this._Compaction()

        output := ""
        if (this.freq > 0) {
            max_us := (this.total_log_time2 * 1000000) / this.freq
            output .= Format("; Max Log Time: {:.3f} us `r`n`r`n", max_us)
        }

        for layout, stats_map in this.stats {
            output .= "[" . layout . "]`r`n"

            sortStr := ""
            for seq, item in stats_map {
                ; 頻度降順（カウントの反転値を0埋め10桁）とシーケンス（昇順）を連結してソート用文字列を作成
                sortStr .= Format("{:010}|{}", 9999999999 - item.count, seq) . "`n"
            }

            if sortStr != "" {
                sortStr := SubStr(sortStr, 1, -1) ; 末尾の改行を削除
                sortedStr := Sort(sortStr, "D`n") ; 昇順ソート（反転値が小さい＝元のカウントが大きい順になる）

                for line in StrSplit(sortedStr, "`n") {
                    if line = ""
                        continue
                    pos := InStr(line, "|")
                    if pos {
                        invCount := Integer(SubStr(line, 1, pos - 1))
                        count := 9999999999 - invCount
                        seq := SubStr(line, pos + 1)
                        item := stats_map[seq]
                        avg12 := item.count_d > 0 ? (item.duration12 // item.count_d) : 0
                        avg13 := item.count_d > 0 ? (item.duration13 // item.count_d) : 0
                        output .= seq . " : " . item.count . " " . item.count_d . " " . avg12 . " " . avg13 .
                            "`r`n"
                    }
                }
            }
            output .= "`r`n"
        }
        try {
            f := FileOpen(this.log_file, "w", "UTF-8")
            f.Write(output)
            f.Close()
        } catch {
        }
        this.last_save_time := A_TickCount
    }

    /**
     * 入力された文字をロガーに記録します。
     * @param {String} char - 記録対象の文字
     */
    static Log(char) {
        static is_warning_shown := false

        if !this.is_logging_enabled
            return
        if WinActive("ahk_group RemoteDesktops")
            return

        if (this.total_log_time > 50) {
            if (!is_warning_shown) {
                ToolTip("TypeAnalyzer: 処理遅延のため記録を一時停止")
                SetTimer(() => ToolTip(), -3000)
                is_warning_shown := true
            }
            ; 50msを超えた入力があった場合は、パフォーマンス保護のため早期リターン
            return
        }
        is_warning_shown := false

        if char = ""
            return
        if !ImeState.IsOn()
            return
        start_qpc := QueryCounter()
        if this.stats_short_idx < this.stats_short_max {
            this.stats_short_idx += 1
            entry := this.stats_short[this.stats_short_idx]
            entry.c := char
            entry.t := A_TickCount
        } else {
            return
        }
        end_qpc := QueryCounter()
        time_qpc := end_qpc - start_qpc
        this.total_log_time := Max(time_qpc, this.total_log_time)

    }
} ;class TypeAnalyzer

/**
 * 文字列をUTF-8エンコーディングに基づく16進数（HEX）文字列に変換します。
 * @param {String} str - 変換対象の文字列
 * @returns {String} 16進数の文字列
 */
StringToHex(str) {
    reqSize := StrPut(str, "UTF-8")
    buf := Buffer(reqSize)
    StrPut(str, buf, "UTF-8")
    hex := ""
    loop reqSize - 1 {
        hex .= Format("{:02x}", NumGet(buf, A_Index - 1, "UChar"))
    }
    return hex
}

/**
 * 現在フォーカスされているコントロールで未確定文字列（入力中・変換中）が存在するかを取得する
 * @returns {Boolean} 未確定文字が存在すれば true
 */
; static IsComposing() {
;     hwnd := GetFocusedControlHandle()
;     if !hwnd
;         return false

;     ; 1. IMM32 API (ImmGetCompositionStringW) による判定
;     hIMC := DllCall("imm32\ImmGetContext", "Ptr", hwnd, "Ptr")
;     if hIMC {
;         compLen := DllCall("imm32\ImmGetCompositionStringW", "Ptr", hIMC, "UInt", 0x0008, "Ptr", 0, "UInt", 0,
;             "Int")
;         DllCall("imm32\ImmReleaseContext", "Ptr", hwnd, "Ptr", hIMC)
;         if (compLen > 0) {
;             ImeState.is_composing_tracked := true
;             return true
;         }
;     }

;     ; 2. 他プロセスウィンドウの場合: AttachThreadInput によるコンテキスト取得
;     targetThreadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0, "UInt")
;     currentThreadId := DllCall("GetCurrentThreadId", "UInt")
;     if (targetThreadId && targetThreadId != currentThreadId) {
;         if DllCall("AttachThreadInput", "UInt", currentThreadId, "UInt", targetThreadId, "Int", 1) {
;             hIMC := DllCall("imm32\ImmGetContext", "Ptr", hwnd, "Ptr")
;             compLen := 0
;             if hIMC {
;                 compLen := DllCall("imm32\ImmGetCompositionStringW", "Ptr", hIMC, "UInt", 0x0008, "Ptr", 0, "UInt",
;                     0, "Int")
;                 DllCall("imm32\ImmReleaseContext", "Ptr", hwnd, "Ptr", hIMC)
;             }
;             DllCall("AttachThreadInput", "UInt", currentThreadId, "UInt", targetThreadId, "Int", 0)
;             if (compLen > 0) {
;                 ImeState.is_composing_tracked := true
;                 return true
;             }
;         }
;     }

;     ; 3. 候補ウィンドウ等の存在チェック (変換中のフォールバック)
;     if WinExist("ahk_class Microsoft.IME.UIManager.CandidateWindow.Host") || WinExist("ahk_class MSCTFIME UI") {
;         return true
;     }

;     ; 4. TSF / モダンアプリ向け: キーストロークトラッキングによる判定
;     if (ImeState.IsOn() && ImeState.is_composing_tracked) {
;         if (ImeState.composition_hwnd != 0 && ImeState.composition_hwnd != hwnd) {
;             ImeState.ResetComposition()
;             return false
;         }
;         return true
;     }

;     return false
; }

; I_1 := 0
; I_2 := 1
; I_3 := 2
; I_4 := 3
; I_5 := 4
; I_6 := 5
; I_7 := 6
; I_8 := 7
; I_9 := 8
; I_0 := 9
; I_minus := 10
; I_hat := 11
; I_yen := 12
; I_q := 13
; I_w := 14
; I_e := 15
; I_r := 16
; I_t := 17
; I_y := 18
; I_u := 19
; I_i := 20
; I_o := 21
; I_p := 22
; I_at := 23
; I_openbracket := 24
; I_a := 25
; I_s := 26
; I_d := 27
; I_f := 28
; I_g := 29
; I_h := 30
; I_j := 31
; I_k := 32
; I_l := 33
; I_semicolon := 34
; I_colon := 35
; I_closebracket := 36
; I_z := 37
; I_x := 38
; I_c := 39
; I_v := 40
; I_b := 41
; I_n := 42
; I_m := 43
; I_comma := 44
; I_period := 45
; I_slash := 46
; I_backslash := 47
; I_up := 48
; I_down := 49
; I_left := 50
; I_right := 51
