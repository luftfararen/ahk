#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "test_framework.ahk"
#Include "..\src\PlayGroundsExp.ahk"

; ----------------------------------------------------------------------------
; Test Group 9: layer_id と mod_key_id の管理構造および判定テスト
; ----------------------------------------------------------------------------
Test_LayerId_To_ModKeyId_Mapping() {
    LogMsg("`n--- Test Group 9: layer_id to mod_key_id Mapping ---`n")
    global layer_id_to_mod_key_id, L_NAVI_CTRL, L_SYMBOL_NUM, L_SYMBOL1, L_SYMBOL2
    global L_SELECT, L_NUMPAD, L_SHIFT, L_FUNC
    global M1, M2, M3, M4, M5, M6, M7, M8

    ; 1. 定数の妥当性確認
    Assert(L_NAVI_CTRL == 1 && L_SYMBOL_NUM == 2 && L_SHIFT == 7 && L_FUNC == 8,
        "Layer ID constants defined correctly")
    Assert(M1 == 1 && M2 == 2 && M7 == 7 && M8 == 8,
        "mod_key_id (M1..M8) constants defined correctly")

    ; 2. 初期配列の紐付け確認
    Assert(layer_id_to_mod_key_id[L_NAVI_CTRL] == M1, "L_NAVI_CTRL mapped to M1")
    Assert(layer_id_to_mod_key_id[L_SYMBOL_NUM] == M2, "L_SYMBOL_NUM mapped to M2")
    Assert(layer_id_to_mod_key_id[L_SELECT] == M5, "L_SELECT mapped to M5")
    Assert(layer_id_to_mod_key_id[L_SHIFT] == M7, "L_SHIFT mapped to M7")
    Assert(layer_id_to_mod_key_id[L_FUNC] == M8, "L_FUNC mapped to M8")

    ; 3. ResolveLayerId / ResolveModKeyId の動作確認
    Assert(ResolveLayerId("NAVI_CTRL") == L_NAVI_CTRL, "ResolveLayerId('NAVI_CTRL') == L_NAVI_CTRL")
    Assert(ResolveLayerId("L_SHIFT") == L_SHIFT, "ResolveLayerId('L_SHIFT') == L_SHIFT")
    Assert(ResolveModKeyId("M1") == 1, "ResolveModKeyId('M1') == 1")
    Assert(ResolveModKeyId("space") == 7, "ResolveModKeyId('space') == 7 (M7)")
    Assert(ResolveModKeyId("f13") == 1, "ResolveModKeyId('f13') == 1 (M1)")
    Assert(ResolveModKeyId("noconv") == 2, "ResolveModKeyId('noconv') == 2 (M2)")

    ; 4. BindLayerToModKey による動的バインド変更テスト
    orig_binding := layer_id_to_mod_key_id.Clone()
    BindLayerToModKey(L_NAVI_CTRL, M7)
    Assert(GetModKeyIdByLayerId(L_NAVI_CTRL) == M7, "L_NAVI_CTRL dynamically rebound to M7")

    ; 未設定 (0) 時の Layers.State() 評価テスト
    BindLayerToModKey(L_NAVI_CTRL, 0)
    Assert(Layers.State(L_NAVI_CTRL) == false, "Layers.State returns false when layer is unmapped (mod_key_id == 0)")

    ; 範囲外 layer_id 評価テスト
    Assert(Layers.State(999) == false, "Layers.State returns false for out-of-range layer_id")

    ; 元の状態に復元
    global layer_id_to_mod_key_id := orig_binding
}

; ----------------------------------------------------------------------------
; Test Group 10: INIファイルの layer_id / mod_key_id 入出力テスト
; ----------------------------------------------------------------------------
Test_Ini_Layer_Binding() {
    LogMsg("`n--- Test Group 10: INI Layer Binding I/O ---`n")
    global layer_id_to_mod_key_id, L_NAVI_CTRL, L_SYMBOL_NUM, L_SHIFT, M1, M2, M7

    test_ini := A_ScriptDir . "\test_binding.ini"
    try FileDelete(test_ini)

    ; テスト用INIファイルの作成
    ini_content := "[Settings]`n"
        . "space=NAVI_CTRL`n"
        . "noconv=SYMBOL_NUM`n"
        . "`n"
        . "[NAVI_CTRL]`n"
        . "a=^a`n"
        . "z=^z`n"
    FileAppend(ini_content, test_ini, "CP0")

    ; INIからのバインディング読み込み
    LoadLayerBindingsFromIni(test_ini)

    ; space=NAVI_CTRL -> L_NAVI_CTRL (1) が space (M7 = 7) にバインドされていること
    Assert(GetModKeyIdByLayerId(L_NAVI_CTRL) == 7, "INI: space=NAVI_CTRL binds L_NAVI_CTRL to M7 (7)",
        "got: " . GetModKeyIdByLayerId(L_NAVI_CTRL))
    ; noconv=SYMBOL_NUM -> L_SYMBOL_NUM (2) が noconv (M2 = 2) にバインドされていること
    Assert(GetModKeyIdByLayerId(L_SYMBOL_NUM) == 2, "INI: noconv=SYMBOL_NUM binds L_SYMBOL_NUM to M2 (2)",
        "got: " . GetModKeyIdByLayerId(L_SYMBOL_NUM))

    ; SaveLayerBindingsToIni のテスト
    SaveLayerBindingsToIni(test_ini)
    saved_text := FileRead(test_ini)
    Assert(InStr(saved_text, "[LayerBinding]"), "INI: [LayerBinding] section created by SaveLayerBindingsToIni")
    Assert(InStr(saved_text, "NAVI_CTRL=M7"), "INI: NAVI_CTRL=M7 saved correctly")

    ; [LayerBinding] セクションからの明示的な読み込みテスト
    layer_id_to_mod_key_id := [1, 2, 3, 4, 5, 6, 7, 8] ; 一旦リセット
    LoadLayerBindingsFromIni(test_ini)
    Assert(GetModKeyIdByLayerId(L_NAVI_CTRL) == 7, "INI: Reloaded NAVI_CTRL binding from saved [LayerBinding]")

    ; クリーンアップ
    try FileDelete(test_ini)
    ; デフォルトバインディングに復元
    layer_id_to_mod_key_id := [M1, M2, 3, 4, 5, 6, M7, 8]
}

; ----------------------------------------------------------------------------
; Test Group 11: 新仕様 [LayerBinding] 配列構造・完全往復・耐性テスト
; ----------------------------------------------------------------------------
Test_New_LayerBinding_Specification() {
    LogMsg("`n--- Test Group 11: New LayerBinding Spec & Robustness ---`n")
    global layer_id_to_mod_key_id, L_NAVI_CTRL, L_SYMBOL_NUM, L_SYMBOL1, L_SYMBOL2
    global L_SELECT, L_NUMPAD, L_SHIFT, L_FUNC
    global M1, M2, M3, M4, M5, M6, M7, M8

    orig_bindings := layer_id_to_mod_key_id.Clone()
    test_ini := A_ScriptDir . "\test_new_spec.ini"
    try FileDelete(test_ini)

    ; 1. 新仕様による全レイヤー配列の正常読み込みテスト
    ini_content1 := "[LayerBinding]`n"
        . "NAVI_CTRL=M1`n"
        . "SYMBOL_NUM=M2`n"
        . "SYMBOL1=M3`n"
        . "SYMBOL2=M4`n"
        . "SELECT=M5`n"
        . "NUMPAD=M6`n"
        . "SHIFT=M7`n"
        . "FUNC=M8`n"
        . "CUSTOM_DYNAMIC=M3`n"
    FileAppend(ini_content1, test_ini, "CP0")

    LoadLayerBindingsFromIni(test_ini)
    Assert(GetModKeyIdByLayerId(L_NAVI_CTRL) == 1, "Spec: NAVI_CTRL bound to M1")
    Assert(GetModKeyIdByLayerId(L_SYMBOL_NUM) == 2, "Spec: SYMBOL_NUM bound to M2")
    Assert(GetModKeyIdByLayerId(L_SELECT) == 5, "Spec: SELECT bound to M5")
    Assert(GetModKeyIdByLayerId(L_SHIFT) == 7, "Spec: SHIFT bound to M7")
    Assert(GetModKeyIdByLayerId(L_FUNC) == 8, "Spec: FUNC bound to M8")
    dyn_id := ResolveLayerId("CUSTOM_DYNAMIC", false)
    Assert(dyn_id > 8 && GetModKeyIdByLayerId(dyn_id) == 3, "Spec: Dynamic CUSTOM_DYNAMIC bound to M3")

    ; 2. 明示的な無効化 ("none", "0", "") テスト
    try FileDelete(test_ini)
    ini_content2 := "[LayerBinding]`n"
        . "SELECT=none`n"
        . "NUMPAD=0`n"
    FileAppend(ini_content2, test_ini, "CP0")
    LoadLayerBindingsFromIni(test_ini)
    Assert(GetModKeyIdByLayerId(L_SELECT) == 0, "Spec: SELECT=none sets mod_key_id to 0 (disabled)")
    Assert(Layers.State(L_SELECT) == false, "Spec: Layers.State(SELECT) is false when disabled")
    Assert(GetModKeyIdByLayerId(L_NUMPAD) == 0, "Spec: NUMPAD=0 sets mod_key_id to 0 (disabled)")

    ; 3. 不正値・未知のIDに対する安全なフォールバックテスト
    try FileDelete(test_ini)
    ini_content3 := "[LayerBinding]`n"
        . "NAVI_CTRL=M99999`n"
        . "SYMBOL_NUM=INVALID_VAL`n"
    FileAppend(ini_content3, test_ini, "CP0")
    LoadLayerBindingsFromIni(test_ini)
    Assert(GetModKeyIdByLayerId(L_NAVI_CTRL) == M1, "Spec: NAVI_CTRL falls back to default M1 on unknown ID")
    Assert(GetModKeyIdByLayerId(L_SYMBOL_NUM) == M2, "Spec: SYMBOL_NUM falls back to default M2 on invalid value")

    ; 4. 記述順序非依存性の検証 (逆順記述)
    try FileDelete(test_ini)
    ini_content4 := "[LayerBinding]`n"
        . "FUNC=M8`n"
        . "SHIFT=M7`n"
        . "NUMPAD=M6`n"
        . "SELECT=M5`n"
        . "SYMBOL2=M4`n"
        . "SYMBOL1=M3`n"
        . "SYMBOL_NUM=M2`n"
        . "NAVI_CTRL=M1`n"
    FileAppend(ini_content4, test_ini, "CP0")
    LoadLayerBindingsFromIni(test_ini)
    loop 8 {
        Assert(layer_id_to_mod_key_id[A_Index] == A_Index, "Spec: Reverse-order entry accurately restores index " . A_Index)
    }

    ; 5. 完全往復 (Save -> Re-read -> Compare) 保存テスト
    try FileDelete(test_ini)
    custom_order := [M7, M6, M5, M4, M3, M2, M1, M8]
    global layer_id_to_mod_key_id := custom_order.Clone()
    SaveLayerBindingsToIni(test_ini)
    ; メモリ上をゼロクリア
    global layer_id_to_mod_key_id := [0, 0, 0, 0, 0, 0, 0, 0]
    LoadLayerBindingsFromIni(test_ini)
    roundtrip_ok := true
    loop 8 {
        if (layer_id_to_mod_key_id[A_Index] != custom_order[A_Index]) {
            roundtrip_ok := false
            break
        }
    }
    Assert(roundtrip_ok, "Spec: Roundtrip Save -> Load strictly preserves 1D array structure and values")

    ; 6. セクション内 ModKeyId 属性テスト
    try FileDelete(test_ini)
    ini_content6 := "[NAVI_CTRL]`n"
        . "ModKeyId=M6`n"
        . "h={Left}`n"
    FileAppend(ini_content6, test_ini, "CP0")
    global layer_id_to_mod_key_id := orig_bindings.Clone()
    LoadLayerBindingsFromIni(test_ini)
    Assert(GetModKeyIdByLayerId(L_NAVI_CTRL) == 6, "Spec: Layer section ModKeyId attribute binds correctly")

    ; 7. 数値レイヤーID表記テスト (1=M7, Layer_2=M6)
    try FileDelete(test_ini)
    ini_content7 := "[LayerBinding]`n"
        . "1=M7`n"
        . "Layer_2=M6`n"
        . "Layer3=M5`n"
    FileAppend(ini_content7, test_ini, "CP0")
    LoadLayerBindingsFromIni(test_ini)
    Assert(GetModKeyIdByLayerId(1) == 7, "Spec: Numeric key 1=M7 sets layer 1 to 7")
    Assert(GetModKeyIdByLayerId(2) == 6, "Spec: Numeric key Layer_2=M6 sets layer 2 to 6")
    Assert(GetModKeyIdByLayerId(3) == 5, "Spec: Numeric key Layer3=M5 sets layer 3 to 5")

    ; クリーンアップ & 復元
    try FileDelete(test_ini)
    global layer_id_to_mod_key_id := orig_bindings
}

RunLayerMappingTests() {
    InitTestSuite("LAYER MAPPING & INI BINDING REGRESSION TESTS")
    Test_LayerId_To_ModKeyId_Mapping()
    Test_Ini_Layer_Binding()
    Test_New_LayerBinding_Specification()
    FinishTestSuite()
}

; 直接実行された場合のみ自動実行
if (A_LineFile == A_ScriptFullPath) {
    RunLayerMappingTests()
}
