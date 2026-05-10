#Requires AutoHotkey v2.0

; ============================================================================
; スクリプト概要
; ============================================================================
; このスクリプトは、AutoHotkey v2 用の高度なキーカスタマイズを提供します。
; 主な機能:
; 1. センターモディファイア (LKey Mode 3): Space、Enter、無変換などのキーを、
;    短押し（タップ）では通常のキーとして、長押しではモディファイアキー
;    （レイヤー切り替え）として機能させます。
; 2. キーリマップ (RKey): キーをリマップし、Shift押下状態、IMEのON/OFF状態
;    に応じて異なる挙動を設定できます。
; 3. 長押しキー (LKey): RKey を拡張し、キーの長押しに別の機能を割り当てます
;    （例：短押しで ';'、長押しで ':'）
; 4. キーレイヤー (#HotIf): LKey を使用して、複数のキーボードレイヤー
;    （ナビゲーション、テンキー、記号レイヤーなど）を作成します。
; 5. レイアウト切り替え: キーボードレイアウト（Colemak, FMIX, 大西配列など）
;    を動的に変更する関数。
; 6. IME制御: IMEの状態を取得、設定、切り替える関数。
; 7. マウス速度制御: ホットキーを使用してシステムのマウス速度を調整するクラス。
; 8. KeyLogger: タイピングの統計（3キーシーケンス（トリグラム）の出現頻度と
;    打鍵間隔）を記録します。各配列の効率分析や、自身のタイピング傾向の把握に
;    活用できます。
; 9. IMEインジケーター (Dot Indicator): 現在の IME 状態を視覚化します。
;    日本語入力が ON の間、マウスカーソルに追従する小さなドットを表示します。
;
;  リアルシフトキーとスペースシフトキーの挙動は個別に設定可能
;  スペースシフトキー修飾として各キーの動作が登録されていればその動作を
;  登録されていれなければ、リアルシフトキーに登録された動作を行う
; ============================================================================

; ============================================================================
; 修飾キー・記号・定数
; ============================================================================
; 修飾記号:
; Win: #
; Ctrl: ^
; Shift: +
; Alt: !

; Send で直接使用できるキー:
; - ^ ¥ @ [ ] . /
; {} が必要なキー:
; Space Tab Enter BS Del Ins Left Right Up Down Home End PgUp PgDn Esc Pause PrintScreen

; ============================================================================
; 修飾キー・記号・定数
; ============================================================================
; --- 変数命名規則 ---
; R_... : ホットキー定義用の生文字列 (例: "sc07B")
; C_... : Send互換の文字列 (例: "{sc07B}")
; B_... : Blindモード用のSend文字列 (例: "{Blind}{sc07B}")

; ============================================================================
; スクリプト設定
; ============================================================================
;SingleInstance Force ;（コメントアウト）複数インスタンスを許可
ProcessSetPriority "Realtime" ; 最高の応答性を確保するため優先度をリアルタイムに設定
SetKeyDelay -1 ; キー入力後のディレイをなしに設定
ListLines 0
SendMode "Input" ; 速度と信頼性のため "Input" モードを使用

InstallKeybdHook true ; キーボードフックを常にインストール
InstallMouseHook true ; マウスフックを常にインストール（MouseSpeedクラス用）
#UseHook true ; ホットキーにフックの使用を強制
#MaxThreadsBuffer True ; 中断された場合にホットキーをバッファリングする
;#MaxThreadsPerHotkey 3 ;（コメントアウト）ホットキーあたりのスレッド数を制限

~^#!v:: {

}
~#!v:: {

}

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

;shift_lambda := () => GetKeyState("Shift", "P")

ReadConfig(section, key, defaultValue) {
    static ConfigPath := A_ScriptDir . "\config.ini"
    return IniRead(ConfigPath, section, key, defaultValue)
}

WriteConfig(value, section, key) {
    static ConfigPath := A_ScriptDir . "\config.ini"
    return IniWrite(value, ConfigPath, section, key)
}

/**
 * Shiftキーが物理的に押されているかを取得する
 * @returns {Boolean} Shiftが押されていれば true
 */
IsPhysicalShiftPressed() {
    ;global shift_lambda
    ;return shift_lambda()
    return GetKeyState("Shift", "P")
}

/*
* 高分解能タイマー(単位:millisecond)
*/
Timer() {
    DllCall("QueryPerformanceFrequency", "Int64*", &freq := 0)
    DllCall("QueryPerformanceCounter", "Int64*", &tick := 0)
    return tick / freq * 1000.0
}

QueryPerformanceFrequency() {
    DllCall("QueryPerformanceFrequency", "Int64*", &freq := 0)
    return freq
}

QueryPerformanceCounter() {
    DllCall("QueryPerformanceCounter", "Int64*", &tick := 0)
    return tick
}

/**
 * アクティブなウィンドウまたはフォーカスされているコントロールのハンドル (HWND) を取得する
 * 正確な IME 状態の検出に必要
 * @returns {Ptr} ウィンドウハンドル (HWND)
 */
GetFocusedControlHandle() {
    static ptr_size := A_PtrSize
    static cb_size := 4 + 4 + (ptr_size * 6) + 16
    static st_gti := Buffer(cb_size, 0)

    hwnd := WinExist("A")
    if hwnd {
        NumPut("UInt", cb_size, st_gti, 0)
        if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", st_gti) {
            hwnd := NumGet(st_gti, 8 + ptr_size, "UInt")
        }
    }
    return hwnd
}

/**
 * 特定のウィンドウの IME (Input Method Editor) 状態を設定する
 * @param {Ptr} hwnd - 対象ウィンドウハンドル
 * @param {Integer} state - 設定したい状態 (1: ON, 0: OFF)
 * @returns {LParam} DllCall の結
 */
SetImeStatus(hwnd, state) {
    return DllCall("SendMessage"
        , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
        , "UInt", 0x0283  ; WM_IME_CONTROL
        , "Ptr", 0x006    ; IMC_SETOPENSTATUS (開状態を設定)
        , "Ptr", state)  ; 1 = ON, 0 = OFF
}

class ImeState {
    static force_ime_on := false
    static cached_state := false

    /**
     * 動作モード
     * 0:前回のキー入力から一定時間の経過後チェック
     * 1:前回のIME状態チェックから一定時間の経過後チェック
     * 2:毎回チェック
     * 3:チェックなし(別途マニュアルでチェック)
     */
    static mode := 0
    static last_action_time := 0
    static last_check_time := 0
    static threshold := 100

    /**
     * 動作状態を設定する
     * @param {Integer} mode - 動作モード
     * 0:前回のキー入力から一定時間の経過後チェック
     * 1:前回のIME状態チェックから一定時間の経過後チェック
     * 2:毎回チェック
     * 3:チェックなし(別途マニュアルでチェックが必要)
     * @param {Integer} threshold - 状態を維持する時間 (ms)
     */
    static SetMode(mode, threshold) {
        ImeState.mode := mode
        ImeState.threshold := threshold
    }
    /**
     * キー操作が行われたことを記録する
     */
    static RecordActivity() {
        ImeState.last_action_time := A_TickCount
    }

    static RecordCheck() {
        ImeState.last_check_time := A_TickCount
    }
    /**
     * 動作状態をリセットする
     */
    static Reset() {
        ImeState.last_action_time := 0
        ImeState.last_check_time := 0
    }

    static MustCheck() {
        if (ImeState.mode == 0) {
            ;キー入力が長時間されない場合、チェックする
            return A_TickCount - ImeState.last_action_time > ImeState.threshold
        } else if (ImeState.mode == 1) {
            ;最後のチェックから時間が経過したら、チェックする
            return A_TickCount - ImeState.last_check_time > ImeState.threshold
        } else if (ImeState.mode == 2) {
            ;常にチェックする
            return true
        } else {
            ;チェックなし
            return false
        }
    }

    static UpdateState() {
        static last_active_hwnd := 0

        hwnd := GetFocusedControlHandle()
        time := A_TickCount

        ; 同じウィンドウであれば強制フラグを確認
        if last_active_hwnd = hwnd {
            if ImeState.force_ime_on {
                cached_state := true
                ImeState.RecordCheck()
                return true
            }
        }
        else {
            ; ウィンドウが変更されたため強制フラグをリセット
            ImeState.force_ime_on := false
        }

        last_active_hwnd := hwnd

        ; 実際の IME 状態を確認
        state := DllCall("SendMessage"
            , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
            , "UInt", 0x0283  ; WM_IME_CONTROL
            , "Ptr", 0x0005   ; IMC_GETOPENSTATUS (開状態を取得)
            , "Ptr", 0)      ; 1 = ON, 0 = OFF

        ImeState.cached_state := (state != 0)
        ImeState.RecordCheck()
        return ImeState.cached_state
    }

    /**
     * アクティブウィンドウの IME が現在 ON かどうかを確認する
     * `force_ime_on` フラグも考慮する
     * @returns {Boolean} IME が ON（または強制 ON）であれば true
     */
    static IsOn(precise := false) {
        if (precise || ImeState.MustCheck()) {
            return ImeState.UpdateState()
        }
        return ImeState.cached_state
    }

    /**
     * 強制 IME ON フラグを切り替える
     */
    static ToggleForce() {
        ImeState.force_ime_on := !ImeState.force_ime_on
    }

    /**
     * 強制フラグの状態に基づいた文字列を返す
     * @returns {String} "On" または "Off"
     */
    static MakeForceStateWord() {
        return ImeState.force_ime_on ? "On" : "Off"
    }
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
IsSingleBraceText(text) {
    return (StrLen(text) >= 3
    && SubStr(text, 1, 1) = "{"
    && SubStr(text, -1) = "}"
    && !InStr(text, "{", false, 2))
}

/**
 * 文字列に波括弧を追加する。既に囲まれている場合はそのまま。
 */
AddBraces(key) {
    if (IsSingleBraceText(key)) {
        return key
    }
    return "{" . key . "}"
}

/**
 * 文字列から波括弧を除去する。
 */
RemoveBraces(key) {
    if (IsSingleBraceText(key)) {
        return SubStr(key, 2, StrLen(key) - 2)
    }
    return key
}

/**
 * 指定されたキー文字列に修飾記号 (+, ^, !, #, {Blind}) が含まれているか確認。
 */
HasModifierSymbols(text) {
    list := ["{Blind}", "+", "#", "^", "!"]
    for item in list {
        if InStr(text, item, false) > 0 {
            return true
        }
    }
    return false
}

; --- 変換マップ定義 ---

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
    "one", "1", "two", "2", "three", "3", "four", "4", "five", "5", "six", "6", "seven", "7", "eight", "8", "nine", "9",
    "zero", "0",
    "space", "Space", "tab", "Tab", "enter", "Enter", "esc", "Esc"
)
char_from_str_map.Default := ""

; 文字 -> 文字列名
str_from_char_map := FlipMap(char_from_str_map)
str_from_char_map.Default := ""

; --- 変換基本関数 ---

; 文字 (;) -> スキャンコード ({sc027})。英数字はそのまま。
ScFromChar(c) {
    sc := sc_from_char_map[c]
    if (sc == "") {
        return c
    }
    return AddBraces(sc)
}

; スキャンコード ({sc027}) -> 文字 (;)。
CharFromSc(sc) {
    sc_raw := RemoveBraces(sc)
    c := char_from_sc_map[sc_raw]
    return (c == "") ? sc : c
}

; 名前 (semicolon) -> 文字 (;)。
CharFromStr(str) {
    c := char_from_str_map[str]
    return (c == "") ? str : c
}

; 文字 (;) -> 名前 (semicolon)。
StrFromChar(c) {
    str := str_from_char_map[c]
    return (str == "") ? c : str
}

; --- 統合ロジック関数 (INI入出力用) ---
/**
 * INIファイルのエントリー名を作る: スキャンコードや文字を名前形式に変換
 * 例: "{sc027}" -> "semicolon", ";" -> "semicolon", "1" -> "one", "a" -> "a", "{Enter}" -> "Enter"
 */
EntryName(sc) {
    c := CharFromSc(StrLower(sc))
    return StrFromChar(c)
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
    ; 名前（semicolon等）から文字（;等）を取得
    c := CharFromStr(str)
    ; 文字からスキャンコードを取得（スキャンコード化できない文字はそのまま返る想定）
    return ScFromChar(c)
}

/**
 * 【送信コマンドの構築】
 * 解決済みのキー表記に、修飾記号などを付与して「Send関数用」の最終文字列を作る。
 */
BuildSendText(text, prefix := "") {
    if text == "" || text == "{none}"
        return ""
    if InStr(text, "{Blind}", false) || HasModifierSymbols(text)
        return text
    if (StrLen(text) == 1 || IsSingleBraceText(text)) {
        return prefix . text
    }
    return text
}

/**
 * レイアウト文字列のパース補助
 */
class LayoutString {
    arr := []
    __New(layout_str) {
        this.layout_str := layout_str
        if this.layout_str = ""
            return
        if InStr(this.layout_str, " ") {
            this.arr := StrSplit(RegExReplace(Trim(this.layout_str), " +", " "), " ")
        } else {
            this.arr := StrSplit(this.layout_str)
        }
    }
    GetElement(index) => (index <= this.arr.Length) ? this.arr[index] : ""
}

class KeyLogItem {
    count := 0
    count_d := 0
    duration12 := 0
    duration13 := 0
}

class KeyLogger {
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

    static ToggleLogging() {
        this.is_logging_enabled := !this.is_logging_enabled
        this.SaveConfig()
        ShowOSD("KeyLogger: " . (this.is_logging_enabled ? "ON" : "OFF"))
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
        this.freq := QueryPerformanceFrequency()
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
            WriteConfig(String(LKey.long_press_th), "Settings", "long_press_th")
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

                        item := KeyLogItem()
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

    static SetLayoutName(section) {
        this.current_layout := section
    }

    static ChangeLayout(section) {
        this._MergeShortTerm()
        this._Consolidate()
        this._Compaction()
        this.SetLayoutName(section)
    }

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
            ; よく使う記号のスキャンコードを文字に変換
            ;char := char_from_sc_map.Get(char, char)

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
                stats_map[seq] := KeyLogItem()

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
                    full_map[seq] := KeyLogItem()
                full_item := full_map[seq]

                full_item.count += mid_item.count
                full_item.count_d += mid_item.count_d
                full_item.duration12 += mid_item.duration12
                full_item.duration13 += mid_item.duration13
            }
        }
        this.stats_mid := Map()
    }

    static SaveIfIdle(time) {
        Critical
        if (time < 20000) {
            return
        }
        if this.stats_short_idx == 0
            return

        ; 前回saveから指定時間経っていたら保存
        if (A_TickCount - this.last_save_time >= this.AUTOSAVE_INTERVAL && time >= 60000) {
            this.Save()
            return
        }

        this._MergeShortTerm()
    }

    /**
     * 現在の統計情報をファイルに書き込む
     */
    static Save() {
        Critical
        this._MergeShortTerm()
        this._Consolidate()

        if this.stats.Count == 0
            return

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
                        output .= seq . " : " . item.count . " " . item.count_d . " " . avg12 . " " . avg13 . "`r`n"
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

    static Log(char) {
        if !this.is_logging_enabled
            return

        current_max := (this.total_log_time * 100)
        if (current_max > this.freq) {
            Tooltip("Too fast")
            ; 10msを超えた入力があった場合は、パフォーマンス保護のため早期リターン
            return
        }

        if char = ""
            return
        if !ImeState.IsOn()
            return
        start := QueryPerformanceCounter()
        if this.stats_short_idx < this.stats_short_max {
            this.stats_short_idx += 1
            entry := this.stats_short[this.stats_short_idx]
            entry.c := char
            entry.t := A_TickCount
        }
        end := QueryPerformanceCounter()
        time := end - start
        this.total_log_time := Max(time, this.total_log_time)

    }
}

/**
 * 現在のウィンドウに対して強制 IME ON フラグを切り替える
 */
ToggleForceImeModeOn() {
    ImeState.ToggleForce()
    ImeState.UpdateState()
    UpdateImeIndicator()
    ShowOSD("Force IME Mode: " . ImeState.MakeForceStateWord())
}

SendImeChar(c) {
    Critical
    ;ImeState.Reset()
    Send(c)
    ImeState.UpdateState()
}

/**
 * 全角/半角キーを送信して IME 状態を切り替える
 */
ToggleImeState() {
    SendImeChar(B_ZENKAKU)
    UpdateImeIndicator()
}

/**
 * 指定されたコンテンツを送信し、キーログを記録する
 * @param {String} c - 送信する文字列
 */
SendAndLog(c) {
    if c = B_NOCONV || c = B_CONV || c = B_ZENKAKU {
        ; ImeState.Reset()
        ; Send(c)
        ; ImeState.UpdateState()
        SendImeChar(c) ;criticalが二重にかかるが大丈夫
        UpdateImeIndicator()
        return
    }
    Send(c)
    KeyLogger.Log(c)
    ImeState.RecordActivity()
}

/**
 * 現在の IME 状態に応じて、特定のキーを送信する
 * @param {String} key_ime_off - IME が OFF の場合に送信するキー文字列
 * @param {String} [key_ime_on=""] - IME が ON の場合に送信するキー文字列
 * 省略された場合は `key_ime_off` が使用される
 */
SendBasedOnImeState(key_ime_off, key_ime_on := "") {
    if key_ime_off = key_ime_on {
        SendAndLog(key_ime_on)
    } else if !ImeState.IsOn() || key_ime_on == "" {
        SendAndLog(key_ime_off)
    } else {
        SendAndLog(key_ime_on)
    }
}

; --- リモートデスクトップ使用時の自動無効化 ---
GroupAdd("RemoteDesktops", "ahk_class TscShellContainerClass") ; Windows 標準RDP
;GroupAdd("RemoteDesktops", "ahk_exe AnyDesk.exe")              ; AnyDesk
;GroupAdd("RemoteDesktops", "ahk_exe TeamViewer.exe")           ; TeamViewer
;GroupAdd("RemoteDesktops", "ahk_exe tvnviewer.exe")            ; TightVNC
;GroupAdd("RemoteDesktops", "ahk_exe vncviewer.exe")            ; RealVNC / UltraVNC

/**
 * リモートデスクトップウィンドウがアクティブな場合に、スクリプトを自動的にサスペンド（一時停止）する
 * @returns {Boolean} サスペンドされた状態であれば true
 */
AutoSuspendForRemoteDesktop() {
    static auto_suspended := false
    if WinActive("ahk_group RemoteDesktops") {
        if !A_IsSuspended {
            Suspend(true)
            auto_suspended := true
        }
    } else {
        if auto_suspended {
            Suspend(false)
            auto_suspended := false
        }
    }
    return auto_suspended
}

/**
 * フォント管理クラス
 * 起動時に一度だけチェックを行い、結果を保持する
 */
class FontManager {
    static Monospace := this._DetermineMonospace()

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
        DllCall("GetTextFace", "Ptr", hdc, "Int", 256, "Ptr", nameBuf)
        actualName := StrGet(nameBuf)

        ; 3. 後処理
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldObj, "Ptr")
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
        DllCall("DeleteObject", "Ptr", hFont)

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

; --- 設定 ---
color_japanese := "Red"
dot_size := 8
; ------------

; キャレット表示用のGUI作成
; 描画用のウィンドウ（GUI）作成
m_gui := Gui("+AlwaysOnTop -Caption +ToolWindow +LastFound -DPIScale")
m_gui.BackColor := color_japanese
WinSetRegion("0-0 w" dot_size " h" dot_size " Ellipse", m_gui)

;DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr") ; DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2

/**
 * マウスカーソル付近に IME 状態を示すインジケータ（ドット）を表示・更新する
 */
UpdateImeIndicator(precise := False) {
    static last_status := -1 ;-1:初期状態, 0:オフ, 1:オン, 2:強制オン

    if !KeyLogger.is_showing_ime_indicator {
        if last_status != 0 {
            m_gui.Hide()
            last_status := 0
        }
        return
    }

    mx := -1, my := 0
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    static last_x := -2, last_y := 0

    if (mx = last_x && my = last_y) {
        ime_state_value := 0
        if ImeState.IsOn(precise) {
            ime_state_value := ImeState.force_ime_on ? 2 : 1
        }

        if ime_state_value > 0 {
            if ime_state_value != last_status {
                m_gui.BackColor := (ime_state_value == 2) ? "Green" : color_japanese
                m_gui.Show("x" (mx + 36) " y" (my + 36) " w" dot_size " h" dot_size " NoActivate")
            }
        } else {
            ; 既に非表示の場合は Hide しない（余計な負荷削減）
            if last_status != 0 {
                m_gui.Hide()
            }
        }
        last_status := ime_state_value
    } else {   ; マウスが動いて位置が変更された場合
        if last_status != -1 {
            m_gui.Hide()
        }
        last_x := mx
        last_y := my
        last_status := -1
    }
}

/**
 * 定期的に実行されるタイマーイベント。IME表示の更新やログの保存などを行う。
 */
TimerEvent() {
    static counter := 0
    if (mod(counter, 5) == 0) {
        if (AutoSuspendForRemoteDesktop()) {
            return
        }
    }

    UpdateImeIndicator()
    ;static mouse_state := 0
    ; if A_TimeIdleMouse < 300 { ;マウス操作時のみ処理時
    ;     if (mouse_state == 0) {
    ;         ;マウス操作でアクティブウィンドウが変わるため
    ;         ;前回のIME状態チェックから一定時間の経過後チェック
    ;         ImeState.SetMode(1, 500)
    ;     }
    ;     UpdateImeIndicator()
    ;     mouse_state := 1
    ; } else { ;マウス操作終了時
    ;     if (mouse_state == 1) {
    ;         ;キー入力に備えて設定
    ;         ;前回のキー入力から一定時間の経過後チェック
    ;         ;キーによるIME状態変更をフックしているので、
    ;         ;そもそもキー押下時のチェックは不要だが、念のため
    ;         ImeState.SetMode(0, 1000)
    ;     }
    ;     mouse_state := 0
    ; }

    ; 20秒以上操作がない場合、ログを保存
    if (mod(counter, 100) == 0) {
        KeyLogger.SaveIfIdle(A_TimeIdlePhysical)
    }
    counter++
}

SetTimer(TimerEvent, 100) ;

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
        DllCall("SystemParametersInfo", "UInt", MouseSpeed.SPI_GETMOUSESPEED, "UInt", 0, "Ptr*", &val, "UInt", 0)
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
        DllCall("SystemParametersInfo", "UInt", MouseSpeed.SPI_SETMOUSESPEED, "UInt", 0, "Ptr", val, "UInt", 0)
        ToolTip("MouseSpeed: " . val)
        SetTimer(ToolTip, 3000) ; ツールチップを3秒間表示する
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

MakeModStr() {
    return (GetKeyState("LWin", "P") || GetKeyState("RWin", "P") ? "#" : "")
    . (GetKeyState("Alt", "P") ? "!" : "")
    . (GetKeyState("Ctrl", "P") ? "^" : "")
    . (GetKeyState("Shift", "P") ? "+" : "")
}

/*============================================================================
 [Class] MKey (モディファイアキー)
 「デュアルロール」モディファイアキー機能を実装します。
 - タイムアウト時間内に離された場合（短押し）はデフォルトキーを送信します。
 - タイムアウト時間を超えて押し続けられた場合は、モディファイアキーとして機能します。
============================================================================*/
; class MKey {
;     /**
;      * コンストラクタ
;      * @param {String} key - 監視するキー (例: "SPACE", "sc07B")。"{...}" 形式でも可。
;      * @param {Integer} [timeout=180] - 短押しと長押しを判別する時間 (ms)。
;      */
;     __New(key, timeout := 180) {
;         if key = "" { ; F13のような「仮想」モディファイア用
;             this.key_str := ""
;             this.key := key ; 登録されたキー
;         } else {
;             this.key := RemoveBraces(key)
;             this.key_str := AddBraces(key)
;         }
;         this.pressed_time := 0 ; 0 = 押されていない, >0 = 押し下げ開始時間
;         this.mod_str := ""     ; 押下時に保持されていた他の修飾キーを保存 (例: "+^")
;         this.timeout := timeout
;     }
;     /**
;      * キーが現在「押し下げ」状態（Down()が呼ばれた）かどうかを確認する
;      * @returns {Boolean} 押されていれば true
;      */
;     IsPressed() => (this.pressed_time != 0)
;     ;IsPressed() => GetKeyState(this.key_str, "P")

;     /**
;      * このキーが押された瞬間の他の修飾キー（Shift, Ctrl, Alt, Win）の状態を保存する
;      */
;     SetModStr() {
;         this.mod_str := MakeModStr()
;     }

;     /**
;      * キー押し下げ時のホットキーで呼び出す (例: `*Space::space.Down()`)
;      * @returns {Boolean} 既に押し下げ済みであれば false (キーリピート防止)、そうでなければ true
;      */
;     Down() {
;         Critical
;         if this.pressed_time != 0 { ; 既に押し下げ処理中のため無視
;             return false
;         }
;         this.pressed_time := A_TickCount ; 押し下げ時間を記録
;         this.SetModStr()                 ; 他の修飾キーを記録
;         return true
;     }

;     /**
;      * キー離し時のホットキーで呼び出す (例: `*Space up::space.Up()`)
;      * 短押しだった場合は元のキー（修飾キー付き）を送信します。
;      */
;     Up() {
;         Critical
;         if (A_TickCount - this.pressed_time < this.timeout) {
;             SendAndLog("{Blind}" . this.mod_str . this.key_str)
;         }
;         this.pressed_time := 0
;     }

;     /**
;      * キーの押し下げ状態を強制的にリセットする
;      */
;     Reset() {
;         this.pressed_time := 0
;     }
; } ;class MKey

/*============================================================================
 [Class] RKey (リマップキー)
 キーリマップを管理し、Shift、IME ON/OFF の状態に応じて異なる出力を処理します。
 登録する文字列の仕様については BuildSendText() のコメントを参照してください。
============================================================================*/
class RKey {
    static layer_list := [1, 2, 3, 4, 5, 6, 7]
    ;static layer_list := [L_NAVI_CTRL, L_SELECT, L_SYMBOL_NUM, L_SYMBOL1, L_SYMBOL2, L_NUMPAD, L_SHIFT]

    static use_registered_key_for_ctrl := false ; (未使用？) ctrl または alt 用
    static last_key := ""
    /**
     * コンストラクタ
     * @param {String} key - 物理キー (例: "q", "{sc027}")。基本的には 1 文字または 1 つのスキャンコード。
     * @param {String} [reg_key=""] - 登録キー (短押し時に送信されるキー)。省略時は物理キーと同じ。
     */
    __New(key, reg_key := "") {
        this.layer_keys := []
        loop RKey.layer_list.Length
            this.layer_keys.Push("")

        this.org_key := AddBraces(key)
        this.org_key_raw := RemoveBraces(key)
        if reg_key = "" {
            this.SetKey(key)   ; IME OFF 時のキーを設定
            this.SetImeKey(key) ; IME ON 時のキーを設定 (デフォルトは OFF 時と同じ)
        } else {
            this.SetKey(reg_key)   ; IME OFF 時のキーを設定
            this.SetImeKey(reg_key) ; IME ON 時のキーを設定 (デフォルトは OFF 時と同じ)
        }
    }

    /**
     * レイヤーキーを設定する
     * @param {Integer} layer_id - レイヤーID
     * @param {String} action - 設定するアクション
     * @param {Boolean} reset_if_blank - 空の場合にリセットするかどうか
     */
    SetLayerKey(layer_id, action, reset_if_blank := false) {
        if action == "" {
            if reset_if_blank {
                this.layer_keys[layer_id] := ""
            }
        } else {
            this.layer_keys[layer_id] := action
        }
    }

    SendLayerKey(layer_id) {

        action := this.layer_keys[layer_id]
        if action == "" {
            if (layer_id == L_SHIFT)
                this.SendShiftedKey()
        } else {
            if action == "{none}"
                return
            RKey.last_key := this.org_key ; 最後に押されたキーとして記録（他キーの Up 時判定用）
            SendAndLog(action)
            return
        }
    }

    /**
     * IME OFF 時のキーマッピングを設定する
     * @param {String} key -  登録する文字列
     * @param {String} [shift_key=""] - Shift 時の登録する文字列。
     */
    SetKey(key, shift_key := "") {
        this.key_text := BuildSendText(key)
        this.shift_key_text := shift_key == "" ? BuildSendText(key, "+") : BuildSendText(shift_key)
    }

    /**
     * IME ON 時のキーマッピングを設定する
     * @param {String} [ime_key=""] - IME ON 時の基本キー (複数文字可)。空白の場合は IME OFF 時と同じ。
     * @param {String} [shift_ime_key=""] - IME ON 時の Shift キー (複数文字可)
     *                                      "" = 自動生成/デフォルト、"{none}" = 無効化。
     */
    SetImeKey(ime_key := "", shift_ime_key := "") {
        if ime_key = "" {
            this.ime_key_text := this.key_text
            this.shift_ime_key_text := shift_ime_key = "" ? this.shift_key_text : BuildSendText(shift_ime_key)
        } else {
            this.ime_key_text := BuildSendText(ime_key)
            this.shift_ime_key_text := shift_ime_key = "" ? BuildSendText(ime_key, "+") : BuildSendText(shift_ime_key)
        }
    }

    /**
     * 内部ヘルパー: IME 状態に基づいて正しいキーを送信する
     * @param {String} ime_key - IME ON 時に送信するキー
     * @param {String} normal_key - IME OFF 時に送信するキー
     */
    _SendKey(ime_key, normal_key) => SendBasedOnImeState(normal_key, ime_key)

    SendShiftedKey(shift := true) {
        Critical
        if shift {
            this._SendKey(this.shift_ime_key_text, this.shift_key_text)
        } else {
            this._SendKey(this.ime_key_text, this.key_text)
        }
        return shift
    }

    /**
     * Ctrl, Alt, Win (CAW) のパススルーを処理する
     * これらの修飾キーのいずれかが押されている場合は、リマップをバイパスして物理キーをそのまま送信する
     * @param {String} pressed_key - 押された物理キー (例: "{x}", "{sc027}")
     * @returns {Boolean} CAW が押されていた場合 (パススルー発生) は true
     */
    _SendCAWKey(pressed_key) {
        caw := GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") || GetKeyState("LWin", "P") || GetKeyState(
            "RWin",
            "P")
        if caw {
            Send("{Blind}" . pressed_key)
            return true
        }
        return false
    }

    /**
     * メインのキー送信ロジック
     * 1. Ctrl/Alt/Win の確認 (パススルー)
     * 2. なければ Shift 状態を確認してリマップキー (基本または Shift 版) を送信
     * @param {String} pressed_key - 押された物理キー
     * @returns {Boolean} CAW パススルーが発生した場合は true
     */
    _SendSCAWKey(pressed_key) {
        if this._SendCAWKey(pressed_key) {
            return true
        }
        this.SendShiftedKey(IsPhysicalShiftPressed())
        return false
    }

    /**
     * キー押し下げ時のホットキーから呼び出す (例: `*x::x.Down()`)
     */
    Down() {
        Critical
        RKey.last_key := this._SendSCAWKey(this.org_key) ? "" : this.org_key
    }

    /**
     * キー離し時のホットキーから呼び出す (例: `*x up::x.Up()`)
     * (RKey では未使用だが、LKey で継承して使用するため定義)
     */
    Up() {
    }
} ;class RKey

/*============================================================================
 [Class] LKey (長押し対応リマップキー)
 RKey を拡張し、一定時間の押し下げ（長押し）に応じたアクションを追加します。

 [モード説明]
 0: 通常のリマップ (RKey と同等。長押し判定なし)
 1: 即時入力 + 長押し置換
    - 押し下げ時にキーを即座に送信。
    - 長押し判定時、送信済みのキーを Backspace で消去し、Shift 版のキーを再送信。
 2: パススルー (入力抑制)
    - 押し下げ時、離し時ともにリマップ出力を抑制する。
 3: 短押し時のみ入力 (MKey 相当)
    - 短押しで離した場合のみキーを送信。長押し時は何も送信しない。
 (予約) 4: 即時入力 + 長押しカスタム置換
    - 押し下げ時に即座に送信し、長押し判定時にカスタムの長押しキーに置換。

 * モード 1, 2, 3, 4 ではキーリピートが無効化されます。
 * モード 0, 1, 2, 4 では Ctrl, Alt, Win (CAW) 押下時は物理キーの修飾としてパススルーされます。
 * 登録キーは RKey と同様に SetKey, SetImeKey で設定します。
 * モード 1, 4 で使用するキーは 1 文字（または 1 つの {スキャンコード}）である必要があります。
============================================================================*/
class LKey extends RKey {
    static long_press_th := 300 ; 長押しと判定する閾値 (ms)
    static last_key := ""       ; リピート防止のため最後に押されたキーを追跡

    pressed_time := 0     ; 物理的に押し下げを開始した時刻
    Layered := false
    /**
     * コンストラクタ
     * @param {String} key - 物理キー (例: "q", "{sc027}")。
     * @param {Integer} [mode=0] - 動作モード (0-4)。
     * @param {String} [reg_key=""] - 登録キー (短押し時に送信されるキー)。
     */
    __New(key, mode := 0, reg_key := "") {
        super.__New(key, reg_key) ; RKey の初期化
        this.long_press_mode := mode
    }

    /**
     * 長押し機能をグローバルに有効化、無効化、または切り替える
     * @param {Integer} [m=2] - モード: 0=無効, 1=有効, 2=切り替え
     * @param {Boolean} [show_info=False] - 画面上に通知を表示するかどうか
     */
    ; static EnableLongPress(m := 2, show_info := False) {
    ;     if m == 0 {
    ;         LKey.long_press_enabled := False
    ;     } else if m == 1 {
    ;         LKey.long_press_enabled := True
    ;     } else {
    ;         LKey.long_press_enabled := !LKey.long_press_enabled ; Toggle
    ;     }
    ;     if show_info {
    ;         if LKey.long_press_enabled {
    ;             ShowOSD("LKey is enabled")
    ;         } else {
    ;             ShowOSD("LKey is disabled")
    ;         }
    ;     }
    ; }

    /*============================================================================
    	(Override) Sets the key mapping for when IME is OFF.
    	@param {String} key - The base key to send.
    	@param {String} [shift_key=""] - Key for Shift.
    ============================================================================*/
    SetKey(key, shift_key := "") {
        super.SetKey(key, shift_key)
    }

    ; /**
    ;  * 長押し時に送信するキー文字列を設定する
    ;  * @param {String} [long_key=""]
    ;  */
    ; SetLongKey(long_key := "") {
    ;     if long_key = "" {
    ;         this.long_press_mode := 1 ; 長押しを有効化
    ;         this.long_key_str := this.shift_key_text ; デフォルトでは Shift 時のキーを使用
    ;     } else if long_key = "none" {
    ;         this.long_press_mode := 0 ; 長押しを無効化
    ;         this.long_key_str := "none"
    ;     } else if long_key = "skip" {
    ;         this.long_press_mode := 2 ; 長押し、キーリピートを無効化
    ;         this.long_key_str := "none"
    ;     } else {
    ;         this.long_press_mode := 1 ; 長押しを有効化
    ;         this.long_key_str := long_key ; 指定されたキーを使用
    ;     }
    ; }

    /**
     * キーが現在押し下げられているかどうかを確認する
     */
    ;IsPressed() => this.pressed_time != 0
    IsPressed() => GetKeyState(this.org_key_raw, "P")

    /**
     * キー押し下げ時の処理
     */
    Down() {
        Critical

        for _, key in RKey.layer_list {
            if LayerState(key) {
                ; 自身がレイヤーキーの場合はレイヤー処理をスキップ
                if (key == L_SHIFT && this == space) ||
                (key == L_NUMPAD && this == tab) ||
                (key == L_SYMBOL_NUM && this == noconv) ||
                (key == L_SYMBOL1 && this == conv) ||
                (key == L_SYMBOL2 && this == f14) ||
                ((key == L_NAVI_CTRL || key == L_SELECT) && this == f13)
                    continue

                super.SendLayerKey(key)
                this.Layered := true
                return
            }
        }
        this.Layered := false
        this._Down()
    }

    /**
     * キー離し時の処理
     */
    Up() {
        Critical
        if !this.Layered
            this._Up()
        this.Layered := false
    }

    _Down() {
        ;Critical

        ; モード 3 (短押し時のみ入力) の特殊処理
        if this.long_press_mode = 3 {
            if (this.pressed_time != 0) {
                return ; キーリピート防止
            }
            this.mod_str := MakeModStr()
            this.pressed_time := A_TickCount
            RKey.last_key := this.org_key
            return
        }
        ;    if this.long_press_mode = 2 || LKey.long_press_enabled = 0 {
        ; this.pressed_time := A_TickCount
        ; RKey.last_key := this.org_key
        ;    }

        ; --- 以下、モード 0, 1, 2 共通の判定 ---
        ; 1. 修飾キー (Ctrl/Alt/Win) が押されている場合はリマップせずパススルー
        if super._SendCAWKey(this.org_key) {
            this.pressed_time := 0
            RKey.last_key := ""
            return
        }

        ; 2. 長押し機能が無効（モード 0）またはグローバル設定がオフの場合
        if this.long_press_mode = 0 { ; || LKey.long_press_enabled = 0
            shift := IsPhysicalShiftPressed()
            this.SendShiftedKey(shift) ; 通常のリマップとして即座に送信
            this.pressed_time := 0
            RKey.last_key := this.org_key
            return
        }

        ; 3. キーリピートによる多重実行を防止
        if this.pressed_time != 0 {
            return
        }

        ; 4. モード 1 の場合、まず「短押し用キー」を即座に送信する
        ;    （長押し確定時に Backspace で消去して置換する）
        if this.long_press_mode = 1 {
            shift := IsPhysicalShiftPressed()
            this.SendShiftedKey(shift)
        }

        ; ; 5. モード 5 (KeyWait ベースの即時入力 + 長押し置換)
        ; if this.long_press_mode = 5 {
        ;     this.pressed_time := A_TickCount
        ;     shift := IsPhysicalShiftPressed()
        ;     this.SendShiftedKey(shift)
        ;     Critical("Off")
        ;     released := KeyWait(this.org_key_raw, "T" . (LKey.long_press_th / 1000))
        ;     if !released {
        ;         Send("{Backspace}")
        ;         this.SendShiftedKey(true)
        ;         KeyWait(this.org_key_raw)
        ;     }
        ;     this.pressed_time := 0
        ;     return
        ; }

        ; 5. 状態を記録し、長押し判定のためのタイマーを開始
        this.pressed_time := A_TickCount
        RKey.last_key := this.org_key
    }

    _Up() {
        ;Critical
        if (this.pressed_time = 0) {
            return
        }

        now := A_TickCount
        duration := now - this.pressed_time
        is_long := (duration >= LKey.long_press_th)

        ; モード 3: 短押しだった場合のみキーを送信
        if this.long_press_mode = 3 {
            ; 他のキーが間に押されておらず、かつタイムアウト内であれば送信
            if !is_long && (RKey.last_key == this.org_key) {
                ;SendAndLog("{Blind}" . this.mod_str . this.org_key)
                SendAndLog(this.mod_str . this.key_text)
            }
            this.pressed_time := 0
            return
        }

        ; モード 1, 2 の共通処理
        ; 前回のホットキーと同じキー（リピートや割り込みがない）場合のみ判定を行う
        if RKey.last_key == this.org_key {
            ; モード 1: 長押し確定時に既存文字を消去して置換
            if this.long_press_mode == 1 {
                if is_long {
                    Send("{Backspace}")
                    this.SendShiftedKey(true) ; 長押しアクション（Shift版）を実行
                }
            }
            ; モード 2: 長押し・短押しに関わらず Up 時には何もしない
        }
        ; モード2の場合、何もしない

        ; 内部状態のリセット
        this.pressed_time := 0
    }
} ;class LKey

; ============================================================================
; キーオブジェクトの生成
; ============================================================================

; --- モディファイアキー (MKey) ---
; f13 := MKey("")
; space := MKey(R_SPACE)
; tab := MKey(R_TAB)
; noconv := MKey(R_NOCONV)
; conv := MKey(R_ENTER)
; f14 := MKey(R_ZENKAKU)
; colon := LKey(C_COLON, 2)

f13 := LKey("f13", 2)
space := LKey(R_SPACE, 3, C_SPACE)
tab := LKey(R_TAB, 3, C_TAB)
noconv := LKey(R_NOCONV, 3, C_ZENKAKU)
conv := LKey(R_CONV, 3, C_ENTER)
f14 := LKey("f14", 3, C_ZENKAKU)

; --- リマップキー (RKey) ---
; (数字列)
k1 := LKey("1")
k2 := LKey("2")
k3 := LKey("3")
k4 := LKey("4")
k5 := LKey("5")
k6 := LKey("6")
k7 := LKey("7")
k8 := LKey("8")
k9 := LKey("9")
k0 := LKey("0")
minus := LKey("-")
hat := LKey(C_HAT) ; ^
yen := LKey("¥") ; ¥
;
; (QWERTY段)
q := LKey("q")
w := LKey("w")
e := LKey("e")
r := LKey("r")
t := LKey("t")
;
y := LKey("y")
u := LKey("u")
i := LKey("i")
o := LKey("o")
p := LKey("p")
at := LKey("@")
openbracket := LKey("[")
;
; (ASDF段)
a := LKey("a")
s := LKey("s")
d := LKey("d")
f := LKey("f")
g := LKey("g")
;
h := LKey("h")
j := LKey("j")
k := LKey("k")
l := LKey("l")
semicolon := LKey(C_SEMICOLON)
colon := LKey(C_COLON)
closebracket := LKey("]")
;
; (ZXCV段)
z := LKey("z")
x := LKey("x")
c := LKey("c")
v := LKey("v")
b := LKey("b")
;
n := LKey("n")
m := LKey("m")
comma := LKey(C_COMMA) ; ,
period := LKey(".") ; .
slash := LKey("/") ; /
backslash := LKey(C_BACKSLASH) ; \ _

enter := LKey(C_ENTER)

; (矢印キー - リマップ用)
up := RKey(C_UP)
down := RKey(C_DOWN)
left := RKey(C_LEFT)
right := RKey(C_RIGHT)

; --- レイアウト用キー登録（ループ用） ---
LAYOUT_SPECIAL_KEYS := [space, tab, noconv, conv, f14, enter, up, down, left, right]
LAYOUT_SPECIAL_NAMES := ["space", "tab", "noconv", "conv", "f14", "enter", "up", "down", "left", "right"]

LAYOUT_NUM_KEYS := [k1, k2, k3, k4, k5, k6, k7, k8, k9, k0, minus]
LAYOUT_CHAR_KEYS := [
    q, w, e, r, t, y, u, i, o, p,
    a, s, d, f, g, h, j, k, l, semicolon,
    z, x, c, v, b, n, m, comma, period, slash
]

LAYOUT_KEYS := [
    k1, k2, k3, k4, k5, k6, k7, k8, k9, k0, minus, hat, yen,
    q, w, e, r, t, y, u, i, o, p, at, openbracket,
    a, s, d, f, g, h, j, k, l, semicolon, colon, closebracket,
    z, x, c, v, b, n, m, comma, period, slash, backslash
]

QWERTY_CHARS := [
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "^", "¥",
    "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "@", "[",
    "a", "s", "d", "f", "g", "h", "j", "k", "l", ";", ":", "]",
    "z", "x", "c", "v", "b", "n", "m", ",", ".", "/", "\"
]

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

; ============================================================================
; キーレイアウト切り替え関数
; ============================================================================
/**
 * すべての IME-ON 時のキー定義（SetImeKey）をリセットし、
 * IME-OFF 時のデフォルト（SetKey）に戻します。
 */
ResetIME() {
    for keyObj in LAYOUT_KEYS {
        keyObj.SetIMEKey()
    }
}

LoadLayoutConfig() {
    try {
        try {
            LKey.long_press_th := Integer(ReadConfig("Settings", "long_press_th", String(
                LKey
                .long_press_th)))
        } catch {
        }
        layout_name := ReadConfig("Settings", "StartupLayout", "")
        if layout_name = ""
            return

        ; ハードコードされたレイアウトを確認
        switch layout_name {
            case "Qwerty": ChangeQwertyLayout()
            case "Oonishi": ChangeOonishiLayout()
            case "Colemak": ChangeColemakLayout()
            case "FMIX12f": ChangeFMIX12f_Layout()
            case "FMIX12f-13fR": ChangeFMIX12f_FMIX13fR_Layout()
            case "FMIX14-14R": ChangeFMIX14_FMIX14R_Layout()
            case "FMIX13f-14fR": ChangeFMIX13f_FMIX14fR_Layout()
            case "FMIX13f-Minato": ChangeFMIX13f_minato_Layout()
            case "FMIX13fie-Minato": ChangeFMIX13fie_minato_Layout()
            default:
                ; INIファイルからカスタムレイアウトの読み込みを試行
                LoadLayoutFromIni(layout_name)
        }
    } catch {
    }
}

; ============================================================================
; レイヤー状態判定関数
; ============================================================================
L_NAVI_CTRL := 1
L_SYMBOL_NUM := 2
L_SYMBOL1 := 3
L_SYMBOL2 := 4
L_SELECT := 5
L_NUMPAD := 6
L_SHIFT := 7

;mod_key_list := [f13,noconv,conv,f14,f13,tab,space]
;L_FUNC := 4

/**
 * config.ini に設定された現在のレイアウト（StartupLayout）を強制的に再読み込みして適用する
 */
LoadLayoutFromIni(index) {
    global L_NAVI_CTRL, L_SYMBOL_NUM, L_SYMBOL1, L_SYMBOL2, L_NUMPAD, L_SELECT
    name := ReadConfig(index, "name", "")
    if name = "" {
        ChangeQwertyLayout()
        return
    }
    ver := ReadConfig(index, "ver", "1")
    if ver = 1 {
        if ApplyLayoutFromIni(index)
            return
    } else if ver = 2 {
        if ApplyLayoutFromIni2(index) {
            ApplyLayerLayoutFromIni(L_NAVI_CTRL, "NAVI_CTRL")
            ApplyLayerLayoutFromIni(L_SYMBOL_NUM, "SYMBOL_NUM")
            ApplyLayerLayoutFromIni(L_SYMBOL1, "SYMBOL1")
            ApplyLayerLayoutFromIni(L_SYMBOL2, "SYMBOL2")
            ApplyLayerLayoutFromIni(L_SELECT, "SELECT")
            ApplyLayerLayoutFromIni(L_NUMPAD, "NUMPAD")
            return
        }
    }
    ChangeQwertyLayout()
}

/**
 * config.ini の指定されたセクションからレイアウト配列を読み込み、適用する
 * @param {String} name - レイアウト名（INIのセクション名）
 * @returns {Boolean} 読み込みに成功した場合は true
 */
ApplyLayoutFromIni(index) {
    ;ini_path := A_ScriptDir . "\config.ini"

    ; 必須のレイアウト文字列を取得
    name := ReadConfig(index, "Name", "")
    if name = ""
        return false
    layout := ReadConfig(index, "Layout", "")
    num := ReadConfig(index, "Num", "1234567890-")
    shift_layout := ReadConfig(index, "ShiftLayout", "")
    shift_num := ReadConfig(index, "ShiftNum", "")

    ; 基本レイアウトの設定
    StoreLayout(name, layout, num, shift_layout, shift_num)
    ResetIME() ; IME ON 時の個別設定を一旦リセット

    ; IME ON 時の個別設定があれば読み込む
    ime_layout := ReadConfig(name, "ImeLayout", "")
    ime_num := ReadConfig(name, "ImeNum", "")
    ime_shift_layout := ReadConfig(name, "ImeShiftLayout", "")
    ime_shift_num := ReadConfig(name, "ImeShiftNum", "")

    if (ime_layout != "" || ime_num != "" || ime_shift_layout != "" || ime_shift_num != "") {
        if (ime_layout == "")
            ime_layout := layout
        if (ime_num == "")
            ime_num := num
        StoreIMELayout(name, ime_layout, ime_num, ime_shift_layout, ime_shift_num)
    }

    ShowOSD("Loaded layout: " . name)
    return true
}

ReadLayoutTextFromIni(section, prefix) {
    layout := ReadConfig(section, prefix . "00", "")
    loop LAYOUT_KEYS.Length - 1 {
        str := ReadConfig(section, prefix . Format("{:02d}", A_Index), "")
        if str == ""
            break
        layout .= " " . str
    }
    return layout
}

class IniMap {
    __New(map, section, prefix := "") {
        this.map := map
        ;this.inipath := ini_path
        this.section := section
        this.prefix := prefix
    }

    Set(c) {
        key := EntryName(c)
        if key == "" {
            return
        }
        val := ReadConfig(this.section, this.prefix . key, "")
        ;val := IniRead(this.inipath, this.section, this.prefix . key, "")
        val := ResolveKeyText(val)
        if val != "" {
            this.map.Set(key, val)
        }
    }
}

/*
 * ini_pathのsectionのprefix+keyで記載されている値を
 * layout_mapに書き込む。
 * QWERTY_CHARS に含まれるキーについて順次読み込みを行う。
 * 特殊キーは個別に読み込む。
*/
ReadEachLayoutFromIni(layout_map, section, prefix := "") {
    ini_map_loader := IniMap(layout_map, section, prefix)
    for i, c in QWERTY_CHARS {
        ini_map_loader.Set(c)
    }
    ; 特殊キーの個別読み込み
    for i, c in LAYOUT_SPECIAL_NAMES {
        ini_map_loader.Set(c)
    }
}

ApplyLayoutFromIni2(section) {
    ; 必須のレイアウト文字列を取得
    name := ReadConfig(section, "Name", "")
    if (name == "")
        return false

    layout := ReadLayoutTextFromIni(section, "L")
    if (layout == "")
        layout_map := MakeLayoutMap("1234567890-^¥qwertyuiop@[asdfghjkl;:]zxcvbnm,./\")
    else
        layout_map := MakeLayoutMap(layout)
    ReadEachLayoutFromIni(layout_map, section, "")

    shift_layout := ReadLayoutTextFromIni(section, "S")
    if (shift_layout == "")
        shift_map := Map()
    else
        shift_map := MakeLayoutMap(shift_layout)
    ReadEachLayoutFromIni(shift_map, section, "s_")

    ; IME ON 時の個別設定があれば読み込む
    ime_layout := ReadLayoutTextFromIni(section, "I")
    if (ime_layout == "")
        ime_map := Map()
    else
        ime_map := MakeLayoutMap(ime_layout)
    ReadEachLayoutFromIni(ime_map, section, "i_")

    ime_shift_layout := ReadLayoutTextFromIni(section, "IS")
    if (ime_shift_layout == "")
        ime_shift_map := Map()
    else
        ime_shift_map := MakeLayoutMap(ime_shift_layout)
    ReadEachLayoutFromIni(ime_shift_map, section, "is_")

    layout_map.Default := ""
    shift_map.Default := ""
    ime_map.Default := ""
    ime_shift_map.Default := ""

    ; 基本レイアウトの設定
    StoreLayoutMap(name, layout_map, shift_map, ime_map, ime_shift_map)

    ShowOSD("Loaded layout: " . name)
    return true
}

/**
 * config.ini の指定されたセクションから、特定のレイヤー用のキー配列を読み込み適用する
 * @param {Integer} layer_id - レイヤー番号
 * @param {String} section - INIのセクション名
 */
ApplyLayerLayoutFromIni(layer_id, section) {
    ini_path := A_ScriptDir . "\config.ini"

    layout_text := ReadLayoutTextFromIni(section, "L")
    layout_map := (layout_text != "") ? MakeLayoutMap(layout_text) : Map()

    ReadEachLayoutFromIni(layout_map, section, "")

    for i, keyObj in LAYOUT_KEYS {
        name := EntryName(QWERTY_CHARS[i])

        ;layout_map[name]が"
        keyObj.SetLayerKey(layer_id, layout_map.Get(name, ""))
    }

    for i, keyObj in LAYOUT_SPECIAL_KEYS {
        name := EntryName(LAYOUT_SPECIAL_NAMES[i])
        keyObj.SetLayerKey(layer_id, layout_map.Get(name, ""))
    }

}

/**
 * 新しい IME-ON 時のキーレイアウトを保存・設定します
 * @param {String} name - レイアウト名
 * @param {String} layout - 新しい IME-ON 時のキー配列
 * @param {String} num_layout - 新しい IME-ON 時の数字列配列
 */
StoreIMELayout(name, layout := "qwertyuiopasdfghjkl;zxcvbnm,./", num_layout := "1234567890-", shift_layout := "",
    shift_num := "") {
    KeyLogger.ChangeLayout(name)
    if name != "" {
        try {
            WriteConfig(name, "Settings", "StartupLayout")
        } catch {
        }
    }

    l_num := LayoutString(num_layout), l_snum := LayoutString(shift_num)
    for i, keyObj in LAYOUT_NUM_KEYS {
        keyObj.SetIMEKey(l_num.GetElement(i), l_snum.GetElement(i))
    }
    l_char := LayoutString(layout), l_schar := LayoutString(shift_layout)
    for i, keyObj in LAYOUT_CHAR_KEYS {
        keyObj.SetIMEKey(l_char.GetElement(i), l_schar.GetElement(i))
    }
}

StoreIMELayout2(name, layout := "1234567890-^¥qwertyuiop@[asdfghjkl;:]zxcvbnm,./\", shift_layout := "") {
    KeyLogger.ChangeLayout(name)
    if name != "" {
        try {
            WriteConfig(name, "Settings", "StartupLayout")
        } catch {
        }
    }

    l := LayoutString(layout), ls := LayoutString(shift_layout)
    for i, keyObj in LAYOUT_KEYS {
        keyObj.SetIMEKey(l.GetElement(i), ls.GetElement(i))
    }
}

/**
 * 現在のキーレイアウトを指定された設定に保存・適用する
 * @param {String} name - レイアウト名
 * @param {String} layout - 保存するキーレイアウト
 * @param {String} num_layout - 保存する数字列レイアウト
 */
StoreLayout(name, layout, num_layout := "1234567890-", shift_layout := "", shift_num := "") {
    KeyLogger.SetLayoutName(name)
    if name != "" {
        try {
            WriteConfig(name, "Settings", "StartupLayout")
        } catch {
        }
    }

    l_num := LayoutString(num_layout), l_snum := LayoutString(shift_num)
    for i, keyObj in LAYOUT_NUM_KEYS {
        keyObj.SetKey(l_num.GetElement(i), l_snum.GetElement(i))
    }
    l_char := LayoutString(layout), l_schar := LayoutString(shift_layout)
    for i, keyObj in LAYOUT_CHAR_KEYS {
        keyObj.SetKey(l_char.GetElement(i), l_schar.GetElement(i))
    }
}

MakeLayoutMap(layout_str := "") {
    res_map := Map()
    if (layout_str == "") {
        return res_map
    }
    l := LayoutString(layout_str)
    for i, key in QWERTY_CHARS {
        res_map.Set(EntryName(key), l.GetElement(i))
    }
    return res_map
}

StoreLayout2(name, layout := "1234567890-^¥qwertyuiop@[asdfghjkl;:];zxcvbnm,./\", shift_layout := "") {
    ;KeyLogger.ChangeLayout(name)
    if name != "" {
        try {
            WriteConfig(name, "Settings", "StartupLayout")
        } catch {
        }
    }

    l := LayoutString(layout), ls := LayoutString(shift_layout)
    for i, keyObj in LAYOUT_KEYS {
        keyObj.SetKey(l.GetElement(i), ls.GetElement(i))
    }
}

StoreLayoutMap(name, layout_map, shift_map, ime_map, ime_shift_map) {
    if name != "" {
        try {
            WriteConfig(name, "Settings", "StartupLayout")
        } catch {
        }
    }
    global QWERTY_CHARS
    for i, keyObj in LAYOUT_KEYS {
        c := QWERTY_CHARS[i]
        key_text := EntryName(c)
        if (!layout_map.Has(key_text))
            layout_map[key_text] := ""
        if (!shift_map.Has(key_text))
            shift_map[key_text] := ""
        keyObj.SetKey(layout_map[key_text], shift_map[key_text])
    }
    ResetIME() ; IME ON 時の個別設定を一旦リセット

    for i, keyObj in LAYOUT_KEYS {
        c := QWERTY_CHARS[i]
        key_text := StrFromChar(c)
        if (!ime_map.Has(key_text))
            ime_map[key_text] := ""
        if (!ime_shift_map.Has(key_text))
            ime_shift_map[key_text] := ""
        keyObj.SetImeKey(ime_map[key_text], ime_shift_map[key_text])
    }
}

/**
 * キーレイアウトを「Qwerty配列」に変更する
 */
ChangeQwertyLayout() {
    StoreLayout("Qwerty", "qwertyuiopasdfghjkl;zxcvbnm,./")
    ResetIME()
    ShowOSD(KeyLogger.current_layout . " layout")
}

/**
 * キーレイアウトを「大西配列」に変更する
 */
ChangeOonishiLayout() {
    StoreLayout("Oonishi", "qlu,.fwrypeiao-ktnshzxcv;gdmjb", "1234567890/")
    ResetIME()
    ShowOSD(KeyLogger.current_layout . " layout")
}

/**
 * キーレイアウトを「Colemak配列」に変更する
 */
ChangeColemakLayout() {
    StoreLayout("Colemak", "qwfpgjluy;arstdhneiozxcvbkm,./")
    ResetIME()
    ShowOSD(KeyLogger.current_layout . " layout")
}

/**
 * Changes layout to "FMIX12f".
 */
ChangeFMIX12f_Layout() {
    StoreLayout("FMIX12f", "qwfrkylup;asdtghneiozxcvbjm,./")
    ResetIME()
    ShowOSD(KeyLogger.current_layout . " layout")
}

/**
 * Changes layout to "FMIX12f-FMIX13fR".
 */
ChangeFMIX12f_FMIX13fR_Layout() {
    StoreLayout("FMIX12f-13fR", "qwfrkylup;asdtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; IME ON 時の差分設定
    e.SetImeKey("d")
    t.SetImeKey("f")
    d.SetImeKey("k")

    ShowOSD(KeyLogger.current_layout . " layout")
}
/**
 * Changes layout to "FMIX14-FMIX14R".
 */
ChangeFMIX14_FMIX14R_Layout() {
    StoreLayout("FMIX14-14R", "qwldkylup;asrtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; IME ON 時の差分設定
    e.SetImeKey("r")
    t.SetImeKey("l")
    d.SetImeKey("k")

    ShowOSD(KeyLogger.current_layout . " layout")
}

/**
 * Changes layout to "FMIX13f-FMIX14fR".
 */
ChangeFMIX13f_FMIX14fR_Layout() {
    StoreLayout("FMIX13f-14fR", "qwrfkylup;asdtghneiozxcvbjm,./")
    ResetIME()

    global e, r, t, u, d

    ; IME ON 時の差分設定
    r.SetImeKey("d")
    t.SetImeKey("f")
    d.SetImeKey("k")

    ShowOSD(KeyLogger.current_layout . " layout")
}

ChangeMinatoLayoutImpl() {
    ResetIME()

    ; IME ON 時の差分設定
    q.SetImeKey("l", "?")
    w.SetImeKey("w")
    e.SetImeKey("r")
    r.SetImeKey("d")
    t.SetImeKey("f")
    a.SetImeKey("n", "(")
    s.SetImeKey("s", ")")
    d.SetImeKey("k")
    f.SetImeKey("t", "-")
    ;g.SetImeKey("h")
    z.SetImeKey("z", "[")
    x.SetImeKey("p", "]")
    c.SetImeKey("m")
    v.SetImeKey("h", "v")
    b.SetImeKey("b", "v")
    y.SetImeKey("ya")
    u.SetImeKey("yu")
    i.SetImeKey("u", "ou")
    o.SetImeKey("yo")
    p.SetImeKey("ou")
    h.SetImeKey(";", "ann") ; ;=nn
    j.SetImeKey("a", "ou")
    k.SetImeKey("i", "xi")
    l.SetImeKey("e", "xe")
    semicolon.SetImeKey("o", "ou")
    ;ToolTip semicolon.shift_ime_key_text " " semicolon.ime_key_text
    n.SetImeKey("-", "a-")
    m.SetImeKey("ya", "ltu") ; :=ltu
    ;slash.SetImeKey("f")
}

ChangeFMIX13_minato_Layout() {
    StoreLayout("FMIX13-Minato", "qwrlkyfup;asdtghneiozxcvbjm,./")
    ChangeMinatoLayoutImpl()
    ShowOSD(KeyLogger.current_layout . " layout")
}

ChangeFMIX13f_minato_Layout() {
    StoreLayout("FMIX13f-Minato", "qwrfkylup;asdtghneiozxcvbjm,./")
    ChangeMinatoLayoutImpl()
    ShowOSD(KeyLogger.current_layout . " layout")
}

ChangeFMIX13fie_minato_Layout() {
    StoreLayout("FMIX13fie-Minato", "qwrfkylup;asdtghnieozxcvbjm,./")
    ChangeMinatoLayoutImpl()
    ShowOSD(KeyLogger.current_layout . " layout")
}

; 終了・リロード時に保存
OnExit((*) => (KeyLogger.Save(), KeyLogger.SaveConfig()))

; ============================================================================
; 設定の読み込み
; ============================================================================
init() {
    start := Timer()
    for i, keyObj in LAYOUT_KEYS {
        keyObj.long_press_mode := 1
    }

    global k1, k2, k3, k4, k5, k6, k7, k8, k9, k0, minus, hat, yen
    global q, w, e, r, t, y, u, i, o, p, at, openbracket
    global a, s, d, f, g, h, j, k, l, semicolon, colon, closebracket
    global z, x, c, v, b, n, m, comma, period, slash, backslash

    global L_NAVI_CTRL, L_SYMBOL_NUM, L_SYMBOL1, L_SYMBOL2, L_SELECT, L_NUMPAD, L_SHIFT

    ; L_SELECT
    k1.SetLayerKey(L_SELECT, "^z")
    k2.SetLayerKey(L_SELECT, "^x")
    k3.SetLayerKey(L_SELECT, "^c")
    k4.SetLayerKey(L_SELECT, "^v")
    z.SetLayerKey(L_SELECT, "^z")
    x.SetLayerKey(L_SELECT, "^x")
    c.SetLayerKey(L_SELECT, "^c")
    v.SetLayerKey(L_SELECT, "^v")
    b.SetLayerKey(L_SELECT, "^z")
    y.SetLayerKey(L_SELECT, R_REDO)
    u.SetLayerKey(L_SELECT, C_BS)
    i.SetLayerKey(L_SELECT, "+{Up}")
    o.SetLayerKey(L_SELECT, "+{PgUp}")
    p.SetLayerKey(L_SELECT, "+{PgDn}")
    at.SetLayerKey(L_SELECT, C_CSHOME)
    openbracket.SetLayerKey(L_SELECT, C_CSEND)
    h.SetLayerKey(L_SELECT, "+{Home}")
    j.SetLayerKey(L_SELECT, "+{Left}")
    k.SetLayerKey(L_SELECT, "+{Down}")
    l.SetLayerKey(L_SELECT, "+{Right}")
    semicolon.SetLayerKey(L_SELECT, "+{Enter}")
    enter.SetLayerKey(L_SELECT, B_ENTER)
    n.SetLayerKey(L_SELECT, "+{End}")
    m.SetLayerKey(L_SELECT, C_DEL)
    comma.SetLayerKey(L_SELECT, "^+{Left}")
    period.SetLayerKey(L_SELECT, "^+{Right}")
    space.SetLayerKey(L_SELECT, C_BS)
    up.SetLayerKey(L_SELECT, "+{Up}")
    left.SetLayerKey(L_SELECT, "+{Left}")
    down.SetLayerKey(L_SELECT, "+{Down}")
    right.SetLayerKey(L_SELECT, "+{Right}")

    ; L_NAVI_CTRL
    k1.SetLayerKey(L_NAVI_CTRL, B_F1)
    k2.SetLayerKey(L_NAVI_CTRL, B_F2)
    k3.SetLayerKey(L_NAVI_CTRL, B_F3)
    k4.SetLayerKey(L_NAVI_CTRL, B_F4)
    k5.SetLayerKey(L_NAVI_CTRL, B_F5)
    k6.SetLayerKey(L_NAVI_CTRL, B_F6)
    k7.SetLayerKey(L_NAVI_CTRL, B_F7)
    k8.SetLayerKey(L_NAVI_CTRL, B_F8)
    k9.SetLayerKey(L_NAVI_CTRL, B_F9)
    k0.SetLayerKey(L_NAVI_CTRL, B_F10)
    minus.SetLayerKey(L_NAVI_CTRL, B_F11)
    hat.SetLayerKey(L_NAVI_CTRL, B_F12)
    yen.SetLayerKey(L_NAVI_CTRL, "^+{sc07D}")
    z.SetLayerKey(L_NAVI_CTRL, B_UNDO)
    x.SetLayerKey(L_NAVI_CTRL, B_CUT)
    c.SetLayerKey(L_NAVI_CTRL, B_COPY)
    v.SetLayerKey(L_NAVI_CTRL, B_PASTE)
    b.SetLayerKey(L_NAVI_CTRL, B_UNDO)
    y.SetLayerKey(L_NAVI_CTRL, B_UNDO)
    u.SetLayerKey(L_NAVI_CTRL, B_BS)
    i.SetLayerKey(L_NAVI_CTRL, B_UP)
    o.SetLayerKey(L_NAVI_CTRL, B_PGUP)
    p.SetLayerKey(L_NAVI_CTRL, B_PGDN)
    at.SetLayerKey(L_NAVI_CTRL, B_CHOME)
    openbracket.SetLayerKey(L_NAVI_CTRL, B_CEND)
    h.SetLayerKey(L_NAVI_CTRL, B_HOME)
    j.SetLayerKey(L_NAVI_CTRL, B_LEFT)
    k.SetLayerKey(L_NAVI_CTRL, B_DOWN)
    l.SetLayerKey(L_NAVI_CTRL, B_RIGHT)
    semicolon.SetLayerKey(L_NAVI_CTRL, B_ENTER)
    closebracket.SetLayerKey(L_NAVI_CTRL, "^+{sc07D}")
    n.SetLayerKey(L_NAVI_CTRL, B_END)
    m.SetLayerKey(L_NAVI_CTRL, B_DEL)
    comma.SetLayerKey(L_NAVI_CTRL, B_CLEFT)
    period.SetLayerKey(L_NAVI_CTRL, B_CRIGHT)
    slash.SetLayerKey(L_NAVI_CTRL, "^+{sc07D}")
    enter.SetLayerKey(L_NAVI_CTRL, "{Blind}^{Enter}")
    a.SetLayerKey(L_NAVI_CTRL, "{Blind}^a")

    ; L_SYMBOL_NUM
    k1.SetLayerKey(L_SYMBOL_NUM, B_F1)
    k2.SetLayerKey(L_SYMBOL_NUM, B_F2)
    k3.SetLayerKey(L_SYMBOL_NUM, B_F3)
    k4.SetLayerKey(L_SYMBOL_NUM, B_F4)
    k5.SetLayerKey(L_SYMBOL_NUM, B_F5)
    k6.SetLayerKey(L_SYMBOL_NUM, B_F6)
    k7.SetLayerKey(L_SYMBOL_NUM, B_F7)
    k8.SetLayerKey(L_SYMBOL_NUM, B_F8)
    k9.SetLayerKey(L_SYMBOL_NUM, B_F9)
    k0.SetLayerKey(L_SYMBOL_NUM, B_F10)
    minus.SetLayerKey(L_SYMBOL_NUM, B_F11)
    hat.SetLayerKey(L_SYMBOL_NUM, B_F12)
    q.SetLayerKey(L_SYMBOL_NUM, "?")
    w.SetLayerKey(L_SYMBOL_NUM, "{Blind}/")
    e.SetLayerKey(L_SYMBOL_NUM, B_NMUL)
    r.SetLayerKey(L_SYMBOL_NUM, B_NADD)
    t.SetLayerKey(L_SYMBOL_NUM, "+F3")
    a.SetLayerKey(L_SYMBOL_NUM, "(")
    s.SetLayerKey(L_SYMBOL_NUM, ")")
    d.SetLayerKey(L_SYMBOL_NUM, "_")
    f.SetLayerKey(L_SYMBOL_NUM, "{Blind}-")
    g.SetLayerKey(L_SYMBOL_NUM, "=")
    y.SetLayerKey(L_SYMBOL_NUM, B_BS)
    u.SetLayerKey(L_SYMBOL_NUM, C_N7)
    i.SetLayerKey(L_SYMBOL_NUM, C_N8)
    o.SetLayerKey(L_SYMBOL_NUM, C_N9)
    p.SetLayerKey(L_SYMBOL_NUM, "+^p")
    h.SetLayerKey(L_SYMBOL_NUM, "=")
    j.SetLayerKey(L_SYMBOL_NUM, C_N0)
    k.SetLayerKey(L_SYMBOL_NUM, C_N1)
    l.SetLayerKey(L_SYMBOL_NUM, C_N2)
    semicolon.SetLayerKey(L_SYMBOL_NUM, B_ENTER)
    n.SetLayerKey(L_SYMBOL_NUM, "+3")
    m.SetLayerKey(L_SYMBOL_NUM, C_N3)
    comma.SetLayerKey(L_SYMBOL_NUM, C_N4)
    period.SetLayerKey(L_SYMBOL_NUM, C_N5)
    slash.SetLayerKey(L_SYMBOL_NUM, C_N6)
    z.SetLayerKey(L_SYMBOL_NUM, "[")
    x.SetLayerKey(L_SYMBOL_NUM, "]")
    c.SetLayerKey(L_SYMBOL_NUM, "+[")
    v.SetLayerKey(L_SYMBOL_NUM, "+]")
    b.SetLayerKey(L_SYMBOL_NUM, C_BACKSLASH)
    space.SetLayerKey(L_SYMBOL_NUM, B_BS)

    ; L_SYMBOL1
    k1.SetLayerKey(L_SYMBOL1, B_F1)
    k2.SetLayerKey(L_SYMBOL1, B_F2)
    k3.SetLayerKey(L_SYMBOL1, B_F3)
    k4.SetLayerKey(L_SYMBOL1, B_F4)
    k5.SetLayerKey(L_SYMBOL1, B_F5)
    k6.SetLayerKey(L_SYMBOL1, B_F6)
    k7.SetLayerKey(L_SYMBOL1, B_F7)
    k8.SetLayerKey(L_SYMBOL1, B_F8)
    k9.SetLayerKey(L_SYMBOL1, B_F9)
    k0.SetLayerKey(L_SYMBOL1, B_F10)
    minus.SetLayerKey(L_SYMBOL1, B_F11)
    hat.SetLayerKey(L_SYMBOL1, B_F12)
    q.SetLayerKey(L_SYMBOL1, "?")
    w.SetLayerKey(L_SYMBOL1, "{Blind}/")
    e.SetLayerKey(L_SYMBOL1, B_NMUL)
    r.SetLayerKey(L_SYMBOL1, B_NADD)
    t.SetLayerKey(L_SYMBOL1, "+F3")
    a.SetLayerKey(L_SYMBOL1, "(")
    s.SetLayerKey(L_SYMBOL1, ")")
    d.SetLayerKey(L_SYMBOL1, "_")
    f.SetLayerKey(L_SYMBOL1, "{Blind}-")
    g.SetLayerKey(L_SYMBOL1, "=")
    y.SetLayerKey(L_SYMBOL1, B_BS)
    u.SetLayerKey(L_SYMBOL1, C_N7)
    i.SetLayerKey(L_SYMBOL1, C_N8)
    o.SetLayerKey(L_SYMBOL1, C_N9)
    p.SetLayerKey(L_SYMBOL1, "+^p")
    h.SetLayerKey(L_SYMBOL1, "=")
    j.SetLayerKey(L_SYMBOL1, C_N0)
    k.SetLayerKey(L_SYMBOL1, C_N1)
    l.SetLayerKey(L_SYMBOL1, C_N2)
    semicolon.SetLayerKey(L_SYMBOL1, B_ENTER)
    n.SetLayerKey(L_SYMBOL1, "+3")
    m.SetLayerKey(L_SYMBOL1, C_N3)
    comma.SetLayerKey(L_SYMBOL1, C_N4)
    period.SetLayerKey(L_SYMBOL1, C_N5)
    slash.SetLayerKey(L_SYMBOL1, C_N6)
    z.SetLayerKey(L_SYMBOL1, "+[")
    x.SetLayerKey(L_SYMBOL1, "+]")
    c.SetLayerKey(L_SYMBOL1, "[")
    v.SetLayerKey(L_SYMBOL1, "]")
    b.SetLayerKey(L_SYMBOL1, C_BACKSLASH)
    space.SetLayerKey(L_SYMBOL1, C_BS)

    ; L_NUMPAD
    k6.SetLayerKey(L_NUMPAD, "{Escape}")
    t.SetLayerKey(L_NUMPAD, B_NADD)
    a.SetLayerKey(L_NUMPAD, "(")
    s.SetLayerKey(L_NUMPAD, ")")
    f.SetLayerKey(L_NUMPAD, "-")
    g.SetLayerKey(L_NUMPAD, "=")
    k7.SetLayerKey(L_NUMPAD, C_N7)
    k8.SetLayerKey(L_NUMPAD, C_N8)
    k9.SetLayerKey(L_NUMPAD, C_N9)
    k0.SetLayerKey(L_NUMPAD, B_NMUL)
    minus.SetLayerKey(L_NUMPAD, B_NSUB)
    hat.SetLayerKey(L_NUMPAD, C_HAT)
    yen.SetLayerKey(L_NUMPAD, "\")
    y.SetLayerKey(L_NUMPAD, C_BS)
    u.SetLayerKey(L_NUMPAD, C_N4)
    i.SetLayerKey(L_NUMPAD, C_N5)
    o.SetLayerKey(L_NUMPAD, C_N6)
    p.SetLayerKey(L_NUMPAD, B_NADD)
    at.SetLayerKey(L_NUMPAD, B_UP)
    h.SetLayerKey(L_NUMPAD, "=")
    j.SetLayerKey(L_NUMPAD, C_N1)
    k.SetLayerKey(L_NUMPAD, C_N2)
    l.SetLayerKey(L_NUMPAD, C_N3)
    semicolon.SetLayerKey(L_NUMPAD, B_LEFT)
    colon.SetLayerKey(L_NUMPAD, B_DOWN)
    closebracket.SetLayerKey(L_NUMPAD, B_RIGHT)
    n.SetLayerKey(L_NUMPAD, C_DEL)

    ; L_SYMBOL2
    q.SetLayerKey(L_SYMBOL2, "+1")
    w.SetLayerKey(L_SYMBOL2, "+2")
    e.SetLayerKey(L_SYMBOL2, "+3")
    r.SetLayerKey(L_SYMBOL2, "+4")
    t.SetLayerKey(L_SYMBOL2, "+5")
    a.SetLayerKey(L_SYMBOL2, "+6")
    s.SetLayerKey(L_SYMBOL2, "+7")
    d.SetLayerKey(L_SYMBOL2, C_HAT)
    g.SetLayerKey(L_SYMBOL2, "+@")
    z.SetLayerKey(L_SYMBOL2, "~")
    x.SetLayerKey(L_SYMBOL2, "@")
    c.SetLayerKey(L_SYMBOL2, ":")
    v.SetLayerKey(L_SYMBOL2, "|")
    b.SetLayerKey(L_SYMBOL2, "\")

    ; L_FUNC
    q.SetLayerKey(L_SYMBOL2, B_F1)
    w.SetLayerKey(L_SYMBOL2, B_F2)
    e.SetLayerKey(L_SYMBOL2, B_F3)
    r.SetLayerKey(L_SYMBOL2, B_F4)
    a.SetLayerKey(L_SYMBOL2, B_F5)
    s.SetLayerKey(L_SYMBOL2, B_F6)
    d.SetLayerKey(L_SYMBOL2, B_F7)
    f.SetLayerKey(L_SYMBOL2, B_F8)
    z.SetLayerKey(L_SYMBOL2, B_F9)
    x.SetLayerKey(L_SYMBOL2, B_F10)
    c.SetLayerKey(L_SYMBOL2, B_F11)
    v.SetLayerKey(L_SYMBOL2, B_F12)

    ; L_SHIFT
    ; for i, keyObj in LAYOUT_KEYS {
    ;     keyObj.SetLayerKey(L_SHIFT, keyObj.shift_key_text)
    ; }
    k1.SetLayerKey(L_SHIFT, B_F1)
    k2.SetLayerKey(L_SHIFT, B_F2)
    k3.SetLayerKey(L_SHIFT, B_F3)
    k4.SetLayerKey(L_SHIFT, B_F4)
    k5.SetLayerKey(L_SHIFT, B_F5)
    k6.SetLayerKey(L_SHIFT, B_F6)
    k7.SetLayerKey(L_SHIFT, B_F7)
    k8.SetLayerKey(L_SHIFT, B_F8)
    k9.SetLayerKey(L_SHIFT, B_F9)
    k0.SetLayerKey(L_SHIFT, B_F10)
    minus.SetLayerKey(L_SHIFT, B_F11)
    hat.SetLayerKey(L_SHIFT, B_F12)
    colon.SetLayerKey(L_SHIFT, "+sc028")
    closebracket.SetLayerKey(L_SHIFT, "+]")

    LoadLayoutConfig()
    KeyLogger.Load()

    end := Timer()
    ShowOSD(Format("{} layout(init:{:.1f}ms)", KeyLogger.current_layout, end - start), 5000)
}

init()

/**
 * 特定のモディファイアレイヤー（M1〜M6）がアクティブかどうかを判定します。
 * 他のレイヤーが同時にアクティブでないことも確認します。
 * @param {Integer} layer - 確認するレイヤー番号
 * @returns {Boolean} 指定されたレイヤーのみがアクティブな場合は true
 */
LayerState(layer) {
    ; Check the specified layer
    if layer = L_NAVI_CTRL {
        return f13.IsPressed() && !(GetKeyState("Alt", "P") || GetKeyState(R_NOCONV, "P"))
    }
    if layer = L_SYMBOL1 {
        return conv.IsPressed()
    }
    if layer = L_SYMBOL2 {
        return f14.IsPressed()
    }
    if layer = L_SYMBOL_NUM {
        return noconv.IsPressed() && !(GetKeyState("F13", "P") || GetKeyState("Alt", "P"))
    }
    if layer = L_NUMPAD {
        return tab.IsPressed()
    }
    if layer = L_SELECT {
        return f13.IsPressed() && (GetKeyState("Alt", "P") || GetKeyState(R_NOCONV, "P"))
    }
    if layer = L_SHIFT {
        return space.IsPressed()
    }
    ; if layer = L_FUNC {
    ;     return f14.IsPressed()
    ; }
    return false
}
; ============================================================================
; ホットキー定義（レイヤー）
; ============================================================================
;*** レイヤー（システム/アプリ制御） ***
#HotIf LayerState(L_NAVI_CTRL)

sc029:: Send(C_EISU) ; Zen/Han -> Eisu
*Enter:: enter.SendLayerKey(L_NAVI_CTRL) ; Enter -> Ctrl+Enter

Esc:: {
    KeyLogger.Save()
    KeyLogger.SaveConfig()
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
; --- レイアウト切り替え ---
#r:: ChangeFMIX14_FMIX14R_Layout()
;#d:: ChangeFMIX12f_Layout()
#s:: ChangeFMIX13f_FMIX14fR_Layout()
#m:: ChangeFMIX13f_minato_Layout()
#n:: ChangeFMIX13fie_minato_Layout()
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
#sc033:: KeyLogger.ToggleImeIndicator()
#.:: KeyLogger.ToggleLogging()
#h:: ShowOSD("Help`n"
    . "Shift+全角/半角: 英数`n"
    . "Win+Alt+Enter: スクリプトの一時停止を切り替え`n"
    . "Win+M1+f: 強制IMEモードのON/OFF 切り替え`n"
    . "Win+M1+Up: マウス速度を上げる`n"
    . "Win+M1+Down: マウス速度を下げる`n"
    . "Win+M1+,: IMEインジケータの表示/非表示を切り替え`n"
    . "Win+M1+.: キーロガーのOn/Offを切り替`n"
    . "==記号レイヤ1==  ==記号レイヤ2==`n"
    . "|?|/|*|+| |    |!|`"|#|$|%|`n"
    . "|(|)|_|-|=|    |&&|`'|^| |``|`n"
    . "|{|}|[|]|\|    |~|@|:|||\|`n"
    , 3000, True)
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
; --- サスペンド（一時停止）ホットキー ---
#SuspendExempt ; 一時停止中でもサスペンドホットキーが動作するように許可
#!Enter:: Suspend ; Win+Alt+Enter でスクリプトの一時停止を切り替え
#SuspendExempt False
#MaxThreadsBuffer False