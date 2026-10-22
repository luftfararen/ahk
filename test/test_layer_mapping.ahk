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

RunLayerMappingTests() {
    InitTestSuite("LAYER MAPPING & INI BINDING REGRESSION TESTS")
    Test_LayerId_To_ModKeyId_Mapping()
    Test_Ini_Layer_Binding()
    FinishTestSuite()
}

; 直接実行された場合のみ自動実行
if (A_LineFile == A_ScriptFullPath) {
    RunLayerMappingTests()
}
