# Changelog

All notable changes to this project will be documented in this file.
The format is maintained in English with comprehensive technical details.

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
