---
name: update-changelog
description: >-
  Use this skill whenever source code, scripts, or configuration files in the project are modified, added, refactored, or fixed. Guides the agent to record detailed technical changes in English into ChangLog.md at the repository root.
---

# Update Changelog Skill

This skill defines the workflow and guidelines for documenting all source code modifications in `ChangLog.md` located at the root of the repository (`C:\src\ahk\ChangLog.md`).

## Core Rules

1. **Language**: All entries in `ChangLog.md` MUST be written in **English**.
2. **Target File**: `ChangLog.md` at the project root (`C:\src\ahk\ChangLog.md`).
3. **Timing**: Update `ChangLog.md` whenever files (`.ahk`, `.ini`, etc.) are modified, added, or removed.
4. **Detail Level**: Entries must be **detailed and thorough**. Do NOT just write a one-liner summary. Explain:
   - What changed
   - Why it changed (background, symptoms, motivation, or root cause)
   - How it was resolved technically (affected functions, classes, logic flow, boundary condition changes)
   - Verification and impact
5. **Terminology**: When describing technical changes, consult and strictly use the official domain terms defined in the [Project Glossary (GLOSSARY.md)](../../references/GLOSSARY.md).

---

## Workflow Steps

### Step 1: Analyze Changes
Examine the modified files and git diff:
```powershell
git status
git diff
```
Identify:
- Which files were modified
- The functional category (Bug Fix, Feature, Performance, Refactoring, Config)
- The technical root cause and exact lines/functions changed

### Step 2: Draft the Changelog Entry
Draft the entry following the standardized format below in professional technical English.

### Step 3: Update `ChangLog.md`
- If `ChangLog.md` is empty or missing, create it with the main `# Changelog` header.
- Always insert the new entry at the top (right after the header / below `# Changelog`), in reverse chronological order.
- Preserve all existing entries.

### Step 4: Verify
- Check that all file names, class names, and method names are accurately formatted with backticks or links.
- Ensure the tone is objective, precise, and clear.

---

## Standard Entry Format

```markdown
## [YYYY-MM-DD] - <Concise Title of the Change>

### Overview
- **Category**: Bug Fix | Feature | Performance Optimization | Refactoring | Configuration
- **Affected Files**: `src/PlayGroundsExp.ahk`, etc.
- **Summary**: High-level explanation of what was achieved.

### Background & Root Cause
- **Symptoms**: What was broken, missing, or degraded.
- **Root Cause**: The underlying technical issue (e.g., array bounds, thread blocking, unhandled state).

### Technical Changes
- **`ClassName.MethodName` / `FunctionName`**:
  - Detailed explanation of what was changed in the code.
  - Explain specific conditional branches, algorithm updates, or API replacements.

### Verification & Impact
- Validation results (syntax checking, test execution, manual verification).
- Expected behavioral outcome and edge cases handled.
```

---

## Example Entry

```markdown
## [2026-10-21] - Fix HoldMode 7 and 8 Regression in PlayGroundsExp.ahk

### Overview
- **Category**: Bug Fix / Regression Fix
- **Affected Files**: `src/PlayGroundsExp.ahk`
- **Summary**: Resolved an issue where dynamic key combinations configured with HoldMode 7 and 8 failed to trigger.

### Background & Root Cause
- **Symptoms**: Combinations configured in `Minato2` and `Preset.ahk` (e.g., `RegistIMECombination(8, ...)`, `m_s_Pf = 7,...`) stopped functioning completely.
- **Root Cause**:
  1. `Layers.State` and `Layers.State2` restricted `layer_id` checks to `layer_id <= layer_id_to_mod_key_id.Length` (size 8). Dynamic combinations register modifier keys into `mod_key_list` at index 9+, causing immediate rejection (`false`).
  2. `Layers._WaitForHold` used `MsgWaitForMultipleObjects` and `SetTimer` without calling AHK message pump (`Sleep`), preventing timer callbacks and hook updates. Furthermore, referencing `mod_key.pressed_time_qpc` directly in the loop caused false positive hold timeouts when `_Up` reset the timestamp to 0.

### Technical Changes
- **`Layers.State` & `Layers.State2`**:
  - Updated boundary checks so that `layer_id > 8` up to `mod_key_list.Length` evaluates `Layers.StateModKeyId(layer_id)`.
- **`Layers.SendLayerKey`**:
  - Directly invoked `Layers.State2ModKeyId(mod_key_id, key_obj)` with the resolved `mod_key_id`.
- **`Layers._WaitForHold`**:
  - Cached `start_time := mod_key.pressed_time_qpc` to prevent timestamp reset corruption.
  - Replaced `MsgWaitForMultipleObjects` with safe `Sleep(1)` polling to ensure AHK message dispatch.

### Verification & Impact
- Validated syntax with `AutoHotkey64.exe /validate`.
- Restored HoldMode 7 and 8 rollover and hold detection functionality.
```
