# Changelog

All notable changes to this project will be documented in this file.
The format is maintained in English with comprehensive technical details.

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
