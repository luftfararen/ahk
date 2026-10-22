#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "test_framework.ahk"
#Include "..\src\PlayGroundsExp.ahk"

; ----------------------------------------------------------------------------
; Test Group 1: Layers._Add() の設定更新漏れ修正テスト
; ----------------------------------------------------------------------------
Test_Layers_Add_Update() {
    LogMsg("`n--- Test Group 1: Layers._Add() ---`n")

    test_layers := Layers()

    ; 初期アイテム登録 (mode 5, hold_th 200, b_time 50)
    item1 := Layers.LayerItem(1, "actionA", "actionA2", "actionA3", 5)
    item1.hold_th := 200
    item1.b_time := 50
    item1.tap_count := 5
    item1.last_mod_key := "dummy"
    test_layers.SetAction2(item1)

    found_item := test_layers.arr[1]
    Assert(found_item.mode == 5 && found_item.hold_th == 200 && found_item.b_time == 50,
        "Initial registration properties match")

    ; 同じ layer_id で新しい設定を再登録 (mode 7, hold_th 150, b_time 20)
    item2 := Layers.LayerItem(1, "newAction", "newAction2", "", 7)
    item2.hold_th := 150
    item2.b_time := 20
    test_layers.SetAction2(item2)

    Assert(test_layers.arr.Length == 1, "Array length remains 1 (no duplicate)")
    updated := test_layers.arr[1]
    Assert(updated.action == "newAction", "action updated")
    Assert(updated.action2 == "newAction2", "action2 updated")
    Assert(updated.action3 == "", "action3 cleared")
    Assert(updated.mode == 7, "mode updated to 7", "got: " . updated.mode)
    Assert(updated.hold_th == 150, "hold_th updated to 150", "got: " . updated.hold_th)
    Assert(updated.b_time == 20, "b_time updated to 20", "got: " . updated.b_time)
    Assert(updated.tap_count == 0, "tap_count reset to 0", "got: " . updated.tap_count)
    Assert(updated.last_mod_key == "", "last_mod_key reset", "got: " . updated.last_mod_key)

    ; IME 側 (ime_arr) も同様に確認
    item_ime1 := Layers.LayerItem(1, "imeA", "", "", 8)
    item_ime1.hold_th := 300
    item_ime1.b_time := 80
    test_layers.SetIMEAction2(item_ime1)

    item_ime2 := Layers.LayerItem(1, "imeB", "", "", 6)
    item_ime2.hold_th := 100
    item_ime2.b_time := 10
    test_layers.SetIMEAction2(item_ime2)

    updated_ime := test_layers.ime_arr[1]
    Assert(updated_ime.action == "imeB", "IME action updated")
    Assert(updated_ime.mode == 6, "IME mode updated to 6")
    Assert(updated_ime.hold_th == 100, "IME hold_th updated to 100")
    Assert(updated_ime.b_time == 10, "IME b_time updated to 10")
}

; ----------------------------------------------------------------------------
; Test Group 2: モード -1 の修飾キー継承テスト
; ----------------------------------------------------------------------------
Test_Mode_MinusOne_Inheritance() {
    LogMsg("`n--- Test Group 2: Mode -1 Inheritance ---`n")

    ; テスト用キーオブジェクト
    test_mod := LKey("q", 6) ; mode 6
    test_mod.hold_mode_org := 6
    test_mod.hold_mode_ime_org := 8

    test_main := LKey("w", 0) ; mode 0
    test_main.hold_mode_org := 0

    ; layer_item with mode = -1
    item := Layers.LayerItem(Layers.Index(test_mod), "comb_action", "", "", -1)
    test_main.SetLayerKey2(item, true)

    ; 登録後の item.mode がメインキーの 0 に書き換わらず -1 を維持しているか
    saved_item := test_main.layers.arr[1]
    Assert(saved_item.mode == -1, "item.mode remains -1 after SetLayerKey2", "got: " . saved_item.mode)

    ; SendLayerKey によるモード解決のシミュレーション
    ; IME OFF 時: mod_key の hold_mode_org (6) が継承されるべき
    resolved_off := (saved_item.mode >= 0) ? saved_item.mode : test_mod.hold_mode_org
    Assert(resolved_off == 6, "Inherited mode is 6 when IME OFF", "got: " . resolved_off)

    ; IME ON 時: mod_key の hold_mode_ime_org (8) が継承されるべき
    resolved_on := (saved_item.mode >= 0) ? saved_item.mode : test_mod.hold_mode_ime_org
    Assert(resolved_on == 8, "Inherited mode is 8 when IME ON", "got: " . resolved_on)

    ; メインキーのモードを変更しても継承モードが変わらないこと
    test_main.hold_mode_org := 4
    resolved_off_after_main_change := (saved_item.mode >= 0) ? saved_item.mode : test_mod.hold_mode_org
    Assert(resolved_off_after_main_change == 6, "Inherited mode unaffected by main key mode change", "got: " .
        resolved_off_after_main_change)

    ; 修飾キーのモードを変更したとき、動的に新しいモードが反映されること
    test_mod.hold_mode_org := 7
    resolved_off_after_mod_change := (saved_item.mode >= 0) ? saved_item.mode : test_mod.hold_mode_org
    Assert(resolved_off_after_mod_change == 7, "Inherited mode dynamically updates when mod key mode changes", "got: " .
        resolved_off_after_mod_change)

    ; 明示的なモード指定(例: 5)は上書きされないこと
    item_explicit := Layers.LayerItem(Layers.Index(test_mod), "act", "", "", 5)
    test_main.SetLayerKey2(item_explicit)
    saved_explicit := test_main.layers.arr[1]
    Assert(saved_explicit.mode == 5, "Explicit mode 5 is preserved", "got: " . saved_explicit.mode)
}

; ----------------------------------------------------------------------------
; Test Group 3: b_time = 0 の取り扱いテスト
; ----------------------------------------------------------------------------
Test_BTime_Zero() {
    LogMsg("`n--- Test Group 3: b_time = 0 Handling ---`n")

    ; 1. HoldMode(7, 200, 0) による明示的 b_time = 0
    hm_zero := HoldMode(7, 200, 0)
    item_zero := Layers.LayerItem(1, "act", "", "", hm_zero)
    Assert(item_zero.b_time == 0, "LayerItem preserves explicit b_time = 0", "got: " . item_zero.b_time)

    ; SendLayerKey 内での解決
    mod_hold_mode := item_zero.mode
    b_resolved := (item_zero.b_time >= 0) ? item_zero.b_time : Layers.b_time
    Assert(b_resolved == 0, "Resolved b_time is 0 when explicitly specified as 0", "got: " . b_resolved)

    ; 2. b_time 未指定 (デフォルト)
    item_default := Layers.LayerItem(1, "act", "", "", 7)
    Assert(item_default.b_time == -1, "LayerItem default b_time is -1 (unspecified)", "got: " . item_default.b_time)

    b_default_resolved := (item_default.b_time >= 0) ? item_default.b_time : ((mod_hold_mode == 8) ? Layers.b_time2 :
        Layers.b_time)
    Assert(b_default_resolved == Layers.b_time, "Resolved b_time is Layers.b_time when unspecified", "got: " .
        b_default_resolved)

    ; 3. モード 8 での b_time 未指定時 -> Layers.b_time2 が選択されること
    item_mode8 := Layers.LayerItem(1, "act", "", "", 8)
    b_mode8_resolved := (item_mode8.b_time >= 0) ? item_mode8.b_time : ((item_mode8.mode == 8) ? Layers.b_time2 :
        Layers.b_time)
    Assert(b_mode8_resolved == Layers.b_time2, "Resolved b_time for mode 8 is Layers.b_time2 when unspecified", "got: " .
        b_mode8_resolved)

    ; 4. モード 8 で明示的 b_time = 0 -> 0 が選択されること
    hm_mode8_zero := HoldMode(8, 200, 0)
    item_mode8_zero := Layers.LayerItem(1, "act", "", "", hm_mode8_zero)
    b_mode8_zero_resolved := (item_mode8_zero.b_time >= 0) ? item_mode8_zero.b_time : ((item_mode8_zero.mode == 8) ?
        Layers.b_time2 : Layers.b_time)
    Assert(b_mode8_zero_resolved == 0, "Resolved b_time for mode 8 is 0 when explicitly specified as 0", "got: " .
        b_mode8_zero_resolved)
}

; ----------------------------------------------------------------------------
; Test Group 4: モード5・7・8・9の境界条件テスト (x-b-1, x-b, x-b+1, x-1, x, x+1)
; ----------------------------------------------------------------------------
SimulateModeDecision(mode, t, x, b, wait_result) {
    ; wait_result: 1 = mod_key先行Up, 2 = key_obj先行Up, 3 = 時間超過
    if (mode == 5) {
        if (t >= x) {
            return { is_held: true, send_a_normal: false, a_state_processed: true }
        } else if (t < x - b) {
            return { is_held: false, send_a_normal: true, a_state_processed: true }
        } else {
            if (wait_result == 3) {
                return { is_held: true, send_a_normal: false, a_state_processed: true }
            } else {
                return { is_held: false, send_a_normal: true, a_state_processed: true }
            }
        }
    } else if (mode == 7) {
        if (t >= x) {
            return { is_held: true }
        } else if (t < x - b) {
            return { is_held: false }
        } else {
            return { is_held: (wait_result == 3) }
        }
    } else if (mode == 8) {
        if (t >= x) {
            return { is_held: true }
        } else if (t < x - b) {
            return { is_held: false }
        } else {
            return { is_held: (wait_result == 2 || wait_result == 3) }
        }
    } else if (mode == 9) {
        if (t >= x) {
            return { is_held: true, bs: false }
        } else if (t < x - b) {
            return { is_held: (wait_result == 3), bs: (wait_result == 3) }
        } else {
            return { is_held: (wait_result == 3), bs: false }
        }
    }
}

Test_Boundary_Conditions_All_Modes() {
    LogMsg("`n--- Test Group 4: Boundary Conditions for Modes 5, 7, 8, 9 ---`n")
    x := 200 ; hold_th
    b := 50  ; b_time
    ; 境界値: 149 (x-b-1), 150 (x-b), 151 (x-b+1), 199 (x-1), 200 (x), 201 (x+1)

    ; --- Mode 5 ---
    Assert(SimulateModeDecision(5, 149, x, b, 1).send_a_normal == true,
    "Mode 5 (x-b-1=149): Rollover -> A normal key sent")
    Assert(SimulateModeDecision(5, 150, x, b, 3).is_held == true, "Mode 5 (x-b=150, wait=3): Buffer start -> Held")
    Assert(SimulateModeDecision(5, 150, x, b, 1).send_a_normal == true,
    "Mode 5 (x-b=150, wait=1): Buffer start -> A先行Up -> Normal key")
    Assert(SimulateModeDecision(5, 151, x, b, 3).is_held == true, "Mode 5 (x-b+1=151, wait=3): Inside buffer -> Held")
    Assert(SimulateModeDecision(5, 199, x, b, 3).is_held == true,
    "Mode 5 (x-1=199, wait=3): Just before threshold -> Held")
    Assert(SimulateModeDecision(5, 200, x, b, 0).is_held == true, "Mode 5 (x=200): Exact threshold -> Held directly")
    Assert(SimulateModeDecision(5, 201, x, b, 0).is_held == true, "Mode 5 (x+1=201): Past threshold -> Held directly")

    ; --- Mode 7 ---
    Assert(SimulateModeDecision(7, 149, x, b, 1).is_held == false, "Mode 7 (x-b-1=149): Rollover -> Not held")
    Assert(SimulateModeDecision(7, 150, x, b, 3).is_held == true, "Mode 7 (x-b=150, wait=3): Buffer start -> Held")
    Assert(SimulateModeDecision(7, 150, x, b, 2).is_held == false, "Mode 7 (x-b=150, wait=2): B先行Up -> Not held")
    Assert(SimulateModeDecision(7, 151, x, b, 3).is_held == true, "Mode 7 (x-b+1=151, wait=3): Inside buffer -> Held")
    Assert(SimulateModeDecision(7, 199, x, b, 3).is_held == true,
    "Mode 7 (x-1=199, wait=3): Just before threshold -> Held")
    Assert(SimulateModeDecision(7, 200, x, b, 0).is_held == true, "Mode 7 (x=200): Exact threshold -> Held directly")
    Assert(SimulateModeDecision(7, 201, x, b, 0).is_held == true, "Mode 7 (x+1=201): Past threshold -> Held directly")

    ; --- Mode 8 ---
    Assert(SimulateModeDecision(8, 149, x, b, 1).is_held == false, "Mode 8 (x-b-1=149): Rollover -> Not held")
    Assert(SimulateModeDecision(8, 150, x, b, 2).is_held == true,
    "Mode 8 (x-b=150, wait=2): B先行Up -> Held (special for Mode 8)")
    Assert(SimulateModeDecision(8, 150, x, b, 1).is_held == false, "Mode 8 (x-b=150, wait=1): A先行Up -> Not held")
    Assert(SimulateModeDecision(8, 151, x, b, 2).is_held == true,
    "Mode 8 (x-b+1=151, wait=2): Inside buffer B先行Up -> Held")
    Assert(SimulateModeDecision(8, 199, x, b, 2).is_held == true,
    "Mode 8 (x-1=199, wait=2): Just before threshold B先行Up -> Held")
    Assert(SimulateModeDecision(8, 200, x, b, 0).is_held == true, "Mode 8 (x=200): Exact threshold -> Held directly")
    Assert(SimulateModeDecision(8, 201, x, b, 0).is_held == true, "Mode 8 (x+1=201): Past threshold -> Held directly")

    ; --- Mode 9 ---
    Assert(SimulateModeDecision(9, 149, x, b, 3).is_held == true && SimulateModeDecision(9, 149, x, b, 3).bs == true,
    "Mode 9 (x-b-1=149, wait=3): Rollover + Timeout -> Backspace then combination")
    Assert(SimulateModeDecision(9, 149, x, b, 2).is_held == false,
    "Mode 9 (x-b-1=149, wait=2): Rollover + B先行Up -> Normal key only, no Backspace")
    Assert(SimulateModeDecision(9, 150, x, b, 3).is_held == true && SimulateModeDecision(9, 150, x, b, 3).bs == false,
    "Mode 9 (x-b=150, wait=3): Buffer -> Combination directly, no Backspace")
    Assert(SimulateModeDecision(9, 200, x, b, 0).is_held == true, "Mode 9 (x=200): Exact threshold -> Held directly")
}

; ----------------------------------------------------------------------------
; Test Group 5: 2キー解放順序マトリクステスト (ケース1〜8)
; ----------------------------------------------------------------------------
Test_Key_Release_Matrix() {
    LogMsg("`n--- Test Group 5: 2-Key Release Order Matrix (Cases 1-8) ---`n")
    x := 200, b := 50

    ; ケース1: A押し -> 閾値十分前(t < x-b)にB押し -> A先にUp
    ; 期待値: A通常, B通常, レイヤーなし
    m5_c1 := SimulateModeDecision(5, 80, x, b, 1)
    Assert(m5_c1.is_held == false && m5_c1.send_a_normal == true, "Case 1 (Mode 5): Rollover -> A normal, B normal")
    m8_c1 := SimulateModeDecision(8, 80, x, b, 1)
    Assert(m8_c1.is_held == false, "Case 1 (Mode 8): Rollover -> A normal(Down), B normal")

    ; ケース2: A押し -> 閾値十分前(t < x-b)にB押し -> B先にUp
    ; 期待値: A通常, B通常, レイヤーなし
    m5_c2 := SimulateModeDecision(5, 80, x, b, 2)
    Assert(m5_c2.is_held == false && m5_c2.send_a_normal == true, "Case 2 (Mode 5): Rollover -> A normal, B normal")
    m8_c2 := SimulateModeDecision(8, 80, x, b, 2)
    Assert(m8_c2.is_held == false, "Case 2 (Mode 8): Rollover -> A normal(Down), B normal")

    ; ケース3: バッファ期間内にB押し -> A先にUp
    ; 期待値: A通常, B通常, レイヤーなし
    m5_c3 := SimulateModeDecision(5, 170, x, b, 1)
    Assert(m5_c3.is_held == false && m5_c3.send_a_normal == true,
        "Case 3 (Mode 5): A released first in buffer -> Normal keys")
    m8_c3 := SimulateModeDecision(8, 170, x, b, 1)
    Assert(m8_c3.is_held == false, "Case 3 (Mode 8): A released first in buffer -> Normal keys")

    ; ケース4: バッファ期間内にB押し -> B先にUp
    ; 期待値: モード5は通常キー、モード8はレイヤーアクション成立！
    m5_c4 := SimulateModeDecision(5, 170, x, b, 2)
    Assert(m5_c4.is_held == false && m5_c4.send_a_normal == true,
        "Case 4 (Mode 5): B released first in buffer -> Normal keys")
    m8_c4 := SimulateModeDecision(8, 170, x, b, 2)
    Assert(m8_c4.is_held == true, "Case 4 (Mode 8): B released first in buffer -> Combination sent!")

    ; ケース5: バッファ期間内にB押し -> 両キー保持で閾値超過
    ; 期待値: レイヤーアクション成立
    m5_c5 := SimulateModeDecision(5, 170, x, b, 3)
    Assert(m5_c5.is_held == true && m5_c5.send_a_normal == false,
        "Case 5 (Mode 5): Hold exceeded in buffer -> Combination sent, no A normal")
    m8_c5 := SimulateModeDecision(8, 170, x, b, 3)
    Assert(m8_c5.is_held == true, "Case 5 (Mode 8): Hold exceeded in buffer -> Combination sent")

    ; ケース6: 閾値直前 (x - 1) にB押し -> 直後にAまたはB解放
    ; 期待値: A先行Upなら通常キー、B先行Upはモード8ならレイヤー成立
    m5_c6A := SimulateModeDecision(5, 199, x, b, 1)
    Assert(m5_c6A.is_held == false && m5_c6A.send_a_normal == true,
        "Case 6-A (Mode 5, t=199): A released first -> Normal key")
    m8_c6B := SimulateModeDecision(8, 199, x, b, 2)
    Assert(m8_c6B.is_held == true, "Case 6-B (Mode 8, t=199): B released first -> Combination sent")

    ; ケース7: タイマーとキー解放処理の競合
    test_key := LKey("r", 1)
    test_key.pressed_time_qpc := HighPrecisionTimer()
    test_key.state := LKey.st_pressing
    test_key.interrupted := false
    ; 早期発火シミュレーション -> 再スケジュールされ、stateはst_pressing維持
    test_key.OnHoldTimeout()
    Assert(test_key.state == LKey.st_pressing, "Case 7: Early timeout does not replace key prematurely")

    ; ケース8: ほぼ同時のキーDown/Up (t ~ 0)
    m5_c8 := SimulateModeDecision(5, 1, x, b, 1)
    Assert(m5_c8.is_held == false && m5_c8.send_a_normal == true,
        "Case 8: Near-simultaneous Down/Up -> Rollover normal keys")
}

; ----------------------------------------------------------------------------
; Test Group 6: b_time 特殊値テスト (b_time = 0, b_time = hold_th, b_time > hold_th)
; ----------------------------------------------------------------------------
Test_BTime_Special_Values() {
    LogMsg("`n--- Test Group 6: b_time Special Edge Cases ---`n")
    x := 200

    ; 1. b_time = 0: グレーゾーンが存在せず、t < x で即ロールオーバー、t >= x でホールド
    b_zero := 0
    Assert(SimulateModeDecision(5, 199, x, b_zero, 0).send_a_normal == true,
    "b_time = 0: t = 199 (< x) -> Immediate rollover normal key")
    Assert(SimulateModeDecision(5, 200, x, b_zero, 0).is_held == true,
    "b_time = 0: t = 200 (>= x) -> Immediate combination")

    ; 2. b_time = 1: 最小のグレーゾーン (199 <= t < 200)
    b_one := 1
    Assert(SimulateModeDecision(5, 198, x, b_one, 0).send_a_normal == true, "b_time = 1: t = 198 (< 199) -> Rollover")
    Assert(SimulateModeDecision(5, 199, x, b_one, 3).is_held == true,
    "b_time = 1: t = 199 (gray zone) -> Wait for hold")

    ; 3. b_time = hold_th (200): バッファが閾値全体をカバー (0 <= t < 200)
    b_equal := 200
    Assert(SimulateModeDecision(5, 50, x, b_equal, 3).is_held == true,
    "b_time = hold_th: t = 50 -> Inside buffer, timeout gives combination")
    Assert(SimulateModeDecision(5, 50, x, b_equal, 1).send_a_normal == true,
    "b_time = hold_th: t = 50 -> Inside buffer, A release gives normal key")

    ; 4. b_time > hold_th (250 > 200): x - b < 0 なので常にバッファ内
    b_large := 250
    Assert(SimulateModeDecision(5, 10, x, b_large, 3).is_held == true,
    "b_time > hold_th: t = 10 -> Inside buffer, timeout gives combination")
}

; ----------------------------------------------------------------------------
; Test Group 7: タイマー競合・再スケジュールテスト
; ----------------------------------------------------------------------------
Test_Timer_Reschedule_And_Race() {
    LogMsg("`n--- Test Group 7: Timer Reschedule and Race Prevention ---`n")

    test_key := LKey("t", 1) ; mode 1
    test_key.pressed_time_qpc := HighPrecisionTimer()
    test_key.state := LKey.st_pressing
    test_key.interrupted := false

    ; 1. 閾値未満での早期発火 (duration ~ 10ms < 300ms)
    test_key.pressed_time_qpc := HighPrecisionTimer() - 10
    test_key.OnHoldTimeout()
    Assert(test_key.state == LKey.st_pressing, "Timer early fire: state remains st_pressing")

    ; 2. 閾値到達での発火 (duration >= 300ms)
    test_key.pressed_time_qpc := HighPrecisionTimer() - (LKey.hold_th + 5)
    test_key.OnHoldTimeout()
    Assert(test_key.state == LKey.st_processed, "Timer at threshold: state becomes st_processed")

    ; 3. 確定後の重複呼び出し防止
    test_key.OnHoldTimeout()
    Assert(test_key.state == LKey.st_processed, "Duplicate OnHoldTimeout ignored")

    ; 4. Up による競合防止 (Up が先に実行された場合)
    test_key2 := LKey("y", 1)
    test_key2.pressed_time_qpc := HighPrecisionTimer() - 50
    test_key2.state := LKey.st_pressing
    test_key2.Up()
    Assert(test_key2.state == LKey.st_init, "Key Up: state resets to st_init")
    ; 後からタイマーが発火しても無視されること
    test_key2.OnHoldTimeout()
    Assert(test_key2.state == LKey.st_init, "OnHoldTimeout after Up is completely ignored")
}

; ----------------------------------------------------------------------------
; Test Group 8: Qwerty レイアウト切り替えと ResetCombinations テスト
; ----------------------------------------------------------------------------
Test_Qwerty_Layout_Switch() {
    LogMsg("`n--- Test Group 8: Qwerty Layout Switch & ResetCombinations ---`n")
    global mod_key_list, q, a, w

    ; 1. カスタムコンビネーション追加シミュレーション
    dummy_key := LKey("f15", 3)
    Layers.Index(dummy_key) ; mod_key_list に9番目の要素が追加される
    Assert(mod_key_list.Length >= 9, "mod_key_list extended with custom key (length >= 9)", "got: " . mod_key_list.Length
    )

    ; 2. ChangeQwertyLayout() を実行
    ChangeQwertyLayout()
    ; mod_key_list が初期の 8 要素（L_FUNC含む）を維持していること
    Assert(mod_key_list.Length == 8, "mod_key_list reset to exact 8 items (preserving L_FUNC)", "got: " . mod_key_list.Length
    )

    ; 3. すべてのキーのレイヤーアイテムが mod_key_list の範囲内にあること
    no_overflow := true
    global LAYOUT_KEYS
    for keyObj in LAYOUT_KEYS {
        for item in keyObj.layers.arr {
            if (item.layer_id > mod_key_list.Length) {
                no_overflow := false
                break 2
            }
        }
    }
    Assert(no_overflow, "No layer item exceeds mod_key_list bounds after ResetCombinations")

    ; 4. キー打鍵（SendLayerKey）が例外なく実行できること
    try {
        q.SendLayerKey(0)
        a.SendLayerKey(0)
        w.SendLayerKey(0)
        Assert(true, "SendLayerKey executed successfully with no Invalid index error after layout switch")
    } catch as err {
        Assert(false, "SendLayerKey threw exception after layout switch", err.Message)
    }
}

; ----------------------------------------------------------------------------
; Test Group 11: _WaitForHold 割り込み検知 & Down() キー解放安全ガード
; ----------------------------------------------------------------------------
Test_WaitForHold_Interruption_And_SafetyGuard() {
    LogMsg("`n--- Test Group 11: _WaitForHold Interruption & Safety Guard ---`n")

    mod_key := LKey("q", 3)
    mod_key.pressed_time_qpc := HighPrecisionTimer()
    mod_key.state := LKey.st_pressing
    mod_key.interrupted := false

    main_key := LKey("w", 0)

    ; 1. mod_key.interrupted == true の場合、_WaitForHold が即座に 0 を返すこと
    mod_key.interrupted := true
    res := Layers._WaitForHold(mod_key, main_key, 200)
    Assert(res == 0, "_WaitForHold returns 0 immediately when mod_key is interrupted", "got: " . res)

    ; 2. mod_key.state != st_pressing の場合、_WaitForHold が即座に 0 を返すこと
    mod_key.interrupted := false
    mod_key.state := LKey.st_processed
    res := Layers._WaitForHold(mod_key, main_key, 200)
    Assert(res == 0, "_WaitForHold returns 0 immediately when mod_key.state != st_pressing", "got: " . res)

    ; 3. key_obj.Down() の安全ガード: 待機中にキーが物理解放された場合、state が st_pressing に上書きされず st_init を維持すること
    test_key := LKey("x", 4)
    test_key.state := LKey.st_init
    test_key.pressed_time_qpc := 0
    ; 物理的に押されていない状態（GetKeyState("x", "P") == 0）で Down() を実行
    test_key.Down()
    Assert(test_key.state == LKey.st_init, "Safety guard: state remains st_init after Down() when key is not physically held", "got: " . test_key.state)
    Assert(test_key.pressed_time_qpc == 0, "Safety guard: pressed_time_qpc remains 0", "got: " . test_key.pressed_time_qpc)
}

RunHoldModeTests() {
    InitTestSuite("HOLD MODE & CORE REGRESSION TESTS")
    Test_Layers_Add_Update()
    Test_Mode_MinusOne_Inheritance()
    Test_BTime_Zero()
    Test_Boundary_Conditions_All_Modes()
    Test_Key_Release_Matrix()
    Test_BTime_Special_Values()
    Test_Timer_Reschedule_And_Race()
    Test_Qwerty_Layout_Switch()
    Test_WaitForHold_Interruption_And_SafetyGuard()
    FinishTestSuite()
}

; 直接実行された場合のみ自動実行
if (A_LineFile == A_ScriptFullPath) {
    RunHoldModeTests()
}
