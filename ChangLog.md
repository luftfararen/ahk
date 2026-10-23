# Changelog

All notable changes to this project will be documented in this file.
The format is maintained in English with comprehensive technical details.

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

## [2026-10-23] - Refactor Layers.SendLayerKey with Extracted _EvaluateChord Decision Engine

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

## [2026-10-23] - Fix _WaitForHold Interruption Leak, Key Release State Corruption, and Focus Safety Guard

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
