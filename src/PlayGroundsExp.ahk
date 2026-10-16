#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================================
; キーカスタマイズスクリプト "Playgrounds" 概要
; このスクリプトは、AutoHotkey v2 用の高度なキーカスタマイズを提供します。
; ============================================================================
; このスクリプトの構造
;   "PlaygGoundsExp.ahk" - 実行対象本体(Playgrounds.ahkの実験用クローン)
;   "Utils.ahk" - ユーティリティ関数集
;   "Preset.ahk" - プリセットの設定関数
;   "Handler.ahk" - 各種イベントのハンドラー
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
; 8. TypeAnalyzer: タイピングの統計（3キーシーケンス（トリグラム）の出現頻度と
;    打鍵間隔）を記録します。各配列の効率分析や、自身のタイピング傾向の把握に
;    活用できます
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
ProcessSetPriority "High" ; 最高の応答性を確保するため優先度を高に設定
SendMode "Event" ; キー取りこぼし（レイヤーロック）を防ぐため "Event" モードを使用
;SendMode "Input" ; AHK v2 推奨のデフォルト送信モード
;SetKeyDelay(15, 5)
SetKeyDelay(-1, -1)
ListLines 0
SetStoreCapsLockMode(false) ; CapsLockがONのときにキー送信でShiftがシミュレートされるのを防ぐ

InstallKeybdHook true ; キーボードフックを常にインストール
InstallMouseHook true ; マウスフックを常にインストール（MouseSpeedクラス用）
#UseHook true ; ホットキーにフックの使用を強制
#MaxThreadsBuffer True ; 中断された場合にホットキーをバッファリングする
;#MaxThreadsPerHotkey 3 ;（コメントアウト）ホットキーあたりのスレッド数を制限

#Include "Utils.ahk"

;+#F23::#!space

; ============================================================================
; レイヤー番号定義（グローバル定数）
; ============================================================================
global L_NAVI_CTRL := 1
global L_SYMBOL_NUM := 2
global L_SYMBOL1 := 3
global L_SYMBOL2 := 4
global L_SELECT := 5
global L_NUMPAD := 6
global L_SHIFT := 7
global L_FUNC := 8

global mod_key_list := []

/**
 * Shiftキーが物理的に押されているか、またはSpaceキーがシフト修飾として機能しているかを判定します。
 * @param {Object} key_obj - 判定対象のキーオブジェクト
 * @returns {Boolean} Shift状態（SandS含む）であれば true
 */
IsPhysicalShiftPressed(key_obj) {
    global space
    ; 物理Shiftキーが押されている場合
    if GetKeyState("Shift", "P")
        return true

    ; 判定対象のキー自身がSpaceキーではなく、かつSpaceキーが押されている場合 (SandS機能)
    if (IsSet(space) && key_obj != space && space.IsPressed())
        return true

    return false
}

/**
 * 指定された仮想キーコード（VK）のリアルタイムな物理押下状態を取得します（GetAsyncKeyStateの呼び出し）。
 * @param {Integer} vk - 仮想キーコード
 * @returns {Boolean} キーが物理的に押されている場合は true
 */
IsKeyPressedRaw(vk) {
    ; user32.dll の GetAsyncKeyState を呼び出す
    ; 戻り値の最上位ビット（16ビット目）が1なら「押されている」
    shortState := DllCall("user32\GetAsyncKeyState", "Int", vk, "Short")

    ; ビット演算で最上位ビットをチェック
    ret := (shortState & 0x8000) != 0
    return ret
}

/**
 * IME（日本語入力）の状態を管理・監視するクラスです。
 */
class ImeState {
    static force_ime_on := false
    static cached_state := false
    static last_active_control_hwnd := 0
    static is_composing_tracked := false
    static composition_count := 0
    static composition_hwnd := 0

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

    /**
     * IME状態の最終チェック時刻を記録します。
     */
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

    /**
     * 現在のモードと時間経過に基づき、IME状態のチェックが必要かどうかを判定します。
     * @returns {Boolean} チェックが必要な場合は true
     */
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

    /**
     * 現在フォーカスされているウィンドウの実際の IME 状態を取得し、キャッシュを更新します。
     * @returns {Boolean} 更新後の IME 状態 (ON なら true)
     */
    static UpdateState() {
        hwnd := GetFocusedControlHandle()
        if !hwnd {
            return ImeState.cached_state
        }

        ; 同じコントロールであれば強制 IME ON フラグを確認
        if (ImeState.last_active_control_hwnd == hwnd) {
            if ImeState.force_ime_on {
                ImeState.cached_state := true
                ImeState.RecordCheck()
                return true
            }
        } else {
            ; コントロールが変更されたため強制フラグをリセット
            ImeState.force_ime_on := false
        }

        ImeState.last_active_control_hwnd := hwnd

        ; 1. 自プロセスウィンドウの場合: ImmGetContext を試行
        hIMC := DllCall("imm32\ImmGetContext", "Ptr", hwnd, "Ptr")
        if hIMC {
            openStatus := DllCall("imm32\ImmGetOpenStatus", "Ptr", hIMC)
            DllCall("imm32\ImmReleaseContext", "Ptr", hwnd, "Ptr", hIMC)
            ImeState.cached_state := (openStatus != 0)
            ImeState.RecordCheck()
            return ImeState.cached_state
        }

        ; 2. 他プロセスウィンドウの場合: フォーカスのある hwnd から DefaultIMEWnd を取得
        default_ime_wnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")

        ; 子ウィンドウで失敗した場合のみトップレベルウィンドウを試す
        if !default_ime_wnd {
            top_hwnd := WinExist("A")
            if (top_hwnd && top_hwnd != hwnd) {
                default_ime_wnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", top_hwnd, "Ptr")
            }
        }

        if default_ime_wnd {
            state := 0
            ; 0x0283: WM_IME_CONTROL, 0x0005: IMC_GETOPENSTATUS
            ; SMTO_ABORTIFHUNG (0x0002) を指定しつつ、タイムアウトを確実に取得
            if DllCall("user32\SendMessageTimeout", "Ptr", default_ime_wnd, "UInt", 0x0283, "Ptr", 0x0005, "Ptr", 0,
                "UInt", 0x0002, "UInt", 100, "Ptr*", &state, "Ptr") {
                ImeState.cached_state := (state != 0)
            }
        }
        ;Todo:Composing状態をキャッシュ
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
     * 文字入力時にコンポジション開始・継続を記録
     */
    static RecordCompositionInput(c) {
        if ImeState.IsOn() {
            ImeState.is_composing_tracked := true
            ImeState.composition_count++
            ImeState.composition_hwnd := GetFocusedControlHandle()
        }
    }

    /**
     * 確定・キャンセル・フォーカス変更等でコンポジションをリセット
     */
    static ResetComposition() {
        ImeState.is_composing_tracked := false
        ImeState.composition_count := 0
    }

    /**
     * Backspace押下時の処理
     */
    static HandleBackspace() {
        if (ImeState.composition_count > 0) {
            ImeState.composition_count--
            if (ImeState.composition_count <= 0) {
                ImeState.is_composing_tracked := false
            }
        }
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

/**
 * 現在のウィンドウに対して強制 IME ON フラグを切り替える
 */
ToggleForceImeModeOn() {
    hwnd := GetFocusedControlHandle()
    ImeState.ToggleForce()
    if (hwnd) {
        ImeState.last_active_control_hwnd := hwnd
    }
    ImeState.UpdateState()
    UpdateImeIndicator()
    ShowOSD("Force IME Mode: " . ImeState.MakeForceStateWord())
}

/**
 * クリティカルセクション内で指定された IME 制御キーまたは文字を送信し、IMEキャッシュ状態を更新します。
 * @param {String} c - 送信するキーまたは文字
 */
SendImeChar(c) {
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
        ImeState.ResetComposition()
        SendImeChar(c) ;criticalが二重にかかるが大丈夫
        UpdateImeIndicator()
        return
    }
    ; if c = R_ADAPTIVE_ENTER {
    ;     if (ImeState.IsOn(true) && ImeState.IsComposing()) {
    ;         key_to_send := "^m"
    ;         Tooltip("Adaptive Enter: ON -> OFF (Ctrl+M)")
    ;     } else {
    ;         key_to_send := B_ENTER
    ;         Tooltip("Adaptive Enter: OFF -> ON (Enter)")
    ;     }
    ;     Send(key_to_send)
    ;     TypeAnalyzer.Log(key_to_send)
    ;     ImeState.RecordActivity()
    ;     ImeState.ResetComposition()
    ;     return
    ; }
    if (c = B_ENTER || c = C_ENTER || c = "{Enter}" || c = "{Blind}{Enter}" || c = B_ESC || c = C_ESC || c = "{Esc}") {
        ImeState.ResetComposition()
    } else if (c = B_BS || c = C_BS || c = "{Backspace}" || c = "{Blind}{Backspace}") {
        ImeState.HandleBackspace()
    } else if (ImeState.IsOn()) {
        ImeState.RecordCompositionInput(c)
    }

    Send(c)
    TypeAnalyzer.Log(c)
    ImeState.RecordActivity()
}

/**
 * 現在の IME 状態に応じて、特定のキーを送信する
 * @param {String} key_ime_off - IME が OFF の場合に送信するキー文字列
 * @param {String} [key_ime_on=""] - IME が ON の場合に送信するキー文字列
 * 省略された場合は `key_ime_off` が使用される
 */
SendBasedOnImeState(key_ime_off, key_ime_on := "", ime_state := -1) {
    if key_ime_on == "{none}" || key_ime_off == "{none}" {
        return ; {none} が指定された場合は何も送信しない
    }
    if key_ime_off == key_ime_on || key_ime_on == "" {
        SendAndLog(key_ime_off)
        return
    }
    ime_on := ime_state == -1 ? ImeState.IsOn() : ime_state == 1
    if (ime_on) {
        SendAndLog(key_ime_on)
    } else {
        SendAndLog(key_ime_off)
    }
}

; --- リモートデスクトップ使用時の自動無効化 ---
GroupAdd("RemoteDesktops", "ahk_class TscShellContainerClass") ; Windows 標準RDP
;GroupAdd("RemoteDesktops", "ahk_exe AnyDesk.exe")              ; AnyDesk
;GroupAdd("RemoteDesktops", "ahk_exe TeamViewer.exe")           ; TeamViewer
;GroupAdd("RemoteDesktops", "ahk_exe tvnviewer.exe")            ; TightVNC
;GroupAdd("RemoteDesktops", "ahk_exe vncviewer.exe")            ; RealVNC / UltraVNC

; --- ホットキーリマップを除外するウィンドウグループ ---
GroupAdd("IgnoreWindows", "ahk_group RemoteDesktops")
GroupAdd("IgnoreWindows", "ahk_exe TextInputHost.exe")
GroupAdd("IgnoreWindows", "ahk_exe PowerToys.AdvancedPaste.exe")

/**
 * リモートデスクトップウィンドウがアクティブな場合に、スクリプトを自動的にサスペンド（一時停止）する
 * @returns {Boolean} サスペンドされた状態であれば true
 */
AutoSuspendForRemoteDesktop() {
    static auto_suspended := false
    if WinActive("ahk_group RemoteDesktops") {
        if !A_IsSuspended {
            LKey.ResetAll()
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
 * マウスカーソル付近に IME 状態を示すインジケータ（ドット）を表示・更新する
 */
UpdateImeIndicator(precise := False) {
    static last_status := -1 ;-1:初期状態, 0:オフ, 1:オン, 2:強制オン

    if !TypeAnalyzer.is_showing_ime_indicator {
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
    static last_focus_hwnd := 0
    cur_hwnd := GetFocusedControlHandle()
    if (cur_hwnd != last_focus_hwnd) {
        ImeState.ResetComposition()
        last_focus_hwnd := cur_hwnd
    }
    static counter := 0
    static is_rdp := false
    if (Mod(counter, 5) == 0) {
        is_rdp := AutoSuspendForRemoteDesktop()
    }
    if is_rdp {
        counter++
        return
    }

    UpdateImeIndicator()

    ; 5秒以上操作がない場合、修飾キーのスタック（レイヤーロック）を防止するために状態をリセット
    ; static last_idle_reset := false
    ; if (A_TimeIdlePhysical > 5000) {
    ;     if (!last_idle_reset) {
    ;         LKey.ResetAll()
    ;         last_idle_reset := true
    ;     }
    ; } else {
    ;     last_idle_reset := false
    ; }

    ; 20秒以上操作がない場合、ログを保存
    if (Mod(counter, 100) == 0) {
        TypeAnalyzer.SaveIfIdle(A_TimeIdlePhysical)
    }

    ; 10秒ごとにキーロガーの最大処理時間をリセットして一時的な遅延スパイクから復帰可能にする
    if (Mod(counter, 100) == 0) {
        if TypeAnalyzer.total_log_time > 0 {
            TypeAnalyzer.total_log_time2 := Max(TypeAnalyzer.total_log_time2, TypeAnalyzer.total_log_time)
            TypeAnalyzer.total_log_time := 0
        }
    }

    counter++
}

/**
 * 現在物理的に押されている修飾キー (Win, Alt, Ctrl, Shift) の AHK プレフィックス記号を構築します。
 * @returns {String} 修飾キーのプレフィックス記号文字列 (例: "+^")
 */
MakeModStr() {
    is_shift := IsPhysicalShiftPressed("")
    return (GetKeyState("LWin", "P") || GetKeyState("RWin", "P") ? "#" : "")
    . (GetKeyState("Alt", "P") ? "!" : "")
    . (GetKeyState("Ctrl", "P") ? "^" : "")
    . (is_shift ? "+" : "")
}

/*============================================================================
 [Class] RKey (リマップキー)
 キーリマップを管理し、Shift、IME ON/OFF の状態に応じて異なる出力を処理します。
 登録する文字列の仕様については BuildSendText() のコメントを参照してください。
============================================================================*/
class RKey {
    ;static layer_list := [1, 2, 3, 4, 5, 6, 7]
    ;static layer_list := [L_NAVI_CTRL, L_SELECT, L_SYMBOL_NUM, L_SYMBOL1, L_SYMBOL2, L_NUMPAD, L_SHIFT]

    static use_registered_key_for_ctrl := false ; (未使用？) ctrl または alt 用
    ;static last_key := ""

    ;org_key: {}付き、基本は物理キーを設定
    ;org_key_raw: {}なし  基本は物理キーを設定
    ;key_text: 送信用テキスト(ShiftOff,ImeOff)
    ;shift_key_text: 送信用テキスト(ShiftOff,ImeOn)
    ;ime_key_text: 送信用テキスト(ShiftOn,ImeOff)
    ;shift_ime_key_text: 送信用テキスト(ShiftOn,ImeOn)
    ;layer_keys: レイヤー用キー配列(IME Off)
    ;layer_ime_keys: レイヤー用キー配列(IME On)

    /**
     * コンストラクタ
     * @param {String} key - 物理キー (例: "q", "{sc027}")。基本的には 1 文字または 1 つのスキャンコード。
     * @param {String} [reg_key=""] - 登録キー (短押し時に送信されるキー)。省略時は物理キーと同じ。
     */
    __New(key, reg_key := "") {
        this.org_key := AddBraces(key)
        raw := RemoveBraces(key)
        sc := GetKeySC(raw)
        this.org_key_raw := sc ? Format("sc{:03x}", sc) : raw
        if reg_key = "" {
            this.SetKey(key)   ; IME OFF 時のキーを設定
            this.SetImeKey(key) ; IME ON 時のキーを設定 (デフォルトは OFF 時と同じ)
        } else {
            this.SetKey(reg_key)   ; IME OFF 時のキーを設定
            this.SetImeKey(reg_key) ; IME ON 時のキーを設定 (デフォルトは OFF 時と同じ)
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
            this.shift_ime_key_text := shift_ime_key = "" ? BuildSendText(ime_key, "+") : BuildSendText(
                shift_ime_key)
        }
    }

    /**
     * 内部ヘルパー: IME 状態に基づいて正しいキーを送信する
     * @param {String} ime_key - IME ON 時に送信するキー
     * @param {String} normal_key - IME OFF 時に送信するキー
     * @param {Int} ime_state - IME 状態 (-1: 現在の状態を内部で取得, 0: OFF, 1: ON)
     */
    _SendKey(ime_key, normal_key, ime_state := -1) => SendBasedOnImeState(normal_key, ime_key, ime_state)
    /*============================================================================
    	(Override) Sends the layer key.
    	@param {Integer} layer_id - The layer ID.
    	@param {Integer} [ime_state=-1] - IME state (-1: auto, 0: off, 1: on).
    ============================================================================*/
    SendShiftedKey(shift := true, ime_state := -1) {
        if shift {
            this._SendKey(this.shift_ime_key_text, this.shift_key_text, ime_state)
        } else {
            this._SendKey(this.ime_key_text, this.key_text, ime_state)
        }
        return shift
    }

    /**
     * 物理的な Shift キーの押下状態に基づいて、対応するキーマッピングを送信します。
     * @returns {Boolean} 送信されたキーが Shift 版である場合は true
     */
    SendKeyWithShift() {
        return this.SendShiftedKey(IsPhysicalShiftPressed(this))
    }

    /**
     * Ctrl, Alt, Win (CAW) のパススルーを処理する
     * これらの修飾キーのいずれかが押されている場合は、リマップをバイパスして物理キーをそのまま送信する
     * @param {String} pressed_key - 押された物理キー (例: "{x}", "{sc027}")
     * @returns {Boolean} CAW が押されていた場合 (パススルー発生) は true
     */
    _SendCAWKey(pressed_key) {
        caw := GetKeyState("Ctrl") || GetKeyState("Alt") || GetKeyState("LWin") || GetKeyState("RWin")
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
        this.SendShiftedKey(IsPhysicalShiftPressed(this))
        return false
    }

    /**
     * キー押し下げ時のホットキーから呼び出す (例: `*x::x.Down()`)
     */
    Down() {
        Critical
        LKey.InterruptOthers(this)
        Layers.last_active_item := ""
        this._SendSCAWKey(this.org_key)
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
 RKey を拡張し、長押し(Hold)と短押し(Tap)とで応じたアクションを追加します。
長押しは、モード（以後、ホールドモード）に応じて挙動が異なり、送信されるキーが切り替えられたり、
あるいは何も送信されず、修飾キーとして利用されたりする。
モードは修飾キーの動作を規定。ここでは被修飾キーをメインキーと呼ぶ。

 [ホールドモード説明]
・ホールドモード0：リマップキー送信
長押し判定を行わない標準的なリマップ。IME状態に応じて送信されるキーが変わる。
キーリピートは有効 。

・ホールドモード1：短押し->リマップキー送信(down時)　長押し->シフト文字置換
押し下げ時に即座にリマップキーを送信する。IME状態に応じて送信されるキーが変わる。
一定時間以上の長押しされていた場合、送信済みの文字を Backspace で消去し、
Shift 版（または指定キー）を再送信して置換する。
キーリピートは無効化される 。

・ホールドモード2：短押し、長押し->未送信(修飾キー利用)
押し下げ・離し時の出力を完全に抑制し、純粋なレイヤー切り替え等の修飾キーとして利用される。
モードの違いを明確化するために、説明では、短押し、長押しという表現を使っているが、
このモードにおいてはその区別はない。
キーリピートは無効化される 。

・ホールドモード3：短押し->リマップキー送信(up時)　長押し->未送信(修飾キー利用)
down時に、scawの状態を保持。
up時に、一定時間以上の長押しされていなければ、scawを反映してリマップキーを送信する。
長押し中や確定後は何も送信されず、修飾キー（レイヤー用）として機能する。
IME状態に依存しない。
キーリピートは無効化される。

・ホールドモード13：ホールドモード3のエイリアス（後方互換性のため維持）。

・ホールドモード4：短押し->リマップキー送信(down時)　長押し->未送信(修飾キー利用)
押し下げ時に即座にリマップキーを送信する。
キーリピートは無効化される以外は、モード 0 と同様の挙動。
キーリピートは無効化される 。
キー送信後、キーが押され続けている間、修飾キーとして機能する 。

・ホールドモード5：
 【説明】
 Aキー: 先に押されるキー、通常キー送信、または、修飾キーとなる
 Bキー: 遅れて押されるキー、通常キー、または、修飾キーとのコンビネーションが送信される

【パラメーター定義】
  - t              : 修飾キーがDown（ホールド開始）してからの経過時間 [ms]
  - Layers.hold_th  : 修飾キー（ホールド）として成立させるための基準閾値 [ms]
  - b_time         : ロールオーバー（高速打鍵）時の誤判定を防ぐバッファ時間 [ms]

 【論理条件とアクション】
 条件0: AキーDown,Up
 [アクション] Aの通常キーを送信する。

 条件1: AキーDown後、十分な時間が経過してから、BキーがDownされた場合
 [判定基準] t >= Layers.hold_th
 [アクション] 修飾キーのコンビネーションを送信する。

 条件2: AキーDown後、ごく短時間（バッファ未満）でBキーがDownされた場合
 [判定基準] t < (Layers.hold_th - b_time)
 [アクション] Aの通常キー、Bの通常キーを送信する。

 条件3: 修飾キーDown後、グレーゾーン（バッファ期間内）でBキーがDownされた場合
 [判定基準] (Layers.hold_th - b_time) <= t < Layers.hold_th
 [アクション] AキーDown時点では判定を保留し、その後のイベントによって挙動を決定する。
   ├─ ケース 3-A: Aキーが先にUp（短押し）された場合
   │   [アクション] Aキー通常キー、Bキーの通常キーを送信する。
   ├─ ケース 3-B: AキーはHoldのまま、先にBキーがUpされた場合
   │   [アクション] Aキー通常キー、Bキーの通常キーを送信する。
   └─ ケース 3-C: 両キーともHoldのまま、経過時間(t)が Layers.hold_th を超えた場合
       [アクション] 閾値（Layers.hold_th）に達した瞬間に、修飾キーのコンビネーションの送信する。

 ・ホールドモード6：
 【説明】
 モード4のタイミング拡張：高速タイピング時のロールオーバーによる誤判定を防ぐ
 Aキー: 先に押されるキー、通常キー送信後、修飾キーとなる
 Bキー: 遅れて押されるキー、通常キー、または、修飾キーとのコンビネーションが送信される
 モード6は、必ず、AキーのDown時に通常キー送信が行われる
修飾キーとのコンビネーションでは、設定によってBackspace付きのキー送信を行っても良い。
これにより、すでに送信されたAの通常キーをキャンセルする。
モードの動作としては、自動でBackspace送信は行わない。
キーリピートは無効化される 。

【パラメーター定義】
  - t              : 修飾キーがDown（ホールド開始）してからの経過時間 [ms]
  - Layers.hold_th  : 修飾キー（ホールド）として成立させるための基準閾値 [ms]

 【論理条件とアクション（修飾キーDownホールド中のメインキー操作）】
 条件1: AキーDown(通常キー送信)後、十分な時間が経過してからBキーがDownされた場合
 [判定基準] t >= Layers.hold_th
 [アクション] 修飾キーのコンビネーションを送信する。

  条件2: AキーDown(通常キー送信)後、特定時間内にBキーがDownされた場合
 [判定基準] t < Layers.hold_th
 [アクション] BキーDown時点では判定を保留し、その後のイベントによって挙動を決定する。
   ├─ ケース 2-A: Aキーが先にUp（短押し）された場合
   │   [アクション] Bの通常キーを送信する。
   ├─ ケース 2-B: AキーはHoldのまま、先にBキーがUpされた場合
   │   [アクション] Bの通常キーを送信する。
   └─ ケース 2-C: 両キーともHoldのまま、経過時間(t)が Layers.hold_th を超えた場合
       [アクション] 閾値（Layers.hold_th）に達した瞬間に、修飾キーのコンビネーション
                    が送信される。

・ホールドモード7：
 【説明】
 モード4のタイミング拡張：高速タイピング時のロールオーバーによる誤判定を防ぐバッファ付きTap-Hold)
 Aキー: 先に押されるキー、通常キー送信後、修飾キーとなる
 Bキー: 遅れて押されるキー、通常キー、または、修飾キーとのコンビネーションが送信される
 モード7は、必ず、AキーのDown時に通常キー送信が行われる
修飾キーとのコンビネーションでは、設定によってBackspace付きのキー送信を行っても良い。
これにより、すでに送信されたAの通常キーをキャンセルする。
モードの動作としては、自動でBackspace送信は行わない。
キーリピートは無効化される 。

【パラメーター定義】
  - t              : 修飾キーがDown（ホールド開始）してからの経過時間 [ms]
  - Layers.hold_th  : 修飾キー（ホールド）として成立させるための基準閾値 [ms]
  - b_time         : ロールオーバー（高速打鍵）時の誤判定を防ぐバッファ時間 [ms]

 【論理条件とアクション（修飾キーDownホールド中のメインキー操作）】
 条件1: AキーDown(通常キー送信)後、十分な時間が経過してからBキーがDownされた場合
 [判定基準] t >= Layers.hold_th
 [アクション] 修飾キーのコンビネーションを送信する。

 条件2: AキーDown(通常キー送信)後、ごく短時間（バッファ未満）でBキーがDownされた場合
 [判定基準] t < (Layers.hold_th - b_time)
 [アクション] Bの通常キー送信する（Down時確定）。

 条件3: AキーDown(通常キー送信)後、グレーゾーン（バッファ期間内）でBキーがDownされた場合
 [判定基準] (Layers.hold_th - b_time) <= t < Layers.hold_th
 [アクション] BキーDown時点では判定を保留し、その後のイベントによって挙動を決定する。
   ├─ ケース 3-A: Aキーが先にUp（短押し）された場合
   │   [アクション] Bの通常キーを送信する。
   ├─ ケース 3-B: AキーはHoldのまま、先にBキーがUpされた場合
   │   [アクション] Bの通常キーを送信する。
   └─ ケース 3-C: 両キーともHoldのまま、経過時間(t)が Layers.hold_th を超えた場合
       [アクション] 閾値（Layers.hold_th）に達した瞬間に、修飾キーのコンビネーション
                    が送信される。

 ・ホールドモード8：
 【説明】
 モード4のタイミング拡張：高速タイピング時のロールオーバーによる誤判定を防ぐバッファ付きTap-Hold)
 Aキー: 先に押されるキー、通常キー送信後、修飾キーとなる
 Bキー: 遅れて押されるキー、通常キー、または、修飾キーとのコンビネーションが送信される
 モード7は、必ず、AキーのDown時に通常キー送信が行われる
修飾キーとのコンビネーションでは、設定によってBackspace付きのキー送信を行っても良い。
これにより、すでに送信されたAの通常キーをキャンセルする。
モードの動作としては、自動でBackspace送信は行わない。
キーリピートは無効化される 。

【パラメーター定義】
  - t              : 修飾キーがDown（ホールド開始）してからの経過時間 [ms]
  - Layers.hold_th  : 修飾キー（ホールド）として成立させるための基準閾値 [ms]
  - b_time2        : ロールオーバー（高速打鍵）時の誤判定を防ぐバッファ時間 [ms]

 【論理条件とアクション（修飾キーDownホールド中のメインキー操作）】
 条件1: AキーDown(通常キー送信)後、十分な時間が経過してからBキーがDownされた場合
 [判定基準] t >= Layers.hold_th
 [アクション] 修飾キーのコンビネーションを送信する。

 条件2: AキーDown(通常キー送信)後、ごく短時間（バッファ未満）でBキーがDownされた場合
 [判定基準] t < (Layers.hold_th - b_time2)
 [アクション] Bの通常キー送信する（Down時確定）。

 条件3: AキーDown(通常キー送信)後、グレーゾーン（バッファ期間内）でBキーがDownされた場合
 [判定基準] (Layers.hold_th - b_time2) <= t < Layers.hold_th
 [アクション] BキーDown時点では判定を保留し、その後のイベントによって挙動を決定する。
   ├─ ケース 3-A: Aキーが先にUp（短押し）された場合
   │   [アクション] Bの通常キーを送信する。
   ├─ ケース 3-B: AキーはHoldのまま、先にBキーがUpされた場合
   │   [アクション] 修飾キーのコンビネーションが送信される。
   └─ ケース 3-C: 両キーともHoldのまま、経過時間(t)が Layers.hold_th を超えた場合
       [アクション] 閾値（Layers.hold_th）に達した瞬間に、修飾キーのコンビネーション
                    が送信される。

・ホールドモード9：
 【説明】
 モード4のタイミング拡張：高速タイピング時のロールオーバーによる誤判定を防ぐバッファ付きTap-Hold)
 Aキー: 先に押されるキー、通常キー送信後、修飾キーとなる
 Bキー: 遅れて押されるキー、通常キー、または、修飾キーとのコンビネーションが送信される
 モード7は、必ず、AキーのDown時に通常キー送信が行われる
修飾キーとのコンビネーションでは、設定によってBackspace付きのキー送信を行っても良い。
これにより、すでに送信されたAの通常キーをキャンセルする。
キーリピートは無効化される 。

【パラメーター定義】
  - t              : 修飾キーがDown（ホールド開始）してからの経過時間 [ms]
  - Layers.hold_th  : 修飾キー（ホールド）として成立させるための基準閾値 [ms]
  - b_time         : ロールオーバー（高速打鍵）時の誤判定を防ぐバッファ時間 [ms]

 【論理条件とアクション（修飾キーDownホールド中のメインキー操作）】
 条件1: AキーDown(通常キー送信)後、十分な時間が経過してからBキーがDownされた場合
 [判定基準] t >= Layers.hold_th
 [アクション] 修飾キーのコンビネーションを送信する。

 条件2: AキーDown(通常キー送信)後、ごく短時間（バッファ未満）でBキーがDownされた場合
 [判定基準] t < (Layers.hold_th - b_time)
 [アクション] Bの通常キー送信する（Down時確定）。
            ただし、A,B両キーともHoldのまま、経過時間(t)が Layers.hold_th を超えた場合
            Backspace送信後に、修飾キーのコンビネーションが送信される。

 条件3: AキーDown(通常キー送信)後、グレーゾーン（バッファ期間内）でBキーがDownされた場合
 [判定基準] (Layers.hold_th - b_time) <= t < Layers.hold_th
 [アクション] BキーDown時点では判定を保留し、その後のイベントによって挙動を決定する。
   ├─ ケース 3-A: Aキーが先にUp（短押し）された場合
   │   [アクション] Bの通常キーを送信する。
   ├─ ケース 3-B: AキーはHoldのまま、先にBキーがUpされた場合
   │   [アクション] Bの通常キーを送信する。
   └─ ケース 3-C: A,B両キーともHoldのまま、経過時間(t)が Layers.hold_th を超えた場合
       [アクション] 閾値（Layers.hold_th）に達した瞬間に、修飾キーのコンビネーション
                    が送信される。


---
■ 共通仕様および制約

・修飾キー (CAW) が押される場合はリマップをバイパスして処理
Ctrl, Alt, Win (CAW) のいずれかが物理的に押されている場合、リマップをバイパスして物理キーをそのまま送信する 。

・物理状態の厳密判定
各モードの分岐や Layers.State によるレイヤー判定には GetKeyState(..., "P") を使用し、ユーザーが実際に指でキーを押し込んでいるかという物理的な状態を正確に取得する 。

・リマップキー登録のルール
モード 1 および 6 では、Backspace による正確な消去を行うため、登録するキーは「1 文字」または「1 つのスキャンコード (例: {sc027})」である必要がある 。

・リマップキー
モード３以外は、IME状態やシフト状態に応じてキーが送信される。
*/
class LKey extends RKey {
    static hold_th := 300 ; 長押し判定閾値 (ms)
    static pre_stroke_buf := 30 ; 互換性保持用
    static st_init := 0
    static st_pressing := 1
    static st_processed := 2

    static instances := []

    /**
     * すべての LKey インスタンスの状態（押下時間、割り込みフラグ、タイマーなど）を初期状態にリセットします。
     */
    static ResetAll() {
        for inst in LKey.instances {
            inst.state := LKey.st_init
            inst.pressed_time_qpc := 0
            inst.interrupted := false
            inst.saved_scaw := ""
            if (inst.timer_name != "") {
                SetTimer(inst.timer_name, 0)
            }
        }
    }

    /**
     * 他のすべての LKey インスタンスに対して割り込みを通知する
     */
    static InterruptOthers(currentKey) {
        for inst in LKey.instances {
            if (inst != currentKey && inst.state == LKey.st_pressing) {
                inst.interrupted := true
                if (inst.timer_name != "") {
                    SetTimer(inst.timer_name, 0)
                }
                inst.state := LKey.st_processed
            }
        }
    }

    state := 0
    pressed_time_qpc := 0 ; 物理的に押し下げを開始した時刻
    interrupted := false  ; 他のキーが割り込んできたら true にするフラグ
    down_ime_state := 0   ; Down時のIME状態を記録
    saved_scaw := ""      ; モード3用のCAW状態保持用フラグ
    timer_name := ""      ; 非同期タイマーコールバック名

    /**
     * コンストラクタ
     */
    __New(key, mode := 0, reg_key := "") {
        super.__New(key, reg_key)
        this.vk := GetKeyVK(this.org_key_raw)
        this.layers := Layers()
        this.hold_mode_org := mode
        this.hold_mode_ime_org := mode

        ; タイマーが常に同じオブジェクトを参照するようにインスタンスに固定
        this.timer_name := ObjBindMethod(this, "OnHoldTimeout")

        LKey.instances.Push(this)
    }

    /**
     * 長押し動作モードを設定します。
     */
    SetMode(mode := 0, ime_mode := 0) {
        if mode >= 0
            this.hold_mode_org := mode
        if ime_mode >= 0
            this.hold_mode_ime_org := ime_mode
    }

    /**
     * IME OFF 時の標準送信キーと、Shift押下時の送信キーを設定します。
     */
    SetKey(key, shift_key := "", ime := false) {
        super.SetKey(key, shift_key)
        if ime
            this.SetImeKey(key, shift_key)
    }

    /**
     * IME ON 時の送信キーと、Shift押下時の送信キー、および動作モードを設定します。
     */
    SetImeKey(ime_key := "", shift_ime_key := "", mode := -1) {
        super.SetImeKey(ime_key, shift_ime_key)
        if (mode != -1)
            this.hold_mode_ime_org := mode
    }

    /**
     * レイヤーキーを設定する
     */
    SetLayerKey(mode, layer_id, action, action2 := "", action3 := "", ime := True) {
        layer_item := Layers.LayerItem(layer_id, action, action2, action3, mode)
        this.SetLayerKey2(layer_item, ime)
    }

    /**
     * LayerItem オブジェクトを直接指定してレイヤーキーアクションを設定します。
     */
    SetLayerKey2(layer_item, ime := True) {
        this.layers.SetAction2(layer_item)
        if ime {
            this.layers.SetIMEAction2(layer_item.Clone())
        }
    }

    /**
     * IME ON 時の特定レイヤーのアクションを設定します。
     */
    SetLayerImeKey(mode, layer_id, action, action2 := "", action3 := "", reset_if_blank := false) {
        layer_item := Layers.LayerItem(layer_id, action, action2, action3, mode)
        this.SetLayerImeKey2(layer_item, reset_if_blank)
    }

    /**
     * LayerItem オブジェクトを直接指定して IME ON 時のレイヤーキーアクションを設定します。
     */
    SetLayerImeKey2(layer_item, reset_if_blank := false) {
        this.layers.SetIMEAction2(layer_item)
    }

    /**
     * 現在アクティブなレイヤーに基づいてキーを送信します。
     */
    SendLayerKey(ime_state) => this.layers.SendLayerKey(this, ime_state)

    /**
     * キーが物理的に押されているかどうかを判定します。
     */
    IsPressed() => GetKeyState(this.org_key_raw, "P")

    /**
     * キー押し下げ時の処理
     */
    Down() {
        Critical
        ime_state := ImeState.IsOn()
        hold_mode := (ime_state == 1) ? this.hold_mode_ime_org : this.hold_mode_org

        ; リピートガード (モード 0 以外用)
        if (hold_mode != 0 && (this.state == LKey.st_pressing || this.state == LKey.st_processed)) {
            return
        }

        ; レイヤーキーの判定
        if this.SendLayerKey(ime_state) {
            if (hold_mode != 0) {
                LKey.InterruptOthers(this)
                this.state := LKey.st_processed
            }
            return
        }

        Layers.last_active_item := ""

        ; 修飾キー (Ctrl/Alt/Win) パススルー判定
        if super._SendCAWKey(this.org_key) {
            if (hold_mode != 0) {
                LKey.InterruptOthers(this)
                this.pressed_time_qpc := 0
                this.state := LKey.st_processed
            }
            return
        }

        ; モード0（長押し判定なし通常送信）
        if (hold_mode == 0) {
            this.SendKeyWithShift()
            return
        }

        this.interrupted := false
        this.pressed_time_qpc := HighPrecisionTimer()
        this.down_ime_state := ime_state
        LKey.InterruptOthers(this)
        this.state := LKey.st_pressing

        switch hold_mode {
            case 1: ; 短押し->即時送信、長押し->置換
                this.SendKeyWithShift()
                SetTimer(this.timer_name, -LKey.hold_th)

            case 2: ; 修飾キー専用（キー送信なし）
                ; 何も送信しない
            case 3, 13: ; 短押し->up時送信（IME不依存）、長押し->修飾キー
                this.saved_scaw := MakeModStr()

            case 5: ; 短押し->up時送信、長押し/コンビネーション->修飾キー
                ; Down時には送信せず保留
            default: ; モード 4, 6, 7, 8, 9: 短押し->即時送信、長押し->修飾キー
                this.SendKeyWithShift()
        }
    }

    /**
     * キー離し時の処理
     */
    Up() {
        Critical
        ime_state := ImeState.IsOn()
        hold_mode := (this.pressed_time_qpc == 0) ? ((ime_state == 1) ? this.hold_mode_ime_org : this.hold_mode_org) :
            ((this.down_ime_state == 1) ? this.hold_mode_ime_org : this.hold_mode_org)

        if (hold_mode == 0) {
            this.state := LKey.st_init
            this.pressed_time_qpc := 0
            return
        }

        if (this.timer_name != "") {
            SetTimer(this.timer_name, 0)
        }

        duration := HighPrecisionTimer() - this.pressed_time_qpc

        ; モード3 / モード13（短押し：Up時に送信、長押し：修飾キー化）のリリース処理
        if (hold_mode == 3 || hold_mode == 13) {
            if (this.state == LKey.st_pressing && !this.interrupted && duration < LKey.hold_th) {
                SendAndLog("{Blind}" . this.saved_scaw . this.key_text)
            }
        } else if (hold_mode == 5) {
            ; モード5：短押し（単独Up時）に通常キーを送信
            if (this.state == LKey.st_pressing && !this.interrupted && duration < LKey.hold_th) {
                this.SendKeyWithShift()
            }
        }

        ; 状態を初期化
        this.state := LKey.st_init
        this.pressed_time_qpc := 0
        this.interrupted := false
        this.saved_scaw := ""
    }

    /**
     * 長押しタイムアウト（モード1用）
     */
    OnHoldTimeout() {
        Critical
        if (this.state == LKey.st_pressing && !this.interrupted) {
            duration := HighPrecisionTimer() - this.pressed_time_qpc
            if (duration >= LKey.hold_th) {
                this.state := LKey.st_processed
                Send("{Backspace}")
                this.SendShiftedKey(true, this.down_ime_state)
            } else {
                remaining := Ceil(LKey.hold_th - duration)
                SetTimer(this.timer_name, -(remaining > 0 ? remaining : 1))
            }
        }
    }
}

; ============================================================================
; キーオブジェクトの生成とグローバル変数の宣言
; ============================================================================
global f13, space, tab, noconv, conv, f14
global k1, k2, k3, k4, k5, k6, k7, k8, k9, k0, minus, hat, yen
global q, w, e, r, t, y, u, i, o, p, at, openbracket
global a, s, d, f, g, h, j, k, l, semicolon, colon, closebracket
global z, x, c, v, b, n, m, comma, period, slash, backslash, enter
global up, down, left, right
global LAYOUT_SPECIAL_KEYS, LAYOUT_SPECIAL_NAMES, LAYOUT_NUM_KEYS, LAYOUT_CHAR_KEYS, LAYOUT_KEYS, QWERTY_CHARS

/**
 * すべての物理キーに対応する RKey / LKey オブジェクトのインスタンスを生成し、
 * レイループ用配列（LAYOUT_KEYS など）に一括してグローバルに登録・初期化します。
 */
InitGlobalKeys() {
    global
    ;f13 := LKey("f13", 3, C_TAB)
    ;tab := LKey(R_TAB, 3, C_ESC)
    ;conv := LKey(R_CONV, 3, C_ZENKAKU)
    ;noconv := LKey(R_NOCONV, 3, C_ZENKAKU)
    f13 := LKey("f13", 3, C_ZENKAKU)
    tab := LKey(R_TAB, 3, C_TAB)
    conv := LKey(R_CONV, 3, C_ENTER)
    noconv := LKey(R_NOCONV, 3, C_ENTER)
    ;conv := LKey(R_CONV, 3, C_BS)
    ;f14 := LKey("f14", 3, C_ZENKAKU)
    f14 := LKey("f14", 3, C_ENTER)
    space := LKey(R_SPACE, 3, C_SPACE)

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
    yen := LKey(C_YEN) ; ¥
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
    up := LKey(C_UP)
    down := LKey(C_DOWN)
    left := LKey(C_LEFT)
    right := LKey(C_RIGHT)

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
}

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

/**
 * 登録されているカスタムキーコンビネーション（レイヤーID > 8）および
 * 動的に拡張された修飾キーリスト（mod_key_list）を初期状態（長さ8）にリセットします。
 */
ResetCombinations() {
    global LAYOUT_KEYS, mod_key_list

    ; mod_key_list を初期の8要素にリセット
    if (mod_key_list.Length > 8) {
        mod_key_list.RemoveAt(9, mod_key_list.Length - 8)
    }

    ; すべてのキーからカスタムコンビネーション（layer_id > 8）を削除
    for keyObj in LAYOUT_KEYS {
        new_arr := []
        for item in keyObj.layers.arr {
            if (item.layer_id <= 8) {
                new_arr.Push(item)
            }
        }
        keyObj.layers.arr := new_arr

        new_ime_arr := []
        for item in keyObj.layers.ime_arr {
            if (item.layer_id <= 8) {
                new_ime_arr.Push(item)
            }
        }
        keyObj.layers.ime_arr := new_ime_arr
    }
}

/**
 * 設定ファイルから起動時のレイアウト設定を読み込み、適用します。
 */
LoadLayoutConfig() {
    try {
        LKey.hold_th := ReadConfigInt("Settings", "HoldTh", LKey.hold_th)
        LKey.pre_stroke_buf := ReadConfigInt("Settings", "PreStrokeBuf", LKey.pre_stroke_buf)
        Layers.b_time := ReadConfigInt("Settings", "b_time", Layers.b_time)
        Layers.b_time2 := ReadConfigInt("Settings", "b_time2", Layers.b_time2)
        Layers.hold_th := ReadConfigInt("Settings", "LayerHoldTh", Layers.hold_th)
        layout_name := ReadConfig("Settings", "StartupLayout", "")
        if layout_name = ""
            return

        ; ハードコードされたレイアウトを確認
        switch layout_name {
            case "Qwerty[Built-in]": ChangeQwertyLayout()
            case "Oonishi[Built-in]": ChangeOonishiLayout()
            case "Colemak[Built-in]": ChangeColemakLayout()
            case "FMIX12f[Built-in]": ChangeFMIX12f_Layout()
            case "FMIX12f-13fR[Built-in]": ChangeFMIX12f_FMIX13fR_Layout()
            case "FMIX14-14R[Built-in]": ChangeFMIX14_FMIX14R_Layout()
            case "FMIX15-15R[Built-in]": ChangeFMIX15_FMIX15R_Layout()
            case "FMIX13f-Minato[Built-in]": ChangeFMIX13f_Minato_Layout()
            case "TF2_2-Minato[Built-in]": ChangeTF2_2_Minato_Layout()
            case "STREAM1.5[Built-in]": ChangeSTREAM1_5_Layout()
            case "FMIX13-Minato[Built-in]": ChangeFMIX13_Minato_Layout()
            default:
                ; INIファイルからカスタムレイアウトの読み込みを試行
                LoadLayoutFromIni(layout_name)
        }
    } catch as err {
        MsgBox("Error in LoadLayoutConfig:`n" . err.Message . "`n" . err.Stack)
    }
}

; ============================================================================
; レイヤー状態判定関数
; ============================================================================
; (L_NAVI_CTRL 等のレイヤー定数、および mod_key_list はスクリプト先頭付近で定義され、Init() 内で初期化されます)

/**
 * キーボードレイヤーの状態管理と、レイヤーキー送信の差分ロジックをカプセル化するクラスです。
 */
class Layers {

    static hold_th := 200
    static b_time := 50 ; 長押しと判定する閾値 (ms)
    static b_time2 := 50 ; 長押しと判定する閾値 (ms)

    static last_active_item := ""

    /**
     * レイヤーにバインドされた個々のアクションを保持するインナークラスです。
     */
    class LayerItem {
        /**
         * コンストラクタ
         * @param {Integer} layer_id - レイヤーID
         * @param {String} action - 送信されるアクション定義
         * @param {String} [action2=""] - 2回目以降の送信されるアクション定義
         * @param {String} [action3=""] - 3回目以降の送信されるアクション定義
         * @param {int or HoldMode}] - 長押し動作モード
         */
        __New(layer_id, action, action2, action3, mode) {
            action1 := action
            if action2 == "" && action3 == "" && InStr(action, "|") && action != "|" {
                parts := StrSplit(action, "|")
                if parts.Length >= 3 {
                    action1 := parts[1]
                    action2 := parts[2]
                    action3 := parts[3]
                } else if parts.Length >= 2 {
                    action1 := parts[1]
                    action2 := parts[2]
                }
            }

            this.layer_id := layer_id
            this.action := action1
            this.action2 := action2
            this.action3 := action3
            this.tap_count := 0
            this.last_mod_key := ""
            this.last_mod_press_start_qpc := 0
            if (mode is HoldMode) {
                this.mode := mode.mode
                this.hold_th := mode.hold_th
                this.b_time := mode.b_time
            } else {
                this.mode := mode
                this.hold_th := -1
                this.b_time := -1
            }
        }

        /**
         * レイヤーアイテムの設定を複製します。状態カウント等は初期化されます。
         */
        Clone() {
            newItem := Layers.LayerItem(this.layer_id, this.action, this.action2, this.action3, this.mode)
            newItem.hold_th := this.hold_th
            newItem.b_time := this.b_time
            return newItem
        }
    }

    ime_arr := []
    arr := []
    ;static layer_id_list := [L_NAVI_CTRL, L_SYMBOL_NUM, L_SYMBOL1, L_SYMBOL2, L_SELECT, L_NUMPAD, L_SHIFT]

    /**
     * 特定のモディファイアレイヤー（M1〜M6）がアクティブかどうかを判定します。
     * 他のレイヤーが同時にアクティブでないことも確認します。
     * @param {Integer} layer - 確認するレイヤー番号
     * @returns {Boolean} 指定されたレイヤーのみがアクティブな場合は true
     */
    static State(layer) {
        if WinActive("ahk_group RemoteDesktops")
            return false

        if (layer < 1 || layer > mod_key_list.Length)
            return false

        key_navi := mod_key_list[L_NAVI_CTRL]
        key_symbol := mod_key_list[L_SYMBOL_NUM]
        key_conv := mod_key_list[L_SYMBOL1]
        key_f14 := mod_key_list[L_SYMBOL2]

        ; Check the specified layer
        if layer = L_NAVI_CTRL {
            return key_navi.IsPressed() && !(GetKeyState("Alt", "P") || key_symbol.IsPressed())
        }
        if layer = L_FUNC {
            return key_conv.IsPressed() && key_f14.IsPressed()
        }
        if layer = L_SYMBOL_NUM {
            return key_symbol.IsPressed() && !(key_navi.IsPressed() || GetKeyState("Alt", "P"))
        }
        if layer = L_SELECT {
            return key_navi.IsPressed() && (GetKeyState("Alt", "P") || key_symbol.IsPressed())
        }
        if layer = L_SYMBOL1 {
            return key_conv.IsPressed() && !key_f14.IsPressed()
        }
        if layer = L_SYMBOL2 {
            return key_f14.IsPressed() && !key_conv.IsPressed()
        }

        ; その他の単純なレイヤー判定は、対応するキーの押下状態を返す
        return mod_key_list[layer].IsPressed()
    }

    /**
     * 指定されたキーが自身でレイヤーキーである場合を除き、レイヤー状態がアクティブかどうかを厳密に判定します。
     * @param {Integer} layer - レイヤーID
     * @param {Array} arr - レイヤーアイテム配列
     * @param {Object} key_obj - 処理対象 of キーオブジェクト
     * @returns {Boolean} レイヤー状態が有効で、対象キーがそのトリガーでない場合は true
     */
    static State2(layer_id, key_obj) {
        if WinActive("ahk_group RemoteDesktops")
            return false

        if (layer_id < 1 || layer_id > mod_key_list.Length)
            return false

        key_navi := mod_key_list[L_NAVI_CTRL]
        key_symbol := mod_key_list[L_SYMBOL_NUM]
        key_conv := mod_key_list[L_SYMBOL1]
        key_f14 := mod_key_list[L_SYMBOL2]

        ; Check the specified layer
        if layer_id = L_NAVI_CTRL {
            if key_navi = key_obj
                return false
            if key_symbol = key_obj
                return false
            return key_navi.IsPressed() && !(GetKeyState("Alt", "P") || key_symbol.IsPressed())
        }
        if layer_id = L_SYMBOL_NUM {
            if key_symbol = key_obj
                return false
            if key_navi = key_obj
                return false
            return key_symbol.IsPressed() && !(key_navi.IsPressed() || GetKeyState("Alt", "P"))
        }

        if layer_id = L_SELECT {
            if key_navi = key_obj
                return false
            if key_symbol = key_obj
                return false
            return key_navi.IsPressed() && (GetKeyState("Alt", "P") || key_symbol.IsPressed())
        }
        if layer_id = L_FUNC {
            if key_conv = key_obj
                return false
            if key_f14 = key_obj
                return false
            return key_conv.IsPressed() && key_f14.IsPressed()
        }
        if layer_id = L_SYMBOL1 {
            if key_conv = key_obj
                return false
            return key_conv.IsPressed() && !key_f14.IsPressed()
        }
        if layer_id = L_SYMBOL2 {
            if key_f14 = key_obj
                return false
            return key_f14.IsPressed() && !key_conv.IsPressed()
        }

        key := mod_key_list[layer_id]
        if key = key_obj
            return false
        return key.IsPressed()
    }
    /**
     * レイヤー修飾キーを登録し、そのインデックスを返す
     * @param {HotKey} key_obj - 修飾キーオブジェクト
     * @returns {Integer} 登録後のレイヤーIDのインデックス
     */
    static Index(key_obj) {
        for i, key in mod_key_list {
            if key_obj = key
                return i
        }
        mod_key_list.Push(key_obj)
        return mod_key_list.Length
    }

    /**
     * アレイ内に同一レイヤーIDの項目が存在すれば更新し、なければ末尾に追加します（内部ユーティリティ）。
     * @param {Array} arr - 対象 of レイヤーアイテム配列
     * @param {LayerItem} item - 追加・更新するレイヤーアイテム
     */
    static _Add(arr, item) {
        for i, v in arr {
            if (v.layer_id == item.layer_id) {
                v.action := item.action
                v.action2 := item.action2
                v.action3 := item.action3
                v.mode := item.mode
                v.hold_th := item.hold_th
                v.b_time := item.b_time
                v.tap_count := 0
                v.last_mod_key := ""
                v.last_mod_press_start_qpc := 0
                if (Layers.last_active_item == v) {
                    Layers.last_active_item := ""
                }
                return
            }
        }
        arr.Push(item)
    }

    /**
     * IME ON 時のレイヤーアクションを設定します。
     * @param {Object} layer_item - 設定する LayerItem オブジェクト
     */
    SetIMEAction2(layer_item) {
        Layers._Add(this.ime_arr, layer_item)
    }

    /**
     * IME OFF 時のレイヤーアクションを設定します。
     * @param {Object} layer_item - 設定する LayerItem オブジェクト
     */
    SetAction2(layer_item) {
        Layers._Add(this.arr, layer_item)
    }

    /**
     * 指定されたレイヤー（src）のマッピングを別のレイヤー（dst）にコピーします。
     * @param {Integer} src - コピー元のレイヤーID
     * @param {Integer} dst - コピー先のレイヤーID
     */
    Copy(src, dst) {
        ; IME OFF
        for item in this.arr {
            if (item.layer_id == src) {
                new_item := item.Clone()
                new_item.layer_id := dst
                this.SetAction2(new_item)
                break
            }
        }
        ; IME ON
        for item in this.ime_arr {
            if (item.layer_id == src) {
                new_item := item.Clone()
                new_item.layer_id := dst
                this.SetIMEAction2(new_item)
                break
            }
        }
    }

    /**
     * 具体的なレイヤーアクションの送信を処理します（内部ヘルパー）。
     * @param {Integer} layer_id - レイヤーID
     * @param {String} action - 送信するキーアクション定義
     * @param {Object} key_obj - トリガーキーオブジェクト
     */
    _SendKey(layer_id, action, key_obj) {
        if action == "" {
            if (layer_id == L_SHIFT)
                key_obj.SendShiftedKey()
        } else {
            if action == "{none}"
                return
            SendAndLog(action)
            ;ToolTip action . " " . layer_id
        }
    }

    /**
     * 修飾キーとメインキーの押下状態を監視し、ホールド閾値の到達またはリリースを検出します。
     * @param {LKey} mod_key - 修飾側のキーオブジェクト
     * @param {LKey} key_obj - メイン側のキーオブジェクト
     * @param {Integer} hold_th - ホールド成立閾値 (ms)
     * @returns {Integer} 1: mod_key 先行Up, 2: key_obj 先行Up, 3: ホールド成立(時間超過)
     */
    static _WaitForHold(mod_key, key_obj, hold_th) {
        loop {
            if !mod_key.IsPressed()
                return 1
            if !key_obj.IsPressed()
                return 2
            if (HighPrecisionTimer() - mod_key.pressed_time_qpc >= hold_th)
                return 3
            Sleep(1)
        }
    }

    /**
     * 現在押下されている修飾レイヤーキーに基づいて、同時押し入力の判定および処理を行います。
     * @param {Object} key_obj - トリガーされたメインキーのオブジェクト
     * @param {Integer} ime_state - 現在のIME状態（0: OFF, 1: ON）
     * @returns {Boolean} 同時押しレイヤーアクションが発生して処理された場合は true、それ以外は false
     */
    SendLayerKey(key_obj, ime_state) {
        arr := ime_state == 1 ? this.ime_arr : this.arr
        for item in arr {
            if (item.layer_id < 1 || item.layer_id > mod_key_list.Length)
                continue
            mod_key := mod_key_list[item.layer_id]
            if (mod_key != key_obj && mod_key.IsPressed() && mod_key.state != LKey.st_init) {
                if Layers.State2(item.layer_id, key_obj) {
                    mod_hold_mode := (item.mode >= 0) ? item.mode : ((ime_state == 1) ? mod_key.hold_mode_ime_org :
                        mod_key.hold_mode_org)

                    is_held := false
                    t_qpc := HighPrecisionTimer() - mod_key.pressed_time_qpc
                    x := (item.hold_th >= 0) ? item.hold_th : Layers.hold_th
                    b := (item.b_time >= 0) ? item.b_time : ((mod_hold_mode == 8) ? Layers.b_time2 : Layers.b_time)

                    if (mod_hold_mode == 6) {
                        if (t_qpc >= x) {
                            is_held := true
                        } else {
                            res := Layers._WaitForHold(mod_key, key_obj, x)
                            is_held := (res == 3)
                        }
                    } else if (mod_hold_mode == 7) {
                        if (t_qpc >= x) {
                            is_held := true
                        } else if (t_qpc < x - b) {
                            is_held := false
                        } else {
                            res := Layers._WaitForHold(mod_key, key_obj, x)
                            is_held := (res == 3)
                        }
                    } else if (mod_hold_mode == 8) {
                        if (t_qpc >= x) {
                            is_held := true
                        } else if (t_qpc < x - b) {
                            is_held := false
                        } else {
                            res := Layers._WaitForHold(mod_key, key_obj, x)
                            is_held := (res == 2 || res == 3) ; メインキー先行Upまたは時間超過で修飾成立
                        }
                    } else if (mod_hold_mode == 9) {
                        if (t_qpc >= x) {
                            is_held := true
                        } else if (t_qpc < x - b) {
                            key_obj.SendKeyWithShift()
                            res := Layers._WaitForHold(mod_key, key_obj, x)
                            if (res == 3) {
                                Send("{Backspace}")
                                is_held := true
                            } else {
                                return true
                            }
                        } else {
                            res := Layers._WaitForHold(mod_key, key_obj, x)
                            is_held := (res == 3)
                        }
                    } else if (mod_hold_mode == 5) {
                        if (t_qpc >= x) {
                            is_held := true
                        } else if (t_qpc < x - b) {
                            is_held := false
                        } else {
                            res := Layers._WaitForHold(mod_key, key_obj, x)
                            is_held := (res == 3)
                        }

                        if !is_held {
                            if (mod_key.state == LKey.st_pressing)
                                mod_key.SendKeyWithShift()
                            mod_key.state := LKey.st_processed
                        }
                    } else {
                        is_held := (t_qpc >= x)
                    }

                    if is_held {
                        mod_key.state := LKey.st_processed
                        action_to_send := item.action
                        if (item.action2 != "" && item.action2 !== false) || (item.action3 != "" && item.action3 !==
                            false) {
                            ; 同一モディファイア押下セッション、かつ同一キーの連続打鍵判定
                            if (item.last_mod_key == mod_key && item.last_mod_press_start_qpc == mod_key.pressed_time_qpc &&
                                Layers.last_active_item == item) {
                                item.tap_count += 1
                            } else {
                                item.tap_count := 1
                                item.last_mod_key := mod_key
                                item.last_mod_press_start_qpc := mod_key.pressed_time_qpc
                            }
                            if (item.tap_count >= 3 && item.action3 != "" && item.action3 !== false) {
                                action_to_send := item.action3
                            } else if (item.tap_count >= 2 && item.action2 != "" && item.action2 !== false) {
                                action_to_send := item.action2
                            }
                        }
                        ; 直近のアクティブなレイヤーアイテムを更新
                        Layers.last_active_item := item

                        this._SendKey(item.layer_id, action_to_send, key_obj)
                        return true
                    }
                }
            }
        }
        return false
    }

}
/**
 * 長押しホールドモードのパラメータ（モード番号、ホールド閾値、バッファ時間）を保持するクラスです。
 */
class HoldMode {
    /**
     * コンストラクタ
     * @param {Integer} mode - 長押し動作モード
     * @param {Integer} [hold_th=-1] - ホールド判定閾値 (ms, -1=未指定)
     * @param {Integer} [b_time=-1] - ロールオーバー誤判定防止バッファ時間 (ms, -1=未指定)
     */
    __New(mode, hold_th := -1, b_time := -1) {
        this.mode := mode
        this.hold_th := hold_th
        this.b_time := b_time
    }
}

/**
 * IME ON 時の特定キーの同時押し（コンビネーション）に対し、連続打鍵数に応じたアクション（最大3段階）を登録します。
 * @param {Integer or HoldMode} mode - 長押し動作モード
 * @param {Object} layer_key_obj - 同時押しのトリガー（修飾側）となる LKey オブジェクト
 * @param {Object} key_obj - 同時押しされるメインキー of LKey オブジェクト
 * @param {String} text - 1回目の押下時に送信するアクション
 * @param {String} [text2=""] - 2回目の連続押下時に送信するアクション
 * @param {String} [text3=""] - 3回目以降の連続押下時に送信するアクション
 */
RegistIMECombination(mode, layer_key_obj, key_obj, text, text2 := "", text3 := "") {
    layer_item := Layers.LayerItem(Layers.Index(layer_key_obj), text, text2, text3, mode)
    key_obj.SetLayerImeKey2(layer_item)
    new_mode := IsObject(mode) ? mode.mode : mode
    if (new_mode != -1) {
        layer_key_obj.hold_mode_ime_org := new_mode
    } else if (layer_key_obj.hold_mode_ime_org == 0) {
        layer_key_obj.hold_mode_ime_org := 1
    }
}

/**
 * IME OFF 時の特定キーの同時押し（コンビネーション）に対し、連続打鍵数に応じたアクション（最大3段階）を登録します。
 * @param {Integer} mode - 長押し動作モード
 * @param {Object} layer_key_obj - 同時押しのトリガー（修飾側）となる LKey オブジェクト
 * @param {Object} key_obj - 同時押しされるメインキー of LKey オブジェクト
 * @param {String} text - 1回目の押下時に送信するアクション
 * @param {String} [text2=""] - 2回目の連続押下時に送信するアクション
 * @param {String} [text3=""] - 3回目以降の連続押下時に送信するアクション
 */
RegistCombination(mode, layer_key_obj, key_obj, text, text2 := "", text3 := "") {
    layer_item := Layers.LayerItem(Layers.Index(layer_key_obj), text, text2, text3, mode)
    key_obj.SetLayerKey2(layer_item, True)
    new_mode := IsObject(mode) ? mode.mode : mode
    if (new_mode != -1) {
        layer_key_obj.hold_mode_org := new_mode
    } else if (layer_key_obj.hold_mode_org == 0) {
        layer_key_obj.hold_mode_org := 1
    }
}

/**
 * config.ini に設定された現在のレイアウト（StartupLayout）を強制的に再読み込みして適用する
 */
LoadLayoutFromIni(index) {
    global L_NAVI_CTRL, L_SYMBOL_NUM, L_SYMBOL1, L_SYMBOL2, L_NUMPAD, L_SELECT, L_FUNC
    name := ReadConfig(index, "name", "")
    if name = "" {
        ; index がセクション名ではなくレイアウト名である場合の検索処理
        found := false
        loop 21 {
            sec := String(A_Index - 1)
            sec_name := ReadConfig(sec, "name", "")
            if sec_name = index {
                index := sec
                name := sec_name
                found := true
                break
            }
        }
        if !found {
            ChangeQwertyLayout()
            ApplyDynamicLayersFromSettings()
            return
        }
    }
    ver := ReadConfig(index, "ver", "1")
    success := false
    if ver = "1" {
        if ApplyLayoutFromIni(index)
            success := true
    } else if ver = "2" {
        if ApplyLayoutFromIni2(index) {
            ApplyLayerLayoutFromIni(L_NAVI_CTRL, "NAVI_CTRL")
            ApplyLayerLayoutFromIni(L_SYMBOL_NUM, "SYMBOL_NUM")
            ApplyLayerLayoutFromIni(L_SYMBOL1, "SYMBOL1")
            ApplyLayerLayoutFromIni(L_SYMBOL2, "SYMBOL2")
            ApplyLayerLayoutFromIni(L_SELECT, "SELECT")
            ApplyLayerLayoutFromIni(L_NUMPAD, "NUMPAD")
            ApplyLayerLayoutFromIni(L_FUNC, "FUNC")
            success := true
        }
    }
    if !success {
        ChangeQwertyLayout()
    }
    ApplyDynamicLayersFromSettings()
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
    num := ReadConfig(index, "Num", "1234567890-") L
    shift_layout := ReadConfig(index, "ShiftLayout", "")
    shift_num := ReadConfig(index, "ShiftNum", "")

    ; 基本レイアウトの設定
    StoreLayout(name, layout, num, shift_layout, shift_num)
    ResetIME() ; IME ON 時の個別設定を一旦リセット

    ; IME ON 時の個別設定があれば読み込む
    ime_layout := ReadConfig(index, "ImeLayout", "")
    ime_num := ReadConfig(index, "ImeNum", "")
    ime_shift_layout := ReadConfig(index, "ImeShiftLayout", "")
    ime_shift_num := ReadConfig(index, "ImeShiftNum", "")

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

/**
 * config.ini の指定されたセクションとプレフィックスに登録されている各キーマッピングを読み込み、マップを更新します。
 * QWERTY_CHARS に含まれるキーおよび特殊キーが順次読み込まれます。
 * @param {Map} layout_map - 更新対象のレイアウトマップ
 * @param {String} section - INIのセクション名
 * @param {String} [prefix=""] - キープレフィックス
 * @param {String} [ini_path=""] - INIファイルのパス
 */
ReadEachLayoutFromIni(layout_map, section, prefix := "", ini_path := "") {
    ini_map_loader := IniMap(layout_map, section, prefix, ini_path)
    for i, c in QWERTY_CHARS {
        ini_map_loader.Set(c)
    }
    ; 特殊キーの個別読み込み
    for i, c in LAYOUT_SPECIAL_NAMES {
        ini_map_loader.Set(c)
    }

    ; m_から始まるキー名の読み込み
    try {
        config_path := A_ScriptDir . "\config.ini"
        section_text := GetIniSection(config_path, section)
    } catch {
        section_text := ""
    }

    ; レイアウトの定義は、m_プレフィクスのキーで設定
    ReadLayerKey(layout_map, section_text, "m_", ini_path)
}

/**
 * config.iniから指定されたプレフィックスのコンビネーション（同時押し）定義を読み込み、クォーテーションを考慮してパースします。
 * @param {String} val - パース対象のカンマ区切り設定文字列
 * @returns {Array} パースされた各要素の配列
 */
ParseIniCombinationValue(val) {
    parts := []
    in_quotes := false
    current := ""
    loop parse, val {
        char := A_LoopField
        if (char == '"') {
            in_quotes := !in_quotes
            current .= char
        } else if (char == "," && !in_quotes) {
            parts.Push(Trim(current))
            current := ""
        } else {
            current .= char
        }
    }
    parts.Push(Trim(current))

    processed_parts := []
    for part in parts {
        processed_parts.Push(StripQuotes(part))
    }
    return processed_parts
}

#include "Preset.ahk"

; 終了・リロード時に保存
OnExit((*) => (TypeAnalyzer.Save(true), TypeAnalyzer.SaveConfig()))

; ============================================================================
; 設定の読み込み
; ============================================================================

/**
 * 構成設定ファイル (config.ini) を専用のエディタまたは規定のアプリで開きます。
 */
OpenConfigEditor(*) {
    ini_path := A_ScriptDir . "\config.ini"
    ini_content := ""
    if FileExist(ini_path) {
        try {
            ini_content := FileRead(ini_path, "UTF-8")
        } catch {
            ; fallback
        }
    }

    if ini_content != "" {
        hex_data := StringToHex(ini_content)
        url := "file:///" . StrReplace(A_ScriptDir, "\", "/") . "/ui/index.html#ini=" . hex_data
        Run(url)
    } else {
        Run('"' . A_ScriptDir . '\ui\index.html"')
    }
}

/**
 * ショートカットキーや記号レイヤーのヘルプ案内をOSDで表示します。
 */
ShowHelp() {
    ShowOSD("Help`n"
        . "Shift+全角/半角: 英数`n"
        . "Win+Alt+Enter: スクリプトの一時停止を切り替え`n"
        . "Win+M1+f: 強制IMEモードのON/OFF 切り替え`n"
        . "Win+M1+Up: マウス速度を上げる`n"
        . "Win+M1+Down: マウス速度を下げる`n"
        . "Win+M1+,: IMEインジケータの表示/非表示を切り替え`n"
        . "Win+M1+.: キーロガーのOn/Offを切り替`n"
        . "==記号レイヤ1==  ==記号レイヤ2==`n"
        . "|?|/|*|+| |    |!|@|#|$|%|`n"
        . "|(|)|_|-|=|    |&&|`'|`"|;|``|`n"
        . "|{|}|[|]|\|    |~|^|:|||\|`n"
        , 3000, True)
}

/**
 * スクリプト起動時の初期化処理（長押し動作の基本有効化、各レイヤーバインドの設定、設定ファイルやログの読み込み）を行います。
 */
Init() {
    g_freq := QueryFrequency()
    start_qpc := HighPrecisionTimer()

    DllCall("winmm\timeBeginPeriod", "UInt", 1, "UInt")

    ; 1. 文字列・キー変換用マップの初期化 (LKeyの生成に必要)
    InitMaps()

    ; 2. グローバルキー変数の初期化
    InitGlobalKeys()

    ; 3. モディファイアキーリストの初期化
    global mod_key_list
    ;                NAVI_CTRL,SYMBOL_NUM,SYMBOL1,SYMBOL2,SELECT,NUMPAD,SHIFT,FUNC
    mod_key_list := [f13, noconv, conv, f14, f13, tab, space, conv]

    ; 4. レイヤーとレイアウトの適用
    InitModLayer()

    ; 5. UI/GUI関連の初期化
    InitGUI()

    ; 6. レイアウト設定・ログの読み込み
    LoadLayoutConfig()
    TypeAnalyzer.Load()

    ; 7. トレイメニューやUIの設定
    A_TrayMenu.Add() ; セパレータ
    A_TrayMenu.Add("Key Layout Config Editorを開く", OpenConfigEditor)

    ; スクリプトと同じフォルダにあるアイコンファイルを指定
    if FileExist("klt.ico") {
        TraySetIcon("klt.ico")
    }

    ; 8. タイマーの開始 (初期化完了後に実行)
    SetTimer(TimerEvent, 100)

    end_qpc := HighPrecisionTimer()
    ShowOSD(Format("{} layout(init:{:.1f}ms)", TypeAnalyzer.current_layout, end_qpc - start_qpc), 5000)
}

Init()

#include "Handler.ahk"

; --- サスペンド（一時停止）ホットキー ---
#SuspendExempt ; 一時停止中でもサスペンドホットキーが動作するように許可
#!Enter:: Suspend ; Win+Alt+Enter でスクリプトの一時停止を切り替え
#SuspendExempt False
#MaxThreadsBuffer False
~*LButton:: ImeState.ResetComposition()