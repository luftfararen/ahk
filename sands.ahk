#Requires AutoHotkey v2.0

; ============================================================================
; スクリプト概要
; ============================================================================
; このスクリプトは、AutoHotkey v2 用の高度なキーカスタマイズを提供します。
; 主な機能:
; 1. センターモディファイア (MKey): Space、Enter、無変換などのキーを、
;    短押し（タップ）では通常のキーとして、長押しではモディファイアキー
;    （レイヤー切り替え）として機能させます。
; 2. キーリマップ (RKey): キーをリマップし、Shift押下状態、IMEのON/OFF状態
;    に応じて異なる挙動を設定できます。
; 3. 長押しキー (LKey): RKey を拡張し、キーの長押しに別の機能を割り当てます
;    （例：短押しで ';'、長押しで ':'）。
; 4. キーレイヤー (#HotIf): MKey を使用して、複数のキーボードレイヤー
;    （ナビゲーション、テンキー、記号レイヤーなど）を作成します。
; 5. レイアウト切り替え: キーボードレイアウト（Colemak, FMIX, 大西配列など）
;    を動的に変更する関数。
; 6. IME制御: IMEの状態を取得、設定、切り替える関数。
; 7. マウス速度制御: ホットキーを使用してシステムのマウス速度を調整するクラス。
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

; --- バックスラッシュ/円キー (\) ---
;R_BACKSLASH := "sc07D"
C_YEN := "{sc07D}"
B_YEN := "{Blind}{sc07D}"

; --- アンダースコアキー (\) ---
;R_backslash := "sc073"
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
B_TAB := "{Blind}{Tab}"

R_SPACE := "Space"
;C_SPACE := "{Space}"
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
; スクリプト設定
; ============================================================================
;SingleInstance Force ;（コメントアウト）複数インスタンスを許可
ProcessSetPriority "Realtime" ; 最高の応答性を確保するため優先度をリアルタイムに設定
SendMode "Input" ; 速度と信頼性のため "Input" モードを使用

InstallKeybdHook true ; キーボードフックを常にインストール
InstallMouseHook true ; マウスフックを常にインストール（MouseSpeedクラス用）
#UseHook true ; ホットキーにフックの使用を強制
#MaxThreadsBuffer True ; 中断された場合にホットキーをバッファリングする
;#MaxThreadsPerHotkey 3 ;（コメントアウト）ホットキーあたりのスレッド数を制限
SetKeyDelay 0 ; キー入力後のディレイをなしに設定

KeyLogger.Load()
; 終了・リロード時に保存
OnExit((*) => (KeyLogger.Save(), KeyLogger.SaveConfig()))

; ============================================================================
; GLOBAL FUNCTIONS
; ============================================================================

shift_lambda := () => GetKeyState("Shift", "P")

/**
 * Shiftキーが物理的に押されているかを取得する
 * @returns {Boolean} Shiftが押されていれば true
 */
IsPhysicalShiftPressed() {
    global shift_lambda
    return shift_lambda()
}

Timer() {
    DllCall("QueryPerformanceFrequency", "Int64*", &freq := 0)
    DllCall("QueryPerformanceCounter", "Int64*", &tick := 0)
    return tick / freq
}

/**
 * アクティブなウィンドウまたはフォーカスされているコントロールのハンドル (HWND) を取得する
 * 正確な IME 状態の検出に必要
 * @returns {Ptr} ウィンドウハンドル (HWND)
 */
GetFocusedControlHandle() {
    static ptrSize := A_PtrSize
    static cbSize := 4 + 4 + (ptrSize * 6) + 16
    static stGTI := Buffer(cbSize, 0)

    hwnd := WinExist("A")
    if hwnd {
        NumPut("UInt", cbSize, stGTI, 0)
        if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", stGTI) {
            hwnd := NumGet(stGTI, 8 + ptrSize, "UInt")
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

QueryPerformanceFrequency() {
    DllCall("QueryPerformanceFrequency", "Int64*", &freq := 0)
    return freq
}

QueryPerformanceCounter() {
    DllCall("QueryPerformanceCounter", "Int64*", &tick := 0)
    return tick
}

; よく使う記号のスキャンコードを文字に変換(;:,.¥_\)
sc_to_char_map := Map("sc027", ";", "sc028", ":", "sc033", ",", "sc034", ".", "sc035", "/", "sc07D", "¥",
    "sc073", "\", "sc00D", "^")

; 記号をスキャンコードに変換
char_to_sc_map := Map(";", "sc027", ":", "sc028", ",", "sc033", ".", "sc034", "/", "sc035", "¥", "sc07D",
    "\", "sc073", "^", "sc00D")

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
    static config_file := A_ScriptDir . "\config.ini"
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
            val := IniRead(this.config_file, "Settings", "LogEnabled", "0")
            this.is_logging_enabled := (val == "1")
        } catch {
            this.is_logging_enabled := false
        }
        try {
            val := IniRead(this.config_file, "Settings", "ImeIndicatorEnabled", "1")
            this.is_showing_ime_indicator := (val == "1")
        } catch {
            this.is_showing_ime_indicator := true
        }
        try {
            this.max_log := Integer(IniRead(this.config_file, "Settings", "MaxLog", "5000"))
        } catch {
            this.max_log := 2000
        }
    }

    /**
     * 設定をファイルに保存する
     */
    static SaveConfig() {
        try {
            IniWrite(this.is_logging_enabled ? "1" : "0", this.config_file, "Settings", "LogEnabled")
            IniWrite(this.is_showing_ime_indicator ? "1" : "0", this.config_file, "Settings", "ImeIndicatorEnabled")
            IniWrite(String(this.max_log), this.config_file, "Settings", "MaxLog")
            IniWrite(String(LKey.long_press_th), this.config_file, "Settings", "long_press_th")
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

        loop this.stats_short_idx {
            entry := this.stats_short[A_Index]
            char := entry.c
            tick := entry.t

            ; {Blind} や {sc033} のような括弧付き文字列のパース
            if InStr(char, "{") {
                if SubStr(char, 1, 7) = "{Blind}"
                    char := SubStr(char, 8) ; {Blind} を除去

                if InStr(char, "{") { ; さらに括弧が含まれるか ({Enter} 等)
                    if SubStr(char, 1, 3) = "{sc" && SubStr(char, -1) = "}"
                        char := SubStr(char, 2, -1) ; {sc033} を sc033 に"
                    else {
                        char := " "
                        ;continue ; 記録対象外の特殊キー ({Enter} 等) は無視
                    }
                }
            }

            ; よく使う記号のスキャンコードを文字に変換
            char := char_to_sc_map.Get(char, char)

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

class LayoutString {
    arr := []

    __New(layoutStr) {
        this.layoutStr := layoutStr

        if this.layoutStr = ""
            return
        if InStr(this.layoutStr, " ") {
            ; 複数の連続するスペースを一つとしてパース
            this.arr := StrSplit(RegExReplace(Trim(this.layoutStr), " +", " "), " ")
        } else {
            this.arr := StrSplit(this.layoutStr)
        }
    }

    GetElement(index) {
        if index <= this.arr.Length
            return this.arr[index]
        return ""
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
    static autoSuspended := false
    if WinActive("ahk_group RemoteDesktops") {
        if !A_IsSuspended {
            Suspend(true)
            autoSuspended := true
        }
    } else {
        if autoSuspended {
            Suspend(false)
            autoSuspended := false
        }
    }
    return autoSuspended
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

    MyGui := Gui("+AlwaysOnTop +ToolWindow -Caption +Disabled")
    MyGui.BackColor := "333333"
    MyGui.SetFont("s12 cWhite w700", "Consolas")

    ; テキスト周囲の余白
    MyGui.MarginX := 20
    MyGui.MarginY := 15

    ; 改行を含むテキストを中央寄せで表示
    MyGui.Add("Text", "Center", text)
    MyGui.Show("NoActivate xCenter y900") ; 画面下部中央に表示

    if key_close {
        ; 全てのキーが離された状態（物理的に何も押されていない状態）になったら閉じる
        fn_close(*) {
            SetTimer(CheckNoKeys, 0)
            try MyGui.Destroy()
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
        SetTimer(() => (MyGui.Destroy()), -duration)
    }
}

; --- 設定 ---
ColorJapanese := "Red"
DotSize := 8
; ------------

; キャレット表示用のGUI作成
; 描画用のウィンドウ（GUI）作成
MGui := Gui("+AlwaysOnTop -Caption +ToolWindow +LastFound -DPIScale")
MGui.BackColor := ColorJapanese
WinSetRegion("0-0 w" DotSize " h" DotSize " Ellipse", MGui)

;DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr") ; DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2

/**
 * マウスカーソル付近に IME 状態を示すインジケータ（ドット）を表示・更新する
 */
UpdateImeIndicator(precise := False) {
    static LastStatus := -1 ;-1:初期状態, 0:オフ, 1:オン, 2:強制オン

    if !KeyLogger.is_showing_ime_indicator {
        if LastStatus != 0 {
            MGui.Hide()
            LastStatus := 0
        }
        return
    }

    mx := -1, my := 0
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    static LastX := -2, LastY := 0

    if (mx = LastX && my = LastY) {
        ime_state_value := 0
        if ImeState.IsOn(precise) {
            ime_state_value := ImeState.force_ime_on ? 2 : 1
        }

        if ime_state_value > 0 {
            if ime_state_value != LastStatus {
                MGui.BackColor := (ime_state_value == 2) ? "Green" : ColorJapanese
                MGui.Show("x" (mx + 36) " y" (my + 36) " w" DotSize " h" DotSize " NoActivate")
            }
        } else {
            ; 既に非表示の場合は Hide しない（余計な負荷削減）
            if LastStatus != 0 {
                MGui.Hide()
            }
        }
        LastStatus := ime_state_value
    } else {   ; マウスが動いて位置が変更された場合
        if LastStatus != -1 {
            MGui.Hide()
        }
        LastX := mx
        LastY := my
        LastStatus := -1
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
    static DefMouseSpeed := 10

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
class MKey {
    /**
     * コンストラクタ
     * @param {String} key - 監視するキー (例: "SPACE", "sc07B")。"{...}" 形式でも可。
     * @param {Integer} [timeout=180] - 短押しと長押しを判別する時間 (ms)。
     */
    __New(key, timeout := 180) {
        if key = "" { ; F13のような「仮想」モディファイア用
            this.key_str := ""
            this.key := key ; 登録されたキー
        } else {
            this.key := removeBraces(key)
            this.key_str := addBraces(key)
        }
        this.pressed_time := 0 ; 0 = 押されていない, >0 = 押し下げ開始時間
        this.mod_str := ""     ; 押下時に保持されていた他の修飾キーを保存 (例: "+^")
        this.timeout := timeout
    }
    /**
     * キーが現在「押し下げ」状態（Down()が呼ばれた）かどうかを確認する
     * @returns {Boolean} 押されていれば true
     */
    IsPressed() => (this.pressed_time != 0)
    ;IsPressed() => GetKeyState(this.key_str, "P")

    /**
     * このキーが押された瞬間の他の修飾キー（Shift, Ctrl, Alt, Win）の状態を保存する
     */
    SetModStr() {
        this.mod_str := MakeModStr()
    }

    /**
     * キー押し下げ時のホットキーで呼び出す (例: `*Space::space.Down()`)
     * @returns {Boolean} 既に押し下げ済みであれば false (キーリピート防止)、そうでなければ true
     */
    Down() {
        Critical
        if this.pressed_time != 0 { ; 既に押し下げ処理中のため無視
            return false
        }
        this.pressed_time := A_TickCount ; 押し下げ時間を記録
        this.SetModStr()                 ; 他の修飾キーを記録
        return true
    }

    /**
     * キー離し時のホットキーで呼び出す (例: `*Space up::space.Up()`)
     * 短押しだった場合は元のキー（修飾キー付き）を送信します。
     */
    Up() {
        Critical
        if (A_TickCount - this.pressed_time < this.timeout) {
            SendAndLog("{Blind}" . this.mod_str . this.key_str)
        }
        this.pressed_time := 0
    }

    /**
     * キーの押し下げ状態を強制的にリセットする
     */
    Reset() {
        this.pressed_time := 0
    }
} ;class MKey

/**
 * 文字列に波括弧を追加する
 * @param {String} str - 文字列
 * @returns {String} 波括弧で囲まれた文字列
 */
addBraces(str) {
    if RegExMatch(str, "^\{.*\}$") {
        return str
    }
    return "{" . str . "}"
}

removeBraces(str) {
    if RegExMatch(str, "^\{.*\}$") {
        return SubStr(str, 2, StrLen(str) - 2)
    }
    return str
}

/**
 * 指定されたキー文字列に修飾記号が含まれているかを確認するヘルパー関数
 * @param {String} text - キー文字列 (例: "^c", "{Blind}a")
 * @returns {Boolean} 修飾記号が含まれていれば true
 */
HasModifierSymbols(text) {
    list := ["{Blind}", "+", "#", "^", "!"]
    for index, item in list {
        if InStr(text, item, 'Off') > 0 {
            return true
        }
    }
    return false
}

/**
 * キー送信用の文字列を生成し、必要に応じて {Blind} 接頭辞を付与する。
 * 
 * 【入力文字列の仕様】
 * 1. 単独の文字 (例: "a") -> "{Blind}a"
 * 2. 特殊記号を含む文字列 (例: "+a", "{Blind}s") -> そのまま返す
 * 3. キー名/スキャンコード (例: "{space}", "{sc027}") -> "{Blind}{space}"
 * 4. プレフィックス指定 (例: prefix="+", text="a") -> "{Blind}+a"
 * 
 * @param {String} text - 変換対象のキー文字列
 * @param {String} [prefix=""] - キー名の前に付与する接頭辞 (例: "+" で Shift)
 * @returns {String} {Blind} が付与された（またはそのままの）キー送信文字列
 */
MakeBlindKeyText(text, prefix := "") {
    if text = ""
        return ""
    has_mod := HasModifierSymbols(text)
    if StrLen(text) == 1
        return has_mod ? text : "{Blind}" . prefix . text
    else
        if has_mod
            return text
    return SubStr(text, 1, 1) == "{" && SubStr(text, -1) == "}" ? "{Blind}" . prefix . text : text
}

/*============================================================================
 [Class] RKey (リマップキー)
 キーリマップを管理し、Shift、IME ON/OFF の状態に応じて異なる出力を処理します。
登録する文字列は、MakeTextKeyのコメントを参照
============================================================================*/
class RKey {
    static use_registered_key_for_ctrl := false ; (未使用？) ctrl または alt 用
    static last_key := ""
    /**
     * コンストラクタ
     * @param {String} key - デフォルトキー(物理キー) (例: "a", "{sc027}")
     * @param {String} [shift_key=""] - Shift 押下時に送信するキー
     *                                 "" = 自動生成 (例: "+a")
     */
    __New(key) {
        this.org_key := addBraces(key)
        this.org_key_bare := removeBraces(key)
        this.shift_key_text := ""     ; (IME OFF) Shift 時のキー
        this.shift_ime_key_text := "" ; (IME ON) Shift 時のキー
        this.SetKey(key)   ; IME OFF 時のキーを設定
        this.SetImeKey(key) ; IME ON 時のキーを設定 (デフォルトは OFF 時と同じ)
    }

    /**
     * IME OFF 時のキーマッピングを設定する
     * @param {String} key -  登録する文字列
     * @param {String} [shift_key=""] - Shift 時の登録する文字列。
     */
    SetKey(key, shift_key := "") {
        this.key := key
        this.key_text := MakeBlindKeyText(key)
        this.shift_key_text := shift_key == "" ? MakeBlindKeyText(key, "+") : MakeBlindKeyText(shift_key)
    }

    /**
     * IME ON 時のキーマッピングを設定する
     * @param {String} [key=""] - IME ON 時の基本キー（復数文字可）。空白の場合は IME OFF 時と同じ。
     * @param {String} [shift_key=""] - IME ON 時の Shift キー（復数文字可）
     *                                 "" = 自動/デフォルト、"none" = 無効化。
     */
    SetImeKey(key := "", shift_key := "") {
        this.ime_key_text := key = "" ? this.key_text : MakeBlindKeyText(key)
        this.shift_ime_key_text := shift_key = "" ? MakeBlindKeyText(key, "+") : MakeBlindKeyText(shift_key)
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
     * キー押し下げ時のホットキーで呼び出す (例: `*x::x.Down("x")`)
     */
    Down() {
        Critical
        RKey.last_key := this._SendSCAWKey(this.org_key) ? "" : this.org_key
    }

    /**
     * キー離し時のホットキーで呼び出す (例: `*x up::x.Up()`)
     * (RKey では未使用だが、LKey で継承されるため定義)
     */
    Up() {
    }
} ;class RKey

/*============================================================================
 [Class] LKey (長押しキー)
 RKey を拡張し、「長押し」アクションを追加します。

[mode]
0:RKeyと同じ（長押し無効）
1:Down時に即送信し長押しでShift版に置換、送信されるキーは登録キー
2:長押しは未送信(Modifier専用)
3:長押しは未送信(MKeyと同じ)、単押しのときはデフォルトキー
(予約)4:長押しは未送信(MKeyと同じ)、単押しのときはデフォルトキー
(予約)5:Down時に登録キーを即送信し、長押しで長押し登録キーに置換

1,2,3,4,5はキーリピートが無効化
0,1,2,4,5はCtrl,Alt,Win(CAW)の押下時はデフォルトキーに対する修飾として送信
* デフォルトキー:コンストラタで登録したキーで通常はqwertyが登録されている
 ただし、変換キーなどの特殊キーには、物理的なキーとは別なキーを割り当てている場合があるので注意が必要
* 登録キー: RKeyと同様SetKey,SetImeKeyで設定する
* (予約)長押し登録キー: SetLongKey,SetLongImeKeyで設定する
* mode=1,5で登録できるキー（文字列）は、一文字のみ
============================================================================*/
class LKey extends RKey {
    static long_press_th := 300 ; 長押しと判定する閾値 (ms)
    static last_key := ""       ; リピート防止のため最後に押されたキーを追跡
    static long_press_enabled := true ; この機能のグローバルな切り替えフラグ

    pressed_time := 0     ; 物理的に押し下げを開始した時刻
    ;long_key_str := ""  ; (未使用) 長押し時に送信するキー。現在は mode 1 で自動的に Shift版が使用される

    /**
     * コンストラクタ
     * @param {String} key - デフォルトキー（短押し時に送信されるキー）
     * @param {Integer} mode -  0:長押し無効、1:Down時に即送信し長押しでShift版に置換、2:長押しで未入力 3:長押しは未入力(MKeyと同じ)、単押しのときはデフォルトキー
     */
    __New(key, mode := 0) {
        super.__New(key) ; RKey の初期化 (基本/Shift キーのペアを作成)
        this.long_press_mode := mode
    }

    /**
     * 長押し機能をグローバルに有効化、無効化、または切り替える
     * @param {Integer} [m=2] - モード: 0=無効, 1=有効, 2=切り替え
     * @param {Boolean} [show_info=False] - 画面上に通知を表示するかどうか
     */
    static EnableLongPress(m := 2, show_info := False) {
        if m == 0 {
            LKey.long_press_enabled := False
        } else if m == 1 {
            LKey.long_press_enabled := True
        } else {
            LKey.long_press_enabled := !LKey.long_press_enabled ; Toggle
        }
        if show_info {
            if LKey.long_press_enabled {
                ShowOSD("LKey is enabled")
            } else {
                ShowOSD("LKey is disabled")
            }
        }
    }

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
    IsPressed() => GetKeyState(this.org_key_bare, "P")

    Down() {
        Critical

        if this.long_press_mode = 3 {
            if (this.pressed_time != 0) {
                return
            }
            this.mod_str := MakeModStr()
            this.pressed_time := A_TickCount
            return
        }

        ;以下、mode 0,1,2共通

        ; 1. Ctrl / Alt / Win が押されている場合は、リマップを行わず「パススルー」させる
        if super._SendCAWKey(this.org_key) {
            this.pressed_time := 0 ;
            ;this.pressing := False ; Up時に何もしない
            RKey.last_key := ""
            return
        }

        ; 2. 長押し機能が無効（モード0）またはグローバル設定がオフの場合
        if this.long_press_mode = 0 || LKey.long_press_enabled = 0 {
            shift := IsPhysicalShiftPressed()
            this.SendShiftedKey(shift) ; 通常の RKey として即座に送信
            this.pressed_time := 0 ;
            RKey.last_key := this.org_key
            return
        }

        ; 3. キーリピートによる多重実行を防止
        if this.pressed_time != 0 {
            return
        }

        ; 4. モード1の場合、まず「短押し用キー」を即座に送信する
        ;    （長押しが確定した場合は、後でこれを Backspace で消去する）
        if this.long_press_mode = 1 {
            shift := IsPhysicalShiftPressed()
            this.SendShiftedKey(shift)
        }

        ; モード2の場合、ここでは何もしない(Up時に処理)

        ; 5. 状態を記録し、長押し判定（Up時）のためのタイマーを開始する
        this.pressed_time := A_TickCount
        RKey.last_key := this.org_key
    }

    Up() {
        Critical
        if (this.pressed_time = 0) {
            return
        }

        now := A_TickCount
        duration := now - this.pressed_time
        is_long := (duration >= LKey.long_press_th)

        if this.long_press_mode = 3 {
            if !is_long {
                SendAndLog("{Blind}" . this.mod_str . this.org_key)
            }
            this.pressed_time := 0
            return
        }

        ; 前回のホットキーと同じキー（リピートや割り込みがない）場合のみ判定を行う
        if RKey.last_key == this.org_key {
            ; モード2: 素早く離した時のみ入力（長押し時は何も送信しない）
            if this.long_press_mode == 2 {
                if !is_long {
                    this.SendShiftedKey(IsPhysicalShiftPressed())
                }
            }
            else { ; モード1: 即時送信・長押しで置換（長押し時に既存文字を消得して再送信）
                if is_long {
                    ;this.send_time := now
                    Send("{Backspace}")
                    this.SendShiftedKey(true) ; Shift版を送信
                }
            }
        }

        ; 内部状態のリセット
        this.pressed_time := 0
        ;return is_long ; 長押しが実行された場合は true
    }
} ;class LKey

; ============================================================================
; キーオブジェクトの生成
; ============================================================================

; --- モディファイアキー (MKey) ---
f13 := MKey("")
space := MKey(R_SPACE)
;shift_lambda := () => (GetKeyState("Shift","P") || space.IsPressed())
tab := MKey(R_TAB)
noconv := MKey(R_NOCONV)
conv := MKey(R_ENTER)
f14 := MKey(R_ZENKAKU)
;colon := LKey(C_COLON, 2)

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
yen := LKey("\") ; ¥
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
;
; (矢印キー - リマップ用)
up := RKey(C_UP)
down := RKey(C_DOWN)
left := RKey(C_LEFT)
right := RKey(C_RIGHT)

; --- レイアウト用キー登録（ループ用） ---
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
    z, x, c, v, b, n, m, comma, period, slash, H
]

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
            LKey.long_press_th := Integer(IniRead(A_ScriptDir . "\config.ini", "Settings", "long_press_th", String(
                LKey
                .long_press_th)))
        } catch {
        }
        layoutName := IniRead(A_ScriptDir . "\config.ini", "Settings", "StartupLayout", "")
        if layoutName = ""
            return

        ; ハードコードされたレイアウトを確認
        switch layoutName {
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
                LoadLayoutFromIni(layoutName)
        }
    } catch {
    }
}

/**
 * config.ini に設定された現在のレイアウト（StartupLayout）を強制的に再読み込みして適用する
 */
LoadLayoutFromIni(index) {
    name := IniRead(A_ScriptDir . "\config.ini", index, "name", "")
    if name = "" {
        ChangeQwertyLayout()
        return
    }
    ver := IniRead(A_ScriptDir . "\config.ini", index, "ver", "1")
    if ver = 1 {
        if ApplyLayoutFromIni(index)
            return
    } else if ver = 2 {
        if ApplyLayoutFromIni2(index)
            return

    }
    ChangeQwertyLayout()
}

/**
 * config.ini の指定されたセクションからレイアウト配列を読み込み、適用する
 * @param {String} name - レイアウト名（INIのセクション名）
 * @returns {Boolean} 読み込みに成功した場合は true
 */
ApplyLayoutFromIni(index) {
    iniPath := A_ScriptDir . "\config.ini"

    ; 必須のレイアウト文字列を取得
    name := IniRead(iniPath, index, "Name", "")
    if name = ""
        return false
    layout := IniRead(iniPath, index, "Layout", "")
    num := IniRead(iniPath, index, "Num", "1234567890-")
    shiftLayout := IniRead(iniPath, index, "ShiftLayout", "")
    shiftNum := IniRead(iniPath, index, "ShiftNum", "")

    ; 基本レイアウトの設定
    StoreLayout(name, layout, num, shiftLayout, shiftNum)
    ResetIME() ; IME ON 時の個別設定を一旦リセット

    ; IME ON 時の個別設定があれば読み込む
    imeLayout := IniRead(iniPath, name, "ImeLayout", "")
    imeNum := IniRead(iniPath, name, "ImeNum", "")
    imeShiftLayout := IniRead(iniPath, name, "ImeShiftLayout", "")
    imeShiftNum := IniRead(iniPath, name, "ImeShiftNum", "")

    if (imeLayout != "" || imeNum != "" || imeShiftLayout != "" || imeShiftNum != "") {
        if (imeLayout == "") imeLayout := layout
            if (imeNum == "") imeNum := num
                StoreIMELayout(name, imeLayout, imeNum, imeShiftLayout, imeShiftNum)
    }

    ShowOSD("Loaded layout: " . name)
    return true
}

ApplyLayoutFromIni2(index) {
    iniPath := A_ScriptDir . "\config.ini"

    ; 必須のレイアウト文字列を取得
    name := IniRead(iniPath, index, "Name", "")
    if name = ""
        return false

    layout := IniRead(iniPath, index, "l00", "")
    loop LAYOUT_KEYS.Length - 1 {
        str := IniRead(iniPath, index, "l" . Format("{:02d}", A_Index), "")
        if str == ""
            break
        layout .= " " . str
    }

    shiftLayout := IniRead(iniPath, index, "s00", "")
    loop LAYOUT_KEYS.Length - 1 {
        str := IniRead(iniPath, index, "s" . Format("{:02d}", A_Index), "")
        if str == ""
            break
        shiftLayout .= " " . str
    }

    ; 基本レイアウトの設定
    StoreLayout2(name, layout, shiftLayout)
    ResetIME() ; IME ON 時の個別設定を一旦リセット

    ; IME ON 時の個別設定があれば読み込む
    imeLayout := IniRead(iniPath, index, "i00", "")
    loop LAYOUT_KEYS.Length - 1 {
        str := IniRead(iniPath, index, "i" . Format("{:02d}", A_Index), "")
        if str == ""
            break
        imeLayout .= " " . str
    }

    imeShiftLayout := IniRead(iniPath, index, "is00", "")
    loop LAYOUT_KEYS.Length - 1 {
        str := IniRead(iniPath, index, "is" . Format("{:02d}", A_Index), "")
        if str == ""
            break
        imeShiftLayout .= " " . str
    }

    if (imeLayout != "" || imeShiftLayout != "") {
        StoreIMELayout2(name, imeLayout, imeShiftLayout)
    }

    ShowOSD("Loaded layout: " . name)
    return true
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
            IniWrite(name, A_ScriptDir . "\config.ini", "Settings", "StartupLayout")
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

StoreIMELayout2(name, layout := "1234567890-^\qwertyuiop@[asdfghjklo:];zxcvbnm,./\", shift_layout := "") {
    KeyLogger.ChangeLayout(name)
    if name != "" {
        try {
            IniWrite(name, A_ScriptDir . "\config.ini", "Settings", "StartupLayout")
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
            IniWrite(name, A_ScriptDir . "\config.ini", "Settings", "StartupLayout")
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

MakeLayoutMap(layout) {
    static qwerty_keys := [
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "^", "¥",
        "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "@", "[",
        "a", "s", "d", "f", "g", "h", "j", "k", "l", ";", ":", "]",
        "z", "x", "c", "v", "b", "n", "m", ",", ".", "/", "\"
    ]
    map := Map()
    l := LayoutString(layout)
    for i, key in qwerty_keys {
        map[key] = l.GetElement(i)
    }

    ;scは{}なし
    ; for i, sc in sc_to_char_map.Keys() {
    ;     map[sc] = map[sc_to_char_map[sc]]
    ; }

    return map

}

StoreLayout2(name, layout := "1234567890-^\qwertyuiop@[asdfghjklo:];zxcvbnm,./\", shift_layout := "") {
    ;KeyLogger.ChangeLayout(name)
    if name != "" {
        try {
            IniWrite(name, A_ScriptDir . "\config.ini", "Settings", "StartupLayout")
        } catch {
        }
    }

    l := LayoutString(layout), ls := LayoutString(shift_layout)
    for i, keyObj in LAYOUT_KEYS {
        keyObj.SetKey(l.GetElement(i), ls.GetElement(i))
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
    w.SetImeKey("w", "wo")
    e.SetImeKey("r", "de")
    r.SetImeKey("d", "da")
    t.SetImeKey("f")

    a.SetImeKey("n", "(")
    s.SetImeKey("s", ")")
    d.SetImeKey("k", "de")
    f.SetImeKey("t", "-")
    ;g.SetImeKey("h")

    z.SetImeKey("z", "[")
    x.SetImeKey("p", "]")
    c.SetImeKey("m")
    v.SetImeKey("h", "v")
    b.SetImeKey("b", "v")

    y.SetImeKey("ya")
    u.SetImeKey("yu")
    i.SetImeKey("u", "yu")
    o.SetImeKey("yo")
    p.SetImeKey("v")

    h.SetImeKey(";", "ann") ; ;=nn
    j.SetImeKey("a", "ya")
    k.SetImeKey("i", "xi")
    l.SetImeKey("e", "xe")
    semicolon.SetImeKey("o", "ou")

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

; ============================================================================
; 設定の読み込み
; ============================================================================
init() {
    for i, keyObj in LAYOUT_KEYS {
        keyObj.long_press_mode := 1
    }

    colon.long_press_mode := 2
}

LoadLayoutConfig()
init()

; ============================================================================
; レイヤー状態判定関数
; ============================================================================

L_NAVL_CTRL := 1
L_SYMBOL_NUM := 2
L_SYMBOL1 := 7
L_SYMBOL2 := 6
L_SELECT := 3
L_NUMPAD := 4
L_SHIFT := 5
L_FUNC := 6

/**
 * 特定のモディファイアレイヤー（M1〜M6）がアクティブかどうかを判定します。
 * 他のレイヤーが同時にアクティブでないことも確認します。
 * @param {Integer} layer - 確認するレイヤー番号
 * @returns {Boolean} 指定されたレイヤーのみがアクティブな場合は true
 */
LayerState(layer) {
    ; Check the specified layer
    if layer = L_NAVL_CTRL {
        return f13.IsPressed() && !(GetKeyState("Alt", "P") || GetKeyState(R_NOCONV, "P"))
    }
    if layer = L_SYMBOL1 {
        return conv.IsPressed()
    }
    if layer = L_SYMBOL2 {
        return colon.IsPressed() || f14.IsPressed()
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

;*** レイヤー（Shift付き編集） ***
#HotIf LayerState(L_SELECT)

; --- 編集（Shift付き） ---
*1:: Send("^z") ; Undo
*2:: Send("^x") ; Cut
*3:: Send("^c") ; Copy
*4:: Send("^v") ; Paste
*z:: Send("^z") ; Undo
*x:: Send("^x") ; Cut
*c:: Send("^c") ; Copy
*v:: Send("^v") ; Paste
*b:: Send("^z") ; Undo

; --- ナビゲーション（Shift付き） ---
*y:: Send(R_REDO) ; Redo (^y)
*u:: Send(C_BS)   ; Backspace
*i:: Send("+{Up}")   ; Shift+Up
*o:: Send("+{PgUp}") ; Shift+PgUp
*p:: Send("+{PgDn}") ; Shift+PgDn
*@:: Send(C_CSHOME) ; Ctrl+Shift+Home
*[:: Send(C_CSEND)  ; Ctrl+Shift+End

*h:: Send("+{Home}")  ; Shift+Home
*j:: Send("+{Left}")  ; Shift+Left
*k:: Send("+{Down}")  ; Shift+Down
*l:: Send("+{Right}") ; Shift+Right
*sc027:: Send("+{Enter}") ; Semicolon (;) -> Shift+Enter
*Enter:: Send(B_ENTER)
*n:: Send("+{End}")   ; Shift+End
*m:: Send(C_DEL)    ; Delete
*sc033:: Send("^+{Left}") ; Comma (,) -> Ctrl+Shift+Left
*.:: Send("^+{Right}") ; Period (.)

*space:: Send(C_BS) ; Space -> Backspace

*up:: Send("+{Up}")
*left:: Send("+{Left}")
*down:: Send("+{Down}")
*right:: Send("+{Right}")
#HotIf

;*** レイヤー（システム/アプリ制御） ***
#HotIf LayerState(L_NAVL_CTRL)

*1:: Send(B_F1)
*2:: Send(B_F2)
*3:: Send(B_F3)
*4:: Send(B_F4)
*5:: Send(B_F5)
*6:: Send(B_F6)
*7:: Send(B_F7)
*8:: Send(B_F8)
*9:: Send(B_F9)
*0:: Send(B_F10)
*-:: Send(B_F11)
*sc00D:: Send(B_F12) ; ^ -> F12

sc07D:: Send("^+{sc07D}") ; \ -> |

*z:: Send(B_UNDO)  ; Undo
*x:: Send(B_CUT)   ; Cut
*c:: Send(B_COPY)  ; Copy
*v:: Send(B_PASTE) ; Paste
*b:: Send(B_UNDO)  ; Undo

; --- 編集・ナビゲーション（Shiftなし） ---
*y:: Send(B_UNDO)  ; Undo (^z)
*u:: Send(B_BS)    ; Backspace
*i:: Send(B_UP)    ; Up
*o:: Send(B_PGUP)  ; PgUp
*p:: Send(B_PGDN)  ; PgDn
*@:: Send(B_CHOME) ; Ctrl+Home
*[:: Send(B_CEND)  ; Ctrl+End

*h:: Send(B_HOME)  ; Home
*j:: Send(B_LEFT)  ; Left
*k:: Send(B_DOWN)  ; Down
*l:: Send(B_RIGHT) ; Right
*sc027:: Send(B_ENTER) ; Semicolon (;) -> Enter
;sc028::Return ; Colon (:) -> Disabled
*]:: Send("+^\")

*n:: Send(B_END)   ; End
*m:: Send(B_DEL)   ; Delete
*sc033:: Send(B_CLEFT) ; Comma (,) -> Ctrl+Left
*.:: Send(B_CRIGHT) ; Period (.) -> Ctrl+Right
sc035:: Send("^+{sc07D}") ; / -> |

*Enter:: Send("{Blind}^{Enter}") ; Enter -> Ctrl+Enter

*a:: Send("{Blind}^a") ; Select All
sc029:: Send(C_EISU) ; Zen/Han -> Eisu
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
;*** レイヤー2 (記号と数字) ***
#HotIf LayerState(L_SYMBOL_NUM)
*1:: Send(B_F1)
*2:: Send(B_F2)
*3:: Send(B_F3)
*4:: Send(B_F4)
*5:: Send(B_F5)
*6:: Send(B_F6)
*7:: Send(B_F7)
*8:: Send(B_F8)
*9:: Send(B_F9)
*0:: Send(B_F10)
*-:: Send(B_F11)
*sc00D:: Send(B_F12) ; ^ -> F12
q:: Send("?")
*w:: Send("{Blind}/")
*e:: Send(B_NMUL) ; Numpad *
*r:: Send(B_NADD) ; Numpad +
t::+F3
*a:: Send("(")
*s:: Send(")")
*d:: Send("_")
*f:: Send("{Blind}-")
g:: Send("=")
y:: Send(B_BS)
u:: Send(C_N7)
i:: Send(C_N8)
o:: Send(C_N9)
p:: Send("+^p")
h:: Send("=")
j:: Send(C_N0)
k:: Send(C_N1)
l:: Send(C_N2)
sc027:: Send(B_ENTER)
n:: Send("+3")
m:: Send(C_N3)
sc033:: Send(C_N4)
.:: Send(C_N5)
sc035:: Send(C_N6)
z:: Send("[")
x:: Send("]")
c:: Send("+[")
v:: Send("+]")
b:: Send(C_BACKSLASH)  ; Undo
*space:: Send(B_BS)
#HotIf
;*** レイヤー (記号) ***
#HotIf LayerState(L_SYMBOL1)
*1:: Send(B_F1)
*2:: Send(B_F2)
*3:: Send(B_F3)
*4:: Send(B_F4)
*5:: Send(B_F5)
*6:: Send(B_F6)
*7:: Send(B_F7)
*8:: Send(B_F8)
*9:: Send(B_F9)
*0:: Send(B_F10)
*-:: Send(B_F11)
*sc00D:: Send(B_F12) ; ^ -> F12
q:: Send("?")
*w:: Send("{Blind}/")
*e:: Send(B_NMUL) ; テンキー *
*r:: Send(B_NADD) ; テンキー +
t::+F3
*a:: Send("(")
*s:: Send(")")
*d:: Send("_")
*f:: Send("{Blind}-")
g:: Send("=")
y:: Send(B_BS)
u:: Send(C_N7)
i:: Send(C_N8)
o:: Send(C_N9)
p:: Send("+^p")
h:: Send("=")
j:: Send(C_N0)
k:: Send(C_N1)
l:: Send(C_N2)
sc027:: Send(B_ENTER)
n:: Send("+3")
m:: Send(C_N3)
sc033:: Send(C_N4)
.:: Send(C_N5)
sc035:: Send(C_N6)
z:: Send("+[")
x:: Send("+]")
c:: Send("[")
v:: Send("]")
b:: Send(C_BACKSLASH)  ; Undo
space:: Send(C_BS)
#HotIf
;*** レイヤー (テンキーレイヤー) ***
#HotIf LayerState(L_NUMPAD)
; --- 左手 ---
6:: Send("{Escape}")
t:: Send(B_NADD) ; テンキー +
a:: Send("(")
s:: Send(")")
f:: Send("-")
g:: Send("=")
; --- 右手 (テンキー) ---
7:: Send(C_N7)
8:: Send(C_N8)
9:: Send(C_N9)
0:: Send(B_NMUL) ; テンキー *
-:: Send(B_NSUB) ; テンキー -
sc00D:: Send(C_HAT) ; ^
sc07D:: Send("\") ; \
y:: Send(C_BS) ; Backspace
u:: Send(C_N4)
i:: Send(C_N5)
o:: Send(C_N6)
p:: Send(B_NADD) ; テンキー +
@:: Send(B_UP)   ; Up
h:: Send("=")
j:: Send(C_N1)
k:: Send(C_N2)
l:: Send(C_N3)
sc027:: Send(B_LEFT)  ; ; -> Left
sc028:: Send(B_DOWN)  ; : -> Down
]:: Send(B_RIGHT) ; ] -> Right
n:: Send(C_DEL) ; DeleteH ; _
space:: Send(C_BS)
#HotIf
#HotIf LayerState(L_SYMBOL2)
q:: Send("+1")
w:: Send("+2")
e:: Send("+3")
r:: Send("+4")
t:: Send("+5")
a:: Send("+6") ;
s:: Send("+7") ;
d:: Send(C_HAT) ;
g:: Send("+@") ;` grave accent
z:: Send("~") ;
x:: Send("@")
c:: Send(":")
v:: Send("|") ; |
b:: Send("\") ; \
#HotIf
#HotIf LayerState(L_FUNC)
q:: Send(B_F1)
w:: Send(B_F2)
e:: Send(B_F3)
r:: Send(B_F4)
a:: Send(B_F5)
s:: Send(B_F6)
d:: Send(B_F7)
f:: Send(B_F8)
z:: Send(B_F9)
x:: Send(B_F10)
c:: Send(B_F11)
v:: Send(B_F12)
#HotIf
#HotIf LayerState(L_SHIFT)
; 1::k1.SendShiftedKey()
; 2::k2.SendShiftedKey()
; 3::k3.SendShiftedKey()
; 4::k4.SendShiftedKey()
; 5::k5.SendShiftedKey()
*1:: Send(B_F1)
*2:: Send(B_F2)
*3:: Send(B_F3)
*4:: Send(B_F4)
*5:: Send(B_F5)
q:: q.SendShiftedKey()
w:: w.SendShiftedKey()
e:: e.SendShiftedKey()
r:: r.SendShiftedKey()
t:: t.SendShiftedKey()
a:: a.SendShiftedKey()
s:: s.SendShiftedKey()
d:: d.SendShiftedKey()
f:: f.SendShiftedKey()
g:: g.SendShiftedKey()
z:: z.SendShiftedKey()
x:: x.SendShiftedKey()
c:: c.SendShiftedKey()
v:: v.SendShiftedKey()
b:: b.SendShiftedKey()
; 6::k6.SendShiftedKey()
; 7::k7.SendShiftedKey()
; 8::k8.SendShiftedKey()
; 9::k9.SendShiftedKey()
; -::minus.SendShiftedKey()
; sc00D::hat.SendShiftedKey()
sc07D:: yen.SendShiftedKey()
*6:: Send(B_F6)
*7:: Send(B_F7)
*8:: Send(B_F8)
*9:: Send(B_F9)
*0:: Send(B_F10)
*-:: Send(B_F11)
*sc00D:: Send(B_F12) ; ^ -> F12
y:: y.SendShiftedKey()
u:: u.SendShiftedKey()
i:: i.SendShiftedKey()
o:: o.SendShiftedKey()
p:: p.SendShiftedKey()
@:: at.SendShiftedKey()
[:: openbracket.SendShiftedKey()
h:: h.SendShiftedKey()
j:: j.SendShiftedKey()
k:: k.SendShiftedKey()
l:: l.SendShiftedKey()
sc027:: semicolon.SendShiftedKey()
sc028::+sc028 ; : -> * (Not using RKey object)
]::+]         ; ] -> } (Not using RKey object)
n:: n.SendShiftedKey()
m:: m.SendShiftedKey()
sc033:: comma.SendShiftedKey()
.:: period.SendShiftedKey()
sc035:: slash.SendShiftedKey()
sc073:: backslash.SendShiftedKey()
Up:: up.SendShiftedKey()
Down:: down.SendShiftedKey()
Left:: left.SendShiftedKey()
Right:: right.SendShiftedKey()
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
; グローバルホットキー (MKey バインド)
; ============================================================================
; これらのホットキーは常にアクティブで、物理キーを
; MKey（モディファイア）オブジェクトにバインドします。
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