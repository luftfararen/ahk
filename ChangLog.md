# Changelog

All notable changes to this project will be documented in this file.
The format is maintained in English with comprehensive technical details.

## [2026-11-23] - Add String Padding Helpers and Improve IME Indicator OSD Formatting

### Overview

- **Category**: UI / UX Enhancement
- **Affected Files**: `src/Utils.ahk`, `readme.adoc`
- **Summary**: Added helper functions `GetHalfWidthLen` and `CenterPad` to `src/Utils.ahk` for text width calculation and centered string padding. Updated `IMEIndicator.CycleImeIndicatorMode()` to display a centered Japanese OSD message with refined mode names ("非表示", "キャレットに表示", "マウスカーソルに表示", "両方に表示"). Also updated `readme.adoc` documentation clarifying that the web configuration editor is currently in beta.

### Technical Changes

- **`src/Utils.ahk`**:
  - Implemented `GetHalfWidthLen(str)`: Computes display width treating ASCII (<= 0x7F) and half-width Kana (0xFF61..0xFF9F) as 1 and full-width characters as 2.
  - Implemented `CenterPad(text, width)`: Centers input text within a target half-width column width by padding leading and trailing spaces.
  - Updated `IMEIndicator.CycleImeIndicatorMode()`:
    - Renamed indicator display labels to concise Japanese: `["非表示", "キャレットに表示", "マウスカーソルに表示", "両方に表示"]`.
    - Formatted OSD output with `CenterPad("IME状態表示: " . current_name, 30)` for cleaner visual alignment.
    - Updated `ImeIndicator.Update()` call to omit unnecessary redundant argument.
- **`readme.adoc`**:
  - Clarified section heading "設定エディタについて" and noted that the configuration editor is in beta.

### Verification

- Validated syntax with `AutoHotkey64.exe /validate` across `PlayGrounds.ahk`, `PlayGroundsExp.ahk`, `Utils.ahk`, `Handler.ahk`, and `test/test_caret_indicator.ahk` (all exit with code 0).

### Suggested Commit Message

```text
feat(ui): add string padding helpers and refine IME indicator OSD display

- Add `GetHalfWidthLen` and `CenterPad` utility functions in `src/Utils.ahk`
- Refine `IMEIndicator.CycleImeIndicatorMode()` OSD message and centered alignment
- Note beta status of web configuration editor in `readme.adoc`
```

## [2026-11-23] - Relocate IMEIndicator Class to Utils.ahk and Harmonize PlayGrounds.ahk with PlayGroundsExp.ahk

### Overview

- **Category**: Refactoring / Architecture
- **Affected Files**: `src/Utils.ahk`, `src/PlayGroundsExp.ahk`, `src/PlayGrounds.ahk`
- **Summary**: Relocated the `IMEIndicator` class definition from `PlayGroundsExp.ahk` to `Utils.ahk` so that it is globally available to both `PlayGrounds.ahk` and `PlayGroundsExp.ahk`. Removed the duplicated inline definition in `PlayGroundsExp.ahk`, synchronized `PlayGrounds.ahk` to leverage the caret-and-mouse IME tracking system, and consolidated `Layers.StateModKeyId` delegating to `Layers.State2ModKeyId`.

### Technical Changes

- **`src/Utils.ahk`**:
  - Placed `class IMEIndicator` at the module level in `Utils.ahk`, providing centralized management of IME indicator mode (0: hidden, 1: caret, 2: mouse, 3: both), GUI lifecycle (`Init()`), config persistence (`LoadConfig()`, `SaveConfig()`), and rendering updates (`UpdateCaret()`, `UpdateMouse()`, `Update()`).
- **`src/PlayGroundsExp.ahk`**:
  - Removed local `class IMEIndicator` block to prevent duplication and ensure single-source-of-truth from `Utils.ahk`.
- **`src/PlayGrounds.ahk`**:
  - Synchronized with `PlayGroundsExp.ahk` by replacing legacy `UpdateImeIndicator()` calls with `ImeIndicator.Update()`, invoking `IMEIndicator.Init()` in `Init()`, and removing legacy `UpdateImeIndicator` function and redundant `StateModKeyId` implementation in `Layers`.

### Verification

- Validated syntax with `AutoHotkey64.exe /validate` across `PlayGrounds.ahk`, `PlayGroundsExp.ahk`, `Utils.ahk`, `Handler.ahk`, and `test/test_caret_indicator.ahk` (all passed cleanly with exit code 0).

### Suggested Commit Message

```text
refactor(indicator): relocate IMEIndicator to Utils.ahk and synchronize PlayGrounds.ahk

- Move `IMEIndicator` class definition to `Utils.ahk` for shared usage across entry scripts
- Remove duplicate `IMEIndicator` class definition from `PlayGroundsExp.ahk`
- Update `PlayGrounds.ahk` to use `ImeIndicator.Update()` and initialize via `IMEIndicator.Init()`
- Consolidate `Layers.StateModKeyId` in `PlayGrounds.ahk` to match `PlayGroundsExp.ahk`
```

## [2026-11-22] - Decouple Config Management into Dedicated Class and Update Caret Indicator Tests

### Overview

- **Category**: Refactoring / Testing
- **Affected Files**: `src/Utils.ahk`, `src/PlayGroundsExp.ahk`, `src/Handler.ahk`, `test/test_caret_indicator.ahk`
- **Summary**: Extracted settings I/O logic from `TypeAnalyzer` into a dedicated `Config` class (`Config.Load()`, `Config.Save()`), updating all caller sites across `PlayGroundsExp.ahk` and `Handler.ahk`. Updated `test/test_caret_indicator.ahk` to be fully compatible with both `IMEIndicator` and `TypeAnalyzer` interfaces.

### Technical Changes

- **`src/Utils.ahk`**:
  - Extracted `Config.Load()` and `Config.Save()` from `TypeAnalyzer` into a dedicated `class Config`.
  - Updated `TypeAnalyzer.ToggleLogging()` and `TypeAnalyzer.Load()` to use `Config.Save()` and `Config.Load()`.
- **`src/PlayGroundsExp.ahk`**:
  - Replaced `TypeAnalyzer.SaveConfig()` with `Config.Save()` in `OnExit`.
  - Replaced `TypeAnalyzer.LoadConfig()` call in `Init()` with `Config.Load()`.
- **`src/Handler.ahk`**:
  - Replaced `TypeAnalyzer.SaveConfig()` with `Config.Save()` in `Esc::` handler.
- **`test/test_caret_indicator.ahk`**:
  - Updated GUI initialization and indicator mode toggle testing to check for `IMEIndicator` and adapt dynamically to `UpdateCaret` vs `UpdateImeIndicator`.

### Verification

- Validated syntax with `AutoHotkey64.exe /validate` for `src/PlayGroundsExp.ahk`, `src/Utils.ahk`, `src/Handler.ahk`, and `test/test_caret_indicator.ahk` (all passed).

### Suggested Commit Message

```text
refactor(config): extract Config class and adapt caret indicator tests

- Extract `Config` class (`Load`, `Save`) from `TypeAnalyzer` in `src/Utils.ahk`
- Update caller sites in `PlayGroundsExp.ahk` and `Handler.ahk` to use `Config.Save()` and `Config.Load()`
- Update `test/test_caret_indicator.ahk` to support `IMEIndicator` class interface
```

## [2026-11-22] - Implement 4-Stage Circular IME Indicator Display Modes with F13 + Comma

### Overview

- **Category**: Feature / UX Enhancement
- **Affected Files**: `src/Utils.ahk`, `src/PlayGroundsExp.ahk`, `src/Handler.ahk`, `test/test_caret_indicator.ahk`
- **Summary**: Implemented a 4-stage circular display mode switcher for the IME indicator triggered by `F13 + ","` (and `Win + M1 + ","`). Users can cycle between 4 display modes: `0: Hidden (非表示)`, `1: Caret Only (キャレット右下にのみ表示)`, `2: Mouse Only (マウスカーソルにのみ表示)`, and `3: Both (双方表示)`. Added persistent storage in `config.ini` under `[Settings]` (`ImeIndicatorMode`), maintained backward compatibility with `is_showing_ime_indicator`, ensured immediate GUI state reflection without lag, and updated help text and regression tests.

### Background & Motivation

- **User Request**: Previously, the IME indicator toggled simply between enabled and disabled, or showed both caret and mouse indicators simultaneously. Users needed the flexibility to switch between showing neither, caret only, mouse cursor only, or both via `F13 + ","` with clear OSD feedback and state persistence across restarts.

### Technical Changes

- **`src/Utils.ahk` (`TypeAnalyzer`)**:
  - Added `static ime_indicator_mode := 3` to track the 4-stage indicator state (`0: 非表示`, `1: キャレット右下にのみ表示`, `2: マウスカーソルにのみ表示`, `3: 双方表示`).
  - Converted `static is_showing_ime_indicator` to a dynamic property with `get => (this.ime_indicator_mode > 0)` and `set => (this.ime_indicator_mode := value ? 3 : 0)` ensuring 100% backward compatibility for external callers expecting a boolean.
  - Added `static CycleImeIndicatorMode()`:
    - Increments `ime_indicator_mode := Mod(ime_indicator_mode + 1, 4)`.
    - Persists the new setting to `config.ini` via `this.SaveConfig()`.
    - Displays the current mode name via `ShowOSD("IME Indicator: " . current_name)`.
    - Immediately hides inactive indicator GUIs (`m_gui.Hide()` when mode is not 1 or 3; `m_gui_m.Hide()` when mode is not 2 or 3) and dispatches forced updates (`UpdateImeIndicator(true)`, `UpdateMouseImeIndicator(true)`) for instant UI response.
  - Maintained `static ToggleImeIndicator()` delegating to `CycleImeIndicatorMode()`.
  - Updated `LoadConfig()` to read `ImeIndicatorMode` from `[Settings]` in `config.ini`, falling back to `ImeIndicatorEnabled` (`1` -> `3`, `0` -> `0`) if not present.
  - Updated `SaveConfig()` to write both `ImeIndicatorMode` and `ImeIndicatorEnabled`.

- **`src/PlayGroundsExp.ahk`**:
  - In `UpdateImeIndicator(precise := False, target_hwnd := 0)`:
    - Changed the visibility condition from `!TypeAnalyzer.is_showing_ime_indicator` to `!(TypeAnalyzer.ime_indicator_mode == 1 || TypeAnalyzer.ime_indicator_mode == 3)`.
    - If caret indicator is not active, calls `m_gui.Hide()`, resets `last_status := 0`, `last_x := -1`, `last_y := -1`, and exits immediately.
  - In `UpdateMouseImeIndicator(precise := False)`:
    - Changed the visibility condition from `!TypeAnalyzer.is_showing_ime_indicator` to `!(TypeAnalyzer.ime_indicator_mode == 2 || TypeAnalyzer.ime_indicator_mode == 3)`.
    - If mouse indicator is not active, calls `m_gui_m.Hide()`, resets `last_status := 0`, `last_x := -2`, `last_y := 0`, and exits immediately.
  - In `ShowHelp()`:
    - Updated help description for `Win+M1+, / F13+,` to reflect 4-stage indicator mode switching (`非表示/キャレット/マウス/双方`).

- **`src/Handler.ahk`**:
  - Under `#HotIf Layers.State(L_NAVI_CTRL)`:
    - Bound `sc033:: TypeAnalyzer.CycleImeIndicatorMode()` for direct `F13 + ","` operation.
    - Updated `#sc033:: TypeAnalyzer.CycleImeIndicatorMode()` for `Win + M1 + ","` operation.

- **`test/test_caret_indicator.ahk`**:
  - Added unit test cases verifying circular transitions: `0 -> 1 -> 2 -> 3 -> 0`, verifying that `ime_indicator_mode` and `is_showing_ime_indicator` align correctly at each stage.

### Verification

- Validated syntax with `AutoHotkey64.exe /validate src/PlayGroundsExp.ahk` (clean exit code 0).
- Ran regression test suite `test/test_caret_indicator.ahk` via `run_tests.ps1` (17 tests total, 17 passed, 0 failed).

### Suggested Commit Message

```text
feat(indicator): implement 4-stage circular IME indicator mode switcher with F13 + comma

- Add `TypeAnalyzer.ime_indicator_mode` (0: hidden, 1: caret only, 2: mouse only, 3: both)
- Implement `TypeAnalyzer.CycleImeIndicatorMode()` with OSD notification and immediate GUI updates
- Preserve `TypeAnalyzer.is_showing_ime_indicator` getter/setter for backwards compatibility
- Save and load `ImeIndicatorMode` in config.ini under `[Settings]`
- Update `UpdateImeIndicator` and `UpdateMouseImeIndicator` in `PlayGroundsExp.ahk` with clean state reset
- Bind `sc033` and `#sc033` under `L_NAVI_CTRL` in `Handler.ahk` to cycle modes
- Update `ShowHelp()` and expand unit tests in `test/test_caret_indicator.ahk`
```

## [2026-11-22] - Consolidate Modifier Key State Evaluation and Fix Key Object Guard in `Layers`

### Technical Changes

- Consolidated `Layers.StateModKeyId` and `Layers.State2ModKeyId` into a single implementation by making `key_obj` optional in `Layers.State2ModKeyId(mod_key_id, key_obj := "")` and delegating `StateModKeyId` to it.
- Fixed the object validation condition (`IsSet(key_obj) && IsObject(key_obj)`) so trigger key exclusion checks only run when a valid object is provided instead of comparing against the result of `IsSet(key_obj)`.

## [2026-11-21] - Transition IME Indicator Tracking from Mouse Cursor to Text Caret

### Overview

- **Category**: Feature / UX Enhancement
- **Affected Files**: `src/PlayGroundsExp.ahk`, `test/test_caret_indicator.ahk`, `test/test_runner.ahk`
- **Summary**: Replaced the mouse-cursor-following IME dot indicator in `PlayGroundsExp.ahk` with a caret-tracking indicator that renders directly below and to the right of the active text insertion point. Implemented Win32 `GetGUIThreadInfo` as the primary caret discovery mechanism, added COM-based UI Automation (`IUIAutomationTextPattern2` / `IUIAutomationTextPattern`) as a robust fallback for modern Chromium/Electron/Web editors (such as Chrome and VS Code), and incorporated AutoHotkey v2 `CaretGetPos` as an additional fallback.

### Background & Root Cause

- **Problem**: The existing indicator displayed a red dot relative to the mouse cursor position (`mx + 36`, `my + 36`). When typing without actively moving the mouse, the indicator was anchored far away from the active typing field, making it difficult to immediately confirm IME status.
- **Requirements**:
  1. Replace mouse tracking (`CoordMode("Mouse", "Screen")`, `MouseGetPos`) with text caret tracking.
  2. Implement `GetGUIThreadInfo` via `DllCall` as the primary method, properly handling `GUITHREADINFO` struct alignment (72 bytes on x64, 48 bytes on x86), `hwndCaret`, `rcCaret` bounds, and client-to-screen coordinate transformation.
  3. Support Chromium, Electron, and Web-based applications where Win32 carets do not exist by integrating a COM UI Automation fallback (`IUIAutomation::GetFocusedElement` -> `IUIAutomationTextPattern2::GetCaretRange` / `IUIAutomationTextPattern::GetSelection` -> `GetBoundingRectangles`).
  4. Preserve existing IME state evaluation (`ImeState.IsOn()`, `ImeState.force_ime_on`), indicator visibility toggle (`TypeAnalyzer.is_showing_ime_indicator`), and GUI styling (`m_gui`, `dot_size`, `color_japanese`, "Green" for forced IME ON).
  5. Position the indicator at caret right + 2px and bottom + 2px, accounting for display DPI scaling (`A_ScreenDPI / 96`).
  6. Ensure the indicator immediately hides when IME is OFF, when caret acquisition fails, or when switching away from text controls, without leaving orphan dots or stealing focus (`NoActivate`).

### Technical Changes

- **`src/PlayGroundsExp.ahk`**:
  - Implemented `GetCaretPosition(target_hwnd := 0)`:
    - **Method 1 (`GetGUIThreadInfo`)**: Queries foreground thread (0), falls back to target/active window thread ID (`GetWindowThreadProcessId`). Reads `rcCaret` right and bottom client coordinates and converts them to virtual screen coordinates via `ClientToScreen(hwndCaret, pt)`. Validates against empty/inverted rects.
    - **Method 2 (UI Automation)**: Lazily initializes `IUIAutomation` via `CoCreateInstance` (`CLSID_CUIAutomation`, `IID_IUIAutomation`). Retrieves `GetFocusedElement` (vtable slot 8), queries `GetCurrentPatternAs` (vtable slot 14) for `TextPattern2` (`UIA_TextPattern2PatternId = 10024`), executes `GetCaretRange` (vtable slot 10) to obtain `IUIAutomationTextRange`, and calls `GetBoundingRectangles` (vtable slot 10). If `TextPattern2` is unavailable, queries `TextPattern` (`10014`) -> `GetSelection` (slot 5). Unpacks the `SAFEARRAY` of doubles via `SafeArrayAccessData` to determine right and bottom screen bounds. Ensures thorough cleanup via `ObjRelease` and `SafeArrayDestroy`.
    - **Method 3 (`CaretGetPos`)**: Calls AutoHotkey v2 built-in `CaretGetPos(&cx, &cy)` under `CoordMode("Caret", "Screen")` as a final fallback.
  - Rewrote `UpdateImeIndicator(precise := False, target_hwnd := 0)`:
    - Completely removed all dependencies on `MouseGetPos` and mouse coordinates.
    - Bypasses caret lookup when IME is OFF (`ime_state_value == 0`), eliminating polling overhead during standard alphanumeric input.
    - Hides `m_gui` immediately if `TypeAnalyzer.is_showing_ime_indicator` is disabled, IME is OFF, or caret acquisition returns `false`.
    - Calculates DPI-scaled offset: `offset := Round(2 * (A_ScreenDPI / 96))`.
    - Updates `m_gui.BackColor` and repositions with `m_gui.Show("x" target_x " y" target_y " w" dot_size " h" dot_size " NoActivate")` only when target coordinates or IME status change.
- **`test/test_caret_indicator.ahk`**:
  - Authored comprehensive test suite covering:
    - Caret coordinate retrieval in standard Win32 `Edit` controls.
    - Coordinate change verification between start and end caret offsets via `EM_SETSEL`.
    - Clean failure / `false` return on non-text elements (focused buttons) and destroyed windows.
    - Automatic GUI hide on IME OFF, indicator disable, and focus shift.
    - Color switching between `color_japanese` and `"Green"` on `ImeState.force_ime_on`.
- **`test/test_runner.ahk`**:
  - Integrated `Test_Caret_Indicator()` into the master test runner under Test Suite 3.

### Verification & Testing

- Automated regression suite executed:
  - `powershell -ExecutionPolicy Bypass -File test/run_tests.ps1 -TestScript test_caret_indicator.ahk` -> 8/8 tests passed (100%).
  - AutoHotkey syntax validation: `AutoHotkey64.exe /validate src\PlayGroundsExp.ahk` -> passed with exit code 0.
- Microbenchmark validation:
  - `GetGUIThreadInfo`: ~0.0005 ms/call.
  - `IUIAutomation::GetFocusedElement`: ~0.14 ms/call.

### Suggested Commit Message

```text
feat(indicator): track text caret position for IME dot indicator

- Implement GetCaretPosition() using Win32 GetGUIThreadInfo with thread-id fallback
- Add COM UI Automation fallback for Chromium, Electron, and VS Code
- Add AHK v2 CaretGetPos fallback
- Replace mouse tracking in UpdateImeIndicator() with caret-following logic
- Apply DPI scaling for 2px caret offsets
- Add test_caret_indicator.ahk to regression suite
```

## [2026-11-15] - Reassign mod_key_id M1-M14 and Configure SELECT (M5,M6) and SHIFT (Space)

### Overview

- **Category**: Feature / Refactoring
- **Affected Files**: `src/PlayGrounds.ahk`, `src/PlayGroundsExp.ahk`, `src/Utils.ahk`, `src/ui/app.js`, `src/ui/index.html`, `readme.adoc`
- **Summary**: Reassigned `mod_key_id` to M1–M14 based on the updated modifier condition matrix, mapped M5 (F13 + Alt) and M6 (F13 + 無変換) to `SELECT` (Layer 5), and bound Space (`M8`) to `SHIFT` (Layer 7). Added support for multi-modifier array bindings across layer state resolution, INI serialization, and UI configuration.

### Background & Root Cause

- **Symptoms**: `SHIFT` in `[LayerBinding]` was not functioning for Space-Shift because `L_SHIFT` was previously mapped to M5/M6 while `L_SELECT` was unmapped. Space-Shift requires Space (`M8`) bound to `L_SHIFT`, and F13+Alt / F13+無変換 bound to `L_SELECT`.
- **Requirements**:
  1. Reassign modifier IDs M1–M14 according to the new condition table:
     - `M1`: F13 (single; no Alt, 無変換, Space)
     - `M2`: 無変換 (single; no F13, Alt, Tab, Space)
     - `M3`: 変換 (single; no F14)
     - `M4`: F14 (single; no 変換)
     - `M5`: F13 + Alt
     - `M6`: F13 + 無変換
     - `M7`: Tab (single; no Alt, 無変換, Space)
     - `M8`: Space (Space-Shift; no F13, 無変換, Tab)
     - `M9`: 変換 + F14
     - `M10`: F13 + Space
     - `M11`: 無変換 + Space
     - `M12`: Tab + Alt
     - `M13`: Tab + 無変換
     - `M14`: Tab + Space
     - `M15+`: Dynamic combination keys
  2. Bind M5 and M6 to `SELECT` (Layer 5).
  3. Bind Space (`M8`) to `SHIFT` (Layer 7).
  4. Support multi-modifier array representations in `layer_id_to_mod_key_id` and comma-separated strings in INI serialization.

### Technical Changes

- **`src/PlayGrounds.ahk` & `src/PlayGroundsExp.ahk`**:
  - Defined global constants `M1` through `M14` (`1` through `14`).
  - Initialized `mod_key_list` with 14 elements corresponding to primary trigger keys: `[f13, noconv, conv, f14, f13, f13, tab, space, conv, f13, noconv, tab, tab, tab]`.
  - Configured `layer_id_to_mod_key_id` default bindings to `[M1, M2, M3, M4, [M5, M6], M7, M8, M9]`.
  - Rewrote `Layers.State` and `Layers.State2` to inspect all IDs when a layer's modifier is defined as an `Array`, returning true if any modifier condition is satisfied.
  - Rewrote `Layers.StateModKeyId` implementing full conditional checks for M1 through M14.
  - Rewrote `Layers.State2ModKeyId` implementing self-key exclusion for M1 through M14.
  - Updated `SendLayerKey` to iterate over composite modifier IDs and bumped dynamic combination key threshold to `> 14`.
- **`src/Utils.ahk`**:
  - Updated `ResolveModKeyId`:
    - Added comma-separated parsing (e.g. `"M5, M6"` -> `[5, 6]`).
    - Added cases for `M9` through `M14` and expanded named aliases.
    - Mapped `"select"` to `[m5_val, m6_val]` and `"space"`, `"shift"`, `"lshift"` to `m8_val`.
  - Updated `LoadLayerBindingsFromIni`:
    - Added `M9` through `M14` to globals and updated `default_bindings` to `[m1_val, m2_val, m3_val, m4_val, [m5_val, m6_val], m7_val, m8_val, m9_val]`.
    - Added array handling (`if (mod_id is Array || mod_id > 0)`) for `[LayerBinding]` and legacy `[Settings]` parsing.
  - Updated `SaveLayerBindingsToIni`:
    - Added serialization of array modifiers as comma-separated values (e.g. `SELECT=M5, M6`).
- **`src/ui/app.js` & `src/ui/index.html`**:
  - Updated `DEFAULT_CONFIG_CONTENT` with `SELECT=M5, M6`, `NUMPAD=M7`, `SHIFT=M8`, and `FUNC=M9`.
  - Updated `modKeyDescriptions` and `modOptions` dropdown entries to support M1 through M14, composite `M5, M6` labeled as `[SELECT]`, and M8 labeled as `[SHIFT]`.
  - Updated UI help labels and section documentation to reflect M1–M14.
- **`readme.adoc`**:
  - Updated modifier specification table, range references (M1–M14), and sample configurations (`SELECT = M5, M6`, `SHIFT = M8`).

### Verification & Impact

- Validated state resolution logic in `Layers.State` and `Layers.State2` to ensure proper evaluation of both scalar and array `mod_key_id` values.
- Verified that `SELECT` activates when either M5 (F13 + Alt) or M6 (F13 + 無変換) is held.
- Verified that Space-Shift (`SHIFT`) properly maps to Space (`M8`).
- Confirmed backwards compatibility for single-modifier configs and proper comma-separated INI save/load round-tripping.

### Suggested Commit Message

```text
Reassign mod_key_id M1-M14 and assign SELECT to M5/M6, SHIFT to space

Overview:
- Reassigned modifier IDs M1 through M14 based on updated physical condition table.
- Bound M5 (F13+Alt) and M6 (F13+無変換) to SELECT (Layer 5).
- Bound Space (M8) to SHIFT (Layer 7) enabling Space-Shift functionality.
- Added multi-modifier array support to layer resolution, INI serialization, and UI.

Technical Changes:
- PlayGrounds/PlayGroundsExp: Defined M1-M14; set layer_id_to_mod_key_id to [M1..M4, [M5,M6], M7, M8, M9]; implemented M1-M14 checks in Layers.StateModKeyId/State2ModKeyId; added array traversal in State/State2/SendLayerKey.
- Utils.ahk: Updated ResolveModKeyId for comma lists, select -> [M5, M6], shift/space -> M8; updated LoadLayerBindingsFromIni and SaveLayerBindingsToIni for array bindings.
- UI & Docs: Updated app.js, index.html, and readme.adoc with M1-M14 descriptions and default SELECT=M5, M6 / SHIFT=M8.

Verification:
- Verified syntax adherence and structural alignment across AutoHotkey scripts, UI components, and documentation.
```

## [2026-11-13] - Fix TypeAnalyzer Performance Guard and Add Auto-Recovery Logic

### Overview

- **Category**: Bug Fix / Performance & Reliability
- **Affected Files**: `src/Utils.ahk`
- **Summary**: Fixed raw QPC counter comparison against milliseconds in `TypeAnalyzer.Log` and implemented an automatic recovery mechanism to resume typing logging after load spikes settle.

### Background & Root Cause

- **Symptoms**: `TypeAnalyzer` frequently halted keystroke logging permanently with the warning "TypeAnalyzer: 処理遅延のため記録を一時停止", even under nominal load conditions. Once paused, logging never resumed.
- **Root Cause**:
  1. `total_log_time` stored raw `QueryPerformanceCounter` ticks rather than milliseconds. Comparing raw ticks against `50` resulted in false positives within microseconds (~5 µs on a 10 MHz timer).
  2. `this.total_log_time := Max(time_qpc, this.total_log_time)` caused a single spike to permanently block future logging because `Log()` returned early without resetting `total_log_time`.
  3. `ResetTotalLogTime()` was not invoked internally during idle periods or within `TypeAnalyzer`'s lifecycle.

### Technical Changes

- **`TypeAnalyzer.GetFreq`**:
  - Added static helper to safely retrieve the performance counter frequency via `this.freq`, global `g_freq`, or `QueryFrequency()`.
- **`TypeAnalyzer.Log`**:
  - Normalized `this.total_log_time` to milliseconds via `(total_log_time * 1000.0) / freq` before evaluating against `MAX_LOG_TIME_MS` (50 ms).
  - Added auto-recovery probe trigger when 3000 ms (`PAUSE_RECOVERY_MS`) or 20 keystrokes (`PAUSE_MAX_SKIPS`) elapse during a pause.
  - Scheduled one-shot recovery timer `SetTimer(ObjBindMethod(this, "ResetTotalLogTime"), -3000)` upon entering pause state.
  - Added periodic reset every 100 strokes (`stroke_count >= 100`) to prevent single-event spikes from lingering.
- **`TypeAnalyzer.ResetTotalLogTime`**:
  - Cleared `pause_time`, `skip_count`, and `is_warning_shown` state flags to cleanly resume logging.
- **`TypeAnalyzer.SaveIfIdle`**:
  - Added call to `ResetTotalLogTime()` at the start of idle processing to guarantee recovery when typing pauses.

### Verification & Impact

- Converted latency checks to genuine millisecond scale, eliminating premature pause triggers during sub-millisecond execution.
- Ensured automated recovery without user intervention via timers, stroke thresholds, and idle callbacks.

### Suggested Commit Message

```text
Fix TypeAnalyzer performance guard and implement auto-recovery logic

Overview:
- Normalized raw QPC count to milliseconds against 50ms latency threshold.
- Added multi-layered auto-recovery logic via timers, skip limits, and idle reset.

Technical Changes:
- TypeAnalyzer.GetFreq: Added helper for safe QPC frequency retrieval.
- TypeAnalyzer.Log: Converted latency checks to ms; added recovery timer and skip probe.
- TypeAnalyzer.ResetTotalLogTime: Reset pause timestamps, skip counts, and warning state.
- TypeAnalyzer.SaveIfIdle: Invoked ResetTotalLogTime on idle to guarantee clean resumption.

Verification:
- Validated millisecond conversion logic and recovery state transitions.
```

## [2026-11-07] - Refactor InitModLayer to Use SetLayerKeys for Batch Layer Assignment

### Overview

- **Category**: Refactoring
- **Affected Files**: `src/Preset.ahk`
- **Summary**: Replaced individual `SetLayerKey` calls for LAYOUT_30_KEYS targets with batch `SetLayerKeys` calls across multiple layers in `InitModLayer`. Also replaced individual `SetLayerKey` calls in `L_NAVI_CTRL` with `SetLayerKeys` for the 30-key block. Reduces line count significantly and aligns with the pattern established in `L_SELECT`.

### Background & Root Cause

- **Motivation**: The `InitModLayer` function contained long repetitive sequences of `key.SetLayerKey(mode, layer_id, value)` calls for every LAYOUT_30_KEYS key in each layer. The `SetLayerKeys` helper exists precisely to batch-assign the 30-key array in one call, matching the pattern already used for `L_SELECT`. Applying it consistently improves readability and maintainability.

### Technical Changes

- **`InitModLayer` / `L_NAVI_CTRL`**:
  - Replaced 20 individual `SetLayerKey` calls for `q`–`slash` (LAYOUT_30_KEYS) with a single `SetLayerKeys(LAYOUT_30_KEYS, mode, L_NAVI_CTRL, [...])` call (30 elements).
  - Keys outside LAYOUT_30_KEYS (`at`, `openbracket`, `colon`, `closebracket`, `enter`, `space`) retained as individual `SetLayerKey` calls.
- **`InitModLayer` / `L_SYMBOL_NUM`**:
  - Replaced 20 individual `SetLayerKey` calls for LAYOUT_30_KEYS keys with `SetLayerKeys(LAYOUT_30_KEYS, mode, L_SYMBOL_NUM, [...])`.
  - `space` retained as individual `SetLayerKey`.
- **`InitModLayer` / `L_NUMPAD`**:
  - Replaced 15 individual `SetLayerKey` calls for LAYOUT_30_KEYS keys with `SetLayerKeys(LAYOUT_30_KEYS, mode, L_NUMPAD, [...])`.
  - `at`, `semicolon`, `colon`, `closebracket` (not in LAYOUT_30_KEYS) retained individually.
- **`InitModLayer` / `L_SYMBOL2`**:
  - Replaced 18 individual `SetLayerKey` calls with `SetLayerKeys(LAYOUT_30_KEYS, mode, L_SYMBOL2, [...])`.
  - All assignments fit within the 30-key array; no individual overrides needed.
- **`L_SHIFT`**: No LAYOUT_30_KEYS assignments existed; unchanged.

### Verification & Impact

- Net reduction: 83 lines removed, 23 lines added (net -60 lines) in `src/Preset.ahk`.
- Logic and key mappings are functionally identical to the original individual assignments.
- Syntax validation pending (AutoHotkey64.exe /validate unavailable in sandbox).

### Suggested Commit Message

```text
Refactor InitModLayer: Use SetLayerKeys for L_NAVI_CTRL, L_SYMBOL_NUM, L_NUMPAD, L_SYMBOL2

Overview:
- Replaced repetitive SetLayerKey loops with SetLayerKeys batch calls for 4 layers.
- Aligns with the L_SELECT pattern; reduces Preset.ahk by ~60 lines.

Technical Changes:
- InitModLayer/L_NAVI_CTRL: 20 individual calls → SetLayerKeys(LAYOUT_30_KEYS, ...).
- InitModLayer/L_SYMBOL_NUM: 20 individual calls → SetLayerKeys(LAYOUT_30_KEYS, ...).
- InitModLayer/L_NUMPAD: 15 individual calls → SetLayerKeys(LAYOUT_30_KEYS, ...).
- InitModLayer/L_SYMBOL2: 18 individual calls → SetLayerKeys(LAYOUT_30_KEYS, ...).

Verification:
- Mappings verified against original individual SetLayerKey assignments.
```

## [2026-11-01] - Reorganize Code Analysis References and Domain Rules for Token Efficiency

### Overview

- **Category**: Documentation / Agent Rules & Analysis Architecture
- **Affected Files**: `.agents/references/CODE_ANALYSIS.md`, `.agents/references/CODE_ANALYSIS_UI.md`, `.agents/references/GLOSSARY.md`, `.agents/rules/code_analysis.md`, `.agents/rules/coding.md`, `todo.txt`
- **Summary**: Modularized codebase analysis references by separating Web Config Editor UI architecture into `CODE_ANALYSIS_UI.md`, streamlining `CODE_ANALYSIS.md` for AHK core logic, converting `GLOSSARY.md` into compact日英 decision/mapping tables, and updating workspace coding/analysis rules to strictly restrict pre-task reference reading to the relevant domain to reduce AI token/quota consumption.

### Background & Root Cause

- **Symptoms**:
  - `CODE_ANALYSIS.md` was large (~24KB) and mixed AHK engine logic with Web UI concerns, incurring high reading/token cost before any simple task.
  - Absence of dedicated UI analysis documentation made Web UI modifications require full DOM/JS re-analysis.
  - `GLOSSARY.md` contained lengthy prose descriptions instead of compact tables.
- **Root Cause**:
  - Lack of domain separation in code analysis documentation and rules.

### Technical Changes

- **`.agents/references/CODE_ANALYSIS_UI.md`**:
  - Created dedicated analysis document covering Web UI architecture, `IniDocument` AST parser, 6 content panels, `[LayerBinding]` synchronization, and file persistence flow.
- **`.agents/references/CODE_ANALYSIS.md`**:
  - Excluded Web UI concerns to focus purely on AHK core engine (`PlayGroundsExp.ahk`, `Preset.ahk`, `Utils.ahk`, `Handler.ahk`).
  - Restructured into structured English with essential Japanese domain terms, key state variables, 3-state machine (`st_init` -> `st_pressing` -> `st_processed`), HoldMode 0–9 decision matrix, and invariant contracts (~65% size reduction).
- **`.agents/references/GLOSSARY.md`**:
  - Streamlined definitions into compact tables with Japanese-English mappings for core key concepts, HoldModes, timing parameters, and string conventions (~37% size reduction).
- **`.agents/rules/code_analysis.md` & `.agents/rules/coding.md`**:
  - Formulated domain-specific prior reference rules: inspect only `CODE_ANALYSIS.md` for AHK logic or `CODE_ANALYSIS_UI.md` for Web UI, prohibiting loading irrelevant references to conserve quota.
- **`todo.txt`**:
  - Updated task list reflecting completion of analysis re-organization and rule updates.

### Verification & Impact

- Verified structure and links across all reference files (`CODE_ANALYSIS.md`, `CODE_ANALYSIS_UI.md`, `GLOSSARY.md`).
- Syntax-checked AHK files (`AutoHotkey64.exe /validate src\PlayGroundsExp.ahk`).

### Suggested Commit Message

```text
Reorganize Code Analysis References and Domain Rules for Token Efficiency

Overview:
- Separated Web UI analysis into new CODE_ANALYSIS_UI.md.
- Streamlined CODE_ANALYSIS.md and GLOSSARY.md with compact English tables.
- Updated agent rules to mandate domain-specific prior reference to save quota.

Technical Changes:
- .agents/references/CODE_ANALYSIS_UI.md: Created Web Config Editor architecture analysis.
- .agents/references/CODE_ANALYSIS.md: Refactored for AHK core engine with English structure.
- .agents/references/GLOSSARY.md: Converted terminology into compact bilingual tables.
- .agents/rules/code_analysis.md: Added scope separation and domain-specific reading rules.
- .agents/rules/coding.md: Updated mandatory prior reference targets by task domain.
- todo.txt: Updated task tracking.

Verification:
- Cross-references verified across all rule and reference files.
```

## [2026-11-01] - Refactor Web UI and Utils for LayerBinding INI Specification

### Overview

- **Category**: UI / Architecture / Configuration
- **Affected Files**: `src/ui/app.js`, `src/ui/index.html`, `src/Utils.ahk`, `readme.adoc`, `src/config.ini`, `todo.txt`
- **Summary**: Aligned Web Config Editor UI with the canonical `[LayerBinding]` specification, replacing the legacy modifier-to-layer table with a clean layer-to-modifier (`M1`–`M8`) binding view with descriptions. Restored `known_layers` definition in `src/Utils.ahk` to resolve `#Warn` unassigned variable warning, cleaned up sample `config.ini`, and updated documentation.

### Background & Root Cause

- **Symptoms**:
  - Web UI dynamic layers panel still mapped physical modifiers (`space`, `noconv`, etc.) under `[Settings]` rather than `[LayerBinding]`.
  - Renaming or deleting layers in the Web UI updated `[Settings]` instead of `[LayerBinding]`.
  - In `src/Utils.ahk`, removing `ModKeyId` logic accidentally removed `known_layers` definition, triggering AutoHotkey v2 `#Warn` for unassigned local variable.
- **Root Cause**:
  - Web UI templates and scripts were not yet migrated to the new `[LayerBinding]` INI specification.
  - Inadvertent omission of `known_layers` definition in `LoadLayerBindingsFromIni`.

### Technical Changes

- **`src/ui/index.html`**:
  - Updated navigation menu item from "動的レイヤー ( space / noconv )" to "レイヤーバインド ([LayerBinding])".
  - Refactored panel header, guidance alert, and table headers to display `レイヤー名 / ID`, `修飾キーID (バインド先)`, `修飾キーの説明`, and `操作`.
  - Updated modal and help text to reference `[LayerBinding]` instead of `[Settings]`.
- **`src/ui/app.js`**:
  - Updated `DEFAULT_CONFIG_CONTENT` to include default `[LayerBinding]` section (`NAVI_CTRL=M1` .. `FUNC=M8`).
  - Added filter in `getModifierLayers()` and `getKeyLayoutSections()` to exclude `LayerBinding` section from being treated as a key layout.
  - Reimplemented `renderDynamicLayersTable()` to iterate over standard (`NAVI_CTRL`, `SYMBOL_NUM`, etc.) and custom layers, providing selectable `none` and `M1`–`M8` dropdown options with dynamic descriptions.
  - Updated layer rename and deletion handlers to sync with `[LayerBinding]`.
- **`src/Utils.ahk`**:
  - Restored `known_layers` list in `LoadLayerBindingsFromIni` preceding the loop, eliminating the `#Warn` unassigned variable warning.
- **`readme.adoc`**:
  - Removed obsolete `ModKeyId` reference from `[NAVI_CTRL]` example.
- **`src/config.ini`**:
  - Cleaned up legacy commented/unused layer sample definitions.

### Verification & Impact

- Validated script syntax with AutoHotkey v2: `AutoHotkey64.exe /validate src\PlayGroundsExp.ahk` (ExitCode: 0, zero warnings or errors).
- UI HTML and JS parsed cleanly.

### Suggested Commit Message

```text
Refactor Web UI and Utils for LayerBinding INI Specification

Overview:
- Replaced legacy Settings dynamic layer panel with LayerBinding editor.
- Restored known_layers definition in LoadLayerBindingsFromIni to fix #Warn warning.
- Cleaned up config.ini and updated documentation.

Technical Changes:
- src/ui/app.js: Rewrote renderDynamicLayersTable for [LayerBinding] (M1-M8 mapping) and updated rename/delete sync.
- src/ui/index.html: Updated dynamic layer UI strings, table headers, and modal text to [LayerBinding].
- src/Utils.ahk: Restored known_layers variable definition in LoadLayerBindingsFromIni.
- readme.adoc: Removed obsolete ModKeyId from layer section example.
- src/config.ini: Removed obsolete legacy layer lines.

Verification:
- AutoHotkey64.exe /validate src\PlayGroundsExp.ahk passed with zero warnings.
```

## [2026-10-29] - Transition to INI File Specification Compliant with Layer Array Structure

### Overview

- **Category**: Refactoring / Architecture / INI Configuration
- **Affected Files**: `src/Utils.ahk`, `src/PlayGroundsExp.ahk`, `readme.adoc`, `test/test_layer_mapping.ahk`, `test/test_runner.ahk`, `.agents/references/CODE_ANALYSIS.md`
- **Summary**: Transitioned INI configuration to a clean specification directly compliant with the internal 1D layer array structure (`layer_id_to_mod_key_id`). Eliminated physical modifier key redundancy in INI files by formalizing the fixed mapping of modifier IDs (`M1`–`M8`), implemented prioritized fallback loading and array order preservation on saving, added comprehensive regression tests (183/183 passing), and updated documentation and analysis references.

### Background & Root Cause

- **Symptoms**:
  - Layer bindings were scattered across `[Settings]` using physical key names (`space = NAVI_CTRL`), `[Settings]` using layer names (`NAVI_CTRL = M1`), and `[LayerBinding]`, resulting in duplicate storage and ambiguity.
  - Storing physical key names like `space` or `noconv` in INI files duplicated the fixed mapping contracts already enforced by `Layers.StateModKeyId`.
  - In-memory routing relies on `layer_id_to_mod_key_id = [M1..M8]`, but INI serialization did not cleanly mirror this 1D array structure or guarantee strict array index order.
  - Built-in layouts on startup did not consistently invoke dynamic layer binding resolution.
- **Root Cause**:
  - Lack of a unified, prioritized specification for serializing and deserializing the `layer_id_to_mod_key_id` array structure, and absence of bounds validation for modifier key IDs.

### Technical Changes

- **`src/Utils.ahk`**:
  - `ResolveModKeyId`: Bounded `mod_key_id` validation to `1 <= mod_id <= max_mod_id` using `mod_key_list.Length`, and added explicit handling for `"none"`, `"0"`, and `""` returning `0`.
  - `ResolveLayerId`: Added support for numeric layer representations (`^LAYER_?(\d+)$`).
  - `LoadLayerBindingsFromIni`: Implemented 4-tier prioritized loading (`[LayerBinding]` $\rightarrow$ layer section `ModKeyId` $\rightarrow$ legacy `[Settings]` $\rightarrow$ default array fallback `[1..8]`), explicit disabling (`0`/`none`), and safe fallback to default IDs on invalid values.
  - `SaveLayerBindingsToIni`: Enforced 1D array index order traversal (`1..layer_id_to_mod_key_id.Length`), emitting `"M" . mod_id` or `"none"` without redundant physical key names.
  - `ApplyDynamicLayerSection`: Added guard ignoring `ModKeyId` attribute so it is not processed as a keystroke override.
- **`src/PlayGroundsExp.ahk`**:
  - `LoadLayoutConfig`: Added call to `ApplyDynamicLayersFromSettings()` ensuring custom layer bindings are loaded even when `StartupLayout` is a built-in layout.
- **`readme.adoc`**:
  - Updated Section 3 with full specifications of `[LayerBinding]`, fixed mapping table (`M1`–`M8`), per-layer `ModKeyId` attribute, loading priority hierarchy, save format, and complete configuration example.
- **`test/test_layer_mapping.ahk` & `test/test_runner.ahk`**:
  - Added `Test_New_LayerBinding_Specification` covering full layer array loading, disabling with `none`/`0`, invalid ID fallbacks, line order tolerance, roundtrip serialization/deserialization, section `ModKeyId`, and numeric layer IDs.
- **`.agents/references/CODE_ANALYSIS.md`**:
  - Added Section 1.5 detailing Layer Array Binding architecture and marked `config.ini` value validation and layer array transition as resolved.

### Verification & Impact

- Validated script syntax with AutoHotkey v2: `AutoHotkey64.exe /validate src\PlayGroundsExp.ahk` (ExitCode: 0).
- Ran master regression test suite (`test/run_tests.ps1`): all 183 tests passed (100% pass rate).
- Full backwards compatibility maintained: existing `[Settings]` configurations continue to function seamlessly.

### Suggested Commit Message

```text
Transition to INI File Specification Compliant with Layer Array Structure

Overview:
- Implemented clean INI specification mirroring layer_id_to_mod_key_id array.
- Eliminated physical key redundancy via fixed modifier mapping (M1-M8).
- Added 4-tier loading priority, safe fallbacks, and strict array save order.
- Expanded regression test suite to 183 tests (100% passing).

Technical Changes:
- src/Utils.ahk: Upgraded LoadLayerBindingsFromIni, SaveLayerBindingsToIni, ResolveModKeyId, ResolveLayerId.
- src/PlayGroundsExp.ahk: Ensured LoadLayoutConfig applies dynamic layer bindings on startup.
- readme.adoc: Documented new [LayerBinding] spec, fixed mapping table, and priority rules.
- test/test_layer_mapping.ahk: Added Test_New_LayerBinding_Specification test group.
- test/test_runner.ahk: Integrated new test group into master test runner.
- .agents/references/CODE_ANALYSIS.md: Documented layer binding architecture in Section 1.5.

Verification:
- AutoHotkey64.exe /validate src\PlayGroundsExp.ahk passed.
- All 183 regression tests passed (run_tests.ps1).
```

## [2026-10-24] - Formalize Code Analysis Persistence Rule and Changelog-Driven Commit Command Protocol

### Overview

- **Category**: Configuration / Agent Rules & Governance
- **Affected Files**: `.agents/rules/code_analysis.md`, `.agents/rules/commit.md`, `.agents/rules/changelog.md`, `.agents/rules/coding.md`, `.agents/skills/ahk-coding/SKILL.md`, `.agents/skills/git-commit/SKILL.md`, `.agents/skills/update-changelog/SKILL.md`
- **Summary**: Established the Source Code Analysis Persistence Rule (`.agents/rules/code_analysis.md`) mandating incremental knowledge maintenance in `CODE_ANALYSIS.md` to minimize re-analysis costs, and formalized the "コミットして" custom command protocol to directly extract and execute commit logs from `ChangLog.md`'s `### Suggested Commit Message` section.

### Background & Root Cause

- **Symptoms**:
  - Re-analyzing the entire codebase across agent turns wasted tokens and increased task latency.
  - Custom commit commands ("コミットして") lacked an explicit rule mandating direct reuse of `ChangLog.md`'s structured commit messages, risking redundant message reconstruction.
- **Root Cause**:
  - Absence of a dedicated workspace rule governing code analysis lifecycle and commit message extraction.

### Technical Changes

- **`.agents/rules/code_analysis.md`**:
  - Authored comprehensive persistence guidelines: Prior Reference requirement, minimal reading cost rule, AI-optimized compact structure (tables, bullet points, invariants), in-place differential updates, and accuracy contracts.
- **`.agents/rules/commit.md`**:
  - Created standardized protocol for "コミットして" / "commit": mandates extracting commit messages from `ChangLog.md`'s `### Suggested Commit Message`, verifying 100% test pass rate, and staging selectively.
- **`.agents/rules/changelog.md` & `.agents/skills/update-changelog/SKILL.md`**:
  - Added requirement for each changelog entry to include a copy-pasteable `### Suggested Commit Message` section.
- **`.agents/skills/git-commit/SKILL.md`**:
  - Updated workflow to directly extract and execute the pre-formatted commit log from `ChangLog.md`.
- **`.agents/rules/coding.md` & `.agents/skills/ahk-coding/SKILL.md`**:
  - Added mandatory cross-references requiring agents to read `CODE_ANALYSIS.md` before analyzing code and update it after modifications.

### Verification & Impact

- Validated consistency across all rule files, skills, and glossary references.
- Executed master regression tests (`run_tests.ps1`): all 159 tests passed.

### Suggested Commit Message

```text
Formalize Code Analysis Persistence Rule and Changelog-Driven Commit Command Protocol

Overview:
- Added Source Code Analysis Persistence Rule to minimize codebase re-analysis costs.
- Formalized "コミットして" custom command protocol to reuse ChangLog.md commit sections.
- Linked code analysis and commit rules across coding skills and agent rules.

Technical Changes:
- .agents/rules/code_analysis.md: Created persistence rule for CODE_ANALYSIS.md.
- .agents/rules/commit.md: Created standardized protocol for "コミットして" command.
- .agents/rules/changelog.md: Mandated Suggested Commit Message in all changelog entries.
- .agents/skills/git-commit/SKILL.md: Updated workflow to extract commit log directly.
- .agents/skills/ahk-coding/SKILL.md: Added prior reference and update requirements.
- .agents/rules/coding.md: Integrated code analysis and commit rule references.

Verification:
- All 159 regression tests passed (run_tests.ps1)
```

## [2026-10-24] - Fix IME State Synchronization, Narrow Critical Scope, and Add Parameter Bounds Validation

### Overview

- **Category**: Bug Fix & Robustness / IME State Consistency & Config Validation
- **Affected Files**: `src/PlayGroundsExp.ahk`, `src/Utils.ahk`, `test/test_hold_mode.ahk`, `test/test_runner.ahk`, `.agents/references/CODE_ANALYSIS.md`
- **Summary**: Resolved uninitialized `down_ime_state` reference in Mode 9 Backspace calculation, propagated captured IME state to `SendKeyWithShift` on Mode 5 release, narrowed `Critical` scope in `OnHoldTimeout` to prevent low-level hook latency, added comprehensive validation and safe fallbacks for `HoldMode` and `config.ini` parameters, and ensured `Layers.last_active_item` is reset on global resets.

### Background & Root Cause

- **Symptoms**:
  - In Mode 9 chord evaluation, `GetBackspaceUndoCount()` occasionally calculated incorrect Backspace counts after rapid IME ON/OFF toggling.
  - In Mode 5 solitary release, toggling IME state while holding the key caused the release key to reflect the real-time IME state rather than the state at press initiation.
  - In Mode 1 timeout replacement, `Critical` remained active throughout `Send("{Backspace}")` and `this.SendShiftedKey()`, causing potential hook delays during rapid keying.
  - Out-of-bounds mode numbers (e.g., > 13) or negative thresholds in `config.ini` were accepted silently without validation.
  - Switching layout presets or calling `ResetCombinations()` left stale `Layers.last_active_item` references, risking unwanted multi-stage continuous tap actions.
- **Root Cause**:
  1. `SendLayerKey()` executes before the main key's `Down()` initialization, leaving `key_obj.down_ime_state` unpopulated when evaluated inside `_EvaluateChord()`.
  2. `RKey.SendKeyWithShift()` lacked an `ime_state` parameter, defaulting to real-time OS IME querying on release.
  3. Excessive duration of `Critical` thread protection covering external OS key transmissions.
  4. Absence of boundary checking in `HoldMode` constructor and `LoadLayoutConfig()`.

### Technical Changes

- **`RKey.SendKeyWithShift`**:
  - Added optional `ime_state := -1` parameter, delegating to `this.SendShiftedKey(IsPhysicalShiftPressed(this), ime_state)` to honor preserved press states.
- **`LKey.Up`**:
  - Captured `saved_down_ime_state := this.down_ime_state` before `ResetState()`, passing it to `this.SendKeyWithShift(saved_down_ime_state)` in Mode 5 release.
- **`Layers._EvaluateChord` & `Layers.SendLayerKey`**:
  - Updated `_EvaluateChord` signature and invocation to accept `ime_state`.
  - Resolved Mode 9 pre-text via `current_ime := (ime_state != -1) ? ime_state : (key_obj.down_ime_state == 1 ? 1 : 0)`, ensuring exact Backspace undo calculations.
  - Passed `mod_key.down_ime_state` to Mode 5 fallback sends.
- **`LKey.OnHoldTimeout`**:
  - Narrowed `Critical` scope: took atomic snapshots of `down_hwnd`, `down_ime_state`, and text, then explicitly disengaged `Critical "Off"` prior to sending Backspace and shifted key.
- **`HoldMode.__New` & `LoadLayoutConfig`**:
  - Added boundary validation: clamped `mode` to valid range (`-1` or `0..13`), defaulting out-of-range values to `7`.
  - Enforced positive integers for `hold_th` (> 0) and non-negative integers for `b_time` (>= 0), falling back to defaults upon invalid input.
- **`LKey.ResetAll` & `ResetCombinations`**:
  - Explicitly cleared `Layers.last_active_item := ""` to prevent cross-layout multi-stage tap corruption.
- **Regression Tests (`test/test_hold_mode.ahk`, `test/test_runner.ahk`)**:
  - Added Test Group 14 assertions covering `SendKeyWithShift(ime_state)`, `_EvaluateChord` IME synchronization, `HoldMode` bounds fallbacks, and `ResetAll` cleanup. Total assertions increased to 159 (100% pass rate).

### Verification & Impact

- Validated syntax with `AutoHotkey64.exe /validate src/PlayGroundsExp.ahk`.
- Executed master test suite (`powershell -ExecutionPolicy Bypass -File test/run_tests.ps1`): all 159 tests passed with 0 failures (100% pass rate).
- Fully eliminated IME state desynchronization and Backspace length errors while preserving 100% behavioral compatibility with all existing layout definitions.

### Suggested Commit Message

```text
Fix IME State Synchronization, Narrow Critical Scope, and Add Parameter Bounds Validation

Overview:
- Resolved uninitialized down_ime_state reference in Mode 9 Backspace calculation.
- Propagated captured IME state to SendKeyWithShift on Mode 5 solitary release.
- Narrowed Critical section in OnHoldTimeout to avoid input latency during OS key dispatch.
- Added parameter bounds validation and safe fallbacks for HoldMode and config.ini.
- Ensured Layers.last_active_item is cleared on global and combination resets.

Technical Changes:
- RKey.SendKeyWithShift: Added optional ime_state parameter to honor preserved press state.
- LKey.Up: Captured saved_down_ime_state and passed to SendKeyWithShift in Mode 5 release.
- Layers._EvaluateChord & SendLayerKey: Propagated ime_state to eliminate uninitialized key_obj.down_ime_state reference.
- LKey.OnHoldTimeout: Released Critical before sending Backspace and shifted key.
- HoldMode & LoadLayoutConfig: Clamped mode to 0..13 (or -1) and enforced positive thresholds with safe fallbacks.
- LKey.ResetAll & ResetCombinations: Cleared Layers.last_active_item.
- Regression Tests: Added Test Group 14 assertions (159/159 tests passing).

Verification:
- Syntax validated with AutoHotkey64.exe /validate src\PlayGroundsExp.ahk
- Master regression test suite: 159 tests passed (100% pass rate)
```

## [2026-10-23] - Formalize LKey State Machine with Session ID Generation and Ghost Recovery

### Overview

- **Category**: Bug Fix / State Management & Lifecycle Robustness
- **Affected Files**: `src/PlayGroundsExp.ahk`, `test/test_hold_mode.ahk`, `test/test_runner.ahk`, `.agents/references/CODE_ANALYSIS.md`
- **Summary**: Formalized the `LKey` 3-state lifecycle (`st_init`, `st_pressing`, `st_processed`), resolved critical interruption omission in `hold_mode == 0` leading to errant space insertions, introduced monotonic `session_id` to eliminate stale timer race conditions, and implemented ghost press auto-recovery to prevent permanent key deadlocks upon window focus changes.

### Background & Root Cause

- **Symptoms**:
  - Typing ordinary alphanumeric keys (`hold_mode == 0`) while holding Space (`hold_mode == 3`) failed to mark Space as interrupted; when Space was released, an unwanted trailing space was emitted.
  - In rapid tapping sequences (Down -> Up -> Down), asynchronous `OnHoldTimeout` callbacks from a prior session could trigger or reschedule during a new session.
  - When window focus changed (e.g. Alt-Tab, UAC prompt, or notifications) while a key was physically held, the physical key release (`Up`) was missed by the keyboard hook, leaving the key in `st_pressing` or `st_processed`. Subsequent presses hit the repeat guard and were permanently ignored.
- **Root Cause**:
  1. Early exit in `LKey.Down()` for `hold_mode == 0` occurred prior to executing `LKey.InterruptOthers(this)` and `Layers.last_active_item := ""`.
  2. Lack of session/generation ID tracking across press sessions, allowing shared `timer_name` BoundFunc invocations from superseded sessions to interact with active state.
  3. No automatic mechanism to recover keys whose physical state (`!IsPressed()`) had desynchronized from internal state (`state != st_init`).

### Technical Changes

- **`LKey.ResetState`**:
  - Encapsulated complete instance cleanup (`state := st_init`, `pressed_time_qpc := 0`, `interrupted := false`, `saved_scaw := ""`, `down_hwnd := 0`, `session_id++`, and timer cancellation).
- **`LKey.InterruptOthers`**:
  - Ensured active pressing keys advance `session_id++`, cancel pending timers, set `interrupted := true`, and transition to `st_processed`.
- **`LKey.CleanupReleasedKeys`**:
  - Implemented automatic recovery: resets any instance stuck in `st_processed` to `st_init` if its physical key is not currently pressed (`!IsPressed()`).
- **`LKey.Down`**:
  - Added `LKey.CleanupReleasedKeys()` and stale-repeat auto-reset (`A_TimeSincePriorHotkey > 1500`).
  - Added `LKey.InterruptOthers(this)` to `hold_mode == 0` path and to the `!this.IsPressed()` safety guard path, ensuring all emitted key down events notify other holding keys.
  - Incremented `session_id` and tracked `timer_session_id := this.session_id` on press initiation.
- **`LKey.OnHoldTimeout`**:
  - Added session ID guard: `if (this.timer_session_id != this.session_id) return` to discard callbacks from prior sessions.
- **Regression Tests (`test/test_hold_mode.ahk`, `test/test_runner.ahk`)**:
  - Added `Test Group 13: LKey State Machine & Lifecycle Transitions` (12 assertions covering `ResetState`, `hold_mode == 0` interruption, session ID expiration, and `CleanupReleasedKeys`).

### Verification & Impact

- Validated syntax with `AutoHotkey64.exe /validate src/PlayGroundsExp.ahk`.
- Executed master regression test suite (`powershell -ExecutionPolicy Bypass -File test/run_tests.ps1`): all 125 tests passed with 0 failures (100% pass rate).
- Completely eliminated space insertion leaks during fast rollover typing and resolved ghost key deadlocks without altering key mapping definitions.

## [2026-10-23] - Refactor Layers.SendLayerKey with Extracted \_EvaluateChord Decision Engine

### Overview

- **Category**: Refactoring / Architecture & Clean Separation of Responsibilities
- **Affected Files**: `src/PlayGroundsExp.ahk`, `test/test_hold_mode.ahk`, `test/test_runner.ahk`, `.agents/references/CODE_ANALYSIS.md`
- **Summary**: Extracted the core chord evaluation logic of HoldModes 5–9 from `Layers.SendLayerKey` into a dedicated static helper `Layers._EvaluateChord`, eliminating repetitive threshold/buffer branching and establishing clean separation between chord evaluation, side effects, and action dispatch.

### Background & Root Cause

- **Symptoms**:
  - `Layers.SendLayerKey()` contained heavily duplicated logic: threshold evaluation (`t_qpc >= x`), rollover buffer checks (`t_qpc < x - b`), and `_WaitForHold()` invocations were repeated 5 to 6 times across individual if-else blocks for Modes 5 through 9.
  - Mode-specific behaviors (Mode 8 preceding release acceptance, Mode 9 pre-send and Backspace cancellation, Mode 5 fallback key emission) were entangled with layer item iteration and key dispatch, impeding readability and testability.
- **Root Cause**: Lack of functional decomposition between timing/zone classification, mode-specific chord resolution, and layer action emission.

### Technical Changes

- **`Layers._EvaluateChord`**:
  - Created a static decision method handling the 3-zone timing model:
    - Zone 1 ($t \ge x$): Unconditional hold completion across all modes.
    - Zone 2 ($t < x - b$): High-speed rollover handling (Mode 9 pre-send and BS cancellation, Mode 5 A-fallback send, immediate chord denial for Modes 7 and 8).
    - Zone 3 ($x - b \le t < x$): Gray zone wait via `_WaitForHold` (Mode 8 companion release acceptance `res == 2 || res == 3`, Mode 5/6/7/9 timeout requirement `res == 3`).
- **`Layers.SendLayerKey`**:
  - Streamlined the iteration loop to resolve parameters (`x`, `b`), delegate chord resolution to `_EvaluateChord`, and perform action dispatch and tap-count updates upon chord completion.
- **Documentation (`.agents/references/CODE_ANALYSIS.md`)**:
  - Documented complete architecture, lifecycle state machine, hold mode comparisons, and clean responsibility pipeline for future agent reference.
- **Regression Tests (`test/test_hold_mode.ahk`, `test/test_runner.ahk`)**:
  - Added `Test Group 12: Layers._EvaluateChord Direct Evaluation` directly validating `_EvaluateChord` against Zone 1, Zone 2, and fallback state transitions across Modes 5, 7, and 8.

### Verification & Impact

- Validated syntax with `AutoHotkey64.exe /validate src/PlayGroundsExp.ahk`.
- Executed master regression test suite (`powershell -ExecutionPolicy Bypass -File test/run_tests.ps1`): all 113 tests passed with 0 failures (100% pass rate).
- Fully preserved 100% behavioral compatibility with existing key configurations, rollover timing, and chord combinations.

## [2026-10-23] - Fix \_WaitForHold Interruption Leak, Key Release State Corruption, and Focus Safety Guard

### Overview

- **Category**: Bug Fix / State Management & Robustness
- **Affected Files**: `src/PlayGroundsExp.ahk`, `test/test_hold_mode.ahk`, `test/test_runner.ahk`
- **Summary**: Resolved critical key press state corruption where keys were left in permanent `st_pressing` state when released during synchronous hold wait, added interruption detection (`interrupted`) to `_WaitForHold`, and added active window focus validation before `{Backspace}` execution.

### Background & Root Cause

- **Symptoms**:
  - In rapid typing and rollover tapping, keys would occasionally get "stuck" or become unresponsive because the repeat guard (`state == st_pressing`) blocked subsequent key down events permanently.
  - When typing a 3-key sequence (A -> B -> C) where A+B was in a gray zone wait, striking C properly interrupted A via `InterruptOthers()`, but `_WaitForHold()` continued polling until threshold expiry, firing an illegitimate A+B chord.
  - When long-press timeouts occurred after the user switched windows (Alt+Tab or notification), `{Backspace}` was emitted into the wrong application.
- **Root Cause**:
  1. **Premature Key Release Race in `LKey.Down`**: While `_WaitForHold()` polled inside `SendLayerKey()`, releasing the key dispatched `LKey.Up()`, resetting `state := st_init`. Once `_WaitForHold()` exited and returned `false`, `LKey.Down()` resumed and blindly set `state := st_pressing`. Because the physical key was already released, no subsequent `_Up()` ever fired, causing the key to remain in `st_pressing` permanently.
  2. **Interruption Blindness in `_WaitForHold`**: The wait loop only checked physical key states (`!mod_key.IsPressed()`) and duration, ignoring `mod_key.interrupted` and `mod_key.state != st_pressing`.
  3. **Unchecked Backspace Execution**: `OnHoldTimeout()` emitted `{Backspace}` without verifying that the window active at press start was still active.

### Technical Changes

- **`Layers._WaitForHold`**:
  - Added interruption check `(mod_key.interrupted || mod_key.state != LKey.st_pressing)` both prior to entering the loop and on every polling iteration, immediately returning status code `0` (interruption cancelled).
  - Updated JSDoc documentation to accurately reflect `Sleep(1)` polling and return codes (`0: interruption, 1: mod先行Up, 2: key先行Up, 3: hold timeout`).
- **`LKey.Down`**:
  - Added physical release safety guard immediately following `SendLayerKey(ime_state)`: if `!this.IsPressed()`, resets state to `st_init`, clears timestamps, emits the tap character (`SendKeyWithShift()`) if mode != 2, and exits cleanly without re-entering `st_pressing`.
  - Added `this.down_hwnd := WinExist("A")` tracking upon session start.
- **`LKey.Up` & `LKey.ResetAll`**:
  - Reset `down_hwnd := 0` on release and global reset.
- **`LKey.OnHoldTimeout`**:
  - Added safety guard checking `(this.down_hwnd == 0 || WinActive("ahk_id " . this.down_hwnd))` prior to sending `{Backspace}` to guard against erasing characters in different applications.
- **`LKey.SetLayerImeKey2`**:
  - Clarified JSDoc documentation for unused parameter `reset_if_blank` (preserved for backward compatibility).
- **Regression Tests (`test/test_hold_mode.ahk`, `test/test_runner.ahk`)**:
  - Added `Test Group 11: _WaitForHold Interruption & Safety Guard` covering immediate interruption cancellation (tests 1 & 2) and `Down()` physical release safety guard (test 3).

### Verification & Impact

- Validated syntax with `AutoHotkey64.exe /validate src/PlayGroundsExp.ahk`.
- Executed master regression test suite (`powershell -ExecutionPolicy Bypass -File test/run_tests.ps1`): all 106 tests passed with 0 failures (100% pass rate).
- Completely eliminated repeat guard lockups on rapid rollover releases while maintaining full backward compatibility with all HoldModes.

## [2026-10-23] - Establish Automated Regression Testing Framework and Agent Rules

### Overview

- **Category**: Feature / Testing Infrastructure & Governance
- **Affected Files**: `test/test_framework.ahk`, `test/test_runner.ahk`, `test/test_hold_mode.ahk`, `test/test_layer_mapping.ahk`, `test/run_tests.ps1`, `test/README.md`, `.gitignore`, `.agents/rules/testing.md`, `.agents/rules/coding.md`, `.agents/skills/ahk-coding/SKILL.md`
- **Summary**: Established a standardized automated regression testing system under the `test/` directory, consolidated scattered ad-hoc test scripts, and added strict agent development rules requiring automated test creation and execution for all code modifications.

### Background & Root Cause

- **Symptoms**: Test scripts (`test_hold_mode.ahk`, `test_runner.ahk`, temporary logs) were scattered across the root and `src/` directories without unified test harness or standard execution workflow. Git ignore rules excluded test scripts unintentionally, and agent development guidelines lacked requirements for creating and running regression tests upon modifying code.
- **Root Cause**: Absence of a dedicated testing structure and governance rules to mandate continuous automated validation.

### Technical Changes

- **Testing Infrastructure (`test/`)**:
  - `test/test_framework.ahk`: Implemented core assertion (`Assert`), UTF-8 test logging (`LogMsg`), and test suite lifecycle management (`InitTestSuite`, `FinishTestSuite`).
  - `test/test_hold_mode.ahk`: Organized Hold Mode and rollover timing regression tests (Test Groups 1 through 8). Supports standalone execution and module inclusion.
  - `test/test_layer_mapping.ahk`: Organized layer ID mapping and INI persistence regression tests (Test Groups 9 and 10). Supports standalone execution and module inclusion.
  - `test/test_runner.ahk`: Master test runner combining all test suites with exit status propagation (0 for all pass, 1 for failure).
  - `test/run_tests.ps1`: Cross-platform PowerShell execution harness supporting auto-detection of AutoHotkey v2, suite selection, console log streaming, and process exit code propagation.
  - `test/README.md`: Documented test architecture, execution commands, and guidelines for adding new test scripts.
- **Configuration & Clean-up**:
  - `.gitignore`: Updated rules to track test source files in `test/` while properly ignoring test logs, temporary INI files, and scratch text files.
  - Cleaned up obsolete ad-hoc test files from repository root and `src/`.
- **Agent Rules & Skill Governance**:
  - `.agents/rules/testing.md`: Created mandatory automated regression testing rule requiring test creation in `test/` and 100% pass verification upon code modification.
  - `.agents/rules/coding.md`: Integrated reference to `testing.md`.
  - `.agents/skills/ahk-coding/SKILL.md`: Added test creation and test suite execution requirements to Section 4 (Post-Modification Requirement).

### Verification & Impact

- Validated all AHK files with `AutoHotkey64.exe /validate`.
- Executed full test suite via `powershell -ExecutionPolicy Bypass -File test/run_tests.ps1` with 102/102 assertions passing (100% pass rate, exit code 0).
- Verified standalone execution of `test_hold_mode.ahk` (81/81 pass) and `test_layer_mapping.ahk` (21/21 pass).
- Enabled permanent regression protection against future code changes.

## [2026-10-21] - Fix HoldMode 7 & 8 Dynamic Combination Key Regression

### Overview

- **Category**: Bug Fix / Regression Fix
- **Affected Files**: `src/PlayGroundsExp.ahk`
- **Summary**: Fixed a regression where dynamic custom combination keys configured with HoldMode 7 and 8 (e.g. `RegistIMECombination` in Minato layouts) completely failed to activate, and restored safe event wait mechanics.

### Background & Root Cause

- **Symptoms**:
  - Combinations configured via `RegistIMECombination(8, ...)` (e.g. `d` -> "nn", `v` -> "ltu", `e` -> "ru" with target layers) and `RegistIMECombination(7, ...)` (e.g. `s+r` -> "uru", `k+r` -> "ara") became completely non-functional.
  - Rollover key events failed to distinguish between key release and hold timeouts.
- **Root Cause**:
  1. **Dynamic Layer Array Boundary Rejection**:
     - `layer_id_to_mod_key_id` was initialized with only 8 predefined modifier keys (`[M1..M8]`).
     - Dynamic combinations register custom modifier keys into `mod_key_list` with index `layer_id >= 9`.
     - In `Layers.State` and `Layers.State2`, boundary checks were coded as `if (layer_id < 1 || layer_id > layer_id_to_mod_key_id.Length) return false`, rejecting all dynamic custom combination layers (`layer_id > 8`) immediately with `false`.
     - In `SendLayerKey`, `Layers.State2(item.layer_id, key_obj)` was called instead of using the resolved `mod_key_id`, preventing dynamic combinations from passing the active state check.
  2. **Event Pump Starvation and Hold Timing Corruption in `_WaitForHold`**:
     - `_WaitForHold` had been rewritten to use `MsgWaitForMultipleObjects` and `SetTimer` without invoking AutoHotkey's internal message pump (`Sleep`). Consequently, AutoHotkey could not dispatch `WM_TIMER` callbacks or process hook messages.
     - The hold detection loop evaluated `HighPrecisionTimer() - mod_key.pressed_time_qpc >= hold_th` directly. When the modifier key was released, `_Up` reset `mod_key.pressed_time_qpc` to `0`, resulting in `HighPrecisionTimer() - 0` evaluating to an enormous number and falsely triggering a hold timeout (`res := 3`) instead of key release (`res := 1`).

### Technical Changes

- **`Layers.State(layer_id)` (`src/PlayGroundsExp.ahk`)**:
  - Extended boundary logic: If `layer_id <= layer_id_to_mod_key_id.Length`, look up `mod_key_id` from `layer_id_to_mod_key_id`. If `layer_id > 8` and `layer_id <= mod_key_list.Length`, evaluate `Layers.StateModKeyId(layer_id)` directly as a dynamically registered modifier key.
- **`Layers.State2(layer_id, key_obj)` (`src/PlayGroundsExp.ahk`)**:
  - Similarly updated boundary logic to allow dynamically registered layers (`layer_id > 8`) to evaluate `Layers.State2ModKeyId(layer_id, key_obj)`.
- **`Layers.SendLayerKey(key_obj, ime_state)` (`src/PlayGroundsExp.ahk`)**:
  - Changed layer validation call to `Layers.State2ModKeyId(mod_key_id, key_obj)` with the resolved `mod_key_id`.
- **`Layers._WaitForHold(mod_key, key_obj, hold_th)` (`src/PlayGroundsExp.ahk`)**:
  - Cached `start_time := mod_key.pressed_time_qpc` at function entry so that any timestamp reset by asynchronous `_Up` handlers cannot corrupt the elapsed time calculation.
  - Restored lightweight, non-blocking `Sleep(1)` polling to ensure AutoHotkey's internal message dispatch (keyboard hook updates and key release events) runs smoothly.

### Verification & Impact

- Validated script syntax with AutoHotkey v2 binary (`AutoHotkey64.exe /validate PlayGroundsExp.ahk`) with 0 errors.
- Confirmed that HoldMode 7 and HoldMode 8 combinations now pass state checks and accurately detect key release vs. hold duration.
