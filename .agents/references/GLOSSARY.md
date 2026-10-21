# Project Glossary / 開発用語集 (Domain Terminology & Concepts)

> This glossary documents all domain-specific terminology, architectural abstractions, and naming conventions used across the **Playgrounds** AutoHotkey v2 codebase.
> **Requirement for AI**: Whenever designing, reading, modifying, or refactoring source code in this project, you MUST reference this glossary to ensure strict consistency with established state models, timing parameters, and layer routing behaviors.

---

## 1. Core Key Architecture & Objects / コアキー設計とオブジェクト

### RKey / リマップキー (Remapped Key)

- **Defined in**: `src/PlayGroundsExp.ahk` (Class `RKey`)
- **Description**: The fundamental base class representing any remappable physical key on the keyboard. It handles physical key press detection via `GetKeyState(..., "P")`, normal key sending, Shift-modified sending, IME ON/OFF differential mapping (`ime_key_text`), and CAW pass-through bypass.

### LKey / 長押し・レイヤーキー (Long-press / Layer Key)

- **Defined in**: `src/PlayGroundsExp.ahk` (Class `LKey extends RKey`)
- **Description**: Subclass of `RKey` that adds sophisticated tap-hold, long-press, center modifier, and layer triggering capabilities. Maintains state (`state`), press start timestamps (`pressed_time_qpc`), and layer mappings (`layers` instance).

### Key State / キーステート (Key Lifecycle States)

- **Defined in**: `src/PlayGroundsExp.ahk` (`LKey.st_init`, `LKey.st_pressing`, `LKey.st_processed`)
- **Description**: The 3-state lifecycle for any `LKey`:
  - `st_init` (0): Key is idle / released / unpressed.
  - `st_pressing` (1): Key is currently held down, awaiting tap-hold or combination evaluation.
  - `st_processed` (2): Key action or layer modifier behavior has already been emitted / resolved during the current press session. Prevents unwanted duplicate or default release actions.

### InterruptOthers / 他キーへの割り込み (Key Interruption)

- **Defined in**: `LKey.InterruptOthers(trigger_key)`
- **Description**: Called whenever a key event occurs to mark all other currently active `LKey` instances as `interrupted := true`. This informs tap-hold handlers (like Mode 3/13) that a subsequent key was struck before release, preventing solitary tap actions.

### CAW Bypass / CAW (Ctrl/Alt/Win) パススルー (Modifier Pass-Through)

- **Defined in**: `RKey._SendCAWKey(pressed_key)`
- **Description**: "CAW" stands for **C**trl, **A**lt, **W**in. When any of these system modifier keys are physically held, custom key remapping is bypassed so that native OS shortcuts (e.g., Ctrl+C, Ctrl+V, Alt+Tab, Win+E) execute transparently without interference.

### Physical Shift vs Space Shift / リアルシフトとスペースシフト

- **Defined in**: `IsPhysicalShiftPressed()`, `SendKeyWithShift()`
- **Description**:
  - **Physical Shift (リアルシフト)**: The actual hardware Shift keys (`LShift` / `RShift`).
  - **Space Shift (スペースシフト)**: The Space key acting as a Shift modifier when configured as a layer or modifier. The codebase allows independent mapping definitions between physical Shift and space-modified Shift.

---

## 2. Hold Modes & Tap-Hold Mechanics / ホールドモード・長押し動作仕様

### HoldMode / 長押し動作モード (Hold Mode)

- **Defined in**: `src/PlayGroundsExp.ahk` (Class `HoldMode`, `LKey.hold_mode_org`, `LKey.hold_mode_ime_org`)
- **Description**: Defines how an `LKey` behaves when pressed, held, or combined with subsequent keys. Can be assigned per-key, per-layer item, or dynamically loaded from `config.ini`.

### HoldMode Class / HoldMode クラス

- **Defined in**: `class HoldMode { __New(mode, hold_th := -1, b_time := -1) }`
- **Description**: Encapsulates a mode number along with custom overrides for the hold threshold (`hold_th`) and rollover buffer duration (`b_time`).

### Mode 0: Normal Key / 通常キー送信 (No Tap-Hold)

- **Description**: Emits normal key output immediately on key down (`_Down`). No hold detection or modifier behavior.

### Mode 1: Immediate Send with Long-Press Replacement / 短押し即時送信・長押し置換

- **Description**: Emits the standard key immediately on key down. If held beyond `hold_th`, automatically emits Backspace (`{BS}`) to erase the previous character and sends the secondary long-press replacement character.

### Mode 3 / Mode 13: Center Modifier (Tap: Send on Up, Hold: Modifier) / センターモディファイア (短押しUp時送信・長押し修飾キー化)

- **Description**: Classical dual-role modifier (e.g., Space or Enter as Layer Modifier). On tap (released before `hold_th` without interruption), sends normal key text on key release (`_Up`). If held past `hold_th` or combined with another key, functions as a layer modifier. Mode 13 adds pre-stroke buffer (`pre_stroke_buf`) protection.

### Mode 4: Send on Down, Hold as Modifier / 即時送信・長押し修飾キー化

- **Description**: Always emits normal key text immediately on key down. However, if held continuously, it simultaneously functions as a layer modifier for subsequent keys.

### Mode 5: Deferred Send, Solo Up Normal / 短押し単独Up時送信・長押しレイヤー化

- **Description**: Does not emit on Down. If held beyond threshold or combined, acts as a modifier. If released alone within threshold, sends normal key.

### Mode 6: Rollover-Protected Tap-Hold (Timing Extension) / モード4タイミング拡張 (ロールオーバー検知)

- **Description**: Extends Mode 4 for high-speed typing. Key A emits normal text on Down. When companion key B is pressed within threshold, evaluation is deferred using `_WaitForHold` until either key is released or threshold expires.

### Mode 7: Tap-Hold with Rollover Buffer / ロールオーバー誤判定防止バッファ付きTap-Hold

- **Defined in**: `src/PlayGroundsExp.ahk` (`mod_hold_mode == 7`)
- **Description**: Key A emits normal text on Down. When companion key B is pressed:
  - If `t >= hold_th`: Combination action is emitted immediately.
  - If `t < (hold_th - b_time)`: Key B is confirmed as normal text (typing rollover).
  - If `(hold_th - b_time) <= t < hold_th` (Gray Zone): Defers via `_WaitForHold`.
    - Key A released first (Case 3-A): B emits normal text.
    - Key B released first (Case 3-B): B emits normal text.
    - Both keys held past `hold_th` (Case 3-C): Combination action is triggered.

### Mode 8: Tap-Hold with Preceding Up Action / ロールオーバー誤判定防止・先行Up対応Tap-Hold

- **Defined in**: `src/PlayGroundsExp.ahk` (`mod_hold_mode == 8`)
- **Description**: Similar to Mode 7 with `b_time2`, but in the gray zone, if companion key B is released first while Key A remains held (Case 3-B), the combination action **IS triggered**. Ideal for fast chorded typing where the main key is tapped and released quickly while the modifier key is held.

### Mode 9: Tap-Hold with Backspace Cancellation / 後発送信・BSキャンセル対応Tap-Hold

- **Defined in**: `src/PlayGroundsExp.ahk` (`mod_hold_mode == 9`)
- **Description**: Extends Mode 7: if both keys are held past `hold_th` even in the short-tap rollover range (`t < hold_th - b`), sends Backspace to erase the early normal character and emits the combination action.

---

## 3. Timing & Buffer Parameters / タイミングパラメータ

### `hold_th` / `HoldTh` / ホールド成立閾値 (Hold Threshold)

- **Description**: Threshold in milliseconds (ms) distinguishing a short tap from a sustained hold (typically 200–300ms).

### `LayerHoldTh` / `Layers.hold_th` / レイヤーホールド成立閾値 (Layer Hold Threshold)

- **Description**: Specific threshold (ms) required to activate layer modifiers and combination actions (configured in `config.ini`, default 150ms).

### `b_time` / ロールオーバー誤判定防止バッファ時間 (Rollover Buffer Time)

- **Description**: Time window in milliseconds (default 50ms) subtracted from `hold_th` to define the "gray zone" for Mode 7. Prevents accidental modifier triggers during rapid sequential typing.

### `b_time2` / ロールオーバー誤判定防止バッファ時間2 (Rollover Buffer Time 2)

- **Description**: Dedicated buffer window in milliseconds (default 50ms) used specifically for Mode 8 evaluation.

### `pre_stroke_buf` / 前打鍵バッファ時間 (Pre-Stroke Buffer)

- **Description**: Time window in milliseconds used in Mode 13 to detect rapid sequential strokes preceding the modifier key.

### `HighPrecisionTimer` / QPC (QueryPerformanceCounter) / 高精度タイマー

- **Defined in**: `Utils.ahk`
- **Description**: High-resolution performance counter wrapper returning elapsed time in milliseconds with sub-millisecond precision. Used for all hold duration calculations.

---

## 4. Layers & Modifier System / レイヤー・修飾システム

### Layer / レイヤー

- **Defined in**: `src/PlayGroundsExp.ahk` (Class `Layers`)
- **Description**: A virtual keyboard layer where physical keys are remapped to alternative keystrokes, navigation commands, or macros.

### Predefined Layers (`layer_id`) / 定義済みレイヤーID

- **`L_NAVI_CTRL` (1)**: Navigation and editing shortcuts (arrows, Home/End, PgUp/PgDn, Ctrl combinations).
- **`L_SYMBOL_NUM` (2)**: Number row and symbol combinations.
- **`L_SYMBOL1` (3)**: Primary symbol layer.
- **`L_SYMBOL2` (4)**: Secondary symbol layer.
- **`L_SELECT` (5)**: Text selection layer (Shift + navigation arrows).
- **`L_NUMPAD` (6)**: Dedicated tenkey numpad layer.
- **`L_SHIFT` (7)**: Dynamic space-shift layer.
- **`L_FUNC` (8)**: Function key layer (F1–F12).

### Mod Key ID (`mod_key_id` / M1〜M8) / 修飾キーID

- **Description**: Fixed indices representing physical/virtual modifier states:
  - **M1**: F13 (alone, without Alt or noconv)
  - **M2**: 無変換 (noconv alone, without F13 or Alt)
  - **M3**: 変換 (conv alone, without F14)
  - **M4**: F14 (alone, without conv)
  - **M5**: F13 + (Alt or 無変換)
  - **M6**: Tab
  - **M7**: Space
  - **M8**: 変換 + F14
  - **M9+**: Dynamically registered custom modifier keys.

### `layer_id_to_mod_key_id` / レイヤー・修飾キーマッピング配列

- **Description**: Global lookup table routing a `layer_id` (1–8) to its corresponding `mod_key_id`. Dynamically re-bound via INI configurations.

### `mod_key_list` / 修飾キーオブジェクトリスト

- **Description**: Global list holding key objects corresponding to `mod_key_id`. Indices 1–8 hold default keys; indices 9+ hold dynamically registered modifier keys created by combinations.

### `LayerItem` / レイヤーアイテム

- **Defined in**: `Layers.LayerItem`
- **Description**: Data structure containing an action mapping bound to a specific layer: `(layer_id, action, action2, action3, mode, hold_th, b_time)`.

### Continuous Tapping (Multi-stage Action) / 連続打鍵 (多段階アクション)

- **Fields**: `action`, `action2`, `action3`, `tap_count`
- **Description**: Allows a single combination key to output different strings depending on how many times it is tapped consecutively while holding the modifier (e.g., tap 1: `ite`, tap 2: `{BS}ta`).

---

## 5. Key Combination & Chording System / コンビネーション・同時押しシステム

### Combination / コンビネーション (同時押し)

- **Defined in**: `RegistCombination()`, `RegistIMECombination()`
- **Description**: Dual-key chording mechanism where pressing Modifier Key + Target Key produces specialized characters, words, or editing macros.

### Dynamic Combination / 動的コンビネーション (`layer_id > 8`)

- **Description**: Any custom combination where an arbitrary non-standard modifier key (e.g. `s`, `k`, `r`, `j`) is used as the chord trigger. The trigger key is assigned index `layer_id >= 9` via `Layers.Index(key_obj)`.
- **CRITICAL IMPLEMENTATION RULE**: Functions like `Layers.State(layer_id)` and `Layers.State2(layer_id, key_obj)` MUST allow `layer_id > 8` up to `mod_key_list.Length` to check dynamic keys via `Layers.StateModKeyId(layer_id)`. Restricting bounds to `layer_id_to_mod_key_id.Length` breaks dynamic combinations.

### Physical Key Prefix (`P` prefix) / 物理キー指定プレフィックス

- **Description**: In INI files (e.g., `m_s_Pf = 7,ite,{BS}ta`), prefixing a key name with `P` (e.g., `Pf`) indicates that the target key refers to the **physical hardware key** (`f`), regardless of what character the active software layout maps to that key.

---

## 6. IME & Input Method System / 入力方式・IME制御

### ImeState / IME状態管理

- **Defined in**: `src/PlayGroundsExp.ahk` (Class `ImeState`)
- **Description**: Manages Windows IME (Input Method Editor) state (0 = Japanese OFF / Direct English input, 1 = Japanese ON / Hiragana input).

### Composition / 未確定文字列 (`IsComposing`)

- **Description**: The transient state when phonetic keystrokes are being buffered by IME into Japanese candidate strings before being finalized (converted and confirmed with Enter).

### Dot Indicator / IMEドットインジケーター

- **Defined in**: `TypeAnalyzer.ToggleImeIndicator()`
- **Description**: Visual feedback indicator that renders a small colored dot near the mouse cursor to display current IME status (Japanese ON vs OFF).

### `ResetIME` & `SetImeKey` / IMEキー再設定

- **Description**: Methods in `LKey` used by layout presets to configure differential outputs when IME is ON (e.g., romaji phonemes `nn` for ん, `ltu` for っ, `ya` for ゃ).

---

## 7. Keyboard Layouts & Presets / 配列・レイアウト定義

### Layout Presets / プリセット配列

- **Defined in**: `src/Preset.ahk`
- **Presets**:
  - `Minato` (湊配列 / Minato2, Minato3): High-efficiency Japanese kana input layout designed for dual-thumb chording.
  - `FMIX` (FMIX13, FMIX13f, FMIX14, FMIX15, FMIX15R): Ergonomic Japanese/English hybrid layout series.
  - `TF2_2-Minato`: Built-in default startup layout pairing FMIX with Minato kana chordings.
  - `Oonishi` (大西配列), `Colemak`, `Qwerty`, `STREAM1.5`.

### Grid Layout Notation (`L00`, `L01`, `L02`, `L03`, `S00`...) / グリッド配列記法

- **Defined in**: `config.ini`
- **Description**: Matrix representation of keyboard rows (L00 = Number row, L01 = Top letter row, L02 = Home row, L03 = Bottom row). `S00`–`S03` represent shifted variants.

### LayoutString / レイアウト文字列クラス

- **Defined in**: `Utils.ahk` (Class `LayoutString`)
- **Description**: Utility converting 30-character concatenated layout strings into array grids and applying them to key objects.

---

## 8. Prefix & String Conventions / 接頭辞および表記規約

### `R_...` / 生ホットキー文字列 (Raw Hotkey String)

- **Example**: `R_CONV := "sc079"`, `R_SPACE := "space"`
- **Description**: Bare key name or scan code string suitable for registering hotkeys with AHK's `Hotkey()` function.

### `C_...` / Send互換文字列 (Send-Compatible String)

- **Example**: `C_CONV := "{sc079}"`, `C_ENTER := "{Enter}"`
- **Description**: Key string enclosed in braces `{}` ready to be passed directly to `Send()` or `SendAndLog()`.

### `B_...` / Blind送信用文字列 (Blind Send String)

- **Example**: `B_CONV := "{Blind}{sc079}"`, `B_TAB := "{Blind}{Tab}"`
- **Description**: Prepended with `{Blind}` to send the key without releasing active modifier keys (Ctrl, Shift, Alt).

---

## 9. Utilities & Tooling / ユーティリティと周辺ツール

### TypeAnalyzer / タイピング統計・トリグラム解析

- **Defined in**: `Utils.ahk` (Class `TypeAnalyzer`)
- **Description**: Records keystroke intervals, trigram (3-key sequence) frequencies, and typing metrics to `log.txt` for layout efficiency analysis.

### MouseSpeed / マウス速度調整

- **Defined in**: `Utils.ahk` (Class `MouseSpeed`)
- **Description**: Adjusts Windows system pointer speed dynamically via hotkeys (`Win+Up` / `Win+Down`).

### ShowOSD / オンスクリーンディスプレイ

- **Defined in**: `Utils.ahk` (`ShowOSD()`)
- **Description**: Displays lightweight, non-intrusive on-screen heads-up display notifications (e.g. when changing layouts or toggling modes).

### IniMap / INIマップユーティリティ

- **Defined in**: `Utils.ahk` (Class `IniMap`)
- **Description**: Reads and writes INI file key-value pairs while automatically stripping inline comments (`;...`).
