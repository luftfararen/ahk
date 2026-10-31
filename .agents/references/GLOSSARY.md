# Project Glossary / 用語集 (Domain Terminology & Concepts)

> **Note for AI Agents**:
> This document defines key domain terminology, architectural concepts, timing parameters, and naming conventions used across the **Playgrounds** AutoHotkey v2 codebase.
> It serves as a dictionary and context reference for code analysis, specification mapping, and understanding code comments (especially in Japanese).
> Detailed code structure, control flow analysis, and algorithmic implementations are documented separately in `CODE_ANALYSIS.md`.

---

## 1. Core Key Architecture & Objects / コアキー設計とオブジェクト

- **リマップキー / Remapped Key (`RKey`)**
  - **Description**: The fundamental base class representing any remappable physical key on the keyboard. Handles physical press detection via `GetKeyState(..., "P")`, normal key sending, Shift-modified sending, IME ON/OFF differential mapping (`ime_key_text`), and CAW pass-through bypass.
  - **Context / Usage**: Class `RKey` in `src/PlayGroundsExp.ahk`.

- **長押し・レイヤーキー / Long-press / Layer Key (`LKey`)**
  - **Description**: Subclass of `RKey` that adds tap-hold, long-press, center modifier, and layer triggering capabilities. Manages key state (`state`), press timestamps (`pressed_time_qpc`), and layer interactions.
  - **Context / Usage**: Class `LKey extends RKey` in `src/PlayGroundsExp.ahk`.

- **キーステート / Key Lifecycle States (`st_init`, `st_pressing`, `st_processed`)**
  - **Description**: The 3-state lifecycle tracking an `LKey` press session:
    - `st_init` (0): Key is idle / released / unpressed.
    - `st_pressing` (1): Key is held down, awaiting tap-hold or chord combination evaluation.
    - `st_processed` (2): Key action or layer modifier has already been emitted or resolved during the session, preventing duplicate release actions.
  - **Context / Usage**: `LKey.st_init`, `LKey.st_pressing`, `LKey.st_processed`.

- **他キーへの割り込み / Key Interruption (`InterruptOthers`)**
  - **Description**: The mechanism where pressing any key sets `interrupted := true` on all other currently active `LKey` instances in `st_pressing`, informing tap-hold logic (e.g., Mode 3/13) that a subsequent key was struck before release.
  - **Context / Usage**: `LKey.InterruptOthers()`.

- **CAW (Ctrl/Alt/Win) パススルー / Modifier Pass-Through (`CAW Bypass`)**
  - **Description**: Pass-through logic for system modifier keys (**C**trl, **A**lt, **W**in). Bypasses custom remappings when native system shortcuts (e.g., Ctrl+C, Alt+Tab, Win+E) are actively pressed.
  - **Context / Usage**: `RKey._SendCAWKey()`.

- **リアルシフトとスペースシフト / Physical Shift vs. Space Shift**
  - **Description**:
    - **Physical Shift (リアルシフト)**: The actual hardware Shift keys (`LShift` / `RShift`).
    - **Space Shift (スペースシフト)**: The Space key configured to act as a Shift modifier layer.
  - **Context / Usage**: `IsPhysicalShiftPressed()`, `SendKeyWithShift()`.

---

## 2. Hold Modes & Tap-Hold Mechanics / ホールドモード・長押し動作仕様

- **長押し動作モード / Hold Mode (`HoldMode`)**
  - **Description**: Specification defining how an `LKey` behaves when pressed, held, or chorded with other keys. Supports per-key, per-layer item, or dynamic `config.ini` settings.
  - **Context / Usage**: Class `HoldMode`, `LKey.hold_mode_org`, `LKey.hold_mode_ime_org`.

- **通常キー送信 / Mode 0: Normal Key**
  - **Description**: Immediate key output on press (`_Down`). No hold detection or modifier behavior.

- **短押し即時送信・長押し置換 / Mode 1: Immediate Send with Long-Press Replacement**
  - **Description**: Emits normal character on press. If held beyond threshold (`hold_th`), sends `{Backspace}` to erase the character and outputs a secondary replacement character.

- **センターモディファイア / Mode 3 & Mode 13: Center Modifier**
  - **Description**: Dual-role modifier (e.g., Space or Enter as Layer Modifier). Outputs normal key text on release (`_Up`) if released before `hold_th` without interruption; functions purely as a layer modifier if held or chorded. Mode 13 includes pre-stroke buffer (`pre_stroke_buf`) protection.

- **即時送信・長押し修飾キー化 / Mode 4: Send on Down, Hold as Modifier**
  - **Description**: Always emits normal key text immediately on press, but functions simultaneously as a layer modifier for subsequent keys while held.

- **短押し単独Up時送信・長押しレイヤー化 / Mode 5: Deferred Send, Solo Up Normal**
  - **Description**: Suppresses output on press. Acts as a modifier if held beyond threshold or chorded; emits normal key text if released alone within threshold.

- **ロールオーバー検知Tap-Hold / Mode 6: Rollover-Protected Tap-Hold**
  - **Description**: Mode 4 extension for rapid typing. Emits normal text on press and defers companion key evaluation via `_WaitForHold`.

- **ロールオーバー誤判定防止バッファ付きTap-Hold / Mode 7: Tap-Hold with Rollover Buffer**
  - **Description**: Uses a rollover buffer (`b_time`) before `hold_th` to establish a gray zone, resolving fast sequential typing without unintended modifier triggers.

- **ロールオーバー誤判定防止・先行Up対応Tap-Hold / Mode 8: Tap-Hold with Preceding Up Action**
  - **Description**: Mode 7 variation using `b_time2` where releasing the companion key before the main key in the gray zone explicitly triggers the chord combination.

- **後発送信・BSキャンセル対応Tap-Hold / Mode 9: Tap-Hold with Backspace Cancellation**
  - **Description**: Pre-sends companion key character in short-tap range to eliminate latency, erasing it via `{Backspace}` if both keys remain held past `hold_th`.

---

## 3. Timing & Buffer Parameters / タイミングパラメータ

- **ホールド成立閾値 / Hold Threshold (`hold_th` / `HoldTh`)**
  - **Description**: Time duration in milliseconds distinguishing a short tap from a sustained hold (typically 150–300ms).
  - **Context / Usage**: `item.hold_th`, `Layers.hold_th`.

- **ロールオーバー誤判定防止バッファ時間 / Rollover Buffer Time (`b_time` / `b_time2`)**
  - **Description**: Time window in milliseconds subtracted from `hold_th` to form the decision "gray zone" in Modes 7, 8, and 9.
  - **Context / Usage**: `Layers.b_time`, `Layers.b_time2`.

- **前打鍵バッファ時間 / Pre-Stroke Buffer (`pre_stroke_buf`)**
  - **Description**: Time window in milliseconds used in Mode 13 to detect rapid sequential strokes preceding a modifier key press.

- **高精度タイマー / High-Precision Timer (`HighPrecisionTimer` / QPC)**
  - **Description**: High-resolution performance counter wrapper returning sub-millisecond precision timestamps for hold and duration checks.
  - **Context / Usage**: Class `HighPrecisionTimer` in `src/Utils.ahk`.

---

## 4. Layers & Chording System / レイヤー・修飾・同時押しシステム

- **レイヤー / Virtual Layer (`Layers`)**
  - **Description**: Virtual key layout mapping physical keys to alternate characters, navigation keys, or macros when a modifier layer is held.
  - **Context / Usage**: Class `Layers` in `src/PlayGroundsExp.ahk`.

- **定義済みレイヤーID / Predefined Layer IDs (`layer_id`)**
  - **Description**: Core internal layer indices:
    - `L_NAVI_CTRL` (1): Navigation & editing shortcuts.
    - `L_SYMBOL_NUM` (2): Number row & symbol combinations.
    - `L_SYMBOL1` (3) / `L_SYMBOL2` (4): Primary & secondary symbol layers.
    - `L_SELECT` (5): Text selection shortcuts.
    - `L_NUMPAD` (6): Tenkey numpad layer.
    - `L_SHIFT` (7): Dynamic Space-Shift layer.
    - `L_FUNC` (8): Function keys (F1–F12).

- **修飾キーID / Modifier Key ID (`mod_key_id` / M1–M8)**
  - **Description**: Standard hardware/virtual modifier slots (M1: F13, M2: 無変換, M3: 変換, M4: F14, M5: F13+Alt/無変換, M6: Tab, M7: Space, M8: 変換+F14, M9+: Dynamic key modifiers).

- **動的コンビネーション / Dynamic Combinations (`layer_id > 8`)**
  - **Description**: Chording combinations where arbitrary regular keys (e.g. `s`, `k`, `r`) serve as dynamic layer modifiers assigned indices `layer_id >= 9`.

- **物理キー指定プレフィックス / Physical Key Prefix (`P` prefix)**
  - **Description**: `P` prefix notation in INI configurations (e.g., `m_s_Pf`) indicating that a mapping binds strictly to the physical hardware key position rather than its software logical output.

- **多段階アクション / Multi-Stage Actions (`Continuous Tapping`)**
  - **Description**: Sequential tapping feature allowing a single combination key to output different actions depending on consecutive tap counts while holding a modifier (`action1`, `action2`, `action3`).

---

## 5. IME & Input Method System / 入力方式・IME制御

- **IME状態管理 / IME State Management (`ImeState`)**
  - **Description**: Handles detection, caching, and control of the Windows Input Method Editor state (0 = Japanese OFF / English, 1 = Japanese ON / Hiragana).
  - **Context / Usage**: Class `ImeState` in `src/PlayGroundsExp.ahk`.

- **未確定文字列 / IME Composition String (`IsComposing`)**
  - **Description**: The uncommitted phonetic text buffer active inside the IME before text conversion or confirmation (`Enter`).

- **IMEドットインジケーター / IME Dot Indicator**
  - **Description**: A visual GUI dot displayed near the mouse cursor reflecting active IME status.
  - **Context / Usage**: `TypeAnalyzer.ToggleImeIndicator()`.

---

## 6. String Conventions & Utilities / 表記規約とユーティリティ

- **生ホットキー文字列 / Raw Hotkey String (`R_...`)**
  - **Description**: Bare hotkey string prefix used when registering hotkeys with AHK's `Hotkey()` API (e.g., `R_CONV := "sc079"`).

- **Send互換文字列 / Send-Compatible String (`C_...`)**
  - **Description**: Key string format enclosed in braces, ready for `Send()` calls (e.g., `C_CONV := "{sc079}"`).

- **Blind送信用文字列 / Blind Send String (`B_...`)**
  - **Description**: Key string prepended with `{Blind}` to send input without releasing active modifiers (e.g., `B_CONV := "{Blind}{sc079}"`).

- **タイピング解析器 / Typing Analyzer (`TypeAnalyzer`)**
  - **Description**: Utility tracking keystroke timing intervals, trigram sequence frequencies, and typing metrics logged to `log.txt`.
  - **Context / Usage**: Class `TypeAnalyzer` in `src/Utils.ahk`.

- **レイアウト文字列クラス / Layout String Parser (`LayoutString`)**
  - **Description**: Utility converting 30-character grid strings into array representations applied to key object matrices.
  - **Context / Usage**: Class `LayoutString` in `src/Utils.ahk`.
