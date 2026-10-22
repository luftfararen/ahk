---
name: ahk-coding
description: >-
  Use this skill whenever designing, writing, modifying, refactoring, or debugging AutoHotkey v2 scripts in this project. Requires consulting the project glossary (GLOSSARY.md) to ensure compliance with domain concepts, key state lifecycles, and hold mode mechanics.
---

# AutoHotkey Coding & Development Skill

This skill defines the technical guidelines and mandatory references for implementing and maintaining code in the **Playgrounds** project.

## MANDATORY: Consult Project Glossary / 単語集の参照義務

Whenever you plan, write, modify, or debug source code in this project, **you MUST reference the project glossary**:
- **[GLOSSARY.md / 開発用語集](../../references/GLOSSARY.md)** (Local path: `.agents/references/GLOSSARY.md`)

This glossary contains the authoritative bilingual definitions and behavioral contracts for:
1. **Key Architecture**: `RKey`, `LKey`, Key States (`st_init`, `st_pressing`, `st_processed`), CAW Pass-Through, Physical vs Space Shift.
2. **Hold Modes**: Exact timing contracts and rollover resolution algorithms for Mode 0 through Mode 13 (especially Mode 7, Mode 8, and Mode 9).
3. **Timing Parameters**: `hold_th`, `LayerHoldTh`, `b_time`, `b_time2`, `pre_stroke_buf`, `HighPrecisionTimer`.
4. **Layer & Modifier Routing**: `mod_key_id` (M1–M8), `layer_id_to_mod_key_id`, dynamic layers (`layer_id > 8` up to `mod_key_list.Length`).
5. **Chording & Combinations**: `RegistCombination`, `RegistIMECombination`, physical key prefixes (`Pf`).
6. **Prefix Conventions**: `R_...` (raw string), `C_...` (send string), `B_...` (blind send string).

---

## Core Development Guidelines

### 1. Key State Lifecycle Contract
- Any key press begins at `st_init` -> `st_pressing` on `_Down()`.
- If an action or layer key is transmitted, the key transitions to `st_processed` to avoid re-triggering default actions on release (`_Up()`).
- In `_Up()`, states are reset to `st_init`, and timestamp `pressed_time_qpc` is cleared.
- Always cache `start_time := mod_key.pressed_time_qpc` before entering polling loops (such as `_WaitForHold`) to prevent timestamp corruption if `_Up()` executes concurrently.

### 2. Layer & Combination Routing Contract
- Standard predefined layers use `layer_id` 1 to 8 mapped via `layer_id_to_mod_key_id`.
- Dynamic key combinations (e.g. `RegistIMECombination`) register trigger keys at `layer_id >= 9` in `mod_key_list`.
- **CRITICAL**: Never restrict layer validation bounds to `layer_id_to_mod_key_id.Length`. Always allow `layer_id <= mod_key_list.Length` to validate dynamic modifier states via `Layers.StateModKeyId(mod_key_id)` or `Layers.State2ModKeyId(mod_key_id, key_obj)`.

### 3. Event Loop & Polling Rules
- In AutoHotkey v2, low-level keyboard hooks and timers require the internal message pump to run.
- Do NOT replace `Sleep(1)` in wait loops with non-pumping Win32 calls like `MsgWaitForMultipleObjects` unless you explicitly dispatch incoming messages. `Sleep(1)` yields the CPU timeslice safely while allowing AHK to process keyboard hook events and key releases.

### 4. Post-Modification Requirement
- After any code modification, validate syntax using:
  ```powershell
  & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' /validate src\PlayGroundsExp.ahk
  ```
- **Automated Regression Testing**:
  - Create new or update existing test cases in the `test/` directory to cover the modified behavior and guard against regressions.
  - Execute both new and existing tests via the master test runner:
    ```powershell
    powershell -ExecutionPolicy Bypass -File test/run_tests.ps1
    # or
    & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' test/test_runner.ahk
    ```
  - Verify that 100% of tests pass (exit code 0, 0 failures).
- Invoke the `update-changelog` skill to document all technical changes in English in `ChangLog.md`.
